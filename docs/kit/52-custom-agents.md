# Custom Agents (agent files)

Este documento describe los **custom agents** del repo: qué son, cuáles incluye el template, cuándo usar cada uno y cómo se integran en los workflows de especificación, RFC e implementación.

---

## Qué es un "custom agent" en este repo

Un **custom agent** es un agente reutilizable especializado que se puede invocar desde Copilot Chat con `@agent-name`. Su objetivo es ejecutar tareas complejas multi-paso de forma autónoma y consistente.

En este template, los custom agents viven en:

- `.github/agents/*.agent.md`

### Características

Los custom agents de este sistema:

- Son agentes especializados por fase (**SPEC**, **RFC**, **IMP**) y rol (intake, planner, writer, reviewer, slicer…)
- Pueden invocar **skills** para aplicar reglas de calidad especializadas
- Se invocan **exclusivamente de forma programática** por el Director (no hay botones de handoff)
- Operan sobre `docs/spec/**` (escritura) y, en modo evolutivo, consultan `codebase/**` (solo lectura)
- Aplican reglas **anti-invención**: si falta información, registran `OPENQ-###` y continúan sin asumir

### Reglas importantes (válidas para todos los agentes)

- Por defecto, deben operar sobre `docs/spec/**`
- **No deben tocar** `docs/kit/**` salvo petición explícita del usuario
- `docs/spec/history/**` es histórico: por defecto debe **ignorarse** (solo lo toca `/close-iteration`)
- **No usan comandos de shell/PowerShell**: prohibidos borrados, limpiezas o comandos destructivos
- En **modo evolutivo** con `codebase/` en el workspace:
  - Consultar `codebase/**` como **fuente de verdad** (solo lectura)
  - Generar **Evidence Packs** en `docs/spec/_inputs/evidence/` cuando sea necesario para fundamentar afirmaciones técnicas
  - Si no hay evidencia suficiente: registrar `OPENQ-###` indicando qué se buscó y dónde

---

## Modelo recomendado de uso (director-first)

Para simplificar la experiencia del desarrollador, el modelo recomendado es:

- El usuario se dirige **siempre** al **director**
- El director conduce una conversación contextualizada: explica qué va a hacer, pide confirmación, delega al subagente programáticamente y presenta el resultado
- El usuario no necesita pensar en “qué fase toca” ni “qué agente toca”
- No hay botones de handoff. Todo el flujo es conversacional y contextualizado al momento del workflow

### Director

#### `spc-spec-director` — Puerta única de entrada

**Archivo:** [../../.github/agents/spc-spec-director.agent.md](../../.github/agents/spc-spec-director.agent.md)

**Propósito:** Interpretar lo que el usuario quiere implementar (o lo que descubre durante el desarrollo) y orquestar SPEC → RFC → IMP sin exigir conocer el flujo interno.

**Qué aporta:**
- Decide si toca Intake / Plan / Write / Review / RFC / IMP
- Explica al usuario qué va a hacer y por qué antes de cada delegación, y espera confirmación
- Conduce él mismo la entrevista de intake (rondas de 2 preguntas) y delega a `spc-spec-intake` en one-shot para formalizar documentos
- Actúa como relay: si un subagente genera OPENQ/decisiones/preguntas, el Director las traslada al usuario en lenguaje claro antes de continuar
- Aplica “pasos atómicos” (bloques pequeños) y evita cambios masivos
- Señaliza gates (OPENQ/DECISION/RFC needed) y bloqueos (BLOCKED)

**Cuándo usarlo:**
- Siempre que quieras avanzar sin pensar en el workflow interno
- Cuando aparezca un hallazgo nuevo en implementación y haya que re-encaminar

---

## Agentes SPEC — Workflow de especificación

### Suite SPEC (5 agentes)

Estos agentes implementan el ciclo **Plan → Redacción → Revisión → Iteración**.

> Nota de IDs:  
> - En SPEC, el plan usa **P01..Pnn** (en `docs/spec/01-plan.md`)  
> - En implementación, las tareas usan **T01..Tnn** (en `docs/spec/spc-imp-tasks/`)

---

#### 1) `spc-spec-intake` — Arranque / ajuste de contexto

