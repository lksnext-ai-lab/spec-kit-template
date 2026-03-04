# FAQ y troubleshooting

Este documento recoge dudas frecuentes y problemas habituales al usar `spec-kit-template`, junto con soluciones prácticas (especialmente en Windows + VS Code + Copilot + MkDocs).

---

## 1) Copilot / agentes / prompts

### 1.1 ¿Tengo que seleccionar un agente para ejecutar un prompt como `/new-spec`?

No necesariamente. Los prompt files pueden ejecutarse sin seleccionar un agente.

Recomendación:

- usar prompts como “procedimientos”
- y agentes como “roles” cuando quieras un comportamiento más guiado.

Si un equipo está empezando, es totalmente válido trabajar solo con prompts.

---

### 1.2 Error: "File './adr/ADR-####-SLUG.md' not found at '.github/prompts/...'"

**Causa típica:** hay un enlace relativo en un archivo dentro de `.github/**` (prompts/agentes).  
VS Code/Copilot resuelve rutas relativas desde esa carpeta, no desde `docs/spec/`.

**Solución:**

- dentro de `.github/**` usar rutas desde la raíz del repo:
  - ✅ `docs/spec/adr/ADR-0001-template.md`
  - ❌ `./adr/ADR-0001-template.md`
- si quieres mostrar un ejemplo de enlace “para spec”, ponlo como texto/código, no como link Markdown, para evitar warnings.

---

### 1.3 Warning en VS Code: “Link … not found” en un prompt/agent

**Causa:** el validador de Markdown intenta resolver el link relativo desde `.github/prompts/` o `.github/agents/`.

**Solución recomendada:**

- en prompts/agentes evita links Markdown relativos.
- escribe rutas como texto o en bloque de código.

Ejemplo:

```txt
En docs/spec usa: adr/ADR-####-<slug>.md
En .github usa: docs/spec/adr/ADR-####-<slug>.md
```

---

### 1.4 ¿Puede un custom agent llamar a otro custom agent?

Sí. El **Director** invoca a todos los subagentes de forma programática (vía `tools: ['agent']`), sin intervención del usuario. El flujo completo es:

- El usuario habla únicamente con el Director.
- El Director explica qué va a hacer, pide confirmación, delega al subagente y presenta el resultado.
- Si un subagente genera OPENQs o necesita información del usuario, el Director actúa como relay: formula la pregunta al usuario en lenguaje claro y, con la respuesta, re-invoca al subagente.
- No hay botones de handoff ni cambios manuales de agente.

---

### 1.5 “No inventar” me deja demasiadas OPENQ, ¿es normal?

Sí. La calidad de una spec mejora cuando:

- las dudas están explícitas,
- y se distinguen de afirmaciones.

Buenas prácticas:

- resolver OPENQ por "bloque" (MVP primero),
- cerrar OPENQ críticas antes de compartir una versión final,
- diferir lo no bloqueante a iteraciones posteriores (I02, I03…).

---

### 1.6 El plan (`docs/spec/01-plan.md`) se ha hecho enorme o se mezclan I01/I02

**Síntomas típicos:**

- el plan contiene secciones duplicadas o tareas "arrastradas" de otra iteración,
- Copilot intenta "reemplazar desde la sección X hasta el final" y acaba mezclando contenido,
- el archivo crece tanto que planificar/redactar se vuelve lento y confuso.

**Causa típica:**

- se usa `01-plan.md` como histórico/backlog, en lugar de plan **único de la iteración activa**.

**Solución recomendada:**

1. Cierra la iteración anterior con `/close-iteration`:

   - archiva snapshots en `docs/spec/history/Ixx/`,
   - limpia `01-plan.md` para que represente **solo** la siguiente iteración.
2. Mantén `01-plan.md` con 5–15 tareas por iteración (si hay más, divide en Iyy).

**Si ya está mezclado y necesitas “desliarlo” manualmente:**

