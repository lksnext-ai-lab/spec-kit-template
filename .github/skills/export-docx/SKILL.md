# SKILL: export-docx (Markdown → DOCX)

## Propósito
Convertir documentación Markdown del repositorio a un archivo DOCX, pudiendo elegir el alcance:
- `spec`: documentación de especificación (`docs/spec/**`)
- `kit`: documentación del propio template/guía (`docs/kit/**`)
- `all`: todo `docs/**`

## Cuándo usarlo
- Cuando se necesite compartir la documentación en formato Word.
- Para entregar una versión “exportable” fuera del repositorio.
- Para revisiones externas donde DOCX sea requisito.

## Dependencias
- Requiere **Pandoc** instalado y disponible en PATH.
- Requiere Python con `PyYAML` si se usa el script del repo.

## Entrada que debes pedir al usuario
1) Alcance de exportación: `spec` | `kit` | `all`
2) Título del documento (opcional)
3) Ruta de salida (opcional; por defecto en `exports/`)
4) Si quiere TOC (por defecto: sí)

## Reglas
- No modificar `docs/kit/**` ni `docs/spec/**` durante el export (solo leer).
- Generar el DOCX en una carpeta dedicada: `exports/`.
- Respetar el orden de navegación definido en `mkdocs.yml` (si existe).
- Si falta Pandoc, devolver instrucciones de instalación y alternativa de ejecución.

## Procedimiento recomendado (Windows / PowerShell)
1) (Opcional) Activar venv si el repo lo usa:
   - `.\.venv\Scripts\activate`
2) Instalar dependencias del script (si no están):
   - `python -m pip install -r tools/requirements.txt`
3) Exportar:
   - `python tools\export_docx.py --scope <spec|kit|all> --output exports\<nombre>.docx --title "<titulo>" --toc`

## Salida esperada
- Un archivo DOCX en `exports/`.
- Mensaje final indicando:
  - scope usado
  - ruta del DOCX generado
  - lista (opcional) de ficheros incluidos

## Notas / limitaciones
- Mermaid/diagramas pueden no renderizarse en DOCX sin configuración adicional.
- Tablas complejas y HTML embebido pueden requerir ajustes.
