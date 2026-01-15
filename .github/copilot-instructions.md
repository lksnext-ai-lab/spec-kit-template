# Instrucciones globales del repo (spec-kit)

## Propósito
Este repositorio contiene una **especificación técnica en Markdown**. El objetivo es producir documentación coherente y ejecutable siguiendo el ciclo:
**Plan → Redacción → Revisión → Iteración**, versionado con Git.

## Principios
- **No inventar**: nunca completes con suposiciones no explícitas. Si falta información, crea una `OPENQ` y continúa.
- **Consistencia**: si cambias un concepto (nombre de entidad, flujo, rol…), revisa impactos en documentos relacionados.
- **Trazabilidad mínima**: mantener vínculos FR ↔ UI ↔ API/EVT ↔ Datos ↔ ADR.
- **Decisiones visibles**: cualquier decisión relevante (arquitectura/seguridad/integración/operación) debe acabar en un ADR.

## Artefactos y responsabilidades
- `docs/00-context.md`: marco del problema, objetivos, alcance y restricciones.
- `docs/01-plan.md`: plan ejecutable de la iteración actual (tareas atómicas + DoD). **Manda el plan**.
- `docs/02-trazabilidad.md`: tabla mínima de trazabilidad (no es un Jira).
- `docs/10-requisitos-funcionales.md`: FR con criterios de aceptación verificables.
- `docs/11-requisitos-tecnicos-nfr.md`: NFR medibles o con verificación definida.
- `docs/95-open-questions.md`: preguntas abiertas (OPENQ) que condicionan la spec.
- `docs/96-todos.md`: backlog de trabajo pendiente de la especificación.
- `docs/97-review-notes.md`: revisión crítica y sugerencias accionables.
- `docs/adr/`: decisiones (ADR) con contexto, alternativas y consecuencias.

## Convenciones de IDs
- Requisitos funcionales: `FR-###` (correlativo, no reutilizable)
- Requisitos NFR: `NFR-###`
- Pantallas/flujos UI: `UI-###`
- Endpoints: `API-###`
- Eventos asíncronos: `EVT-###` (si aplica)
- Roles (opcional): `ROL-###`
- Preguntas: `OPENQ-###`
- TODOs: `TODO-###`
- ADRs: `ADR-####`

## Marcadores permitidos durante elaboración
- `TODO:` trabajo pendiente (idealmente reflejado también en `docs/96-todos.md`)
- `OPENQ:` duda/pregunta (registrar también en `docs/95-open-questions.md`)
- `RISK:` riesgo detectado
- `DECISION:` decisión pendiente (normalmente → ADR)

## Reglas de escritura
- Idioma principal: **español**.
- Tono: profesional, orientado a ejecución.
- Preferir estructura clara, listas y tablas.
- Evitar vaguedades (“rápido”, “seguro”, “escalable”) sin umbrales o método de verificación.

## Reglas de calidad por documento
- FR: siempre con **criterios de aceptación verificables** + prioridad + estado.
- NFR: siempre con **métrica objetivo** (SLO/SLI/umbral) o **verificación explícita**.
- UI: definir estados (cargando, vacío, error, sin permisos) y reglas por rol.
- Backend: definir validaciones, errores, authz y (si aplica) asincronía/reintentos/idempotencia.
- Seguridad/Infra: incluir operación real (secretos, accesos, auditoría, backups/DR, observabilidad).

## Proceso de trabajo (obligatorio)
1) **Planificar**: actualizar `docs/01-plan.md` con tareas atómicas y DoD.
2) **Redactar**: ejecutar el plan editando documentos en `docs/`.
3) **Revisar**: actualizar `docs/97-review-notes.md` con observaciones accionables.
4) **Iterar**: convertir feedback en cambios, TODOs u OPENQs y repetir.

## Gestión de dudas, trabajo pendiente y decisiones
- Si falta información:
  - crea `OPENQ:` en el lugar donde aparezca,
  - registra `OPENQ-###` en `docs/95-open-questions.md` (con impacto y qué bloquea).
- Si surge trabajo pendiente:
  - crea `TODO-###` en `docs/96-todos.md`.
- Si surge una decisión:
  - marca `DECISION:` en el documento relevante,
  - y registra ADR en `docs/adr/` (por el revisor o cuando corresponda).
  - enlaza la ADR desde el punto donde se menciona la decisión.

## Enlaces
- En documentos dentro de `docs/` usa enlaces relativos (por ejemplo `./adr/ADR-0001-...md`).
- En agentes/prompts (en `.github/`) usa rutas explícitas tipo `docs/...` para evitar rutas relativas incorrectas.
