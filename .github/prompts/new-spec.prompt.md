---
name: new-spec
description: Arranca una nueva especificación: completa contexto mínimo, abre OPENQ iniciales y deja listo el handoff al Planner.
---

Objetivo: arrancar el repo de especificación con el mínimo contexto real, sin inventar.

Instrucciones:
1) Haz un máximo de 8 preguntas (prioriza: propósito/usuario, alcance IN/OUT, MVP, datos sensibles/compliance, integraciones, restricciones, criterios de éxito, roles, riesgos).
2) Con las respuestas, actualiza:
   - docs/00-context.md (resumen, objetivos, alcance, roles, restricciones/supuestos, referencias)
   - docs/95-open-questions.md (crea OPENQ-### para todo lo que falte o sea incierto)
3) NO redactes FR/NFR aún.
4) Si aparece una decisión fuerte, marca DECISION: en el documento adecuado (no crees ADR aquí).
5) Al final, sugiere pasar al Planner para crear docs/01-plan.md.

Usa rutas explícitas tipo docs/... (no enlaces relativos desde este prompt).
