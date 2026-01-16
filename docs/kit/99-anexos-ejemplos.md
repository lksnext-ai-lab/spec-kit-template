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

### 1.2 Error: “File './adr/ADR-####-<slug>.md' not found at '.github/prompts/...'”
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
````

---

### 1.4 ¿Puede un custom agent llamar a otro custom agent?

En la práctica, lo habitual es que:

* tú selecciones el agente adecuado,
* o ejecutes un prompt concreto,
  y el “handoff” se haga como recomendación (“siguiente paso: usa Planner / ejecuta /plan-iteration”).

Si quieres automatizar encadenado de agentes, eso depende de las capacidades concretas del entorno (Copilot / VS Code / configuración disponible). El diseño del spec-kit ya está preparado para que el flujo se ejecute como:

* prompts encadenables,
* o agentes por rol.

---

### 1.5 “No inventar” me deja demasiadas OPENQ, ¿es normal?

Sí. La calidad de una spec mejora cuando:

* las dudas están explícitas,
* y se distinguen de afirmaciones.

Una buena práctica es:

* resolver OPENQ por “bloque” (MVP primero),
* y cerrar las OPENQ críticas antes de compartir una versión final.

---

## 2) Git / repositorios / template

### 2.1 ¿Los cambios del template se propagan automáticamente a repos creados desde él?

No. Crear un repo desde un template copia el contenido en ese momento, pero no se actualiza solo.

Opciones:

* mantener cada repo “congelado” con la versión usada,
* o hacer upgrades manuales (por PR) copiando cambios en `.github/**` y configuración.

---

### 2.2 Tengo warnings de LF/CRLF al hacer `git add`

**Causa:** Windows + configuración de autocrlf o line endings inconsistentes.

Soluciones recomendadas:

* añadir `.gitattributes` y fijar line endings (LF),
* usar `git add --renormalize .` tras añadir `.gitattributes`,
* acordar una norma de equipo.

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

   * prompt debe mostrar `(.venv)`
2. usa siempre:

   * `python -m pip install ...`
3. si persiste, considerar instalar Python desde python.org (si política lo permite).

---

### 3.3 ¿Cómo cambio el puerto de MkDocs?

```powershell
python -m mkdocs serve -a 127.0.0.1:8001
```

---

### 3.4 MkDocs falla por navegación (mkdocs.yml)

Causas típicas:

* rutas mal escritas en `mkdocs.yml`
* archivos movidos/renombrados sin actualizar nav

Solución:

* revisar `mkdocs.yml`
* validar con:

```powershell
python -m mkdocs build --strict
```

---

### 3.5 ¿Se puede usar Mermaid?

Sí, pero requiere:

* habilitar `pymdownx.superfences` (normalmente ya)
* y configurar Mermaid (según enfoque: plugin o JS extra)

Recomendación:

* solo activarlo si el equipo realmente lo va a usar,
* y probar que renderiza bien en Material.

---

## 4) Organización de docs (spec vs kit)

### 4.1 ¿Por qué separar `docs/spec/` y `docs/kit/`?

Para evitar mezcla entre:

* documentación del sistema (kit),
* y documentación del proyecto (spec).

Esto:

* reduce ruido en la spec,
* protege el kit de modificaciones accidentales,
* y facilita navegación en MkDocs.

---

### 4.2 El Writer me ha tocado `docs/kit/**`. ¿Qué hago?

Primero:

* revisar qué cambió (diff),
* revertir si no era solicitado.

Después:

* reforzar instructions/prompt/agent:

  * “No modificar docs/kit salvo solicitud explícita”.

---

## 5) Calidad de la spec

### 5.1 FR sin criterios verificables

Solución:

* reescribir FR con criterios de aceptación tipo “Dado/Cuando/Entonces”
* añadir prioridad/estado
* enlazar a UI/API si aplica

---

### 5.2 NFR vagos (“rápido”, “seguro”, “escalable”)

Solución:

* convertirlos en métrica objetivo (SLO/umbral) o verificación explícita
* asociar a drivers (seguridad, rendimiento, coste, compliance)

---

### 5.3 Muchas DECISION sin ADR

Solución:

* ejecutar `/review-and-adr`
* revisar que el reviewer enlaza ADR desde el punto de DECISION

---

## 6) Si algo no encaja

Si encuentras un caso que no cubre el kit:

* registra una nota en `docs/spec/97-review-notes.md` (si aplica a una spec concreta)
* o abre una issue/nota interna para mejorar el template
* describe:

  * qué intentabas hacer,
  * qué pasó,
  * qué esperabas,
  * y cómo lo resolverías.

Esto alimenta la evolución del spec-kit sin improvisar cambios.
