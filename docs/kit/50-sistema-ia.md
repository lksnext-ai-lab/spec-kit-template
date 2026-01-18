# Sistema de IA del spec-kit: visión general

Este documento explica, de forma didáctica, cómo se utiliza la IA dentro de `spec-kit-template` para crear especificaciones técnicas en `docs/spec/`.

La idea no es “generar texto”, sino sostener un flujo de trabajo repetible y controlado:

**Plan → Write → Review → Iterate**

Para ello se combinan 4 tipos de componentes:

1) **Instructions** (reglas globales del repositorio)
2) **Custom Agents** (roles de trabajo)
3) **Prompt files** (comandos repetibles)
4) **Skills** (patrones reutilizables de calidad)

---

## 1) Los 4 componentes: qué son y para qué sirven

### 1.1 Instructions (Copilot instructions)
**Qué es:** un conjunto de reglas globales del repo: estilo, alcance, restricciones y proceso.  
**Dónde vive:** `.github/copilot-instructions.md`  
**Para qué sirve:** alinear la “forma de trabajar” del asistente y del equipo. Es el contrato base.

Ejemplos de lo que gobierna:
- “No inventar: si falta info → OPENQ”
- “No tocar docs/kit salvo petición”
- Convenciones de IDs (FR/NFR/UI/API/OPENQ/TODO/ADR)
- Calidad mínima por documento
- Proceso obligatorio Plan → Write → Review → Iterate

**Especificidad:** aplica siempre como “marco” cuando Copilot trabaja en este repo.

---

### 1.2 Custom Agents
**Qué es:** roles predefinidos con responsabilidad (intake, planner, writer, reviewer).  
**Dónde vive:** `.github/agents/`  
**Para qué sirve:** separar tareas cognitivas y evitar “mezclar todo en una única conversación”.

Ejemplos típicos:
- Intake: entrevista inicial + aterrizaje de contexto
- Planner: convierte estado actual en plan ejecutable
- Writer: ejecuta tareas del plan editando docs/spec
- Reviewer: revisión crítica + creación de ADRs

**Especificidad:** un agente aporta “personalidad operativa”: foco, checklist mental, límites y handoffs.

---

### 1.3 Prompt files (comandos)
**Qué es:** comandos reutilizables que ejecutas en Copilot Chat (ej. `/new-spec`).  
**Dónde vive:** `.github/prompts/`  
**Para qué sirve:** encapsular procedimientos repetibles para que el equipo ejecute siempre igual el flujo.

Prompt files típicos:
- `/new-spec` → arranque controlado de la spec
- `/plan-iteration` → crear/actualizar plan de iteración
- `/write-from-plan` → ejecutar el plan
- `/review-and-adr` → revisión crítica + ADRs automáticos
- `/close-iteration` → cierre de iteración + archivado en histórico y limpieza de ficheros activos

**Especificidad:** el prompt es “procedimiento”; el agente es “rol”. Un prompt puede usarse sin seleccionar agente.

---

### 1.4 Skills
**Qué es:** patrones reutilizables de redacción/calidad para secciones concretas (FR, NFR, UI, arquitectura, etc.).  
**Dónde vive:** `.github/skills/`  
**Para qué sirve:** normalizar la salida (estructura, vocabulario, checks) y reducir la variabilidad entre autores.

Ejemplos:
- Cómo redactar FR con criterios verificables
- Cómo redactar NFR con métrica/validación
- Qué incluir en seguridad baseline o infra operativa
- Cómo estructurar arquitectura e integraciones

**Especificidad:** un skill no “manda” el proceso; aporta “cómo hacerlo bien” dentro de una tarea.

---

## 2) Diferencias rápidas (cuándo usar cada uno)

- **Instructions**: “reglas del sistema” (siempre activas).  
- **Agents**: “quién trabaja” (rol / enfoque).  
- **Prompts**: “qué procedimiento ejecuto” (acciones repetibles).  
- **Skills**: “cómo redacto con calidad” (patrón reutilizable).

Una forma útil de verlo:
- Instructions = Constitución
- Agents = Roles
- Prompts = Playbooks
- Skills = Plantillas/patrones de calidad

---

## 3) Relaciones entre componentes

