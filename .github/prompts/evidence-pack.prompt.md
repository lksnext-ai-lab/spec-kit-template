---
name: evidence-pack
description: Investiga un TEMA en `codebase/**` (solo lectura) y genera/actualiza un Evidence Pack en `docs/spec/_inputs/evidence/`. Opcionalmente actualiza `codebase-map.md` y crea OPENQs. No inventa: lo no verificable se marca como UNVERIFIABLE y/o OPENQ.
---

# Prompt: Evidence Pack (repo -> evidence)

## Objetivo
- Investigar en `codebase/**` (solo lectura) el TEMA indicado.
- Generar o actualizar un Evidence Pack en `docs/spec/_inputs/evidence/`.
- Si aplica, actualizar `docs/spec/_inputs/codebase-map.md` con cambios mínimos.
- No inventar: si no hay evidencia suficiente, marcarlo como UNVERIFIABLE y/o OPENQ (según modo).

---

## Entrada
- TEMA: <rellenar>
- PISTAS (opcional): <términos, rutas o nombres>
- ALCANCE (opcional): backend | frontend | security | infra | data | ops | api | all

---

## Parámetros opcionales
- `AUDIT_MODE` (default `as-is`):
  - `as-is`: el EP describe el estado actual del repo (realidad)
  - `evolutive`: el EP puede incluir gaps “to-be” (planificados) sin tratarlos como errores
- `TARGET_EP` (opcional):
  - ruta a un EP existente o prefijo `EP-###` para forzar actualización (anti-duplicados)
- `OPENQ_MODE` (default `write`): `write` | `link-only`
- `CODEBASE_MAP_MODE` (default `write`): `write` | `link-only`
- `EP_MODE` (default `write`): `write` | `link-only`
- `MAX_EVIDENCE_PATHS` (default `15`): máximo de rutas citadas en evidencias
- `MAX_EP_LINES` (default `250`): presupuesto de tamaño del EP (prioriza)
- `REPORT_VERSION` (default `1.2`)

---

## Reglas (hard)
- NO crear/editar nada en `codebase/**`.
- Ignorar `docs/spec/history/**` (no leer, no editar).
- No inventar: toda afirmación debe ser:
  - CONFIRMED (con evidencia), o
  - INFERRED (con razón + confianza), o
  - UNVERIFIABLE (y/o OPENQ).
- Evitar churn: nada de reescrituras masivas de `codebase-map.md` ni reordenaciones amplias.
- Respetar presupuestos (`MAX_EVIDENCE_PATHS`, `MAX_EP_LINES`): prioriza lo crítico.

---

## Preparación (obligatoria)
1) Confirmar que existen:
   - `docs/spec/_inputs/evidence/`
   - `docs/spec/_inputs/evidence/_TEMPLATE-evidence-pack.md`
   - `docs/spec/95-open-questions.md`
2) `docs/spec/_inputs/codebase-map.md`:
   - Si existe, usarlo.
   - Si no existe y `CODEBASE_MAP_MODE=write`, crear un skeleton mínimo (ver “Template mínimo”).

---

## Método de investigación

### 1) Plan de búsqueda (registrable)
Genera 3–8 consultas basadas en TEMA/PISTAS/ALCANCE:
- términos funcionales (auth, token, roles, mcp, job, queue…)
- rutas típicas (src/, config/, infra/, api/, controller…)
- fuentes de verdad (README, package/pom/pyproject, docker, env examples)

> Guardar estas consultas en el EP como “Search log”.

### 2) Recolección de evidencia
- Abrir archivos relevantes y extraer:
  - rutas concretas (siempre)
  - identificadores clave (nombres de clases, endpoints, variables), sin copiar bloques largos
- No exceder `MAX_EVIDENCE_PATHS`.

### 3) Síntesis de conclusiones (obligatorio)
Cada conclusión debe quedar clasificada como:
- **CONFIRMED**: evidencia directa
- **INFERRED**: evidencia indirecta (explicar por qué)
- **UNVERIFIABLE**: no hay evidencia suficiente
- **PLANNED_CHANGE**: (solo si `AUDIT_MODE=evolutive`) gap razonable “to-be”

Para cada conclusión añade:
- `CONFIDENCE`: HIGH | MED | LOW
- `SEVERITY`: BLOCKER | MAJOR | MINOR (si aplica)
  - BLOCKER: security/secrets/authz/datos sensibles/integraciones críticas
  - MAJOR: piezas relevantes no críticas
  - MINOR: detalle/low impact

---

