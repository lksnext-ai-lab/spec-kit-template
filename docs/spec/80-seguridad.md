# Seguridad

> Objetivo: definir el baseline de seguridad: autenticación/autorización, protección de datos,
> auditoría y mitigaciones. Debe alinearse con NFR y arquitectura.

## 1. Alcance y datos sensibles

- Datos tratados: TODO
- Datos sensibles: TODO
- Clasificación interna (si existe): TODO

## 2. Autenticación

- Método: TODO (SSO, OAuth2/OIDC, usuarios internos, etc.)
- Gestión de sesiones/tokens: TODO
- MFA (si aplica): TODO
- OpenQ/Decision: DECISION: TODO (¿ADR?)

## 3. Autorización

- Modelo: TODO (RBAC/ABAC)
- Permisos clave: ver `docs/20-conceptualizacion.md`
- Reglas de acceso a recursos: TODO (por entidad/proyecto/tenant)

## 4. Protección de datos

- Cifrado en tránsito: TODO
- Cifrado en reposo: TODO
- Gestión de secretos: TODO
- Retención / borrado: TODO
- Backups y datos personales: TODO

## 5. Auditoría y trazabilidad

- Qué acciones se auditan: TODO
- Campos mínimos de auditoría: usuario, timestamp, acción, objeto, resultado
- Acceso a logs: TODO
- Retención de logs: TODO

## 6. Seguridad de API e integraciones

- Rate limiting / throttling: TODO
- Validación de inputs: TODO
- Protección CSRF/CORS (si aplica): TODO
- Gestión de claves/rotación: TODO

## 7. Amenazas y mitigaciones (ligero)

| Amenaza | Riesgo | Mitigación | Evidencia/Verificación |
|---|---|---|---|
| TODO | TODO | TODO | TODO |

## 8. Requisitos de cumplimiento

- Normativa: TODO
- Políticas internas: TODO

---

Referencia: [NFR](./11-requisitos-tecnicos-nfr.md) · [Arquitectura](./40-arquitectura.md) · [Infra](./90-infra.md)
