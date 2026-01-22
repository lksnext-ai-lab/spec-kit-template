# Estructura del repositorio

Este documento describe la organización del repositorio `spec-kit-template`, separando claramente:

- la **especificación** que se redacta para un proyecto (`docs/spec/`)
- y la **guía del sistema** (`docs/kit/`)
además de los componentes de soporte IA (agentes, prompts y skills).

---

## Vista general (alto nivel)

Estructura típica:

- `docs/`
  - `spec/` → **especificación del proyecto** (lo que generan/modifican agentes y equipo)
    - `adr/` → decisiones (ADR)
    - `history/` → histórico de iteraciones (snapshots cerrados)
  - `kit/` → **guía del spec-kit** (documentación del template/sistema)
  - `assets/` → recursos compartidos (imágenes, diagramas, etc.)
- `.github/`
  - `copilot-instructions.md` → reglas globales del repo para Copilot/agentes
  - `agents/` → custom agents (roles de trabajo)
  - `prompts/` → prompt files ejecutables (`/new-spec`, `/plan-iteration`, etc.)
  - `skills/` → skills reutilizables (plantillas/patrones de salida)
  - `workflows/` → CI (lint, build docs, etc.)
  - `CODEOWNERS` → gobierno del repo
  - `PULL_REQUEST_TEMPLATE.md` → checklist de PR
- `mkdocs.yml` → navegación/tema de la documentación (Material)
- `README.md` / `USAGE.md` → introducción y guía de uso rápida
- `.editorconfig`, `.gitattributes` → consistencia de formato/line endings

---

## Carpeta `docs/`

### `docs/spec/` — Especificación del proyecto

Aquí vive el contenido que describe el sistema a construir. Es el área de trabajo “normal” del equipo y de los agentes.

Características:

- Markdown “modular” por secciones.
- Convenciones de IDs (FR/NFR/UI/API/OPENQ/TODO/ADR).
- Trazabilidad mínima.
- Decisiones explícitas como ADRs.
- Trabajo por iteraciones (plan ejecutable por iteración).

Archivos principales (orientativo):

- `index.md` (índice / punto de entrada)
- `00-context.md` (objetivo, alcance, restricciones)
- `01-plan.md` (plan de la iteración **activa**)
- `02-trazabilidad.md` (mapa mínimo de vínculos)
- `10-...` FR, `11-...` NFR
- `20-...` conceptualización
- `30-...` UI spec
- `40-...` arquitectura
- `50-...` datos
- `60-...` backend
- `70-...` frontend
- `80-...` seguridad
- `90-...` infra
- `95-open-questions.md`, `96-todos.md`, `97-review-notes.md` (estado “vivo”)

#### `docs/spec/adr/` — ADRs (decisiones)

Decisiones relevantes capturadas como registros, siguiendo un formato consistente.

- `ADR-0001-template.md` sirve como plantilla.
- Los ADRs nuevos se crean cuando aparece `DECISION:` en la spec y el reviewer lo detecta.

> Nota: dentro de `docs/spec/**` se permiten enlaces relativos (por ejemplo `adr/ADR-0002-...md`).

#### `docs/spec/history/` — Histórico de iteraciones (snapshots)

Carpeta para almacenar snapshots de iteraciones cerradas, con el objetivo de:

- evitar que `01-plan.md` acumule iteraciones antiguas,
- evitar que `95-open-questions.md`, `96-todos.md` y `97-review-notes.md` crezcan sin control,
- y mantener un “estado vivo” pequeño y accionable para agentes y equipo.

Convención:

- Cada iteración cerrada se archiva en `docs/spec/history/<Ixx>/` (por ejemplo, `docs/spec/history/I01/`).

Reglas de uso:

- Por defecto, prompts y agentes deben **ignorar** `docs/spec/history/**` durante Plan/Write/Review.
- Solo el prompt **`/close-iteration`** puede crear/actualizar contenido dentro de `docs/spec/history/**`.
- El índice `docs/spec/index.md` debe enlazar el histórico para navegación y auditoría.

