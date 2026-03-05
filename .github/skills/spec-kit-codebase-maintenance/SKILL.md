---
category: spec-kit
scope: codebase
status: stable
---

# Skill: codebase_maintenance

## Objetivo

Definir **cuándo y cómo** actualizar la documentación derivada del codebase
(`codebase-map.md` y Evidence Packs) tras cambios en `codebase/**`,
evitando burocracia innecesaria.

Este skill lo consume `spc-codebase-discovery` (modo `refresh`) y el Director
(para decidir si proponer refresh post-implementación).

---

## Principios

- **Mantenimiento proporcional:** solo actualizar lo impactado por el cambio real.
- **Sin burocracia:** refactors internos sin cambio funcional NO requieren actualización.
- **Diff-friendly:** nunca reescribir el mapa/EP completo; solo secciones afectadas.
- **Opt-in:** la actualización es una sugerencia del Director, no una obligación automática.

---

## Señales de obsolescencia

El Director o los agentes pueden detectar obsolescencia mediante:

1) **Fecha:** `last_updated` en `codebase-map.md` > 60 días → WARN.
2) **Cruce de áreas:** si una tarea Txx completada (tipo `code-change` o `migration`)
   opera sobre un área listada en `areas_covered` del mapa → sugerir refresh.
3) **OPENQ resuelta:** si se cierra una OPENQ que referenciaba el mapa o un EP,
   verificar si esa resolución afecta al contenido documentado.

---

## Tabla de actualización: tipo de cambio → acción

| Tipo de cambio en codebase | Acción sobre `codebase-map.md` | Acción sobre Evidence Packs |
|---------------------------|-------------------------------|----------------------------|
| Nuevo módulo/servicio | Añadir sección en "Módulos/capacidades" | Recomendar EP si es crítico (auth/datos/integración) |
| Cambio de stack/framework | Actualizar "Stack y tooling" | Actualizar EP de stack si existe |
| Nuevo endpoint/API | Actualizar "Interfaces públicas" | EP solo si es integración externa |
| Cambio de modelo de datos/migraciones | Actualizar "Persistencia" | Actualizar EP de datos si existe |
| Cambio de auth/roles/permisos | Actualizar sección relevante | Actualizar o crear EP (tema crítico) |
| Cambio de CI/CD o infra | Actualizar "Operación" | EP solo si afecta a despliegue |
| Nuevo entrypoint | Actualizar "Entrypoints y bootstrap" | No requiere EP |
| Cambio de config/env | Actualizar "Operación" (config) | No requiere EP salvo secretos |
| Refactor interno (sin cambio funcional) | **No tocar** | **No tocar** |
| Renombrado de módulos (sin cambio funcional) | Actualizar nombres/rutas en secciones afectadas | Actualizar rutas en EPs afectados |
| Eliminación de módulos | Eliminar/marcar sección del módulo | Marcar EP como obsoleto si aplica |

---

## Protocolo de refresh (para `spc-codebase-discovery` modo `refresh`)

### Paso 1 — Determinar scope
- Recibir `CHANGED_AREAS` o inferirlas cruzando tareas Txx completadas con el mapa.
- Mapear cada área cambiada a secciones del mapa.

### Paso 2 — Actualizar secciones afectadas
- Leer la sección actual del mapa.
- Re-verificar en `codebase/` las rutas/módulos de esa sección.
- Actualizar con evidencia nueva, sin tocar el resto del mapa.
- Actualizar `last_updated` y `areas_covered`.

### Paso 3 — Evaluar EPs
- Si un EP existente cubre un área cambiada:
  - Verificar que sus conclusiones confirmadas siguen siendo válidas.
  - Actualizar las que hayan cambiado.
  - Marcar como obsoletas las que ya no apliquen.
- Si hay un área nueva crítica sin EP: recomendar (o crear 1 máximo).

### Paso 4 — Registrar cambios
- Documentar qué secciones se actualizaron y por qué.
- Registrar OPENQs nuevas si procede.

---

## Cuándo NO actualizar

- Refactors internos que no cambian comportamiento observable.
- Cambios de estilo/formato en el código (linting, formatting).
- Actualización de dependencias menores sin cambio de API.
- Corrección de bugs que no alteran la arquitectura ni los contratos.

**Regla:** si alguien pregunta "¿el mapa sigue siendo correcto?", la respuesta debería
ser "sí" después de estos cambios. Si lo es → no actualizar.

---

## DoD del refresh

- [ ] Solo secciones impactadas actualizadas (no reescritura completa).
- [ ] `last_updated` y `areas_covered` actualizados.
- [ ] EPs afectados revisados/actualizados.
- [ ] Sin secciones no impactadas modificadas.
- [ ] OPENQs registradas si hay gaps nuevos.
