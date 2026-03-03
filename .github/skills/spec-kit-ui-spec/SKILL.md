---
name: spec-kit-ui-spec
description: "Define o revisa la UI spec en docs/spec/30-ui-spec.md: mapa de pantallas/diálogos, flujos, acciones, permisos, validaciones, estados y trazabilidad UI↔FR. Sin inventar; referenciar backend/datos solo como links o TBD."
license: Proprietary
---

# Skill: UI Spec (spec-kit)

## Objetivo
Describir la UI a nivel **implementable** (comportamiento y reglas), evitando:
- “pixel perfect” (diseño visual),
- contratos técnicos detallados (API/payloads/modelos),
- decisiones de producto inventadas.

## Archivos que se pueden modificar
- Primario: `docs/spec/30-ui-spec.md`
- Si aplica:
  - `docs/spec/02-trazabilidad.md` (UI ↔ FR)
  - `docs/spec/95-open-questions.md` (gaps críticos)
  - `docs/spec/96-todos.md` (pendientes no bloqueantes)

> No tocar otros ficheros salvo petición explícita.

## Reglas duras (anti-deriva)
1) No inventar
- No asumir roles, reglas de visibilidad, campos, validaciones, textos, analítica o decisiones de producto si no están definidos.
- Si falta info que cambia el comportamiento: `OPENQ:` (enlazar a `95-open-questions.md`).

2) UI ≠ backend
- No definir endpoints, payloads ni modelos de datos aquí.
- Si una acción requiere backend: indicar `Backend: TBD` o link a `docs/spec/60-backend.md#...` si existe.

3) UI ≠ diseño visual
- No decidir layout pixel-perfect, CSS, tipografías, librerías o componentes concretos.
- Sí describir estructura a alto nivel: “listado con filtros”, “formulario en secciones”, “tabla con columnas…”.

4) Permisos explícitos (deny-by-default)
- Toda acción relevante debe indicar roles/permisos.
- Si no hay permiso definido → se considera NO permitido y/o `OPENQ`.

5) Validación
- Validación cliente: solo UX (si aplica).
- Validación definitiva: servidor (describir comportamiento esperado, no implementación).

## Convenciones
- Pantallas: `UI-###`
- Diálogos/modales: `DLG-###`
- Flujos: `FLOW-###` (opcional, recomendado en MVP)
- Para listas largas: indicar paginación/filtros a nivel de comportamiento (sin tecnología).

## Output contract (mínimos)
`docs/spec/30-ui-spec.md` debe contener:
1) Mapa UI/DLG (tabla)
2) Fichas UI/DLG (solo para lo relevante en MVP; el resto puede quedar como stub con TBD)
3) Flujos MVP (FLOW) con variantes principales
4) Sección final: Decisiones / OPENQ / TODO

## 1) Mapa UI/DLG (tabla obligatoria)
| ID | Nombre | Tipo | Roles | Objetivo | Entradas/Salidas | FR relacionados | Bloquea | Notas |
|---|---|---|---|---|---|---|---|---|

Regla: cada UI/DLG debe enlazar al menos 1 FR o justificar “transversal” (p.ej. login).

## 2) Plantilla por UI/DLG (usar nivel “completo” o “stub”)

### UI-### — Nombre (COMPLETA)
**Propósito:**  
**Roles:**  
**Entrada / salida:** cómo se llega / a dónde vuelve  
**Estructura (alto nivel):** secciones / elementos principales  

**Datos requeridos (conceptual):**
- Qué se muestra/edita (sin modelo técnico)

**Acciones (por acción):**
- Acción:
- Roles/permisos:
- Confirmación: sí/no (y cuándo)
- Validaciones (cliente): (si aplica) o `TBD`
- Resultado esperado:
  - éxito:
  - error:
- Backend: `TBD` o link a backend (si existe)

**Reglas de visibilidad (si aplica):**
- Por rol:
- Por estado/datos:

**Estados (mínimos):**
- Cargando:
- Vacío:
- Error:
- Sin permisos:
- (Opcional) Sin conexión / reintento:
- (Si aplica) Éxito/confirmación:

**Trazabilidad:**
- FR: FR-###, FR-### (obligatorio)

**Bloqueos y pendientes:**
- Bloquea MVP: Sí/No
- `OPENQ:` ...
- `TODO:` ...

### DLG-### — Nombre (COMPLETA)
(igual que UI, pero centrado en propósito + acciones + confirmaciones + estados)

### UI-### — Nombre (STUB)
Usar cuando aún no hay definición suficiente pero quieres mapearla:
- Propósito:
- Roles: `TBD`
- Acciones clave: `TBD`
- FR: FR-### (si aplica) o `TBD`
- Bloquea MVP: Sí/No
- `OPENQ/TODO:` ...

## 3) Flujos (FLOW) — recomendado para MVP
### FLOW-### — Nombre
- Inicio: UI-XXX
- Pasos: UI-A → UI-B → DLG-C → UI-D
- Variantes:
  - por rol/permisos
  - por error
  - por vacío
- FR relacionados:

## Permisos (opcional, recomendado si hay complejidad)
### Matriz PERM (por área o por pantalla)
| Recurso/Acción | Rol A | Rol B | Rol C | Notas |
| --- | --- | --- | --- | --- |

## Reglas para OPENQ / TODO
- OPENQ: falta info que cambia comportamiento o permisos (bloquea definición/aceptación).
- TODO: falta detalle que no bloquea MVP (pero debe cerrarse antes de “Validated”).

## DoD
- [ ] Mapa UI/DLG completo para el alcance actual (MVP como mínimo)
- [ ] Para cada UI/DLG MVP: ficha completa con acciones + permisos + estados mínimos
- [ ] Flujos MVP documentados con variantes principales
- [ ] Backend/datos referenciados solo como links o TBD (sin inventar contratos)
- [ ] Bloqueos declarados (OPENQ/TODO) sin “rellenar” información inexistente
