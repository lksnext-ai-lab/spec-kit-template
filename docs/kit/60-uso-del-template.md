# Uso del template (crear repo, clonar y arrancar una spec)

Este documento explica cómo usar `spec-kit-template` para crear una nueva especificación de proyecto, cómo trabajar con VS Code + Copilot y cómo mantener el repositorio de forma ordenada en un equipo.

> Nota: Este template está pensado para uso interno. Adapta nombres, permisos y normas de tu organización.

> **Atajo recomendado:** si quieres crear el workspace completo (spec + codebase + `.code-workspace`) en un solo paso, usa el script de bootstrap: `tools/bootstrap.ps1` (Windows) o `tools/bootstrap.sh` (Unix/Mac). Ver [61-bootstrap.md](61-bootstrap.md) para instrucciones detalladas.

---

## 1) Crear un nuevo repositorio a partir del template

### Opción A — “Use this template” (recomendada)

1) En GitHub, abre el repositorio `spec-kit-template`.
2) Pulsa **Use this template** → **Create a new repository**.
3) Nombra el repo siguiendo una convención clara, por ejemplo:
   - `spec-<cliente>-<proyecto>`
   - `spec-<producto>-<mvp>`
4) Define visibilidad (normalmente **privado** en entorno corporativo).
5) Crea el repositorio.

Ventajas:

- copia la estructura completa (docs/spec + docs/kit + .github),
- deja todo listo sin scripts adicionales.

---

### Opción B — Script interno (alternativa)

Si tu equipo quiere estandarizar más (naming, etiquetas, permisos), se puede usar un script interno para crear repos desde el template mediante API/CLI, pero añade complejidad de mantenimiento.

Recomendación:

- empezar con Opción A,
- y solo migrar a script cuando haya necesidad real.

---

### Opción C — Script de bootstrap (recomendada para workspace completo)

Si necesitas crear el repo de spec, vincular un codebase existente y generar el archivo `.code-workspace` de VS Code en un solo paso:

```powershell
# Windows
.\tools\bootstrap.ps1
```

```bash
# Unix / Mac
bash tools/bootstrap.sh
```

El script guia paso a paso: verifica herramientas, pide nombre de proyecto, ofrece opciones para el repo de spec y el codebase, y genera todo automáticamente.

Ver [61-bootstrap.md](61-bootstrap.md) para una guía completa del script con pantallas y opciones.

---

## 2) Clonar en local y abrir en VS Code

Ejemplo (Windows / PowerShell):

```powershell
cd C:\Dev
git clone <URL-del-nuevo-repo>
cd <carpeta-del-repo>
code .
```

---

## 3) Pre-requisitos de VS Code + Copilot

Recomendado:

* VS Code actualizado
* Git configurado
* GitHub Copilot habilitado
* Acceso a Copilot Chat en el repo

Opcional (pero muy útil):

* extensión de Markdown (lint, preview mejorado)
* extensión de MkDocs si el equipo la usa (no imprescindible)

---

## 4) Arranque controlado de una nueva especificación

> Recomendación de UX: usa el enfoque **director-first** (agente `spc-spec-director`). El Director conduce la entrevista de contexto directamente, gestiona el flujo completo de forma conversacional y delega a los subagentes sin que el usuario tenga que pensar en el proceso interno.

### Paso 1 — Arrancar con Intake (`/new-spec` o agente Director)

En Copilot Chat, tienes dos opciones equivalentes de arranque:

**Opción A (rápida):** ejecuta `/new-spec` y responde a la entrevista mínima.
**Opción B (recomendada):** usa el agente `spc-spec-director`. El Director conduce la entrevista por rondas (máximo 2 preguntas por turno) y al terminar formaliza los documentos automáticamente.

El resultado debe actualizar/crear:

* `docs/spec/00-context.md`
* `docs/spec/index.md`
* `docs/spec/95-open-questions.md` (si aplica)

Objetivo:

* dejar la spec "arrancada" con alcance y terminología mínima,
* sin inventar datos (si falta info → OPENQ).

---

### Paso 2 — Planificar la primera iteración con `/plan-iteration` (o agente Planner)

Ejecuta `/plan-iteration` (o usa el agente `spc-spec-planner`) para actualizar:

* `docs/spec/01-plan.md`

