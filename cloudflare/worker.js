export default {
  async fetch(request, env) {
    const url = new URL(request.url)
    if (url.pathname.startsWith('/api/chat')) {
      return fetch(request)
    }

    try {
      const response = await fetch(request, { signal: AbortSignal.timeout(10000) })

      if (response.status >= 500) {
        return maintenancePage()
      }

      return response
    } catch {
      return maintenancePage()
    }
  }
}

function maintenancePage() {
  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Ivan Pashkulev — Back Soon</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600&family=Inter:wght@300;400&display=swap');
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: #0D1117;
      color: #E6EDF3;
      font-family: 'Inter', sans-serif;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      text-align: center;
      padding: 2rem;
    }
    .dot {
      width: 12px;
      height: 12px;
      background: #00D4FF;
      border-radius: 50%;
      margin: 0 auto 2rem;
      animation: pulse 2s ease-in-out infinite;
    }
    h1 {
      font-family: 'Space Grotesk', sans-serif;
      font-size: 1.8rem;
      font-weight: 600;
      margin-bottom: 0.5rem;
    }
    .accent { color: #00D4FF; }
    p {
      color: #8B949E;
      font-size: 0.95rem;
      line-height: 1.6;
      max-width: 360px;
      margin: 1rem auto 0;
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); box-shadow: 0 0 0 0 rgba(0,212,255,0.4); }
      50% { opacity: 0.8; transform: scale(1.1); box-shadow: 0 0 0 10px rgba(0,212,255,0); }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="dot"></div>
    <h1>Ivan <span class="accent">Pashkulev</span></h1>
    <p>This page is temporarily offline. Check back soon.</p>
  </div>
</body>
</html>`

  return new Response(html, {
    status: 503,
    headers: { 'Content-Type': 'text/html;charset=UTF-8' }
  })
}
