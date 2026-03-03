---
category: project
scope: spec
status: stable
---

# Skill: generate-tool-permissions

## Propósito

Generar `TOOL_PERMISSIONS` completo (148 entries) a partir de la tabla de `docs/spec/60-backend.md` (sección 3) y actualizar `EP-001` sección 5 con el mapeo completo.

> Este skill es **project-specific** (no forma parte del framework spec-kit). Mantiene documentación sincronizada con la definición actual del backend.

## Cuándo usar

- Completar el TODO asociado a la generación de `TOOL_PERMISSIONS` en evidencia (p.ej. `TODO-I03-012`)
- Regenerar `TOOL_PERMISSIONS` tras cambios en la tabla de tools de `60-backend.md`
- Validar consistencia entre la tabla de tools y el mapeo publicado en evidencias

## Protocolo de ejecución

### 1) Leer tabla de tools (60-backend.md sección 3)

- Archivo: `docs/spec/60-backend.md`
- Sección: `## 3. Mapeo completo Endpoints HTTP → Tools MCP`
- Columnas esperadas: `| Tool Name | Endpoint HTTP | Permission | Sync/Async | Categoría |`
- Parsear **todas** las filas (ignorar header y separador)

### 2) Extraer entries

Por cada fila de tabla:
- **Tool Name**: columna 1 (snake_case, ej: `apps_list`, `public_chat_call`)
- **Permission**: columna 3 (formato `resource:operation`, ej: `apps:read`, `agents:execute`)
- Parsear permission: split por `:` → `(resource, operation)`

Validaciones mínimas:
- Total entries esperado: **148** *(si el backend cambia, este número puede cambiar; en ese caso, no inventar: actualizar el “esperado” solo si la tabla fuente lo justifica)*.
- Formato permission: `^[a-z_]+:(read|write|delete|execute)$`
- No duplicados en `tool_name`

### 3) Generar tabla Markdown

Formato output para EP-001 sección 5:

```markdown
| Tool Name | Resource | Operation |
|-----------|----------|-----------|
| admin_activate_user | admin | write |
| admin_deactivate_user | admin | write |
| ... (entries ordenados alfabéticamente) |
| version_get | version | read |

**Total: 148 tools mapeados**
```

Orden: alfabético por `tool_name`.

### 4) Generar dict Python (opcional, para código middleware)

```python
# Auto-generated - DO NOT EDIT MANUALLY
TOOL_PERMISSIONS = {
    "admin_activate_user": ("admin", "write"),
    "admin_deactivate_user": ("admin", "write"),
    # ... entries
    "version_get": ("version", "read"),
}
```

### 5) Actualizar EP-001 sección 5

* Archivo: `docs/spec/_inputs/evidence/EP-001-permisos-api-keys-actual.md`
* Localizar: `## 5. TOOL_PERMISSIONS: mapeo tool → permisos`
* Reemplazar el contenido actual con:

  * Tabla Markdown completa (todas las entries)
  * Sub-sección `### Dict Python para middleware` con el dict generado (si aplica)
  * Nota de trazabilidad: “Auto-generado desde `60-backend.md` sección 3 (YYYY-MM-DD)”

### 6) Validación post-generación

* Contar entries: debe ser **148** (o el total real de la tabla fuente, si ha cambiado)
* Spot-check manual: revisar 10–15 entries aleatorios contra la tabla original
* Verificar categorías representadas (orientativo):

  * Internal: apps, agents, silos, ai_services, api_keys, domains, embedding_services, mcp_configs, mcp_servers, ocr, output_parsers, repositories, folders, collaboration, admin, version, usage_stats, conversations, auth, user
  * Public: agents, chat, files, ocr, repositories, resources, silos
* Verificar operaciones: read, write, delete, execute

### 7) Actualizar documentos relacionados

Si cambios significativos o cierre de un TODO:

* `docs/spec/96-todos.md`: marcar `TODO-I03-012` como DONE (o el TODO vigente equivalente)
* `docs/spec/01-plan.md`: **si el plan actual incluye una fila `Pxx` para esta actividad**, actualizar su estado (DONE / notas).

  > No usar `Txx` aquí: `Txx` es para implementación (`docs/spec/spc-imp-*`), no para el plan de SPEC.

## Reglas críticas

* **NO inventar permisos**: usar exactamente los valores de la columna “Permission” en `60-backend.md`
* **NO omitir entries**: nada de “omitido por brevedad” en el output final de EP-001
* **Formato consistente**: snake_case en tool names; lowercase en resource/operation
* **Evidencia**: citar `60-backend.md` sección 3 como fuente
* **Fecha**: registrar fecha de generación en EP-001

## Output esperado

Al completar este skill:

1. EP-001 sección 5 actualizada con tabla completa (todas las entries)
2. (Opcional) dict Python `TOOL_PERMISSIONS` generado (copiable para middleware)
3. TODO de referencia marcado DONE (si aplica)
4. Mensaje de confirmación: `✓ TOOL_PERMISSIONS actualizado: <N> tools mapeados desde 60-backend.md`

## Ejemplo output (primeras 5 entries)

```markdown
| Tool Name | Resource | Operation |
|-----------|----------|-----------|
| admin_activate_user | admin | write |
| admin_deactivate_user | admin | write |
| admin_delete_user | admin | delete |
| admin_get_stats | admin | read |
| admin_get_user | admin | read |
```

## Troubleshooting

* **“menos entries de las esperadas”**: verificar que la tabla en `60-backend.md` esté completa (no truncada)
* **permission sin `resource:operation`**: revisar columna 3 de la tabla; debe incluir `:` y operación válida
* **duplicados**: `tool_name` debe ser único (revisar typos en la tabla)
