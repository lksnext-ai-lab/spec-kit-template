---
name: spec-style
description: Usa este skill cuando generes o edites cualquier documento de especificación en docs/spec/*.md. Define estilo, convenciones de IDs, enlaces, y el uso correcto de TODO/OPENQ/RISK/DECISION.
---

# Spec-style — Estilo y convenciones del spec-kit


## Objetivo

Asegurar que toda la documentación en `docs/spec/` sea **consistente, ejecutable
y fácil de revisar**.


## Idioma y tono

- Idioma principal: **español**.
- Tono: **profesional**, orientado a ejecución.
- Prioriza claridad sobre “prosa bonita”.


## Estructura recomendada

- Usa encabezados claros (H2/H3) y listas.
- Para catálogos (FR, NFR, UI, API, entidades): **tablas** + sección de detalle
  cuando sea necesario.
- Evita párrafos largos: divide en bullets.


## Markdown robusto (render/export)

### Encabezados

- Tras cualquier encabezado (`#`, `##`, `###`, ...) deja **una línea en blanco**.
- Excepción: si el siguiente contenido es otro encabezado inmediatamente.

### Listas y sublistas

- Usa `-` para bullets (no mezclar con `*`).
- Sublistas con **4 espacios por nivel**.

Ejemplo:

- Nivel 0
    - Nivel 1
        - Nivel 2

### Bloques de código (```)

Regla anti-roturas: si el bloque está dentro de una lista o “caja” (admonition),
debe ir:
1) precedido por **línea en blanco**, y
2) con el fence **indentado al nivel del contenedor**.

Ejemplo dentro de bullet:

- **Ejemplo:**

    ```json
    { "status": "CREATED" }
    ```

Ejemplo dentro de admonition (MkDocs Material):

!!! note
    Texto.

    ```json
    { "status": "CREATED" }
    ```

### Tablas

- Evita fences (```json/```bash) dentro de celdas: puede romper el render.
- Alternativas: mover el ejemplo fuera de la tabla o usar inline code corto.


## Convenciones de IDs

- FR: `FR-###` (correlativo, no reutilizable)
- NFR: `NFR-###`
- UI: `UI-###`
- API: `API-###`
- EVT (asíncrono): `EVT-###`
- OPENQ: `OPENQ-###`
- TODO: `TODO-###`
- ADR: `ADR-####`


### Reglas

- No reutilices IDs.
- Si dudas del siguiente ID: mira el último de la tabla correspondiente y suma
  1.


## Marcadores permitidos durante elaboración

- `TODO:` trabajo pendiente (si es relevante, también en `docs/spec/96-todos.md`)
- `OPENQ:` pregunta (si es relevante, también en `docs/spec/95-open-questions.md`)
- `RISK:` riesgo detectado
- `DECISION:` decisión pendiente (normalmente debe acabar en un ADR)


### Buenas prácticas

- Si un `OPENQ` bloquea una iteración, debe aparecer también en
  `docs/spec/01-plan.md`.
- Si un `DECISION` afecta a arquitectura/seguridad/integraciones/operación, debe
  terminar en ADR.


## Criterios de calidad (rápidos)

- FR:

  - criterios de aceptación **verificables**
  - prioridad (MVP/Should/Could)
  - trazabilidad (UI/API/Datos/ADR si aplica)

- NFR:

  - objetivo medible (SLO/SLI/umbral) o verificación explícita (prueba/evidencia)

- UI:

  - estados: cargando/vacío/error/sin permisos
  - reglas por rol

- Backend:

  - errores, validaciones, authz
  - síncrono/asíncrono claro

- Seguridad/Infra:

  - enfoque operativo (secretos, accesos, auditoría, backups/DR, observabilidad)


## Enlaces

- Dentro de `docs/spec/`: usa enlaces relativos.

  - Ejemplo desde `docs/spec/40-arquitectura.md` a un ADR:
    `./adr/ADR-0001-...md`

- En `.github/agents` y `.github/prompts`: usa rutas explícitas `docs/spec/...`
  (para evitar rutas relativas erróneas).


## Anti-patrones (evitar)

- “El sistema será rápido / seguro / escalable” sin umbral o verificación.
- Requisitos duplicados sin trazabilidad.
- Decisiones escondidas dentro de texto sin ADR.
- Cambios grandes sin reflejarlos en `docs/spec/02-trazabilidad.md` y sin notas
  en review.


## Mini-ejemplos


### Criterio de aceptación verificable (bien)

- “Dado X, cuando el usuario hace Y, entonces el sistema muestra Z en menos de
  2s (p95).”


### Vago (mal)

- “La pantalla debe ser intuitiva y rápida.”
