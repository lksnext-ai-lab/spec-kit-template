# Conceptos clave y flujo (Plan → Write → Review → Iterate)

Este documento explica los conceptos que estructuran `spec-kit-template` y el flujo de trabajo recomendado para crear especificaciones consistentes con apoyo de Copilot.

---

## Conceptos clave

### Especificación (“spec”)
Conjunto de documentos en `docs/spec/` que describen qué se va a construir y cómo debe comportarse el sistema, con el nivel de precisión suficiente para:

- reducir ambigüedad,
- permitir estimación y diseño técnico,
- guiar implementación,
- y soportar revisión (técnica y funcional).

### Iteración
Unidad de trabajo de documentación. Una iteración se define en `docs/spec/01-plan.md` e incluye:

- objetivo concreto,
- alcance IN/OUT,
- tareas atómicas,
- y una definición de terminado (DoD).

Ejemplos:
- I01: “Cerrar FR del MVP + NFR mínimos + flujo de checkout”
- I02: “Detallar backend (API + errores) y trazabilidad”
- I03: “Revisión crítica + ADRs de decisiones pendientes”

### Plan ejecutable
El plan en `docs/spec/01-plan.md` es el “contrato” de la iteración: indica qué se va a tocar y qué significa que está terminado. No es un backlog infinito ni una planificación de proyecto: es **accionable** y verificable.

### Trazabilidad mínima
En `docs/spec/02-trazabilidad.md` se mantiene un mapa mínimo, suficiente para enlazar:

- Requisitos (FR)
- UI (pantallas/flujos)
- Backend (API/EVT)
- Datos (entidades)
- Decisiones (ADR)

La trazabilidad evita specs “en islas” y acelera revisión e impacto de cambios.

### Marcadores de elaboración
Durante el trabajo aparecen elementos que deben quedar explícitos:

- `OPENQ`: falta información, hay una incógnita relevante
- `TODO`: trabajo pendiente concreto
- `RISK`: riesgo identificado
- `DECISION`: hay que tomar una decisión relevante (normalmente termina en ADR)

Estos marcadores “sostienen” la iteración sin bloquearla, manteniendo la spec honesta.

### ADR (Architecture Decision Record)
Un ADR es un documento en `docs/spec/adr/` que captura una decisión relevante, con:

- contexto y drivers (por qué importa),
- alternativas consideradas,
- decisión (o estado “propuesto”),
- consecuencias e impacto operativo.

Los ADR evitan decisiones implícitas o perdidas en texto.

---

## El flujo recomendado

El flujo se basa en un bucle corto y repetible:

1) **Plan**
2) **Write**
3) **Review**
4) **Iterate**

### 1) Plan (planificar una iteración)
Objetivo: convertir el estado actual de la spec en una lista breve de tareas atómicas con DoD.

- Documento central: `docs/spec/01-plan.md`
- Entrada típica: contexto + índice + estado actual de docs
- Salida: 5–15 tareas, cada una con resultado verificable

Pistas:
- Si hay dudas que bloquean, se registran como `OPENQ-###` pero el plan sigue con lo no bloqueante.
- Si aparece una decisión, se marca `DECISION:` (sin crear ADR en esta fase).

### 2) Write (redactar/ejecutar el plan)
Objetivo: completar las tareas del plan editando documentos de la spec.

- Los cambios deben seguir el plan (una tarea toca 1–3 archivos).
- Se actualiza la trazabilidad mínimamente conforme se concreta contenido.
- Si aparece trabajo extra no previsto: `TODO-###`
- Si aparece duda: `OPENQ-###`
- Si aparece decisión: `DECISION:` (para que el reviewer lo transforme en ADR)

Resultado: una spec más completa y consistente, lista para revisión.

### 3) Review (revisión crítica)
Objetivo: detectar fallos antes de que se conviertan en deuda (inconsistencias, vaguedades, huecos, riesgos).

- Documento central: `docs/spec/97-review-notes.md`
- El reviewer:
  - marca bloqueantes/importantes,
  - propone cambios mínimos concretos,
  - y crea ADRs automáticamente si detecta `DECISION:` sin ADR enlazado.

Resultado: feedback accionable que vuelve a convertirse en plan o en tareas de escritura.

### 4) Iterate (iterar)
Objetivo: convertir el feedback en cambios.

- Si el feedback cabe en la iteración actual: ejecutar otra ronda de Write → Review.
- Si abre nuevo trabajo: planificar otra iteración (I02, I03, …).

---

## Qué “mueve” el flujo (artefactos de control)

En la práctica, el ciclo se sostiene con estos artefactos:

- `docs/spec/01-plan.md` → define qué se hace y qué significa “terminado”.
- `docs/spec/95-open-questions.md` → evita inventar y preserva bloqueos reales.
- `docs/spec/96-todos.md` → captura trabajo pendiente sin contaminar el plan actual.
- `docs/spec/97-review-notes.md` → convierte calidad en tareas concretas.
- `docs/spec/adr/` → captura decisiones y reduce ambigüedad futura.

---

## Señales de que el flujo está funcionando
- El plan es corto, verificable y no se convierte en “mini-Jira”.
- La spec no “inventa”: las dudas quedan como OPENQ.
- Hay pocas contradicciones entre documentos (conceptos estables).
- La trazabilidad se mantiene viva (aunque mínima).
- Las decisiones importantes acaban en ADR.
- Se pueden hacer PRs revisables por iteración.

Siguiente lectura recomendada: **`30-estructura-del-repo.md`**.
