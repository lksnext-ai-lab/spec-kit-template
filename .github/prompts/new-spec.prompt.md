---
name: new-spec
description: Arranca una nueva especificación: entrevista mínima, rellena contexto y abre OPENQ iniciales (sin escribir FR/NFR todavía).
---

Objetivo
Arrancar una especificación nueva con contexto real mínimo, sin inventar, y dejando abiertas las preguntas que condicionan requisitos/arquitectura.

Reglas duras
- No inventes requisitos ni decisiones.
- Máximo 8 preguntas.
- Si el usuario no puede responder, NO bloquees: registra OPENQ y continúa.
- No redactes FR/NFR completos todavía.

Preguntas (máximo 8, priorizadas)
1) ¿Qué se va a construir y para quién (usuario principal)?
2) ¿Qué problema resuelve y qué éxito se considera “bien” (criterios medibles si es posible)?
3) Alcance IN/OUT y qué es MVP vs “más adelante”.
4) Datos tratados y si hay datos sensibles/compliance (RGPD, auditoría, etc.).
5) Roles principales (alto nivel) y quién decide.
6) Integraciones obligatorias (sistemas externos) y restricciones.
7) Restricciones técnicas (cloud/on-prem, lenguaje, stack, etc.) si existen.
8) Riesgos/limitaciones conocidas (tiempo, presupuesto, dependencias).

Acciones tras obtener respuestas
1) Actualiza `docs/spec/00-context.md`:
   - Resumen ejecutivo (5–10 líneas)
   - Problema/oportunidad
   - Objetivos (idealmente OBJ-01..)
   - Alcance IN/OUT + no-objetivos
   - Stakeholders/roles alto nivel
   - Restricciones y supuestos
   - Integraciones conocidas
   - Riesgos iniciales
2) Actualiza `docs/spec/95-open-questions.md`:
   - Añade OPENQ-### para toda incertidumbre relevante.
   - Asigna Impacto (Bajo/Medio/Alto) y qué bloquea (doc o tarea futura).
   - ID: usa el siguiente número libre mirando la tabla (OPENQ-001, OPENQ-002…).
3) Si detectas una decisión fuerte (auth, multi-tenant, mensajería, despliegue, etc.):
   - añade un marcador `DECISION:` en el documento más cercano (contexto/seguridad/arquitectura),
   - y crea una OPENQ si falta información.
   - NO crees ADR aquí.

Salida en el chat (resumen)
- Qué se actualizó (lista de archivos)
- Lista de OPENQ creadas (IDs)
- Siguiente acción sugerida: ejecutar `/plan-iteration` o usar el agente Planner.