## Determinar el Evidence Pack destino (anti-duplicados)
1) Si `TARGET_EP` está definido:
   - si es `EP-###`: localizar el primer EP cuyo nombre empiece por `EP-###` y actualizarlo
   - si es una ruta a archivo: actualizar ese archivo
   - si no existe: fail-fast (no inventar ruta)
2) Si no hay `TARGET_EP`:
   - generar slug del tema en kebab-case (p.ej. `Auth & Roles` -> `auth-roles`)
   - buscar EPs existentes que contengan el slug:
     - si hay 1 → actualizar ese EP
     - si hay varios → elegir el de número más alto y registrar “posible duplicidad” en el EP
     - si no hay → crear nuevo EP con el siguiente número libre

Nuevo EP:
- `EP-###-<tema-kebab>.md` donde ### = mayor EP existente + 1

---

## Crear/actualizar el Evidence Pack (EP_MODE)

### Formato recomendado dentro del EP (machine-friendly)
Al inicio del EP incluir un bloque YAML:

```yaml
report_version: "<REPORT_VERSION>"
audit_mode: "<AUDIT_MODE>"
topic: "<TEMA>"
scope: "<ALCANCE|all>"
updated_at: "YYYY-MM-DD"
evidence_paths: <n>
conclusions:
  confirmed: <n>
  inferred: <n>
  unverifiable: <n>
  planned_change: <n>
```

### Si `EP_MODE=write`

* Usar como base `docs/spec/_inputs/evidence/_TEMPLATE-evidence-pack.md`.
* Rellenar (mínimo):

  * Contexto: por qué se investiga (y qué bloquea)
  * Search log: queries + rutas principales revisadas
  * Evidencias (lista priorizada, máx. `MAX_EVIDENCE_PATHS`)
  * Conclusiones:

    * CONFIRMED (cada una con `EVIDENCE: codebase/...`)
    * INFERRED (con motivo + `CONFIDENCE`)
    * UNVERIFIABLE (sin inventar; enlazar a OPENQ si existe)
    * PLANNED_CHANGE (si aplica, y por qué parece “to-be”)
  * Impacto probable del evolutivo (módulos afectados, riesgos, tests/migraciones si aplica)
  * Notas de seguridad/operación si el tema toca esos ámbitos

Guardrail tamaño:

* Si el EP supera `MAX_EP_LINES`, recorta:

  * primero detalles repetidos,
  * luego evidencias redundantes,
  * pero conserva conclusiones y paths clave.

### Si `EP_MODE=link-only`

* No escribir archivos.
* Proponer el contenido del EP en el chat:

  * nombre de archivo destino
  * search log
  * evidencias
  * conclusiones (con confidence)

---

## OPENQ cuando falte evidencia (OPENQ_MODE)

Crear/proponer OPENQ si:

* el punto es BLOCKER/MAJOR, o

* el riesgo de implementarlo mal es alto.

* `OPENQ_MODE=write`:

  * crear `OPENQ-###` en `docs/spec/95-open-questions.md` (siguiente número libre)
  * incluir:

    * pregunta concreta
    * impacto (B/M/A o BLOCKER/MAJOR/MINOR)
    * intentos (queries + rutas revisadas)
    * qué falta para cerrarla

* `OPENQ_MODE=link-only`:

  * no escribir; proponer en chat y reflejarlo en el EP (si se está redactando)

---

## Actualizar `codebase-map.md` cuando aplique (CODEBASE_MAP_MODE)

Solo si el tema afecta a visión global (stack, estructura, interfaces, datos, operación).

* `CODEBASE_MAP_MODE=write`:

  * insertar cambios mínimos en la sección adecuada (no reordenar)
  * añadir referencia al EP:

    * `EVIDENCE PACK: docs/spec/_inputs/evidence/EP-###-<tema-kebab>.md`
* `CODEBASE_MAP_MODE=link-only`:

  * proponer el bloque exacto a añadir

---

## Template mínimo para `codebase-map.md` (si no existe y se debe crear)

Si no existe y `CODEBASE_MAP_MODE=write`, crear:

# Codebase Map

## Overview

* Stack/runtime (si es verificable)
* Layout alto nivel

## Key directories

* `codebase/...`

## Interfaces & integration points

* APIs / jobs / events (si aplica)

## Data & persistence

* BBDD / migrations (si aplica)

## Operations

* logging/metrics/tracing/config/secrets (si aplica)

## Evidence packs

* Lista de EPs con enlaces

---

## Salida (siempre)

En el chat, reportar:

* EP creado/actualizado o propuesto (ruta)
* `codebase-map.md` actualizado o propuesto
* OPENQs creadas o propuestas (IDs)
* 3–6 conclusiones clave con `CONFIDENCE`
* Nota si hay posibles duplicados de EP detectados
