---
name: infra
description: Usa este skill para definir o revisar infraestructura y operación en docs/spec/90-infra.md: entornos, CI/CD, observabilidad, backups/DR, accesos, secretos y requisitos operativos.
---

# Infra — Infraestructura y operación (dev / pre / prod)

## Objetivo

Definir lo mínimo necesario para operar la solución con calidad:

- entornos,
- despliegue y CI/CD,
- observabilidad,
- backups/DR,
- accesos y secretos,
- y consideraciones de coste.

## Dónde aplicar

- `docs/spec/90-infra.md` (principal)
- `docs/spec/11-requisitos-tecnicos-nfr.md` (NFR de operación)
- `docs/spec/40-arquitectura.md` (topología)
- `docs/spec/80-seguridad.md` (seguridad operativa)

## Entornos (mínimo)

- DEV: datos sintéticos, accesos amplios controlados
- PRE: lo más parecido a PROD, datos anonimizados si aplica
- PROD: datos reales, accesos restringidos y auditados

Para cada entorno define:

- propósito
- tipo de datos
- accesos/roles
- diferencias con otros entornos

## CI/CD (mínimo)

- estrategia de despliegue (rolling/blue-green/manual gates)
- versionado y rollback
- migraciones de datos (cómo y cuándo)
- “Definition of Ready” para deploy a PROD (pruebas mínimas)

## Observabilidad operativa (mínimo)

- logs centralizados y estructurados (retención)
- métricas clave (latencia, errores, throughput, colas si aplica)
- alertas mínimas (error rate, disponibilidad, saturación)
- dashboards de operación

## Backups / DR (mínimo)

- qué se backuppea (BBDD, ficheros, config)
- frecuencia y retención
- restauración (procedimiento)
- RTO/RPO si aplica
- pruebas periódicas de restore (recomendado)

## Seguridad operativa

- gestión de secretos (almacenamiento, rotación)
- control de accesos (least privilege, MFA, break-glass si aplica)
- hardening y parches
- segregación de redes si aplica

## Coste (opcional, pero útil)

- drivers principales (tráfico, almacenamiento, observabilidad, licencias)
- límites y alertas de coste si aplica

## Checklist rápido (revisión infra)

- [ ] Entornos definidos (DEV/PRE/PROD) con diferencias claras.
- [ ] Estrategia CI/CD y rollback.
- [ ] Observabilidad mínima (logs/métricas/alertas).
- [ ] Backups + restore definidos (y RTO/RPO si aplica).
- [ ] Secretos/accesos/hardening tratados.
