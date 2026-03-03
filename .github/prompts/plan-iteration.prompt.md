---
name: plan-iteration
description: Crea/actualiza `docs/spec/01-plan.md` con UNA iteración activa ejecutable (tareas atómicas + DoD) y gates (OPENQ/DECISION). IDs del plan usan `Pxx` para no colisionar con tareas de implementación `Txx`. Fail-fast si 01-plan contiene histórico mezclado: se recomienda `/close-iteration`.
---

# plan-iteration

## Objetivo
Convertir el estado actual de `docs/spec/` en un plan ejecutable en `docs/spec/01-plan.md` para una única **iteración activa** (Ixx), con tareas atómicas y DoD verificable.

---

## Parámetros opcionales
- `OPENQ_MODE` (default `link-only`):
  - `link-only`: solo referencia OPENQs existentes o propone nuevas (sin escribirlas)
  - `write`: además crea/actualiza `docs/spec/95-open-questions.md`
- `ITERATION_ID` (opcional): forzar Ixx (si no se indica, inferir)
- `OWNER` (opcional): responsable (si no, “Por definir”)
- `PLAN_FOCUS` (opcional): `spec` | `rfc` | `imp` | `mixed` (si no, inferir)
- `MAX_TASKS` (default `12`): 5–15 recomendado

---

## Reglas (hard)
- El plan debe ser breve y ejecutable.
- 5–15 tareas atómicas por iteración (por defecto `MAX_TASKS=12`).
- El plan no redacta la spec: solo define el trabajo a realizar.
- Ignora completamente `docs/spec/history/**` (no leer, no editar).
- No uses comandos de shell/PowerShell/Bash (prohibido cualquier acción destructiva).
- No inventar: si falta info, registrar incertidumbre como OPENQ o DECISION.

---

## Regla sobre `docs/spec/01-plan.md` (iteración activa única)
`docs/spec/01-plan.md` debe contener **solo la iteración activa**.

### Detección de archivo “mezclado”
Considera que `01-plan.md` está mezclado si contiene:
- más de un bloque “Iteración Ixx”,
- o secciones de “cerrado/archivado/histórico”,
- o referencias a varias Ixx como si coexistieran.

**Si está mezclado**:
- NO reescribir el archivo.
- Salida en el chat:
  - “Archivo mezclado: ejecutar `/close-iteration` para archivar y dejar `01-plan.md` limpio.”
- Terminar (fail-fast).

---

## Lectura previa obligatoria
- `docs/spec/00-context.md`
- `docs/spec/index.md` (si existe)
- `docs/spec/95-open-questions.md` y `docs/spec/96-todos.md` (para no duplicar)
- ADRs relevantes: `docs/spec/adr/**` (si existen)
- (Opcional) RFCs existentes en `docs/spec/rfc/**` (para alinear el plan si ya hay RFC activo)

---

## Cómo elegir la iteración (Ixx)
1) Si se provee `ITERATION_ID` → usarlo.
2) Si `01-plan.md` ya tiene iteración activa clara → mantenerla.
3) Si no:
   - inferir el siguiente correlativo libre (I01, I02, ...)
   - documentarlo en metadatos.

---

## Cómo inferir PLAN_FOCUS (si no se provee)
- `spec` si la mayoría de tareas van a `docs/spec/(10|11|20|30|40|50|60|70|80|90)-*` y ADR/OPENQ.
- `rfc` si el objetivo principal es `docs/spec/rfc/**` + `_inputs/rfc/**`.
- `imp` si el objetivo principal es `docs/spec/spc-imp-backlog.md` / `spc-imp-tasks/**`.
- `mixed` si hay un bloque claro de cada tipo.

---

## Formato obligatorio de `docs/spec/01-plan.md`
Reescribir el archivo COMPLETO **solo** si no está mezclado.

### 1) Cabecera estable (para parsing)
- Iteración: Ixx
- Fecha inicio: YYYY-MM-DD
- Owner: <OWNER|Por definir>
- Estado: Draft | En curso | En revisión
- Plan focus: spec | rfc | imp | mixed
- MAX_TASKS: n

### 2) Objetivo de iteración (1 párrafo)
### 3) Alcance IN/OUT (bullets)
### 4) Entregables (lista de archivos a dejar en estado “revisable”)
### 5) Tareas (tabla)

IDs del plan: `P01..Pnn` (plan). No usar `Txx`.

Tabla obligatoria:

| ID (Pxx) | Tipo | Tarea | Archivos | Resultado-DoD | Bloqueos |
|---|---|---|---|---|---|
| P01 | spec/rfc/imp | ... | 1–3 rutas | 1–3 bullets verificables | `-` o `OPENQ/DECISION/...` |

Reglas:
- Cada tarea toca 1–3 archivos.
- DoD verificable (1–3 bullets).
- Si no es ejecutable por falta de info → `Bloqueos` debe contener referencia explícita (OPENQ o DECISION).

### 6) Decisiones y preguntas abiertas (gates)
- `DECISION:` (si aplica, con impacto)
- `OPENQ:` (si aplica)

Reglas para OPENQ:
- Si `OPENQ_MODE=write`:
  - crear/actualizar `docs/spec/95-open-questions.md` (siguiente `OPENQ-###` libre)
- Si `OPENQ_MODE=link-only`:
  - NO escribir el archivo
  - proponer el texto de OPENQ dentro del plan y marcarlo como “(propuesta)”.

### 7) Riesgos y chequeos de calidad (mini)
- 5–10 bullets:
  - riesgos de coherencia
  - dependencias externas
  - puntos donde el reviewer debe mirar con lupa

---

## Salida en el chat (resumen operativo)
- Iteración: Ixx + focus
- Lista de tareas Pxx (con Tipo)
- OPENQ/DECISION creadas o propuestas
- Recomendación “rule-based” de siguiente paso:
  - Si focus incluye `spec` → `spc-spec-writer` luego `spc-spec-reviewer`
  - Si focus incluye `rfc` → `spc-rfc-writer` luego `spc-rfc-reviewer`
  - Si focus incluye `imp` → `spc-imp-backlog-slicer` → `spc-imp-task-detailer` → `spc-imp-coverage-auditor`
