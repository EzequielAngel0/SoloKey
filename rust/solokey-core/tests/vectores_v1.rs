//! La cripto del nucleo da EXACTAMENTE lo que daba la v1, con los vectores de CAL-2 (`vectores/v1/`).

use std::path::PathBuf;

use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use serde_json::Value;
use solokey_core::crypto::{self, KdfParams};
use solokey_core::v1;

pub fn vectores_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../vectores/v1")
}

fn vectores() -> Value {
    let p = vectores_dir().join("vectores.json");
    let s = std::fs::read_to_string(&p)
        .unwrap_or_else(|e| panic!("faltan los vectores de CAL-2 en {p:?}: {e}"));
    serde_json::from_str(&s).unwrap()
}

fn s<'a>(v: &'a Value, k: &str) -> &'a str {
    v[k].as_str().unwrap_or_else(|| panic!("falta {k}"))
}

fn u(v: &Value, k: &str) -> u32 {
    v[k].as_u64().unwrap() as u32
}

#[test]
fn kdf_de_la_v1_con_doble_utf8() {
    let d = vectores();
    for k in d["kdf"].as_array().unwrap() {
        let params = KdfParams {
            memory_kib: u(k, "memoryKiB"),
            iterations: u(k, "iterations"),
            parallelism: u(k, "parallelism"),
        };
        let input = hex::decode(s(k, "kdfInputHex")).unwrap();
        let salt = STANDARD.decode(s(k, "saltBase64")).unwrap();
        let key = crypto::derive_key(&input, &salt, params).unwrap();
        assert_eq!(hex::encode(*key), s(k, "keyHex"), "{}", s(k, "uso"));
    }
    // La maestra: la entrada del KDF se reconstruye desde el texto con la doble codificacion.
    let maestra = &d["kdf"][0];
    assert_eq!(
        hex::encode(&*v1::master_kdf_input(s(maestra, "password"))),
        s(maestra, "kdfInputHex")
    );
    // El PIN y la exportacion van en UTF-8 simple.
    assert_eq!(
        hex::encode(s(&d["kdf"][1], "password").as_bytes()),
        s(&d["kdf"][1], "kdfInputHex")
    );
    assert_eq!(
        hex::encode(s(&d["export"], "password").as_bytes()),
        s(&d["export"], "kdfInputHex")
    );
}

#[test]
fn maestra_verifica_y_la_incorrecta_no() {
    let d = vectores();
    let b = &d["boveda"];
    let mkc = &b["masterKeyConfig"];
    let salt = STANDARD.decode(s(mkc, "salt")).unwrap();
    let verification = STANDARD.decode(s(mkc, "verificationData")).unwrap();
    let p = &mkc["kdfParams"];
    let params = KdfParams {
        memory_kib: u(p, "memory"),
        iterations: u(p, "iterations"),
        parallelism: u(p, "parallelism"),
    };
    let key = v1::derive_master_key(s(b, "masterPassword"), &salt, params).unwrap();
    assert_eq!(hex::encode(*key), s(b, "derivedKeyHex"));
    assert!(crypto::verify_key(key.as_ref(), &verification));
    let bad = v1::derive_master_key(s(b, "wrongPassword"), &salt, params).unwrap();
    assert!(!crypto::verify_key(bad.as_ref(), &verification));
}

#[test]
fn aes_gcm_de_la_v1() {
    let d = vectores();
    let a = &d["aesGcm"];
    let key = hex::decode(s(a, "keyHex")).unwrap();
    let blob = hex::decode(s(a, "blobHex")).unwrap();
    assert_eq!(
        crypto::decrypt(&blob, &key).unwrap().as_slice(),
        s(a, "plaintextUtf8").as_bytes()
    );
}

#[test]
fn doble_sobre_de_la_v1() {
    let d = vectores();
    let dc = &d["dobleCifrado"];
    assert!(v1::is_double_envelope(s(dc, "muestra")));
    let pt = v1::open_double_envelope(s(dc, "muestra"), s(dc, "pin")).unwrap();
    assert_eq!(pt.as_slice(), s(dc, "plaintext").as_bytes());
    assert!(v1::open_double_envelope(s(dc, "muestra"), "000000").is_err());
}

#[test]
fn codigo_de_recuperacion_abre_la_clave() {
    let d = vectores();
    let b = &d["boveda"];
    let ss = &b["secureStorage"];
    let rk = v1::recovery_code_key(s(b, "recoveryCode")).unwrap();
    let wrapped = STANDARD.decode(s(ss, "recovery_encrypted_master")).unwrap();
    let master = crypto::decrypt(&wrapped, rk.as_ref()).unwrap();
    assert_eq!(hex::encode(master.as_slice()), s(b, "derivedKeyHex"));
}
