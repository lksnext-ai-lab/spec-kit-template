---
name: audit-spec-vs-codebase
description: Reality-check de `docs/spec/**` contra el estado actual del repo (codebase + rutas extra en solo lectura). Clasifica afirmaciones (CONFIRMED/INCORRECT/UNVERIFIABLE/PLANNED_CHANGE) con evidencia y confianza. Corrige spec SOLO con evidencia directa y anclaje diff-safe; el resto se registra como OPENQ/EP. Escribe review notes estables.
---

# audit-spec-vs-codebase (reality check)

## Objetivo
Revisar `docs/spec/**` y asegurar que las afirmaciones técnicas son coherentes con el estado del repo.  
Distinguir:
- lo que **ya existe** (as-is),
- lo que **no se puede verificar**,
- y lo que **la spec define como cambio futuro** (to-be).

Aplicar correcciones SOLO cuando la evidencia sea directa y con cambios mínimos.

---

## Parámetros opcionales
- `FOCUS` (opcional): backend | frontend | security | infra | data | ops | api | all
- `AUDIT_MODE` (default `as-is`):
  - `as-is`: valida la spec contra el estado actual; diferencias suelen ser INCORRECT/UNVERIFIABLE
  - `evolutive`: asume que la spec puede describir cambios futuros; diferencias pueden ser PLANNED_CHANGE
- `MAX_CLAIMS` (default `25`)
- `OPENQ_MODE` (default `write`): `write` | `link-only`
- `EP_MODE` (default `write`): `write` | `link-only`
- `CODEBASE_MAP_MODE` (default `write`): `write` | `link-only`
- `PATCH_MODE` (default `minimal`): `none` | `minimal`
- `EXTRA_READ_PATHS` (default empty): lista de rutas adicionales (solo lectura) a considerar como “realidad” (p.ej. `infra/**`, `docker/**`, `compose/**`, `.github/**`)
- `REPORT_VERSION` (default `1.1`)

---

## Alcance (hard)
- Leer `docs/spec/**` (excluye `docs/spec/history/**`).
- Leer `codebase/**` (solo lectura).
- Leer `EXTRA_READ_PATHS` (solo lectura) si se proporcionan.
- Editar SOLO si los modos lo permiten:
  - `docs/spec/**` (solo cambios mínimos si `PATCH_MODE=minimal`)
  - `docs/spec/_inputs/codebase-map.md` (si `CODEBASE_MAP_MODE=write`)
  - `docs/spec/_inputs/evidence/EP-###-*.md` (si `EP_MODE=write`)
  - `docs/spec/95-open-questions.md` (si `OPENQ_MODE=write`)
  - `docs/spec/97-review-notes.md` (siempre)
- PROHIBIDO escribir en `codebase/**` o en rutas extra.

---

## Reglas duras (anti-ruido)
- No reescrituras masivas: cambios diff-friendly.
- No inventar: si la evidencia no es directa → NO corregir; registrar como UNVERIFIABLE/OPENQ/EP.
- Priorizar por severidad: seguridad/datos/integraciones/operación/arquitectura base primero.
- Respetar `MAX_CLAIMS`; listar pendientes si se excede.
- Si `AUDIT_MODE=evolutive`, no convertir automáticamente diferencias en INCORRECT si pueden ser “to-be”.

---

## Qué es una “afirmación técnica” (claim)
Cualquier afirmación verificable (o que debería serlo) en el repo:
- stack/frameworks/runtime
- estructura módulos/capas
- endpoints/API/eventos/jobs
- persistencia/migraciones/modelos
- authn/authz/roles
- configuración/env/secrets
- operación (logging/metrics/tracing, CI/CD, backups)
- integración con servicios externos

---

## Clasificación de claims (estable)
- `CONFIRMED`: evidencia directa en repo.
- `INCORRECT`: contradice evidencia directa y, en `AUDIT_MODE=evolutive`, NO parece un cambio futuro definido.
- `UNVERIFIABLE`: no hay evidencia suficiente (o es indirecta/ambigua).
- `PLANNED_CHANGE`: (solo en `AUDIT_MODE=evolutive`) la spec describe algo que aún no está, y la diferencia es coherente como “to-be”.

