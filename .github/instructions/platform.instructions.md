---
applyTo: ".github/**"
---

# Platform instructions (.github/**)

Estas instrucciones aplican a la “plataforma” del repo: agentes, prompts, skills, workflows e instrucciones.

## Reglas duras

1) **Rutas desde raíz (obligatorio)**
   - En `.github/**` usar siempre rutas desde raíz del repo: `docs/spec/...`
   - Evitar enlaces relativos (`../..`) y rutas ambiguas

2) **No romper contratos**
   - Si un archivo define un comando, un agente o un skill, mantener su interfaz estable:
     - nombres de comandos (`/new-spec`, `/plan-iteration`, etc.)
     - nombres de agentes (`spc-...`)
     - estructura y propósito de cada skill
   - Si hay que renombrar/migrar, hacerlo completo:
     - actualizar referencias en docs/kit y en `.github/**`
     - y dejar el repo coherente (sin restos)

3) **Cambios mínimos, intención clara**
   - Evitar “refactors” cosméticos
   - Cambiar solo lo necesario por coherencia, claridad o corrección
   - Mantener el lenguaje operativo (qué hace / entradas / salidas / archivos)

4) **Convenciones de naming y formato**
   - Agents: `.github/agents/spc-<fase>-<rol>.agent.md`
   - Prompts: `.github/prompts/*.prompt.md`
   - Skills: `.github/skills/<skill>/SKILL.md` (carpeta + `SKILL.md`)
   - Instructions: `.github/copilot-instructions.md` y `.github/instructions/*.instructions.md`

5) **Separación SPEC vs IMP**
   - SPEC plan usa `Pxx` en `docs/spec/01-plan.md`
   - Implementación usa `Txx` en `docs/spec/spc-imp-*`
   - No mezclar IDs en los artefactos equivocados

6) **Histórico**
   - `docs/spec/history/**` debe estar excluido por defecto de procesos operativos (lint, plan, write, review).
   - Solo se toca al cerrar iteraciones.

7) **No inventar**
   - No afirmar que existe un archivo/comando/agente si no existe en el repo.
   - Si falta algo: proponerlo como cambio explícito o registrar TODO en SPEC.

## Edición de agentes y prompts

- Mantener entradas y salidas claras.
- Incluir rutas de archivos explícitas en “Outputs”.
- Evitar instrucciones contradictorias entre prompts/agentes.
- Los prompt files deben ser ejecutables y reproducibles (procedimiento consistente).

## Edición de skills

- Un skill es un patrón reutilizable: propósito, cuándo usar, protocolo, outputs, validaciones.
- Evitar “marcar progreso” en plan SPEC con IDs Txx.
- Preferir reglas verificables y validaciones (conteos, formatos, criterios).
