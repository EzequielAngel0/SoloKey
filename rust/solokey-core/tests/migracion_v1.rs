//! Migracion v1 -> v2 con la boveda que genero la app v1 (CAL-2). Siempre sobre una COPIA en un temporal.

use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};

use serde_json::Value;
use solokey_core::crypto;
use solokey_core::migrate_v1::{migrate, V1Location};
use solokey_core::vault::{self, Vault};
use solokey_core::CoreError;

fn vectores_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../vectores/v1")
}

fn vectores() -> Value {
    serde_json::from_str(&fs::read_to_string(vectores_dir().join("vectores.json")).unwrap())
        .unwrap()
}

fn copy_dir(from: &Path, to: &Path) {
    fs::create_dir_all(to).unwrap();
    for e in fs::read_dir(from).unwrap() {
        let e = e.unwrap();
        if e.file_type().unwrap().is_dir() {
            copy_dir(&e.path(), &to.join(e.file_name()));
        } else {
            fs::copy(e.path(), to.join(e.file_name())).unwrap();
        }
    }
}

struct Escena {
    _tmp: tempfile::TempDir,
    src: V1Location,
    dest: PathBuf,
    backup: PathBuf,
    mkc: String,
    almacen: BTreeMap<String, String>,
    password: String,
}

/// Copia la boveda v1 de los vectores a un temporal.
fn escena() -> Escena {
    let d = vectores();
    let tmp = tempfile::tempdir().unwrap();
    let v1dir = tmp.path().join("v1");
    copy_dir(&vectores_dir().join("boveda"), &v1dir);
    fs::remove_file(v1dir.join("export.skvault")).unwrap(); // no es parte de la boveda
    let ss = d["boveda"]["secureStorage"].as_object().unwrap();
    let almacen: BTreeMap<String, String> = ss
        .iter()
        .map(|(k, v)| (k.clone(), v.as_str().unwrap().to_owned()))
        .collect();
    Escena {
        src: V1Location {
            db: v1dir.join("vault_guard_db.sqlite"),
            secure_files_dir: v1dir.join("secure_files"),
        },
        dest: vault::vault_path(&tmp.path().join("v2")),
        backup: tmp.path().join("copia-v1"),
        mkc: almacen["master_key_config"].clone(),
        almacen,
        password: d["boveda"]["masterPassword"].as_str().unwrap().to_owned(),
        _tmp: tmp,
    }
}

fn hash_tree(dir: &Path) -> BTreeMap<String, [u8; 32]> {
    let mut m = BTreeMap::new();
    for e in fs::read_dir(dir).unwrap() {
        let e = e.unwrap();
        if e.file_type().unwrap().is_dir() {
            for (k, v) in hash_tree(&e.path()) {
                m.insert(format!("{}/{k}", e.file_name().to_string_lossy()), v);
            }
        } else {
            m.insert(
                e.file_name().to_string_lossy().into(),
                crypto::sha256(&fs::read(e.path()).unwrap()),
            );
        }
    }
    m
}

