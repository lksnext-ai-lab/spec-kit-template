# Copilot Instructions (Repo-wide)

Estas instrucciones aplican a todo el repositorio.  
Además, existen instrucciones **por ruta** en `.github/instructions/*.instructions.md` que afinan el comportamiento según el área (SPEC / KIT / plataforma /.github / codebase).

## Principios globales (siempre)

1) **Director-first (obligatorio en modo agente):** el flujo se orquesta desde `spc-spec-director`, la única puerta de entrada visible al usuario. Los 9 subagentes operan con `user-invocable: false` y solo se activan por delegación del Director. El usuario expresa intención ("qué quiere"), no el procedimiento interno.
2) **No inventar:** si falta información o evidencia, registrar `OPENQ-###` (o `TODO-###` si es trabajo pendiente) en los ficheros correspondientes.
3) **Cambios pequeños y diff-friendly:** evitar reescrituras masivas y cambios cosméticos. Cambiar solo lo necesario.
4) **Sin operaciones destructivas:** no usar comandos de shell/PowerShell/Bash para borrar/limpiar ni modificar cosas fuera del alcance pedido.
5) **Fuentes de verdad por zona:**
   - `docs/spec/**` = especificación viva (principal) → es el destino por defecto de “actualiza la documentación”.
   - `docs/kit/**` = guía del sistema → **NO modificar** salvo petición **explícita** de cambiar el KIT. Si no se pide, proponer cambios como recomendación o registrar `TODO` en SPEC.
   - `docs/spec/history/**` = histórico → ignorar por defecto; solo se toca al cerrar iteración.
   - `codebase/**` (si existe) = fuente técnica as-is → **solo lectura**.
6) **Separación de IDs:**
   - SPEC plan: `P01..Pnn` en `docs/spec/01-plan.md`
   - Implementación: `T01..Tnn` en `docs/spec/spc-imp-*`
   - No mezclar `Txx` dentro del plan de SPEC.
7) **Verificación externa solo si es necesaria para no inventar:** si no se puede verificar, registrar OPENQ. Si se usa verificación externa, incluir `### Fuentes` (URL + fecha + 1 línea) en el documento afectado.

## Arquitectura agéntica

El sistema usa un patrón Director + 9 subagentes organizados en 4 fases secuenciales con gates humanos entre ellas:

| Fase | Propósito | Agentes |
|------|-----------|----------|
| 1 — Entender | Capturar contexto y requisitos | `spc-spec-intake` |
| 2 — Especificar | Planificar, redactar y revisar spec | `spc-spec-planner` → `spc-spec-writer` ⇄ `spc-spec-reviewer` |
| 3 — RFC | Formalizar cambios relevantes | `spc-rfc-writer` ⇄ `spc-rfc-reviewer` |
| 4 — Implementar | Backlog, fichas y cobertura | `spc-imp-backlog-slicer` → `spc-imp-task-detailer` ⇄ `spc-imp-coverage-auditor` |

Reglas de delegación:
- La delegación es **100% programática** (`tools: ['agent']`). No hay handoffs ni botones clicables.
- El Director es el único interlocutor del usuario. Antes de cada delegación: explica qué va a hacer, qué agente usará, qué archivos tocará, y espera confirmación del usuario.
- Para intake (Fase 1), el Director conduce él mismo la entrevista multi-turno con el usuario (patrón stepper) y luego delega a `spc-spec-intake` en one-shot para formalizar los documentos.
- Los subagentes tienen `user-invocable: false` y NO aparecen en el selector de agentes. Solo son accesibles vía delegación programática del Director.
- No invocar más de 2 subagentes programáticamente sin presentar resultados intermedios al usuario.
- El Director NO hace el trabajo de los subagentes: analiza, decide la fase, explica, pide confirmación, delega y consolida resultados.

### Política CHANGE: Patch vs RFC

- **RFC obligatorio** si afecta a: datos/migraciones, auth/roles, compatibilidad API/contratos, seguridad/compliance, NFR críticos, integraciones externas, alcance/coste/riesgo relevante.
- **Patch** solo si es aclaración/corrección menor sin impacto en lo anterior.
- En caso de duda → RFC.

## Proceso recomendado (alto nivel)

Ciclo interno en cada fase: **Plan → Write → Review → Iterate**  
Cierre formal (opcional recomendado): **Close iteration** para archivar snapshot y limpiar estado vivo.

Reglas operativas:
- `docs/spec/01-plan.md` representa una **única iteración activa** (no un backlog infinito).
- Si el plan mezcla iteraciones, usar el procedimiento de cierre de iteración; no "limpiar manualmente" a ciegas.
- El Director decide automáticamente a qué fase/subagente derivar según el estado actual de la SPEC.

## Enlaces y rutas

- En `.github/**` (agentes/prompts/skills/workflows), usar rutas desde raíz: `docs/spec/...` (evitar enlaces relativos ambiguos).
- En `docs/spec/**`, los enlaces relativos son válidos (por ejemplo `adr/ADR-0002-...md`).

## Si hay conflicto entre instrucciones

Prioridad:
1) Estas instrucciones globales
2) Instrucciones por ruta en `.github/instructions/*.instructions.md`
3) Contenido del prompt/agent activo (siempre respetando 1 y 2)
4) Skills (patrones de calidad)

Si una instrucción local contradice una global, prevalece la global.
