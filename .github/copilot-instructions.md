# Instrucciones globales del repo (spec-kit)

## Objetivo
Generar y mantener especificaciones técnicas en Markdown bajo el flujo:
**Plan → Redacción → Revisión → Iteración**.

## Reglas no negociables
- No inventes requisitos ni detalles técnicos. Si falta información: crea `OPENQ:` y registra la pregunta en `docs/95-open-questions.md`.
- Mantén consistencia entre documentos. Si cambias un concepto, revisa impactos en docs relacionados.
- Todo lo “decisional” debe acabar en un ADR si impacta arquitectura/seguridad/integración/operación.
- Requisitos funcionales usan IDs `FR-###`. NFR usan `NFR-###` y deben ser medibles cuando aplique.
- El archivo `docs/01-plan.md` manda: la redacción debe ejecutarlo y la revisión debe validarlo.

## Marcadores permitidos durante elaboración
- `TODO:` trabajo pendiente (idealmente reflejado también en `docs/96-todos.md`)
- `OPENQ:` pregunta abierta (idealmente en `docs/95-open-questions.md`)
- `RISK:` riesgo
- `DECISION:` decisión pendiente (normalmente → ADR)

## Estilo
- Español, tono profesional, orientado a ejecución.
- Estructura clara, listas y tablas cuando ayuden.
- Criterios de aceptación verificables para cada FR.

