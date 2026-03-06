# Bootstrap: instalar y actualizar SPEC KIT

El script de bootstrap (`tools/bootstrap.ps1` en Windows, `tools/bootstrap.sh` en Unix/Mac) automatiza la creación de un workspace completo de spec-kit en un solo comando.

Además, detecta instalaciones existentes y ofrece un flujo interactivo de **auto-actualización** para mantener el kit al día.

Es el punto de entrada recomendado tanto para proyectos nuevos como para actualizar proyectos en desarrollo.

---

## Qué hace

El script detecta automáticamente en qué modo debe operar:

### Modo instalación (primera vez)

En un único flujo guiado de 5 pasos:

1. Comprueba las herramientas necesarias (git, VS Code, GitHub CLI, Python)
2. Crea o clona el repositorio de spec desde el template
3. Vincula (o crea) un repositorio de codebase, si aplica
4. Genera el archivo `.code-workspace` de VS Code
5. (Opcional) Instala dependencias Python (MkDocs) y extensiones de VS Code

Al terminar tienes una **carpeta lista para abrir en VS Code** con todo configurado.

### Modo actualización (ejecuciones posteriores)

Si el script detecta el archivo `tools/.speckit` (generado en la primera instalación):

1. Compara la versión instalada con la última versión del template remoto
2. Muestra un menú interactivo con opciones: actualizar, ver changelog, ver archivos afectados, o saltar
3. Verifica el estado de git antes de sobrescribir (con doble confirmación si hay cambios sin commit)
4. Aplica la actualización copiando solo los archivos gestionados por el kit
5. Ofrece recargar VS Code para que los cambios en agentes/skills surtan efecto

> **Importante:** las actualizaciones nunca tocan `docs/spec/**` ni el codebase. Solo se actualizan los archivos del kit (agentes, skills, prompts, instructions, docs/kit, tools, etc.).

---

## Cómo ejecutarlo

### Windows (PowerShell)

```powershell
cd C:\Dev
.\spec-kit-template\tools\bootstrap.ps1
```

> Si PowerShell bloquea la ejecución de scripts: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

### Unix / Mac (Bash)

```bash
cd ~/Dev
bash spec-kit-template/tools/bootstrap.sh
```

---

## Pantalla de inicio

Al arrancar, el script muestra un header con la versión actual, branding de LKS Next y una barra de progreso:

```
  +==============================================================+
  |                                                              |
  |       _____ ____  ___________     __ __ ________            |
  |      / ___// __ \/ ____/ ___/    / //_//  _/_  __/          |
  |      \__ \/ /_/ / __/ / /       / ,<   / /  / /             |
  |     ___/ / ____/ /___/ /___    / /| |_/ /  / /              |
  |    /____/_/   /_____/\____/   /_/ |_/___/ /_/               |
  |                                                              |
  |  Workspace Bootstrap                              v2.3.0     |
  |  by LKS Next                                                 |
  |                                                              |
  +==============================================================+
```

En modo instalación, la parte inferior muestra una barra de progreso con los 5 pasos:

```
  Step 0/5  ----------------------------------------  0%

  [ Prerequisites ] [ Project ] [ Spec repo ] [ Codebase ] [ Extras ]
```

En modo actualización, pasa directamente al menú de actualización (ver sección más abajo).

---

## Paso 1 — Prerequisites (verificación de herramientas)

El script verifica las herramientas disponibles:

```
  STEP 1 / 5 -- Checking prerequisites
  --------------------------------------------------------

    ✓ Git        2.43.0         (requerido)
    ✓ VS Code    1.87.0         (opcional)
    ✓ GitHub CLI 2.44.1         (opcional — para crear repo en GitHub)
    ○ Python     — no encontrado (opcional — para MkDocs/venv)

    All required tools found.

  Press Enter to continue...
```

- **Git** es el único requerido. Sin él, el script se detiene.
- Las demás herramientas son opcionales: si no están, simplemente se deshabilita la opción correspondiente.

---

## Paso 2 — Project (nombre y directorio)

```
  STEP 2 / 5 -- Project name and location
  --------------------------------------------------------

  > Project name (e.g. mi-app): mi-crm
  > Base directory [C:\Dev]:
```

- **Project name**: nombre del proyecto. Se normaliza a minúsculas y sin caracteres especiales (ej. `Mi CRM` → `mi-crm`). El repo de spec se llamará `spec-mi-crm`.
- **Base directory**: carpeta donde se crearán los subdirectorios. Por defecto, el directorio actual.

---

## Paso 3 — Spec repo (repositorio de especificación)

El selector interactivo permite navegar con las flechas del teclado. Al mover entre opciones, se muestra un panel contextual con una descripción detallada de cada una:

```
  How do you want to set up the spec repository?

    --> * Create from GitHub template
        o Clone template locally
        o Use existing spec repo

    +-------------------------------------------------------+
    |  Creates a new private/public repo in your GitHub     |
    |  org using the spec-kit-template. Requires the        |
    |  GitHub CLI (gh) to be installed and authenticated.   |
    |                                                       |
    +-------------------------------------------------------+

    Up/Down Navigate   Enter Select                     1/3
```

