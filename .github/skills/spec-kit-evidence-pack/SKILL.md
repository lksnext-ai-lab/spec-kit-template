---
category: spec-kit
scope: codebase
status: stable
---

# Skill: evidence_pack

## Objetivo

Investigar un tema en `codebase/**` (**solo lectura**) y producir un **Evidence Pack** reutilizable para sustentar `docs/spec/**` sin inventar.

**Output:** `docs/spec/_inputs/evidence/EP-###-<tema>.md` (siguiendo el template del repo)

---

## Fuente de verdad (estructura del EP)

Usar SIEMPRE como base:

- `docs/spec/_inputs/evidence/_TEMPLATE-evidence-pack.md`

El Evidence Pack resultante debe mantener exactamente las secciones A–F del template (mismo orden, mismos títulos).

> Se permiten ampliaciones internas (más bullets/sub-bullets) dentro de A–F, pero **no** reordenar ni sustituir el esquema.

---

## Principios

- **Read-only:** no modificar `codebase/**`.
- **Evidencia primero:** conclusiones confirmadas siempre con rutas concretas.
- **No inventar:** si no se confirma, se registra `OPENQ-###`.
- **Separación estricta:** confirmado vs inferido vs desconocido.
- **Reproducible:** registrar cobertura (términos y paths) para poder repetir el análisis.
- **Seguro:** no copiar valores sensibles (tokens, API keys, credenciales).

---

## EP-###: numeración y naming (regla operativa)

- Elegir el **siguiente número disponible** (3 dígitos) sin reutilizar:
  - `EP-001-...`, `EP-038-...`, etc.
- Nombre recomendado del fichero:
  - `EP-###-<tema-en-kebab-case>.md`
- Si ya existe un EP del mismo tema, crear uno nuevo solo si:
  - el alcance es distinto (subtema), o
  - la codebase ha cambiado sustancialmente y necesitas “v2”.

---

## Timeboxing (obligatorio)

### Quick (20–40 min)
- 3–8 búsquedas
- 3–8 ficheros clave
- 3–8 conclusiones confirmadas
- A/B/C/D con tamaño acotado (ver “límites”)

### Deep (60–120 min)
- 8–15 búsquedas
- 8–20 ficheros clave
- 8–15 conclusiones confirmadas
- incluir impacto/riesgos/tests/compatibilidad si aplica

Si se agota el timebox:
- cerrar con confirmadas + OPENQ (sin “rellenar” con inferencias)

---

## Reglas duras (hard rules)

1) **Prohibido modificar `codebase/**`.**

2) **Evidencia con granularidad**
   - Cada conclusión confirmada debe incluir:
     - ruta `codebase/...`
     - y cuando sea posible: símbolo (clase/función/método) o bloque relevante.
   - Evitar “evidencia” vaga tipo “mirado el repo”.

3) **Inferencias: uso excepcional**
   - Solo si hay evidencia indirecta clara y la inferencia es acotada.
   - Si afecta a seguridad, contratos, permisos o datos → NO inferir: OPENQ.

4) **No copiar secretos**
   - No copiar valores de `.env`, tokens o keys.
   - Se permite mencionar “existe variable X / `.env.example`”, sin valores.

5) **Cobertura obligatoria**
   - Registrar:
     - **Términos buscados** en `Contexto`.
     - **Paths/archivos revisados** y **evidencia negativa** (si aplica) en `E) Evidencias revisadas`.

6) **OPENQ coherente**
   - Si aparece en `F) OPENQ`, debe existir también en `docs/spec/95-open-questions.md` (y enlazarse).

---

## Límites recomendados (para evitar ruido)

- Quick:
  - A) 3–8 bullets
  - B) 0–3 bullets
  - C) 3–10 bullets
  - D) 3–8 bullets
  - E) 5–15 paths/archivos
- Deep:
  - A) 8–15 bullets
  - B) 0–5 bullets
  - C) 8–20 bullets
  - D) 8–15 bullets
  - E) 10–30 paths/archivos

---

## Procedimiento

### 1) Crear el EP desde el template
- Copiar `docs/spec/_inputs/evidence/_TEMPLATE-evidence-pack.md` a `EP-###-<tema>.md`.
- Rellenar cabecera (Autor, Fecha).
- En `Contexto`, añadir también:
  - **Modo:** Quick | Deep
  - **Términos buscados:** lista corta (5–15)
  - (Opcional) Pistas recibidas

### 2) Ejecutar búsquedas (queries)
Construir queries combinando:
- tema + sinónimos
- capas: `controller/router/service/repository/policy/guard/middleware`
- datos: `orm/schema/migration`
- async: `job/queue/worker/cron`

### 3) Abrir ficheros clave y extraer evidencia
Para cada fichero relevante:
- qué confirma (1 línea)
- ruta exacta
- símbolo/bloque si aplica

### 4) Rellenar secciones del EP (A–F)

#### A) Conclusiones confirmadas
- Hechos as-is con evidencia directa.
- Formato recomendado:
  - `<conclusión>` — Evidencia: `codebase/...` (símbolo si aplica)

#### B) Conclusiones inferidas
- Solo si aplica.
- Incluir:
  - evidencia indirecta
  - motivo de inferencia
  - riesgo (low/medium/high)

#### C) Detalles operativos relevantes para la spec
- Config/env (sin valores)
- flujos/estados
- errores/casos borde
- seguridad
- observabilidad

#### D) Impacto probable del evolutivo
- módulos/rutas afectadas
- riesgos y mitigaciones
- tests a revisar/añadir
- migraciones/compatibilidad/rollout

> Importante: si una afirmación aquí no está confirmada, marcarla explícitamente como “HIPÓTESIS” o convertirla en OPENQ si es crítica.

#### E) Evidencias revisadas
- Listar paths/archivos revisados con una línea de “para qué”.
- Añadir al final (obligatorio):
  - **Paths inspeccionados (resumen):** carpetas o áreas principales
  - **Evidencia negativa (si aplica):**
    - “Busqué `<término>` en `<ruta>` y no encontré referencias relevantes.”

#### F) OPENQ (si aplica)
- Añadir preguntas abiertas con:
  - por qué bloquea
  - qué se intentó (términos + paths/archivos)
- Registrar también en `docs/spec/95-open-questions.md` con el mismo ID.

---

## DoD (Definition of Done)

Un Evidence Pack está “listo” si:

- [ ] Existe `docs/spec/_inputs/evidence/EP-###-<tema>.md` creado desde el template
- [ ] Autor y Fecha están rellenos
- [ ] `Contexto` incluye: modo + términos buscados
- [ ] A) incluye:
  - Quick: ≥ 3 confirmadas
  - Deep: ≥ 8 confirmadas
  y todas tienen evidencia (`codebase/...` + símbolo cuando posible)
- [ ] E) lista paths/archivos revisados y añade (al final) paths inspeccionados + evidencia negativa si aplica
- [ ] Las hipótesis en D) están marcadas como HIPÓTESIS (o convertidas en OPENQ si críticas)
- [ ] Si hay OPENQ en F), están también en `docs/spec/95-open-questions.md`
- [ ] No contiene valores sensibles (tokens/keys/credenciales)

---

## Anti-patrones

- Conclusiones sin evidencia
- “Probablemente…” como sustituto de confirmación
- Mezclar to-be dentro de “Confirmadas”
- EP sin cobertura (términos/paths)
- Copiar secretos o valores de `.env`
