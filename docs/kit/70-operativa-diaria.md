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

### 1.3 Discovery del codebase (opcional, solo modo evolutivo)

Si trabajas sobre un proyecto existente (hay `codebase/` con contenido en el workspace):

- Verifica si existe `docs/spec/_inputs/codebase-map.md`.
  - Si no existe o tiene más de 60 días → considera ejecutar discovery (`spc-codebase-discovery` vía el Director).
  - Si existe y está actualizado → úsalo como referencia durante la redacción.
- Los Evidence Packs en `docs/spec/_inputs/evidence/EP-*` complementan el mapa con análisis detallados de áreas específicas.

El discovery es siempre opcional. El Director lo propondrá automáticamente cuando detecte las condiciones, pero el usuario puede rechazarlo.

Tipos de discovery:

- **Inicial:** mapa completo + Evidence Packs principales. Ideal al inicio.
- **Focalizado:** un Evidence Pack sobre un tema concreto. Útil antes de redactar arquitectura, backend, datos, etc.
- **Refresh:** actualización incremental tras implementar cambios en el codebase.
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

## 4) Generación de RFC (post-SPEC)

Cuando la spec está suficientemente estable, se puede generar un **RFC** como artefacto narrativo consolidado para stakeholders o revisión formal.

### 4.1 Cuándo generar un RFC

Genera un RFC cuando:

- El cambio afecta a datos/migraciones, auth/roles, compatibilidad de API, seguridad, integraciones externas o alcance/coste relevante.
- Necesitas presentar la propuesta a stakeholders en formato ejecutivo.
- El equipo requiere un artefacto narrativo consolidado desde la spec multi-archivo.

No es obligatorio para cada iteración: solo cuando el impacto justifique formalizarlo.

### 4.2 Flujo RFC: Write → Review → Iterate

1. **Write** → `spc-rfc-writer`:
   - Indicar: tema, RFC_ID (ej. `RFC-0001`), variante (architecture/proposal/decision)
   - Salidas: `docs/spec/rfc/<RFC_ID>-<slug>.md` + artefactos en `docs/spec/_inputs/rfc/<RFC_ID>/`

2. **Review** → `spc-rfc-reviewer`:
   - Verifica: sin invenciones, coherente con ADRs, evidencias, cobertura seguridad/operación/compatibilidad
   - Emite: PASS / WARN / FAIL con acciones priorizadas

3. **Iterate** según veredicto:
   - PASS → RFC aceptado
   - WARN/FAIL (cambios sustanciales) → volver a `spc-rfc-writer`
   - Solo correcciones menores → `spc-rfc-reviewer` con MODE=patch-rfc

Regla: el RFC complementa la spec; **no** la reemplaza. Si el RFC revela gaps en la spec, actualizar la spec primero.

---

## 5) Backlog de implementación / SPC-IMP (post-SPEC)

Cuando la spec está revisada y estabilizada, se puede convertir en un backlog canónico de tareas de implementación (T01..Tnn) con trazabilidad a SPEC/ADR/RFC.

### 5.1 Cuándo generar el backlog

Genera el backlog cuando:

- La spec tiene FR/NFR/UI/arquitectura razonablemente completos y revisados.
- El equipo va a planificar el desarrollo en CODEBASE.
- Se necesita trazabilidad explícita SPEC ↔ implementación.

No generar el backlog con la spec en borrador: producirá fichas llenas de bloqueantes.

### 5.2 Flujo SPC-IMP: Slice → Detail → Audit → Iterate

1. **Slice** → `spc-imp-backlog-slicer`:
   - Genera `docs/spec/spc-imp-backlog.md` con tareas T01..Tnn (IDs **estables**: nunca renumerar)
   - Crea stubs en `docs/spec/spc-imp-tasks/` si se solicita

2. **Detail** → `spc-imp-task-detailer`:
   - Detalla fichas `docs/spec/spc-imp-tasks/Txx.md` con DoD verificable y trazabilidad a FR/NFR/ADR/RFC
   - Marca `blocked` si una tarea depende de una decisión aún abierta en la spec

3. **Audit** → `spc-imp-coverage-auditor`:
   - Verifica cobertura: FR/NFR/ADR/RFC vs backlog + fichas
   - Emite PASS / WARN / FAIL con gaps y acciones correctivas

4. **Iterate** si hay gaps o fichas bloqueadas:
   - Resolver OPENQs/decisiones en SPEC primero
   - Volver a `spc-imp-task-detailer` para completar fichas
   - Re-auditar con `spc-imp-coverage-auditor`

