# Kit: guía de uso y funcionamiento (spec-kit-template)

Esta sección documenta el **sistema** `spec-kit-template`: cómo está diseñado, cómo se usa con VS Code + Copilot y cómo mantener una especificación técnica en Markdown de forma iterativa.

> Nota: La especificación de cada proyecto vive en `docs/spec/`.  
> Este “Kit” explica el template y su modo de uso.

---

## Objetivo del kit
- Facilitar el onboarding de personas que van a usar el template.
- Explicar el flujo recomendado (Plan → Write → Review → Iterate).
- Documentar el sistema de IA (instructions, agentes, prompts, skills).
- Recoger prácticas recomendadas y troubleshooting.

---

## Lectura recomendada (por orden)

### 1) Visión general
- `00-resumen-ejecutivo.md`
- `10-objetivo-y-alcance.md`
- `20-conceptos-clave-y-flujo.md`
- `30-estructura-del-repo.md`
- `40-documentacion-generada.md`

### 2) Sistema de IA (cómo se usa Copilot en este repo)
- `50-sistema-ia.md`
- `51-instructions.md`
- `52-custom-agents.md`
- `53-prompts.md`
- `54-skills.md`

### 3) Uso del template y operativa
- `60-uso-del-template.md`
- `70-operativa-diaria.md`
- `80-previsualizacion-mkdocs.md`

### 4) Evolución y soporte
- `90-mantenimiento-y-evolucion.md`
- `95-faq-y-troubleshooting.md`

---

## Principios clave (recordatorio rápido)
- **No inventar**: si falta info, registrar `OPENQ`.
- **Plan manda**: la iteración se ejecuta desde `docs/spec/01-plan.md`.
- **Decisiones visibles**: `DECISION` → ADR.
- **Separación**:
  - `docs/spec/**` = especificación del proyecto
  - `docs/kit/**` = guía del sistema

---

## Navegación rápida
- Para crear una nueva spec: empieza por `docs/kit/60-uso-del-template.md`.
- Para entender Copilot en el repo: `docs/kit/50-sistema-ia.md`.
- Para previsualizar en navegador: `docs/kit/80-previsualizacion-mkdocs.md`.
- Si algo falla: `docs/kit/95-faq-y-troubleshooting.md`.
