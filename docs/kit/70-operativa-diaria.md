# Operativa diaria (cómo trabajar en una spec)

Este documento describe la rutina recomendada para mantener una especificación viva con `spec-kit-template`, minimizando deuda documental y maximizando consistencia entre personas.

---

## Principio general

La especificación se trabaja como un producto: en **iteraciones cortas** y con control de calidad.

Regla de oro:
- **Plan** manda (qué se hace y qué significa terminado)
- **Write** ejecuta (cambios concretos y trazables)
- **Review** controla calidad (feedback accionable + ADR)
- **Iterate** mejora (nuevas iteraciones con foco)

Nota operativa importante:
- `docs/spec/01-plan.md` representa **una única iteración activa** (evita mezclar I01/I02… en el mismo plan).
- Las iteraciones cerradas se archivan en `docs/spec/history/Ixx/` y, por defecto, se tratan como **solo lectura** para el día a día.

---

## 1) Ritual de inicio de iteración

### 1.1 Verificar que el plan corresponde a la iteración activa
Antes de redactar, asegúrate de que `docs/spec/01-plan.md` está actualizado para la iteración actual:

- iteración (Ixx) y estado (Draft/En curso/En revisión/Cerrado),
- objetivo (1 párrafo),
- alcance IN/OUT,
- tareas atómicas con DoD verificable,
- entregables explícitos.

Si el plan no existe o está desactualizado:
- ejecutar `/plan-iteration` (o usar el agente Planner).

Regla práctica:
- si el plan empieza a crecer demasiado, es señal de **dividir** en otra iteración, no de añadir más tareas.

---

### 1.2 Revisión rápida de “estado” (antes de escribir)
Antes de escribir, revisa:
- `docs/spec/95-open-questions.md` (qué bloquea y qué sigue abierto)
- `docs/spec/96-todos.md` (qué quedó pendiente / backlog vivo)
- `docs/spec/97-review-notes.md` (hallazgos del último review)

Objetivo:
- no duplicar trabajo,
- y no ignorar bloqueantes.

Importante:
- evita leer `docs/spec/history/**` para planificar o redactar. El histórico es referencia, no material “activo”.

---

## 2) Durante la redacción (Write)

### 2.1 Escribir “siguiendo el plan”
La redacción debe seguir las tareas del plan. Recomendación práctica:

- 1 tarea → 1 commit (si el equipo lo permite)
- o 2–3 tareas relacionadas → 1 commit

Evitar:
- saltar de documento en documento sin cerrar DoD
- “mejoras infinitas” fuera del alcance de la iteración

Si aparece trabajo relevante fuera del alcance:
- registrar `TODO-###` (ver 2.3) y seguir con el plan.

---

### 2.2 Cómo gestionar huecos de información (OPENQ)
Si falta información:
1) marca `OPENQ:` en el punto donde aparece (dentro del documento)
2) registra `OPENQ-###` en `docs/spec/95-open-questions.md` con:
   - contexto,
   - impacto,
   - qué bloquea,
   - propuesta de resolución.

Regla:
- no rellenar huecos con suposiciones “plausibles”.

---

### 2.3 Cómo gestionar trabajo pendiente (TODO)
Si aparece trabajo pendiente concreto fuera del alcance:
- crea `TODO-###` en `docs/spec/96-todos.md`.

Incluye:
- qué hay que hacer,
- dónde aplica,
- prioridad sugerida,
- y si depende de alguna OPENQ.

---

### 2.4 Cómo gestionar decisiones (DECISION → ADR)
Si aparece una decisión relevante:
- marca `DECISION:` en el punto donde se detecta,
- sin intentar “cerrarla” inventando.

Después:
- el reviewer la transformará en ADR con `/review-and-adr` (o agente Reviewer).

---

### 2.5 Mantener trazabilidad mínima
Cada vez que concretes:
- FR,
- UI,
- API/evento,
- datos,
- o decisión,