**Archivo:** [../../.github/agents/spc-spec-intake.agent.md](../../.github/agents/spc-spec-intake.agent.md)

**Propósito:** Formalizar el contexto recogido por el Director en los documentos de spec.

> **Este agente NO interactúa con el usuario directamente.** La entrevista la conduce el Director.

**Qué hace** (invocado en one-shot por el Director):
- Recibe todo el contexto acumulado por el Director en el prompt de tarea
- Crea/actualiza `docs/spec/00-context.md` con objetivo, alcance, éxito, restricciones, integraciones y riesgos
- Crea/actualiza `docs/spec/95-open-questions.md` con OPENQs identificadas
- Señaliza gates: `DECISION` y/o `RFC needed` cuando aplique
- Devuelve al Director un resumen (documentos tocados, OPENQs, gates, evaluación DoR)
- En modo evolutivo: consulta `codebase/**` para confirmar supuestos técnicos

**Salidas obligatorias:**
- `docs/spec/00-context.md` actualizado
- `docs/spec/95-open-questions.md` actualizado

**Invocado por:** el Director, tras completar la entrevista con el usuario

**Siguiente paso típico:** el Director presenta el resultado al usuario y propone Planner

---

#### 1b) `spc-codebase-discovery` — Documentación del codebase (opcional)

**Archivo:** [../../.github/agents/spc-codebase-discovery.agent.md](../../.github/agents/spc-codebase-discovery.agent.md)

**Propósito:** Explorar y documentar un codebase existente cuando se trabaja en modo evolutivo. Genera artefactos consumibles por el resto de agentes.

**Cuándo se invoca:**
- Después del intake, si existe `codebase/` con contenido sustancial (>10 archivos) y no hay mapa o está obsoleto (>60 días).
- Durante la redacción (Fase 2), si el writer necesita un Evidence Pack para una sección técnica.
- Tras la implementación (Fase 4), si las tareas completadas afectan áreas documentadas en el mapa.

**3 modos:**
- `initial` — Mapa completo + hasta 3 Evidence Packs de las áreas principales.
- `focused` — Un solo Evidence Pack sobre un tema específico (FOCUS).
- `refresh` — Actualización incremental de mapa y EPs afectados por cambios recientes.

**Salidas:**
- `docs/spec/_inputs/codebase-map.md` (mapa del proyecto)
- `docs/spec/_inputs/evidence/EP-###-<tema>.md` (Evidence Packs)
- OPENQs registradas en `docs/spec/95-open-questions.md`

**Qué NO hace:**
- No modifica el codebase ni la spec.
- No se invoca en proyectos greenfield (sin `codebase/`).
- No reemplaza la lectura directa de `codebase/` por otros agentes cuando necesiten info puntual.

**Siguiente paso típico:** el Director presenta los artefactos al usuario y continúa hacia Planner o Writer

---

#### 2) `spc-spec-planner` — Planificación de iteración (Pxx)

**Archivo:** [../../.github/agents/spc-spec-planner.agent.md](../../.github/agents/spc-spec-planner.agent.md)

**Propósito:** Mantener `docs/spec/01-plan.md` como **plan ejecutable de iteración activa** (no backlog infinito), con:

- Objetivo de iteración
- Alcance IN/OUT
- Gates (OPENQ/DECISION/RFC needed)
- 5–15 tareas atómicas con DoD verificable
- Bloques ejecutables (stepper-friendly)

**Qué hace:**
- Construye tareas atómicas con:
  - **ID: P01, P02…**
  - Tarea (verbo + objeto)
  - Archivos (rutas explícitas)
  - DoD (1–3 bullets verificables)
  - Gates (OPENQ/DECISION/RFC needed)
  - Estado (TODO/READY/BLOCKED)
- En modo evolutivo:
  - exige estrategia de evidencia para decisiones críticas (rutas `codebase/...`, Evidence Pack o `OPENQ`)
- Si detecta mezcla de iteraciones en `01-plan.md`:
  - **no limpia manualmente**
  - recomienda `/close-iteration` y replanificar

**Qué puede editar:**
- ✅ `docs/spec/01-plan.md` (obligatorio)
- ✅ `docs/spec/95-open-questions.md` / `docs/spec/96-todos.md` (si aplica)
- ✅ (modo evolutivo) `docs/spec/_inputs/codebase-map.md` y Evidence Packs
- ❌ No redacta la spec completa (eso es Writer)

