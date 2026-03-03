---
category: spec-kit
scope: rfc
status: stable
---

# SKILL: rfc-proposal

## Propósito

Crear/actualizar un RFC narrativo en español que **resuma y conecte** la especificación distribuida en `docs/spec/**`, sin sustituirla.

El RFC sirve para:
- Alinear stakeholders (qué se va a hacer y por qué).
- Consolidar decisiones (ADRs) y trade-offs.
- Identificar riesgos y gaps (OPENQ) sin “rellenar”.

---

## Inputs (mínimo)

- `ROOT_SPEC_DIR`: `docs/spec/`
- `RFC_ID` (opcional): `RFC-0001`, `RFC-0002`, ...
- `SLUG` (opcional): texto corto del cambio (kebab-case)
- `VARIANTE` (opcional): `architecture` (default) | `executive`
- `FOCUS` (opcional): 3–8 bullets con énfasis (p.ej. “seguridad”, “operación”, “migración”, “frontend”).

---

## Outputs (obligatorio)

- RFC Markdown en `docs/spec/rfc/`:
  - `architecture`: `docs/spec/rfc/<RFC_ID>-<slug>.md`
  - `executive`: `docs/spec/rfc/<RFC_ID>-<slug>-executive.md`

- Sección final **“Fuentes utilizadas”** con listado de ficheros `docs/spec/**` consultados y motivo (1 línea c/u).

> Opcional (solo si el repositorio ya lo está usando): crear/actualizar
> `docs/spec/_inputs/rfc/<RFC_ID>/sources.md` con el mismo listado de fuentes.

---

## Hard rules (no negociables)

1) **Idioma**: todo en español.

2) **No inventar**
- No afirmar hechos/decisiones/cifras/contratos/SLAs/endpoints si no están en `docs/spec/**`.
- Si falta evidencia: escribir `OPENQ:` y enlazar a `../95-open-questions.md` (o indicar dónde debe crearse).

3) **Separación as-is / to-be**
- “Confirmado (as-is)” solo si hay evidencia explícita en spec.
- “Propuesta / decisión” debe quedar claramente como tal.
- Si es hipótesis: marcar `HIPÓTESIS:` o convertir en `OPENQ` si es crítica.

4) **Evidencias por sección**
- Cada sección del RFC termina con:
  - `**Evidencias:**` + links relativos (mín. 1).
- Secciones críticas (seguridad/operación/migración/alternativas) requieren **≥2 evidencias** si existen fuentes.

5) **Contradicciones**
- Si dos fuentes se contradicen:
  - `DISCREPANCIA:` + descripción + links a ambas.
  - Si bloquea decisión: `OPENQ`.

6) **Formato**
- Markdown limpio (aplicar el skill `spec-style`).
- Evitar quotes largos; preferir síntesis.

---

## Regla de enlaces (determinista)

El RFC vive en `docs/spec/rfc/**`, así que los links a spec deben ser relativos con `../`:

- `../10-requisitos-funcionales.md`
- `../60-backend.md#...` (solo si el anchor es estable)
- `../adr/ADR-0009-....md`
- `../95-open-questions.md#openq-xxx`

Si no estás seguro del anchor, enlaza al archivo sin `#`.

---

## Reglas de tamaño (para evitar inflado)

### VARIANTE=executive
- 1 página aprox.
- 3 bloques: “qué”, “impacto”, “riesgos/decisiones”.
- Máximo 10–14 bullets en total.

### VARIANTE=architecture
El RFC debe adaptarse al tamaño real del cambio:

- **Small change** (pocas secciones afectadas):
  - 1–2 flujos E2E
  - 5–8 riesgos
  - OPENQ: solo las que bloquean o son relevantes (no forzar cantidad)

- **Medium/Large change**:
  - 2–3 flujos E2E (incluye 1 error path)
  - 8–15 riesgos
  - OPENQ relevantes (hasta ~15)

Nunca “rellenar” para alcanzar un número.

---

## Workflow recomendado (3 pasadas)

### Pass 1 — Cobertura y fuentes
- Identificar qué ficheros de `docs/spec/**` son fuente para cada sección del RFC.
- Preparar lista inicial para “Fuentes utilizadas”.

### Pass 2 — Extracción (sin redactar aún)
Extraer puntos mínimos:
- objetivo/alcance IN/OUT
- decisiones (ADRs) y trade-offs
- arquitectura alto nivel (componentes y límites)
- flujos E2E
- seguridad/operación/migración si aplican
- riesgos y OPENQ/discrepancias

Si una parte es crítica y no hay material: OPENQ.

### Pass 3 — Redacción + Quality Gate
- Redactar el RFC con secciones claras y evidencias al final de cada una.
- Aplicar checklist final.

---

## Plantilla (compacta, VARIANTE=architecture)

## <RFC_ID> — <Título del evolutivo>
**Estado:** Draft | Reviewed | Approved  
**Fecha:** YYYY-MM-DD (si no consta, fecha actual)  
**Owner:** <si consta; si no, OPENQ>  
**Decisión solicitada:** 1–2 frases

### 1) Resumen ejecutivo
(8–12 líneas)
**Evidencias:** …

### 2) Contexto y problema
**Evidencias:** …

### 3) Objetivos y alcance
- IN:
- OUT / No-objetivos: (si no existe, OPENQ)
**Evidencias:** …

### 4) Propuesta de solución (alto nivel)
Componentes + límites + contratos a alto nivel.
**Evidencias:** …

### 5) Flujos E2E
(1–3 flujos según tamaño; al menos 1 error path si aplica)
**Evidencias:** …

### 6) Alternativas y decisiones
(2–3 si existen; si no hay alternativas en spec, no inventar)
**Evidencias:** (ADRs)

### 7) Seguridad y privacidad
Activos / amenazas / mitigaciones (MVP vs diferido).
**Evidencias:** …

### 8) Operación
Deploy, rollback, observabilidad mínima, runbooks si existen.
**Evidencias:** …

### 9) Compatibilidad y migración
Breaking/no-breaking, plan de migración, versionado si existe.
**Evidencias:** …

### 10) Riesgos y OPENQ
- Tabla de riesgos (5–15 según tamaño).
- OPENQ relevantes (sin forzar cantidad).
**Evidencias:** …

### 11) Criterios de aceptación
Lista verificable.
**Evidencias:** …

### 12) Fuentes utilizadas
- `docs/spec/...` — propósito
- …

### 13) Auto-chequeo (Quality Gate)
- [ ] Evidencias por sección
- [ ] No inventar / OPENQ donde faltan datos
- [ ] Discrepancias marcadas
- [ ] As-is vs propuesta separados
- [ ] Formato spec-style OK

---

## DoD

- [ ] RFC creado/actualizado en `docs/spec/rfc/**` con naming correcto
- [ ] Cada sección termina con “Evidencias” (links `../...`)
- [ ] No hay hechos sin evidencia (o marcados como HIPÓTESIS/OPENQ)
- [ ] Discrepancias y OPENQ registradas y enlazadas
- [ ] “Fuentes utilizadas” completa
- [ ] Markdown limpio (spec-style)
