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
- `docs/spec/history/**` es histórico: por defecto debe **ignorarse** (solo lo toca `/close-iteration`).
- Dentro de `.github/**`, usar rutas desde raíz (`docs/spec/...`) y evitar enlaces relativos tipo `./...`.

---

## Prompts core incluidos

### 1) `/new-spec`

**Propósito:** arrancar una nueva especificación en `docs/spec/`.

Qué hace:

- guía una entrevista mínima **en modo conversacional** (no “formulario”):
  - realiza **2 preguntas CORE por turno** (máximo 8 CORE),
  - puede hacer **0–2 repreguntas** solo si hay ambigüedad/contradicción, decisión de alto impacto o riesgo de inventar,
  - tras cada respuesta: **resume** lo entendido, **registra OPENQ** si falta info y pide confirmación para continuar,
  - aplica un **presupuesto anti “conversación infinita”** (p. ej., 8 CORE + hasta 4 aclaraciones; el resto → OPENQ),
- crea/actualiza:
  - `docs/spec/00-context.md`
  - `docs/spec/index.md`
  - `docs/spec/95-open-questions.md` (OPENQ iniciales)

Cuándo usarlo:

- al inicio de un proyecto/spec,
- cuando el contexto/alcance cambia de forma relevante.

Salida esperada:

- contexto e índice iniciales listos,
- open questions registradas con impacto,
- siguiente paso recomendado: `/plan-iteration` (o usar el agente Planner).

Notas:

- En proyectos complejos, el **agente Intake** suele ofrecer una experiencia más natural (mismas reglas, preguntas adaptativas). `/new-spec` actúa como atajo de arranque.

---

### 2) `/plan-iteration`

**Propósito:** crear/actualizar un plan ejecutable de iteración en `docs/spec/01-plan.md`.

Qué hace:

- lee el estado actual de `docs/spec/**` (ignorando `docs/spec/history/**`),
- detecta huecos/contradicciones,
- propone 5–15 tareas atómicas con DoD verificable,
- añade gates:
  - `OPENQ-###` si falta info
  - `DECISION:` si hay elecciones relevantes (sin crear ADR aquí)

Cuándo usarlo:

- al inicio de cada iteración,
- después de un review (para convertir feedback en plan),
- tras cerrar una iteración con `/close-iteration`.

Salida esperada:

- `docs/spec/01-plan.md` actualizado (solo iteración activa),
- lista de tareas y entregables,
- siguiente paso recomendado: `/write-from-plan`.

---

### 3) `/write-from-plan`

**Propósito:** ejecutar el plan (`docs/spec/01-plan.md`) redactando/actualizando la spec.

Qué hace:

- recorre las tareas del plan (en orden),
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

- revisa coherencia y calidad de `docs/spec/**` (ignorando `docs/spec/history/**`),
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

### 5) `/close-iteration`

**Propósito:** cerrar la iteración activa, archivar “snapshots” y dejar el repo listo para planificar la siguiente iteración sin mezclar planes.

Qué hace:

- detecta la iteración activa `Ixx` leyendo `docs/spec/01-plan.md`,
- crea `docs/spec/history/<Ixx>/` con snapshots de:
  - `01-plan.md`, `95-open-questions.md`, `96-todos.md`, `97-review-notes.md`
  - y un `00-summary.md` mínimo,
- “limpia” los archivos activos **sin borrar información**:
  - deja `01-plan.md` como plan SOLO de la siguiente iteración (placeholder + link a histórico),
  - deja `95-open-questions.md` solo con OPENQ que siguen abiertas para la siguiente iteración,
  - deja `96-todos.md` solo con TODOs pendientes aplicables,
  - reinicia `97-review-notes.md` como plantilla limpia + link al histórico,
- actualiza `docs/spec/index.md` añadiendo la sección “Histórico de iteraciones”.

Cuándo usarlo:

- al cerrar una iteración (I01, I02…),
- cuando el plan se ha “contaminado” mezclando iteraciones y quieres volver a un estado limpio y mantenible.

Salida esperada:

- histórico creado con enlaces claros,
- archivos activos listos para Iyy,
- siguiente paso recomendado: `/plan-iteration` (generar plan detallado de la nueva iteración).

---

### 6) `/export-docx`

**Propósito:** generar el comando de exportación a DOCX para `spec`, `kit` o `all`.  
**Salida esperada:** comando listo para copiar/pegar en PowerShell y notas de verificación (Pandoc, ubicación del output).

Notas de alcance:

- Por defecto, para `spec` y `all` se **excluye** `docs/spec/history/**` para evitar DOCX enormes/confusos.
- Si necesitas exportar también el histórico, usa el flag `--include-history`.

---

## Cómo se combinan con agentes

Puedes usar prompts sin seleccionar agente. Aun así, la combinación típica es:

- Intake → `/new-spec` (o usar directamente el agente Intake)
- Planner → `/plan-iteration`
- Writer → `/write-from-plan`
- Reviewer → `/review-and-adr`
- (Opcional) cierre → `/close-iteration` → vuelta a Planner

En equipos, es útil acordar:

- “siempre planificamos con `/plan-iteration`”
- “siempre revisamos con `/review-and-adr`”
- “cerramos iteración con `/close-iteration`”
para mantener consistencia.

---

## Buenas prácticas al ejecutar prompts

1. **Contexto mínimo primero**

   - Si el repo está vacío o hay poca info, empieza por `/new-spec` (o por el agente Intake).

2. **Iteraciones cortas**

   - Evita planes gigantes. Mejor 5–15 tareas.

3. **No inventar**

   - Si falta info, OPENQ. Es preferible un hueco explícito a una suposición.

4. **Mantener trazabilidad**

   - No obsesionarse con el 100%, pero sí mantener el "mínimo vivo".

5. **Cerrar iteraciones para evitar mezcla**

- Cuando una iteración termina, usa `/close-iteration` para archivar snapshots y mantener `01-plan.md` limpio.

---

## Errores frecuentes

- Ejecutar `/write-from-plan` sin haber definido un `01-plan.md` coherente.
- Dejar `DECISION:` sin ADR (o sin que el reviewer lo transforme).
- Permitir que el prompt toque `docs/kit/**`.
- Usar enlaces relativos en `.github/**` que generan rutas rotas.
- Tratar el intake como un “formulario” (8 preguntas de golpe) en lugar de una conversación guiada por rondas.
- Mezclar iteraciones dentro de `docs/spec/01-plan.md`:
  - si ocurre, no intentes “limpiar a mano”: usa `/close-iteration` y luego `/plan-iteration`.
- Incluir `docs/spec/history/**` en exportaciones DOCX sin querer (DOCX enorme): por defecto se excluye; usa `--include-history` solo si lo necesitas.

---

## Referencias

- Visión general del sistema IA: `docs/kit/50-sistema-ia.md`
- Custom agents: `docs/kit/52-custom-agents.md`
- Skills: `docs/kit/54-skills.md`
- Reglas globales: `.github/copilot-instructions.md`
