# Custom agents

Este documento describe los **Custom Agents** incluidos en `spec-kit-template`: qué rol cumplen, cómo colaboran entre sí y cómo deben usarse para generar una especificación consistente en `docs/spec/`.

---

## Qué es un Custom Agent (en este contexto)

Un **Custom Agent** es un “rol de trabajo” definido para Copilot. No es un prompt suelto: es una configuración que orienta el comportamiento para una tarea concreta (por ejemplo, planificar o revisar).

En este repositorio, los agentes viven en:

- `.github/agents/*.agent.md`

Los agentes deben operar bajo las **Copilot Instructions** del repo y, por defecto:
- **editar solo** `docs/spec/**`
- **no tocar** `docs/kit/**` salvo petición explícita
- **ignorar** `docs/spec/history/**` (histórico de iteraciones; no es “fuente viva”)

---

## Por qué usar agentes (en vez de un único chat)

Separar agentes ayuda a:

- **enfocar** el trabajo (cada rol tiene checklist mental y límites claros),
- mejorar **consistencia** (menos variabilidad entre sesiones/autores),
- reducir “mezclas” (planificar ≠ redactar ≠ revisar),
- y crear una rutina de trabajo fácil de enseñar al equipo.

---

## Agentes incluidos (estándar)

El template define 4 agentes principales (nombres orientativos):

1) Intake
2) Planner
3) Writer
4) Reviewer

### 1) Intake (arranque / entrevista)
**Propósito:** recopilar información mínima para arrancar una spec sin inventar.

Responsabilidades:
- hacer preguntas clave (qué se construye, usuarios/roles, MVP, restricciones, datos sensibles, integraciones),
- conducir una entrevista **conversacional** (no “formulario”):
  - **2 preguntas CORE por turno** (orden estable por rondas),
  - **repreguntas opcionales (0–2)** solo si hay ambigüedad, contradicción, decisión de alto impacto o riesgo de inventar,
  - tras cada respuesta: **resumen breve + registro de OPENQ** y confirmación explícita para continuar,
  - **presupuesto anti “conversación infinita”** (p. ej., 8 CORE + hasta 4 aclaraciones),
- crear o actualizar:
  - `docs/spec/00-context.md`
  - `docs/spec/index.md` (solo ajustes mínimos si detecta roturas)
  - `docs/spec/95-open-questions.md` (si hay lagunas)

Qué NO hace:
- no define arquitectura en detalle,
- no redacta FR/NFR completos,
- no produce un plan de iteración completo (eso es del Planner),
- no crea ADRs (si aparece una decisión, marca `DECISION:` y registra OPENQ si faltan drivers/datos),
- no usa ni “rescata” contenido desde `docs/spec/history/**`.

Cuándo usarlo:
- al iniciar una nueva spec (recomendado),
- o cuando el contexto cambia significativamente.

Relación con `/new-spec`:
- `/new-spec` es un **atajo** para arrancar la conversación de intake (mismas reglas de “no inventar” y apertura de OPENQ),
- en proyectos complejos, se recomienda priorizar el **agente Intake** por su capacidad de adaptar preguntas y aclaraciones.

---

### 2) Planner (planificación de iteraciones)
**Propósito:** convertir el estado actual de la spec en un plan ejecutable.

Responsabilidades:
- leer `docs/spec/**` y detectar qué falta, qué contradice y qué bloquea,
- actualizar `docs/spec/01-plan.md` con:
  - objetivo, alcance IN/OUT,
  - 5–15 tareas atómicas,
  - DoD verificable,
  - gates de OPENQ/DECISION.

Qué NO hace:
- no redacta contenido profundo (FR/NFR/UI/arquitectura),
- no crea ADRs (solo marca `DECISION:` para que el Reviewer lo formalice),
- no intenta “limpiar” planes mezclados con ediciones destructivas o comandos.

Nota operativa (planes mezclados):
- Si detecta que `docs/spec/01-plan.md` contiene iteraciones mezcladas/duplicadas, debe recomendar ejecutar **`/close-iteration`** para archivar la iteración cerrada y dejar el plan activo limpio antes de continuar planificando.

Cuándo usarlo:
- al inicio de cada iteración,
- tras una revisión crítica (para convertir feedback en plan),
- tras cerrar una iteración con `/close-iteration`.

