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

Regla práctica:

- `docs/spec/01-plan.md` representa **una única iteración activa**.
- Las iteraciones cerradas se archivan en `docs/spec/history/Ixx/` para evitar mezclar planes y generar ficheros enormes.

### Histórico de iteraciones (snapshots)

Para preservar trazabilidad sin contaminar el “estado vivo”, las iteraciones cerradas se guardan en:

- `docs/spec/history/<Ixx>/`

Contiene snapshots (copias) del plan y artefactos de control (`95-open-questions`, `96-todos`, `97-review-notes`) y un resumen mínimo (`00-summary.md`).

Regla práctica:

- Prompts y agentes deben **ignorar** `docs/spec/history/**` durante Plan/Write/Review.
- Solo el prompt `/close-iteration` crea/actualiza el histórico.

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
### Modo evolutivo con codebase

Cuando el proyecto ya tiene código implementado, el modo evolutivo permite:

- Consultar el codebase existente (solo lectura) para fundamentar decisiones técnicas.
- Generar un **codebase-map.md** con el mapa técnico del sistema.
- Crear **Evidence Packs (EP-###)** con evidencia específica del código.
- Verificar información externa (integraciones, SDKs, APIs) con **playwright-mcp**.
- Citar evidencia concreta del codebase en la spec.

El agente `spc-codebase-discovery` automatiza esta exploración, generando `codebase-map.md` y Evidence Packs mediante análisis del código. El Director ofrece esta fase como **opción después del Intake** si el proyecto tiene codebase; es totalmente opcional y se puede rechazar sin fricción.

Regla: **no inventar** — cualquier afirmación técnica debe tener evidencia del codebase o registrarse como `OPENQ-###`.

### Evidence Packs (EP-###)

Documentos en `docs/spec/_inputs/evidence/` que contienen investigación técnica específica del codebase:

- Rutas/archivos concretos analizados.
- Contenido confirmado vs inferido (distinguir ambos).
- Respuesta a preguntas técnicas específicas (autenticación, permisos, datos, integraciones, etc.).

Generados con el skill `evidence_pack` o el prompt `/evidence-pack`.

### Verificación de integraciones y fuentes externas

Para afirmaciones sobre integraciones, SDKs, APIs externas, límites o compatibilidades de terceros:

- **No inventar**: si no se puede verificar → registrar `OPENQ-###` indicando qué falta y por qué importa.
- Si el usuario aporta documentación o se tiene acceso directo a ella: reflejarla en la spec con la fuente (`### Fuentes`: URL + fecha + qué se extrajo).
- Si la duda afecta a un área crítica (auth, contratos de integración, datos sensibles): usar impacto `BLOCKER` o `MAJOR` en la OPENQ.
---

## El flujo recomendado

El flujo se basa en un bucle corto y repetible:

1) **Plan**
2) **Write**
3) **Review**
4) **Iterate**

> Nota: “Iterate” incluye tanto aplicar feedback como **cerrar una iteración** para archivar y dejar limpio el plan activo antes de arrancar la siguiente.

### 1) Plan (planificar una iteración)

Objetivo: convertir el estado actual de la spec en una lista breve de tareas atómicas con DoD.

- Documento central: `docs/spec/01-plan.md`
- Entrada típica: contexto + índice + estado actual de docs
- Salida: 5–15 tareas, cada una con resultado verificable

Pistas:

- Si hay dudas que bloquean, se registran como `OPENQ-###` pero el plan sigue con lo no bloqueante.
- Si aparece una decisión, se marca `DECISION:` (sin crear ADR en esta fase).
- El plan debe referirse al “estado vivo” de `docs/spec/**` e ignorar `docs/spec/history/**`.

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

Objetivo: convertir el feedback en cambios y preparar el siguiente ciclo.

- Si el feedback cabe en la iteración actual: ejecutar otra ronda de **Write → Review**.
- Si abre nuevo trabajo: planificar otra iteración (I02, I03, …).

Cierre recomendado de iteración:

