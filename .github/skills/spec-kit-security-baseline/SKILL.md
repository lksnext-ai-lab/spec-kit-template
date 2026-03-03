---
name: spec-kit-security-baseline
description: "Define o revisa seguridad en docs/spec/80-seguridad.md: authn/authz, datos/secretos, auditoría, controles de API/integraciones y threat-lite. Evita suposiciones; abre ADR/OPENQ cuando falte info o haya trade-offs."
license: Proprietary
---

# Skill: Security Baseline (spec-kit)

## Objetivo
Dejar `docs/spec/80-seguridad.md` en un estado **operable y verificable** para MVP:
- AuthN (autenticación, sesiones/tokens)
- AuthZ (modelo, reglas por recurso)
- Protección de datos y secretos
- Auditoría / trazabilidad de acciones sensibles
- Controles de API e integraciones
- Threat-lite (amenazas → mitigaciones → verificación/evidencia)

## Archivos que se pueden modificar
- Primario: `docs/spec/80-seguridad.md`
- Si aplica:
  - `docs/spec/11-requisitos-tecnicos-nfr.md` (NFRs de seguridad verificables/medibles)
  - `docs/spec/90-infra.md` (secretos, hardening, retenciones operativas)
  - `docs/spec/40-arquitectura.md` (impactos y patrones)
  - `docs/spec/adr/ADR-*.md` (trade-offs)
  - `docs/spec/95-open-questions.md` (gaps críticos)
  - `docs/spec/96-todos.md` (pendientes no bloqueantes)

> No tocar otros ficheros salvo petición explícita.

## Reglas duras (anti-deriva)
1) **No inventar**
- No asumir MFA/SSO, RBAC/ABAC, cifrado en reposo, retenciones, herramientas, ni niveles de logging si no están definidos.
- Si falta info que condiciona el diseño/aceptación: `OPENQ:` (no rellenar).

2) **No secretos / no datos sensibles**
- Nunca incluir valores reales (keys, tokens, passwords, certificados) ni datos personales en ejemplos.
- Regla de logs/errores: no deben exponer secretos ni datos sensibles (si aplica, declararlo como control + verificación).

3) **Vendor-neutral por defecto**
- Describir patrones (OIDC, secrets manager, rate limiting) sin imponer proveedor/stack salvo evidencia explícita.

4) **Deny-by-default**
- Por defecto, sin permiso explícito → acceso denegado.
- Excepciones solo si están justificadas y evidenciadas.

5) **Trade-offs relevantes → ADR**
- Ej.: RBAC vs ABAC, scopes vs permisos granulares, auditoría detallada vs coste/privacidad, cifrado en reposo MVP vs fase 2, estrategia rotación.

6) **Clasificación: requerido vs recomendado**
En el documento, marcar explícitamente cada control como:
- `REQUERIDO` (evidenciado o exigido por FR/NFR/ADR)
- `RECOMENDADO` (baseline sugerido)
- `TBD/OPENQ` (falta decisión o datos)

## Output contract para 80-seguridad.md (mínimos)
El documento debe contener:
1) **Activos y datos sensibles (conceptual)**  
2) **AuthN** (método + sesión/tokens, o OPENQ si no está definido)  
3) **AuthZ** (modelo + reglas por recurso)  
4) **Datos/secretos** (almacenamiento patrón + rotación si existe o OPENQ)  
5) **Auditoría** (acciones auditadas + campos mínimos + verificación)  
6) **Controles API/integraciones** (validación, rate limit si aplica, protección de errores)  
7) **Threat-lite** (tabla amenaza→mitigación→verificación/evidencia)  
8) **Decisiones y gaps** (links a ADR/OPENQ)

## Workflow (determinista)

### 1) Inventario mínimo (Activos y superficies)
- Activos: usuarios, roles/permisos, datos sensibles, claves/config, integraciones.
- Superficies: API, admin, integraciones, colas/jobs (si existen), almacenamiento.
- Si falta clasificación de datos o alcance de “datos sensibles”: `OPENQ`.