Objetivo:

* definir 5–15 tareas atómicas con DoD,
* y una lista clara de entregables en `docs/spec/**`.

Nota operativa:

* `docs/spec/01-plan.md` representa **una única iteración activa**.
* IDs del plan en SPEC: **P01..Pnn** (Pxx).
  (Los IDs **Txx** se reservan para tareas de implementación.)

---

### Paso 3 — Redactar siguiendo el plan con `/write-from-plan` (o agente Writer)

Ejecuta `/write-from-plan` (o usa el agente `spc-spec-writer`) para:

* completar las tareas del plan (Pxx),
* actualizar trazabilidad (`docs/spec/02-trazabilidad.md`) al mínimo vivo,
* registrar OPENQ/TODO/DECISION según aparezcan.

---

### Paso 4 — Revisión crítica con `/review-and-adr` (o agente Reviewer)

Ejecuta `/review-and-adr` (o usa el agente `spc-spec-reviewer`) para:

* generar/actualizar `docs/spec/97-review-notes.md`,
* crear OPENQ/TODO si procede,
* y crear ADRs automáticamente cuando existan `DECISION:` sin ADR enlazado.

---

### Paso 5 — (Recomendado) Cerrar iteración con `/close-iteration`

Cuando la iteración esté completada (o decidas cerrarla formalmente), ejecuta `/close-iteration` para:

* archivar snapshots en `docs/spec/history/Ixx/`,
* "limpiar" los archivos activos (`01-plan.md`, `95/96/97`) dejándolos como **estado vivo**,
* preparar el repo para planificar la siguiente iteración sin mezclar planes ni inflar ficheros.

---

## 5) Trabajo diario (iteraciones)

Ciclo recomendado:

1. `/plan-iteration` → plan corto y verificable (iteración activa)
2. `/write-from-plan` → ejecutar tareas
3. `/review-and-adr` → revisión + ADR
4. (Opcional recomendado) `/close-iteration` → archivar y preparar siguiente iteración
5. Repetir: planificar I02, ejecutar, revisar, cerrar…

Buenas prácticas:

* Mantener iteraciones pequeñas (mejor varias rondas cortas).
* Evitar "reescrituras masivas".
* Mantener `OPENQ` y `TODO` al día.
* Tratar `docs/spec/history/**` como **solo lectura** para el día a día:

  * por defecto, prompts/agentes deben ignorarlo para planificar/redactar/revisar.

---

## 6) Recomendación de flujo Git (equipo)

### Opción simple (equipo pequeño)

* Commits directos a main con mensajes claros por iteración.
* Revisión ligera manual antes de mezclar cambios grandes.

### Opción recomendada (equipo mediano)

* Rama por iteración o por bloque:

  * `iter/I01`
  * `feature/fr-mvp`
  * `review/adr-decisions`
* Pull Request con checklist (si existe plantilla).
* Un revisor (mínimo) antes de merge.

---

## 7) Qué se edita y qué no (recordatorio)

Por defecto:

* Sí: `docs/spec/**`
* Sí (si hace falta): `docs/assets/**`
* No: `docs/kit/**` (salvo petición explícita)
* Cambios en `.github/**` deben tratarse como cambios de plataforma (revisar con cuidado).

---

## 8) Checklist de “spec lista para compartir”

Antes de compartir una especificación:

* `docs/spec/00-context.md` está claro (IN/OUT, roles, restricciones).
* FR con criterios verificables y estados.
* NFR con métricas/validación.
* UI con estados mínimos.
* Backend con catálogo de errores y authz.
* Seguridad + infra con operación real.
* Trazabilidad mínima actualizada.
* `docs/spec/97-review-notes.md` sin bloqueantes abiertos.
* `OPENQ` y `TODO` revisados (y marcados como aceptados si quedan abiertos).
* (Recomendado) Iteración cerrada con `/close-iteration` si se va a iniciar una nueva iteración o a congelar un baseline:

  * histórico generado en `docs/spec/history/Ixx/`
  * archivos activos "limpios" y manejables.

---

## 9) Workflows adicionales

Además del flujo principal (Plan → Write → Review → Iterate), el template soporta workflows especializados:

### 9.1 Generación de propuestas RFC

Para documentar cambios complejos o decisiones críticas antes de implementarlas:

