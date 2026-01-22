# Requisitos técnicos / No funcionales (NFR)

> Reglas:
>
> - Deben ser **medibles o verificables** cuando sea posible.
> - En caso de no poder medir: define un método de verificación (prueba/certificación/revisión).
> - Evitar vaguedades (“rápido”, “seguro”, “escalable”) sin umbrales.

## Convenciones

- **ID**: `NFR-###` (correlativo).
- **Estado**: `Draft` / `Validated` / `Deprecated`.
- **Categoría**: Seguridad / Disponibilidad / Rendimiento / Observabilidad / Privacidad&Legal / Mantenibilidad / Portabilidad / UX&Accesibilidad / Coste.
- Si el NFR implica una decisión de arquitectura → `DECISION:` y ADR.

---

## Tabla resumen

| ID | Título | Categoría | Estado | Objetivo (métrica) | Verificación | Notas |
| --- | --- | --- | --- | --- | --- | --- |
| NFR-001 | TODO | Seguridad | Draft | TODO | TODO | TODO |

---

## Detalle de requisitos

### NFR-001 — TODO

- **Categoría**: TODO
- **Descripción**: TODO
- **Objetivo / Métrica** (cuando aplique):
  - SLI: TODO
  - SLO: TODO
  - Umbral/límite: TODO
- **Alcance**: TODO (qué parte del sistema aplica)
- **Exclusiones**: TODO
- **Verificación**:
  - Prueba: TODO
  - Evidencia: TODO (logs, informe, checklist, pentest, etc.)
- **Implicaciones**:
  - Arquitectura: TODO
  - Operación: TODO
  - Coste: TODO
- **Estado**: Draft
- **Observaciones**:
  - TODO / OPENQ / RISK / DECISION

---

## NFR mínimos sugeridos (para no olvidarlos)

- Seguridad: autenticación, autorización, protección de datos, auditoría.
- Disponibilidad: backups/DR, tolerancia a fallos (si aplica), ventana de mantenimiento.
- Observabilidad: logging estructurado, métricas clave, alertas básicas.
- Privacidad&Legal: retención, acceso, cifrado (si aplica), cumplimiento.
- Mantenibilidad: versionado API, pruebas mínimas, documentación.
