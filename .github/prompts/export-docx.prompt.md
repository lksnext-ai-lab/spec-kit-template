---
name: export-docx
description: Exporta documentación Markdown a DOCX usando `tools/export_docx.py` (Pandoc). Respeta el orden del `mkdocs.yml` nav si existe; si no, usa un fallback por convención. No modifica `docs/**`, pero genera un .md combinado junto al output.
---

# export-docx

## Objetivo
Generar un comando **listo para copiar/pegar** para exportar documentación Markdown a DOCX usando:

`python tools/export_docx.py ...`

Scopes soportados por el script:
- `spec` → `docs/spec/**` (excluye `docs/spec/history/**` por defecto)
- `kit` → `docs/kit/**`
- `all` → `docs/**` (excluye `docs/spec/history/**` por defecto)

---

## Flags reales (no inventar)
El script soporta exactamente:
- `--scope {spec,kit,all}` (default `spec`)
- `--output <ruta.docx>` (default `exports/output.docx`)
- `--title "<título>"` (opcional)
- `--toc` (opcional, añade TOC de Pandoc)
- `--no-page-break` (opcional; por defecto **sí** inserta saltos de página entre secciones)
- `--include-history` (opcional; incluye `docs/spec/history/**` solo para scope `spec` o `all`)

---

## Reglas duras
- NO modificar `docs/**`.
- Output recomendado bajo `exports/`.
- No inventar opciones no soportadas.

---

## Orden de documentos (cómo funciona)
- Si existe `mkdocs.yml`, el script usa `nav:` para determinar el orden.  
  Requiere `pyyaml` instalado.
- Si no hay `mkdocs.yml` o no hay `nav`, usa un orden por convención (fallback).

---

## Requisitos previos (siempre)
1) Estar en un repo válido con carpeta `docs/`.
2) Tener `pandoc` en PATH:
   - comprobar: `pandoc --version`
3) Si existe `mkdocs.yml` (nav):
   - instalar PyYAML: `python -m pip install pyyaml`

---

## Efectos colaterales esperados (importante)
Al exportar:
- Se crea un Markdown combinado “limpio” junto al output base:
  - si `--output exports/spec.docx` → crea también `exports/spec.md`
- Se crea un temporal con page breaks:
  - `exports/_combined_<scope>_temp.md` (se borra al final si todo va bien)

---

## Defaults recomendados (si el usuario no especifica)
- `scope=spec`
- `output=exports/spec.docx`
- sin TOC
- con page breaks
- sin histórico

---

## Comandos listos para copiar/pegar

### Exportar SPEC (recomendado)
`python tools/export_docx.py --scope spec --output exports/spec.docx`

### Exportar KIT
`python tools/export_docx.py --scope kit --output exports/kit.docx`

### Exportar TODO (docs)
`python tools/export_docx.py --scope all --output exports/docs.docx`

### Opcionales
- Con título:
  `python tools/export_docx.py --scope spec --output exports/spec.docx --title "SPEC"`
- Con tabla de contenidos:
  `python tools/export_docx.py --scope spec --output exports/spec.docx --toc`
- Sin saltos de página:
  `python tools/export_docx.py --scope spec --output exports/spec.docx --no-page-break`
- Incluyendo histórico (solo spec/all):
  `python tools/export_docx.py --scope spec --output exports/spec-con-historico.docx --include-history`

### Alternativa Windows (si se usa `py`)
Sustituir `python` por `py` si aplica:
`py tools/export_docx.py --scope spec --output exports/spec.docx`

---

## Salida (obligatoria en el chat)
1) El comando final elegido.
2) Confirmación explícita de:
   - scope
   - output
   - toc (sí/no)
   - page breaks (sí/no)
   - include-history (sí/no)
3) Recordatorio de:
   - `pandoc --version`
   - `python -m pip install pyyaml` si hay mkdocs nav

Mini resumen machine-friendly:

```yaml
scope: "spec|kit|all"
output: "exports/....docx"
title: "<vacío|texto>"
toc: true|false
page_break_between_sections: true|false
include_history: true|false
```
