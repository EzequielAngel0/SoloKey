# Ramas y commits

| Rama | Rol |
|---|---|
| `main` | Lo publicado (releases). Solo el dueño mergea a `main`, con la feature terminada y probada. |
| `develop` | Integración. Todo el trabajo entra aquí primero. CI corre en cada push. |
| `<tipo>/<tema>` | Rama corta desde `develop`, una por cambio; se borra al mergear. |

Prefijos (los mismos tipos que el commit): `feat/` · `fix/` · `docs/` · `chore/` · `test/` · `refactor/`.

## Flujo

```bash
git switch develop && git pull --ff-only
git switch -c feat/mi-cambio
# trabajar; commits con el formato de abajo
git push -u origin feat/mi-cambio
git switch develop && git pull --ff-only
git merge --no-ff feat/mi-cambio && git push
git branch -d feat/mi-cambio && git push origin --delete feat/mi-cambio
```

Publicar: PR `develop -> main`, solo cuando el dueño lo pida.

## Commits

- **Una sola línea**: `tipo(ambito): descripcion concreta`. Tipos: `feat | fix | chore | docs | test | refactor`.
- Español **sin acentos** (ASCII). Sin cuerpo, sin bullets y **sin pies de firma** (nada de "Co-Authored-By" ni "Generated with").
- Concreto: qué regla, pantalla o arreglo exacto. Ejemplo: `fix(sync): el resumen cuenta los archivos seguros aplicados en el delta`.

## Varias sesiones a la vez

Dos sesiones sobre el MISMO árbol se pisan (comparten el index de git y el hook analiza todo el árbol). Cada sesión
paralela trabaja en su propio worktree:

```powershell
git worktree add ..\SoloKey-<tema> -b feat/<tema> develop
```

Para quitarlo, **no** uses `git worktree remove` a secas si hubo `flutter pub get` o un build de Windows dentro: sigue
las uniones de `windows/flutter/ephemeral/.plugin_symlinks` y vacía el caché de Pub de TODOS los proyectos. Usa
`.\tool\quitar-worktree.ps1 ..\SoloKey-<tema>` (quita las uniones antes y se niega si hay cambios sin subir).
