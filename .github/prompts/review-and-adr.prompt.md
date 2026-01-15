---
name: review-and-adr
description: Revisión crítica + creación automática de ADRs cuando detecta DECISION sin ADR enlazado.
---

Objetivo: revisar coherencia/calidad y crear ADRs para decisiones pendientes.

Instrucciones:
1) Revisa coherencia entre:
   Contexto ↔ FR/NFR ↔ Conceptualización ↔ UI ↔ Arquitectura ↔ Datos ↔ Backend/Frontend ↔ Seguridad ↔ Infra.
2) Actualiza docs/97-review-notes.md con notas accionables (bloqueantes, contradicciones, ambigüedades, riesgos, mejoras).
3) Si falta info: crea OPENQ-### en docs/95-open-questions.md.
4) Si hay trabajo pendiente: crea TODO-### en docs/96-todos.md.
5) Auto-ADR:
   - por cada DECISION: sin ADR enlazado, crea un fichero en docs/adr/ADR-####-<slug>.md usando la plantilla
   - enlaza el ADR desde el doc donde estaba el DECISION:
   - si falta info en la decisión, deja el ADR en “Propuesto” y crea OPENQ.

Usa rutas explícitas tipo docs/... (no enlaces relativos desde este prompt).
