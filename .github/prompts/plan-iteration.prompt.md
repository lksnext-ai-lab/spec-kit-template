---
name: plan-iteration
description: Crea/actualiza docs/01-plan.md con una iteración ejecutable (tareas atómicas + DoD) y gates (OPENQ/DECISION).
---

Objetivo: convertir el estado actual de docs/ en un plan ejecutable en docs/01-plan.md.

Instrucciones:
1) Lee docs/00-context.md + índice + estado de docs/ (qué está vacío, qué contradice, qué falta).
2) Actualiza docs/01-plan.md:
   - Metadatos (iteración, fecha, responsable, estado)
   - Objetivo de iteración (1 párrafo)
   - Alcance IN/OUT
   - Entregables (lista de archivos docs a actualizar)
   - Tareas atómicas (5–15) en tabla: ID / Tarea / Archivos / Resultado-DoD
3) Identifica gates:
   - Si falta info: crea/actualiza OPENQ-### en docs/95-open-questions.md y enlázalo en el plan.
   - Si hay decisiones: marca DECISION: en el plan (no crees ADR aquí).
4) No redactes FR/NFR completos ni arquitectura/UI en profundidad (eso es trabajo del Writer).

Usa rutas explícitas tipo docs/... (no enlaces relativos desde este prompt).