- Cuando una iteración está “cerrada” (DoD cumplido y review aceptable), ejecuta **`/close-iteration`** para:
  - archivar snapshots en `docs/spec/history/<Ixx>/`,
  - limpiar `01-plan.md` para la nueva iteración activa,
  - y dejar `95-open-questions.md`, `96-todos.md`, `97-review-notes.md` en modo “vivo” (solo lo pendiente).

Esto evita el error frecuente de mezclar I01/I02 en el mismo plan y que los agentes intenten “limpiar” archivos grandes de forma insegura.
### 5) RFC e IMP (fases opcionales, post-SPEC)

Una vez que la spec está razonablemente estable, el sistema soporta dos fases adicionales, ambas orquestadas por `spc-spec-director` con el mismo principio rector: **no inventar**.

#### Sub-flujo RFC

Objetivo: consolidar la spec multi-archivo en un artefacto narrativo para stakeholders o revisión formal.

1. **Write** (`spc-rfc-writer`) → genera `docs/spec/rfc/<RFC_ID>-<slug>.md` + artefactos auxiliares en `docs/spec/_inputs/rfc/<RFC_ID>/`
2. **Review** (`spc-rfc-reviewer`) → audita el RFC y emite **PASS / WARN / FAIL** con acciones priorizadas
3. **Iterate** → si FAIL/WARN con cambios sustanciales: volver a rfc-writer; si solo correcciones menores: patch directo

Regla: el RFC complementa la spec; no la reemplaza. La fuente de verdad sigue siendo `docs/spec/**`.

#### Sub-flujo SPC-IMP

Objetivo: convertir SPEC/ADR/RFC en un backlog canónico de tareas de implementación (**T01..Tnn**).

*Prerequisito:* la spec debe estar razonablemente completa y revisada.

1. **Slice** (`spc-imp-backlog-slicer`) → genera `docs/spec/spc-imp-backlog.md` con IDs **estables** (nunca renumerar)
2. **Detail** (`spc-imp-task-detailer`) → crea/actualiza fichas `docs/spec/spc-imp-tasks/Txx.md` con DoD verificable y trazabilidad a FR/NFR/ADR/RFC
3. **Audit** (`spc-imp-coverage-auditor`) → verifica cobertura FR/NFR/ADR/RFC vs backlog+fichas; emite **PASS / WARN / FAIL**
4. **Iterate** → si hay gaps: resolver en SPEC primero, luego re-detallar y re-auditar

Nota: Pxx = plan SPEC (`docs/spec/01-plan.md`); Txx = implementación (`docs/spec/spc-imp-tasks/`). No mezclar.
---

## Qué “mueve” el flujo (artefactos de control)

En la práctica, el ciclo se sostiene con estos artefactos:

- `docs/spec/01-plan.md` → define qué se hace y qué significa “terminado”.
- `docs/spec/95-open-questions.md` → evita inventar y preserva bloqueos reales.
- `docs/spec/96-todos.md` → captura trabajo pendiente sin contaminar el plan actual.
- `docs/spec/97-review-notes.md` → convierte calidad en tareas concretas.
- `docs/spec/adr/` → captura decisiones y reduce ambigüedad futura.
- `docs/spec/history/` → conserva iteraciones cerradas sin contaminar el estado vivo.- `docs/spec/rfc/` → propuestas narrativas generadas por `spc-rfc-writer` (fase RFC).
- `docs/spec/spc-imp-backlog.md` + `docs/spec/spc-imp-tasks/` → backlog canónico Txx (fase SPC-IMP).
---

## Señales de que el flujo está funcionando

- El plan es corto, verificable y no se convierte en “mini-Jira”.
- La spec no “inventa”: las dudas quedan como OPENQ.
- Hay pocas contradicciones entre documentos (conceptos estables).
- La trazabilidad se mantiene viva (aunque mínima).
- Las decisiones importantes acaban en ADR.
- Se pueden hacer PRs revisables por iteración.
- Las iteraciones se cierran y archivan: `01-plan.md` no acumula históricos ni duplicados.

Siguiente lectura recomendada: **`30-estructura-del-repo.md`**.
