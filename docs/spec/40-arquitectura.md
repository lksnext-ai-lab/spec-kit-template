# Arquitectura

> Objetivo: describir la solución a nivel de componentes/servicios, sus responsabilidades, integraciones,
> y decisiones técnicas relevantes (ADRs). Mantener coherencia con FR/NFR y con el modelo de datos.

## 1. Drivers y restricciones

- Drivers (qué fuerza la arquitectura): TODO (NFR clave, integraciones, time-to-market, etc.)
- Restricciones no negociables: TODO
- Supuestos relevantes: TODO

## 2. Visión general

- Estilo arquitectónico: TODO (monolito modular / microservicios / event-driven / etc.)
- Resumen (10–15 líneas): TODO
- Diagrama (opcional): TODO (Mermaid/C4)

## 3. Componentes / servicios
> Cada componente debe indicar: responsabilidad, interfaces (API/EVT), datos que gestiona, dependencias y NFR relevantes.

| Componente | Tipo | Responsabilidad | Interfaces (API/EVT) | Datos (entidades) | Dependencias | NFR clave |
|---|---|---|---|---|---|---|
| SVC-001 | TODO | TODO | API-001, EVT-001 | EntidadX | TODO | NFR-001 |

### Detalle (si aplica)

#### SVC-001 — TODO

- Responsabilidad: TODO
- Entradas/Salidas: TODO
- Datos: TODO
- Seguridad: TODO
- Observabilidad: TODO
- Riesgos: RISK: TODO

## 4. Integraciones

| Sistema externo | Propósito | Método | Contrato | Autenticación | NFR | Notas |
|---|---|---|---|---|---|---|
| EXT-001 | TODO | Sync/Async | TODO | TODO | NFR-XXX | TODO |

## 5. Comunicación y consistencia

- Comunicación síncrona: TODO
- Comunicación asíncrona / eventos: TODO
- Consistencia de datos: TODO (fuerte/eventual; transacciones; idempotencia)
- Reintentos / DLQ (si aplica): TODO

## 6. Observabilidad (resumen)

- Logs: TODO
- Métricas: TODO
- Trazas: TODO
- Alertas mínimas: TODO

## 7. Decisiones (ADRs)

- DECISION: TODO (crear ADR)
- Enlaces: `docs/spec/adr/ADR-XXXX.md`

## 8. Riesgos y deuda técnica

- RISK: TODO
- TODO: deuda técnica aceptada

---

Referencia: [NFR](./11-requisitos-tecnicos-nfr.md) · [Backend](./60-backend.md) · [Infra](./90-infra.md)
