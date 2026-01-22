# Infraestructura (dev / pre / prod)

> Objetivo: definir entornos, despliegue, observabilidad, backups/DR y requisitos operativos.
> Debe cubrir lo mínimo para operar con seguridad y fiabilidad (NFR).

## 1. Entornos

| Entorno | Propósito | Datos | Accesos | Observaciones |
| --- | --- | --- | --- | --- |
| DEV | TODO | Sintéticos | TODO | TODO |
| PRE | TODO | Anonimizados (si aplica) | TODO | TODO |
| PROD | TODO | Reales | TODO | TODO |

## 2. Topología (alto nivel)

- Componentes desplegados: TODO
- Redes / segmentación: TODO
- DNS / certificados: TODO

## 3. Deploy y CI/CD

- Estrategia: TODO (blue/green, rolling, manual gates)
- Artefactos: TODO (contenedores, paquetes)
- Versionado y rollback: TODO
- Migraciones de datos: TODO (cómo/ventanas)

## 4. Observabilidad operativa

- Logs: TODO (centralización, retención)
- Métricas: TODO (SLI/SLO)
- Alertas: TODO (mínimos)
- Dashboards: TODO

## 5. Backups y continuidad (DR)

- Qué se backuppea: TODO
- Frecuencia: TODO
- Retención: TODO
- Restauración (RTO/RPO): TODO (si aplica)
- Pruebas de restore: TODO

## 6. Seguridad operativa

- Gestión de secretos: TODO
- Hardening: TODO
- Gestión de accesos: TODO (least privilege)
- Actualizaciones y parches: TODO

## 7. Coste (opcional)

- Estimación inicial: TODO
- Drivers de coste: TODO

## 8. Preguntas abiertas

- OPENQ: TODO
- DECISION: TODO (¿ADR?)

---

Referencia: [Arquitectura](./40-arquitectura.md) · [Seguridad](./80-seguridad.md) · [NFR](./11-requisitos-tecnicos-nfr.md)
