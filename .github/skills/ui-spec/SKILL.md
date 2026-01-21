---
name: ui-spec
description: Usa este skill para definir o revisar especificaciones de interfaz (UI) en docs/spec/30-ui-spec.md: mapa de pantallas, estados, acciones, validaciones, navegación y trazabilidad UI↔FR.
---

# Ui-spec — Especificación de interfaz (pantallas y flujos)


## Objetivo

Describir la UI de forma implementable sin diseñar “pixel perfect”:

- pantallas (qué hay y para qué),
- navegación/flujos,
- comportamientos y estados,
- reglas por rol y validaciones,
- trazabilidad con FR.


## Dónde aplicar

- `docs/spec/30-ui-spec.md` (principal)
- `docs/spec/02-trazabilidad.md` (UI ↔ FR)
- Referencias a conceptualización (roles/permisos) y backend (API)


## Convenciones

- Pantallas: `UI-###`
- Flujos de navegación: `NAV-###` (opcional)
- Acciones: describe permisos y validaciones (no solo “botón X”)
- Estados mínimos por pantalla:

  - Cargando
  - Vacío (sin datos)
  - Error (fallo)
  - Sin permisos


## Plantilla recomendada por pantalla

**UI-### — Nombre**

- Propósito (qué resuelve)
- Roles (quién puede verla/operarla)
- Entrada (cómo se llega) / Salida (a dónde va)
- Componentes o secciones (alto nivel)
- Acciones (por acción: permisos + validaciones + confirmaciones)
- Reglas de visibilidad (por rol/estado)
- Estados (cargando/vacío/error/sin permisos)
- Mensajes (microcopy mínimo, si aplica)
- Analítica UX (opcional)
- FR relacionados
- Notas (`OPENQ/RISK/DECISION/TODO`)


## Mapa de pantallas (tabla)

Debe existir una tabla tipo:

- UI | Nombre | Roles | Objetivo | Entradas/Salidas | FR relacionados | Notas


### Regla

- Cada pantalla debe enlazar al menos 1 FR (o justificar por qué no).


## Cómo describir flujos sin dibujar pantallas

Para cada flujo relevante:

- Inicio: UI-XXX
- Pasos: UI-A → UI-B → UI-C
- Variantes (por rol, por error, por datos vacíos)
- FR relacionados


## Buenas prácticas

- Evita “pantallas monstruo”: si una pantalla tiene demasiadas acciones,
  considera partir en subpantallas/diálogos.
- Valida en cliente pero asume validación definitiva en servidor.
- Declara reglas de permisos explícitas para evitar ambigüedad.
- Si una pantalla depende de datos o endpoints no definidos aún:

  - crea `TODO` o `OPENQ` y enlázalo en trazabilidad.


## Checklist rápido (revisión UI)

- [ ] Mapa de pantallas completo y numerado (UI-###).
- [ ] Cada pantalla tiene propósito y roles.
- [ ] Acciones con validaciones y permisos.
- [ ] Estados definidos (cargando/vacío/error/sin permisos).
- [ ] Navegación/flujo principal descrito.
- [ ] Trazabilidad UI ↔ FR actualizada.
