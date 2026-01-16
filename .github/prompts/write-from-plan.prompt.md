---
name: write-from-plan
description: Ejecuta docs/spec/01-plan.md (redacción/actualización de docs), manteniendo trazabilidad y registrando TODO/OPENQ/DECISION con disciplina.
---

Objetivo
Ejecutar `docs/spec/01-plan.md` como “tareas de implementación” y materializarlo en cambios concretos dentro de `docs/spec/`.

Reglas duras
- No inventes requisitos ni detalles técnicos.
- Ejecuta tareas en orden.
- Evita reescrituras masivas: cambios incrementales y seguros.
- Si falta info: marca `OPENQ:` y registra `OPENQ-###` en `docs/spec/95-open-questions.md`.
- Si surge trabajo pendiente: crea `TODO-###` en `docs/spec/96-todos.md`.
- Si aparece una elección relevante: marca `DECISION:` (el Reviewer abrirá el ADR).

Método
1) Lee `docs/spec/01-plan.md` (tareas + DoD de iteración).
2) Por cada tarea Txx:
   - edita solo los archivos indicados (o el mínimo imprescindible),
   - completa el Resultado/DoD de la tarea,
   - añade enlaces y trazabilidad cuando ya existan IDs.
3) Mantén `docs/spec/02-trazabilidad.md` (mínimo):
   - si creas/amplías FR: añade/actualiza fila FR (aunque UI/API estén en TODO)
   - si defines UI: enlaza FR
   - si defines API/EVT: enlaza FR
   - si identificas entidades: enlaza FR
   - si existe ADR asociado: ponlo en la columna ADR (si se conoce)

Gestión de IDs (OPENQ/TODO)
- OPENQ: usa el siguiente número libre en `docs/spec/95-open-questions.md`.
- TODO: usa el siguiente número libre en `docs/spec/96-todos.md`.
- No reutilices IDs.

Salida en el chat (resumen)
- Archivos actualizados (lista)
- FR/NFR/UI/API/EVT/Entidades añadidas o ampliadas (si aplica)
- OPENQ/TODO/DECISION creadas (IDs)
- Recomendación: ejecutar `/review-and-adr` o pasar al agente Reviewer
