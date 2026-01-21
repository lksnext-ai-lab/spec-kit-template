# UI Spec (pantallas y flujos)

> Objetivo: especificar pantallas, navegación y comportamiento.
> No es diseño visual final, pero sí define lo necesario para implementar con coherencia.

## 1. Principios de UX/UI (alto nivel)

- Principio 1: TODO
- Principio 2: TODO
- Accesibilidad (mínimos): TODO
- Responsive: TODO

## 2. Convenciones

- ID de pantalla: `UI-###`
- Si hay estados relevantes: define “Estados” (vacío, cargando, error, sin permisos, etc.)
- Si una pantalla soporta acciones importantes: define validaciones y mensajes.

## 3. Mapa de pantallas

| UI | Nombre | Roles | Objetivo | Entradas/Salidas | FR relacionados | Notas |
|---|---|---|---|---|---|---|
| UI-001 | TODO | TODO | TODO | TODO | FR-001 | TODO |

## 4. Especificación por pantalla

### UI-001 — TODO (Nombre)

- **Propósito**: TODO
- **Roles**: TODO
- **Entrada (cómo se llega)**: TODO (desde qué pantallas/links)
- **Componentes / secciones**:
  - Sección A: TODO
  - Sección B: TODO
- **Acciones**:
  - Acción 1: TODO (validaciones, permisos)
  - Acción 2: TODO
- **Reglas de visibilidad**:
  - TODO (según rol/estado)
- **Estados**:
  - Cargando: TODO
  - Vacío: TODO
  - Error: TODO
  - Sin permisos: TODO
- **Mensajes / microcopy** (si aplica):
  - TODO
- **Analítica / eventos UX** (opcional):
  - TODO
- **FR relacionados**: FR-XXX
- **Notas**:
  - TODO / OPENQ / RISK / DECISION

## 5. Flujos de navegación

### NAV-001 — TODO

- **Inicio**: UI-XXX
- **Pasos**: UI-AAA → UI-BBB → UI-CCC
- **Variantes**: TODO
- **FR relacionados**: FR-XXX

## 6. Consideraciones de diseño (sin “pintar pantallas”)

- Estilo general: TODO (minimalista, corporativo, etc.)
- Consistencia: componentes reutilizables, patrón de formularios, etc.
- Performance percibida: skeletons, paginación, etc.

---

Referencia: [Conceptualización](./20-conceptualizacion.md) · [Arquitectura](./40-arquitectura.md)
