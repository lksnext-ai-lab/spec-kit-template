---
name: requirements-nfr
description: Usa este skill para definir o revisar requisitos no funcionales (NFR) en docs/spec/11-requisitos-tecnicos-nfr.md: métricas, verificación, categorías mínimas y baseline operativo.
---

# Requirements-nfr — Requisitos no funcionales (NFR)

## Objetivo

Definir NFR de forma **medible o verificable**, alineados con arquitectura,
seguridad e infraestructura.

## Dónde aplicar

- `docs/spec/11-requisitos-tecnicos-nfr.md` (principal)
- `docs/spec/40-arquitectura.md`, `docs/spec/80-seguridad.md`,
  `docs/spec/90-infra.md` (impactos)
- `docs/spec/01-plan.md` (si un NFR bloquea una iteración)

## Convenciones

- ID: `NFR-###` correlativo.
- Estado: `Draft` / `Validated` / `Deprecated`.
- Categoría: Seguridad / Disponibilidad / Rendimiento / Observabilidad /
  Privacidad&Legal / Mantenibilidad / Portabilidad / UX&Accesibilidad / Coste.

## Plantilla recomendada por NFR

### NFR-### — Título

- Categoría
- Descripción
- Objetivo/Métrica (si aplica)
- Alcance y exclusiones
- Verificación (prueba y evidencia)
- Implicaciones (arquitectura/operación/coste)
- Observaciones (`OPENQ/RISK/DECISION/TODO`)

## Cómo expresar “medible” vs “verificable”

### Medible (preferido)

- Define SLI y SLO (o umbral)

  - Ej: “p95 tiempo de respuesta < 2s en endpoint API-001 con 200 RPS”
  - Ej: “Disponibilidad mensual >= 99.9% (SLO)”

### Verificable (cuando medir no aplique)

- Define método y evidencia

  - Ej: “Revisión de configuración + informe de pentest”
  - Ej: “Checklist de hardening + captura de configuración”

## NFR mínimos sugeridos (baseline)

### Seguridad

- AuthN/AuthZ definidos; principio least privilege
- Cifrado en tránsito; cifrado en reposo si hay datos sensibles
- Gestión de secretos (rotación/almacenamiento seguro)
- Auditoría de acciones relevantes

### Disponibilidad / Continuidad

- Backups, retención, pruebas de restore
- RTO/RPO si aplica
- Ventanas de mantenimiento y estrategia de rollback

### Observabilidad

- Logging estructurado con correlación
- Métricas clave y alertas mínimas
- Trazas (si aplica) o al menos correlation-id end-to-end

### Rendimiento / Escalabilidad

- Supuestos de carga y límites (aunque sean aproximados)
- Paginación/filtrado para listados grandes
- Estrategia para picos (si aplica)

### Privacidad & Legal (si aplica)

- Retención/borrado
- Accesos a datos personales
- Anonimización en pre

## Antipatrones (evitar)

- “Será escalable” sin escenario de carga y límites.
- “Será seguro” sin controles concretos.
- “Alta disponibilidad” sin definir cómo (topología, DR, backups, etc.).

## Checklist rápido (revisión NFR)

- [ ] Cada NFR tiene métrica o verificación explícita.
- [ ] Categoría definida.
- [ ] Alcance/exclusiones claras.
- [ ] Implicaciones operativas mencionadas.
- [ ] Si implica decisiones, existe `DECISION:` (y luego ADR).