### Opción 1 — Crear repo en GitHub desde el template

Requiere GitHub CLI (`gh`) autenticado. El script pedirá:

```
  > GitHub org/user for the new repo [lksnext-ai-lab]: mi-org
  > Visibility
      [1] Private    ← recomendado
      [2] Public
  > Choose [1]:
```

Crea el repo `mi-org/spec-mi-crm` en GitHub a partir del template y lo clona localmente.

### Opción 2 — Clonar localmente sin crear repo en GitHub

Clona el template directamente en local, desvincula el origen git y hace el commit inicial. Ideal para empezar sin GitHub o para uso interno.

### Opción 3 — Usar un repo de spec ya clonado

```
  > Path to existing spec repo: C:\Dev\spec-mi-crm
```

Simplemente apunta a una carpeta existente. El script solo generará el workspace file.

---

## Paso 4 — Codebase (repositorio del código)

El selector interactivo funciona igual que el anterior:

```
  How do you want to set up the codebase project?

    --> * Existing local repo
        o Clone from URL
        o Create empty (git init)
        o Skip (no codebase for now)

    +-------------------------------------------------------+
    |  Link an existing codebase project already on your    |
    |  machine. The bootstrap adds it to the VS Code        |
    |  workspace as a second root folder.                   |
    |                                                       |
    +-------------------------------------------------------+

    Up/Down Navigate   Enter Select                     1/4
```

### Opción 1 — Repo existente en local

```
  > Path to codebase repo: C:\Dev\mi-crm-backend
```

Vincula la carpeta como la raíz `codebase` del workspace.

### Opción 2 — Clonar desde URL

```
  > Git clone URL: https://github.com/mi-org/mi-crm.git
  > Local folder name [mi-crm]:
```

Clona el repo dentro del directorio base.

### Opción 3 — Crear carpeta vacía

Crea una carpeta con `git init` dentro del directorio base. Útil cuando el proyecto de código está por empezar.

### Opción 4 — Sin codebase

El workspace solo tendrá la carpeta `spec`. Se puede añadir el codebase más adelante editando el `.code-workspace`.

---

## Paso 5 — Extras (opciones adicionales)

```
  STEP 5 / 5 -- Optional setup
  --------------------------------------------------------

  > Create Python venv and install mkdocs + tools? [Y/n]:
  > Install recommended VS Code extensions? [y/N]:
  > Open VS Code when done? [Y/n]:
```

- **Python venv**: crea `.venv/` en la carpeta spec e instala `mkdocs`, `mkdocs-material` y `pyyaml`. Necesario para previsualizar la documentación en navegador.
- **VS Code extensions**: instala `GitHub.copilot` y `GitHub.copilot-chat` si no están ya instaladas.
- **Abrir VS Code**: abre el workspace automáticamente al terminar.

> Si Python no se encontró en el Paso 1, la opción de venv se omite automáticamente.

---

## Resultado final

```
  +==============================================================+
  |  DONE!                                                       |
  +==============================================================+
  |                                                              |
  |  C:\Dev\                                                     |
  |    +-- spec-mi-crm\              spec                        |
  |    +-- mi-crm\                   codebase                    |
  |    +-- mi-crm.code-workspace     workspace                   |
  |                                                              |
  +--------------------------------------------------------------+
  |                                                              |
  |  Next steps:                                                 |
  |    1. Open the workspace in VS Code                          |
  |    2. In Copilot Chat: @spc-spec-director                    |
  |    3. Or run /new-spec to start the specification            |
  |                                                              |
  +--------------------------------------------------------------+
  |                                                              |
  |  SPEC KIT by LKS Next                                       |
  |  Thank you for using SPEC KIT!                               |
  |                                                              |
  +==============================================================+
```

El archivo `.code-workspace` abre VS Code con ambas carpetas (`spec` y `codebase`) visibles en el explorador, y configura `chat.useAgentSkills: true` para que los agentes de Copilot funcionen correctamente.

---

## Opciones de línea de comando (avanzado)

Para uso automatizado o en CI, el script acepta flags que evitan las preguntas interactivas:

| Flag (PowerShell)    | Flag (Bash)        | Descripción                                         |
|----------------------|--------------------|-----------------------------------------------------|
| `-WorkspaceOnly`     | `--workspace-only` | Solo regenera el `.code-workspace`, sin clonar repos|
| `-NoVenv`            | `--no-venv`        | No crear entorno Python ni instalar dependencias    |
| `-NoOpen`            | `--no-open`        | No abrir VS Code al terminar                        |
| `-Yes`               | `--yes`            | Aceptar todos los valores por defecto               |
| `-DryRun`            | `--dry-run`        | Simular sin crear ni modificar nada                 |
| `-Check`             | `--check`          | Comprobar si hay actualización (exit 0/1, para CI)  |
| `-Update`            | `--update`         | Forzar reaplicación aunque la versión coincida       |