- restaura el plan correcto desde `docs/spec/history/Ixx/01-plan.md` (si existe),
- o reescribe `docs/spec/01-plan.md` dejando solo:

  - Iteración Iyy (metadatos),
  - objetivo + alcance IN/OUT,
  - placeholder para regenerar con `/plan-iteration`.

---

### 1.7 Copilot propone borrar archivos o ejecutar `Remove-Item` y sale “Auto approval denied”

**Síntoma típico:**
Copilot intenta ejecutar un comando tipo `Remove-Item ...` y VS Code muestra algo como:

- "Run pwsh command? Auto approval denied by rule Remove-Item (default)"
- opciones: Allow / Skip

**Contexto:**

- Es normal que el entorno bloquee comandos destructivos por seguridad.
- Además, en este repo **preferimos** que los prompts/agentes resuelvan con **edición de ficheros**, no con borrados.

**Qué hacer:**

- Elige **Skip**.
- Pide (o aplica) una solución no destructiva:

  - copiar contenido a `docs/spec/history/Ixx/...`,
  - reescribir los archivos activos con plantillas limpias,
  - y dejar el histórico como snapshots.

**Recomendación:**

- Usa `/close-iteration` para el cierre: está diseñado para **no depender** de borrados ni comandos shell.

---

### 1.8 ¿Ejecuto el plan o lo reviso primero? ¿Qué significa “revisar plan”?

**Ejecuto el plan** cuando:

- `docs/spec/01-plan.md` está claro, corto y verificable,
- no hay bloqueantes evidentes,
- las tareas tienen DoD comprobable y archivos acotados.

**Reviso el plan** cuando:

- el plan parece demasiado grande,
- hay gates sin registrar,
- el orden de tareas no es lógico,
- o hay señales de mezcla con otra iteración.

“Revisar plan” significa comprobar, como mínimo:

- Iteración y estado correctos (Ixx, Draft/En curso/En revisión),
- 5–15 tareas atómicas (no mini-Jira),
- DoD verificable,
- OPENQ/DECISION enlazadas si bloquean,
- entregables claros (qué archivos deben cambiar en esta iteración).

---

## 2) Git / repositorios / template

### 2.1 ¿Los cambios del template se propagan automáticamente a repos creados desde él?

No. Crear un repo desde un template copia el contenido en ese momento, pero no se actualiza solo.

Opciones:

- mantener cada repo "congelado" con la versión usada,
- o hacer upgrades manuales (por PR) copiando cambios en `.github/**` y configuración.

---

### 2.2 Tengo warnings de LF/CRLF al hacer `git add`

**Causa:** Windows + configuración de autocrlf o line endings inconsistentes.

Soluciones recomendadas:

- añadir `.gitattributes` y fijar line endings (LF),
- usar `git add --renormalize .` tras añadir `.gitattributes`,
- acordar una norma de equipo.

---

## 3) MkDocs (previsualización en navegador)

### 3.1 Error: “El término 'mkdocs' no se reconoce…”

**Causa:** el ejecutable `mkdocs.exe` no está en PATH (común con Python de Microsoft Store).

**Solución:**
Usa MkDocs así:

```powershell
python -m mkdocs serve
```

y para build estricto:

```powershell
python -m mkdocs build --strict
```

---

### 3.2 Pip instala “en user” aunque tengo el venv activado

Puede ocurrir en algunos entornos de Windows (especialmente con Python de Microsoft Store).

Recomendaciones:

1. asegúrate de activar el venv:

   - el prompt debe mostrar `(.venv)`
2. usa siempre:

   - `python -m pip install ...`
3. si persiste, considerar instalar Python desde python.org (si política lo permite).

---

### 3.3 ¿Cómo cambio el puerto de MkDocs?

```powershell
python -m mkdocs serve -a 127.0.0.1:8001
```

---

### 3.4 MkDocs falla por navegación (mkdocs.yml)

Causas típicas:

