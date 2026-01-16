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

En este template, los skills viven en:

- `.github/skills/<skill-name>/SKILL.md`

---

## Para qué sirven

Los skills ayudan a:

1) **Normalizar calidad**
- Evitan que cada persona redacte FR/NFR/UI de forma distinta.
- Reducen ambigüedad y vaguedades.

2) **Acelerar redacción sin perder consistencia**
- Proporcionan “plantillas mentales” para escribir bien a la primera.

3) **Reducir deuda documental**
- Evitan huecos típicos (estados UI, catálogo de errores, operación, etc.).

4) **Mejorar revisión**
- El reviewer puede evaluar contra una checklist conocida.

---

## Qué NO son

- No son “prompt files” ejecutables (no son comandos tipo `/new-spec`).
- No sustituyen a `copilot-instructions.md` (que gobierna el marco global).
- No “mandan” el proceso; guían la calidad cuando se redacta un tipo de contenido.

---

## Skills incluidos (core)

Los skills core actuales suelen cubrir las áreas clave de una especificación:

### 1) `spec-style`
**Objetivo:** estilo y convenciones de redacción para toda la spec.  
**Aporta:** tono profesional, estructura clara, uso de IDs y marcadores, evitar vaguedades.

### 2) `requirements-fr`
**Objetivo:** cómo redactar requisitos funcionales (FR).  
**Aporta:** estructura por FR-###, criterios de aceptación verificables, prioridad y estado.

### 3) `requirements-nfr`
**Objetivo:** cómo redactar requisitos no funcionales (NFR).  
**Aporta:** NFR-### medibles (SLO/SLI/umbrales) o verificación explícita, y relación con drivers.

### 4) `ui-spec`
**Objetivo:** cómo especificar pantallas y flujos de UI sin diseñar visualmente.  
**Aporta:** UI-###, estados mínimos (loading/empty/error/sin permisos), reglas por rol, validaciones.

### 5) `architecture`
**Objetivo:** cómo redactar arquitectura técnica y límites de sistema.  
**Aporta:** componentes/servicios, integraciones, responsabilidades, riesgos, y puntos de decisión.

### 6) `security-baseline`
**Objetivo:** baseline de seguridad mínimo operativo.  
**Aporta:** authn/authz, secretos, auditoría, amenazas, controles, compliance y operación real.

### 7) `infra`
**Objetivo:** infraestructura y operación (dev/pre/prod).  
**Aporta:** CI/CD, observabilidad, logging, backups/DR, configuración, despliegue y runbooks.

> Nota: el conjunto exacto puede variar según el repo; lo importante es mantener los “core” para consistencia.

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
3) Estructura recomendada (plantilla)
4) Checklist de calidad
5) Anti-patrones (errores comunes)
6) Ejemplo breve (si aporta)

---

## Cómo añadir un nuevo skill

1) Crear carpeta:
- `.github/skills/<nombre-skill>/`

2) Crear archivo:
- `.github/skills/<nombre-skill>/SKILL.md`

3) Mantenerlo corto y accionable:
- plantillas claras
- checklists verificables

4) Actualizar esta guía (`docs/kit/54-skills.md`):
- añadir el skill a la lista y explicar su objetivo

5) (Opcional) Referenciarlo desde prompts/agentes
- si el skill afecta a un flujo frecuente, merece referencia explícita.

Ejemplos de skills adicionales (según necesidades del equipo):
- `integration-patterns`
- `eventing-async`
- `data-governance`
- `testing-strategy`
- `observability`
- `performance-baseline`

---

## Buenas prácticas de mantenimiento

- No convertir skills en “mini-libros”: deben ser guías prácticas.
- Revisar skills cuando el equipo cambie su forma de trabajar.
- Versionar cambios en skills como cambios “de plataforma”.
- Evitar duplicar reglas globales: si es transversal, va a instructions.

---

## Referencias
- Visión general del sistema IA: `docs/kit/50-sistema-ia.md`
- Prompts: `docs/kit/53-prompts.md`
- Custom agents: `docs/kit/52-custom-agents.md`
- Reglas globales: `.github/copilot-instructions.md`