* **Agentes**: `spc-rfc-writer` / `spc-rfc-reviewer`
* **Skill**: `rfc-proposal`
* **Salida**: propuestas estructuradas con alternativas, impacto, costos y estrategia

Ver `docs/kit/52-custom-agents.md` para más detalle.

### 9.2 Gestión de backlog de implementación (SPC-IMP)

Para proyectos grandes donde la spec debe generar backlog ejecutable de implementación:

* **Agentes**: `spc-imp-backlog-slicer` / `spc-imp-task-detailer` / `spc-imp-coverage-auditor`
* **Skills**: `spc-imp-task-definition` / `generate-tool-permissions`
* **Workflow**: slicing de spec en tareas atómicas, definición detallada, auditoría de cobertura

Ver `docs/kit/52-custom-agents.md` y `docs/kit/54-skills.md` para más detalle.

---

## 10) Modo evolutivo con codebase

Cuando trabajas en un proyecto que ya tiene código implementado:

### 10.1 Configuración del workspace

* El codebase debe estar en el workspace (normalmente en carpeta `codebase/` o similar).
* El repo de spec puede estar en otro workspace folder paralelo.
* Los agentes pueden **leer** el codebase pero **nunca modificarlo**.

### 10.2 Flujo de trabajo recomendado

1. **Generar codebase-map**: usa el skill `codebase_scout` para crear `docs/spec/_inputs/codebase-map.md`.
2. **Planificar con evidencia**: al planificar iteraciones, consulta el codebase-map para decisiones técnicas.
3. **Generar Evidence Packs**: cuando una sección requiera precisión técnica específica:

   * Usa el prompt `/evidence-pack` o el skill `evidence_pack`
   * Salida: `docs/spec/_inputs/evidence/EP-###-<tema>.md`
4. **Citar evidencia**: en decisiones técnicas relevantes, enlaza o referencia:

   * Rutas del codebase: `codebase/<ruta/al/archivo>`
   * Evidence Packs: `docs/spec/_inputs/evidence/EP-###-<tema>.md`
5. **OPENQ si no hay evidencia**: si no encuentras evidencia suficiente tras buscar en el codebase:

   * No inventar: registrar `OPENQ-###` indicando qué falta y dónde se buscó

### 10.3 Prompts específicos para modo evolutivo

* `/audit-spec-vs-codebase`: audita consistencia entre spec y código
* `/evidence-pack`: genera Evidence Pack para un tema específico

Ver `docs/kit/53-prompts.md` para más detalle.

---

## 11) Siguiente lectura recomendada

* Bootstrap (crear workspace en un paso): `docs/kit/61-bootstrap.md`
* Operativa diaria: `docs/kit/70-operativa-diaria.md`
* Previsualización en navegador: `docs/kit/80-previsualizacion-mkdocs.md`
* FAQ/troubleshooting: `docs/kit/95-faq-y-troubleshooting.md`

---

## 12) Exportar la documentación a DOCX (Word)

Este repositorio permite exportar la documentación a un archivo **DOCX** (Word) para compartirla fuera del repo.

### Requisitos

* Tener **Pandoc** instalado y disponible en PATH.
* Tener Python disponible para ejecutar el script del repo.
* (Opcional) Puedes usar el prompt `/export-docx` para que Copilot te genere el comando exacto.

### Exportar SPEC (docs/spec/**)

Por defecto:

* **NO** se incluye TOC (tabla de contenidos),
* cada archivo `.md` empieza en **una nueva página** (a través del script).

```powershell
python tools\export_docx.py --scope spec --output exports\spec.docx --title "Especificación técnica"
```

Si quieres TOC:

```powershell
python tools\export_docx.py --scope spec --output exports\spec.docx --title "Especificación técnica" --toc
```

Si NO quieres saltos de página entre ficheros:

```powershell
python tools\export_docx.py --scope spec --output exports\spec.docx --title "Especificación técnica" --no-page-break
```

---

### Exportar KIT (docs/kit/**)

```powershell
python tools\export_docx.py --scope kit --output exports\kit.docx --title "Spec-kit: guía interna"
```

---

### Notas

* El resultado se genera en `exports/`.
* Para comprobar Pandoc:

  ```powershell
  pandoc --version
  ```
