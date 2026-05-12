"""Sonda login Cemig — passa cred, captura token CSRF, tenta POST."""
import re
import requests
from urllib.parse import urljoin

BASE = "https://atende.cemig.com.br"
UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

s = requests.Session()
s.headers["User-Agent"] = UA

# 1. GET login page
r = s.get(f"{BASE}/Login", allow_redirects=True, timeout=20)
print(f"GET /Login -> {r.status_code} {r.url}  len={len(r.text)}")
tok = re.search(r'name="__RequestVerificationToken"[^>]*value="([^"]+)"', r.text)
print(f"CSRF token: {('OK ' + tok.group(1)[:30] + '...') if tok else 'NAO ACHADO'}")

# 2. Inspect form action+fields
form = re.search(r'<form[^>]*id="form"[^>]*action="([^"]+)"[^>]*method="post"', r.text, re.I) \
       or re.search(r'<form[^>]*method="post"[^>]*action="([^"]+)"', r.text, re.I) \
       or re.search(r'<form[^>]*action="([^"]+)"[^>]*method="post"', r.text, re.I)
action = form.group(1) if form else "/Login"
print(f"Form action: {action}")
inputs = re.findall(r'<input[^>]+name="([^"]+)"[^>]*(?:value="([^"]*)")?', r.text)
nomes = [n for n,_ in inputs if not n.startswith('_')]
print(f"Form fields: {set(nomes)}")

# 3. POST credentials
import sys
cpf, senha = sys.argv[1], sys.argv[2]
payload = {
    "__RequestVerificationToken": tok.group(1) if tok else "",
    "Acesso": cpf,
    "Senha": senha,
    "ManterConectado": "false",
    "AcessoCompartilhado": "False",
}
r2 = s.post(urljoin(BASE, action), data=payload, allow_redirects=False, timeout=20)
print()
print(f"POST {action} -> {r2.status_code}")
loc = r2.headers.get("location")
print(f"  Location: {loc}")
# Erros costumam vir no body
if r2.text:
    for marker in ["erro", "Erro", "ERRO", "inv", "Senha", "Usu"]:
        m = re.search(rf'[^>]*{marker}[^<]{{0,160}}', r2.text)
        if m: print(f"  body[{marker}]: {m.group(0).strip()[:180]}"); break
print(f"  cookies dom: {[c.name for c in s.cookies if 'cemig' in c.domain or 'atende' in c.domain]}")

# 4. Se redirect 302, segue
if r2.status_code in (301, 302) and loc:
    r3 = s.get(urljoin(BASE, loc), allow_redirects=True, timeout=20)
    print(f"GET {loc} -> {r3.status_code} {r3.url}")
    titulo = re.search(r"<title>([^<]+)</title>", r3.text)
    print(f"  title: {titulo.group(1).strip() if titulo else '?'}")
