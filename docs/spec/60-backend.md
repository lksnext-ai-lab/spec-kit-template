# Backend (API, mensajería, integraciones)

> Objetivo: definir el contrato backend: APIs, eventos asíncronos, integraciones y reglas transversales
> (auth, errores, versionado). Mantener trazabilidad con FR y UI.

## 1. Principios

- Estilo: TODO (REST/GraphQL)
- Versionado: TODO (v1, headers, etc.)
- Formato de errores: TODO (estructura de error)
- Idempotencia (si aplica): TODO
- Paginación/filtrado/ordenación: TODO

## 2. Seguridad (resumen)

- Autenticación: TODO
- Autorización: TODO (roles/permisos)
- Rate limiting / protección: TODO

## 3. Catálogo de endpoints

| API | Método | Ruta | Descripción | Roles | FR | Request/Response | Notas |
| --- | --- | --- | --- | --- | --- | --- | --- |
| API-001 | GET | /todo | TODO | ROL-001 | FR-001 | TODO | TODO |

## 4. Detalle por endpoint (cuando haga falta)

### API-001 — GET /todo

- **Descripción**: TODO
- **Roles**: TODO
- **Entrada**: query/path/body (TODO)
- **Salida**: TODO
- **Códigos de respuesta**: TODO
- **Validaciones**: TODO
- **Errores**: TODO
- **Auditoría** (si aplica): TODO
- **FR relacionados**: FR-XXX
- **Notas**: TODO / OPENQ / RISK / DECISION

## 5. Asíncrono / mensajería (si aplica)

### Eventos

| EVT | Evento | Productor | Consumidor | Payload (alto nivel) | FR | Garantías | Notas |
| --- | --- | --- | --- | --- | --- | --- | --- |
| EVT-001 | todo.created | SVC-001 | SVC-002 | TODO | FR-001 | at-least-once | TODO |

### Reglas operativas

- Reintentos: TODO
- DLQ: TODO
- Ordenación:
