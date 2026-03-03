---
category: spec-kit
scope: platform
status: stable
---

# SKILL: export-docx (Markdown → DOCX)

## Propósito

Exportar documentación Markdown del repo a **DOCX** usando el script:

`python tools/export_docx.py`

Permite elegir alcance (scope) y opciones de formato, **sin modificar `docs/**`**.

---

## Cuándo usarlo

- Compartir documentación con terceros en formato Word.
- Entregables fuera del repositorio (auditorías, stakeholders, etc.).
- Revisiones donde DOCX sea requisito.

---

## Alcances soportados (scope)

Scopes soportados por el script (no inventar):

- `spec` → `docs/spec/**` (excluye `docs/spec/history/**` por defecto)
- `kit` → `docs/kit/**`
- `all` → `docs/**` (excluye `docs/spec/history/**` por defecto)

> Nota: existe `--include-history` para incluir `docs/spec/history/**` solo en `spec` o `all`.

---

## Entrada que debes pedir al usuario

1) `scope`: `spec` | `kit` | `all` (default recomendado: `spec`)
2) `output`: ruta del `.docx` (default recomendado: `exports/spec.docx`)
3) `title` (opcional)
4) `toc`: sí/no (default recomendado: no)
5) `page breaks`: sí/no  
   - Por defecto el script inserta saltos de página entre secciones.
   - Para desactivarlo: `--no-page-break`
6) `include-history`: sí/no (solo útil en `spec` o `all`; default: no)

---

## Requisitos previos (siempre)

1) Estar en la raíz del repo (debe existir `docs/`)
2) Pandoc disponible en PATH:
   - comprobar: `pandoc --version`
3) Si existe `mkdocs.yml` con `nav:` (para respetar orden):
   - instalar PyYAML: `python -m pip install pyyaml`

---

## Reglas duras

- **NO modificar `docs/**`** (solo lectura).
- Output recomendado en `exports/`.
- **No inventar flags**: el script soporta exactamente:
  - `--scope {spec,kit,all}`
  - `--output <ruta.docx>`
  - `--title "<título>"`
  - `--toc`
  - `--no-page-break`
  - `--include-history`

---

## Orden de documentos (cómo funciona)

- Si existe `mkdocs.yml` con `nav:`, el script usa ese orden (requiere PyYAML).
- Si no existe `mkdocs.yml` o no hay `nav`, usa un orden fallback por convención.

---

## Procedimiento recomendado (Windows / PowerShell)

1) Verificar Pandoc:

```powershell
pandoc --version
```

2. (Opcional) Si hay `mkdocs.yml` con `nav`, instalar PyYAML:

```powershell
python -m pip install pyyaml
```

3. Exportar (comando base):

```powershell
python tools\export_docx.py --scope <spec|kit|all> --output exports\<nombre>.docx
```

4. Opcionales (solo si el usuario lo pide):

* Título:

  * `--title "..." `
* TOC:

  * `--toc`
* Sin saltos de página:

  * `--no-page-break`
* Incluir histórico (solo spec/all):

  * `--include-history`

> Alternativa Windows: usar `py` en lugar de `python` si aplica.

---

## Efectos colaterales esperados (importante)

Al exportar, el script puede generar archivos auxiliares bajo `exports/`:

* Un Markdown combinado “limpio” junto al output base:

  * `exports/<nombre>.md`
* Un temporal con page breaks:

  * `exports/_combined_<scope>_temp.md`
  * (se borra al final si todo va bien)

---

## Salida esperada

* Un archivo `.docx` en `exports/`.
* Confirmación final incluyendo:

  * `scope`
  * `output`
  * `toc` (sí/no)
  * `page_break_between_sections` (sí/no)
  * `include_history` (sí/no)
* (Opcional) lista de ficheros incluidos si el script lo muestra.

Mini resumen machine-friendly (siempre que se ejecute):

```yaml
scope: "spec|kit|all"
output: "exports/....docx"
title: "<vacío|texto>"
toc: true|false
page_break_between_sections: true|false
include_history: true|false
```

---

## Notas / limitaciones

* Mermaid/diagramas pueden no renderizarse en DOCX sin configuración adicional.
* Tablas complejas y HTML embebido pueden requerir ajustes.
* Si falla Pandoc, primero resolver instalación/configuración antes de iterar.

---

## Troubleshooting rápido

* **`pandoc` no encontrado**:

  * Instalar Pandoc y reabrir terminal; repetir `pandoc --version`.
* **Orden “raro” de secciones**:

  * Revisar si existe `mkdocs.yml` y si contiene `nav:`; si sí, instalar `pyyaml`.
* **Necesito incluir histórico**:

  * Usar `--include-history` (solo `spec` / `all`).

