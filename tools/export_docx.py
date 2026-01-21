import argparse
import shutil
import subprocess
from pathlib import Path
from typing import Any

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None  # type: ignore


def _die(msg: str, code: int = 1) -> None:
    raise SystemExit(f"[export-docx] {msg}")


def _load_mkdocs_nav(repo_root: Path) -> list:
    mkdocs = repo_root / "mkdocs.yml"
    if not mkdocs.exists():
        return []

    if yaml is None:
        _die("Falta PyYAML. Instala con: python -m pip install pyyaml")

    assert yaml is not None  # type narrowing para type checker
    data = yaml.safe_load(mkdocs.read_text(encoding="utf-8-sig"))
    return data.get("nav", []) or []


def _rel_to_docs_lower(p: Path, docs_dir: Path) -> str:
    try:
        return p.relative_to(docs_dir).as_posix().lower()
    except Exception:
        return p.as_posix().lower()


def _is_history_md(p: Path, docs_dir: Path) -> bool:
    rel = _rel_to_docs_lower(p, docs_dir)
    return rel.startswith("spec/history/") and rel.endswith(".md")


def _collect_history_files(docs_dir: Path) -> list[Path]:
    """
    Recoge todos los .md bajo docs/spec/history/** en un orden estable:
    - Ordena carpetas por nombre (I01, I02, ...)
    - Dentro de cada iteración: 00-summary, 01-plan, 95-open-questions, 96-todos, 97-review-notes, resto ordenado
    """
    history_root = docs_dir / "spec" / "history"
    if not history_root.exists():
        return []

    files: list[Path] = []
    iter_dirs = sorted([d for d in history_root.iterdir() if d.is_dir()], key=lambda d: d.name.lower())

    preferred = [
        "00-summary.md",
        "01-plan.md",
        "95-open-questions.md",
        "96-todos.md",
        "97-review-notes.md",
    ]

    for d in iter_dirs:
        # preferidos primero si existen
        for fn in preferred:
            p = d / fn
            if p.exists() and p.is_file():
                files.append(p)

        # resto .md
        others = sorted([p for p in d.glob("*.md") if p.name.lower() not in {x.lower() for x in preferred}],
                        key=lambda p: p.name.lower())
        files.extend(others)

        # subcarpetas (por si se añadieran en el futuro)
        sub = sorted([p for p in d.rglob("*.md") if p.is_file() and p.parent != d], key=lambda p: p.as_posix().lower())
        files.extend(sub)

    # uniq preservando orden
    seen = set()
    uniq: list[Path] = []
    for f in files:
        r = f.resolve()
        if r not in seen:
            seen.add(r)
            uniq.append(f)
    return uniq


def _append_history_if_needed(files: list[Path], docs_dir: Path, want_scope: str, include_history: bool) -> list[Path]:
    if (not include_history) or (want_scope not in ("spec", "all")):
        return files

    history_files = _collect_history_files(docs_dir)
    if not history_files:
        return files

    # Añadir al final preservando uniq
    seen = {f.resolve() for f in files}
    out = list(files)
    for hf in history_files:
        r = hf.resolve()
        if r not in seen:
            seen.add(r)
            out.append(hf)
    return out


def _collect_md_from_nav(nav, docs_dir: Path, want_scope: str, include_history: bool) -> list[Path]:
    """
    Extrae paths .md desde mkdocs.yml nav, respetando orden.
    Filtra por scope:
      - spec: paths bajo spec/ (por defecto excluye spec/history/** salvo --include-history)
      - kit: paths bajo kit/
      - all: no filtra (por defecto excluye spec/history/** salvo --include-history)
    """
    files: list[Path] = []

    def add_if_match(rel_path: str):
        rel = Path(rel_path)
        p = docs_dir / rel  # mkdocs.yml normalmente referencia rutas relativas a docs_dir (ej. spec/index.md)

        if not p.exists():
            # Intento extra: si la ruta venía con 'docs/...'
            if rel.parts and rel.parts[0].lower() == "docs":
                p2 = docs_dir.parent / rel
                if p2.exists():
                    p = p2
                else:
                    return
            else:
                return

        # Excluir history por defecto
        if (not include_history) and _is_history_md(p, docs_dir):
            return

        if want_scope == "all":
            files.append(p)
            return

        rel_to_docs = _rel_to_docs_lower(p, docs_dir)

        if want_scope == "spec" and rel_to_docs.startswith("spec/"):
            # Excluir history por defecto (doble guardia)
            if (not include_history) and rel_to_docs.startswith("spec/history/"):
                return
            files.append(p)
        elif want_scope == "kit" and rel_to_docs.startswith("kit/"):
            files.append(p)

    def walk(node):
        if isinstance(node, str):
            if node.lower().endswith(".md"):
                add_if_match(node)
            return

        if isinstance(node, list):
            for it in node:
                walk(it)
            return

        if isinstance(node, dict):
            for _title, value in node.items():
                walk(value)
            return

    walk(nav)

    # Elimina duplicados preservando orden
    seen = set()
    uniq = []
    for f in files:
        r = f.resolve()
        if r not in seen:
            seen.add(r)
            uniq.append(f)

    # Si se pide histórico, lo añadimos al final (sin romper el orden del nav)
    return _append_history_if_needed(uniq, docs_dir, want_scope, include_history)