**Cuándo se invoca:**
- Después de que el Director formalice el contexto con intake
- Al iniciar una nueva iteración
- Para actualizar el plan cuando cambie el alcance

**Siguiente paso típico:** el Director presenta el plan al usuario y propone Writer

---

#### 3) `spc-spec-writer` — Redacción y ejecución del plan

**Archivo:** [../../.github/agents/spc-spec-writer.agent.md](../../.github/agents/spc-spec-writer.agent.md)

**Propósito:** Ejecutar el plan de `docs/spec/01-plan.md` y materializarlo en documentos de `docs/spec/**` con cambios pequeños y verificables.

**Qué hace:**
- Ejecuta solo:
  - `TASKS: Pxx,Pyy` si se indica, o
  - tareas `READY`, o
  - un subconjunto acotado (change budget) si el plan es legacy
- Por tarea:
  - Modifica solo los archivos indicados (o el mínimo imprescindible)
  - Cumple el DoD
  - Si falta info: `OPENQ:` + `OPENQ-###`
  - Si hay trabajo nuevo fuera del plan: `TODO-###`
  - Si hay decisión relevante: `DECISION:` (Reviewer creará ADR)
- En modo evolutivo:
  - `codebase/**` es solo lectura y fuente de verdad as-is
  - afirmaciones técnicas relevantes requieren:
    - evidencia (rutas `codebase/...`) o Evidence Pack
    - o `OPENQ` explícita si no se puede verificar
- Si hay incertidumbre crítica (auth/datos/seguridad/integraciones/NFR críticos) sin evidencia:
  - **STOP policy**: no sigue “como si”
  - registra OPENQ y marca la tarea como BLOCKED (si el plan permite estado)

**Al finalizar:**
- Actualiza trazabilidad mínima (`docs/spec/02-trazabilidad.md`) sin reescrituras masivas
- Actualiza `docs/spec/index.md` solo si se crean docs nuevos

**Siguiente paso típico:** el Director presenta el resultado al usuario y propone Reviewer

---

#### 4) `spc-spec-reviewer` — Revisión crítica + Auto-ADR

**Archivo:** [../../.github/agents/spc-spec-reviewer.agent.md](../../.github/agents/spc-spec-reviewer.agent.md)

**Propósito:** Mejorar calidad, coherencia y completitud de la especificación sin reescribirla masivamente.

**Qué hace:**
- Audita coherencia Contexto ↔ FR/NFR ↔ UI ↔ Arquitectura ↔ Datos ↔ Backend/Frontend ↔ Seguridad ↔ Infra
- Verifica:
  - FR con CA verificables
  - NFR medibles o verificables
  - trazabilidad mínima activa (02-trazabilidad)
  - evidencia (en modo evolutivo): rutas `codebase/...` o Evidence Packs donde aplique
- Política de edición:
  - correcciones pequeñas y seguras
  - feedback accionable en `docs/spec/97-review-notes.md`
- Auto-ADR:
  - si detecta `DECISION:` sin ADR enlazado, crea ADR usando la plantilla y enlaza

**Salidas obligatorias:**
- `docs/spec/97-review-notes.md`
- `docs/spec/95-open-questions.md` / `docs/spec/96-todos.md` (si aplica)
- `docs/spec/adr/ADR-####-*.md` (si aplica)

**Siguiente paso típico:** el Director presenta el veredicto al usuario; si hay correcciones, propone re-invocar Writer

---

## Agentes RFC — Propuesta técnica / ejecutiva

### Suite RFC (2 agentes)

> Los RFC son artefactos narrativos (stakeholders/arquitectura).  
> La **fuente de verdad** sigue siendo `docs/spec/**`.

#### 5) `spc-rfc-writer` — Generador de RFC

**Archivo:** [../../.github/agents/spc-rfc-writer.agent.md](../../.github/agents/spc-rfc-writer.agent.md)

**Propósito:** Generar/actualizar un RFC en español a partir de la spec multi-archivo.

