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
- `docs/spec/history/**` es histórico (snapshots): por defecto se **ignora**. Solo `/close-iteration` crea/actualiza histórico.

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

- En proyectos complejos, usar **`spc-spec-director`** ofrece la experiencia más natural: el Director conduce la entrevista directamente y formaliza el contexto en one-shot. `/new-spec` actúa como atajo de arranque.

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
- después de cerrar una iteración con `/close-iteration` (para planificar la siguiente).

Salida esperada:

- `docs/spec/01-plan.md` actualizado,
- lista de tareas y entregables,
- siguiente paso recomendado: `/write-from-plan`.

Nota importante:

- Si `docs/spec/01-plan.md` contiene iteraciones mezcladas/duplicadas, no debe “limpiarse” manualmente: se recomienda ejecutar `/close-iteration` para archivar y dejar el plan activo limpio.

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

Notas:

- Ignora `docs/spec/history/**`.
- Si el plan está mezclado o no representa claramente una única iteración activa, detente y ejecuta `/close-iteration` + `/plan-iteration`.

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

**Propósito:** cerrar la iteración activa archivando el estado en `docs/spec/history/Ixx/` y dejando limpios los ficheros “activos” para iniciar la siguiente iteración.

Qué hace:

- detecta la iteración activa (`Ixx`) desde `docs/spec/01-plan.md`,
- crea `docs/spec/history/<Ixx>/` con snapshots:
  - `01-plan.md`, `95-open-questions.md`, `96-todos.md`, `97-review-notes.md`
  - y un `00-summary.md` con resumen final y qué pasa a la siguiente iteración,
- reescribe los ficheros activos para que representen SOLO la nueva iteración (Iyy):
  - `docs/spec/01-plan.md` queda como plan activo (placeholder listo para `/plan-iteration`)
  - `docs/spec/95-open-questions.md` queda con solo OPENQ abiertas relevantes
  - `docs/spec/96-todos.md` queda con solo TODOs pendientes relevantes
  - `docs/spec/97-review-notes.md` se reinicia (plantilla limpia) con enlace a histórico
- actualiza `docs/spec/index.md` añadiendo enlaces al histórico de iteraciones.

Cuándo usarlo:

- al cerrar una iteración (I01, I02…),
- cuando el plan se ha mezclado con iteraciones anteriores y quieres “resetear” el plan activo sin perder trazabilidad,
- antes de arrancar una nueva iteración para evitar archivos enormes y confusos.

Salida esperada:

- histórico creado y enlazado desde el índice,
- activos limpios para la siguiente iteración,
- lista explícita de OPENQ/TODO que pasan a Iyy,
- siguiente paso recomendado: `/plan-iteration`.

---

### 6) `/export-docx`

**Propósito:** generar el comando de exportación a DOCX para `spec`, `kit` o `all`.  
**Salida esperada:** comando listo para copiar/pegar en PowerShell y notas de verificación (Pandoc, ubicación del output).

Notas:

- Por defecto, al exportar `spec` o `all` se recomienda EXCLUIR `docs/spec/history/**` para evitar DOCX enormes y confusos.
- Si el usuario quiere incluir histórico, debe indicarlo explícitamente y el comando debe reflejarlo (según opciones soportadas por `tools/export_docx.py`).

---

## Prompts de modo codebase (evolutivos)

Estos prompts se usan cuando el workspace contiene un repositorio de código (`codebase/**`) y se redacta especificación para proyectos existentes:

### 7) `/audit-spec-vs-codebase`

**Archivo:** [.github/prompts/audit-spec-vs-codebase.prompt.md](../.github/prompts/audit-spec-vs-codebase.prompt.md)

**Propósito:** auditar la especificación contra la realidad del codebase, ajustar la spec o crear OPENQ cuando hay discrepancias.

Qué hace:

- Lee `docs/spec/**` (ignorando `docs/spec/history/**`)
- Consulta `codebase/**` (solo lectura) como fuente de verdad técnica
- Detecta:
  - **Afirmaciones sin evidencia**: cuando la spec dice algo técnico no sustentado
  - **Contradicciones**: cuando la spec contradice el codebase real
  - **Gaps**: cuando falta información crítica en la spec respecto al codebase
  - **Invenciones**: cuando se asume comportamiento no confirmado
- Ajusta la spec:
  - Cita rutas `codebase/...` para sustentar afirmaciones
  - Enlaza Evidence Packs (`docs/spec/_inputs/evidence/EP-###-<tema>.md`) si existen
  - Crea `OPENQ-###` si no hay evidencia suficiente (indicando qué se revisó)
- Actualiza `docs/spec/_inputs/codebase-map.md` si detecta información estructural relevante

Cuándo usarlo:

