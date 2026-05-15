"""Cemig login helper — fluxo Chrome NATIVO (sem Playwright).

Por que Chrome nativo: Playwright adiciona flags de automacao que o Google
detecta e bloqueia o botao "Continuar com Google" (fica girando, nunca aceita).
Chrome direto na linha de comando, apontando pro profile persistido, comporta
como Chrome de gente -> Google deixa logar normal.

Fluxo:
  1. Checa se ja esta logado (cookies + bearer cache validos chamando a API).
     Se OK -> marca sessao_ok, sai.
  2. Senao abre chrome.exe NATIVO no profile persistente.
  3. User loga manual e fecha o Chrome.
  4. Apos fechado, dispara cemig_refresh_bearer.refresh(headless=True) pra
     capturar o Bearer novo via Playwright (so leitura, nao interage com
     Google nesse momento).
  5. Marca sessao_ok no state.

Uso:
    python C:/VB.Code.Teste/_cemig_login.py
"""
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path


PROFILE = Path("C:/VB.Code.Teste/_chrome_profile_cemig")
COOKIES_OUT = Path("C:/VB.Code.Teste/_cemig_cookies.json")
# URL de login certa do Cemig (Keycloak + Continuar com Google).
LOGIN_URL = "https://atende.cemig.com.br/Login"
HOME_URL = "https://www.atendimento.cemig.com.br/portal/home"


def _achar_chrome() -> str:
    """Acha o chrome.exe instalado no sistema."""
    candidatos = [
        shutil.which("chrome"),
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        str(Path.home() / "AppData/Local/Google/Chrome/Application/chrome.exe"),
    ]
    for c in candidatos:
        if c and Path(c).exists():
            return c
    raise RuntimeError("chrome.exe nao encontrado — instale o Google Chrome")


def _ja_logado() -> bool:
    """Tenta chamar a API com o cache atual. Se passa, esta logado."""
    sys.path.insert(0, "C:/cemig")
    try:
        from cemig_api import CemigAPI
        api = CemigAPI()
        sites = api.listar_sites(page=1, page_size=2)
        print(f"  [check] API respondeu: {len(sites)} sites")
        return True
    except Exception as e:
        print(f"  [check] nao logado: {str(e)[:160]}")
        return False


def _refresh_bearer_headless() -> bool:
    """Apos user logar, captura Bearer headless usando o profile."""
    sys.path.insert(0, "C:/cemig")
    try:
        from cemig_refresh_bearer import refresh
        bearer = refresh(headless=True)
        print(f"  [refresh] Bearer capturado: {bearer[:30]}...")
        return True
    except Exception as e:
        print(f"  [refresh] FALHOU: {e}")
        return False


def _marcar_ok():
    sys.path.insert(0, "C:/cemig")
    try:
        from sessao_alerta import marcar_ok
        r = marcar_ok()
        if r.get("transicao"):
            print(f"  [alerta] sessao restaurada -> WA={r.get('wa')} email={r.get('email')}")
        else:
            print("  [alerta] state estava limpo")
    except Exception as e:
        print(f"  [alerta] falhou: {e}")


def _esperar_chrome_fechar(proc: subprocess.Popen):
    """Espera o user fechar o Chrome. Imprime dica a cada 30s."""
    print("\n" + "=" * 68)
    print(">> CHROME ABERTO — LOGUE NO PORTAL CEMIG NA JANELA QUE APARECEU")
    print(">> Use 'Continuar com Google' normalmente.")
    print(">> Quando ver sua HOME do portal Cemig, FECHE o Chrome.")
    print("=" * 68 + "\n")
    inicio = time.time()
    last_dica = 0
    while proc.poll() is None:
        time.sleep(2)
        elapsed = int(time.time() - inicio)
        if elapsed - last_dica >= 30:
            print(f"  [esperando] Chrome aberto ha {elapsed//60}m{elapsed%60:02d}s. "
                  f"Feche a janela quando logar.")
            last_dica = elapsed
    print(f"\n  Chrome fechado apos {int(time.time() - inicio)}s.")


def main():
    print("=== Cemig login helper ===\n")

    # Passo 1: ja esta logado?
    print("1) Checando se sessao atual ja esta valida...")
    if _ja_logado():
        print("\n✓ Voce JA esta logado. Nada a fazer.")
        _marcar_ok()
        return 0

    # Passo 2: abre Chrome nativo
    try:
        chrome = _achar_chrome()
    except RuntimeError as e:
        print(f"\n✗ {e}")
        return 1
    print(f"\n2) Abrindo Chrome nativo: {chrome}")
    print(f"   Profile: {PROFILE}")
    PROFILE.mkdir(parents=True, exist_ok=True)
    cmd = [
        chrome,
        f"--user-data-dir={PROFILE}",
        "--no-first-run", "--no-default-browser-check",
        "--new-window", LOGIN_URL,
    ]
    try:
        proc = subprocess.Popen(cmd)
    except Exception as e:
        print(f"\n✗ erro ao abrir Chrome: {e}")
        return 1

    # Passo 3: aguarda user fechar
    _esperar_chrome_fechar(proc)

    # Passo 4: refresh Bearer via Playwright headless
    print("\n3) Capturando Bearer novo (Playwright headless)...")
    if not _refresh_bearer_headless():
        print("\n✗ Refresh falhou. Talvez voce nao tenha logado, ou tenha "
              "fechado antes de chegar na home. Rode de novo.")
        return 1

    # Passo 5: marca sessao restaurada
    print("\n4) Marcando sessao OK e avisando canais...")
    _marcar_ok()

    print("\n✓ TUDO PRONTO. Proximo ciclo do coletor ja vai rodar normal.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
