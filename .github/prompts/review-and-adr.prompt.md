---
name: review-and-adr
description: Revisión crítica con veredicto PASS/WARN/FAIL + generación controlada de ADRs (sin duplicados) a partir de DECISIONs. Produce `docs/spec/97-review-notes.md` con formato estable y acciones priorizadas. Opcionalmente aplica patch mínimo (links, typos, markers), evitando churn.
---

# review-and-adr

## Objetivo
Revisar `docs/spec/**` (y opcionalmente RFC/IMP) para:
- detectar inconsistencias, huecos y riesgos,
- producir un informe accionable (`97-review-notes.md`),
- y crear ADRs **solo** cuando exista información suficiente o cuando el ADR pueda quedar correctamente marcado como “Propuesto” con drivers claros.

---

## Parámetros opcionales
- `REVIEW_SCOPE` (default `spec`): `spec` | `rfc` | `imp` | `spec,rfc` | `spec,imp` | `all`
- `PATCH_MODE` (default `minimal`): `none` | `minimal`
  - `none`: no modificar nada excepto `docs/spec/97-review-notes.md`
  - `minimal`: permitir patch mínimo (links/typos/markers/enlaces ADR/index)
- `OPENQ_MODE` (default `link-only`): `link-only` | `write`
- `TODO_MODE` (default `write`): `write` | `link-only`
- `ADR_MODE` (default `write`): `write` | `link-only`
- `STRICT` (default `false`)
- `MAX_FINDINGS` (default `40`): límite duro; priorizar por severidad
- `REPORT_VERSION` (default `1.1`)

---

## Reglas duras
- Ignorar `docs/spec/history/**`.
- No tocar CODEBASE.
- No usar shell/PowerShell/Bash.
- Evitar churn: no reescrituras masivas.
- Si `PATCH_MODE=none`, no tocar ningún archivo salvo `97-review-notes.md`.

---

## Política de severidad (estable por categoría)

### Siempre BLOCKER
- Seguridad/privacidad: secretos, authN/authZ, permisos, exposición de datos sin definir o contradictoria.
- Contradicción entre docs clave (FR/NFR/arquitectura/seguridad) sin reconciliar.
- Decisión crítica implícita sin drivers (si bloquea implementación o RFC).
- (Si REVIEW_SCOPE incluye imp) backlog roto: columnas/vocabulario o blocked sin reason.

### Por defecto MAJOR
- NFR sin verificación (cómo se valida).
- Migración/compatibilidad sin plan cuando aplica.
- Operación incompleta (logging/observabilidad/rollback) si se espera por NFR.
- ADR existente incompleto pero marcado como vigente/aceptado.

### Por defecto MINOR
- Terminología inconsistente, pequeños gaps de redacción, enlaces mejorables.

> Si `STRICT=true`, elevar MINOR→MAJOR y MAJOR→BLOCKER en categorías críticas.

---

## Selección de alcance
- `spec`: revisar docs/spec principales, excluyendo edición de `adr/**` salvo para indexado/linking.
- `rfc`: revisar `docs/spec/rfc/**` + `_inputs/rfc/**` si existen.
- `imp`: revisar backlog+tasks, sin modificar.

---

## Checklist de revisión
1) Coherencia cross-doc
2) FR testables + aceptación
3) NFR medibles o verificables
4) Operación mínima (si aplica)
5) Trazabilidad incremental (si aplica)
6) ADRs: vigencia, consistencia y calidad mínima

---

## ADR review (calidad mínima)
Para ADRs vigentes (no superseded):
- Deben tener: contexto, drivers, opciones, decisión, consecuencias, validación.
Si falta algo:
- registrar MAJOR (o BLOCKER si afecta a seguridad/operación).

---

## Auto-ADR (controlado y anti-ruido)

### DECISION candidata
- `DECISION:` explícita o decisión inequívoca que afecta arquitectura/seguridad/datos/contratos/operación/migración.

### Regla dura: “ADR escribible” vs “ADR solo propuesta”
Un ADR es **escribible** (ADR_MODE=write) solo si:
- existen ≥2 alternativas reales, y
- existen drivers claros (NFR/restricciones/evidencias), y
- se puede redactar consecuencias y validación sin inventar.

Si no cumple:
- NO crear ADR en disco.
- Registrar “ADR-(propuesta)” en `97-review-notes.md` con:
  - título sugerido, slug, ubicación para enlazar, y qué info falta.

### Anti-duplicados
- Buscar ADR equivalente por slug/título/tema.
- Si existe, enlazarlo y no crear otro.

### Si se crea ADR (ADR_MODE=write)
- Crear con estado `Propuesto` salvo que la decisión ya esté claramente tomada y justificada.
- Actualizar `docs/spec/adr/index.md` (si PATCH_MODE=minimal).
- Enlazar desde el documento origen (si PATCH_MODE=minimal).

---

## OPENQ/TODO (según modo)
- Dedupe obligatorio (buscar antes).
- Si `link-only`: no escribir; proponer en notes.

---

## Output: `docs/spec/97-review-notes.md` (estructura estable)

Debe incluir:

```yaml
report_version: "<REPORT_VERSION>"
scope: "<REVIEW_SCOPE>"
patch_mode: "<PATCH_MODE>"
adr_mode: "<ADR_MODE>"
openq_mode: "<OPENQ_MODE>"
todo_mode: "<TODO_MODE>"
verdict: "PASS|WARN|FAIL"
generated_at: "YYYY-MM-DD"
findings_total: <n>
blockers: <n>
majors: <n>
minors: <n>
```

1. Resumen (veredicto + motivos)
2. BLOCKER (top, hasta 15)
3. MAJOR (hasta 20)
4. MINOR (hasta 20)
5. ADRs (creados / enlazados / propuestos)
6. OPENQ/TODO (creados o propuestos)
7. Cambios aplicados (solo si PATCH_MODE=minimal)
8. Próximo paso recomendado (rule-based)

Reglas:

* No exceder `MAX_FINDINGS`. Prioriza BLOCKER>MAJOR>MINOR.
* Cada finding debe tener:

  * Severidad (BLOCKER/MAJOR/MINOR)
  * Categoría (security/consistency/nfr/ops/migration/traceability/adr/imp)
  * Ubicación (archivo#sección)
  * Problema
  * Acción mínima sugerida
  * Evidencia/link (si aplica)

---

## Veredicto PASS/WARN/FAIL

* FAIL si existe ≥1 BLOCKER.
* WARN si no hay BLOCKER pero hay ≥1 MAJOR.
* PASS si no hay BLOCKER y MAJOR es 0 (o muy bajo y acotado, best-effort).

---

## Salida en el chat (resumen)

* Veredicto + top 5 hallazgos
* ADRs creados/enlazados/propuestos
* OPENQ/TODO creados/propuestos
* Cambios aplicados (si PATCH_MODE=minimal)
* Próximo paso recomendado
