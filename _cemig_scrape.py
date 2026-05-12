"""Cemig portal — automacao: usa perfil logado pra extrair HTML das paginas.
Salva snapshots e tenta listar instalacoes + trocar."""
import json, time
from pathlib import Path
from playwright.sync_api import sync_playwright

USER_DATA = Path("C:/VB.Code.Teste/_chrome_profile_cemig")
SNAPSHOTS = Path("C:/VB.Code.Teste/_cemig_snap"); SNAPSHOTS.mkdir(exist_ok=True)

def save(page, nome):
    html = page.content()
    (SNAPSHOTS / f"{nome}.html").write_text(html, encoding="utf-8")
    page.screenshot(path=str(SNAPSHOTS / f"{nome}.png"), full_page=True)
    print(f"[snap] {nome}: HTML={len(html)} chars, URL={page.url}", flush=True)

def texto_visivel(page):
    return page.evaluate("() => document.body.innerText").strip()

with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context(
        user_data_dir=str(USER_DATA), headless=False, channel="chrome",
        args=["--start-maximized", "--disable-blink-features=AutomationControlled"],
        no_viewport=True,
    )
    ctx.add_init_script("Object.defineProperty(navigator,'webdriver',{get:()=>undefined})")
    page = ctx.pages[0] if ctx.pages else ctx.new_page()
    try: page.goto("https://www.atendimento.cemig.com.br/portal/home", wait_until="domcontentloaded", timeout=30000)
    except Exception as e: print(f"[goto-warn] {e}", flush=True)
    time.sleep(3)
    # Tira banner OneTrust de cookies (intercepta cliques)
    for sel in ['button:has-text("Aceitar cookies")', '#onetrust-accept-btn-handler', 'button:has-text("Rejeitar cookies")']:
        try:
            el = page.locator(sel).first
            if el.count() and el.is_visible():
                el.click(); print(f"[cookies] aceito via {sel}", flush=True)
                time.sleep(1); break
        except: pass
    save(page, "1-home")
    print("\n=== TEXTO HOME ===", flush=True)
    print(texto_visivel(page)[:2000], flush=True)

    # Procura botao/link "Trocar"
    print("\n=== PROCURANDO 'Trocar' ===", flush=True)
    for sel in ['text=Trocar', 'button:has-text("Trocar")', 'a:has-text("Trocar")', '[aria-label*="Trocar" i]']:
        try:
            el = page.locator(sel).first
            if el.count() and el.is_visible():
                print(f"[encontrado] {sel}", flush=True)
                el.click()
                time.sleep(3)
                save(page, "2-trocar")
                print("\n=== TEXTO TROCAR ===", flush=True)
                print(texto_visivel(page)[:3000], flush=True)
                break
        except Exception as e:
            print(f"  sel {sel}: {e}", flush=True)

    # Lista todos os links e botoes da pagina atual (debug)
    print("\n=== TODOS LINKS DA PAGINA ATUAL ===", flush=True)
    try:
        links = page.evaluate("() => Array.from(document.querySelectorAll('a, button')).map(e => ({tag:e.tagName, text:(e.innerText||'').trim().slice(0,80), href:e.href||null, aria:e.getAttribute('aria-label')})).filter(x => x.text || x.aria)")
        for x in links[:60]:
            print(f"  {x['tag']:6} {x['text'][:60]:60} {x.get('href') or ''}", flush=True)
    except Exception as e: print(f"  err: {e}", flush=True)

    print("\n[fim] mantendo browser aberto 5min...", flush=True)
    time.sleep(300)
    try: ctx.close()
    except: pass
