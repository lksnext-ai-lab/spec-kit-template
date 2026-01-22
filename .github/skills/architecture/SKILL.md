---
name: architecture
description: Usa este skill para definir o revisar arquitectura en docs/spec/40-arquitectura.md: componentes/servicios, integraciones, comunicación sync/async, consistencia, observabilidad y decisiones (ADR).
---

# Architecture — Arquitectura de la solución

## Objetivo

Describir una arquitectura coherente con FR/NFR, cubriendo:

- componentes/servicios y responsabilidades,
- integraciones,
- comunicación (sync/async),
- consistencia,
- observabilidad,
- y decisiones en ADR.

## Dónde aplicar

- `docs/spec/40-arquitectura.md` (principal)
- Referencias: `docs/spec/11-requisitos-tecnicos-nfr.md`,
  `docs/spec/60-backend.md`, `docs/spec/90-infra.md`
- Decisiones: `docs/spec/adr/`

## Principios

- Empieza por drivers (NFR y restricciones).
- Diseña responsabilidades claras (evita “servicios que hacen de todo”).
- Si una decisión cambia la arquitectura: marca `DECISION:` → ADR.

## Plantilla de componente/servicio (mínimo)

Para cada componente (SVC-### o similar):

- Responsabilidad (1–3 líneas)
- Interfaces: API-### y/o EVT-###
- Datos que gestiona (entidades)
- Dependencias (otros servicios / sistemas externos)
- NFR clave (seguridad, disponibilidad, observabilidad, rendimiento)
- Riesgos y mitigaciones

## Integraciones

Para cada integración externa:

- Propósito
- Método (sync/async)
- Contrato (API, eventos, ficheros)
- Autenticación/autorización
- Limitaciones (rate limits, ventanas, SLAs)
- Riesgos

## Sync vs Async (cuándo usar)

- Sync: lectura/consulta, baja latencia, dependencia directa aceptable.
- Async: procesos largos, desacoplar, tolerar fallos, integración entre dominios.

Si dudas:

- crea `OPENQ` o `DECISION` y sugiere 2 alternativas.

## Consistencia e idempotencia

- Define si hay consistencia fuerte vs eventual.
- Si hay eventos:

  - al menos “at-least-once” y consumidores idempotentes
  - reintentos y DLQ (si aplica)

## Observabilidad (mínimo)

- Correlation-id end-to-end (frontend→backend→servicios)
- Logs estructurados
- Métricas (errores, latencia, throughput)
- Alertas mínimas

## ADR (decisiones arquitectónicas)

Crea/actualiza ADR cuando:

- cambia el estilo (monolito/microservicios)
- se elige mensajería/event-driven
- se decide la estrategia de auth, multi-tenant, cifrado, etc.
- se decide base de datos o particionado

Marca `DECISION:` donde se detecte (Reviewer genera ADR si falta).

## Checklist rápido (revisión arquitectura)

- [ ] Drivers/NFR explícitos.
- [ ] Componentes con responsabilidades claras.
- [ ] Integraciones bien descritas.
- [ ] Sync/async justificado.
- [ ] Consistencia/idempotencia tratadas si hay eventos.
- [ ] Observabilidad mínima definida.
- [ ] Decisiones relevantes enlazadas a ADR.