---

### `docs/kit/` — Guía del spec-kit (manual del sistema)

Documentación interna del template y su uso.

Propósito:

- explicar cómo funciona el sistema (IA + estructura),
- definir el flujo recomendado,
- documentar configuración y troubleshooting,
- y permitir onboarding del equipo.

Regla crítica:

- `docs/kit/**` no debe ser modificado por prompts/agentes salvo petición explícita.

---

### `docs/assets/` — Recursos compartidos

Carpeta común para imágenes/diagramas que se referencian desde `spec` o `kit`.

Buenas prácticas:

- nombrado claro (ej. `arch-overview.png`, `ui-flow-checkout.svg`)
- evitar assets duplicados
- mantener tamaño razonable

---

## Carpeta `.github/` (soporte IA y gobierno)

### `.github/copilot-instructions.md`

Reglas globales de trabajo del repo:

- alcance (qué tocar / qué no tocar)
- calidad mínima por documento
- proceso (Plan → Write → Review → Iterate)
- convenciones (IDs, OPENQ/TODO/ADR)
- reglas sobre histórico (`docs/spec/history/**`) y quién puede escribir ahí

Es el “contrato” que guía al asistente y ayuda a que el equipo trabaje homogéneamente.

---

### `.github/agents/` — Custom agents

Agentes con rol y responsabilidad definida. Normalmente:

- `60-intake.agent.md` → arranque/entrevista
- `70-planner.agent.md` → planificación de iteraciones
- `80-writer.agent.md` → redacción según plan
- `90-reviewer.agent.md` → revisión crítica + ADR

Los agentes deben:

- operar sobre `docs/spec/**` (estado vivo),
- **ignorar** `docs/spec/history/**`,
- evitar enlaces relativos en `.github/**` (usar rutas desde raíz: `docs/spec/...`).

---

### `.github/prompts/` — Prompt files

Comandos reutilizables que ejecutas en Copilot Chat, por ejemplo:

- `/new-spec`
- `/plan-iteration`
- `/write-from-plan`
- `/review-and-adr`
- `/close-iteration`

Los prompt files:

- implementan el flujo recomendado,
- producen cambios en archivos (principalmente en `docs/spec/**`),
- y proporcionan consistencia de salida.

Regla práctica:

- en `.github/**` evitar enlaces relativos como `./...` (provoca rutas erróneas).

---

### `.github/skills/` — Skills

“Bloques de conocimiento” reutilizables para producir contenido consistente.

Ejemplos:

- requisitos FR / NFR
- UI spec
- arquitectura
- seguridad baseline
- infra

Los skills ayudan a:

- normalizar estructura y vocabulario,
- asegurar que FR/NFR/UI se redactan con calidad mínima,
- acelerar redacción sin perder coherencia.

---

### `.github/workflows/` — CI

Automatizaciones que ayudan a calidad:

- lint de Markdown
- build de MkDocs (`mkdocs build --strict`)

---

## Archivos de configuración (raíz)

### `mkdocs.yml`

Define:

- navegación (secciones Spec y Kit)
- tema (Material)
- extensiones Markdown

### `.editorconfig` y `.gitattributes`

Garantizan consistencia entre sistemas (especialmente Windows):

- line endings (LF)
- encoding
- espacios finales, etc.

---

## Recomendaciones de organización

- Mantener `docs/spec/` “limpio” y orientado a especificación.
- Mantener `docs/kit/` como manual del sistema y onboarding.
- Evitar duplicar reglas: si algo es “norma”, mejor en `copilot-instructions.md` y referenciar desde otros documentos.
- Usar PRs para cambios en `.github/**` y en la estructura del template.
- Cerrar iteraciones de forma explícita: usar `/close-iteration` para archivar snapshots y mantener el plan activo limpio.

Siguiente lectura recomendada: **`40-documentacion-generada.md`**.
