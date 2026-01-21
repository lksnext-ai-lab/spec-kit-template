---
name: export-docx
description: Genera el comando de exportación a DOCX (spec/kit/all) usando tools/export_docx.py y Pandoc. Sin índice por defecto.
---

# Export-docx


## Objetivo

Ayudar al usuario a exportar documentación Markdown a DOCX eligiendo el alcance.

- spec: `docs/spec/**`
- kit: `docs/kit/**`
- all: `docs/**`


## Entrada (preguntas mínimas)

1. ¿Qué quieres exportar? (`spec` | `kit` | `all`)
2. Nombre del archivo de salida (sin ruta). Por defecto:

   - `spec.docx` / `kit.docx` / `docs.docx`

3. Título del documento (opcional)
4. ¿Incluir TOC (tabla de contenidos)? (sí/no; por defecto **NO**)
5. (Solo si scope=`spec` o `all`) ¿Incluir histórico `docs/spec/history/**`?
   (sí/no; por defecto **NO**)


## Reglas

- NO modifiques ningún archivo de `docs/` (solo lectura).
- El output debe ir a `exports/`.
- El comando debe ser para PowerShell en Windows.
- Usa siempre `python` y el script `tools\export_docx.py`.
- Por defecto: NO incluir `--toc`.
- Por defecto: cada archivo `.md` debe comenzar en una nueva página
  (lo gestiona el script).
- Si falta Pandoc, indica cómo verificar e instalar.
- Por defecto, EXCLUYE `docs/spec/history/**`:

  - Para `--scope spec`: no exportar histórico salvo petición explícita.
  - Para `--scope all`: no exportar histórico salvo petición explícita (para
    evitar DOCX enormes y confusos).


## Salida (obligatoria)

1. Un comando listo para copiar/pegar en PowerShell.
2. Un ejemplo alternativo (mínimo) cambiando el scope (`spec` ↔ `kit`).
3. Nota breve con:

   - dónde quedará el DOCX generado
   - cómo verificar Pandoc (`pandoc --version`)
   - si se excluye/incluye histórico, indicarlo explícitamente


## Plantilla de comando

`python tools\export_docx.py --scope <spec|kit|all> --output exports\<archivo>.docx --title "<titulo>"`


## Notas

- Si el usuario pide TOC, añade `--toc`.
- Si no hay título, omite `--title`.
- Si el usuario pide explícitamente NO saltos de página, añade `--no-page-break`.
- Si el usuario pide incluir histórico:

  - añade el flag correspondiente del script (por ejemplo `--include-history`)
    si existe,
  - y si no existe, indícalo como limitación y sugiere exportar `history` por
    separado o ampliar el script.