#[test]
fn migra_todo_y_descifra_igual() {
    let d = vectores();
    let e = escena();
    let antes = hash_tree(e.src.db.parent().unwrap());

    let rep = migrate(&e.src, &e.mkc, &e.almacen, &e.password, &e.dest, &e.backup).unwrap();

    let f = &d["filas"];
    assert_eq!(
        rep.credentials,
        f["credential_entries"].as_array().unwrap().len()
    );
    assert_eq!(rep.folders, f["folder_entries"].as_array().unwrap().len());
    assert_eq!(
        rep.categories,
        f["category_entries"].as_array().unwrap().len()
    );
    assert_eq!(
        rep.history,
        f["password_history_entries"].as_array().unwrap().len()
    );
    assert_eq!(
        rep.files,
        f["secure_file_entries"].as_array().unwrap().len()
    );
    assert!(rep.v1_had_recovery);

    // La copia previa es identica a la v1 original (BD y archivos).
    let copia = hash_tree(&e.backup);
    for (k, h) in &antes {
        assert_eq!(copia.get(k), Some(h), "la copia de {k} no coincide");
    }
    // Los originales se retiraron; la v2 existe y su temporal no.
    assert!(!e.src.db.exists() && !e.src.secure_files_dir.exists());
    assert!(e.dest.exists());
    assert!(!PathBuf::from(format!("{}.migrando", e.dest.display())).exists());

    // La v2 se abre con la MISMA maestra, en UTF-8 simple (ya sin la doble codificacion).
    let v = Vault::open(&e.dest, e.password.as_bytes()).unwrap();
    assert!(
        !v.header().has_recovery,
        "el codigo de la v1 no sirve; la v2 pide uno nuevo"
    );

    // Cada credencial: columnas + payload de la v1, igual.
    let payloads: BTreeMap<&str, Value> = d["payloads"]
        .as_array()
        .unwrap()
        .iter()
        .map(|p| {
            (
                p["id"].as_str().unwrap(),
                serde_json::from_str(p["payloadJson"].as_str().unwrap()).unwrap(),
            )
        })
        .collect();
    for fila in f["credential_entries"].as_array().unwrap() {
        let id = fila["id"].as_str().unwrap();
        let r = v.get(id).unwrap();
        assert_eq!(r.kind, "credential");
        assert_eq!(r.updated_at, fila["updated_at"].as_i64().unwrap());
        let data: Value = serde_json::from_str(&r.data).unwrap();
        assert_eq!(data["title"], fila["title"]);
        assert_eq!(data["type"], fila["type"]);
        assert_eq!(data["categoryId"], fila["category_id"]);
        assert_eq!(
            data["isFavorite"],
            Value::Bool(fila["is_favorite"].as_i64() == Some(1))
        );
        assert_eq!(
            data["isHidden"],
            Value::Bool(fila["is_hidden"].as_i64() == Some(1))
        );
        assert_eq!(data["sortOrder"], fila["sort_order"]);
        assert_eq!(data["createdAt"], fila["created_at"]);
        assert_eq!(data["customRotationDays"], fila["custom_rotation_days"]);
        for (k, val) in payloads[id].as_object().unwrap() {
            assert_eq!(&data[k], val, "{id}.{k}");
        }
    }
    // El doble sobre sigue abriendo con su PIN desde la v2.
    let dc = &d["dobleCifrado"];
    let c = v.get(dc["credencial"].as_str().unwrap()).unwrap();
    let data: Value = serde_json::from_str(&c.data).unwrap();
    let pw = solokey_core::v1::open_double_envelope(
        data["password"].as_str().unwrap(),
        dc["pin"].as_str().unwrap(),
    )
    .unwrap();
    assert_eq!(
        pw.as_slice(),
        dc["plaintextDeLaCredencial"]["password"]
            .as_str()
            .unwrap()
            .as_bytes()
    );

    // Carpetas, categorias e historial.
    for fila in f["folder_entries"].as_array().unwrap() {
        let data: Value =
            serde_json::from_str(&v.get(fila["id"].as_str().unwrap()).unwrap().data).unwrap();
        assert_eq!(data["name"], fila["name"]);
        assert_eq!(data["parentId"], fila["parent_id"]);
        assert_eq!(data["colorHex"], fila["color_hex"]);
    }
    for fila in f["category_entries"].as_array().unwrap() {
        let data: Value =
            serde_json::from_str(&v.get(fila["id"].as_str().unwrap()).unwrap().data).unwrap();
        assert_eq!(data["name"], fila["name"]);
    }
    for fila in f["password_history_entries"].as_array().unwrap() {
        let r = v.get(fila["id"].as_str().unwrap()).unwrap();
        assert_eq!(r.kind, "history");
        let data: Value = serde_json::from_str(&r.data).unwrap();
        assert_eq!(data["credentialId"], fila["credential_id"]);
        assert!(data["password"].is_string() || data["password"].is_null());
    }

    // Archivos seguros: el contenido descifra igual (hash) y los metadatos se conservan.
    for sf in d["secureFiles"].as_array().unwrap() {
        let id = sf["id"].as_str().unwrap();
        let bytes = v.get_blob(id).unwrap().unwrap();
        let hex: String = crypto::sha256(&bytes)
            .iter()
            .map(|b| format!("{b:02x}"))
            .collect();
        assert_eq!(hex, sf["plaintextSha256"].as_str().unwrap());
        let data: Value = serde_json::from_str(&v.get(id).unwrap().data).unwrap();
        assert_eq!(data["name"], sf["name"]);
    }

    // En el archivo v2 no queda en claro ni un titulo ni un tipo.
    let raw = fs::read(&e.dest).unwrap();
    for fila in f["credential_entries"].as_array().unwrap() {
        let t = fila["title"].as_str().unwrap().as_bytes();
        assert!(!raw.windows(t.len()).any(|w| w == t), "titulo en claro");
    }
}

#[test]
fn maestra_equivocada_no_toca_nada() {
    let d = vectores();
    let e = escena();
    let antes = hash_tree(e.src.db.parent().unwrap());
    let wrong = d["boveda"]["wrongPassword"].as_str().unwrap();
    assert_eq!(
        migrate(&e.src, &e.mkc, &e.almacen, wrong, &e.dest, &e.backup).err(),
        Some(CoreError::WrongPassword)
    );
    assert_eq!(hash_tree(e.src.db.parent().unwrap()), antes);
    assert!(!e.dest.exists() && !e.backup.exists());
}

#[test]
fn archivo_alterado_aborta_y_la_v1_queda_intacta() {
    let e = escena();
    // Un .enc con un bit cambiado: no descifra, la migracion debe abortar sin activar la v2.
    let victima = fs::read_dir(&e.src.secure_files_dir)
        .unwrap()
        .next()
        .unwrap()
        .unwrap()
        .path();
    let mut bytes = fs::read(&victima).unwrap();
    let last = bytes.len() - 1;
    bytes[last] ^= 1;
    fs::write(&victima, bytes).unwrap();
    let antes = hash_tree(e.src.db.parent().unwrap());

    assert_eq!(
        migrate(&e.src, &e.mkc, &e.almacen, &e.password, &e.dest, &e.backup).err(),
        Some(CoreError::Decrypt)
    );
    assert_eq!(
        hash_tree(e.src.db.parent().unwrap()),
        antes,
        "la v1 no se toca"
    );
    assert!(!e.dest.exists());
    assert!(!PathBuf::from(format!("{}.migrando", e.dest.display())).exists());
    assert!(
        e.backup.join("vault_guard_db.sqlite").exists(),
        "la copia previa se queda"
    );
}

#[test]
fn no_pisa_una_v2_existente_ni_una_copia_previa() {
    let e = escena();
    fs::create_dir_all(e.dest.parent().unwrap()).unwrap();
    fs::write(&e.dest, b"ya hay algo").unwrap();
    assert_eq!(
        migrate(&e.src, &e.mkc, &e.almacen, &e.password, &e.dest, &e.backup).err(),
        Some(CoreError::AlreadyExists)
    );
    fs::remove_file(&e.dest).unwrap();
    fs::create_dir_all(&e.backup).unwrap();
    fs::write(e.backup.join("algo"), b"x").unwrap();
    assert_eq!(
        migrate(&e.src, &e.mkc, &e.almacen, &e.password, &e.dest, &e.backup).err(),
        Some(CoreError::AlreadyExists)
    );
    assert!(e.src.db.exists());
}
