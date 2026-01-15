---
name: write-from-plan
description: Ejecuta docs/01-plan.md (redacción/actualización de documentos), manteniendo trazabilidad y creando TODO/OPENQ cuando proceda.
---

Objetivo: ejecutar el plan como “tareas de implementación” sobre docs/.

Instrucciones:
1) Lee docs/01-plan.md y ejecuta tareas en orden.
2) Para cada tarea:
   - edita solo los archivos indicados (o el mínimo imprescindible)
   - cumple el Resultado/DoD de la tarea
   - si falta info: marca OPENQ: y registra OPENQ-### en docs/95-open-questions.md
   - si surge trabajo nuevo: crea TODO-### en docs/96-todos.md
   - si detectas una decisión: marca DECISION: (el Reviewer abrirá ADR)
3) Actualiza docs/02-trazabilidad.md (mínimo) cuando crees/amplíes FR/UI/API/entidades.
4) Evita reescrituras masivas; prioriza cambios incrementales.

Usa rutas explícitas tipo docs/... (no enlaces relativos desde este prompt).
