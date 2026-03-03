---
name: new-spec
description: Arranca una nueva especificación en modo conversacional (2 preguntas por turno). Entrevista mínima, rellena contexto y abre OPENQ iniciales (sin escribir FR/NFR todavía).
---

# new-spec

## Objetivo

Arrancar una especificación nueva con **contexto mínimo real** para evitar inventar y permitir planificación inmediata.  
Este prompt **NO** redacta FR/NFR completos ni crea ADRs.

Salida principal:
- `docs/spec/00-context.md` (mínimo viable)
- `docs/spec/95-open-questions.md` (OPENQ iniciales, según modo)

---

## Parámetros opcionales

- `OPENQ_MODE` (default `write`):
  - `write`: crea/actualiza `docs/spec/95-open-questions.md`
  - `link-only`: no escribe el archivo; propone OPENQs en el chat
- `MAX_TOTAL_QUESTIONS` (default `12`): límite duro total (CORE + aclaraciones)
- `CONFIRM_EACH_ROUND` (default `true`): pedir confirmación para pasar a la siguiente ronda

---

## Reglas duras

- No inventes requisitos ni decisiones.
- No redactes FR/NFR completos todavía.
- Variabilidad controlada: cubre siempre las **4 rondas CORE** (8 preguntas CORE) en el orden indicado.
- Haz **máximo 2 preguntas CORE por turno** y espera respuesta antes de continuar.
- Tras cada respuesta, puedes hacer **hasta 2 repreguntas** SOLO si:
  - hay ambigüedad/contradicción,
  - es una decisión de alto impacto,
  - bloquea definir IN/OUT o MVP,
  - o el riesgo de inventar es alto.
- Presupuesto anti-bucle: máximo **12 preguntas** en total (8 CORE + hasta 4 aclaraciones).  
  Si se agota: registra OPENQ y cierra.
- Ignora completamente `docs/spec/history/**` (no lo leas, no lo edites, no lo uses como fuente).

---

## Modo “spec nueva” vs “ajuste incremental”
Antes de preguntar, decide:
- **Spec nueva** si `docs/spec/00-context.md` no existe o está casi vacío.
- **Ajuste** si ya existe contenido relevante.

Regla (ajuste):
- No reescribas `00-context.md` entero: añade/corrige solo secciones concretas.
- No elimines OPENQs existentes: añade nuevas o ajusta impacto/estado.

---

## Modo conversacional (obligatorio)

Después de cada respuesta del usuario:

1) Resume lo entendido en 3–6 bullets (sin inventar).  
2) Identifica:
   - **OPENQ** si falta información relevante para evitar inventar o fijar IN/OUT/MVP.
   - **DECISION** si hay una elección de alto impacto (seguridad, auth, multi-tenant, despliegue, integraciones críticas, etc.).
3) Registra OPENQ/DECISION según política (ver abajo).
4) Si procede, haz 0–2 repreguntas (máximo).
5) Si `CONFIRM_EACH_ROUND=true`: pregunta explícitamente: **“¿Sigo con las siguientes 2 preguntas?”**  
   Solo si el usuario confirma, continúa.

Si el usuario no puede responder una pregunta:
- Registra OPENQ y continúa (no bloquees el arranque).

---

## Rondas CORE (orden estable, wording adaptable)

### Ronda 1 — Marco + éxito
1) ¿Qué se va a construir y para quién (usuario principal / segmento)?
2) ¿Qué problema resuelve y cómo sabremos que va bien (señales o métricas, si existen)?

### Ronda 2 — Alcance + roles/decisión
1) ¿Qué entra en el MVP y qué queda explícitamente fuera (OUT), y qué sería “más adelante”?
2) ¿Cuáles son los roles principales (alto nivel) y quién toma decisiones cuando haya dudas?

### Ronda 3 — Datos/compliance + integraciones
1) ¿Qué datos se tratarán y hay datos sensibles/compliance (RGPD, auditoría, etc.)?
2) ¿Qué integraciones externas son obligatorias y hay restricciones (APIs, SFTP, mensajería, etc.)?

### Ronda 4 — Restricciones técnicas + riesgos
1) ¿Hay restricciones técnicas (cloud/on-prem, lenguaje, stack, proveedor preferido)?
2) ¿Riesgos o limitaciones conocidas (tiempo, presupuesto, dependencias, equipo)?

---

## Política OPENQ vs DECISION (consistencia)

### Crear OPENQ si…
- falta un dato que cambia IN/OUT o MVP,
- falta un dato que cambia seguridad/compliance,
- falta un dato que cambia integraciones/contratos,
- o el riesgo de inventar es alto.

Contenido mínimo de una OPENQ:
- Contexto
- Impacto (Bajo/Medio/Alto)
- Qué bloquea (doc/tarea/fase)
- Qué falta para cerrarla

### Marcar DECISION si…
- hay una elección que afecta arquitectura/seguridad/datos/operación,
- existen alternativas razonables.

Regla:
- `DECISION:` NO crea ADR aquí.
- Si faltan drivers o info → crea OPENQ asociada.

---

## Acciones tras obtener respuestas (al finalizar el intake)

### 1) Actualiza `docs/spec/00-context.md` (mínimo viable)
Debe incluir (mínimo):
- Resumen ejecutivo
- Problema/oportunidad
- Objetivos (idealmente `OBJ-01..`)
- Alcance IN/OUT + no-objetivos
- MVP vs futuro (si aplica)
- Stakeholders/roles alto nivel + decisores
- Datos y compliance (si aplica)
- Integraciones conocidas
- Restricciones y supuestos
- Riesgos/limitaciones conocidas

> Si ya existe: edita solo lo necesario y evita reordenar secciones.

### 2) Actualiza `docs/spec/95-open-questions.md` (según OPENQ_MODE)
- `OPENQ_MODE=write`: añade `OPENQ-###` con el siguiente número libre.
- `OPENQ_MODE=link-only`: no escribas el archivo; lista OPENQs propuestas en el chat.

### 3) Señaliza `DECISION:` (si aplica)
- Añade `DECISION:` en el documento más cercano (normalmente `00-context.md`).
- NO crees ADR aquí.

---

## Salida en el chat (al cerrar)

- Qué se actualizó (lista de archivos)
- Lista de OPENQ creadas o propuestas
- DECISIONs señalizadas (archivo/sección)
- Siguiente acción canónica:
  - ejecutar `/plan-iteration` (o usar el agente `spc-spec-planner`)
