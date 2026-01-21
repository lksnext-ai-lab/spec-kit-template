---
name: close-iteration
description: Cierra la iteración activa usando tools/close_iteration.py (snapshot + limpieza) y valida el resultado antes de iniciar Iyy.
---

# Close-iteration


## Objetivo

Cerrar la iteración actual (Ixx) y preparar la siguiente (Iyy) de forma
**determinista** usando el script `tools/close_iteration.py`, evitando ediciones
manuales grandes que puedan truncarse.


## Reglas duras

- NO hagas el cierre “a mano” editando/copypasteando documentos completos.
- El cierre se ejecuta con `python tools\close_iteration.py`
  (Windows/PowerShell).
- No usar comandos destructivos (no borrar).
- Opera SOLO en `docs/spec/**` (no tocar `docs/kit/**`).
- Si no puedes inferir Ixx/Iyy con seguridad, pregunta al usuario.


## Lectura previa (obligatoria)

- `docs/spec/01-plan.md` (para detectar Ixx)
- `docs/spec/95-open-questions.md`
- `docs/spec/96-todos.md`
- `docs/spec/97-review-notes.md`
- `docs/spec/index.md`


## Paso 0 — Detectar iteración

1. Lee `docs/spec/01-plan.md` y detecta la iteración activa `Ixx` (I01/I02/...).
2. Determina `Iyy` incrementando (I01→I02...). Si no es inequívoco, pregunta:
   “¿Qué iteración estás cerrando (Ixx) y cuál es la siguiente (Iyy)?”


## Paso 1 — Proponer comando (dry-run)

Genera un comando listo para copiar/pegar (PowerShell).

- Primero, siempre un dry-run:

  `python tools\close_iteration.py --dry-run`

- Si Ixx/Iyy no se detectan bien, añade explícitamente:

  `python tools\close_iteration.py --dry-run --ixx I01 --next I02`

Pide al usuario que lo ejecute y pegue la salida.


## Paso 2 — Ejecutar cierre real

Tras ver el dry-run, genera el comando real (sin `--dry-run`) para copiar/pegar.
Si el usuario confirma que el output del dry-run es correcto, proceder.

- Comando real:

  `python tools\close_iteration.py`

- Si aplica, con `--ixx/--next`:

  `python tools\close_iteration.py --ixx I01 --next I02`


## Paso 3 — Validación (obligatoria)

Tras ejecutar el comando real, valida leyendo (o pidiendo al usuario que
compruebe) estos puntos.


### A) Histórico

- Existe `docs/spec/history/<Ixx>/`.
- Los snapshots `01-plan.md`, `95-open-questions.md`, `96-todos.md`,
  `97-review-notes.md` en histórico tienen contenido razonable (no “recortado”).

  - Si el usuario lo puede verificar: comparar rápidamente nº de líneas o
    tamaño con los activos previos.


### B) Activos preparados para Iyy

- `docs/spec/01-plan.md` menciona Iyy y es un esqueleto limpio (sin contenido
  viejo de Ixx).
- `docs/spec/95-open-questions.md` y `docs/spec/96-todos.md` tienen enlace a
  histórico y, si se pudo filtrar, solo pendientes.
- `docs/spec/97-review-notes.md` es plantilla limpia para Iyy con enlace a
  histórico.
- `docs/spec/index.md` tiene entrada en “Histórico de iteraciones”.


## Salida en el chat (obligatoria)

- Comando(s) ejecutados (dry-run + real)
- Carpeta de histórico creada
- Archivos afectados (creados/actualizados)
- Qué pasa a Iyy (OPENQ/TODO) si el script pudo filtrarlo
- Siguiente acción sugerida: ejecutar `/plan-iteration` para generar el plan
  detallado de Iyy
