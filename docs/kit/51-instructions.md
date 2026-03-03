# Copilot instructions

Este documento explica qué son las **Copilot Instructions** en `spec-kit-template`, qué problema resuelven y cómo deben redactarse y mantenerse.

---

## Qué son

Las **Copilot Instructions** son el conjunto de reglas del repositorio que guían a Copilot (y a los agentes/prompt files) cuando trabajan en este proyecto.

En este template se dividen en dos niveles:

### 1) Instrucciones globales (repo-wide)

- `.github/copilot-instructions.md`

Actúan como “marco general”:

- definen el **alcance** (qué se puede modificar y qué no),
- establecen **principios** (no inventar, consistencia, trazabilidad),
- fijan **convenciones** (IDs y marcadores),
- y describen el proceso Plan → Write → Review → Iterate.

### 2) Instrucciones por ruta (path-specific)

- `.github/instructions/*.instructions.md`

Afinan el comportamiento según el área del repositorio (SPEC, plataforma, codebase, etc.). Se aplican mediante `applyTo`.

En el estado actual del template:

- `spec.instructions.md` → aplica a `docs/spec/**`
- `platform.instructions.md` → aplica a `.github/**`
- `codebase.instructions.md` → aplica a `codebase/**` (si existe en el workspace)

> Nota: no existe un `kit.instructions.md`. La regla de “no modificar `docs/kit/**` salvo petición explícita” vive en las instrucciones globales.

---

## Qué problema resuelven

Sin un conjunto de reglas, la salida de IA tiende a ser:

- inconsistente entre sesiones/autores,
- demasiado creativa (inventar detalles),
- poco operativa (texto largo y poco verificable),
- y con riesgo de tocar archivos que no deberían tocarse.

Las instructions resuelven esto imponiendo:

- un estándar único de calidad,
- un mecanismo explícito de dudas (OPENQ) y trabajo pendiente (TODO),
- y una separación estricta entre `docs/spec/**` (por defecto sí) y `docs/kit/**` (por defecto no).

Además, en specs largas evitan un problema común: **acumulación y mezcla de iteraciones** (planes y listados que crecen indefinidamente), estableciendo un patrón de **histórico por iteración**.

---

## Qué deben contener (mínimo recomendado)

Una buena configuración de instrucciones debe cubrir:

1) **Reglas de alcance (cortafuegos)**
   - qué carpetas se editan por defecto (normalmente `docs/spec/**`)
   - qué carpetas no se tocan (normalmente `docs/kit/**`)

2) **Gestión del histórico por iteración (recomendado)**
   - `docs/spec/history/**` como snapshots cerrados
   - regla de **ignorar el histórico** para planificar/redactar/revisar
   - excepción: solo el cierre de iteración debe crear/actualizar histórico

3) **Principios globales**
   - no inventar
   - cambios diff-friendly (evitar reescrituras masivas)
   - trazabilidad mínima
   - decisiones visibles (ADR)

4) **Convenciones**
   - IDs (FR/NFR/UI/API/OPENQ/TODO/ADR)
   - marcadores: `OPENQ`, `TODO`, `DECISION`, `ADR`

5) **Proceso**
   - Planificar → Redactar → Revisar → Iterar
   - (Opcional recomendado) Cerrar iteración → archivar histórico → preparar siguiente iteración

6) **Reglas de enlaces**
   - en `.github/**` rutas desde raíz
   - en `docs/spec/**` enlaces relativos permitidos

---

## Modo evolutivo con codebase en el workspace

Cuando el workspace contiene un repositorio de código (normalmente en root `codebase/`), se trabaja en **modo evolutivo**: redactar especificaciones basándose en un proyecto existente.

### Concepto

- **Escritura**: los agentes/prompts crean/editan **solo** en `docs/spec/**` (repo `spec`)
- **Lectura**: los agentes/prompts consultan el código en `codebase/**` como **fuente de verdad técnica**
- **Nunca modificar codebase**: `codebase/**` es **solo lectura**

### Protocolo de consulta del codebase (obligatorio)

Las instrucciones definen un protocolo de 4 pasos:

#### 1) Contexto derivado

- Mantener `docs/spec/_inputs/codebase-map.md` como **mapa técnico resumido** del codebase.
- Antes de planificar o redactar decisiones técnicas, consultar este mapa.

#### 2) Evidencia bajo demanda (Evidence Packs)

- Cuando una sección requiera precisión técnica, generar un **Evidence Pack**.
- Guardar Evidence Pack en `docs/spec/_inputs/evidence/EP-###-<tema>.md`.
- Incluir rutas revisadas, hallazgos confirmados (con rutas), gaps y recomendaciones.