## Confianza (simple)
- `HIGH`: evidencia directa (config/código) y unívoca.
- `MED`: evidencia fuerte pero indirecta (nombres, wiring parcial).
- `LOW`: indicios; no se debe corregir spec en base a esto.

---

## Método (obligatorio)

### Paso 1 — Inventario de claims (hasta MAX_CLAIMS)
Extrae claims desde `docs/spec/**` (según FOCUS). Para cada claim:
- ID `CLM-01..`
- texto resumido de la afirmación (1 línea)
- ubicación `docs/spec/...#sección`
- severidad estimada (BLOCKER/MAJOR/MINOR)
- “naturaleza” (si se puede inferir): `as-is` / `to-be` / `unknown`

### Paso 2 — Verificación contra repo
Buscar evidencia en:
- `codebase/**`
- y `EXTRA_READ_PATHS` si existen

Registrar:
- rutas concretas
- fragmentos/identificadores (sin copiar grandes bloques)
- clasificación + confianza

### Paso 3 — Acciones (según modos)

#### Correcciones de spec (solo si PATCH_MODE=minimal)
Solo si:
- estado = `INCORRECT` con `CONFIDENCE=HIGH`, o
- estado = `CONFIRMED` pero la spec afirma algo distinto y hay evidencia directa.

**Guardrail diff-safe:**
- editar solo la frase/sección mínima,
- no reescribir párrafos,
- añadir ancla `EVIDENCE: <ruta(s)>` inmediatamente junto al ajuste.

Si `AUDIT_MODE=evolutive` y el claim es razonable como futuro:
- preferir `PLANNED_CHANGE` + nota en review, no “corregir”.

#### UNVERIFIABLE
- Crear OPENQ y/o EP:
  - OPENQ si la falta de evidencia bloquea decisiones o puede generar implementación errónea.
  - EP si requiere investigación estructurada (mapear módulos, servicios, permisos, etc.)

#### PLANNED_CHANGE
- No corregir spec.
- Registrar como:
  - “gap intencional” entre as-is y to-be,
  - y sugerir tarea de implementación (derivación a `spc-imp-*`) si procede.

### Paso 4 — codebase-map (si aplica)
Si detectas desalineación o falta de mapa:
- actualizar/proponer `docs/spec/_inputs/codebase-map.md` con rutas + referencias a EPs.

---

## Severidad (estable)
- BLOCKER: seguridad, secretos, authz, exposición de datos, integraciones críticas, operación base, decisiones arquitectónicas base.
- MAJOR: NFR verificabilidad, migración/compatibilidad importante, piezas relevantes no críticas.
- MINOR: detalles, redacción, enlaces.

Regla seguridad:
- Claim de seguridad `UNVERIFIABLE` → BLOCKER por defecto.

---

## Reporte — `docs/spec/97-review-notes.md` (siempre)
Añadir sección:

## Reality check vs repo (audit-spec-vs-codebase)

```yaml
report_version: "<REPORT_VERSION>"
audit_mode: "<AUDIT_MODE>"
focus: "<FOCUS|all>"
max_claims: <MAX_CLAIMS>
patch_mode: "<PATCH_MODE>"
openq_mode: "<OPENQ_MODE>"
ep_mode: "<EP_MODE>"
codebase_map_mode: "<CODEBASE_MAP_MODE>"
extra_read_paths: ["..."]
```

Tabla:

| Claim  | Severidad           | Estado                                          | Confianza    | En spec           | Evidencia repo | Acción                           |
| ------ | ------------------- | ----------------------------------------------- | ------------ | ----------------- | -------------- | -------------------------------- |
| CLM-01 | BLOCKER/MAJOR/MINOR | CONFIRMED/INCORRECT/UNVERIFIABLE/PLANNED_CHANGE | HIGH/MED/LOW | docs/spec/...#... | codebase/...   | patch / OPENQ / EP / planned-gap |

Además:

* Correcciones aplicadas (si PATCH_MODE=minimal)
* OPENQs creadas/propuestas
* EPs creados/propuestos
* Cambios en codebase-map (si aplica)
* Pendientes por auditar (si excede MAX_CLAIMS)

---

## Resultado esperado

* Spec alineada con evidencia directa (cuando existe).
* Diferencias “to-be” separadas como `PLANNED_CHANGE` (en evolutivos).
* Lo no verificable queda explícito como OPENQ/EP.
* Review notes accionables y estables.
