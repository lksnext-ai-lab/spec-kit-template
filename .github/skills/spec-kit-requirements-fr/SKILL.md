---
name: spec-kit-requirements-fr
description: "Define/refina requisitos funcionales (FR) en docs/spec/10-requisitos-funcionales.md: alcance IN/OUT, roles, flujos, criterios de aceptación verificables y trazabilidad mínima. Abre OPENQ/ADR cuando falte info o haya trade-offs."
license: Proprietary
---

# Skill: Requirements-FR (spec-kit)

## Objetivo
Mantener requisitos funcionales claros, verificables y sin ambigüedad, listos para derivar a UI/API/datos sin mezclar capas.

## Archivos que se pueden modificar
- Primario: `docs/spec/10-requisitos-funcionales.md`
- Si aplica:
  - `docs/spec/02-trazabilidad.md`
  - `docs/spec/95-open-questions.md`
  - `docs/spec/adr/ADR-*.md`
  - `docs/spec/96-todos.md`

## Reglas duras (anti-deriva)
1) **No inventar**
- Si falta información que cambia el comportamiento → `OPENQ` (no rellenar).

2) **FR ≠ Diseño (anti-solutioning)**
Un FR NO debe incluir:
- endpoints concretos, nombres de rutas, payloads,
- estructura de BBDD/tablas,
- componentes UI específicos, layouts o librerías,
- elecciones tecnológicas (“usar X”).
Eso va en UI/backend/datos/arquitectura.

3) **FR ≠ NFR**
- Rendimiento, disponibilidad, retención, cifrado, logging, auditoría técnica, etc. se referencian como:
  - “Debe cumplir NFR-…” (o enlace a `docs/spec/11-requisitos-tecnicos-nfr.md`)
- No introducir umbrales/cifras si no existen en la spec.

4) **Granularidad**
- Un FR = 1 capacidad principal que un actor puede ejecutar end-to-end.
- Si para validar necesitas 2 historias distintas o 2 actores principales → dividir.
- Si es una “variante” de un FR existente (mismo objetivo), mantener como variante, no como FR nuevo.

5) **Criterios de aceptación verificables**
- Deben ser testeables (Given/When/Then o checklist verificable).
- Evitar adjetivos sin condición (“intuitivo”, “rápido”, “fácil”).
- Si hay permisos/roles: incluir aceptación de “acceso denegado” cuando aplique.

## Convenciones
- IDs: `FR-###` correlativo, no reutilizar.
- Prioridad: `MVP` | `Should` | `Could`
- Estado: `Draft` | `Validated` | `Deprecated`
- Deprecación: mantener el FR con razón y referencia al que lo sustituye (si aplica).

## Plantilla obligatoria por FR

### FR-### — <Verbo + objeto>

**Descripción:** (1–3 líneas)  
**Actor principal:** (1)  
**Actores secundarios:** (opcional)  
**Alcance:** IN / OUT (si OUT no está claro → OPENQ)  

**Precondiciones:** (si aplica)  

**Flujo principal:**
1. ...
2. ...
3. ...

**Variantes / errores:**
- V1: ...
- E1: ... (si aplica al negocio o a permisos/datos)

**Criterios de aceptación (CA) — verificables:**
- CA1 ...
- CA2 ...
- (Si aplica) CA-AccesoDenegado: ...

**Dependencias:** (otros FR / sistemas externos / datos “conceptuales”)  
**Prioridad:** MVP | Should | Could  
**Estado:** Draft | Validated | Deprecated  

**Trazabilidad mínima:**
- UI: `TBD` | link a `docs/spec/30-ui-spec.md` (si existe)
- Backend/API/Eventos: `TBD` | link a `docs/spec/60-backend.md` (si existe)
- Datos: `TBD` | link a `docs/spec/50-modelo-datos.md` (si existe)
- ADR: link a `docs/spec/adr/ADR-....md` (si aplica)

**Notas:** (solo si aplica)
- `OPENQ:` ...
- `DECISION:` (si hay alternativas funcionales con trade-offs)
- `TODO:` (si es un pendiente no bloqueante)

## Reglas prácticas para OPENQ / ADR / TODO
- **OPENQ**: falta un dato que cambia el comportamiento o el alcance (bloquea definición).
- **ADR**: hay alternativas con trade-off relevante (producto/operación/seguridad) y hay que decidir.
- **TODO**: mejora o detalle que no cambia el comportamiento base del FR.

## Priorización
- MVP: imprescindible para flujo E2E base.
- Should: valioso pero no bloquea E2E base.
- Could: diferible.

Si hay conflicto:
- abrir OPENQ proponiendo 2 opciones de MVP (mínimo vs completo) con criterios de elección.

## Duplicados y solapes
Antes de crear FR nuevo:
- buscar por actor + verbo + objeto.
- si solapa: fusionar o convertir en variante/errores.

## DoD
Un FR está “listo” si:
- [ ] Título accionable (verbo + objeto)
- [ ] Actor principal definido
- [ ] Alcance IN/OUT explícito (o OPENQ si falta OUT)
- [ ] Flujo principal completo
- [ ] Variantes/errores cuando aplique (al menos permisos/error relevante si procede)
- [ ] CA verificables
- [ ] Prioridad + estado
- [ ] Trazabilidad mínima (con `TBD` si falta detalle)
- [ ] OPENQ/ADR creadas si falta info o hay trade-offs
