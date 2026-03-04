---
name: spec-kit-architecture
description: "Define o revisa la arquitectura en docs/spec/40-arquitectura.md: componentes y límites, contratos, sync/async, datos/ownership, seguridad y observabilidad. Crea ADR/OPENQ cuando falte información o haya trade-offs."
license: Proprietary
argument-hint: "[cambio/tema] [drivers FR/NFR] [restricciones] [pistas/evidence packs]"
user-invocable: false
---

# Skill: Architecture (spec-kit)

## Objetivo
Dejar `docs/spec/40-arquitectura.md` en un estado **ejecutable y coherente** con FR/NFR, minimizando suposiciones:
- componentes y responsabilidades (límites claros),
- contratos entre componentes e integraciones externas,
- criterios sync/async + consistencia/idempotencia cuando aplique,
- ownership de datos,
- seguridad y observabilidad mínima (MVP),
- decisiones y gaps (ADR/OPENQ).

## Archivos que se pueden modificar
- **Primario:** `docs/spec/40-arquitectura.md`
- **Si aplica (solo cuando haga falta):**
  - `docs/spec/adr/ADR-*.md` (decisiones)
  - `docs/spec/95-open-questions.md` (gaps críticos)
  - `docs/spec/96-todos.md` (acciones/pendientes no bloqueantes)

> No tocar otros ficheros de `docs/spec/**` salvo petición explícita del usuario.

## Inputs recomendados
- `docs/spec/10-requisitos-funcionales.md`
- `docs/spec/11-requisitos-tecnicos-nfr.md`
- `docs/spec/50-modelo-datos.md` (si hay datos)
- Evidence Packs relevantes: `docs/spec/_inputs/evidence/`
- ADRs existentes: `docs/spec/adr/`

## Reglas duras
1) **No inventar**
- Si algo condiciona la arquitectura y no está claro → `OPENQ` (no “rellenar”).

2) **Arquitectura = to-be, pero basada en drivers**
- En la arquitectura, cada bloque importante debe referenciar drivers (FR/NFR/ADR/EP).
- Si una decisión no está cerrada: marcarla como `DECISION PENDIENTE` y abrir ADR/OPENQ.

3) **Cada trade-off relevante → ADR**
Crear ADR cuando se elige entre opciones con impacto (p.ej. sync vs async, modelo de permisos, estrategia de idempotencia, etc.).

4) **Diff-friendly**
- Cambios acotados y estructurados; evitar reescrituras masivas.

## Workflow (determinista)

### 1) Drivers y supuestos (1 pantalla)
En `40-arquitectura.md`, abrir con:
- Drivers FR/NFR (5–12 bullets)
- Restricciones (técnicas/operativas/legales) (3–8 bullets)
- Supuestos explícitos (si no están en spec → OPENQ)

### 2) Snapshot de arquitectura (alto nivel)
- Lista de componentes (máx. 12 en MVP; si hay más, agrupar por “dominio/capacidad”).
- Diagrama ASCII breve (opcional, pero recomendado).
- Tabla de límites:
  - Componente | Responsabilidad | Interfaces | Datos que posee | Dependencias

### 3) Contratos e interacción (sync/async)
Para cada relación relevante:
- Tipo: HTTP/API | Evento | Job | Fichero | Otro
- Sync/Async y justificación (1–3 líneas)
- Errores y resiliencia:
  - timeouts, reintentos, backoff, DLQ si aplica
- Consistencia:
  - fuerte vs eventual (por flujo)
- Idempotencia (si aplica):
  - clave idempotencia / dedupe / “at-least-once”

> Si no puedes justificar sync/async con drivers → ADR o OPENQ.

### 4) Cross-cutting (mínimos verificables)
**Seguridad (MVP):**
- authn/authz a alto nivel (sin inventar detalles)
- manejo de secretos (sin valores)
- límites de permisos y auditoría si aplica

**Observabilidad (MVP):**
- correlation-id end-to-end
- logs estructurados (campos mínimos)
- métricas mínimas (latencia, errores, throughput; colas/jobs si aplica)
- alertas base (error-rate, latencia, “stuck queue” si aplica)

### 5) Decisiones y gaps
- `DECISION:` → link ADR
- `OPENQ:` → link a `95-open-questions.md`
- `TODO:` (no bloqueante) → `96-todos.md` si conviene

## Plantillas compactas

### Card de componente (SVC)
- **Nombre**
- **Responsabilidad** (1–3 líneas)
- **Interfaces** (IN/OUT)
- **Datos que posee** (ownership explícito)
- **Dependencias**
- **Sync/Async** (si aplica)
- **Seguridad** (alto nivel)
- **Observabilidad mínima**
- **Failure modes (Top 3)** + mitigación
- **Decisiones/OPENQ**

### Card de integración externa (INT)
- **Sistema / propósito**
- **Contrato** (API/evento/fichero) + versionado si aplica
- **Auth** (alto nivel)
- **Límites** (rate limits / ventanas / SLAs si existen)
- **Errores** (timeouts/reintentos/DLQ si aplica)
- **Riesgos** + mitigación
- **OPENQ**

## DoD (Definition of Done)
- [ ] Drivers FR/NFR explícitos al inicio
- [ ] Componentes con límites claros y ownership de datos
- [ ] Contratos e integraciones descritos (tipo + sync/async + errores)
- [ ] Consistencia/idempotencia tratadas si hay async/eventos/jobs
- [ ] Seguridad y observabilidad mínima definidas (MVP)
- [ ] Trade-offs relevantes enlazados a ADR
- [ ] Gaps críticos en OPENQ (no en suposiciones)
