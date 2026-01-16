# Prompts (prompt files)

Este documento describe los **prompt files** del repo: qué son, cuáles incluye `spec-kit-template`, cuándo usar cada uno y qué salida esperar.

---

## Qué es un “prompt file” en este repo

Un **prompt file** es un comando reutilizable que se ejecuta en Copilot Chat (por ejemplo, escribiendo `/new-spec`). Su objetivo es encapsular un procedimiento repetible del flujo Plan → Write → Review.

En este template, los prompt files viven en:

- `.github/prompts/*.prompt.md`

Características:
- Son “playbooks”: describen objetivo, reglas, lectura previa y salidas obligatorias.
- Normalizan el flujo entre diferentes personas y sesiones.
- Se pueden usar **sin seleccionar un agente** (aunque combinan muy bien con los agentes).

Reglas importantes:
- Por defecto, deben operar sobre `docs/spec/**`.
- No deben tocar `docs/kit/**` salvo petición explícita.
- Dentro de `.github/**`, usar rutas desde raíz (`docs/spec/...`) y evitar enlaces relativos tipo `./...`.

---

## Prompts core incluidos

### 1) `/new-spec`
**Propósito:** arrancar una nueva especificación en `docs/spec/`.

Qué hace:
- guía una entrevista mínima si falta contexto,
- crea/actualiza:
  - `docs/spec/00-context.md`
  - `docs/spec/index.md`
  - `docs/spec/95-open-questions.md` (OPENQ iniciales)

Cuándo usarlo:
- al inicio de un proyecto/spec,
- cuando el contexto/alcance cambia de forma relevante.

Salida esperada:
- contexto e índice iniciales listos,
- open questions registradas,
- siguiente paso recomendado: `/plan-iteration`.

---

### 2) `/plan-iteration`
**Propósito:** crear/actualizar un plan ejecutable de iteración en `docs/spec/01-plan.md`.

Qué hace:
- lee el estado actual de `docs/spec/**`,
- detecta huecos/contradicciones,
- propone 5–15 tareas atómicas con DoD verificable,
- añade gates:
  - `OPENQ-###` si falta info
  - `DECISION:` si hay elecciones relevantes (sin crear ADR aquí)

Cuándo usarlo:
- al inicio de cada iteración,
- después de un review (para convertir feedback en plan).

Salida esperada:
- `docs/spec/01-plan.md` actualizado,
- lista de tareas y entregables,
- siguiente paso recomendado: `/write-from-plan`.

---

### 3) `/write-from-plan`
**Propósito:** ejecutar el plan (`docs/spec/01-plan.md`) redactando/actualizando la spec.

Qué hace:
- recorre las tareas del plan,
- edita documentos `docs/spec/**` según DoD,
- actualiza trazabilidad (`docs/spec/02-trazabilidad.md`) al mínimo vivo,
- registra:
  - `OPENQ-###` si falta info
  - `TODO-###` si aparece trabajo pendiente fuera de iteración
  - `DECISION:` si aparece decisión relevante (sin crear ADR aquí)

Cuándo usarlo:
- después de planificar una iteración,
- tras un review para aplicar mejoras.

Salida esperada:
- documentos actualizados según plan,
- trazabilidad mínima ajustada,
- próximos pasos: `/review-and-adr`.

---

### 4) `/review-and-adr`
**Propósito:** revisión crítica de la spec y creación automática de ADRs cuando proceda.

Qué hace:
- revisa coherencia y calidad de `docs/spec/**`,
- deja feedback accionable en `docs/spec/97-review-notes.md`,
- añade `OPENQ-###` y `TODO-###` si procede,
- detecta `DECISION:` sin ADR y crea:
  - `docs/spec/adr/ADR-####-<slug>.md` (nuevo ADR)
  - basado en `docs/spec/adr/ADR-0001-template.md`
- actualiza trazabilidad (columna ADR) cuando aplique

Cuándo usarlo:
- al final de una iteración,
- antes de compartir/validar formalmente una spec.

Salida esperada:
- review notes con hallazgos,
- ADRs creados/enlazados,
- siguiente acción: volver a Writer o planificar nueva iteración.

---

## Cómo se combinan con agentes

Puedes usar prompts sin seleccionar agente. Aun así, la combinación típica es:

- Intake → `/new-spec`
- Planner → `/plan-iteration`
- Writer → `/write-from-plan`
- Reviewer → `/review-and-adr`

En equipos, es útil acordar:
- “siempre planificamos con `/plan-iteration`”
- “siempre revisamos con `/review-and-adr`”
para mantener consistencia.

---

## Buenas prácticas al ejecutar prompts

1) **Contexto mínimo primero**
- Si el repo está vacío o hay poca info, empieza por `/new-spec`.

2) **Iteraciones cortas**
- Evita planes gigantes. Mejor 5–15 tareas.

3) **No inventar**
- Si falta info, OPENQ. Es preferible un hueco explícito a una suposición.

4) **Mantener trazabilidad**
- No obsesionarse con el 100%, pero sí mantener el “mínimo vivo”.

5) **Usar review como control de calidad**
- El reviewer debe encontrar inconsistencias y “forzar” ADRs para decisiones relevantes.

---

## Errores frecuentes

- Ejecutar `/write-from-plan` sin haber definido un `01-plan.md` coherente.
- Dejar `DECISION:` sin ADR (o sin que el reviewer lo transforme).
- Permitir que el prompt toque `docs/kit/**`.
- Usar enlaces relativos en `.github/**` que generan rutas rotas.

---

## Referencias
- Visión general del sistema IA: `docs/kit/50-sistema-ia.md`
- Custom agents: `docs/kit/52-custom-agents.md`
- Skills: `docs/kit/54-skills.md`
- Reglas globales: `.github/copilot-instructions.md`