- Después de redactar secciones técnicas (arquitectura, backend, datos, integraciones) en modo evolutivo
- Cuando sospechas que la spec está "asumiendo" comportamientos no verificados
- Antes de una revisión formal para validar coherencia spec ↔ codebase

Salida esperada:

- Spec actualizada con evidencias (`codebase/...` o links a Evidence Packs)
- `OPENQ-###` creados para gaps detectados
- Notas de auditoría con hallazgos (contradicciones, invenciones, ajustes realizados)
- Siguiente paso recomendado: `/review-and-adr` para validar calidad final

---

### 8) `/evidence-pack`

**Archivo:** [.github/prompts/evidence-pack.prompt.md](../.github/prompts/evidence-pack.prompt.md)

**Propósito:** investigar un tema específico en `codebase/**` y generar un Evidence Pack con hallazgos sustentados.

Qué hace:

- Recibe un **tema** a investigar (p. ej. "auth flow", "permisos por rol", "integración con servicio X")
- Explora `codebase/**` de forma acotada:
  - Busca archivos/carpetas relevantes con términos relacionados
  - Lee código fuente, configs, tests relacionados
  - Distingue entre hallazgos **confirmados** (evidencia directa) y **inferidos** (probable pero no explícito)
- Genera `docs/spec/_inputs/evidence/EP-###-<tema>.md` con:
  - **Tema**: qué se investiga
  - **Rutas revisadas**: archivos/carpetas consultados en `codebase/**`
  - **Hallazgos confirmados**: afirmaciones con evidencia directa (citas de rutas)
  - **Hallazgos inferidos**: lo que parece probable pero requiere validación
  - **Gaps detectados**: información que no se encuentra (candidatos a OPENQ)
  - **Recomendaciones para la spec**: cómo reflejar estos hallazgos sin inventar
- Aplica skill `evidence_pack` para estructura y calidad

Cuándo usarlo:

- Cuando una sección de la spec requiere precisión técnica (auth, permisos, datos, integraciones, operación)
- Antes de redactar decisiones técnicas críticas que dependen del codebase
- Cuando necesitas fundamentar una decisión arquitectónica con hechos del sistema existente

Salida esperada:

- Evidence Pack en `docs/spec/_inputs/evidence/EP-###-<tema>.md`
- Reporte con rutas consultadas, hallazgos (confirmados vs inferidos) y gaps
- Siguiente paso recomendado: usar el Evidence Pack como referencia al redactar/actualizar la spec (enlazar desde secciones relevantes)

---

## Cómo se combinan con agentes

Puedes usar prompts sin seleccionar agente. Aun así, la combinación típica es:

- Inicio → `spc-spec-director` (orquesta todo el flujo conversacionalmente)
- O prompts explícitos: `/new-spec` → `/plan-iteration` → `/write-from-plan` → `/review-and-adr`

En equipos, es útil acordar:

- “siempre planificamos con `/plan-iteration`”
- “siempre revisamos con `/review-and-adr`”
- “siempre cerramos iteración con `/close-iteration`”
para mantener consistencia.

---

## Buenas prácticas al ejecutar prompts

1. **Contexto mínimo primero**

   - Si el repo está vacío o hay poca info, empieza por `spc-spec-director` (o por `/new-spec` si prefieres prompts).

2. **Iteraciones cortas**

   - Evita planes gigantes. Mejor 5–15 tareas.

3. **No inventar**

   - Si falta info, OPENQ. Es preferible un hueco explícito a una suposición.

4. **Mantener trazabilidad**

   - No obsesionarse con el 100%, pero sí mantener el "mínimo vivo".

5. **Usar review como control de calidad**

   - El reviewer debe encontrar inconsistencias y "forzar" ADRs para decisiones relevantes.

6. **Cerrar iteraciones para evitar mezcla**

   - Al finalizar una iteración, ejecuta `/close-iteration` antes de arrancar la siguiente. Evita planes mezclados y archivos cada vez más grandes.

---

## Errores frecuentes

- Ejecutar `/write-from-plan` sin haber definido un `01-plan.md` coherente.
- Dejar `DECISION:` sin ADR (o sin que el reviewer lo transforme).
- Permitir que el prompt toque `docs/kit/**`.
- Usar enlaces relativos en `.github/**` que generan rutas rotas.
- Tratar el intake como un “formulario” (8 preguntas de golpe) en lugar de una conversación guiada por rondas (el Director hace esto correctamente si lo dejas operar).
- No cerrar iteraciones y acabar con `01-plan.md` mezclando I01/I02.

---

## Referencias

- Visión general del sistema IA: `docs/kit/50-sistema-ia.md`
- Custom agents: `docs/kit/52-custom-agents.md`
- Skills: `docs/kit/54-skills.md`
- Reglas globales: `.github/copilot-instructions.md`
