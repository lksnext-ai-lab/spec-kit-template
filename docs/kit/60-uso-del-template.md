# Uso del template (crear repo, clonar y arrancar una spec)

Este documento explica cómo usar `spec-kit-template` para crear una nueva especificación de proyecto, cómo trabajar con VS Code + Copilot y cómo mantener el repositorio de forma ordenada en un equipo.

> Nota: Este template está pensado para uso interno. Adapta nombres, permisos y normas de tu organización.

---

## 1) Crear un nuevo repositorio a partir del template

### Opción A — “Use this template” (recomendada)
1) En GitHub, abre el repositorio `spec-kit-template`.
2) Pulsa **Use this template** → **Create a new repository**.
3) Nombra el repo siguiendo una convención clara, por ejemplo:
   - `spec-<cliente>-<proyecto>`
   - `spec-<producto>-<mvp>`
4) Define visibilidad (normalmente **privado** en entorno corporativo).
5) Crea el repositorio.

Ventajas:
- copia la estructura completa (docs/spec + docs/kit + .github),
- deja todo listo sin scripts adicionales.

---

### Opción B — Script interno (alternativa)
Si tu equipo quiere estandarizar más (naming, etiquetas, permisos), se puede usar un script interno para crear repos desde el template mediante API/CLI, pero añade complejidad de mantenimiento.

Recomendación:
- empezar con Opción A,
- y solo migrar a script cuando haya necesidad real.

---

## 2) Clonar en local y abrir en VS Code

Ejemplo (Windows / PowerShell):

```powershell
cd C:\Dev
git clone <URL-del-nuevo-repo>
cd <carpeta-del-repo>
code .
````

---

## 3) Pre-requisitos de VS Code + Copilot

Recomendado:

* VS Code actualizado
* Git configurado
* GitHub Copilot habilitado
* Acceso a Copilot Chat en el repo

Opcional (pero muy útil):

* extensión de Markdown (lint, preview mejorado)
* extensión de MkDocs si el equipo la usa (no imprescindible)

---

## 4) Arranque controlado de una nueva especificación

### Paso 1 — Ejecutar `/new-spec`

En Copilot Chat:

* Ejecuta `/new-spec` y responde a la entrevista mínima.
* El resultado debe actualizar/crear:

  * `docs/spec/00-context.md`
  * `docs/spec/index.md`
  * `docs/spec/95-open-questions.md` (si aplica)

Objetivo:

* dejar la spec “arrancada” con alcance y terminología mínima,
* sin inventar datos.

---

### Paso 2 — Planificar la primera iteración con `/plan-iteration`

Ejecuta `/plan-iteration` para actualizar:

* `docs/spec/01-plan.md`

Objetivo:

* definir 5–15 tareas atómicas con DoD,
* y una lista clara de entregables en `docs/spec/**`.

---

### Paso 3 — Redactar siguiendo el plan con `/write-from-plan`

Ejecuta `/write-from-plan` para:

* completar las tareas,
* actualizar trazabilidad (`docs/spec/02-trazabilidad.md`) al mínimo vivo,
* registrar OPENQ/TODO/DECISION según aparezcan.

---

### Paso 4 — Revisión crítica con `/review-and-adr`

Ejecuta `/review-and-adr` para:

* generar `docs/spec/97-review-notes.md`,
* crear OPENQ/TODO si procede,
* y crear ADRs automáticamente cuando existan `DECISION:` sin ADR enlazado.

---

## 5) Trabajo diario (iteraciones)

Ciclo recomendado:

1. `/plan-iteration` → plan corto y verificable
2. `/write-from-plan` → ejecutar tareas
3. `/review-and-adr` → revisión + ADR
4. Iterar (volver al Writer o planificar I02)

Buenas prácticas:

* Mantener iteraciones pequeñas (mejor varias rondas cortas).
* Evitar “reescrituras masivas”.
* Mantener `OPENQ` y `TODO` al día.

---

## 6) Recomendación de flujo Git (equipo)

### Opción simple (equipo pequeño)

* Commits directos a main con mensajes claros por iteración.
* Revisión ligera manual antes de mezclar cambios grandes.

### Opción recomendada (equipo mediano)

* Rama por iteración o por bloque:

  * `iter/I01`
  * `feature/fr-mvp`
  * `review/adr-decisions`
* Pull Request con checklist (si existe plantilla).
* Un revisor (mínimo) antes de merge.

---

## 7) Qué se edita y qué no (recordatorio)

Por defecto:

* Sí: `docs/spec/**`
* Sí (si hace falta): `docs/assets/**`
* No: `docs/kit/**` (salvo petición explícita)
* Cambios en `.github/**` deben tratarse como cambios de plataforma (revisar con cuidado).

---

## 8) Checklist de “spec lista para compartir”

Antes de compartir una especificación:

* `docs/spec/00-context.md` está claro (IN/OUT, roles, restricciones).
* FR con criterios verificables y estados.
* NFR con métricas/validación.
* UI con estados mínimos.
* Backend con catálogo de errores y authz.
* Seguridad + infra con operación real.
* Trazabilidad mínima actualizada.
* `docs/spec/97-review-notes.md` sin bloqueantes abiertos.
* `OPENQ` y `TODO` revisados (y marcados como aceptados si quedan abiertos).

---

## 9) Siguiente lectura recomendada

* Operativa diaria: `docs/kit/70-operativa-diaria.md`
* Previsualización en navegador: `docs/kit/80-previsualizacion-mkdocs.md`
* FAQ/troubleshooting: `docs/kit/95-faq-y-troubleshooting.md`
