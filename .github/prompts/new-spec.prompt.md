---
name: new-spec
description: Arranca una nueva especificación en modo conversacional (2 preguntas por turno). Entrevista mínima, rellena contexto y abre OPENQ iniciales (sin escribir FR/NFR todavía).
---

# New-spec


## Objetivo

Arrancar una especificación nueva con contexto real mínimo, sin inventar, y
dejando abiertas las preguntas que condicionan requisitos/arquitectura, **en una
conversación natural** (2 preguntas por turno).


## Reglas duras

- No inventes requisitos ni decisiones.
- No redactes FR/NFR completos todavía.
- Mantén **variabilidad controlada**: cubre siempre las mismas 8 áreas (CORE),
  en el orden de rondas indicado.
- Haz **máximo 2 preguntas CORE por turno** y espera respuesta antes de
  continuar.
- Tras cada respuesta, puedes hacer **hasta 2 repreguntas** SOLO si:

  - hay ambigüedad/contradicción,
  - es una decisión de alto impacto,
  - bloquea definir IN/OUT o MVP,
  - o el riesgo de inventar es alto.

- Presupuesto anti “conversación infinita”: máximo **12 preguntas** en total
  (8 CORE + hasta 4 aclaraciones). Si se agota, registra OPENQ y cierra.
- Ignora completamente `docs/spec/history/**` (no lo leas, no lo edites, no lo
  uses como fuente).


## Modo conversacional (obligatorio)

Después de cada respuesta del usuario:

1. Resume lo entendido en 3–6 bullets (sin inventar).
2. Registra `OPENQ-###` si falta información relevante (con contexto + impacto +
   qué bloquea).
3. Si procede (según reglas), haz 0–2 repreguntas de aclaración.
4. Pregunta explícitamente: **“¿Sigo con las siguientes 2 preguntas?”**

Solo si el usuario confirma, continúa a la siguiente ronda.


## Rondas CORE (orden estable, wording adaptable)


### Ronda 1 — Marco + éxito

1. ¿Qué se va a construir y para quién (usuario principal / segmento)?
2. ¿Qué problema resuelve y cómo sabremos que va bien (señales o métricas, si
   existen)?


### Ronda 2 — Alcance + roles/decisión

3. ¿Qué entra en el MVP y qué queda explícitamente fuera (OUT), y qué sería “más
   adelante”?
4. ¿Cuáles son los roles principales (alto nivel) y quién toma decisiones
   cuando haya dudas?


### Ronda 3 — Datos/compliance + integraciones

5. ¿Qué datos se tratarán y hay datos sensibles/compliance (RGPD, auditoría,
   etc.)?
6. ¿Qué integraciones externas son obligatorias y hay restricciones (APIs, SFTP,
   mensajería, etc.)?


### Ronda 4 — Restricciones técnicas + riesgos

7. ¿Hay restricciones técnicas (cloud/on-prem, lenguaje, stack, proveedor
   preferido)?
8. ¿Riesgos o limitaciones conocidas (tiempo, presupuesto, dependencias,
   equipo)?


## Acciones tras obtener respuestas (al finalizar el intake)

1. Actualiza `docs/spec/00-context.md`:

   - Resumen ejecutivo (5–10 líneas)
   - Problema/oportunidad
   - Objetivos (idealmente OBJ-01..)
   - Alcance IN/OUT + no-objetivos
   - MVP vs futuro (si aplica)
   - Stakeholders/roles alto nivel + decisores
   - Datos y compliance (si aplica)
   - Integraciones conocidas
   - Restricciones y supuestos
   - Riesgos iniciales

2. Actualiza `docs/spec/95-open-questions.md`:

   - Añade OPENQ-### para toda incertidumbre relevante.
   - Asigna Impacto (Bajo/Medio/Alto) y qué bloquea (doc o tarea futura).
   - ID: usa el siguiente número libre mirando la tabla
     (OPENQ-001, OPENQ-002…).

3. Si detectas una decisión fuerte (auth, multi-tenant, mensajería, despliegue,
   pagos, etc.):

   - añade un marcador `DECISION:` en el documento más cercano
     (contexto/seguridad/arquitectura),
   - y crea una OPENQ si falta información.
   - NO crees ADR aquí.


## Salida en el chat (al cerrar)

- Qué se actualizó (lista de archivos)
- Lista de OPENQ creadas (IDs)
- Siguiente acción sugerida: ejecutar `/plan-iteration` o usar el agente Planner