actualiza `docs/spec/02-trazabilidad.md` al mínimo razonable.

No hace falta perfección, pero sí:
- que exista vínculo básico,
- o un TODO explícito si falta.

---

## 3) Final de iteración (Review + cierre)

### 3.1 Ejecutar review
Al finalizar cambios:
- ejecutar `/review-and-adr` (o usar el agente Reviewer).

Objetivos del review:
- detectar inconsistencias,
- localizar vaguedades,
- forzar ADRs para decisiones relevantes,
- y registrar mejoras accionables.

Salida:
- `docs/spec/97-review-notes.md` actualizado,
- ADRs creados si procede,
- OPENQ/TODO actualizadas.

---

### 3.2 Decidir: continuar la iteración o cerrarla
Según el resultado del review:

- Si hay bloqueantes:
  - aplicar cambios con Writer (otra mini-ronda Write → Review)
- Si el scope crece o aparecen muchas tareas nuevas:
  - planificar otra iteración (Iyy) con `/plan-iteration`
  - (y evitar mezclarlo dentro del mismo plan)
- Si la iteración se considera lista (baseline estable o “lista para compartir”):
  - cerrar formalmente la iteración con `/close-iteration`.

---

### 3.3 Cerrar iteración con `/close-iteration` (recomendado)
Cuando la iteración se cierre, ejecuta `/close-iteration` para:

- archivar snapshots en `docs/spec/history/Ixx/` (plan + OPENQ + TODO + review notes),
- dejar `docs/spec/01-plan.md` preparado para la siguiente iteración (Iyy),
- limpiar `95/96/97` para mantenerlos como **estado vivo** y manejable.

Regla:
- `docs/spec/history/**` debe quedar “solo lectura” para prompts/agentes, salvo el cierre de iteración.

---

## 4) Flujo Git recomendado (día a día)

### 4.1 Commits
Mensajes recomendados (claros y pequeños):
- `I01: define FR MVP checkout`
- `I01: add NFR baseline + verification`
- `I01: review fixes + ADR-0003 auth strategy`
- `I01: close iteration (history snapshot + clean active files)`

### 4.2 Pull Requests (si aplica)
Si trabajáis con PR:
- 1 PR por iteración o por bloque
- incluir enlace a `docs/spec/01-plan.md`
- checklist de calidad (FR/NFR/UI/seguridad/infra/trazabilidad)

---

## 5) Roles sugeridos en equipo

No es obligatorio, pero ayuda:

- **Owner de spec** (responsable de consistencia global)
- **Reviewer técnico** (arquitectura/seguridad/infra)
- **Reviewer funcional** (FR/flujo/alcance)
- **Editor** (ejecuta el plan con el Writer)

---

## 6) Señales de alarma típicas

- El plan crece sin cerrar nada (plan ≈ mini-Jira)
- Hay muchas “DECISION” sin ADR
- FR sin criterios verificables
- NFR sin métrica/verificación
- UI sin estados mínimos
- Backend sin catálogo de errores/authz
- Seguridad/infra sin operación real
- Trazabilidad abandonada
- `95/96/97` crecen sin control y cuesta encontrar “lo vivo”

Si aparecen 2–3 señales, parar y:
- hacer un review,
- convertir huecos en OPENQ/TODO,
- replanificar,
- y si procede cerrar iteración con `/close-iteration`.

---

## 7) Checklist rápida diaria (5 minutos)

Antes de terminar el día:
- ¿He actualizado la trazabilidad mínima si he concretado algo?
- ¿He registrado OPENQ si he detectado falta de info?
- ¿He convertido trabajo pendiente en TODO?
- ¿He marcado DECISION si he detectado una decisión relevante?
- ¿El plan sigue representando la iteración activa (y no se está mezclando con otra)?

---

Siguiente lectura recomendada:
- Previsualización en navegador: `docs/kit/80-previsualizacion-mkdocs.md`
- FAQ/troubleshooting: `docs/kit/95-faq-y-troubleshooting.md`
