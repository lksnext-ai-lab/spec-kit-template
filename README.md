# Spec Kit Template

> **Versión:** `2.5.4` — fuente única en [`VERSION`](VERSION) <!-- x-release-please-version -->

Plantilla para crear **especificaciones técnicas** en Markdown con VS Code + GitHub Copilot, siguiendo un flujo agéntico: **Entender → Especificar → RFC → Implementar**, versionado con Git.

> Este repositorio es una **plantilla**. Los contenidos en `docs/` son placeholders para iniciar una especificación real en un repo creado desde aquí.

---

## Quick start

El script de bootstrap crea automáticamente el workspace completo (spec + codebase + archivo `.code-workspace`), detecta e instala dependencias opcionales y abre VS Code.

```
  +==============================================================+
  |                                                              |
  |       _____ ____  ___________     __ __ ________             |
  |      / ___// __ \/ ____/ ___/    / //_//  _/_  __/           |
  |      \__ \/ /_/ / __/ / /       / ,<   / /  / /              |
  |     ___/ / ____/ /___/ /___    / /| |_/ /  / /               |
  |    /____/_/   /_____/\____/   /_/ |_/___/ /_/                |
  |                                                              |
  |  Workspace Bootstrap                              v2.X.X     |
  |  by LKS Next                                                 |
  |                                                              |
  +==============================================================+
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/lksnext-ai-lab/spec-kit-template/main/tools/bootstrap.ps1 | iex
```

**macOS / Linux (Bash):**

```bash
curl -sL https://raw.githubusercontent.com/lksnext-ai-lab/spec-kit-template/main/tools/bootstrap.sh | bash
```

**Requisitos:** solo `git`. Opcionalmente: `gh` (GitHub CLI), `python 3.8+`, `code` (VS Code CLI).

> **¿Desde dónde ejecutarlo?** Desde cualquier carpeta. El script pregunta un **directorio base** (por defecto la carpeta actual) y crea todo dentro de él.

El script guía por los pasos: nombre del proyecto, directorio base, creación del spec desde el template de GitHub, enlace o creación del codebase, y configuración de venv/extensiones.

En ejecuciones posteriores, si ya existe una instalación (`tools/.speckit`), el bootstrap entra en **modo actualización**: comprueba la versión remota, muestra un menú interactivo (ver changelog, ver archivos afectados, aplicar o saltar) y actualiza solo los archivos del kit sin tocar `docs/spec/**` ni el codebase.

Flags adicionales: `--check` (CI: exit 0/1 según estado) · `--update` (forzar reaplicación).

Guía completa: [USAGE.md](USAGE.md).

---

## Alternativa: uso manual

1. En GitHub, pulsa **Use this template** para crear un repositorio nuevo.
2. Clona el repositorio y ábrelo en VS Code.
3. Crea el workspace manualmente (ver [USAGE.md](USAGE.md)).

---

## Qué incluye

- **Documentación** en `docs/spec/` — contexto, requisitos, UI, arquitectura, datos, backend, seguridad, infra y ADRs.
- **Instructions** en `.github/copilot-instructions.md` + `.github/instructions/` — reglas globales de repo, spec y codebase.
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

---

## Estructura del workspace (recomendada)

Spec Kit funciona como un **workspace multi-root** en VS Code con dos proyectos:

```
mi-proyecto/
 spec-mi-proyecto/        spec (este template)
 mi-proyecto/             codebase (nuevo o existente)
 mi-proyecto.code-workspace
```

El bootstrap genera este layout automáticamente.

### Estructura principal del spec

| Archivo | Contenido |
|---|---|
| `docs/spec/index.md` | Índice de la especificación |
| `docs/spec/00-context.md` | Contexto del proyecto |
| `docs/spec/01-plan.md` | Plan de iteración activo |
| `docs/spec/02-trazabilidad.md` | Trazabilidad |
| `docs/spec/10-...` / `11-...` | Requisitos funcionales y NFR |
| `docs/spec/adr/` | Decisiones de arquitectura (ADRs) |

---

## Configuración recomendada en VS Code

Activar `chat.useAgentSkills = true` (preview) para que Copilot cargue automáticamente los skills del repo.

---

## Vista en navegador (opcional)

```bash
python -m venv .venv
.\.venv\Scripts\activate      # Windows
pip install mkdocs mkdocs-material
mkdocs serve
```

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

> Note: Project governance may require maintainer approval for changes.

---

## Legal

- **Autoría:** desarrollado y mantenido por **LKS Next** — ver [NOTICE](NOTICE).
- **Licencia:** Apache License 2.0 — ver [LICENSE](LICENSE).
- **Proyectos generados:** el proyecto generado desde esta plantilla puede elegir su propia licencia y no está obligado a ser Apache-2.0 — ver [OUTPUT.md](OUTPUT.md).
- **Marcas:** ver [TRADEMARKS.md](TRADEMARKS.md).