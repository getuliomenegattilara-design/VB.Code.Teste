"""Usa cookies capturados pra sondar endpoints autenticados do portal."""
import json, requests
from pathlib import Path

cks = json.loads(Path("C:/VB.Code.Teste/_cemig_cookies.json").read_text())
s = requests.Session()
for c in cks:
    s.cookies.set(c["name"], c["value"], domain=c["domain"].lstrip("."))
s.headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
s.headers["Accept"] = "application/json, text/plain, */*"

BASE = "https://www.atendimento.cemig.com.br"
endpoints = [
    "/api/auth/session",
    "/api/auth/csrf",
    "/portal/api/contas",
    "/portal/api/fatura",
    "/portal/api/instalacoes",
    "/api/contas",
    "/api/fatura/aberta",
    "/api/historico/consumo",
    "/api/manutencao",
    "/api/usuario",
    "/api/cliente",
]
for ep in endpoints:
    try:
        r = s.get(BASE + ep, timeout=12, allow_redirects=False)
        body = r.text[:250].replace("\n", " ")
        print(f"{r.status_code:3} {ep:40} {body}")
    except Exception as e:
        print(f"ERR {ep:40} {e}")
