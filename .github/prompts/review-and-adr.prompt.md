---
name: review-and-adr
description: Revisión crítica + creación automática de ADRs al detectar DECISION sin ADR enlazado. Registra notas y genera TODO/OPENQ cuando proceda.
---

Objetivo
Revisar la especificación con ojos críticos, dejar feedback accionable y crear ADRs automáticamente para decisiones pendientes.

Reglas
- No reescrituras masivas.
- Sí ediciones mínimas y seguras: marcar TODO/OPENQ/RISK/DECISION, enlazar ADRs, correcciones pequeñas.
- El resultado principal es `docs/97-review-notes.md`.

Checklist de revisión (obligatorio)
- Coherencia: `00-context` ↔ FR/NFR ↔ conceptualización ↔ UI ↔ arquitectura ↔ datos ↔ backend/frontend ↔ seguridad ↔ infra
- Calidad FR: criterios de aceptación verificables + prioridad/estado
- Calidad NFR: objetivos medibles o verificación definida
- Trazabilidad: `docs/02-trazabilidad.md` actualizado mínimamente
- Operación: observabilidad, backups/DR, secretos, accesos, auditoría

Actualizar `docs/97-review-notes.md`
- Rellena: Bloqueantes, Contradicciones, Ambigüedades, Riesgos, Sugerencias
- Cada nota debe incluir:
  - Severidad (Alta/Media/Baja)
  - Dónde aplica (archivo/sección)
  - Por qué importa
  - Cambio sugerido
  - Enlace a TODO/OPENQ/ADR si se crea

Crear OPENQ/TODO si procede
- Si falta información clave: añade `OPENQ-###` en `docs/95-open-questions.md` (siguiente número libre).
- Si hay trabajo pendiente concreto: añade `TODO-###` en `docs/96-todos.md` (siguiente número libre).

Auto-ADR (obligatorio)
Para cada `DECISION:` detectada en documentos `docs/*.md`:
1) Si ya hay referencia a un ADR en esa sección, NO crear otro (solo proponer completar si está incompleto).
2) Si NO hay ADR asociado:
   - Determina el siguiente ID disponible mirando `docs/adr/` (ADR-0001, ADR-0002…).
   - Crea `docs/adr/ADR-####-<slug>.md` usando `docs/adr/ADR-0001-template.md`.
     - Estado inicial: Propuesto
     - Incluye mínimo: contexto, drivers (NFR/restricciones), 2 opciones, decisión (o “pendiente”), consecuencias, impacto operativo, plan de adopción.
   - Si falta info para decidir: añade `OPENQ:` en el ADR y crea/actualiza la OPENQ en `docs/95-open-questions.md`.
   - Enlaza el ADR desde el documento origen:
     - En docs, usa un enlace relativo desde `docs/`: `./adr/ADR-####-<slug>.md`
     - Ejemplo de texto: `DECISION: ... (ver ADR-#### en docs/adr/ADR-####-<slug>.md)`

Trazabilidad
- Si la decisión afecta a FR/UI/API/Datos y se conoce el vínculo, actualiza `docs/02-trazabilidad.md` columna ADR.
- Si no se conoce, añade TODO en la fila correspondiente o crea TODO en `docs/96-todos.md`.

Salida en el chat (resumen)
- Notas clave (bloqueantes primero)
- ADRs creados (IDs + archivos)
- OPENQ/TODO creados (IDs)
- Siguiente acción: volver al Writer para aplicar mejoras
