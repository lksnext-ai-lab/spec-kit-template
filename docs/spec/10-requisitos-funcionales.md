# Requisitos funcionales (FR)

> Reglas:
>
> - No inventar requisitos: si falta info usa `OPENQ:` y registra también en `docs/spec/95-open-questions.md`.
> - Cada FR debe tener **criterios de aceptación verificables**.
> - Mantén trazabilidad mínima en `docs/spec/02-trazabilidad.md` (FR ↔ UI ↔ API/Async ↔ Datos ↔ ADR).

## Convenciones

- **ID**: `FR-###` (correlativo, sin reutilizar).
- **Prioridad**: `MVP` / `Should` / `Could`.
- **Estado**: `Draft` / `Validated` / `Deprecated`.
- **Criterios de aceptación (CA)**: bullets verificables (evitar “debe ser fácil”, “intuitivo”…).
- Si un FR depende de una decisión: marca `DECISION:` y crea/actualiza ADR.

---

## Tabla resumen (backlog)

| ID | Título | Prioridad | Estado | Actores/Roles | Dependencias | Notas |
| --- | --- | --- | --- | --- | --- | --- |
| FR-001 | TODO | MVP | Draft | TODO | TODO | TODO |

---

## Detalle de requisitos

### FR-001 — TODO: título breve y accionable

- **Descripción**: TODO (qué capacidad aporta al usuario)
- **Actores/Roles**: TODO
- **Precondiciones**: TODO (si aplica)
- **Flujo principal (happy path)**:
  1) TODO
  2) TODO
- **Flujos alternativos / errores**:
  - TODO
- **Criterios de aceptación**:
  - CA1: TODO (verificable)
  - CA2: TODO (verificable)
- **Prioridad**: MVP
- **Estado**: Draft
- **Trazabilidad**:
  - UI: UI-XXX (si aplica)
  - API/Async: API-XXX / EVT-XXX (si aplica)
  - Datos: EntidadX/EntidadY (si aplica)
  - ADR: ADR-XXXX (si aplica)
- **Observaciones**:
  - TODO / OPENQ / RISK / DECISION

---

## Checklist de calidad (para reviewer)

- [ ] Todos los FR tienen CA verificables.
- [ ] Los FR MVP están claramente marcados.
- [ ] No hay FR duplicados o contradictorios.
- [ ] Cada FR relevante tiene trazabilidad mínima.