def _collect_fallback(docs_dir: Path, want_scope: str, include_history: bool) -> list[Path]:
    """
    Si no hay nav o mkdocs.yml, usa un orden por convención.
    """
    def p(rel: str) -> Path:
        return docs_dir / rel

    if want_scope == "kit":
        candidates = ["kit/index.md"]
        candidates += sorted(
            [
                x.relative_to(docs_dir).as_posix()
                for x in (docs_dir / "kit").glob("*.md")
                if x.name != "index.md"
            ]
        )
        files = [p(c) for c in candidates if p(c).exists()]
        return files

    if want_scope == "spec":
        candidates = [
            "spec/index.md",
            "spec/00-context.md",
            "spec/01-plan.md",
            "spec/02-trazabilidad.md",
            "spec/10-requisitos-funcionales.md",
            "spec/11-requisitos-tecnicos-nfr.md",
            "spec/20-conceptualizacion.md",
            "spec/30-ui-spec.md",
            "spec/40-arquitectura.md",
            "spec/50-modelo-datos.md",
            "spec/60-backend.md",
            "spec/70-frontend.md",
            "spec/80-seguridad.md",
            "spec/90-infra.md",
            "spec/95-open-questions.md",
            "spec/96-todos.md",
            "spec/97-review-notes.md",
        ]
        files = [p(c) for c in candidates if p(c).exists()]
        return _append_history_if_needed(files, docs_dir, want_scope, include_history)

    # all
    files: list[Path] = []
    files += _collect_fallback(docs_dir, "kit", include_history)
    files += _collect_fallback(docs_dir, "spec", include_history)

    extras = []
    for md in docs_dir.rglob("*.md"):
        rel = md.relative_to(docs_dir).as_posix().lower()

        # Excluir lo ya cubierto por kit/spec (incluyendo history)
        if rel.startswith("kit/") or rel.startswith("spec/"):
            continue

        extras.append(md)

    files += sorted(extras, key=lambda x: x.as_posix().lower())

    # uniq preservando orden
    seen = set()
    uniq: list[Path] = []
    for f in files:
        r = f.resolve()
        if r not in seen:
            seen.add(r)
            uniq.append(f)
    return uniq


_PAGEBREAK = """```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```"""


def _create_pandoc_temp_with_pagebreaks(clean_md: Path, temp_md: Path) -> None:
    """
    Crea una versión temporal del MD limpio añadiendo saltos de página OpenXML
    entre secciones de nivel 1 (# Título) para Pandoc.
    """
    text = clean_md.read_text(encoding="utf-8")
    lines = text.split('\n')
    result = []
    
    # Bandera para detectar el primer h1 (no añadir pagebreak antes del primero)
    first_h1 = True
    
    for i, line in enumerate(lines):
        # Detectar líneas que empiezan con "# " (h1)
        if line.startswith('# ') and not line.startswith('## '):
            if not first_h1:
                # Añadir pagebreak antes de este h1 (excepto el primero)
                result.append('')
                result.append(_PAGEBREAK)
                result.append('')
            first_h1 = False
        
        result.append(line)
    
    temp_md.parent.mkdir(parents=True, exist_ok=True)
    temp_md.write_text('\n'.join(result), encoding="utf-8")


def _strip_yaml_frontmatter(text: str) -> str:
    """
    Elimina bloques YAML frontmatter (---...---) solo si están al inicio del archivo.
    YAML frontmatter debe estar en la primera línea (sin contenido previo).
    """
    lines = text.split("\n")
    if not lines:
        return text
    
    # Ignorar líneas en blanco iniciales
    first_content_idx = 0
    for i, line in enumerate(lines):
        if line.strip():
            first_content_idx = i
            break
    
    # Solo es frontmatter YAML si la primera línea no vacía es exactamente "---"
    if first_content_idx < len(lines) and lines[first_content_idx].strip() == "---":
        # Buscar el cierre del bloque YAML (segundo "---")
        for i in range(first_content_idx + 1, len(lines)):
            if lines[i].strip() == "---":
                # Retornar todo después del cierre
                return "\n".join(lines[i+1:]).lstrip()
    
    # Si no se encuentra cierre o no es frontmatter válido, retornar el texto original
    return text


