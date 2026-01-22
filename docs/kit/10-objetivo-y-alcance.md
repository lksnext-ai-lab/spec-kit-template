# Objetivo y alcance

Este documento define el propósito de `spec-kit-template`, qué cubre y qué queda fuera, para que el equipo lo use de forma consistente y sin expectativas erróneas.

---

## Objetivo principal

Disponer de un **repositorio plantilla** que permita crear y mantener **especificaciones técnicas en Markdown** de forma:

- **rápida** (arranque guiado y escritura asistida),
- **consistente** (estructura, convenciones y calidad mínima),
- **iterativa** (Plan → Redacción → Revisión),
- **auditable/versionada** (Git),
- **navegable** (MkDocs + Material),
- y con **decisiones explícitas** (ADRs).

En la práctica, el objetivo es que la especificación resultante sea **“ejecutable”**: no como código, sino como documento operativo que guía el desarrollo y reduce ambigüedad.

---

## Alcance funcional (qué cubre)

### 1) Generación y mantenimiento de especificaciones

El template cubre el ciclo completo de creación y evolución de la documentación técnica de un proyecto:

- Contexto, alcance y restricciones
- Requisitos funcionales (FR) con criterios verificables
- Requisitos no funcionales (NFR) medibles o con verificación definida
- Conceptualización (roles, permisos, flujos y reglas)
- Especificación UI (pantallas, estados y comportamiento)
- Arquitectura (componentes/servicios, integraciones)
- Modelo de datos (alto nivel)
- Backend (API, eventos, asincronía, validación, errores)
- Frontend (contratos con backend, estado, navegación)
- Seguridad (baseline, auditoría, amenazas y controles)
- Infra/Operación (entornos, CI/CD, observabilidad, backups/DR)
- Gestión deAZ de OPENQ/TODO/RISK/DECISION
- Decisiones con ADR (alternativas y consecuencias)
- Trazabilidad mínima entre artefactos

### 2) Soporte IA integrado al repositorio

Incluye una “capa operativa” para trabajar con Copilot:

- **Copilot Instructions**: reglas globales del repo
- **Prompt files**: comandos repetibles para cada fase
- **Custom Agents**: roles (intake, planner, writer, reviewer)
- **Skills**: patrones reutilizables para producir contenido consistente

### 3) Previsualización y navegación

Incluye configuración de MkDocs para:

- navegar la spec por secciones,
- previsualizar en navegador,
- y facilitar revisión/lectura por terceros.

---

## Alcance operativo (cómo se usa)

- Se crea un repo nuevo desde el template por cada proyecto/especificación.
- El equipo trabaja por **iteraciones** (I01, I02, …), cada una con un plan ejecutable.
- El contenido evoluciona con commits y, preferiblemente, PRs si hay varios autores.

---

## Fuera de alcance (qué NO cubre)

### 1) Gestión de proyecto / ejecución

- No sustituye a Jira, Azure DevOps, etc.
- No gestiona tiempos, dependencias externas, costes, hitos o asignación formal.

### 2) Diseño visual y entrega UX

- No crea prototipos ni maquetas (Figma, etc.).
- Sí define especificaciones de UI: pantallas, estados, flujos y reglas.

### 3) Implementación y scaffolding de código

- No genera un repositorio de aplicación ni código base.
- No es un generador de microservicios ni un framework.

### 4) Validación contractual o normativa completa

- Puede ayudar a documentar requisitos RGPD, seguridad, etc.,
  pero no sustituye auditorías, DPO, revisiones legales, pentesting u homologaciones.

---

## Criterios de éxito (qué significa que funciona)

Una especificación generada con el template se considera “buena” si:

- La gente de negocio/PO puede leer el alcance y entender el MVP.
- El equipo de desarrollo puede implementar sin “inventar” comportamientos críticos.
- Hay trazabilidad mínima FR ↔ UI ↔ API/EVT ↔ Datos ↔ ADR.
- Las dudas están explicitadas (OPENQ) y las decisiones quedan en ADR.
- Seguridad e infra incluyen operación real (auditoría, secretos, backups, observabilidad).
- El documento se mantiene vivo mediante iteraciones y versionado.

---

## Nota sobre separación de documentación

Este repositorio distingue claramente:

- `docs/spec/**`: documentación de **la especificación** (lo que generan/modifican agentes y equipo para un proyecto).
- `docs/kit/**`: documentación del **template/sistema** (manual interno y guía de uso).

Por defecto, los agentes y prompts deben operar **solo** sobre `docs/spec/**`, salvo petición explícita.

Siguiente lectura recomendada: **`20-conceptos-clave-y-flujo.md`**.
