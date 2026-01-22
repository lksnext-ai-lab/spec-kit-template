# Anexos y ejemplos (referencia rápida)

Este documento contiene ejemplos mínimos (copy/paste) para redactar y mantener una especificación con calidad, sin inventar información.

> Objetivo: ejemplos cortos. Si crece demasiado, dividir por anexos.

---

## 1) Ejemplo de FR (bien formado)

### FR-001 — Checkout: confirmar pedido

- **Prioridad:** Alta
- **Estado:** Draft
- **Descripción:** El usuario podrá confirmar un pedido con los productos del carrito y una dirección de envío válida.
- **Criterios de aceptación:**
  1. **Dado** un usuario autenticado con un carrito no vacío, **cuando** confirma el pedido, **entonces** se crea un pedido con estado `CREATED`.
  2. **Dado** que la dirección de envío es inválida, **cuando** confirma, **entonces** se muestra un error y no se crea el pedido.
  3. **Dado** un error de stock, **cuando** confirma, **entonces** se informa qué ítems fallan y el pedido no se crea.

---

## 2) Ejemplo de NFR (medible / verificable)

### NFR-001 — Rendimiento: latencia API checkout

- **Objetivo:** P95 < 800 ms para `POST /api/orders` bajo carga nominal definida.
- **Verificación:** prueba de carga (k6) en entorno pre con dataset representativo.
- **Notas:** excluir picos de cold start si aplica.

---

## 3) Ejemplo de UI spec (estados mínimos)

### UI-010 — Pantalla "Checkout"

- **Roles:** Cliente
- **Acciones:**
  - confirmar pedido
  - editar dirección
- **Estados:**
  - **Cargando:** skeleton + botón deshabilitado
  - **Vacío:** si carrito vacío → CTA “Volver a catálogo”
  - **Error:** mensaje no técnico + acción “Reintentar”
  - **Sin permisos:** mensaje + logout (si sesión inválida)
- **Validaciones:**
  - dirección obligatoria
  - email con formato válido

---

## 4) Ejemplo de DECISION → ADR

En documento (por ejemplo `40-arquitectura.md`):

`DECISION: Comunicación asíncrona para confirmación de pedido (ver ADR-0003: adr/ADR-0003-eventing-checkout.md)`

En ADR (`docs/spec/adr/ADR-0003-eventing-checkout.md`):

- Contexto
- Drivers (NFR)
- Opciones (mínimo 2)
- Decisión (o pendiente)
- Consecuencias
- Plan de adopción

---

## 5) Ejemplo de OPENQ (con impacto)

**OPENQ-002 — ¿Se requiere pago en el MVP?**

- **Contexto:** FR-001 y UI-010 asumen confirmación “sin pago” o “con pago”.
- **Impacto:** define flujo UI, integraciones, seguridad y modelo de datos.
- **Bloquea:** `30-ui-spec.md`, `60-backend.md`, ADR de integración pagos.
- **Cómo resolver:** decisión de negocio + proveedor de pago (si aplica).

---

## 6) Ejemplo de TODO (concreto)

### TODO-004 — Definir catálogo de errores API-POST-ORDER

- **Dónde:** `docs/spec/60-backend.md`
- **Motivo:** faltan códigos/formatos de error para validaciones y stock.
- **Prioridad sugerida:** Alta
- **Depende de:** OPENQ-002 (si hay pago cambia catálogo)

---

## 7) Ejemplo de trazabilidad mínima (fila)

| FR | UI | API/EVT | Datos | ADR |
| --- | --- | --- | --- | --- |
| FR-001 | UI-010 | API-001 `POST /api/orders` | Order, OrderItem, Address | ADR-0003 |

---

## 8) Ejemplo de “bloqueante” en review notes

- **Severidad:** Alta  
- **Dónde:** `60-backend.md` (API-001)  
- **Por qué importa:** sin catálogo de errores, el frontend no puede implementar estados/errores coherentes.  
- **Cambio sugerido:** definir errores 400/401/403/409/500 con payload estándar.  
- **Relacionado:** TODO-004
