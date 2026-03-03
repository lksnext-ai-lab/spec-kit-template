---
category: spec-kit
scope: imp
status: stable
---

# Skill: spc-imp-task-definition

## Objetivo
Definir una **tarea de desarrollo atómica (Txx)** lista para ejecución en **codebase/**, derivada de `docs/spec/**` (RFC/FR/NFR/ADR/plan), **sin inventar**. La salida debe permitir implementar con **alcance acotado**, **trazabilidad** y **DoD verificable**.

---

## Principios
- **SPEC manda**: la ficha Txx se basa en evidencias del SPEC.
- **CODEBASE valida**: los comandos y verificaciones reales viven en `codebase/docs/agentic/spc-imp-dod.md`.
- **No inventar**: lo no definido se convierte en `OPENQ` o en tarea de research.
- **1 tarea = 1 PR** (salvo infra/migración).

---

## Reglas duras (hard rules)
1) **No inventar**
   - Si falta una decisión, regla, umbral, contrato o valor por defecto: escribir `OPENQ:` y enlazar dónde debe resolverse (p. ej. `docs/spec/95-open-questions.md` o la sección concreta).
2) **Placeholders no son evidencia**
   - Cualquier `TODO`, `TBD`, `WIP`, `pendiente`, `por definir`, `???` es placeholder.
   - Un placeholder **no puede** sustentar requisitos ni comportamiento. Si afecta a la tarea → `OPENQ:` y, si bloquea, `Estado: blocked`.
3) **Evidencia mínima obligatoria**
   - Cada Txx debe enlazar al menos a:
     - 1 evidencia funcional (FR o sección concreta de spec)
     - y si aplica: 1 evidencia NFR/ADR/RFC.
4) **DoD verificable**
   - La tarea debe incluir comandos reproducibles o, como mínimo, referenciar:
     - `codebase/docs/agentic/spc-imp-dod.md`
   - Si el DoD del codebase no existe o está incompleto → registrar `OPENQ` y no marcar `ready`.
5) **Alcance acotado**
   - Si el alcance supera un PR razonable, dividir en subtareas.
6) **Compatibilidad/migración**
   - Si hay impacto en contratos, datos, configuración o despliegue: incluir sección “Compatibilidad/Migración” aunque sea breve.
7) **Trazabilidad explícita**
   - Incluir links a RFC/ADR/FR/NFR (o “N/A” si no aplica).

---

## Estados recomendados
- `todo`: pendiente de research/definición final
- `ready`: lista para research/implementación en codebase
- `blocked`: bloqueada por `OPENQ` o decisión necesaria

> Nota: el detalle de estados completos vive en el backlog canónico `docs/spec/spc-imp-backlog.md`.

---

## Plantilla de salida (Txx)
**Ruta recomendada:** `docs/spec/spc-imp-tasks/Txx.md`  
**Idioma:** español.

> No rellenar con suposiciones. Si no hay datos, usar `OPENQ:`.

---

# Txx — <Título corto de la tarea>

## Metadatos
- ID: Txx
- Estado: todo | ready | blocked
- Prioridad: P1 | P2 | P3
- Tipo: code-change | docs-only | infra | test-only
- Dependencias: (IDs Tyy / ADR / PR / tarea previa)
- Riesgo: low | medium | high
- Owner: (opcional)

## Contexto (con evidencia)
- (2–6 bullets) Por qué existe esta tarea.
- Links obligatorios a SPEC (RFC/FR/NFR/ADR relevantes).

## Objetivo
(1 párrafo) Qué debe conseguirse al terminar.

## Alcance
### IN
- (bullets concretos)

### OUT
- (bullets concretos; evita scope creep)

## Requisitos compilados
### Funcionales (FR)
- FR: <link a SPEC> — resumen (1 línea)

### No funcionales / Constraints (NFR / ADR / RFC)
- NFR/ADR/RFC: <link> — resumen (1 línea)

> Si no hay NFR/constraints aplicables, indicar `N/A`.

## Enfoque propuesto (mínimo viable)
- (3–10 bullets) Enfoque técnico sugerido.
- Si hay alternativas relevantes:
  - Opción A: ...
  - Opción B: ...
  - Estado: DECISION existente | OPENQ

## Cambios en codebase (alto nivel)
- Componentes/módulos: (lista)
- Archivos impactados (aprox): (lista o rutas candidatas)
- Configuración/variables: (si aplica)

> Si no está claro dónde tocar: “Necesita research” (no inventar rutas).

## Criterios de aceptación (verificables)
- [ ] ...
- [ ] ...
- [ ] ...

## Definition of Done (DoD) — verificable
Referencia base: `codebase/docs/agentic/spc-imp-dod.md`

- Tests:
  - [ ] Ejecutar: `<comando>` (o “ver DoD del repo” si el comando está allí)
- Lint/Format:
  - [ ] Ejecutar: `<comando>`
- Build/Typecheck:
  - [ ] Ejecutar: `<comando>`
- Docs (si aplica):
  - [ ] Actualizar: `<archivo>` y justificar

## NFR checks aplicables (si aplica)
Referencia: `codebase/docs/agentic/spc-imp-nfr-checks.md`

- OBS: OK/NA — checks: ...
- SEC: OK/NA — checks: ...
- REL: OK/NA — checks: ...
- PERF: OK/NA — checks: ...
- COMP/OPS: OK/NA — checks: ...
- QA: OK/NA — checks: ...

## Validación / Plan de pruebas
- Unit:
- Integration/E2E:
- Casos borde:

## Compatibilidad / Migración (si aplica)
- Impacto:
- Estrategia (flags/coexistencia/migración):
- Rollback:

## Riesgos y mitigaciones
- Riesgo: ... → Mitigación: ...

## OPENQ (si aplica)
- OPENQ: ... (link a `docs/spec/95-open-questions.md` o sección a crear)

## Trazabilidad (obligatorio)
- RFC: ...
- ADR: ...
- Spec/FR: ...
- Spec/NFR: ...

---

## Checklist de calidad (para marcar “ready”)

* [ ] Evidencia FR incluida (link real)
* [ ] NFR/ADR/RFC incluidos si aplican
* [ ] Alcance IN/OUT claro
* [ ] Criterios de aceptación verificables
* [ ] DoD reproducible (comandos o referencia clara al DoD del repo)
* [ ] No hay placeholders usados como hechos
* [ ] Si falta info crítica → `OPENQ` y `Estado: blocked` (no “ready”)
