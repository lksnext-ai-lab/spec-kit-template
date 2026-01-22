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

- **Gestión de elaboración (estado “vivo”)**
  - Open Questions (OPENQ)
  - TODOs
  - Review notes

- **Histórico (snapshots por iteración)**
  - Snapshots de plan/OPENQ/TODO/review por iteración cerrada

- **Decisiones**
  - ADRs

---

## Estado vivo vs histórico (por qué existe `docs/spec/history/`)

Para que los agentes no mezclen iteraciones ni generen archivos enormes, la spec se gestiona con dos “capas”:

### Estado vivo (lo que usan prompts/agentes a diario)

- `docs/spec/01-plan.md` → **solo la iteración activa**
- `docs/spec/95-open-questions.md` → **solo OPENQ abiertas/relevantes**
- `docs/spec/96-todos.md` → **solo TODOs pendientes**
- `docs/spec/97-review-notes.md` → **review notes de la iteración activa** (o el último review vivo)

Regla práctica:

- Prompts y agentes deben **ignorar `docs/spec/history/**`** al planificar/redactar/revisar.

### Histórico (snapshots cerrados, para auditoría y navegación)

- `docs/spec/history/<Ixx>/` contiene una foto completa del cierre de una iteración, más un resumen.
- Solo el prompt **`/close-iteration`** crea o actualiza contenido en `docs/spec/history/**`.

---

## Tabla de documentos (qué es cada uno)

| Archivo | Propósito | Cuándo se actualiza | Salidas típicas |
| --- | --- | --- | --- |
| `docs/spec/index.md` | Punto de entrada e índice navegable de la spec | Al inicio, al cerrar iteraciones y cuando cambie la estructura | Enlaces, convenciones, lectura recomendada, enlaces al histórico |
| `docs/spec/00-context.md` | Problema, objetivos, alcance, restricciones y riesgos | Arranque y cuando cambie el marco | IN/OUT, roles, supuestos, integraciones |
| `docs/spec/01-plan.md` | Plan ejecutable de la iteración **activa** (tareas + DoD) | Cada iteración | Lista breve de tareas verificables |
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
| `docs/spec/95-open-questions.md` | Preguntas abiertas con impacto (estado vivo) | Cuando falta info o hay dependencia | OPENQ-### con impacto y plan de resolución |
| `docs/spec/96-todos.md` | Trabajo pendiente (backlog vivo de la spec) | Cuando aparece trabajo fuera de iteración | TODO-### priorizables |
| `docs/spec/97-review-notes.md` | Hallazgos y feedback accionable (estado vivo) | En cada revisión | bloqueantes/importantes + cambios sugeridos |
| `docs/spec/adr/*` | Decisiones relevantes (ADR) | Cuando hay `DECISION:` | ADR con alternativas y consecuencias |
| `docs/spec/history/<Ixx>/*` | Snapshots de una iteración cerrada + resumen | Al cerrar iteración (`/close-iteration`) | plan/OPENQ/TODO/review de cierre + `00-summary.md` |

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

Cierre recomendado:

- Cuando una iteración está completada y revisada, ejecutar `/close-iteration` para archivar snapshots y mantener el estado vivo pequeño.

---

## Cómo se asegura consistencia y calidad

El sistema combina:

- **convenciones** (IDs, marcadores, trazabilidad, ADR),
- **plan por iteración** con DoD verificable,
- **review notes** como mecanismo de control de calidad,
- **skills** para normalizar la redacción de secciones clave,
- y **cierre de iteración** con histórico para evitar mezclar I01/I02 y reducir ruido para los agentes.

---

## Señales de alarma típicas (cuando hay que corregir)

- FR sin criterios de aceptación verificables.
- NFR redactados como adjetivos (sin umbral o verificación).
- UI sin estados mínimos (loading/empty/error/sin permisos).
- Backend sin catálogo de errores o sin authz definido.
- Seguridad/Infra sin operación real (secretos, auditoría, backups/DR, observabilidad).
- Mucho texto “bonito” pero poca trazabilidad.
- Decisiones relevantes sin ADR.
- `01-plan.md` mezclando iteraciones o acumulando histórico (síntoma: cuesta “leer qué toca ahora”).

Siguiente lectura recomendada: **`50-sistema-ia.md`**.