Ejemplos:

```powershell
# Windows: modo silencioso (acepta todo por defecto, no abre VS Code)
.\tools\bootstrap.ps1 -Yes -NoOpen

# Windows: simulación sin crear nada
.\tools\bootstrap.ps1 -DryRun

# Solo regenerar el workspace file (si los repos ya existen)
.\tools\bootstrap.ps1 -WorkspaceOnly
```

```bash
# Unix: modo silencioso
bash tools/bootstrap.sh --yes --no-open

# Unix: simulación
bash tools/bootstrap.sh --dry-run

# CI: comprobar si hay actualización disponible (exit 0 = al día, exit 1 = hay update)
bash tools/bootstrap.sh --check
```

---

## Auto-actualización

Si ejecutas el bootstrap en un proyecto que ya tiene SPEC KIT instalado, el script entra automáticamente en **modo actualización**.

### Detección

El script busca el archivo `tools/.speckit` en la carpeta del spec (relativo a la ubicación del propio script). Este archivo JSON se genera automáticamente en la primera instalación y contiene:

```json
{
  "version": "2.3.0",
  "installed": "2026-03-05T10:30:00Z",
  "updated": null,
  "template": "lksnext-ai-lab/spec-kit-template",
  "mode": "template",
  "managed": [
    ".github/agents",
    ".github/instructions",
    "docs/kit",
    "tools",
    "..."
  ]
}
```

### Menú de actualización

Cuando hay una nueva versión disponible:

```
  Existing SPEC-KIT project detected
  Installed: v2.2.1

  New version available: v2.2.1 -> v2.3.0

  What would you like to do?

    --> * Update to v2.3.0
        o View changelog
        o View files that will change
        o Skip update

    +-------------------------------------------------------+
    |  Updates all managed files: agents, skills, prompts,  |
    |  instructions, docs/kit, tools, and config files.     |
    |  Your spec documents (docs/spec/**) and codebase      |
    |  will NOT be modified.                                |
    +-------------------------------------------------------+

    Up/Down Navigate   Enter Select                     1/4
```

### Protección de cambios sin commit

Si el script detecta cambios sin commit en archivos gestionados, muestra una advertencia y pide doble confirmación antes de sobrescribir:

```
  !!  You have uncommitted changes in managed files:
       M .github/agents/spc-spec-director.agent.md
       M tools/bootstrap.ps1

  How do you want to proceed?

    --> * Abort (I will commit first)
        o Continue anyway (I can recover with git)
```

### Archivos gestionados

La actualización solo afecta a los archivos "gestionados" por el kit:

| Ruta                          | Contenido                              |
|-------------------------------|----------------------------------------|
| `.github/agents/`             | Agentes de Copilot (10 agentes)        |
| `.github/instructions/`       | Instructions por ruta                  |
| `.github/prompts/`            | Prompt files (comandos /)              |
| `.github/skills/`             | Skills de framework                    |
| `.github/workflows/`          | CI workflows                           |
| `.github/copilot-instructions.md` | Instructions globales              |
| `docs/kit/`                   | Documentación del kit                  |
| `tools/`                      | Scripts del kit                        |
| `VERSION`                     | Versión del kit                        |
| `mkdocs.yml`                  | Configuración MkDocs                   |

> **`docs/spec/**` nunca se modifica.** La especificación del proyecto y el codebase quedan intactos.

### Uso en CI

Para integrar la comprobación de versiones en un pipeline de CI:

```yaml
- name: Check SPEC-KIT version
  run: bash tools/bootstrap.sh --check
  # exit 0 = up to date, exit 1 = update available
```

---

## Estructura resultante del workspace

```
C:\Dev\
  spec-mi-crm\          ← repositorio de especificación
    docs/
      spec/             ← la especificación del proyecto
      kit/              ← guía del template (no tocar)
    .github/
      agents/           ← agentes de Copilot
      prompts/          ← comandos /new-spec, /plan-iteration, etc.
    tools/
      bootstrap.ps1     ← este script
      .speckit          ← archivo de control de versión
    .venv/              ← entorno Python (si se instaló)

  mi-crm\               ← codebase del proyecto (si se configuró)
    src/
    ...

  mi-crm.code-workspace ← abrir esto en VS Code
```

---

## Próximos pasos tras ejecutar el script

1. Abre `mi-crm.code-workspace` en VS Code (o déjalo que lo abra automáticamente).
2. En Copilot Chat, escribe `@spc-spec-director` y describe qué quieres especificar.
3. El Director te guiará por el proceso de forma conversacional.

Alternativa con prompts: ejecuta `/new-spec` en Copilot Chat para arrancar directamente.

---

- Flujo de trabajo diario: [70-operativa-diaria.md](70-operativa-diaria.md)
- Uso general del template: [60-uso-del-template.md](60-uso-del-template.md)
- Previsualización en navegador: [80-previsualizacion-mkdocs.md](80-previsualizacion-mkdocs.md)
