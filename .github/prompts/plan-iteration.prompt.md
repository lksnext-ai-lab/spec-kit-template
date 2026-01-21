---
name: plan-iteration
description: Crea/actualiza docs/spec/01-plan.md con una iteración ejecutable (tareas atómicas + DoD) y gates (OPENQ/DECISION).
---

# Plan-iteration


## Objetivo

Convertir el estado actual de `docs/spec/` en un plan ejecutable en
`docs/spec/01-plan.md` (tipo “Plan → Write → Review”).


## Reglas

- El plan debe ser breve y ejecutable (no un Jira).
- 5–15 tareas atómicas por iteración.
- No redactes FR/NFR/arquitectura/UI en profundidad: solo planifica.
- Si falta información: crea OPENQ.
- Si hay una elección relevante: marca DECISION (sin crear ADR aquí).
- Ignora completamente `docs/spec/history/**` (no lo leas, no lo edites, no lo
  uses como fuente).
- `docs/spec/01-plan.md` debe contener SOLO la iteración activa:

  - Si detectas que incluye histórico/iteraciones cerradas mezcladas o
    duplicadas, NO intentes “limpiar” ni borrar secciones.
  - En ese caso, detén la generación y recomienda ejecutar `/close-iteration`
    para archivar y dejar `01-plan.md` limpio antes de planificar la siguiente
    iteración.

- No uses comandos de shell / PowerShell / Bash (prohibido `Remove-Item` u
  operaciones destructivas). Solo ediciones de archivos.


## Lectura previa obligatoria

- `docs/spec/00-context.md`
- `docs/spec/index.md`
- Estado general de `docs/spec/` (qué está vacío, qué contradice, qué falta)
- `docs/spec/95-open-questions.md` y `docs/spec/96-todos.md` (para no duplicar)
- (Excluye explícitamente `docs/spec/history/**`)


## Actualizar `docs/spec/01-plan.md` (estructura obligatoria)

- Reescribe el archivo COMPLETO `docs/spec/01-plan.md` en cada ejecución (no
  intentes reemplazos parciales por rangos de líneas).

1. Metadatos:

   - Iteración (ej. I01)
   - Fecha inicio (YYYY-MM-DD)
   - Responsable
   - Estado (Draft/En curso/En revisión/Cerrado)

2. Objetivo de iteración (1 párrafo).
3. Alcance IN/OUT de la iteración.
4. Entregables: lista de archivos `docs/spec/` que deben quedar actualizados.
5. Tareas (tabla): ID / Tarea / Archivos / Resultado-DoD

   - Cada tarea toca 1–3 archivos.
   - Resultado-DoD debe ser verificable (1–3 bullets).
   - Si una tarea depende de info, enlaza la OPENQ en el DoD o en “Decisiones y
     preguntas”.


## Gates (OPENQ/DECISION)

- Si detectas una incertidumbre que cambia contenido:

  - crea/actualiza `docs/spec/95-open-questions.md` con OPENQ-### (siguiente
    número libre)
  - enlázala desde la sección “Decisiones y preguntas abiertas” del plan.

- Si detectas una decisión importante:

  - añade `DECISION:` en el plan (y/o en el doc correspondiente si ya está claro)
  - NO crees ADR aquí (lo hará el Reviewer).


## Opcional (solo si hace falta)

- Si aparece trabajo pendiente fuera de esta iteración: crea `TODO-###` en
  `docs/spec/96-todos.md` (siguiente número libre).


## Salida en el chat (resumen)

- Iteración definida (Ixx)
- Lista de tareas (Txx) creadas
- OPENQ/TODO/DECISION añadidas
- Siguiente acción sugerida: ejecutar `/write-from-plan` o usar el agente Writer
