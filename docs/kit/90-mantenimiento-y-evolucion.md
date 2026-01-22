# Evolución y comunicación de cambios del spec-kit

Este documento recoge dos ideas:

1) cómo comunicar y gestionar cambios del `spec-kit-template` cuando ya hay varias personas/equipos usándolo,
2) y una visión de evolución: líneas de mejora que podrían explorarse para ampliar el valor del sistema.

> Nota: este documento no busca definir un proceso “pesado” de mantenimiento, sino aportar un marco práctico y realista.

---

## 1) Comunicación de cambios

### 1.1 Por qué es importante

Cambiar el template (prompts, agentes, skills, estructura, convenciones) puede afectar a:

- cómo se genera y revisa la documentación a partir de ese momento,
- cómo se comportan los asistentes (calidad, estilo, rutas, reglas),
- y la consistencia entre distintas specs generadas en momentos diferentes.

En la práctica, el impacto más relevante no es “romper el repositorio”, sino **cambiar el comportamiento del sistema** y, por tanto, el tipo de documentación que se produce.

### 1.2 Naturaleza del impacto: no hay “replicabilidad perfecta”

Aunque en teoría una herramienta sugiere replicabilidad, en este caso hay dos realidades:

- la generación asistida por IA no es estrictamente determinista,
- y la redacción humana tampoco lo es.

Por eso, el foco no debería ser exigir “reproducir exactamente” una spec pasada, sino:

- entender qué ha cambiado en el sistema,
- evaluar el impacto esperado en futuras specs,
- y dar visibilidad al equipo sobre el nuevo comportamiento deseado.

### 1.3 Canal recomendado

Se recomienda mantener un único canal “oficial” para comunicar cambios del spec-kit. Ejemplos:

- un canal de Teams (p.ej. `#spec-kit`)
- o un sistema de *release notes* interno.

El objetivo del canal:

- anunciar cambios con un lenguaje práctico (“qué cambia” y “por qué”),
- aportar guía sobre cuándo adoptar el cambio,
- y recoger feedback de quienes lo usan.

### 1.4 Formato recomendado de comunicación

Cuando se publique un cambio relevante, el mensaje debería incluir:

- **Qué se ha cambiado**
  - (ej. “/review-and-adr ahora crea ADRs también al detectar DECISION en arquitectura y seguridad”)
- **Motivación**
  - (ej. “se estaban quedando decisiones implícitas sin ADR”)
- **Impacto esperado**
  - (ej. “más ADRs, más claridad; posiblemente más OPENQ si faltan drivers”)
- **Acción recomendada**
  - (ej. “adoptar en repos nuevos; repos existentes solo si vais a seguir iterando la spec”)
- **Riesgos o notas**
  - (ej. “si hay enlaces relativos en .github, revisad rutas”)

### 1.5 Evaluación de cambios (impactos)

Dado que no existe “replicabilidad exacta”, se recomienda evaluar cambios con un enfoque práctico:

- Probar el flujo completo en un **repo demo** (o un “proyecto ficticio” de referencia)
- Verificar:
  - que los prompts siguen operando solo sobre `docs/spec/**`,
  - que no aparecen rutas rotas,
  - que la salida mantiene calidad (FR/NFR/UI/seguridad/infra),
  - y que MkDocs compila (`mkdocs build --strict`)

Esto funciona como “prueba de aceptación” del sistema, aunque no garantice determinismo total.

---

## 2) Evolución del spec-kit (líneas a explorar)

La versión actual se centra en generar especificaciones técnicas consistentes y navegables. A futuro, este sistema podría convertirse en una base para crear **guardarraíles** y asistencia operativa en el ciclo de desarrollo.

A continuación se proponen líneas de evolución (no compromisos), para debatir y priorizar según valor real.

---

### 2.1 Guardarraíles para desarrollo asistido (Copilot / IA)

Posibilidad: ampliar el kit para ayudar a que el equipo escriba código “mejor” con IA, no solo documentación.

Ejemplos:

- normas y patrones de arquitectura (por stack) como skills de desarrollo
- checklists de seguridad y calidad que se apliquen a PRs
- prompts para refactors seguros y consistentes
- generación de “guardrails” por módulo (backend, frontend, infra)

Objetivo:

- alinear estilo, seguridad y decisiones técnicas en el código, igual que se alinea la spec.

---

### 2.2 Asistencia para estimaciones

Posibilidad: a partir de FR/UI/arquitectura ya documentados, generar apoyo para estimar:

- desglose de trabajo por épicas/historias técnicas
- riesgos y dependencias
- hipótesis que condicionan la estimación (OPENQ)
- escenarios (MVP vs ampliado)

Nota:

- no pretende dar “la estimación definitiva”, sino ayudar a estructurarla y justificarla.

---

### 2.3 Generación de tickets (Jira / Azure DevOps)

Posibilidad: generar tickets a partir de la spec:

- crear historias de usuario desde FR-###
- generar tareas técnicas desde arquitectura/backend/frontend
- enlazar cada ticket con:
  - FR/UI/API/Datos/ADR
- proponer criterios de aceptación y DoD por ticket

Salida posible:

- JSON/CSV importable
- o formato compatible con la API de Jira

---

### 2.4 Planes de prueba y validación

Posibilidad: derivar testing desde la spec:

- casos de prueba funcionales por FR (happy path + edge cases)
- pruebas de permisos/roles (matriz)
- pruebas de error handling (API/Frontend)
- pruebas NFR (carga, resiliencia, seguridad)
- checklists de validación previa a release

Esto cerraría el círculo:
FR → UI/API → pruebas → validación.

---

### 2.5 Observabilidad y operación

Posibilidad: elevar el nivel de “operación real” en la spec y conectarlo con artefactos de implementación:

- catálogo de eventos/logs/metrics por servicio
- dashboards sugeridos
- alertas y umbrales (derivados de NFR)
- runbooks de incidencias

---

### 2.6 Publicación y gobernanza de specs

Posibilidad: mejorar la forma de compartir y gobernar specs dentro de la empresa:

- versión “firmada” o “release” de una spec
- changelog de spec por iteración
- plantillas de revisión formal
- permisos y visibilidad (si las specs son sensibles)

---

## 3) Recomendación práctica: cómo explorar evolución sin romper el core

Para evolucionar sin perder estabilidad:

- Mantener el core (Plan/Write/Review + docs/spec + ADR) como base estable.
- Probar nuevas líneas como “módulos opcionales”:
  - nuevos skills,
  - prompts adicionales,
  - o un directorio `docs/kit/labs/` para experimentos.

Cuando una idea demuestre valor real:

- se integra en el core en una versión mayor/menor,
- y se comunica en el canal oficial.

---

## 4) Siguiente paso sugerido

Definir una lista corta de “ideas de evolución” priorizadas (Top 5) y probar 1 de ellas en un repo demo.

(El objetivo no es imaginar mucho, sino experimentar poco y validar rápido.)

---

Siguiente lectura recomendada:

- FAQ/troubleshooting: `docs/kit/95-faq-y-troubleshooting.md`
