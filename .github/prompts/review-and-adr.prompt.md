---
name: review-and-adr
description: Revisión crítica + creación automática de ADRs al detectar DECISION sin ADR enlazado. Registra notas y genera TODO/OPENQ cuando proceda.
---

Objetivo
Revisar la especificación con ojos críticos, dejar feedback accionable y crear ADRs automáticamente para decisiones pendientes.

Reglas
- No reescrituras masivas.
- Sí ediciones mínimas y seguras: marcar TODO/OPENQ/RISK/DECISION, enlazar ADRs, correcciones pequeñas.
- El resultado principal es `docs/spec/97-review-notes.md`.
- No modificar `docs/kit/**` salvo solicitud explícita del usuario.

Checklist de revisión (obligatorio)
- Coherencia: `00-context` ↔ FR/NFR ↔ conceptualización ↔ UI ↔ arquitectura ↔ datos ↔ backend/frontend ↔ seguridad ↔ infra
- Calidad FR: criterios de aceptación verificables + prioridad/estado
- Calidad NFR: objetivos medibles o verificación definida
- Trazabilidad: `docs/spec/02-trazabilidad.md` actualizado mínimamente
- Operación: observabilidad, backups/DR, secretos, accesos, auditoría

Actualizar `docs/spec/97-review-notes.md`
- Rellena: Bloqueantes, Contradicciones, Ambigüedades, Riesgos, Sugerencias
- Cada nota debe incluir:
  - Severidad (Alta/Media/Baja)
  - Dónde aplica (archivo/sección)
  - Por qué importa
  - Cambio sugerido
  - Enlace a TODO/OPENQ/ADR si se crea

Crear OPENQ/TODO si procede
- Si falta información clave: añade `OPENQ-###` en `docs/spec/95-open-questions.md` (siguiente número libre).
- Si hay trabajo pendiente concreto: añade `TODO-###` en `docs/spec/96-todos.md` (siguiente número libre).

Auto-ADR (obligatorio)
Para cada `DECISION:` detectada en documentos de la especificación (`docs/spec/*.md` excluyendo `docs/spec/adr/**`):
1) Si ya hay referencia a un ADR en esa sección, NO crear otro (solo proponer completar si está incompleto).
2) Si NO hay ADR asociado:
   - Determina el siguiente ID disponible mirando `docs/spec/adr/` (ADR-0001, ADR-0002…).
   - Crea `docs/spec/adr/ADR-####-<slug>.md` usando `docs/spec/adr/ADR-0001-template.md`.
     - Estado inicial: Propuesto
     - Incluye mínimo: contexto, drivers (NFR/restricciones), 2 opciones, decisión (o “pendiente”), consecuencias, impacto operativo, plan de adopción.
   - Si falta info para decidir: añade `OPENQ:` en el ADR y crea/actualiza la OPENQ en `docs/spec/95-open-questions.md`.
- Enlaza el ADR desde el documento origen:
  - Si editas un documento en `docs/spec/`, usa enlace relativo **sin `./`**:
    ```txt
    DECISION: ... (ver ADR-#### en adr/ADR-####-<slug>.md)
    ```
  - Nunca uses rutas relativas dentro de `.github/**` (prompts/agentes): ahí siempre rutas desde raíz (`docs/spec/...`).


Trazabilidad
- Si la decisión afecta a FR/UI/API/Datos y se conoce el vínculo, actualiza `docs/spec/02-trazabilidad.md` columna ADR.
- Si no se conoce, añade TODO en la fila correspondiente o crea TODO en `docs/spec/96-todos.md`.

Salida en el chat (resumen)
- Notas clave (bloqueantes primero)
- ADRs creados (IDs + archivos)
- OPENQ/TODO creados (IDs)
- Siguiente acción: volver al Writer para aplicar mejoras
