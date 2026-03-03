---
category: spec-kit
scope: codebase
status: stable
---

# Skill: codebase_scout

## Objetivo

Explorar `codebase/**` (**solo lectura**) para construir/actualizar un **mapa técnico as-is** útil para el flujo SPEC (plan/write/review), minimizando el riesgo de inventar.

**Output principal:**
- `docs/spec/_inputs/codebase-map.md`

**Outputs secundarios (si aplica):**
- `docs/spec/95-open-questions.md` (OPENQ-### nuevas cuando falte evidencia)
- Recomendación de Evidence Pack cuando el tema requiera profundidad (`evidence_pack`).

---

## Principios

- **Read-only**: nunca modificar `codebase/**`.
- **Evidencia primero**: afirmaciones técnicas relevantes deben estar sustentadas con rutas concretas.
- **No inventar**: si no se confirma, se registra `OPENQ`.
- **Mapa operativo**: síntesis accionable, no enciclopedia.
- **Seguridad**: no copiar secretos (tokens, API keys, credenciales, `.env` reales).

---

## Entradas

- `codebase/**` (solo lectura)
- (Opcional) Pistas del usuario: rutas, módulos, términos, servicios
- (Opcional) Evidence Packs existentes: `docs/spec/_inputs/evidence/`

---

## Salidas

1) `docs/spec/_inputs/codebase-map.md` (crear/actualizar)
2) `OPENQ-###` en `docs/spec/95-open-questions.md` si hay gaps críticos
3) (Opcional) “Recomendación EP”: listar qué Evidence Packs conviene generar y por qué

---

## Timeboxing (obligatorio)

Elegir un modo (por defecto: **Quick**):

### Quick scan (15–30 min)
- Stack + tooling
- Entry point(s)
- Estructura de carpetas (alto nivel)
- 5–10 módulos/capacidades con evidencia mínima
- Persistencia (BBDD/ORM/migraciones) si se encuentra rápido
- CI/tests (mención breve)

### Deep scan (60–90 min)
Además de lo anterior:
- Interfaces públicas (punto de definición de rutas o resumen por familias)
- Jobs/workers/cron/colas (si existen)
- Logging/observabilidad/config más detallado
- 10–20 módulos/capacidades con evidencias

Si el timebox se agota:
- priorizar completar **DoD mínimo** y abrir `OPENQ` en lo crítico.

---

## Reglas duras (hard rules)

1) **Prohibido modificar codebase**
2) **Evidencia estándar**
   - Cada afirmación importante debe incluir `EVIDENCE:` con rutas `codebase/...`
   - Si no hay evidencia, no se formula como hecho → `OPENQ`.
3) **Sin secretos**
   - No copiar valores de `.env`/secrets ni tokens. A lo sumo: “existe `.env.example` / variable X”.
4) **Confianza**
   - No usar “probablemente”. O está confirmado con evidencia, o se formula como `OPENQ`.
5) **Cambios diff-friendly**
   - Actualizar por secciones sin reescrituras masivas.

---

## Procedimiento (pasos)

### 1) Stack y tooling (as-is)
Buscar evidencias en ficheros típicos:
- Node/TS: `package.json`, lockfile, `tsconfig*`
- Python: `pyproject.toml`, `requirements.txt`, `poetry.lock`
- Java: `pom.xml`, `build.gradle`
- Docker: `Dockerfile`, `docker-compose.yml`
- Mono-repo: `turbo.json`, `nx.json`, `pnpm-workspace.yaml`

Registrar:
- runtime(s), framework(s), gestor de deps
- scripts relevantes (`dev`, `build`, `test`, `lint`)

### 2) Entry point(s) y bootstrap
Localizar:
- punto de arranque
- carga de config/env
- registro de routers/modules

Registrar:
- entrypoint confirmado
- cómo se compone la app (muy alto nivel)

### 3) Estructura de carpetas (alto nivel)
Listar 8–20 carpetas max con 1 línea de propósito.
Evitar listas infinitas.

### 4) Módulos/capacidades
Definir “módulo” como:
- carpeta/paquete con responsabilidades claras (p.ej. `auth`, `users`, `repositories`)
- y normalmente al menos 2 de: router/controller, service, schema/model, policy/middleware

Para cada módulo (5–10 Quick / 10–20 Deep):
- 1–3 rutas clave
- 1 línea de qué hace

### 5) Interfaces públicas (Deep o si es fácil)
- Dónde se definen rutas (router index / controllers)
- Si hay OpenAPI/Swagger, registrarlo con evidencia

### 6) Persistencia y datos
Identificar:
- DB
- ORM
- migraciones
- nombres de entidades principales (solo nombres)

### 7) Calidad y operación
Mencionar (con evidencia):
- tests: ubicación + framework
- CI/CD: workflows/pipelines
- logging/observabilidad: librerías/config (alto nivel)
- config: `.env.example`, `config/`, settings

---

## Formato obligatorio para `codebase-map.md`

El documento debe incluir estas secciones (aunque alguna sea breve):

1) **Resumen ejecutivo** (5–10 líneas)
2) **Última actualización** (YYYY-MM-DD) + modo (Quick/Deep)
3) **Stack y tooling**
4) **Entrypoints y bootstrap**
5) **Estructura de carpetas (alto nivel)**
6) **Módulos/capacidades**
7) **Interfaces públicas** (si aplica / OPENQ)
8) **Persistencia** (si aplica / OPENQ)
9) **Operación** (tests/CI/logging/config)
10) **Evidencias** (lista)
11) **Cobertura del scout**:
    - paths inspeccionados
    - términos buscados (si aplica)
12) **OPENQ detectadas** (links)

### Estándar de evidencia
Usar bullets tipo:
- `EVIDENCE: codebase/src/main.ts` — bootstrap servidor
- `EVIDENCE: codebase/src/modules/auth/*` — módulo auth
- `EVIDENCE: codebase/.github/workflows/ci.yml` — pipeline CI

---

## Cuándo escalar a Evidence Pack (recomendación)

Si se detecta que requiere investigación específica y es crítico para decisiones:
- auth/roles/permisos
- secretos/API keys
- arquitectura async/jobs/colas
- integraciones externas críticas
- modelo de datos sensible

Entonces:
- recomendar `EP-###` y describir qué preguntas debe responder.

---

## DoD (mínimo para considerarlo “suficiente”)

- [ ] Stack + tooling (o OPENQ)
- [ ] Entry point(s) (o OPENQ)
- [ ] Estructura de carpetas (alto nivel)
- [ ] 5–10 módulos (Quick) o 10–20 (Deep) con evidencia
- [ ] Persistencia (o OPENQ)
- [ ] CI/tests/logging/config mencionados (o OPENQ)
- [ ] Sección “Evidencias” y “Cobertura del scout”
- [ ] OPENQ registradas si hay gaps críticos

---

## Anti-patrones

- “Probablemente usan X” sin evidencia
- Listas de archivos sin síntesis
- Mezclar to-be (SPEC) dentro del as-is (CODEBASE)
- Copiar secretos o valores de `.env`
