# Copilot instructions

Este documento explica qué son las **Copilot Instructions** en `spec-kit-template`, qué problema resuelven y cómo deben redactarse y mantenerse.

---

## Qué son

Las **Copilot Instructions** son el conjunto de reglas globales del repositorio que guían a Copilot (y a los agentes/prompt files) cuando trabajan en este proyecto.

En este template viven en:

- `.github/copilot-instructions.md`

Actúan como el “marco de trabajo” del sistema:
- definen el **alcance** (qué se puede modificar y qué no),
- establecen **principios** (no inventar, consistencia, trazabilidad),
- fijan **convenciones** (IDs y marcadores),
- y describen el **proceso** Plan → Write → Review → Iterate.

---

## Qué problema resuelven

Sin un conjunto de reglas globales, la salida de IA tiende a ser:
- inconsistente entre sesiones/autores,
- demasiado creativa (inventar detalles),
- poco operativa (texto largo y poco verificable),
- y con riesgo de tocar archivos que no deberían tocarse.

Las instructions resuelven esto imponiendo:
- un estándar único de calidad,
- un lenguaje y tono profesional,
- un mecanismo explícito de dudas (OPENQ) y trabajo pendiente (TODO),
- y una separación estricta entre `docs/spec/**` y `docs/kit/**`.

---

## Qué deben contener (mínimo recomendado)

Una buena `copilot-instructions.md` debe incluir:

1) **Propósito del repositorio**
   - qué se produce (spec en Markdown)
   - cómo se trabaja (ciclo iterativo)

2) **Reglas de alcance (cortafuegos)**
   - qué carpetas se editan por defecto (normalmente `docs/spec/**`)
   - qué carpetas no se tocan (normalmente `docs/kit/**`)

3) **Principios**
   - no inventar
   - consistencia
   - trazabilidad mínima
   - decisiones visibles (ADR)

4) **Mapa de artefactos y responsabilidades**
   - lista de documentos de `docs/spec/` y para qué sirven

5) **Convenciones**
   - IDs (FR/NFR/UI/API/OPENQ/TODO/ADR)
   - marcadores permitidos (TODO/OPENQ/RISK/DECISION)

6) **Reglas de calidad**
   - FR con criterios verificables
   - NFR con métrica o verificación
   - UI con estados mínimos
   - backend con validaciones/errores/authz
   - seguridad/infra con operación real

7) **Proceso obligatorio**
   - Planificar → Redactar → Revisar → Iterar

8) **Reglas de enlaces**
   - en `.github/**` rutas desde raíz
   - en `docs/spec/**` enlaces relativos permitidos

---

## Cómo se relacionan con agentes, prompts y skills

- **Instructions**: marco global y obligatorio.
- **Agentes**: aplican el marco desde su rol (planner/writer/reviewer).
- **Prompts**: procedimientos que deben respetar el marco.
- **Skills**: patrones de calidad que complementan, pero no sustituyen, las instructions.

Regla práctica:
> Si una norma afecta al comportamiento global del repo, va en instructions.  
> Si es un procedimiento repetible, va en un prompt file.  
> Si es un rol, va en un agente.  
> Si es “cómo redactar X con calidad”, va en un skill.

---

## Buenas prácticas de mantenimiento

### Cambios pequeños y versionados
- Cambiar instructions debe considerarse un cambio “de sistema”.
- Preferir PRs y revisión por otra persona.
- Explicar el “por qué” del cambio en el commit/PR.

### Evitar duplicidad
- No repetir reglas en muchos sitios.
- Referenciar instructions desde otros documentos (kit) si hace falta.

### Mantenerlo accionable
- Reglas claras, operativas y comprobables.
- Evitar lenguaje ambiguo (“mejor”, “bonito”, “correcto”) sin criterio.

---

## Errores frecuentes (y cómo evitarlos)

- **Permitir inventar**: no definir OPENQ como salida estándar ante falta de info.
- **No separar spec vs kit**: olvidar el cortafuegos `docs/spec/**` vs `docs/kit/**`.
- **Rutas relativas en `.github/**`**: causan errores de “file not found”.
- **Reglas demasiado largas**: si crece mucho, mover detalles al kit y dejar en instructions lo esencial.

---

## Referencias internas
- Archivo real de reglas: `.github/copilot-instructions.md`
- Visión general del sistema: `docs/kit/50-sistema-ia.md`
- Prompts: `docs/kit/53-prompts.md`
- Agentes: `docs/kit/52-custom-agents.md`
- Skills: `docs/kit/54-skills.md`
