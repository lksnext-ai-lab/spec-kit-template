# Resumen ejecutivo

`spec-kit-template` es una plantilla de repositorio para crear y mantener **especificaciones técnicas en Markdown** de forma consistente, iterativa y versionada con Git, apoyándose en **VS Code + GitHub Copilot** (prompts, agentes y skills).

El objetivo es que la especificación no sea un documento “estático”, sino un conjunto de artefactos vivos que se construyen mediante un ciclo repetible:

Ciclo: **Plan → Redacción → Revisión → Iteración**

## Qué problema resuelve

En equipos de desarrollo es habitual que las especificaciones:

- se queden incompletas o desactualizadas,
- no conecten requisitos con UI/API/datos/decisiones,
- y dependan demasiado de la persona que las redacta.

Este template aporta:

- **estructura** (carpetas y documentos predefinidos),
- **convenciones** (IDs, marcadores, trazabilidad, ADR),
- y un **flujo asistido por IA** (Plan/Writer/Reviewer) para acelerar la creación y mejorar la calidad.

## Qué incluye (visión rápida)

- `docs/spec/`: la **especificación** (lo que se redacta para un proyecto concreto).
- `docs/kit/`: la **guía del sistema** (cómo funciona el template y cómo usarlo).
- `.github/agents/`: agentes (intake / planner / writer / reviewer).
- `.github/prompts/`: comandos de trabajo (`/new-spec`, `/plan-iteration`, `/write-from-plan`, `/review-and-adr`).
- `.github/skills/`: skills reutilizables para FR/NFR/UI/arquitectura/seguridad/infra.
- `mkdocs.yml`: navegación y previsualización en navegador (Material for MkDocs).

## Resultados esperados

Cuando se usa correctamente, el equipo obtiene:

- una especificación coherente y navegable,
- trazabilidad mínima FR ↔ UI ↔ API/EVT ↔ Datos ↔ ADR,
- un registro explícito de dudas (OPENQ), tareas (TODO) y decisiones (ADR),
- y un histórico de cambios (Git) que refleja la evolución del producto.

## A quién va dirigido

- Equipos que necesitan generar especificaciones técnicas de manera rápida pero sólida.
- Coordinadores / arquitectos que quieren consistencia y revisión crítica.
- Equipos que iteran con frecuencia y necesitan que la documentación “acompañe” al producto.

## Qué NO pretende ser

- No es una herramienta de gestión de proyecto (no sustituye Jira).
- No genera pantallas ni diseño visual final (define especificaciones de UI, no maquetas).
- No sustituye decisiones humanas: ayuda a documentarlas y a revisarlas.

Siguiente lectura recomendada: **`10-objetivo-y-alcance.md`**.
