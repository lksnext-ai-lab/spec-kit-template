# Skills

Este documento describe qué son los **skills** en `spec-kit-template`, para qué sirven, cuáles incluye el repositorio y cómo ampliarlos.

---

## Qué es un “skill” en este repo

Un **skill** es un bloque reutilizable de instrucciones/patrones para producir contenido consistente y de calidad dentro de la especificación.

En lugar de repetir “cómo redactar FR” o “qué debe incluir seguridad” en cada conversación, el skill encapsula:

- estructura recomendada,
- checklist de calidad,
- convenciones,
- y criterios verificables.

---

## Dónde viven (estructura recomendada)

Los skills viven bajo:

- `.github/skills/`

Para diferenciar claramente lo que pertenece al **framework spec-kit** de lo que pertenece a un **proyecto concreto**, se usa esta convención:

- **Framework (spec-kit):**
  - `.github/skills/spec-kit-<skill-name>/SKILL.md`

- **Proyecto (workspace/project-specific):**
  - `.github/skills/<skill-name>/SKILL.md`
  - (no llevan prefijo `spec-kit-`)

> Nota: se mantiene un único nivel de carpetas bajo `.github/skills/` para maximizar compatibilidad y descubrimiento sencillo por herramientas.

---

## Para qué sirven

Los skills ayudan a:

1. **Normalizar calidad**
   - Evitan que cada persona redacte FR/NFR/UI de forma distinta.
   - Reducen ambigüedad y vaguedades.

2. **Acelerar redacción sin perder consistencia**
   - Proporcionan "plantillas mentales" para escribir bien a la primera.

3. **Reducir deuda documental**
   - Evitan huecos típicos (estados UI, catálogo de errores, operación, etc.).

4. **Mejorar revisión**
   - El reviewer puede evaluar contra una checklist conocida.

---

## Qué NO son

- No son “prompt files” ejecutables (no son comandos tipo `/new-spec`).
- No sustituyen a `copilot-instructions.md` (que gobierna el marco global).
- No “mandan” el proceso; guían la calidad cuando se redacta un tipo de contenido.

---

## Skills incluidos

### A) Skills del framework (spec-kit)

Estos skills forman parte del funcionamiento general del template y se consideran “plataforma”.

1) `spec-style`  
**Ruta:** `.github/skills/spec-kit-spec-style/SKILL.md`  
**Objetivo:** estilo y convenciones de redacción para toda la spec.

2) `requirements-fr`  
**Ruta:** `.github/skills/spec-kit-requirements-fr/SKILL.md`  
**Objetivo:** cómo redactar requisitos funcionales (FR).

3) `requirements-nfr`  
**Ruta:** `.github/skills/spec-kit-requirements-nfr/SKILL.md`  
**Objetivo:** cómo redactar requisitos no funcionales (NFR).

4) `ui-spec`  
**Ruta:** `.github/skills/spec-kit-ui-spec/SKILL.md`  
**Objetivo:** cómo especificar pantallas y flujos de UI sin diseñar visualmente.

5) `architecture`  
**Ruta:** `.github/skills/spec-kit-architecture/SKILL.md`  
**Objetivo:** cómo redactar arquitectura técnica y límites de sistema.

6) `security-baseline`  
**Ruta:** `.github/skills/spec-kit-security-baseline/SKILL.md`  
**Objetivo:** baseline de seguridad mínimo operativo.

7) `infra`  
**Ruta:** `.github/skills/spec-kit-infra/SKILL.md`  
**Objetivo:** infraestructura y operación (dev/pre/prod).

8) `codebase-scout`  
**Ruta:** `.github/skills/spec-kit-codebase-scout/SKILL.md`  
**Objetivo:** explorar `codebase/**` para construir un mapa técnico derivado (modo evolutivo).  
**Salida típica:** `docs/spec/_inputs/codebase-map.md`.

9) `evidence-pack`  
**Ruta:** `.github/skills/spec-kit-evidence-pack/SKILL.md`  
**Objetivo:** investigar un tema específico en `codebase/**` y generar un Evidence Pack con hallazgos sustentados.  
**Salida típica:** `docs/spec/_inputs/evidence/EP-###-<tema>.md`.

10) `rfc-proposal`  
**Ruta:** `.github/skills/spec-kit-rfc-proposal/SKILL.md`  
**Objetivo:** patrón de calidad para RFC/Proposal (español) como artefacto narrativo para stakeholders.

11) `spc-imp-task-definition`  
**Ruta:** `.github/skills/spec-kit-spc-imp-task-definition/SKILL.md`  
**Objetivo:** definir tareas atómicas de implementación (Txx) ejecutables para CODEBASE.

12) `export-docx`  
**Ruta:** `.github/skills/spec-kit-export-docx/SKILL.md`  
**Objetivo:** exportar documentación Markdown a DOCX.

---

### B) Skills específicos del proyecto (workspace/project-specific)

Estos skills existen porque este repositorio/proyecto lo necesita; **no forman parte del framework spec-kit**.

1) `generate-tool-permissions`  
**Ruta:** `.github/skills/generate-tool-permissions/SKILL.md`  
**Objetivo:** generar documentación sincronizada de permisos/herramientas desde definiciones del backend.

---

## Cómo se usan (práctica)

### Uso manual

Un autor puede leer el skill antes de redactar una sección (por ejemplo FR) y seguir su checklist.

### Uso por agentes/prompts

El sistema puede “invocar” el skill como referencia cuando:

- el Writer redacta FR/NFR/UI
- el Reviewer revisa calidad y detecta huecos típicos

En cualquier caso, los skills funcionan como:

- guía de estructura,
- checklist de calidad,
- y recordatorio de convenciones.

---

## Convenciones recomendadas para skills

Un `SKILL.md` suele incluir:

1) Propósito del skill
2) Cuándo usarlo
3) Protocolo de ejecución (pasos)
4) Validaciones / checks (conteos, formatos, criterios)
5) Anti-patrones (errores comunes)
6) Ejemplo breve (si aporta)

### Metadatos recomendados (front-matter)

Para que la clasificación no dependa solo del nombre de carpeta, se recomienda añadir un front-matter YAML mínimo en cada `SKILL.md`:

```yaml
---
category: spec-kit | project
scope: spec | rfc | imp | codebase | platform
status: stable | experimental | deprecated
---
```

---

## Cómo añadir un nuevo skill

1. Elegir categoría y nombre:

* framework: `spec-kit-<nombre-skill>`
* proyecto: `<nombre-skill>` (sin prefijo `spec-kit-`)

2. Crear carpeta:

* `.github/skills/<carpeta-skill>/`

3. Crear archivo:

* `.github/skills/<carpeta-skill>/SKILL.md`

4. Mantenerlo corto y accionable:

* plantillas claras
* checklists verificables

5. Actualizar esta guía (`docs/kit/54-skills.md`)

6. (Opcional) Referenciarlo desde prompts/agentes si afecta a un flujo frecuente

---