def _build_combined_md(files: list[Path], out_md: Path, title: str | None) -> None:
    """
    Construye MD limpio combinado (sin saltos de página OpenXML).
    """
    chunks = []
    if title:
        chunks.append(f"# {title}\n")

    for f in files:
        text = f.read_text(encoding="utf-8-sig", errors="ignore").strip()
        if not text:
            continue

        # Eliminar frontmatter YAML para evitar conflictos al combinar
        text = _strip_yaml_frontmatter(text)
        if not text.strip():
            continue

        # Reemplazar "---" decorativo solitario que causa problemas con Pandoc
        # (Pandoc lo interpreta como separador de tabla y rompe el formato)
        lines = text.split('\n')
        cleaned_lines = []
        for i, line in enumerate(lines):
            # Si es una línea con solo "---" (decorativa), reemplazar por línea horizontal alternativa
            if line.strip() == '---':
                # Verificar que no es parte de frontmatter YAML (ya eliminado) ni de tabla
                # Cambiar por * * * que Pandoc interpreta mejor
                cleaned_lines.append('* * *')
            else:
                cleaned_lines.append(line)
        text = '\n'.join(cleaned_lines)

        chunks.append(text)
        chunks.append("")  # línea en blanco

    out_md.parent.mkdir(parents=True, exist_ok=True)
    out_md.write_text("\n".join(chunks).strip() + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description="Exporta docs Markdown a DOCX (Pandoc).")
    parser.add_argument("--scope", choices=["spec", "kit", "all"], default="spec")
    parser.add_argument("--output", default="exports/output.docx")
    parser.add_argument("--title", default=None)
    parser.add_argument("--toc", action="store_true", help="Incluye tabla de contenidos (Pandoc --toc). (Por defecto: NO)")
    parser.add_argument("--no-page-break", action="store_true", help="No insertar saltos de página entre archivos. (Por defecto: SÍ)")
    parser.add_argument(
        "--include-history",
        action="store_true",
        help="Incluye el histórico docs/spec/history/** en la exportación (por defecto se excluye). Aplica a scope spec/all.",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    docs_dir = repo_root / "docs"

    if not docs_dir.exists():
        _die("No existe la carpeta 'docs/'. Ejecuta desde un repo spec-kit válido.")

    pandoc = shutil.which("pandoc")
    if not pandoc:
        _die("No se encuentra 'pandoc' en PATH. Instala Pandoc y reintenta. (Windows: choco install pandoc)")

    nav = _load_mkdocs_nav(repo_root)

    if nav:
        files = _collect_md_from_nav(nav, docs_dir, args.scope, include_history=args.include_history)
    else:
        files = _collect_fallback(docs_dir, args.scope, include_history=args.include_history)

    if not files:
        _die(f"No se han encontrado archivos Markdown para scope='{args.scope}'.")

    # Calcular nombre base del output (quitar .docx si existe)
    out_docx = (repo_root / args.output).resolve()
    if out_docx.suffix.lower() == '.docx':
        out_base = out_docx.with_suffix('')
    else:
        out_base = out_docx
        out_docx = out_docx.with_suffix('.docx')
    
    out_md_clean = out_base.with_suffix('.md')
    out_md_temp = repo_root / "exports" / f"_combined_{args.scope}_temp.md"

    # 1. Generar MD limpio (sin OpenXML pagebreaks)
    _build_combined_md(
        files=files,
        out_md=out_md_clean,
        title=args.title,
    )

    # 2. Crear versión temporal con pagebreaks OpenXML para Pandoc
    if not args.no_page_break:
        _create_pandoc_temp_with_pagebreaks(out_md_clean, out_md_temp)
        pandoc_input = out_md_temp
    else:
        # Si no se quieren pagebreaks, usar directamente el MD limpio
        pandoc_input = out_md_clean

    out_docx.parent.mkdir(parents=True, exist_ok=True)

    cmd = [
        pandoc,
        str(pandoc_input),
        "-f", "markdown-yaml_metadata_block+raw_attribute",
        "-t", "docx",
        "-o", str(out_docx),
    ]
    if args.toc:
        cmd.append("--toc")

    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        if "permission denied" in e.stderr.lower():
            _die(
                f"No se puede escribir el archivo '{out_docx}'.\n"
                f"       Posibles causas:\n"
                f"       - El archivo está abierto en Word u otra aplicación (ciérralo e intenta de nuevo)\n"
                f"       - No tienes permisos de escritura en '{out_docx.parent}'\n"
                f"       Solución rápida: cierra el archivo o usa otro nombre con --output"
            )
        else:
            _die(f"Error al ejecutar Pandoc:\n{e.stderr}")

    # 3. Limpiar archivo temporal
    if out_md_temp.exists():
        out_md_temp.unlink()

    print(f"[export-docx] OK")
    print(f"[export-docx] scope: {args.scope}")
    print(f"[export-docx] markdown: {out_md_clean}")
    print(f"[export-docx] docx: {out_docx}")
    print(f"[export-docx] files: {len(files)}")
    print(f"[export-docx] page_break_between_files: {not args.no_page_break}")
    print(f"[export-docx] toc: {args.toc}")
    print(f"[export-docx] include_history: {args.include_history}")


if __name__ == "__main__":
    main()
