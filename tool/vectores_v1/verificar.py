"""Verifica vectores/v1 con una implementacion independiente de la v1 (Python, no Dart).

Corre dentro de Podman con tool/vectores_v1/verificar.ps1; lee /v (vectores/v1, solo lectura).
Si esto pasa, otro lenguaje (el nucleo Rust) puede leer la boveda v1 con lo que hay en vectores.json.
"""
import base64, json, sqlite3, sys
from argon2.low_level import hash_secret_raw, Type
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

v = json.load(open('/v/vectores.json', encoding='utf-8'))
ok = True
def check(name, cond):
    global ok
    print(('PASA ' if cond else 'FALLA'), name); ok = ok and cond

def argon(inp, salt_b64, m, t, p):
    return hash_secret_raw(inp, base64.b64decode(salt_b64), time_cost=t, memory_cost=m, parallelism=p, hash_len=32, type=Type.ID)

def dec(key, blob):
    return AESGCM(key).decrypt(blob[:12], blob[12:], None)

for k in v['kdf']:
    out = argon(bytes.fromhex(k['kdfInputHex']), k['saltBase64'], k['memoryKiB'], k['iterations'], k['parallelism'])
    check('kdf ' + k['uso'], out.hex() == k['keyHex'])

pw = v['boveda']['masterPassword']
double = pw.encode('utf-8').decode('latin-1').encode('utf-8')
check('entrada de la maestra = doble codificacion UTF-8', double.hex() == v['kdf'][0]['kdfInputHex'])
cfg = v['boveda']['masterKeyConfig']
key = bytes.fromhex(v['boveda']['derivedKeyHex'])
check('verificationData', dec(key, base64.b64decode(cfg['verificationData'])) == b'SoloKey::v1::verify')
wrong = v['boveda']['wrongPassword'].encode('utf-8').decode('latin-1').encode('utf-8')
wk = argon(wrong, cfg['salt'], cfg['kdfParams']['memory'], cfg['kdfParams']['iterations'], cfg['kdfParams']['parallelism'])
try:
    dec(wk, base64.b64decode(cfg['verificationData'])); check('la incorrecta no abre', False)
except Exception:
    check('la incorrecta no abre', True)

a = v['aesGcm']
check('aes-gcm', dec(bytes.fromhex(a['keyHex']), bytes.fromhex(a['blobHex'])).decode() == a['plaintextUtf8'])

db = sqlite3.connect('/v/boveda/vault_guard_db.sqlite')
check('esquema v10', db.execute('PRAGMA user_version').fetchone()[0] == 10)
pay = {p['id']: p['payloadJson'] for p in v['payloads']}
rows = db.execute('SELECT id, encrypted_payload FROM credential_entries').fetchall()
check('8 credenciales', len(rows) == 8)
for cid, blob in rows:
    check('payload ' + cid[-2:], dec(key, blob).decode() == pay[cid])
for hid, cid, blob in db.execute('SELECT id, credential_id, encrypted_payload FROM password_history_entries'):
    json.loads(dec(key, blob))
check('historial descifra', True)

rec = v['boveda']['secureStorage']['recovery_encrypted_master']
code = v['boveda']['recoveryCode'].replace('-', '').replace(' ', '')
code += '=' * (-len(code) % 4)
check('codigo de recuperacion abre la clave', dec(base64.b64decode(code), base64.b64decode(rec)) == key)

for f in v['secureFiles']:
    data = dec(key, open('/v/boveda/secure_files/' + f['storedFileName'], 'rb').read())
    check('archivo ' + f['name'], base64.b64encode(data).decode() == f['plaintextBase64'])

d = v['dobleCifrado']
_, salt, ct = d['muestra'].split(':')
dk = argon(d['pin'].encode(), salt, 32768, 2, 2)
check('doble cifrado', dec(dk, base64.b64decode(ct)).decode() == d['plaintext'])

e = open('/v/boveda/export.skvault', 'rb').read()
check('magic SKVE2', e[:8] == b'SKVE2\x00\x00\x00')
ek = argon(v['export']['password'].encode('utf-8'), base64.b64encode(e[8:40]).decode(), 65536, 3, 2)
exp = json.loads(dec(ek, e[40:]))
check('export: 8 credenciales y 2 carpetas', len(exp['credentials']) == 8 and len(exp['folders']) == 2)
sys.exit(0 if ok else 1)
