# Spec Kit Template
> **Versión:** `2.1.0` — fuente única en [`VERSION`](VERSION)
Plantilla para crear **especificaciones técnicas** en Markdown con VS Code + COPILOT, siguiendo un flujo “agentic”:
**Plan → Redacción → Revisión → Iteración**, versionado con Git.

> **Proyecto de LKS Next**: este repositorio (spec-kit-template) está desarrollado y mantenido por **LKS Next**.

## Ownership & attribution

**Spec Kit Template** (spec-kit-template) is developed and maintained by **LKS Next**.

See: [NOTICE](NOTICE)

## License

This project is licensed under the **Apache License 2.0**.

See: [LICENSE](LICENSE)

## Output licensing (projects generated from this template)

Using this repository as a template may generate a new project. The generated project can choose its own license and is not required to be Apache-2.0 solely because it was generated from this template.

See: [OUTPUT.md](OUTPUT.md)

## Trademarks

See: [TRADEMARKS.md](TRADEMARKS.md)

## Qué incluye

- Estructura de documentación en `docs/` (contexto, requisitos, UI, arquitectura, datos, backend, seguridad, infra, ADRs).
- **Instructions** en `.github/copilot-instructions.md` + `.github/instructions/` (reglas globales de repo, spec y codebase).
- **Custom agents** en `.github/agents/` — 3 suites, 10 agentes:
  - **SPEC** (director-first): `spc-spec-director` · `spc-spec-intake` · `spc-spec-planner` · `spc-spec-writer` · `spc-spec-reviewer`
  - **RFC**: `spc-rfc-writer` · `spc-rfc-reviewer`
  - **IMP** (backlog): `spc-imp-backlog-slicer` · `spc-imp-task-detailer` · `spc-imp-coverage-auditor`
- **Prompt files** en `.github/prompts/` — 8 comandos:
  - `/new-spec` · `/plan-iteration` · `/write-from-plan` · `/review-and-adr`
  - `/close-iteration` · `/audit-spec-vs-codebase` · `/evidence-pack` · `/export-docx`
- **Skills** en `.github/skills/` — 12 skills de framework + 1 de proyecto:
  - Spec: `spec-style` · `requirements-fr` · `requirements-nfr` · `ui-spec` · `architecture` · `security-baseline` · `infra`
  - Avanzados: `codebase-scout` · `evidence-pack` · `rfc-proposal` · `spc-imp-task-definition` · `export-docx`
- **CI** en `.github/workflows/` (`docs-quality.yml`).
- `mkdocs.yml` para navegación y vista en navegador (opcional).

## Quick start

El bootstrap crea automáticamente el workspace completo (spec + codebase + archivo `.code-workspace`), detecta e instala dependencias opcionales, y abre VS Code.

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/lksnext-ai-lab/spec-kit-template/main/tools/bootstrap.ps1 | iex
```

**macOS / Linux (Bash):**

```bash
curl -sL https://raw.githubusercontent.com/lksnext-ai-lab/spec-kit-template/main/tools/bootstrap.sh | bash
```

**Requisitos:** solo `git`. Opcionalmente: `gh` (GitHub CLI), `python 3.8+`, `code` (VS Code CLI).

> **¿Desde dónde ejecutarlo?** Desde cualquier carpeta. El script pregunta un **directorio base** (por defecto la carpeta actual) y crea todo dentro de él — no hay que preparar nada a mano.

El script guiará por los pasos: nombre del proyecto, directorio base, creación del spec desde el template de GitHub, enlace o creación del codebase, y configuración de venv/extensiones.

Guía completa de uso: **`USAGE.md`**.

## Cómo usar esta plantilla (alternativa manual)

1) En GitHub, abre este repo y pulsa **Use this template** para crear un repositorio nuevo (privado o público, según tus necesidades).  
2) Clona el repositorio nuevo y ábrelo en VS Code.
3) Crea el workspace manualmente (ver `USAGE.md`).

## Estructura del workspace (recomendada)

Spec Kit funciona como un **workspace multi-root** en VS Code con dos proyectos:

```
mi-proyecto/
├── spec-mi-proyecto/       ← spec (este template)
├── mi-proyecto/            ← codebase (nuevo o existente)
└── mi-proyecto.code-workspace
```

El bootstrap genera este layout automáticamente.

## Estructura principal (dentro del spec)

- Índice de la especificación: `docs/spec/index.md`
- Contexto: `docs/spec/00-context.md`
- Plan de iteración: `docs/spec/01-plan.md`
- Trazabilidad: `docs/spec/02-trazabilidad.md`
- Requisitos: `docs/spec/10-...` y `docs/spec/11-...`
- Decisiones: `docs/spec/adr/`

## Ajuste recomendado en VS Code

- Activar (preview) `chat.useAgentSkills = true` para que Copilot cargue automáticamente los skills del repo.

## Vista en navegador (opcional)

El repo incluye `mkdocs.yml`. Si quieres servirlo localmente:

    python -m venv .venv
    .\.venv\Scripts\activate
    pip install mkdocs mkdocs-material
    mkdocs serve

---

Nota: Este repo es una **plantilla**. Los contenidos en `docs/` son placeholders para iniciar una especificación real en un repo creado desde aquí.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

> Note: Project governance may require maintainer approval for changes.
