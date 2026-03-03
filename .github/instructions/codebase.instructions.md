---
applyTo: "codebase/**"
---

# Codebase instructions (codebase/**)

Estas instrucciones aplican al repositorio de código cuando está presente en el workspace como `codebase/**`.

## Regla 0: SOLO LECTURA

- `codebase/**` es **read-only**.
- No crear, borrar ni modificar archivos en `codebase/**`.
- Cualquier cambio a implementar se describe en `docs/spec/**` o en tareas SPC-IMP, pero no se aplica aquí.

## Objetivo del modo evolutivo

Usar el codebase como fuente de verdad **as-is** para:

- confirmar stack, módulos y arquitectura real,
- encontrar endpoints, modelos, permisos, flujos,
- fundamentar decisiones y requisitos,
- evitar inventar.

## Protocolo de evidencia

Cuando se afirme algo técnico sobre el as-is:

1) **Citar evidencia** con rutas concretas:
   - `codebase/<ruta/al/archivo>` (+ clase/función relevante)
2) Si la evidencia es amplia o compleja:
   - crear un **Evidence Pack** en `docs/spec/_inputs/evidence/EP-###-<tema>.md`
   - y enlazarlo desde la spec
3) Si tras buscar no hay evidencia suficiente:
   - registrar `OPENQ-###` indicando:
     - qué se intentó verificar
     - dónde se buscó (rutas y términos)
     - qué falta para cerrar la duda

## Buenas prácticas de búsqueda

- Buscar por:
  - nombres de endpoints/routers/controllers
  - nombres de servicios (`*Service`)
  - permisos/roles (`permission`, `scope`, `role`, `policy`)
  - entidades/modelos (ORM)
  - configuración (`env`, `settings`, `config`, `yaml`)
- Revisar:
  - módulos “core” y “infra”
  - tests si existen
  - documentación interna del repo

## Qué producir a partir del codebase (outputs típicos)

- `docs/spec/_inputs/codebase-map.md` (mapa técnico resumido)
- Evidence Packs en `docs/spec/_inputs/evidence/`
- `OPENQ-###` en `docs/spec/95-open-questions.md` cuando falte evidencia

## Prohibiciones (anti-invención)

- No “deducir” implementaciones no vistas.
- No asumir que un patrón existe “porque suele existir”.
- No afirmar que un endpoint existe si no se encuentra.
- No describir modelos/campos sin evidencia.

## Nota sobre verificación externa

La verificación externa (web, herramientas, etc.) solo se usa si es necesaria para no inventar.
Si no se puede verificar, registrar `OPENQ`.
