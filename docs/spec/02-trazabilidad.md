# Trazabilidad (FR ↔ UI ↔ API ↔ Datos ↔ ADR)

> Objetivo: mantener coherencia entre lo que se pide (FR), cómo se usa (UI), cómo se implementa (API/Async),
> qué persiste (Datos) y qué se decidió (ADR). Se rellena progresivamente.

## Reglas

- Un FR importante debería apuntar al menos a: UI (si aplica) y API/Async (si aplica).
- Si hay una decisión que afecte diseño/seguridad/operación → ADR.
- Evitar sobre-gestión: no es un Jira, es una “red de enlaces mínima”.

## Tabla principal

| FR | UI | API/Async | Datos (entidades) | ADR | Notas |
| --- | --- | --- | --- | --- | --- |
| FR-001 | UI-001 | API-001 | EntidadX, EntidadY | ADR-0001 | TODO |

## Catálogo (opcional, si crece el proyecto)

### UI (pantallas / flows)

| UI | Nombre | Roles | FR relacionados | Notas |
| --- | --- | --- | --- | --- |
| UI-001 | TODO | TODO | FR-001 | TODO |

### API/Async (endpoints / eventos)

| ID | Tipo | Método/Ruta o Evento | FR relacionados | Notas |
| --- | --- | --- | --- | --- |
| API-001 | Sync | GET /todo | FR-001 | TODO |
| EVT-001 | Async | event.todo.created | FR-001 | TODO |

### Datos (entidades)

| Entidad | Propósito | FR relacionados | Notas |
| --- | --- | --- | --- |
| EntidadX | TODO | FR-001 | TODO |

---

Anterior: [Plan ←](./01-plan.md) · Siguiente: [Requisitos funcionales →](./10-requisitos-funcionales.md)
