# Conceptualización (roles, permisos, flujos)

> Objetivo: describir cómo funciona el sistema desde la perspectiva operativa:
> **quién** hace **qué**, con **qué permisos**, siguiendo **qué flujos** y bajo **qué reglas**.

## 1. Visión operativa (resumen)

TODO: 5–10 líneas sobre cómo se usará el sistema en el día a día.

## 2. Roles y responsabilidades

| Rol | Descripción | Objetivos | FR principales |
|---|---|---|---|
| ROL-001 | TODO | TODO | FR-001 |

> Nota: usa IDs `ROL-###` si quieres mantener trazabilidad.

## 3. Permisos (alto nivel)

### 3.1 Lista de permisos (catálogo)

| Permiso | Descripción |
|---|---|
| PERM-001 | TODO |

### 3.2 Matriz rol ↔ permisos

| Rol \ Permiso | PERM-001 | PERM-002 |
|---|---:|---:|
| ROL-001 | ✅ | ❌ |

## 4. Entidades de negocio (conceptuales)

TODO: lista de “cosas” importantes del dominio (aunque luego se concreten en el modelo de datos).

- Entidad: TODO (qué es, ciclo de vida)

## 5. Flujos de trabajo principales

> Recomendación: 3–7 flujos. Cada flujo enlaza FR relacionados.

### FLW-001 — TODO (Nombre del flujo)

- **Objetivo**: TODO
- **Actores**: TODO
- **Precondiciones**: TODO
- **Pasos**:
  1) TODO
  2) TODO
- **Variantes / excepciones**:
  - TODO
- **Reglas de negocio**:
  - TODO
- **FR relacionados**: FR-XXX, FR-YYY
- **Puntos de auditoría / trazabilidad** (si aplica):
  - TODO

## 6. Reglas de negocio (consolidado)

- RB-001: TODO

## 7. Preguntas abiertas / decisiones

- OPENQ: TODO
- DECISION: TODO (¿ADR?)

---

Referencia: [Requisitos funcionales](./10-requisitos-funcionales.md)