- rutas mal escritas en `mkdocs.yml`,
- archivos movidos/renombrados sin actualizar nav.

Solución:

- revisar `mkdocs.yml`,
- validar con:

```powershell
python -m mkdocs build --strict
```

---

### 3.5 ¿Se puede usar Mermaid?

Sí, pero requiere:

- habilitar `pymdownx.superfences` (normalmente ya),
- y configurar Mermaid (según enfoque: plugin o JS extra).

Recomendación:

- solo activarlo si el equipo realmente lo va a usar,
- y probar que renderiza bien en Material.

---

## 4) Organización de docs (spec vs kit)

### 4.1 ¿Por qué separar `docs/spec/` y `docs/kit/`?

Para evitar mezcla entre:

- documentación del sistema (kit),
- y documentación del proyecto (spec).

Esto:

- reduce ruido en la spec,
- protege el kit de modificaciones accidentales,
- y facilita navegación en MkDocs.

---

### 4.2 El Writer me ha tocado `docs/kit/**`. ¿Qué hago?

Primero:

- revisar qué cambió (diff),
- revertir si no era solicitado.

Después:

- reforzar instructions/prompt/agent:

  - "No modificar docs/kit salvo solicitud explícita".

---

### 4.3 ¿Qué hago con `docs/spec/history/**`?

`docs/spec/history/**` contiene snapshots por iteración (I01, I02…).

Reglas recomendadas:

- es **solo lectura** para el trabajo diario,
- por defecto prompts/agentes deben **ignorar** el histórico para planificar/redactar/revisar,
- solo `/close-iteration` crea/actualiza dentro de `history/**`.

Si lo incluyes en MkDocs nav:

- hazlo como sección "Histórico" para consulta, no como parte de la spec activa.

---

### 4.4 ¿Qué es el modo evolutivo con codebase?

**Modo evolutivo** es cuando trabajas en la especificación de un proyecto que **ya tiene código implementado**.

Características:

