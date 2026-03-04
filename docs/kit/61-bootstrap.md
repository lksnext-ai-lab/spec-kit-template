# Bootstrap: crear un workspace desde cero

El script de bootstrap (`tools/bootstrap.ps1` en Windows, `tools/bootstrap.sh` en Unix/Mac) automatiza la creación de un workspace completo de spec-kit en un solo comando.

Es el punto de entrada recomendado cuando comienzas un proyecto nuevo desde cero.

---

## Qué hace

En un único flujo guiado de 5 pasos, el script:

1. Comprueba las herramientas necesarias (git, VS Code, GitHub CLI, Python)
2. Crea o clona el repositorio de spec desde el template
3. Vincula (o crea) un repositorio de codebase, si aplica
4. Genera el archivo `.code-workspace` de VS Code
5. (Opcional) Instala dependencias Python (MkDocs) y extensiones de VS Code

Al terminar tienes una **carpeta lista para abrir en VS Code** con todo configurado.

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

Al arrancar, el script muestra un header con la versión actual y una barra de progreso:

```
  +==============================================================+
  |                                                              |
  |       _____ ____  ___________     __ __ ________            |
  |      / ___// __ \/ ____/ ___/    / //_//  _/_  __/          |
  |      \__ \/ /_/ / __/ / /       / ,<   / /  / /             |
  |     ___/ / ____/ /___/ /___    / /| |_/ /  / /              |
  |    /____/_/   /_____/\____/   /_/ |_/___/ /_/               |
  |                                                              |
  |  Workspace Bootstrap                              v2.2.0     |
  |                                                              |
  +==============================================================+
```

En la parte inferior se muestra una barra de progreso con los 5 pasos:

```
  Step 0/5  ----------------------------------------  0%

  [ Prerequisites ] [ Project ] [ Spec repo ] [ Codebase ] [ Extras ]
```

---

## Paso 1 — Prerequisites (verificación de herramientas)

El script verifica las herramientas disponibles:

```
  STEP 1 / 5 -- Checking prerequisites
  ________________________________________________________

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
  ________________________________________________________

  > Project name (e.g. mi-app): mi-crm
  > Base directory [C:\Dev]:
```

- **Project name**: nombre del proyecto. Se normaliza a minúsculas y sin caracteres especiales (ej. `Mi CRM` → `mi-crm`). El repo de spec se llamará `spec-mi-crm`.
- **Base directory**: carpeta donde se crearán los subdirectorios. Por defecto, el directorio actual.

---

## Paso 3 — Spec repo (repositorio de especificación)

```
  STEP 3 / 5 -- Spec repository
  ________________________________________________________

    [1] Create from GitHub template (requires gh CLI)   ← por defecto si gh está disponible
    [2] Clone template locally (no GitHub repo)         ← por defecto si no hay gh
    [3] I already have the spec cloned

  > Choose [1]:
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

```
  STEP 4 / 5 -- Codebase project
  ________________________________________________________

    [1] Existing local repo     ← vincular carpeta ya existente
    [2] Clone from URL          ← clonar desde Git
    [3] Create empty (git init) ← proyecto nuevo desde cero
    [4] Skip (no codebase for now)

  > Choose [1]:
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
  ________________________________________________________

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
  +==============================================================+
  |                                                              |
  |  Next steps:                                                 |
  |    1. Open the workspace in VS Code                          |
  |    2. In Copilot Chat: @spc-spec-director                    |
  |    3. Or run /new-spec to start the specification            |
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
