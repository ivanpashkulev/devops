# devops

Terraform infrastructure and Docker Compose deployment for
ivanpashkulev.com and dj.ivanpashkulev.com.

This is an intentionally minimal learning setup. Improvements are introduced
individually, with an explanation of the problem each change solves.

## Architecture

Browser → Cloudflare → Hetzner Nginx container → application containers

- Browser-to-Cloudflare traffic uses HTTPS.
- Cloudflare-to-Nginx traffic uses HTTPS with an Origin CA certificate.
- Cloudflare must use Full (strict) encryption mode.
- Nginx-to-application traffic uses HTTP over the Compose network.
- Terraform restricts origin web access to Cloudflare IP ranges.
- SSH is restricted to configured trusted addresses and the Terraform runner.
- This deployment does not use Cloudflare Tunnel.

| Public route | Compose destination |
| --- | --- |
| ivanpashkulev.com/api/ | api:8000, removing the /api/ prefix |
| ivanpashkulev.com/ | web:4173 |
| dj.ivanpashkulev.com/ | dj:3000 |

Nginx redirects HTTP to HTTPS and disables API response buffering for
streaming chat.

The optional Cloudflare Worker provides a maintenance response for failed
origin requests. Its /api/chat path bypasses the maintenance handling.

## Deployment files

- terraform/hetzner/: infrastructure and DNS.
- docker-compose.yml: application image versions and container settings.
- nginx/nginx.conf: HTTPS and routing.
- ansible/inventory/hetzner.hcloud.yml: dynamic server discovery.
- ansible/requirements.yml: Ansible collections.
- ansible/deploy.yml: Docker installation and application deployment.

Application repositories open PRs updating image tags in docker-compose.yml.
The playbook deploys that file directly.

## Prerequisites

- A provisioned Ubuntu 24.04 Hetzner server.
- An Ansible controller with SSH access to the server as root.
- Ansible, requests and python-dateutil installed on the controller.
- The collections listed in ansible/requirements.yml installed.
- Publicly pullable application images.
- Proxied Cloudflare DNS records and Full (strict) encryption enabled.

The controller must provide these environment variables:

| Variable | Purpose |
| --- | --- |
| HCLOUD_TOKEN | Read-only Hetzner inventory API token |
| OPENAI_API_KEY | API application credential |
| CLOUDFLARE_ORIGIN_CERT | Complete Origin certificate PEM |
| CLOUDFLARE_ORIGIN_KEY | Complete Origin private-key PEM |

GitHub repository secrets do not automatically become environment variables.
The deployment workflow must explicitly map them into the Ansible step.

## Running locally

From the repository root:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
ansible-inventory -i ansible/inventory/hetzner.hcloud.yml --graph
ansible-playbook -i ansible/inventory/hetzner.hcloud.yml \
  ansible/deploy.yml --private-key /path/to/private-key
```

Confirm that the inventory lists the intended server before deployment.
The SSH source address must be allowed by the Hetzner firewall.

The playbook installs Docker and Compose, copies configuration and
certificates, pulls images, and recreates the containers.

Application files are installed under /opt/ivanpashkulev.
Certificates are installed under /etc/nginx/ssl.
The OpenAI key is passed through the Compose process environment; the
playbook does not create a remote .env file.

For GitHub Actions, Ansible will run in the same job as Terraform so it uses
the runner address Terraform authorized. Workflow wiring is a separate step.

## Checking the result

Open both websites and check that their content loads. Test chat separately.

A successful playbook currently means the deployment commands succeeded.
It does not prove application readiness.

On the server, inspect containers with:

```bash
docker ps
docker logs nginx
docker logs api-main
docker logs web-main
docker logs dj
```

Do not share logs without checking them for sensitive content.

## Deliberate limitations and future improvements

| Current behavior | Improvement to explore |
| --- | --- |
| Every deployment recreates every container, causing brief downtime. | Recreate only changed services and reload Nginx when appropriate. |
| Nginx resolves service names when loading configuration. Independently recreated application containers can leave stale addresses. | Dynamic Docker DNS resolution. |
| No automated application checks. | Bounded readiness checks and public HTTPS verification. |
| An empty inventory can result in a successful run with no deployment. | Fail explicitly when no targets are found. |
| No configuration validation before containers are replaced. | Validate Compose, Nginx and certificates before activation. |
| No automatic rollback. | Record the last working deployment and implement recovery. |
| Nginx sees Cloudflare's address as the client address. Incoming forwarded headers are not normalized. | Restore visitor IPs using trusted Cloudflare ranges and configure application proxy trust. |
| Unknown hostnames can reach a default website. | Explicit default-server rejection. |
| Most Nginx protocol, session and timeout settings use defaults. | Tune only when a compatibility or measured performance need appears. |
| Deployment uses root SSH access. | Introduce a dedicated deployment user and deliberate privilege escalation. |
| Commands that handle the OpenAI key suppress output. | Improve diagnostics while preserving secret redaction. |
| Pull/start commands report changes on every run. | Use Compose modules for more accurate change reporting. |
| Dependencies and package updates are not fully locked. | Define and test a reproducible dependency update policy. |
| Old images can accumulate. | Add controlled image cleanup with rollback retention. |
| Frontend builds at container startup. | Build once in CI and deploy a production runtime. |
| Public AI chat lacks application-level abuse controls. | Add quotas, rate limits and cost controls before production use. |
| No monitoring or recovery exercises. | Add alerts, resource monitoring and tested recovery procedures. |

Changes should be introduced one at a time, documenting the observed
problem, the chosen solution and its tradeoffs.