#### 3) Si no hay evidencia suficiente

- **No inventar**: registrar `OPENQ-###` en `docs/spec/95-open-questions.md`.
- Indicar:
  - qué se intentó verificar
  - en qué rutas se buscó
  - por qué no se pudo confirmar
  - hipótesis mínima (si aplica), marcada como *no confirmada*

#### 4) Trazabilidad

- En decisiones técnicas relevantes, enlazar Evidence Pack y/o rutas del codebase que sustentan lo descrito.

Formato recomendado:

```markdown
**EVIDENCE:** `codebase/src/auth/AuthController.ts` (handler de login)
**EVIDENCE PACK:** `docs/spec/_inputs/evidence/EP-002-auth-flow.md`
```

---

## Protocolo de verificación externa

A veces hace falta información externa para evitar inventar (integraciones, SDKs/APIs, licencias, compatibilidades, límites, pasos de instalación, prácticas de seguridad).

Las instrucciones definen un protocolo simple:

1. **Buscar en fuentes primarias**

   * Documentación oficial del proveedor/tecnología
   * Repositorio oficial (README/docs/releases/LICENSE/SECURITY)
2. **Si no se puede verificar**

   * registrar `OPENQ-###` o pedir al usuario que aporte el contenido o lo añada al repo como snapshot

### Subsección "Fuentes" obligatoria

Cuando se use información verificada externamente, registrar en el documento afectado una subsección `### Fuentes` con:

* URL completa
* Fecha de consulta (YYYY-MM-DD)
* 1 línea del dato extraído

Ejemplo:

```markdown
### Fuentes

- https://<docs-oficial> - 2026-02-14 - Límite de rate limit para el endpoint X
- https://<repo-oficial>/releases/... - 2026-02-14 - Cambio de API en la versión Y
```

### Prioridad de fuentes

1. Documentación oficial del proyecto/tecnología
2. Repositorio oficial
3. Releases/tags oficiales
4. Issues/discussions oficiales (si aplica)

---

## Cómo se relacionan con agentes, prompts y skills

* **Instructions**: marco global y obligatorio (repo-wide + path-specific).
* **Agentes**: aplican el marco desde su rol (planner/writer/reviewer).
* **Prompts**: procedimientos repetibles que deben respetar el marco.
* **Skills**: patrones de calidad que complementan, pero no sustituyen, las instructions.

Regla práctica:

> Si una norma afecta al comportamiento global del repo, va en instructions (global o por ruta).
> Si es un procedimiento repetible, va en un prompt file.
> Si es un rol, va en un agente.
> Si es “cómo redactar X con calidad”, va en un skill.

---

## Buenas prácticas de mantenimiento

### Cambios pequeños y versionados

* Cambiar instructions debe considerarse un cambio “de sistema”.
* Preferir PRs y revisión por otra persona.
* Explicar el “por qué” del cambio en el commit/PR.

### Evitar duplicidad

* No repetir reglas en muchos sitios.
* Si una regla es por ruta, no duplicarla en todos los documentos: referenciarla.

### Mantenerlo accionable

* Reglas claras, operativas y comprobables.
* Evitar lenguaje ambiguo (“mejor”, “bonito”, “correcto”) sin criterio.

### Mantener estable el “estado vivo”

* El plan activo vive en `docs/spec/01-plan.md` (una sola iteración activa, Pxx).
* `OPENQ/TODO/review notes` deben mantenerse como listados vivos.
* El detalle histórico debe archivarse por iteración en `docs/spec/history/Ixx/`.

---

## Errores frecuentes (y cómo evitarlos)

* **Permitir inventar**: no definir OPENQ como salida estándar ante falta de info.
* **No separar spec vs kit**: olvidar el cortafuegos `docs/spec/**` vs `docs/kit/**`.
* **Rutas relativas en `.github/**`**: causan errores de “file not found”.
* **Reglas demasiado largas**: cuando crece, modularizar con `.github/instructions/*.instructions.md`.
* **Planes “bola de nieve”**: no cerrar iteraciones y dejar que `01-plan.md` / `95/96/97` crezcan y mezclen iteraciones.

---

## Referencias internas

* Instrucciones globales: `.github/copilot-instructions.md`
* Instrucciones por ruta: `.github/instructions/*.instructions.md`
* Visión general del sistema: `docs/kit/50-sistema-ia.md`
* Agentes: `docs/kit/52-custom-agents.md`
* Prompts: `docs/kit/53-prompts.md`
* Skills: `docs/kit/54-skills.md`
* Flujo y conceptos: `docs/kit/20-conceptos-clave-y-flujo.md`
