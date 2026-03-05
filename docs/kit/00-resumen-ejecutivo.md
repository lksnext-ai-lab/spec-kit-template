# Resumen ejecutivo

`spec-kit-template` es una plantilla de repositorio para crear y mantener **especificaciones técnicas en Markdown** de forma consistente, iterativa y versionada con Git, apoyándose en **VS Code + GitHub Copilot** (prompts, agentes y skills).

El objetivo es que la especificación no sea un documento “estático”, sino un conjunto de artefactos vivos que se construyen mediante un ciclo repetible:

Ciclo: **Plan → Redacción → Revisión → Iteración**

> Recomendación de uso: enfoque **director-first**. El usuario se dirige al agente `spc-spec-director` y este orquesta el resto del flujo sin exigir conocer la mecánica interna.

---

## Qué problema resuelve

En equipos de desarrollo es habitual que las especificaciones:

- se queden incompletas o desactualizadas,
- no conecten requisitos con UI/API/datos/decisiones,
- y dependan demasiado de la persona que las redacta.

Este template aporta:

- **estructura** (carpetas y documentos predefinidos),
- **convenciones** (IDs, marcadores, trazabilidad, ADR),
- y un **flujo asistido por IA** (Plan/Writer/Reviewer) para acelerar la creación y mejorar la calidad, manteniendo gates explícitos (`OPENQ`, `DECISION`, `RFC needed`).

---

## Qué incluye (visión rápida)

- `docs/spec/`: la **especificación** (lo que se redacta para un proyecto concreto).
- `docs/kit/`: la **guía del sistema** (cómo funciona el template y cómo usarlo).
- `.github/agents/`: **agentes organizados en 3 suites** (convención `spc-<fase>-<rol>`):
  - **SPEC** (flujo principal de especificación):
    - `spc-spec-director` (puerta única / orquestación)
    - `spc-spec-intake` (formaliza contexto en one-shot; invocado por el Director)
    - `spc-codebase-discovery` (documenta codebase existente; opcional, modo evolutivo)
    - `spc-spec-planner` (plan de iteración activa)
    - `spc-spec-writer` (redacción desde plan)
    - `spc-spec-reviewer` (revisión crítica + ADR)
  - **RFC** (propuestas consolidadas para stakeholders):
    - `spc-rfc-writer` / `spc-rfc-reviewer`
  - **SPC-IMP** (backlog de implementación trazable):
    - `spc-imp-backlog-slicer` / `spc-imp-task-detailer` / `spc-imp-coverage-auditor`

  > Nota de IDs:
  > - En SPEC, el plan usa **P01..Pnn** en `docs/spec/01-plan.md`.
  > - En implementación, las tareas usan **T01..Tnn** (backlog y fichas Txx).

- `.github/prompts/`: **comandos** de trabajo (`/new-spec`, `/plan-iteration`, `/write-from-plan`, `/review-and-adr`, `/close-iteration`, `/audit-spec-vs-codebase`, `/evidence-pack`, `/export-docx`).
- `.github/skills/`: **skills reutilizables** (FR/NFR/UI/arquitectura/seguridad/infra + codebase_scout/evidence_pack/RFC/SPC-IMP + export-docx).
- **Modo evolutivo**: soporte para trabajar con codebase existente (lectura, Evidence Packs, verificación externa cuando sea necesaria para no inventar).
- `mkdocs.yml`: navegación y previsualización en navegador (Material for MkDocs).

---

## Resultados esperados

Cuando se usa correctamente, el equipo obtiene:

- una especificación coherente y navegable,
- trazabilidad mínima FR ↔ UI ↔ API/EVT ↔ Datos ↔ ADR,
- un registro explícito de dudas (OPENQ), tareas (TODO) y decisiones (ADR),
- un histórico de cambios (Git) que refleja la evolución del producto,
- y un flujo que permite introducir correctivos cuando aparecen hallazgos en implementación (sin “romper” el proceso).

---

## A quién va dirigido

- Equipos que necesitan generar especificaciones técnicas de manera rápida pero sólida.
- Coordinadores / arquitectos que quieren consistencia y revisión crítica.
- Equipos que iteran con frecuencia y necesitan que la documentación “acompañe” al producto.

---

## Qué NO pretende ser

- No es una herramienta de gestión de proyecto (no sustituye Jira).
- No genera pantallas ni diseño visual final (define especificaciones de UI, no maquetas).
- No sustituye decisiones humanas: ayuda a documentarlas, revisarlas y mantenerlas trazables.

Siguiente lectura recomendada: **`10-objetivo-y-alcance.md`**.
