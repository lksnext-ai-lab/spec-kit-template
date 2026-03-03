---
name: spec-kit-infra
description: "Define o revisa infraestructura y operación en docs/spec/90-infra.md: entornos, CI/CD, despliegue/rollback, observabilidad, backups/DR, accesos/secretos y coste. Abre ADR/OPENQ cuando falte info o haya trade-offs."
license: Proprietary
---

# Skill: Infra (spec-kit)

## Objetivo
Dejar `docs/spec/90-infra.md` **operable y verificable** para MVP, sin suposiciones:
- Entornos (DEV/PRE/PROD o los que existan)
- CI/CD y estrategia de release
- Despliegue + verificación post-deploy + rollback
- Observabilidad mínima (logs/métricas/alertas)
- Backups/DR + restore (y pruebas)
- Accesos/secretos/hardening
- Coste (drivers + controles básicos)

## Cuándo usar
- Cuando la spec ya define qué construir y falta “cómo operarlo”.
- Antes de empezar implementación/release para evitar sorpresas (rollback, backups, alertas, accesos).
- En cambios que afecten despliegue, datos, seguridad operativa u observabilidad.

## Archivos que se pueden modificar
- **Primario:** `docs/spec/90-infra.md`
- **Si aplica:**
  - `docs/spec/adr/ADR-*.md` (decisiones infra/ops con trade-offs)
  - `docs/spec/95-open-questions.md` (gaps críticos)
  - `docs/spec/96-todos.md` (pendientes no bloqueantes)

> No tocar otros ficheros de `docs/spec/**` salvo petición explícita del usuario.

## Fuentes típicas (leer antes)
- `docs/spec/11-requisitos-tecnicos-nfr.md`
- `docs/spec/40-arquitectura.md`
- `docs/spec/80-seguridad.md`
- `docs/spec/60-backend.md` / `docs/spec/70-frontend.md`
- Evidence Packs `docs/spec/_inputs/evidence/`

## Reglas duras
1) **No inventar**
- No fijar RTO/RPO, retención, SLAs, herramientas concretas, cloud/on-prem, tamaños o volúmenes si no están en la spec/evidencia.
- Si falta un dato crítico → `OPENQ:` y enlazar a `docs/spec/95-open-questions.md`.

2) **Vendor-neutral por defecto**
- Describir patrones (“blue/green”, “rolling”, “secrets manager”) sin imponer proveedor/stack.
- Si el proveedor/stack existe en la spec, entonces sí: referenciarlo.

3) **No secretos**
- Nunca incluir valores reales (keys, tokens, passwords, endpoints privados). Solo “existe X” + dónde se configura.

4) **Trade-offs relevantes → ADR**
Crear ADR cuando se elige entre opciones con impacto:
- estrategia de despliegue (rolling vs blue/green vs gates manuales),
- estrategia de secretos,
- retención de logs/costes,
- DR/restore,
- política de accesos (break-glass, MFA, segregación).

5) **MVP vs Fase 2**
- Lo mínimo operable va en MVP.
- Mejoras deseables pero no bloqueantes: “Fase 2” o `TODO` (sin contaminar MVP).

## Output contract para 90-infra.md (mínimos)
El documento debe incluir, como mínimo:
1) Entornos y diferencias reales
2) Release/CI/CD (stages + checks mínimos)
3) Despliegue: estrategia + verificación post-deploy + rollback
4) Migraciones: cómo/cuándo y condiciones de “safe deploy”
5) Observabilidad mínima
6) Backups/restore/DR
7) Accesos/secretos/hardening
8) Coste (drivers + 2–5 controles básicos)
9) Sección final: **“Fuentes y evidencias”** (lista corta de ficheros `docs/spec/**` consultados)

## Workflow (determinista)

### 1) Entornos (obligatorio)
- Si la spec define entornos, respetarlos.
- Si no, asumir DEV/PRE/PROD como base y marcar OPENQ si PRE no existe.

Tabla recomendada:
| Entorno | Propósito | Datos | Accesos | Objetivo de paridad | Desviaciones |
| --- | --- | --- | --- | --- | --- |

### 2) CI/CD + release (obligatorio)
Definir:
- triggers (PR, merge, tag, manual),
- stages y checks mínimos,
- artefactos,
- gates para PROD.

Tabla recomendada:
| Stage | Trigger | Checks mínimos | Artefactos | Output |
| --- | --- | --- | --- | --- |

### 3) Despliegue, verificación y rollback (obligatorio)
Definir:
- estrategia (rolling/blue-green/canary/manual gates) **sin imponer stack**,
- verificación post-deploy (smoke: qué validar y cómo),
- rollback (pasos + condiciones),
- “safe deploy” (qué lo puede bloquear).

### 4) Observabilidad mínima (obligatorio)
- logs estructurados + retención (solo si existe; si no: OPENQ)
- métricas mínimas: latencia, errores, throughput; colas/jobs si aplica
- alertas base: error rate, latencia, “stuck queue/job”
- dashboards esenciales

Tabla recomendada:
| Señal | Qué mide | Umbral/alerta | Retención | Owner |
| --- | --- | --- | --- | --- |

### 5) Backups y DR (obligatorio)
- qué se backuppea (BBDD, ficheros, config),
- frecuencia + retención,
- restore (pasos verificables),
- prueba de restore (si no existe: TODO),
- RTO/RPO solo si hay evidencia; si no, OPENQ.

Tabla recomendada:
| Activo | Backup | Frecuencia | Retención | Restore (pasos) | RTO/RPO | Notas |
| --- | --- | --- | --- | --- | --- | --- |

### 6) Seguridad operativa (obligatorio)
- secretos: almacenamiento/rotación (si no está definido: OPENQ)
- accesos: least privilege, MFA si aplica, break-glass si aplica
- hardening/parches
- segregación de red si aplica

Tabla recomendada:
| Área | Control | MVP/F2 | Evidencia/ADR/OPENQ |
| --- | --- | --- | --- |

### 7) Coste (recomendado)
- drivers principales
- controles: budgets/alerts, límites de retención, sampling, escalado
- si falta info: OPENQ

## Reglas de tamaño (evitar inflado)
- Cambios pequeños: mantener 90-infra.md compacto; usar 1 tabla por área como máximo.
- Cambios medianos/grandes: usar tablas completas y detallar rollback/restore.

## DoD (Definition of Done)
- [ ] Entornos definidos (y desviaciones de paridad declaradas)
- [ ] CI/CD definido (stages + checks + gates PROD)
- [ ] Despliegue + verificación post-deploy + rollback documentados
- [ ] Migraciones descritas con condiciones de “safe deploy”
- [ ] Observabilidad mínima definida (logs/métricas/alertas/dashboards)
- [ ] Backups + restore definidos; prueba de restore (o TODO); RTO/RPO solo con evidencia
- [ ] Seguridad operativa tratada sin exponer valores
- [ ] Trade-offs relevantes enlazados a ADR
- [ ] Gaps críticos en OPENQ
- [ ] “Fuentes y evidencias” añadida al final de 90-infra.md