---

### 3) Writer (redacción / ejecución del plan)
**Propósito:** ejecutar el plan editando la spec con cambios concretos y trazables.

Responsabilidades:
- seguir `docs/spec/01-plan.md` tarea por tarea,
- actualizar documentos de `docs/spec/**` según DoD,
- mantener `docs/spec/02-trazabilidad.md` al mínimo vivo,
- registrar:
  - `OPENQ-###` en `docs/spec/95-open-questions.md`
  - `TODO-###` en `docs/spec/96-todos.md`
  - `DECISION:` en el doc correspondiente (si aparece una decisión)

Qué NO hace:
- no “resuelve” dudas inventando,
- no crea ADRs (eso es trabajo del Reviewer),
- no replanifica: si necesita cambiar alcance/orden o introducir gates, debe registrarlo como TODO/OPENQ y volver a Planner,
- no ejecuta “limpiezas” de ficheros ni usa comandos de shell,
- no usa ni edita `docs/spec/history/**`.

Cuándo usarlo:
- después de planificar una iteración,
- para aplicar los cambios sugeridos en revisión.

---

### 4) Reviewer (revisión crítica + ADR)
**Propósito:** revisar con ojos críticos y elevar decisiones a ADR.

Responsabilidades:
- revisar coherencia global (contexto ↔ FR/NFR ↔ UI ↔ arquitectura ↔ datos ↔ backend/frontend ↔ seguridad ↔ infra),
- registrar feedback accionable en `docs/spec/97-review-notes.md`,
- crear `OPENQ-###` y `TODO-###` si procede,
- detectar `DECISION:` sin ADR enlazado y crear ADR automáticamente en `docs/spec/adr/`.

Qué NO hace:
- no reescribe “todo”,
- no convierte el review en una nueva especificación paralela,
- no toma decisiones inventadas: si falta info, deja “Propuesto” + OPENQ,
- no intenta “limpiar” planes mezclados; si ocurre, lo registra como hallazgo y sugiere `/close-iteration`,
- no usa ni edita `docs/spec/history/**` (salvo enlazarlo desde el índice si procede).

Cuándo usarlo:
- al final de cada iteración,
- cuando se quiere elevar calidad antes de compartir/firmar la spec.

---

## Cómo colaboran entre sí (handoffs)

Flujo típico:

1) **Intake** → deja contexto e índice listos (y OPENQ iniciales)
2) **Planner** → produce `01-plan.md`
3) **Writer** → ejecuta plan y actualiza docs/spec
4) **Reviewer** → genera review notes y ADRs
5) (Opcional) **Close iteration** → `/close-iteration` archiva la iteración cerrada y limpia archivos activos
6) Vuelta a **Planner** (nueva iteración) o **Writer** (aplicar mejoras)

---

## Reglas comunes para todos los agentes

### Alcance (cortafuegos)
- Por defecto, editar solo `docs/spec/**`.
- No tocar `docs/kit/**` salvo petición explícita.
- Ignorar `docs/spec/history/**` en lectura/edición (solo snapshots).

### No inventar
- Si falta info: `OPENQ-###`.
- Si la info es tentativa: marcar como supuesto o riesgo.

### Rutas y enlaces
- En `.github/**` (agentes/prompts): usar rutas desde raíz (`docs/spec/...`).
- En `docs/spec/**`: enlaces relativos son válidos (por ejemplo `adr/ADR-0002-...md`) y evita `./`.

### Cambios mínimos, iterativos
- No hacer refactors masivos del texto.
- Mejor pequeñas mejoras verificables por iteración.

---

## Consejos de uso en equipo

- Usar el mismo ciclo en todas las specs: facilita onboarding.
- Hacer PRs por iteración (o al menos commits por iteración).
- Tratar cambios en `.github/**` como cambios “de plataforma” y revisarlos con más cuidado.
- Si hay conflicto de criterio entre personas, capturarlo como `DECISION:` → ADR.

---

## Referencias
- Instructions (reglas globales): `.github/copilot-instructions.md`
- Prompts (comandos): `docs/kit/53-prompts.md`
- Skills (patrones de calidad): `docs/kit/54-skills.md`
- Flujo general: `docs/kit/20-conceptos-clave-y-flujo.md`
