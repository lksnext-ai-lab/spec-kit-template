# Documentación que se genera (spec)

Este documento describe **qué documentación de especificación** se produce en `docs/spec/`, qué objetivo tiene cada archivo y cómo encajan entre sí.

La idea clave: la “spec” no es un documento único, sino un **conjunto de artefactos** coherentes, trazables y revisables por iteraciones.

---

## Mapa de artefactos (visión general)

La especificación se organiza en:

- **Entrada y control**
  - Índice (`index.md`)
  - Contexto (`00-context.md`)
  - Plan (`01-plan.md`)
  - Trazabilidad (`02-trazabilidad.md`)

- **Contenido funcional y de producto**
  - Requisitos funcionales (FR)
  - Conceptualización (roles, permisos, flujos)
  - UI Spec (pantallas y comportamiento)

- **Contenido técnico**
  - Arquitectura
  - Modelo de datos
  - Backend
  - Frontend
  - Seguridad
  - Infra/Operación

- **Gestión de elaboración**
  - Open Questions (OPENQ)
  - TODOs
  - Review notes

- **Decisiones**
  - ADRs

---

## Tabla de documentos (qué es cada uno)

| Archivo | Propósito | Cuándo se actualiza | Salidas típicas |
|---|---|---|---|
| `docs/spec/index.md` | Punto de entrada e índice navegable de la spec | Al inicio y cuando cambie la estructura | Enlaces, convenciones, lectura recomendada |
| `docs/spec/00-context.md` | Problema, objetivos, alcance, restricciones y riesgos | Arranque y cuando cambie el marco | IN/OUT, roles, supuestos, integraciones |
| `docs/spec/01-plan.md` | Plan ejecutable de iteración (tareas + DoD) | Cada iteración | Lista breve de tareas verificables |
| `docs/spec/02-trazabilidad.md` | Vínculos mínimos FR↔UI↔API/EVT↔Datos↔ADR | En cada iteración (mínimo vivo) | Tabla actualizada, TODOs explícitos |
| `docs/spec/10-requisitos-funcionales.md` | Requisitos funcionales con CA verificables | Al definir MVP y al ampliar alcance | FR-### con criterios, prioridad, estado |
| `docs/spec/11-requisitos-tecnicos-nfr.md` | NFR medibles o con verificación definida | Cuando se definan SLO/controles/limitaciones | NFR-### con umbral o método de verificación |
| `docs/spec/20-conceptualizacion.md` | Roles, permisos, flujos y reglas de negocio | Tras FR y al concretar comportamiento | Matriz rol↔permiso, flujos por caso |
| `docs/spec/30-ui-spec.md` | Pantallas/flujos UI, estados y comportamiento | Tras conceptualización y al concretar UX | UI-###, estados (loading/empty/error) |
| `docs/spec/40-arquitectura.md` | Componentes/servicios, integraciones y despliegue lógico | Cuando se define solución técnica | Diagramas, límites, decisiones marcadas |
| `docs/spec/50-modelo-datos.md` | Entidades, relaciones y reglas de datos (alto nivel) | Cuando FR/UI/backend maduran | Entidades, cardinalidades, ownership |
| `docs/spec/60-backend.md` | Contratos API/eventos, sync/async, validaciones, errores | Cuando se define implementación backend | API-###, EVT-###, authz, idempotencia |
| `docs/spec/70-frontend.md` | Arquitectura frontend, estado, navegación y consumo de API | Cuando se define implementación frontend | Componentes/estado, contratos, manejo errores |
| `docs/spec/80-seguridad.md` | Baseline de seguridad y controles operativos | Al definir arquitectura e infra | authn/authz, secretos, auditoría, amenazas |
| `docs/spec/90-infra.md` | Entornos, CI/CD, observabilidad, backups/DR | Al definir operación real | pipelines, monitoring, logs, DR plan |
| `docs/spec/95-open-questions.md` | Preguntas abiertas con impacto | Cuando falta info o hay dependencia | OPENQ-### con impacto y plan de resolución |
| `docs/spec/96-todos.md` | Trabajo pendiente (backlog de spec) | Cuando aparece trabajo fuera de iteración | TODO-### priorizables |
| `docs/spec/97-review-notes.md` | Hallazgos y feedback accionable | En cada revisión | bloqueantes/importantes + cambios sugeridos |
| `docs/spec/adr/*` | Decisiones relevantes (ADR) | Cuando hay `DECISION:` | ADR con alternativas y consecuencias |

---

## Orden recomendado de construcción (heurística)

Aunque se itera, suele funcionar bien este orden:

1) `00-context.md` + `index.md`
2) `10-requisitos-funcionales.md` (MVP primero)
3) `20-conceptualizacion.md` (roles, permisos, flujos)
4) `30-ui-spec.md` (pantallas y estados)
5) `11-requisitos-tecnicos-nfr.md` (mínimos operativos + seguridad + rendimiento)
6) `40-arquitectura.md` + ADRs principales
7) `50-modelo-datos.md`
8) `60-backend.md` y `70-frontend.md`
9) `80-seguridad.md` y `90-infra.md`
10) Trazabilidad `02-...` “mínimo vivo” durante todo el proceso

---

## Cómo se asegura consistencia y calidad

El sistema combina:
- **convenciones** (IDs, marcadores, trazabilidad, ADR),
- **plan por iteración** con DoD verificable,
- **review notes** como mecanismo de control de calidad,
- y **skills** para normalizar la redacción de secciones clave.

---

## Señales de alarma típicas (cuando hay que corregir)
- FR sin criterios de aceptación verificables.
- NFR redactados como adjetivos (sin umbral o verificación).
- UI sin estados mínimos (loading/empty/error/sin permisos).
- Backend sin catálogo de errores o sin authz definido.
- Seguridad/Infra sin operación real (secretos, auditoría, backups/DR, observabilidad).
- Mucho texto “bonito” pero poca trazabilidad.
- Decisiones relevantes sin ADR.

Siguiente lectura recomendada: **`50-sistema-ia.md`**.