### 3.1 Jerarquía de influencia (de más global a más concreto)
1) **Instructions** (marco general y límites)
2) **Agent** (rol y responsabilidad)
3) **Prompt** (procedimiento específico)
4) **Skills** (patrones de calidad aplicables)

> Nota práctica: prompts y agentes deben respetar siempre las instructions; los skills refuerzan la calidad de la salida en cada documento.

---

## 4) Flujos típicos (cómo se usan en el día a día)

### 4.1 Flujo estándar recomendado
1) Ejecutar `/new-spec` (o agente Intake)  
2) Ejecutar `/plan-iteration` (o agente Planner)  
3) Ejecutar `/write-from-plan` (o agente Writer)  
4) Ejecutar `/review-and-adr` (o agente Reviewer)  
5) (Opcional pero recomendado) Ejecutar `/close-iteration` al cerrar la iteración  
6) Volver al Writer (aplicar mejoras) o planificar nueva iteración

Este flujo se repite por iteraciones (I01, I02, …).

### Nota operativa: estado vivo vs histórico
- `docs/spec/01-plan.md` representa **una única iteración activa**.
- `docs/spec/95-open-questions.md`, `96-todos.md` y `97-review-notes.md` deben mantenerse como **estado vivo** (solo lo relevante/pediente).
- Las iteraciones cerradas se archivan en `docs/spec/history/Ixx/` para evitar planes mezclados y ficheros cada vez más grandes.
- Por defecto, prompts y agentes deben **ignorar `docs/spec/history/**`** al planificar/redactar/revisar.

---

## 5) Diagrama: ciclo de trabajo y artefactos

```mermaid
flowchart TD
  U[Usuario] -->|/new-spec o Intake| C[docs/spec/00-context.md + index.md]
  C -->|/plan-iteration o Planner| P[docs/spec/01-plan.md]
  P -->|/write-from-plan o Writer| S[Actualiza docs/spec/* + trazabilidad]
  S -->|/review-and-adr o Reviewer| R[docs/spec/97-review-notes.md]
  R -->|si DECISION| A[docs/spec/adr/ADR-####-<slug>.md]
  R -->|si faltan datos| Q[docs/spec/95-open-questions.md]
  R -->|si trabajo pendiente| T[docs/spec/96-todos.md]
  R -->|cerrar iteración| X[/close-iteration]
  X --> H[docs/spec/history/Ixx/* (snapshots)]
  X -->|nueva iteración| P
```

(Nota: si Mermaid no se renderiza aún, se puede activar en MkDocs más adelante.)

---

## 6) Reglas operativas que evitan errores frecuentes

### 6.1 Separación Spec vs Kit

* La IA (prompts/agentes) debe editar **solo** `docs/spec/**`.
* `docs/kit/**` solo se modifica si el usuario lo solicita explícitamente.

### 6.2 Histórico de iteraciones (`docs/spec/history/**`)

* `docs/spec/history/**` contiene **snapshots cerrados por iteración**.
* Por defecto, prompts y agentes deben **ignorar** este directorio para planificar/redactar/revisar.
* Solo el prompt `/close-iteration` puede crear/actualizar contenido dentro de `docs/spec/history/**`.

### 6.3 Rutas en `.github/**`

* En prompts/agentes (`.github/**`) usar siempre rutas desde raíz: `docs/spec/...`.
* Evitar enlaces relativos tipo `./adr/...` en `.github/**` para no generar rutas rotas.

### 6.4 Rutas en `docs/spec/**`

* En la spec, enlaces relativos son correctos (por ejemplo `adr/ADR-0002-...md`).

---

## 7) Qué aporta este sistema frente a “un chat que redacta”

* Control del alcance por iteración (plan ejecutable).
* Calidad mínima reforzada por skills.
* Revisión crítica sistemática (review notes).
* Decisiones visibles (ADR) y trazables.
* Evita inventar: OPENQ como mecanismo de honestidad.
* Evolución versionada (Git) y navegable (MkDocs).
* Evita planes mezclados y “documentos bola de nieve”: histórico por iteración (`/close-iteration`).

---

## Lecturas recomendadas

* `51-instructions.md` (detalle de reglas globales)
* `52-custom-agents.md` (roles y handoffs)
* `53-prompts.md` (comandos y resultados esperados)
* `54-skills.md` (skills core y cómo ampliarlos)

Siguiente lectura recomendada: **`60-uso-del-template.md`**.

