# spec-kit — Guía de uso (interna)

Esta guía explica cómo crear y mantener **especificaciones técnicas en Markdown** usando el template `spec-kit-template` en GitHub y el flujo **Plan → Write → Review** en VS Code + Copilot.

---

## 0) Requisitos previos

- Git configurado (credenciales para GitHub).
- (Recomendado) VS Code + GitHub Copilot habilitado.
- (Opcional) `gh` CLI para crear repos desde template automáticamente.
- (Opcional) Python 3.8+ para mkdocs y herramientas avanzadas (`tools/`).
- (Recomendado) Activar *Agent Skills* (preview):
  - VS Code Settings → `chat.useAgentSkills` = `true`

---

## 1) Crear el workspace (bootstrap automático — recomendado)

El modo más rápido es usar el script de bootstrap, que configura todo de forma interactiva:

**Windows (PowerShell):**

```powershell
# Opción A: one-liner (descarga y ejecuta)
irm https://raw.githubusercontent.com/lksnext/spec-kit-template/main/tools/bootstrap.ps1 | iex

# Opción B: desde un clon local del template
.\tools\bootstrap.ps1
```

**macOS / Linux (Bash):**

```bash
# Opción A: one-liner
curl -sL https://raw.githubusercontent.com/lksnext/spec-kit-template/main/tools/bootstrap.sh | bash

# Opción B: desde un clon local del template
bash tools/bootstrap.sh
```

El script guía por 5 pasos:

1. **Prerequisites** — detecta `git`, `code`, `gh`, `python`
2. **Project name** — nombre del proyecto + directorio base
3. **Spec repo** — crear desde GitHub template, clonar, o usar existente
4. **Codebase** — repo existente, clonar URL, crear vacío, o skip
5. **Extras** — venv + mkdocs, extensiones VS Code, abrir VS Code

Resultado:

```
mi-proyecto/
├── spec-mi-proyecto/          ← spec (desde el template)
├── mi-proyecto/               ← codebase
└── mi-proyecto.code-workspace ← workspace VS Code
```

Flags disponibles: `--workspace-only`, `--no-venv`, `--no-open`, `--yes`, `--dry-run`.

---

## 2) Crear el workspace (manual)

Si prefieres no usar el bootstrap:

1. Ir a GitHub → repositorio **`spec-kit-template`**.
2. Pulsar **Use this template**.
3. Crear el repositorio nuevo (normalmente **Private**).
4. Nombre recomendado:
   - `spec-<cliente>-<proyecto>` o el estándar interno acordado.
5. Clonar el nuevo repo y el codebase (si existe) en carpetas hermanas.
6. Crear un archivo `.code-workspace`:

```json
{
  "folders": [
    { "name": "spec",     "path": "./spec-mi-proyecto" },
    { "name": "codebase", "path": "./mi-proyecto" }
  ],
  "settings": {
    "powershell.cwd": "codebase",
    "chat.useAgentSkills": true
  },
  "extensions": {
    "recommendations": [
      "GitHub.copilot",
      "GitHub.copilot-chat"
    ]
  }
}
```

7. Abrir el workspace en VS Code: `code mi-proyecto.code-workspace`

---

## 3) Flujo estándar (Plan → Write → Review)

Este es el flujo recomendado para casi todos los proyectos. Se ejecuta por **iteraciones**.

### 3.1 Arranque

En Copilot Chat:

1: Ejecuta **`/new-spec`** *(o usa el agente `intake`)*
   Resultado:

   - `docs/spec/00-context.md` con contexto mínimo real
   - `docs/spec/95-open-questions.md` con OPENQ iniciales

### 3.2 Planificación de iteración

2: Ejecuta **`/plan-iteration`** *(o usa el agente `planner`)*
   Resultado:

   - `docs/spec/01-plan.md` con tareas atómicas (5–15) + DoD
   - gates: `OPENQ` y `DECISION` si proceden

### 3.3 Redacción / ejecución del plan

3: Ejecuta **`/write-from-plan`** *(o usa el agente `writer`)*
   Resultado:

   - documentos de `docs/` actualizados según el plan
   - trazabilidad mínima en `docs/spec/02-trazabilidad.md`
   - nuevos `TODO-###` y `OPENQ-###` si aparece trabajo o dudas

### 3.4 Revisión crítica + ADR automáticos

4: Ejecuta **`/review-and-adr`** *(o usa el agente `reviewer`)*
   Resultado:

   - `docs/spec/97-review-notes.md` con observaciones accionables
   - creación automática de ADR en `docs/spec/adr/` si detecta `DECISION:` sin ADR enlazado

### 3.5 Iterar

- Repite **Writer ↔ Reviewer** hasta cumplir el DoD de `docs/spec/01-plan.md`.

---

## 4) Convenciones importantes (para todo el equipo)

### 4.1 IDs

- FR: `FR-###` → `docs/spec/10-requisitos-funcionales.md`
- NFR: `NFR-###` → `docs/spec/11-requisitos-tecnicos-nfr.md`
- UI: `UI-###` → `docs/30-ui-spec.md`
- API: `API-###` → `docs/60-backend.md`
- EVT (asíncrono): `EVT-###` → `docs/60-backend.md` (si aplica)
- OPENQ: `OPENQ-###` → `docs/spec/95-open-questions.md`
- TODO: `TODO-###` → `docs/spec/96-todos.md`
- ADR: `ADR-####` → `docs/spec/adr/`

### 4.2 Marcadores permitidos durante elaboración

- `TODO:` trabajo pendiente (si es relevante, también en `docs/spec/96-todos.md`)
- `OPENQ:` duda importante (también en `docs/spec/95-open-questions.md`)
- `RISK:` riesgo detectado
- `DECISION:` decisión pendiente (debe acabar en ADR)

### 4.3 Calidad mínima

- FR: siempre con **criterios de aceptación verificables** + prioridad.
- NFR: siempre con **métrica objetivo** o **verificación explícita**.
- Trazabilidad: `docs/spec/02-trazabilidad.md` debe mantenerse “mínimo pero vivo”.
- Decisiones relevantes: siempre como ADR (el reviewer puede crearlas).

---

## 5) Previsualizar documentación en navegador (opcional)

El repo incluye `mkdocs.yml`.

### Opción A (simple)

Usa el preview Markdown de VS Code.

### Opción B (MkDocs local)

```powershell
cd <NOMBRE_DEL_REPO>
python -m venv .venv
.\.venv\Scripts\activate
pip install mkdocs mkdocs-material
mkdocs serve
```

Luego abre la URL que indique la consola (normalmente `http://127.0.0.1:8000/`).

---

## 6) Recomendaciones de colaboración (equipo)

- Trabajar por iteraciones: una iteración debe ser revisable y con DoD claro.
- Usar PRs para revisión si hay más de una persona editando.
- Mantener `docs/spec/95-open-questions.md` actualizado: las dudas críticas deben estar ahí.
- Mantener `docs/spec/97-review-notes.md` accionable: cada observación debe acabar en cambio, TODO, OPENQ o ADR.
- Si el proyecto crece, crear ADRs temprano: evita decisiones “escondidas” en texto.
