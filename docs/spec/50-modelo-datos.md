# Modelo de datos (conceptual)

> Objetivo: definir entidades principales, relaciones y reglas de integridad.
> No es un modelo físico, pero debe servir para alinear UI/API/Arquitectura.

## 1. Principios y alcance

- Alcance del modelo: TODO
- Principios (p.ej., auditable, soft-delete, multi-tenant): TODO
- Datos sensibles (si aplica): TODO (→ seguridad)

## 2. Entidades principales (catálogo)

| Entidad | Propósito | Campos clave (alto nivel) | Ciclo de vida | FR relacionados | Notas |
|---|---|---|---|---|---|
| ENT-001 | TODO | TODO | TODO | FR-001 | TODO |

## 3. Relaciones (alto nivel)

- ENT-001 1..N ENT-002 — TODO
- TODO

## 4. Reglas de integridad y negocio

- Regla 1: TODO
- Regla 2: TODO

## 5. Auditoría y trazabilidad

- ¿Qué cambios deben auditase?: TODO
- ¿Quién y cuándo?: TODO
- Retención: TODO (si aplica)

## 6. Consideraciones de rendimiento

- Índices esperables (conceptual): TODO
- Volumetrías (aprox.): TODO
- Archivado: TODO

## 7. Preguntas abiertas

- OPENQ: TODO
- DECISION: TODO (¿ADR?)

---

Referencia: [Arquitectura](./40-arquitectura.md) · [Backend](./60-backend.md)