- El codebase está en el workspace (normalmente `codebase/` o similar).
- Los agentes/prompts pueden **leer** el codebase pero **nunca modificarlo** (solo lectura).
- La spec se fundamenta en **evidencia real** del código existente.
- Se genera un **codebase-map.md** con el mapa técnico del sistema.
- Se crean **Evidence Packs (EP-###)** con investigación técnica específica.

**Cuándo usarlo:**

- Evolutivos de sistemas existentes.
- Migraciones/refactors que requieren documentar el estado actual.
- Auditorías técnicas o alineación de spec con implementación.

Ver `docs/kit/60-uso-del-template.md` (sección "Modo evolutivo con codebase") para más detalle.

---

### 4.5 ¿Cuándo debo generar un Evidence Pack?

Genera un **Evidence Pack** (EP-###) cuando:

- Necesitas precisión técnica sobre autenticación/autorización, modelo de datos, integraciones, operación.
- Vas a tomar decisiones arquitectónicas que dependen del código existente.
- Quieres documentar cómo funciona realmente algo crítico en el sistema actual.

**Cómo generarlo:**

- Usa el prompt `/evidence-pack` o el skill `evidence_pack`.
- Salida: `docs/spec/_inputs/evidence/EP-###-<tema>.md`

**No generar EP para:**

- Consultas rápidas (usa búsquedas directas en el codebase).
- Información obvia o ya mapeada en `codebase-map.md`.

Ver `docs/kit/70-operativa-diaria.md` (sección "Operativa en modo evolutivo") para más detalle.

---

### 4.6 ¿Qué es la verificación externa y cuándo se requiere?

**Verificación externa** es el proceso de consultar fuentes oficiales (documentación, repos, releases) para confirmar información sobre:

- Integraciones con servicios externos.
- SDKs/APIs y sus capacidades/límites.
- Compatibilidades y versiones.
- Licencias y políticas de uso.
- Pasos de instalación y configuración.

**Herramientas obligatorias:**

1. **Primaria**: `playwright-mcp` (navegación web automatizada).
2. **Fallback**: `chrome-devtools-mcp`.
3. Si ninguna está disponible: registrar `OPENQ-###` o pedir al usuario que aporte la información.

**Registro obligatorio:**

- Siempre añadir subsección `### Fuentes` en el documento afectado con:
  - URL + fecha (YYYY-MM-DD) + qué se extrajo (1 línea)

**Prioridad de fuentes:**

- Documentación oficial > repo oficial > releases > issues/discussions

Ver `.github/copilot-instructions.md` (sección "Verificar con fuentes externas") para más detalle.

---

### 4.7 ¿Qué hago si no tengo acceso a playwright-mcp?

Si `playwright-mcp` (o `chrome-devtools-mcp`) no está disponible cuando necesitas verificar información externa:

**Opciones:**

1. **Registrar `OPENQ-###`** indicando:
   - Qué información falta verificar.
   - Qué fuentes deberían consultarse.
   - Impacto de no tener esta información.

2. **Pedir al usuario** que:
   - Aporte la información manualmente.
   - O añada snapshots/capturas al repo como documentación auxiliar.

3. **Si es información crítica**: marcar la tarea como **bloqueada** hasta que se resuelva el acceso.

**No inventar**: nunca completar con suposiciones cuando se trata de APIs externas, límites, compatibilidades o licencias.

---

## 5) Calidad de la spec

### 5.1 FR sin criterios verificables

Solución:

- reescribir FR con criterios de aceptación tipo "Dado/Cuando/Entonces",
- añadir prioridad/estado,
- enlazar a UI/API si aplica.

---

### 5.2 NFR vagos (“rápido”, “seguro”, “escalable”)

Solución:

- convertirlos en métrica objetivo (SLO/umbral) o verificación explícita,
- asociar a drivers (seguridad, rendimiento, coste, compliance).

---

### 5.3 Muchas DECISION sin ADR

Solución:

- ejecutar `/review-and-adr`,
- revisar que el reviewer enlaza ADR desde el punto de DECISION.

---

## 6) Si algo no encaja

Si encuentras un caso que no cubre el kit:

- registra una nota en `docs/spec/97-review-notes.md` (si aplica a una spec concreta),
- o abre una issue/nota interna para mejorar el template,
- describe:

  - qué intentabas hacer,
  - qué pasó,
  - qué esperabas,
  - y cómo lo resolverías.

Esto alimenta la evolución del spec-kit sin improvisar cambios.

---

## 7) Exportación a DOCX

### 7.1 Error: “No se encuentra 'pandoc' en PATH”

Síntoma:

- el script falla indicando que no localiza `pandoc`.

Solución:

1. Verificar:

   ```powershell
   pandoc --version
   ```

2. Instalar Pandoc y reintentar (según política de tu equipo):

   - Windows (Chocolatey):

     ```powershell
     choco install pandoc
     ```

   - O instalador oficial de Pandoc.

---

### 7.2 El DOCX sale con formato raro (tablas/diagramas)

Limitaciones típicas:

- Mermaid/diagramas pueden no renderizar sin configuración adicional.
- Tablas complejas o HTML embebido pueden perder fidelidad.

Recomendación:

- preferir Markdown "simple" (tablas razonables, headings claros),
- revisar el resultado y ajustar contenido si el DOCX es un entregable formal.

---

### 7.3 ¿Por qué no aparece TOC (tabla de contenidos)?

Por defecto, el export está pensado para **no incluir TOC** salvo que lo pidas explícitamente.

Solución:

- ejecuta con `--toc` si quieres tabla de contenidos.

Ejemplo:

```powershell
python tools\export_docx.py --scope spec --output exports\spec.docx --title "Especificación técnica" --toc
```

---

Siguiente lectura recomendada:

- Anexos y ejemplos: `docs/kit/99-anexos-ejemplos.md`
