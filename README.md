# Spec Kit Template

Plantilla para crear **especificaciones técnicas** en Markdown con VS Code + Copilot, siguiendo un flujo “agentic”:
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
- Agentes (custom agents) en `.github/agents/`:
  - `intake` · `planner` · `writer` · `reviewer` (con creación automática de ADRs al detectar `DECISION:`).
- Prompt files en `.github/prompts/` (comandos `/new-spec`, `/plan-iteration`, `/write-from-plan`, `/review-and-adr`).
- Skills en `.github/skills/` (reutilizables para FR/NFR/UI/arquitectura/seguridad/infra).
- `mkdocs.yml` para navegación y vista en navegador (opcional).

## Cómo usar esta plantilla (crear una nueva especificación)

1) En GitHub, abre este repo y pulsa **Use this template** para crear un repositorio nuevo (privado o público, según tus necesidades).  
2) Clona el repositorio nuevo y ábrelo en VS Code.

Guía completa de uso: **`USAGE.md`**.

## Estructura principal

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
