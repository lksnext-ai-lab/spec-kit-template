# Previsualización en navegador (MkDocs + Material)

Este documento explica cómo previsualizar la documentación (`docs/`) en el navegador usando **MkDocs** con **Material for MkDocs**.

El objetivo es poder leer y revisar la spec de forma cómoda, con navegación, búsqueda y enlaces internos.

---

## 1) Qué se previsualiza

MkDocs renderiza el contenido de `docs/` (incluye `docs/spec/` y `docs/kit/`) usando la configuración de:

- `mkdocs.yml`

Salida típica:
- en local: servidor de desarrollo (hot reload)
- opcional: publicación en GitHub Pages (si se habilita)

---

## 2) Requisitos

- Python instalado (recomendado 3.11+; en Windows vale 3.13 si funciona en tu entorno).
- Acceso a terminal (PowerShell).
- Repositorio clonado.

---

## 3) Crear entorno virtual e instalar dependencias (Windows)

Desde la raíz del repo:

```powershell
cd C:\Dev\<tu-repo>
python -m venv .venv
.\.venv\Scripts\activate
python -m pip install --upgrade pip
python -m pip install mkdocs mkdocs-material
````

> Nota importante (Windows): usa `python -m mkdocs` en vez de `mkdocs` si tu instalación de Python no expone scripts en PATH.
> Esto evita el error: “El término 'mkdocs' no se reconoce...”.

---

## 4) Arrancar el servidor local (recomendado)

Con el venv activado:

```powershell
python -m mkdocs serve
```

Por defecto, verás algo como:

* `http://127.0.0.1:8000/`

Abre esa URL en el navegador.

---

## 5) Validar que todo compila (modo estricto)

Para CI o para verificar enlaces/navegación:

```powershell
python -m mkdocs build --strict
```

Si hay enlaces rotos o entradas de navegación inválidas, `--strict` fallará.

---

## 6) Material for MkDocs: recomendaciones

### 6.1 Funcionalidades útiles

* búsqueda integrada
* navegación lateral
* modo oscuro (si se habilita)
* bloques admonition (`!!! note`, `!!! warning`, etc.)
* tablas y código con buen render

### 6.2 Recomendación de estilo

* mantener títulos cortos y claros
* usar listas y tablas
* usar admonitions para notas operativas

Ejemplo:

```md
!!! warning "Bloqueante"
    Esta decisión requiere ADR antes de continuar.
```

---

## 7) Troubleshooting rápido (problemas típicos)

### 7.1 “mkdocs no se reconoce…”

Solución:

* usar `python -m mkdocs serve` en lugar de `mkdocs serve`.

Causa habitual:

* scripts instalados fuera del PATH (especialmente con Python de Microsoft Store).

---

### 7.2 Pip instala “en user” aunque estés en venv

Síntoma:

* “Defaulting to user installation…”

Causas posibles:

* venv no activado correctamente,
* restricción del entorno de Python,
* instalación de Python desde Microsoft Store.

Soluciones recomendadas:

1. verificar que el venv está activo:

   * el prompt debe mostrar `(.venv)`
2. usar siempre `python -m pip ...`
3. si persiste, considerar instalar Python desde python.org (si la política corporativa lo permite)

---

### 7.3 Puerto ocupado

Si el 8000 está ocupado:

```powershell
python -m mkdocs serve -a 127.0.0.1:8001
```

---

### 7.4 Errores de navegación (mkdocs.yml)

Si MkDocs falla al arrancar o al construir:

* revisar rutas en `mkdocs.yml`
* verificar que los archivos existen en `docs/`

Recomendación:

* correr `python -m mkdocs build --strict` para detectar inconsistencias.

---

## 8) (Opcional) Publicación en GitHub Pages

Se puede añadir un workflow que:

* construya el sitio
* publique en Pages

Recomendación:

* activarlo solo cuando el equipo quiera compartir specs de forma más amplia
* y revisar permisos/privacidad (si las specs son sensibles)

---

## 9) Checklist de previsualización (rápida)

* venv activo: `(.venv)`
* instalación ok: `python -m mkdocs --version`
* servidor ok: `python -m mkdocs serve`
* build estricto pasa: `python -m mkdocs build --strict`

---

Siguiente lectura recomendada:

* FAQ/troubleshooting: `docs/kit/95-faq-y-troubleshooting.md`

