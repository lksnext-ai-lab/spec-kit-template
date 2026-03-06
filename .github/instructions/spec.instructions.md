---
applyTo: "docs/spec/**"
---

# SPEC instructions (docs/spec/**)

Estas instrucciones aplican a la especificación viva en `docs/spec/**`.

## Reglas duras (SPEC)

1) **No inventar.** Si falta info, registrar:
   - `OPENQ-###` en `docs/spec/95-open-questions.md`
   - `TODO-###` en `docs/spec/96-todos.md` si es trabajo pendiente (no pregunta)
2) **Ignorar histórico.** `docs/spec/history/**` se considera histórico:
   - Por defecto, no leer ni editar para Plan/Write/Review.
   - Solo se usa al **cerrar iteración**.
3) **Plan de iteración activa.**
   - `docs/spec/01-plan.md` representa **una única iteración activa**.
   - IDs del plan: **P01..Pnn** (Pxx).
   - No usar `Txx` en `01-plan.md` (Txx es implementación).
4) **Cambios diff-friendly.**
   - Evitar reescrituras masivas.
   - No reordenar secciones por estética.
   - Modificar solo lo necesario para cumplir DoD.
5) **Sin shell destructivo.** No ejecutar borrados/limpiezas.
6) **Modo evolutivo (si existe `codebase/**`).**
   - `codebase/**` es **solo lectura** y fuente de verdad as-is.
   - La spec puede describir to-be, pero no se debe inventar el as-is.
   - Afirmaciones técnicas relevantes deben tener:
     - evidencia (rutas `codebase/...`) o
     - Evidence Pack en `docs/spec/_inputs/evidence/EP-###-<tema>.md`
     - o `OPENQ` explícita si no se puede verificar.
7) **Edición directa y limpieza de temporales.** Usar herramientas de edición directa para modificar archivos de spec. No generar scripts para aplicar cambios. Si un agente crea archivos auxiliares/temporales, eliminarlos inmediatamente tras su uso (o confirmar con el usuario si deben persistir).

## STOP policy (anti-falso-ready)

Si se está redactando o revisando algo crítico y no hay evidencia suficiente:
- auth/roles/permissions
- secretos/api keys
- datos sensibles/modelo
- integraciones críticas
- NFR críticos (seguridad, auditoría, trazabilidad, disponibilidad, etc.)

Entonces:
1) Registrar `OPENQ-###` con impacto (BLOCKER/MAJOR/MINOR) y qué falta para cerrar.
2) En el documento, marcar el punto con `OPENQ:` y enlazar el ID.
3) Si existe plan con estado, marcar la tarea como `BLOCKED` (solo esa fila).

Prohibido “rellenar” con texto plausible sin soporte.

## Convenciones de IDs y marcadores

- `OPENQ-###`: dudas/faltantes
- `TODO-###`: trabajo pendiente
- `DECISION:`: decisión relevante (debe terminar en ADR si procede)
- `ADR-####`: registro de decisión en `docs/spec/adr/`

## Trazabilidad mínima (siempre)

Mantener `docs/spec/02-trazabilidad.md` actualizado al mínimo vivo:
- FR ↔ UI ↔ API/EVT ↔ Datos ↔ ADR (cuando aplique)

No crear tablas enormes ni reescribir; añadir lo imprescindible.

## Reglas de enlaces

- En `docs/spec/**`, enlaces relativos son válidos (p.ej. `adr/ADR-0003-...md`).
- En `.github/**`, usar rutas desde raíz (`docs/spec/...`).

## Proceso recomendado (SPEC)

Ciclo base:
1) Plan (Pxx) → `01-plan.md`
2) Write (ejecutar Pxx) → actualizar docs afectados
3) Review (+ ADR) → `97-review-notes.md` + ADRs si hay DECISION
4) Iterar

Cierre (recomendado cuando se termina una iteración o para “limpiar” estado vivo):
- Archivar snapshot en `docs/spec/history/Ixx/`
- Dejar `01-plan.md`, `95/96/97` como estado vivo manejable
