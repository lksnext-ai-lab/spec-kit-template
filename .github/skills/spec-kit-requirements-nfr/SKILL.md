---
name: spec-kit-requirements-nfr
description: "Define o revisa requisitos no funcionales (NFR) en docs/spec/11-requisitos-tecnicos-nfr.md: medibles o verificables, con método de verificación, drivers, y sin inventar umbrales. Abre OPENQ/ADR cuando falte info o haya trade-offs."
license: Proprietary
---

# Skill: Requirements-NFR (spec-kit)

## Objetivo
Mantener NFR claros, **medibles o verificables**, sin suposiciones, y útiles para implementación/validación.

## Archivos que se pueden modificar
- Primario: `docs/spec/11-requisitos-tecnicos-nfr.md`
- Si aplica:
  - `docs/spec/90-infra.md` (operación/monitoring/backups)
  - `docs/spec/80-seguridad.md` (controles)
  - `docs/spec/40-arquitectura.md` (trade-offs/impacto técnico)
  - `docs/spec/adr/ADR-*.md` (decisiones con trade-off)
  - `docs/spec/95-open-questions.md` (gaps)
  - `docs/spec/96-todos.md` (pendientes)

> No tocar otros ficheros salvo petición explícita.

## Reglas duras (anti-deriva)
1) **No inventar umbrales**
- No fijar p95, disponibilidad, RTO/RPO, retención, límites de carga, etc. si no están definidos.
- Si son necesarios: `TBD` + `OPENQ` (o `TODO` si no bloquea).

2) **NFR ≠ FR**
- Un NFR no describe flujos funcionales ni UI/API concretas; describe condiciones y verificación.

3) **Vendor-neutral por defecto**
- No imponer herramientas/stack salvo evidencia explícita.

4) **No crear NFR “de catálogo”**
- Cada NFR debe tener un **driver** (riesgo, compliance, coste, escala, UX, operación, etc.). Si no hay driver, no crear el NFR.

5) **Trade-offs relevantes → ADR**
- Cuando cumplir el NFR implica elegir (coste vs retención, latencia vs consistencia, etc.).

## Convenciones
- ID: `NFR-###` correlativo
- Prioridad: `MVP` | `Should` | `Could`
- Estado: `Draft` | `Validated` | `Deprecated`
- Categoría (usa solo si aporta): Seguridad | Disponibilidad/Continuidad | Rendimiento/Escalabilidad | Observabilidad | Privacidad/Legal | Mantenibilidad | Portabilidad | UX/Accesibilidad | Coste

## Plantilla obligatoria por NFR

### NFR-### — <Título>

**Driver:** (por qué existe; 1–2 líneas)  
**Categoría:** (opcional)  
**Prioridad:** MVP | Should | Could  
**Estado:** Draft | Validated | Deprecated  
**Bloquea:** Sí | No (si falta dato)  

**Enunciado:** (condición clara, sin adjetivos vacíos)  

**Métrica (si aplica):**
- SLI: (qué se mide)
- Umbral: (valor o `TBD`)
- Ventana/escenario: (valor o `TBD`)
> Si hay SLI pero umbral TBD: NO inventar número.

**Verificación (obligatoria):**
- Método: test | checklist | monitorización | revisión config | auditoría
- Evidencia: dónde queda (dashboard, log, reporte, captura, acta)

**Impacto (solo cuando aplica):**
- Seguridad: link a `docs/spec/80-seguridad.md` o `TBD`
- Infra/Operación: link a `docs/spec/90-infra.md` o `TBD`
- Arquitectura: link a `docs/spec/40-arquitectura.md` o `TBD`
(Para UX/mantenibilidad puede omitirse si no aporta.)

**Notas (si aplica):**
- `OPENQ:` … (si bloquea o condiciona)
- `TODO:` … (si no bloquea)
- `DECISION:` … (y ADR)
- `RISK:` …

## Reglas prácticas: TBD / OPENQ / TODO
- **OPENQ**: falta un dato que cambia el diseño/operación o bloquea aceptación.
- **TODO**: falta un dato que no bloquea MVP (pero debe cerrarse antes de “Validated”).
- Marcar `Bloquea: Sí/No` coherente con lo anterior.

## Antipatrones
- Umbrales numéricos inventados.
- “Alta disponibilidad” sin verificación ni estrategia.
- “Seguridad fuerte” sin controles verificables.
- NFR sin driver.

## DoD
Un NFR está “listo” si:
- [ ] Tiene driver explícito
- [ ] Enunciado claro
- [ ] Verificación + evidencia definidas
- [ ] Si hay métricas: SLI definida y umbral no inventado (TBD si falta)
- [ ] TBD clasificado como OPENQ (bloquea) o TODO (no bloquea)
- [ ] Trade-offs referenciados a ADR si aplican
