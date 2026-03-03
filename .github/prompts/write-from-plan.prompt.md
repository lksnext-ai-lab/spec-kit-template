---
name: write-from-plan
description: Ejecuta la iteración activa en `docs/spec/01-plan.md` para materializar cambios en `docs/spec/**` de forma incremental, trazable y sin invenciones. Procesa tareas `Pxx` y respeta `Tipo` (spec/rfc/imp). Modo `auto` decide qué ejecutar y qué derivar a agentes canónicos, minimizando riesgo y churn.
---

# write-from-plan

## Objetivo
Ejecutar la **iteración activa** de `docs/spec/01-plan.md` y materializar cambios en `docs/spec/**`, con:
- disciplina anti-invención,
- trazabilidad incremental,
- gates (OPENQ/TODO/DECISION),
- y decisiones de derivación automáticas (rfc/imp) cuando corresponda.

---

## Parámetros opcionales
- `EXECUTE_TYPES` (default `auto`):
  - `auto`: ejecuta `spec` y solo ejecuta `rfc/imp` si es “trivial y seguro” (ver heurísticas)
  - `spec`: solo `Tipo=spec`
  - `spec,rfc`: `spec` + `rfc`
  - `spec,rfc,imp`: todo (solo si se fuerza)
- `OPENQ_MODE` (default `link-only`): `link-only` | `write`
- `TODO_MODE` (default `write`): `write` | `link-only`
- `UPDATE_TRACEABILITY` (default `true`)
- `MAX_TASKS` (default `12`)
- `STOP_ON_BLOCKERS` (default `2`): detenerse si se generan >= N bloqueos reales (OPENQ/DECISION) que impiden continuar
- `REPORT_VERSION` (default `1.0`)

---

## Reglas duras
- No inventar requisitos ni detalles técnicos.
- Evitar reescrituras masivas: cambios incrementales y diff-friendly.
- Ignorar `docs/spec/history/**`.
- No usar shell/PowerShell/Bash.
- Ejecutar solo la iteración activa. Si `01-plan.md` está mezclado → detener y recomendar `/close-iteration` + `/plan-iteration`.

---

## Lectura previa obligatoria
1) `docs/spec/01-plan.md`
2) `docs/spec/00-context.md`
3) `docs/spec/95-open-questions.md` y `docs/spec/96-todos.md` (solo para dedupe)
4) ADRs `docs/spec/adr/**` (si aplica)
5) `docs/spec/02-trazabilidad.md` (si `UPDATE_TRACEABILITY=true`)

---

## Parseo del plan (Pxx)
- Extraer tabla: `Pxx | Tipo | Tarea | Archivos | Resultado-DoD | Bloqueos`.
- Validar que IDs son Pxx (no Txx). Si hay Txx → detener y recomendar regenerar con `/plan-iteration`.

---

## Orden de ejecución (reordenamiento mínimo, sin replanificar)
Dentro del conjunto de tareas ejecutables:
1) tareas que crean/definen base (FR/NFR/arquitectura) antes que
2) tareas de trazabilidad/indexes antes que
3) tareas de refinamiento/edición.

Regla:
- No cambiar el plan; solo escoger este orden interno para ejecutar mejor.

---

## Heurísticas “trivial y seguro” (EXECUTE_TYPES=auto)

### Para `Tipo=rfc` (ejecutar solo si)
- Existe spec suficiente (no hay blockers críticos abiertos sobre decisiones del RFC), y
- el trabajo es principalmente:
  - generar el RFC a partir de archivos de spec ya existentes, o
  - completar secciones formales con links a spec (sin inventar).
Si no cumple: derivar a `spc-rfc-writer`.

### Para `Tipo=imp` (ejecutar solo si)
- El plan pide *solo*:
  - crear/actualizar `docs/spec/spc-imp-backlog.md`, o
  - crear stubs de tareas,
  - sin tocar CODEBASE.
Si no cumple: derivar a `spc-imp-backlog-slicer` (y luego detailer/auditor).

---

## Ejecución tarea a tarea
Para cada Pxx ejecutable:
- Editar SOLO archivos listados (o el mínimo imprescindible si falta uno crítico).
- Cumplir Resultado/DoD con outputs verificables.
- Añadir links a evidencias internas (docs/spec) cuando corresponda.
- Si aparece un bloqueo real:
  - registrar `OPENQ` o `DECISION` o `TODO` según corresponda,
  - incrementar contador de blockers,
  - si blockers >= `STOP_ON_BLOCKERS` → detener ejecución (para evitar ruido).

---

## Gestión de OPENQ/TODO/DECISION
### OPENQ
- `OPENQ_MODE=write`: crear/actualizar `docs/spec/95-open-questions.md` con `OPENQ-###`.
- `OPENQ_MODE=link-only`: no escribir; proponer en el resumen.

### TODO
- `TODO_MODE=write`: crear/actualizar `docs/spec/96-todos.md` con `TODO-###`.
- `TODO_MODE=link-only`: no escribir; proponer en el resumen.

### DECISION
- Marcar `DECISION:` en el documento afectado o en sección de decisiones si existe.
- No crear ADR aquí.

---

## Trazabilidad incremental (si UPDATE_TRACEABILITY=true)
Actualizar `docs/spec/02-trazabilidad.md` solo para lo tocado en esta pasada:
- FR ↔ UI ↔ API/EVT ↔ Entidades ↔ ADR (si aplica).

---

## Salida en el chat (resumen estable)

```yaml
report_version: "<REPORT_VERSION>"
iteration: "Ixx"
executed_tasks: ["P01","P02", "..."]
skipped_tasks: ["P05", "..."]
skipped_reason: "derivation|blocked|type-not-allowed"
files_updated: ["docs/spec/..", "..."]
blockers_created: <n>
openq_mode: "<OPENQ_MODE>"
todo_mode: "<TODO_MODE>"
next_recommended: ["spc-spec-reviewer", "..."]
```

* Lista breve de cambios por archivo
* Gates creados/propuestos (OPENQ/TODO/DECISION)
* Pendientes por derivación:

  * `rfc` → `spc-rfc-writer` / `spc-rfc-reviewer`
  * `imp` → `spc-imp-backlog-slicer` → `spc-imp-task-detailer` → `spc-imp-coverage-auditor`
