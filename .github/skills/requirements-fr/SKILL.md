---
name: requirements-fr
description: Usa este skill cuando tengas que definir, refinar o revisar requisitos funcionales (FR) en docs/spec/10-requisitos-funcionales.md, incluyendo criterios de aceptación y priorización MVP.
---

# Requirements-fr — Requisitos funcionales (FR)


## Objetivo

Crear requisitos funcionales claros, no ambiguos y verificables, listos para:

- conceptualización (roles/flujos),
- UI spec (pantallas),
- backend (API/eventos),
- trazabilidad.


## Dónde aplicar

- `docs/spec/10-requisitos-funcionales.md` (principal)
- `docs/spec/02-trazabilidad.md` (enlaces FR↔UI↔API↔Datos↔ADR)
- `docs/spec/01-plan.md` (si un FR bloquea una iteración o requiere decisión)


## Convenciones FR

- ID: `FR-###` correlativo.
- Prioridad: `MVP` / `Should` / `Could`
- Estado: `Draft` / `Validated` / `Deprecated`


## Plantilla recomendada por FR

**FR-### — Título**

- Descripción (qué capacidad aporta)
- Actores/Roles
- Precondiciones (si aplica)
- Flujo principal (pasos)
- Alternativas/errores
- Criterios de aceptación (CA) verificables
- Prioridad y estado
- Trazabilidad (UI/API/Datos/ADR si existe)
- Observaciones (`OPENQ/RISK/DECISION/TODO`)


## Cómo escribir buenos criterios de aceptación

Reglas:

- Deben ser **observables** y **testeables**.
- Evita adjetivos (“fácil”, “intuitivo”, “rápido”) sin condición.
- Si hay performance, expresa umbral (p.ej., p95 < 2s) o remite a NFR.

Formato útil:

- **Dado** [contexto], **cuando** [acción], **entonces** [resultado].
- Incluye errores esperados cuando sea crítico.


## Ejemplos

✅ Bien:

- “Dado un usuario con rol ROL-001, cuando crea un registro válido, entonces el
  sistema lo guarda y muestra confirmación; si faltan campos obligatorios,
  muestra mensajes por campo.”

❌ Mal:

- “El usuario podrá crear registros fácilmente.”


## Priorización MVP (reglas prácticas)

- MVP: imprescindible para usar el sistema de punta a punta.
- Should: aporta valor, pero no bloquea operación básica.
- Could: nice-to-have o diferible.

Consejo:

- Si hay desacuerdo, crea `OPENQ` y propone 2 alternativas de MVP.


## Detección de duplicados y solapamientos

Antes de crear un FR nuevo:

- revisa si ya existe uno parecido (por título o actor/flujo).
- si se solapa, decide:

  - fusionar
  - separar por casos de uso
  - o marcar dependencias


## Trazabilidad mínima obligatoria

Por cada FR (al menos MVP):

- Añade una fila en `docs/spec/02-trazabilidad.md`.
- Si aún no hay UI/API/Datos, deja `TODO` en esas columnas.


## Checklist rápido (revisión FR)

- [ ] Título accionable (verbo + objeto).
- [ ] Descripción no ambigua.
- [ ] Roles/actores definidos.
- [ ] CA verificables.
- [ ] Prioridad y estado definidos.
- [ ] Trazabilidad mínima añadida.
- [ ] OPENQ/DECISION registradas si falta info.
