---
name: close-iteration
description: Cierra la iteración activa (Ixx) de forma determinista con `tools/close_iteration.py` (snapshot + preparación de Iyy), usando dry-run obligatorio y validación estricta. Minimiza churn y evita cierres manuales grandes.
---

# close-iteration

## Objetivo
Cerrar la iteración actual (Ixx) y preparar la siguiente (Iyy) de forma **determinista** usando `tools/close_iteration.py`, evitando ediciones manuales grandes (copypaste/movidos) que pueden truncarse o mezclar histórico.

---

## Reglas duras
- **Dry-run obligatorio** antes de ejecutar el cierre real.
- **Siempre** ejecutar el script con `--ixx` y `--next` cuando se tenga certeza de los valores.
- No cierres “a mano” moviendo/pegando documentos completos.
- No borrar archivos manualmente.
- No tocar `docs/kit/**`.
- Ignorar `docs/spec/history/**` como fuente de verdad (solo se valida que el snapshot se ha creado bien).

---

## Preflight (obligatorio, para evitar mezclas)
Antes del dry-run:
1) Asegúrate de estar en el root del repo.
2) Asegúrate de que no hay cambios “accidentales” mezclados con el cierre.
   - Recomendación práctica: revisar el estado de tu working tree y decidir si:
     - incluyes esos cambios (idealmente commit previo), o
     - los apartas (stash/descartar) para cerrar una iteración limpia.

> Este prompt no ejecuta git; solo exige que el cierre se haga con control.

---

## Lectura previa (obligatoria)
- `docs/spec/01-plan.md` (para detectar Ixx y comprobar que no está mezclado)
- `docs/spec/95-open-questions.md`
- `docs/spec/96-todos.md`
- `docs/spec/97-review-notes.md`
- `docs/spec/index.md`

---

## Paso 0 — Detectar Ixx e Iyy (fail-fast)
1) Lee `docs/spec/01-plan.md` y detecta la iteración activa `Ixx` (I01/I02/...).
2) Determina `Iyy` como el siguiente correlativo (I01→I02→...).

### Caso “01-plan mezclado o ambiguo”
Si `docs/spec/01-plan.md` parece mezclar iteraciones (múltiples Ixx, secciones cerradas/archivadas, etc.) o no se puede inferir con seguridad:
- **NO continúes**.
- Pide al usuario los valores exactos:
  - “¿Qué iteración cierras (Ixx) y cuál es la siguiente (Iyy)?”

---

## Paso 1 — Proponer comando (dry-run)
Genera un comando listo para copiar/pegar.

> Usar rutas con `/` para compatibilidad (PowerShell, CMD, Bash, zsh).

Dry-run (siempre con Ixx/Iyy):
- `python tools/close_iteration.py --dry-run --ixx I01 --next I02`

Alternativa Windows si se usa `py`:
- `py tools/close_iteration.py --dry-run --ixx I01 --next I02`

Pide al usuario que ejecute el dry-run y pegue la salida.

### Qué debe verificar el usuario en la salida del dry-run
- Que el script va a crear/actualizar `docs/spec/history/<Ixx>/`.
- Qué archivos van a snapshotearse (al menos: `01-plan.md`, `95-open-questions.md`, `96-todos.md`, `97-review-notes.md`, y referencias de `index.md` si aplica).
- Que **no** toca rutas fuera de `docs/spec/**`.
- Que no va a sobrescribir un histórico existente de `<Ixx>` de forma inesperada.
  - Si el dry-run sugiere overwrite/conflicto: **detener** y corregir Ixx/Iyy o revisar la situación.

---

## Paso 2 — Ejecutar cierre real
Solo después de revisar que el dry-run es correcto, genera el comando real:

- `python tools/close_iteration.py --ixx I01 --next I02`

Alternativa Windows:
- `py tools/close_iteration.py --ixx I01 --next I02`

---

## Paso 3 — Validación estricta (obligatoria)
Tras ejecutar el comando real, validar (leyendo o pidiendo al usuario verificar):

### A) Histórico creado y coherente
- Existe `docs/spec/history/<Ixx>/`.
- Dentro existen snapshots (mínimo):
  - `01-plan.md`
  - `95-open-questions.md`
  - `96-todos.md`
  - `97-review-notes.md`
- Contenido razonable (no truncado/recortado).
  - Verificación rápida: abrir 1–2 y comprobar que no están vacíos o incompletos.

### B) Activos preparados para Iyy (limpios)
- `docs/spec/01-plan.md` ahora corresponde a `Iyy` y está limpio (sin restos de Ixx).
- Importante: el plan nuevo usa **Pxx** (plan).  
  Si aparecen **Txx** en `01-plan.md`, tratarlo como fallo de cierre/plantilla (Txx queda reservado para implementación `spc-imp`).

### C) Enlaces y continuidad
- `docs/spec/index.md` referencia el histórico de `<Ixx>` (si el script lo hace).
- `95-open-questions.md` y `96-todos.md` quedan en estado consistente para Iyy:
  - o bien filtrados a pendientes,
  - o bien con enlace explícito al histórico de Ixx (según diseño del script).

### D) Señales de “no efectos colaterales”
- No se han cambiado archivos fuera de `docs/spec/**` como parte del cierre.

---

## Qué hacer si la validación falla
- Si falta `history/<Ixx>` o faltan snapshots:
  - no arreglar moviendo/pegando a mano.
  - repetir dry-run y re-ejecutar con `--ixx/--next` correctos.
- Si `01-plan.md` queda mezclado o con restos de Ixx:
  - tratarlo como fallo del cierre (o del script) y corregir repitiendo el proceso, no a mano.

---

## Salida en el chat (obligatoria)
- Ixx cerrada e Iyy preparada
- Comandos usados (dry-run + run)
- Carpeta creada: `docs/spec/history/<Ixx>/`
- Snapshots verificados
- Qué pasa a Iyy (OPENQ/TODO) según resultado del script
- Siguiente acción sugerida:
  - ejecutar `/plan-iteration` para planificar Iyy
  - después `/write-from-plan` y `/review-and-adr`