**Salidas típicas:**
- `docs/spec/rfc/<RFC_ID>-<slug>.md`
- `docs/spec/_inputs/rfc/<RFC_ID>/(sources.md, notes.md, quality-report.md)`

**Siguiente paso típico:** el Director presenta el RFC al usuario y propone spc-rfc-reviewer

#### 6) `spc-rfc-reviewer` — Auditor de RFC

**Archivo:** [../../.github/agents/spc-rfc-reviewer.agent.md](../../.github/agents/spc-rfc-reviewer.agent.md)

**Propósito:** Auditar el RFC contra la spec/ADRs para detectar invenciones, gaps y contradicciones. Emite PASS/WARN/FAIL y acciones priorizadas.

---

## Agentes SPC-IMP — Backlog de implementación (Txx)

### Suite SPC-IMP (3 agentes)

Estos agentes convierten SPEC/RFC/ADR en un backlog canónico de tareas de implementación para CODEBASE.

#### 7) `spc-imp-backlog-slicer` — Generador de backlog

**Archivo:** [../../.github/agents/spc-imp-backlog-slicer.agent.md](../../.github/agents/spc-imp-backlog-slicer.agent.md)

**Propósito:** Convertir la especificación en `docs/spec/spc-imp-backlog.md` con tareas T01..Tnn (IDs estables).

#### 8) `spc-imp-task-detailer` — Detallador de tareas

**Archivo:** [../../.github/agents/spc-imp-task-detailer.agent.md](../../.github/agents/spc-imp-task-detailer.agent.md)

**Propósito:** Transformar filas del backlog en fichas Txx ejecutables con DoD verificable y trazabilidad a SPEC/ADR/RFC.

#### 9) `spc-imp-coverage-auditor` — Auditor de cobertura

**Archivo:** [../../.github/agents/spc-imp-coverage-auditor.agent.md](../../.github/agents/spc-imp-coverage-auditor.agent.md)

**Propósito:** Verificar cobertura FR/NFR/ADR/RFC vs backlog+fichas Txx. Produce report con acciones correctivas.

---

## Workflows (cómo se usan en la práctica)

### Workflow 1: Especificación nueva (director-first)

```
Usuario ←→ spc-spec-director (conversación continua)
  │
  ├─ [si falta contexto]
  │   Director entrevista al usuario (rondas de 2 preguntas)
  │   → confirma → delega a spc-spec-intake (one-shot, formaliza docs)
  │   → presenta resultado → gate humano
  │
  ├─ [si hay codebase/ con contenido y no hay mapa]
  │   Director propone discovery (opcional: rápido/profundo/saltar)
  │   → si acepta → delega a spc-codebase-discovery (MODE=initial)
  │   → presenta artefactos (mapa, EPs, OPENQs)
  │   → si el discovery revela discrepancias con contexto → ofrece re-intake
  │   → gate humano
  │
  ├─ [si falta plan]
  │   Director explica → confirma → delega a spc-spec-planner
  │   → presenta resultado
  │
  ├─ [si hay READY]
  │   Director explica → confirma → delega a spc-spec-writer
  │   → si subagente genera OPENQs: Director pregunta al usuario → re-invoca
  │   → presenta resultado
  │
  └─ [revisión]
      Director explica → confirma → delega a spc-spec-reviewer
      → si hay WARNs/FAILs: Director los traslada al usuario, pide confirmación, itera
      → gate humano → iterar o /close-iteration
```

### Workflow 2: Generación de RFC

```
Usuario ←→ spc-spec-director (conversación continua)
  ├─ Director explica → confirma → delega a spc-rfc-writer → presenta resultado
  ├─ Director explica → confirma → delega a spc-rfc-reviewer → presenta resultado
  └─ gate humano: usuario acepta/rechaza el RFC
```

### Workflow 3: Backlog de implementación (SPEC → IMP)

```
Usuario ←→ spc-spec-director (conversación continua)
  ├─ Director explica → confirma → delega a spc-imp-backlog-slicer → presenta resultado
  ├─ Director explica → confirma → delega a spc-imp-task-detailer → presenta resultado
  ├─ Director explica → confirma → delega a spc-imp-coverage-auditor → presenta resultado
  └─ si hay gaps: Director los traslada al usuario → itera detailer → re-audit
```

