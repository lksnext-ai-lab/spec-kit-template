---
name: security-baseline
description: Usa este skill para definir o revisar seguridad en docs/spec/80-seguridad.md (y NFR relacionados): auth, autorización, protección de datos, auditoría, amenazas y controles mínimos.
---

# Security-baseline — Baseline de seguridad

## Objetivo

Definir un baseline de seguridad operativo y verificable:

- autenticación y autorización,
- protección de datos,
- auditoría y trazabilidad,
- controles de API,
- y una evaluación ligera de amenazas.

## Dónde aplicar

- `docs/spec/80-seguridad.md` (principal)
- `docs/spec/11-requisitos-tecnicos-nfr.md` (NFR de seguridad)
- `docs/spec/40-arquitectura.md` y `docs/spec/90-infra.md` (impactos)
- ADR cuando haya decisiones fuertes

## Baseline mínimo (lo que no debe faltar)

### Autenticación

- Método (SSO/OIDC/OAuth2/usuarios internos)
- Gestión de sesión/tokens (expiración, refresh)
- MFA (si aplica)
- Política de password (si aplica)

Si hay alternativas: `DECISION:` (→ ADR).

### Autorización

- Modelo RBAC/ABAC
- Permisos por rol (referencia a conceptualización)
- Reglas de acceso a recursos (por entidad/proyecto/tenant)

### Protección de datos

- Cifrado en tránsito (TLS)
- Cifrado en reposo si hay datos sensibles
- Gestión de secretos (vault/rotación)
- Retención y borrado (RGPD si aplica)
- Anonimización en pre si se usan datos reales

### Auditoría y logging

- Acciones auditadas (crear/editar/borrar, accesos, cambios de permisos)
- Contenido mínimo: usuario, timestamp, acción, objeto, resultado,
  correlation-id
- Retención y acceso a logs (quién puede verlos)

### Seguridad de API e integraciones

- Validación de inputs (server-side siempre)
- Rate limiting / throttling
- CORS/CSRF si aplica
- Gestión de claves (rotación, scopes)

## Amenazas (ligero, “threat-lite”)

Para cada amenaza relevante:

- riesgo
- mitigación
- verificación/evidencia

Ejemplos típicos:

- Acceso no autorizado → RBAC/ABAC + pruebas
- Exfiltración de datos → cifrado + control de accesos + auditoría
- Abuso de API → rate limiting + detección + alertas

## Evidencias / verificación (recomendado)

- Checklist de configuración
- Revisión de código/políticas
- Pentest (si aplica)
- Pruebas automatizadas de permisos (cuando aplique)

## Checklist rápido (revisión seguridad)

- [ ] AuthN definida (y decisión en ADR si hay opciones).
- [ ] AuthZ definida con reglas por recurso.
- [ ] Secretos y cifrado tratados.
- [ ] Auditoría definida (qué, cómo, retención).
- [ ] Controles API (validación, rate limit).
- [ ] Threat-lite con mitigaciones y evidencia.
