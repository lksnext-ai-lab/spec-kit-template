# spec-kit-template

Plantilla interna para crear **especificaciones técnicas** en Markdown con un flujo “agentic” en VS Code:
**Plan → Redacción → Revisión → Iteración**, versionado con Git.

## Flujo recomendado (siempre igual)
1. **Intake**: completa contexto mínimo y genera índice inicial.
2. **Planner**: actualiza `docs/01-plan.md` con tareas atómicas + decisiones pendientes.
3. **Writer**: ejecuta el plan editando los documentos en `docs/`.
4. **Reviewer**: revisa con ojos críticos y deja notas accionables en `docs/97-review-notes.md`.
5. Itera (Writer ↔ Reviewer) hasta cumplir el DoD del plan.

## Convenciones rápidas
- Requisitos funcionales: `FR-###` en `docs/10-requisitos-funcionales.md`
- Requisitos técnicos / NFR: `NFR-###` en `docs/11-requisitos-tecnicos-nfr.md`
- Decisiones: `docs/adr/ADR-XXXX.md`
- Marcadores durante elaboración:
  - `TODO:` trabajo pendiente
  - `OPENQ:` pregunta abierta
  - `RISK:` riesgo detectado
  - `DECISION:` decisión pendiente (normalmente acaba en ADR)

## Vista en navegador (opcional)
Este repo incluye `mkdocs.yml`. Si queréis servirlo en local:
1) `python -m venv .venv`
2) Activar venv
3) `pip install mkdocs mkdocs-material`
4) `mkdocs serve`

> Nota: el uso de Material es opcional. Con MkDocs “pelado” también sirve.