Nota de IDs:

- **Pxx** = tareas del plan SPEC (`docs/spec/01-plan.md`)
- **Txx** = tareas de implementación (`docs/spec/spc-imp-tasks/`)
- No mezclar.

---

## 6) Flujo Git recomendado (día a día)

### 6.1 Commits

Mensajes recomendados (claros y pequeños):

- `I01: define FR MVP checkout`
- `I01: add NFR baseline + verification`
- `I01: review fixes + ADR-0003 auth strategy`
- `I01: close iteration (history snapshot + clean active files)`

### 6.2 Pull Requests (si aplica)

Si trabajáis con PR:

- 1 PR por iteración o por bloque
- incluir enlace a `docs/spec/01-plan.md`
- checklist de calidad (FR/NFR/UI/seguridad/infra/trazabilidad)

---

## 7) Roles sugeridos en equipo

No es obligatorio, pero ayuda:

- **Owner de spec** (responsable de consistencia global)
- **Reviewer técnico** (arquitectura/seguridad/infra)
- **Reviewer funcional** (FR/flujo/alcance)
- **Editor** (ejecuta el plan con el Writer)

---

## 8) Señales de alarma típicas

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

## 9) Checklist rápida diaria (5 minutos)

Antes de terminar el día:

- ¿He actualizado la trazabilidad mínima si he concretado algo?
- ¿He registrado OPENQ si he detectado falta de info?
- ¿He convertido trabajo pendiente en TODO?
- ¿He marcado DECISION si he detectado una decisión relevante?
- ¿El plan sigue representando la iteración activa (y no se está mezclando con otra)?

---

## 10) Operativa en modo evolutivo (con codebase existente)

Cuando trabajas en modo evolutivo (proyecto con codebase ya implementado):

### 10.1 Cuándo generar Evidence Packs

Genera un Evidence Pack (`/evidence-pack` o skill `evidence_pack`) cuando:

- Necesitas precisión técnica sobre autenticación, permisos, datos, integraciones u operación.
- Vas a tomar decisiones arquitectónicas que dependen del código existente.
- Necesitas verificar cómo funciona realmente algo crítico en el sistema.
- Quieres documentar una integración compleja o un flujo no obvio.

**No generar EP** para:

- Consultas rápidas (usa búsquedas directas en el codebase).
- Información obvia o ya mapeada en `codebase-map.md`.

### 10.2 Cómo verificar información externa

Para integraciones, SDKs, APIs, límites, compatibilidades, licencias:

1. **Obligatorio**: usar `playwright-mcp` (o fallback `chrome-devtools-mcp`) para verificar.
2. **Priorizar fuentes**: documentación oficial > repo oficial > releases > issues/discussions.
3. **Registrar fuentes**: siempre añadir subsección `### Fuentes` con:
   - URL + fecha (YYYY-MM-DD) + qué se extrajo (1 línea)
4. **Si no hay acceso a herramientas**: registrar `OPENQ-###` o pedir al usuario que aporte snapshots.

### 10.3 Cómo citar evidencia del codebase en la spec

Cuando afirmes algo técnico relevante en la spec:

- **Citar rutas concretas**:
  ```
  **EVIDENCE:** `codebase/src/auth/AuthController.ts` (endpoint login)
  ```
- **Referenciar Evidence Packs**:
  ```
  **EVIDENCE PACK:** `docs/spec/_inputs/evidence/EP-001-auth-flow.md`
  ```
- **Si hay decisión arquitectónica**: enlazar el EP en el ADR correspondiente.

### 10.4 Regla anti-invención (critical)

Si no encuentras evidencia suficiente tras buscar en el codebase:

1. **No completar con suposiciones**: dejar explícito que falta evidencia.
2. **Registrar `OPENQ-###`** en `docs/spec/95-open-questions.md` indicando:
   - Términos usados para buscar
   - Rutas revisadas
   - Hipótesis mínima (marcada explícitamente como *no confirmada*)

### 10.5 Nombres reales vs inventados

- **Siempre usar nombres reales** del codebase: módulos, paquetes, servicios, variables de entorno, funciones, clases.
- **Si no encuentras el nombre real**: marcar `OPENQ-###` en vez de inventar.

---

Siguiente lectura recomendada:

- Previsualización en navegador: `docs/kit/80-previsualizacion-mkdocs.md`
- FAQ/troubleshooting: `docs/kit/95-faq-y-troubleshooting.md`
