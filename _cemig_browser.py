"""Cemig portal + capture amplo (tudo XHR/fetch, com body, append em arquivo)."""
import json, time
from pathlib import Path
from playwright.sync_api import sync_playwright

USER_DATA = Path("C:/VB.Code.Teste/_chrome_profile_cemig")
USER_DATA.mkdir(exist_ok=True)
OUT_CKS = Path("C:/VB.Code.Teste/_cemig_cookies.json")
OUT_NET = Path("C:/VB.Code.Teste/_cemig_network.log")
OUT_NET.write_text("")  # zera
START = "https://www.atendimento.cemig.com.br/portal/home"

def append(line):
    with OUT_NET.open("a", encoding="utf-8") as f:
        f.write(line + "\n")
    print(line, flush=True)

def on_req(req):
    # Capta XHR/fetch + document (Next.js SSR) + downloads
    if req.resource_type not in ("xhr", "fetch", "document"): return
    # Filtra noise: onetrust, google analytics, fonts cdn
    url = req.url
    if any(n in url for n in ("cookielaw.org", "onetrust.com", "googletagmanager", "google-analytics",
                                "fonts.gstatic", "fonts.googleapis", "doubleclick")):
        return
    append(f"REQ [{req.resource_type:8}] {req.method:5} {url}")
    pd = req.post_data
    if pd: append(f"  body: {pd[:400]}")

def on_resp(resp):
    if resp.request.resource_type not in ("xhr", "fetch", "document"): return
    url = resp.url
    if any(n in url for n in ("cookielaw.org", "onetrust.com", "googletagmanager", "google-analytics",
                                "fonts.gstatic", "fonts.googleapis", "doubleclick")):
        return
    ct = (resp.headers.get("content-type") or "")[:60]
    append(f"RSP [{resp.request.resource_type:8}] {resp.status:3} {url}  [{ct}]")
    if resp.status in (200, 201) and "json" in ct:
        try:
            body = resp.body().decode("utf-8", "replace")[:800]
            append(f"  json: {body}")
        except Exception as e:
            append(f"  json-err: {e}")

def on_download(dl):
    append(f"DOWNLOAD url={dl.url} sug_name={dl.suggested_filename}")
    try:
        dest = Path("C:/VB.Code.Teste/_cemig_downloads") / dl.suggested_filename
        dest.parent.mkdir(exist_ok=True)
        dl.save_as(str(dest))
        append(f"  saved: {dest}")
    except Exception as e:
        append(f"  download-err: {e}")

with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context(
        user_data_dir=str(USER_DATA),
        headless=False,
        channel="chrome",
        args=["--start-maximized", "--disable-blink-features=AutomationControlled"],
        no_viewport=True,
    )
    ctx.add_init_script("Object.defineProperty(navigator,'webdriver',{get:()=>undefined})")
    ctx.on("request", on_req)
    ctx.on("response", on_resp)
    page = ctx.pages[0] if ctx.pages else ctx.new_page()
    page.on("download", on_download)
    page.on("framenavigated", lambda f: append(f"NAV  {f.url}") if f == page.main_frame else None)
    try:
        page.goto(START, wait_until="domcontentloaded", timeout=30000)
    except Exception as e:
        print(f"[goto-warn] {e}", flush=True)

    print("\n[NAVEGA] Clica em Trocar -> escolhe instalacao -> abre Conta de Luz / Historico.", flush=True)
    print("Tudo XHR/fetch sera logado em " + str(OUT_NET) + "\n", flush=True)
    deadline = time.time() + 900
    while time.time() < deadline:
        time.sleep(3)
        try: _ = page.url
        except: break
    try:
        cks = [c for c in ctx.cookies() if "cemig.com.br" in c.get("domain","")]
        OUT_CKS.write_text(json.dumps(cks, indent=2))
    except: pass
    try: ctx.close()
    except: pass