### 2) AuthN (autenticación / sesión)
- Método (SSO/OIDC/OAuth2/usuarios internos): **solo si existe**, si no → OPENQ.
- Sesión/tokens (exp/refresh): si no existe definición → `TBD` + `OPENQ` si bloquea.
- MFA: si aplica, solo si está definido; si es requisito probable → `RECOMENDADO` + OPENQ.

### 3) AuthZ (autorización)
- Modelo (RBAC/ABAC/híbrido): según spec/ADR; si no, OPENQ.
- Reglas por recurso: leer/crear/editar/borrar + acciones admin.
- Principios:
  - deny-by-default
  - least privilege
- Verificación: tests de permisos o checklist de validación (definir evidencia).

### 4) Datos y secretos
- **Datos sensibles**: qué se considera sensible (conceptual).
- **Cifrado en tránsito/reposo**: solo como REQUERIDO si está en spec; si no, RECOMENDADO + OPENQ si bloquea.
- Secretos:
  - patrón de almacenamiento (sin herramienta)
  - acceso (quién/qué proceso)
  - rotación (si existe) o OPENQ
- Regla de errores/logs: no exponer PII/secretos (control + evidencia).

### 5) Auditoría
Definir:
- Acciones auditadas (mínimo recomendado; ajustar al dominio):
  - cambios de permisos/roles
  - acciones admin críticas
  - acceso/operaciones sobre datos sensibles (si aplica)
  - creación/edición/borrado de entidades críticas
- Campos mínimos de evento: actor, timestamp, acción, recurso, resultado, correlation-id (si existe).
- Verificación/evidencia: dónde se comprueba (tests, logs de auditoría, reporte, dashboard).

### 6) Controles API e integraciones
- Validación server-side inputs
- Protección de errores (no filtrar info sensible)
- Rate limiting/throttling: REQUERIDO solo si se define; si no, RECOMENDADO + OPENQ si riesgo.
- Integraciones: scopes/keys, rotación (si definido) u OPENQ.

### 7) Threat-lite (obligatorio, sin “relleno”)
Completar 5–12 amenazas reales (según tamaño del cambio):

| Amenaza | Impacto | Mitigación (REQUERIDO/RECOMENDADO, MVP/F2) | Verificación/Evidencia | Estado (OK/OPENQ) |
| --- | --- | --- | --- | --- |

Regla: si falta verificación/evidencia, no marcar como “OK”.

### 8) Consolidar decisiones y gaps
- `DECISION:` → ADR
- `OPENQ:` → 95-open-questions
- `TODO:` → 96-todos si no bloquea

## Plantillas compactas

### Control (CTRL)
- **Control:** (qué protege)
- **Tipo:** REQUERIDO | RECOMENDADO | TBD
- **MVP/F2**
- **Dónde aplica:** (API/admin/integ/datos)
- **Verificación:** (cómo se prueba)
- **Evidencia:** (dónde queda)

### Matriz de permisos (PERM) — opcional pero recomendada si hay authz complejo
| Recurso/Acción | Rol A | Rol B | Rol C | Notas |
| --- | --- | --- | --- | --- |

### Evento auditoría (AUD)
- actor
- timestamp
- acción
- recurso
- resultado
- correlation-id (si aplica)

## DoD
- [ ] AuthN descrita o OPENQ si no existe definición
- [ ] AuthZ descrita (modelo + reglas por recurso) + deny-by-default explícito
- [ ] Datos/secretos tratados sin valores reales + regla de no filtrado en logs/errores
- [ ] Auditoría definida (acciones + campos mínimos + evidencia)
- [ ] Controles API/integraciones descritos (con verificación/evidencia)
- [ ] Threat-lite completo con mitigación + verificación (sin “relleno”)
- [ ] Trade-offs relevantes enlazados a ADR
- [ ] Gaps críticos en OPENQ
