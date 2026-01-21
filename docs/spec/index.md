# Especificación técnica — Índice

> Documento vivo. Se permiten marcadores durante elaboración:
> **TODO:** trabajo pendiente · **OPENQ:** pregunta abierta · **RISK:** riesgo · **DECISION:** decisión pendiente (normalmente → ADR)

## Lectura recomendada (orden)

1. [Contexto](./00-context.md)
2. [Plan](./01-plan.md)
3. [Requisitos funcionales](./10-requisitos-funcionales.md)
4. [Requisitos técnicos / NFR](./11-requisitos-tecnicos-nfr.md)
5. [Conceptualización (roles, permisos, flujos)](./20-conceptualizacion.md)
6. [UI Spec](./30-ui-spec.md)
7. [Arquitectura](./40-arquitectura.md)
8. [Modelo de datos](./50-modelo-datos.md)
9. [Backend](./60-backend.md)
10. [Frontend](./70-frontend.md)
11. [Seguridad](./80-seguridad.md)
12. [Infra (dev/pre/prod)](./90-infra.md)

## Puntos de control

- [Preguntas abiertas (OPENQ)](./95-open-questions.md)
- [TODOs (backlog)](./96-todos.md)
- [Review notes](./97-review-notes.md)
- [ADRs (decisiones)](./adr/)

## Convenciones clave

| Elemento | Convención | Dónde vive |
|---|---|---|
| Requisitos funcionales | `FR-###` + criterios de aceptación verificables | `10-requisitos-funcionales.md` |
| Requisitos no funcionales | `NFR-###` + objetivo/métrica cuando aplique | `11-requisitos-tecnicos-nfr.md` |
| Pantallas / flujos UI | `UI-###` | `30-ui-spec.md` |
| Endpoints / eventos | `API-###` (y/o `EVT-###` si aplica) | `60-backend.md` |
| Decisiones | `ADR-####` | `docs/spec/adr/` |
| Trazabilidad | FR ↔ UI ↔ API ↔ Datos ↔ ADR | `02-trazabilidad.md` |

## Cómo trabajar (método)

1) Completa `00-context.md` con el mínimo contexto real.  
2) El **Planner** actualiza `01-plan.md` con tareas atómicas y DoD.  
3) El **Writer** ejecuta el plan editando los documentos.  
4) El **Reviewer** deja observaciones en `97-review-notes.md` y/o marca `TODO/OPENQ/RISK/DECISION`.  
5) Itera hasta cumplir el DoD.

---

Siguiente: [Contexto →](./00-context.md)
