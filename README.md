# devops

Infrastructure as Code for [ivanpashkulev.com](https://ivanpashkulev.com). This repository contains everything needed to deploy and run the full stack on a server — Docker Compose service definitions, nginx reverse proxy configuration, and Cloudflare Worker code.

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │           Cloudflare Edge            │
                    │                                      │
  Browser ─HTTPS──▶│  Worker (maintenance fallback)       │
                    │         │                            │
                    │         ▼                            │
                    │  Cloudflare Tunnel (cloudflared)     │
                    └──────────────┬──────────────────────┘
                                   │ HTTP (outbound tunnel)
                    ┌──────────────▼──────────────────────┐
                    │           Ubuntu AMD64 VM            │
                    │                                      │
                    │  ┌─────────────────────────────┐    │
                    │  │         nginx:alpine         │    │
                    │  │   :80 (reverse proxy)        │    │
                    │  └────────┬────────────┬────────┘    │
                    │           │            │             │
                    │    /api/* │            │ /*          │
                    │           ▼            ▼             │
                    │  ┌──────────────┐ ┌──────────────┐  │
                    │  │  api-main    │ │  web-main    │  │
                    │  │  FastAPI     │ │  Vite Preview│  │
                    │  │  :8000       │ │  :4173       │  │
                    │  └──────┬───────┘ └──────────────┘  │
                    └─────────┼────────────────────────────┘
                              │ HTTPS
                    ┌─────────▼────────────────────────────┐
                    │             OpenAI API               │
                    │             gpt-4o-mini              │
                    └──────────────────────────────────────┘
```

## How It Works

**Traffic flow:**
1. A visitor opens `https://ivanpashkulev.com` — their browser connects to Cloudflare over HTTPS
2. A Cloudflare Worker intercepts the request and attempts to forward it to the origin
3. If the origin is unreachable (server down, maintenance), the Worker returns a styled maintenance page
4. Otherwise, the request travels through the Cloudflare Tunnel to the VM — no open inbound ports required
5. nginx receives the request on port 80 and routes it:
   - `/api/*` → `api-main` FastAPI service on port 8000
   - `/*` → `web-main` Vite preview server on port 4173
6. For `/api/chat`, the FastAPI service calls OpenAI's `gpt-4o-mini` model over HTTPS

**SSL/TLS:** Cloudflare terminates HTTPS at the edge. Traffic between Cloudflare and the VM is encrypted by the tunnel. nginx serves plain HTTP internally — no certificate management required.

**GitOps deployment:** Docker image tags in `docker-compose.yml` are updated automatically via pull requests opened by GitHub Actions in the `api-main`, `web-main`, and `dj` repositories on every merge to `main`.

## Repository Structure

```
devops/
├── docker-compose.yml          # Service definitions
├── nginx/
│   └── nginx.conf              # Reverse proxy configuration
├── cloudflare/
│   └── worker.js               # Maintenance page Worker
├── .env.example                # Environment variable template
└── .gitignore                  # Excludes .env and assets/
```

## Services

### nginx
- Image: `nginx:alpine`
- Exposes port 80 to the host
- Routes `/api/` to the FastAPI backend (strips prefix)
- Routes everything else to the frontend
- Configured with `proxy_buffering off` for SSE support

### api-main
- Image: `ghcr.io/ivanpashkulev/api-main:<sha>`
- FastAPI + LangGraph AI agent
- Requires the `OPENAI_API_KEY` environment variable
- Uses `OPENAI_MODEL`, which defaults to `gpt-4o-mini`
- Requires `assets/` volume mount with context documents
- Source: [ivanpashkulev/api-main](https://github.com/ivanpashkulev/api-main)

### web-main
- Image: `ghcr.io/ivanpashkulev/web-main:<sha>`
- React + Vite frontend
- Requires `VITE_API_URL=/api` (used at build time inside the container)
- Source: [ivanpashkulev/web-main](https://github.com/ivanpashkulev/web-main)

## Prerequisites

- Ubuntu AMD64 server
- Docker + Docker Compose
- `cloudflared` installed
- Domain on Cloudflare with nameservers configured
- OpenAI API key

## Deployment

### First-time Setup

**1. Clone the repository**
```bash
git clone https://github.com/ivanpashkulev/devops.git
cd devops
```

**2. Create environment file**
```bash
cp .env.example .env
nano .env
```

Set the OpenAI API key. The model is optional and defaults to `gpt-4o-mini`:
```env
OPENAI_API_KEY=your-openai-api-key
OPENAI_MODEL=gpt-4o-mini
```

**3. Place context assets**

Create an `assets/` directory and place context documents inside (CV, bio, summaries):
```bash
mkdir assets
# copy your .pdf, .txt, or .md files into assets/
```

**4. Set up Cloudflare Tunnel**
```bash
cloudflared tunnel login
cloudflared tunnel create <tunnel-name>
```

Create `/etc/cloudflared/config.yml`:
```yaml
tunnel: <tunnel-id>
credentials-file: /etc/cloudflared/<tunnel-id>.json

ingress:
  - hostname: ivanpashkulev.com
    service: http://localhost:80
  - service: http_status:404
```

Route the domain and install as a service:
```bash
cloudflared tunnel route dns <tunnel-name> <tunnel-id>
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

**5. Start the stack**
```bash
docker compose pull
docker compose up -d
```

### Updating

When a new image is available (after merging a deploy PR):
```bash
git pull
docker compose pull
docker compose up -d
```

### Stopping

```bash
docker compose down
```

The Cloudflare Tunnel continues running. If the origin is unreachable, the Cloudflare Worker automatically serves the maintenance page to visitors.

## Cloudflare Worker

The `cloudflare/worker.js` file contains a Cloudflare Worker that acts as a transparent proxy with automatic maintenance page fallback. It:

- Forwards all requests to the origin with a 10-second timeout
- Returns a styled maintenance page if the origin responds with 502/503 or is unreachable
- Passes all other responses through unchanged

The Worker is deployed manually via the Cloudflare dashboard and routed to `ivanpashkulev.com/*`.