### Workflow 4: Modo evolutivo con codebase

Reglas clave:
- `codebase/**` = **solo lectura**, as-is
- La spec puede describir to-be (cambio futuro)
- Afirmaciones técnicas relevantes requieren:
  - rutas `codebase/...` o Evidence Pack
  - o `OPENQ-###` si no se puede verificar

Flujo de discovery (opcional, orquestado por el Director):

1. **Post-intake:** si hay `codebase/` con contenido y no hay mapa → el Director propone discovery (rápido/profundo/saltar).
2. **Pre-redacción técnica:** si el writer necesita info para una sección (arquitectura, backend, datos, seguridad, infra) y no hay EP → el Director propone Evidence Pack focalizado.
3. **Post-implementación:** si las tareas Txx completadas afectan áreas documentadas en el mapa → el Director propone refresh del mapa.

En todos los casos, el usuario puede rechazar el discovery sin fricción. El flujo continúa normalmente.

---

## Buenas prácticas al usar agentes

1) **Director-first:** usa `spc-spec-director` como puerta única. El Director guía la conversación, pide confirmación antes de cada paso y traslada preguntas de los subagentes al usuario cuando es necesario. No hace falta saber qué fase toca.  
2) **Evidence Packs para precisión:** cuando algo es crítico (auth, permisos, datos, integraciones, operación), mejor Evidence Pack que suposición.  
3) **Respeta iteraciones cerradas:** si aparece mezcla de iteraciones, usa `/close-iteration` antes de seguir.  
4) **Verificación externa solo cuando sea necesaria:** si sin ella se inventaría, verifica y añade `### Fuentes` (URL + fecha + 1 línea). Si no se puede verificar, `OPENQ`.  
5) **RFC resume y enlaza:** no reemplaza la spec; la complementa.  
6) **IMP después de validar SPEC:** genera Txx cuando la spec está razonablemente estable y revisada.

---

## Errores frecuentes

1) **Invocar Writer sin plan:** Writer ejecuta `docs/spec/01-plan.md`. Si falta, el Director invocará Planner primero.  
2) **Inventar en lugar de OPENQ:** si falta info, `OPENQ-###`. El Director traslada esas preguntas al usuario.  
3) **Confundir Pxx con Txx:** Pxx = plan SPEC; Txx = tareas de implementación.  
4) **Limpiar manualmente plan mezclado:** usa `/close-iteration`.  
5) **RFC sin spec mínima:** produce RFC lleno de `OPENQ`. Mejor estabilizar spec primero.

---

## Referencias

### Documentación relacionada
- [50-sistema-ia.md](50-sistema-ia.md)
- [51-instructions.md](51-instructions.md)
- [53-prompts.md](53-prompts.md)
- [54-skills.md](54-skills.md)
- [70-operativa-diaria.md](70-operativa-diaria.md)

### Copilot instructions
- [../../.github/copilot-instructions.md](../../.github/copilot-instructions.md)

### Agentes (archivos)
- [../../.github/agents/spc-spec-director.agent.md](../../.github/agents/spc-spec-director.agent.md)
- [../../.github/agents/spc-spec-intake.agent.md](../../.github/agents/spc-spec-intake.agent.md)
- [../../.github/agents/spc-spec-planner.agent.md](../../.github/agents/spc-spec-planner.agent.md)
- [../../.github/agents/spc-spec-writer.agent.md](../../.github/agents/spc-spec-writer.agent.md)
- [../../.github/agents/spc-spec-reviewer.agent.md](../../.github/agents/spc-spec-reviewer.agent.md)
- [../../.github/agents/spc-rfc-writer.agent.md](../../.github/agents/spc-rfc-writer.agent.md)
- [../../.github/agents/spc-rfc-reviewer.agent.md](../../.github/agents/spc-rfc-reviewer.agent.md)
- [../../.github/agents/spc-imp-backlog-slicer.agent.md](../../.github/agents/spc-imp-backlog-slicer.agent.md)
- [../../.github/agents/spc-imp-task-detailer.agent.md](../../.github/agents/spc-imp-task-detailer.agent.md)
- [../../.github/agents/spc-imp-coverage-auditor.agent.md](../../.github/agents/spc-imp-coverage-auditor.agent.md)
