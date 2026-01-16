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
    data = yaml.safe_load(mkdocs.read_text(encoding="utf-8"))
    return data.get("nav", []) or []


def _collect_md_from_nav(nav, docs_dir: Path, want_scope: str) -> list[Path]:
    """
    Extrae paths .md desde mkdocs.yml nav, respetando orden.
    Filtra por scope:
      - spec: paths bajo spec/
      - kit: paths bajo kit/
      - all: no filtra
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

        if want_scope == "all":
            files.append(p)
            return

        try:
            rel_to_docs = p.relative_to(docs_dir).as_posix().lower()
        except Exception:
            rel_to_docs = p.as_posix().lower()

        if want_scope == "spec" and rel_to_docs.startswith("spec/"):
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
    return uniq


def _collect_fallback(docs_dir: Path, want_scope: str) -> list[Path]:
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
        return [p(c) for c in candidates if p(c).exists()]

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
        return [p(c) for c in candidates if p(c).exists()]

    # all
    files = []
    files += _collect_fallback(docs_dir, "kit")
    files += _collect_fallback(docs_dir, "spec")

    extras = []
    for md in docs_dir.rglob("*.md"):
        rel = md.relative_to(docs_dir).as_posix()
        if rel.startswith("kit/") or rel.startswith("spec/"):
            continue
        extras.append(md)

    files += sorted(extras, key=lambda x: x.as_posix().lower())

    # uniq
    seen = set()
    uniq = []
    for f in files:
        r = f.resolve()
        if r not in seen:
            seen.add(r)
            uniq.append(f)
    return uniq


_OPENXML_PAGEBREAK = """```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```"""


def _build_combined_md(files: list[Path], out_md: Path, title: str | None, page_break_between_files: bool) -> None:
    chunks = []
    if title:
        chunks.append(f"# {title}\n")

    first = True
    for f in files:
        text = f.read_text(encoding="utf-8", errors="ignore").strip()
        if not text:
            continue

        # Cada archivo empieza en página nueva (excepto el primero)
        if (not first) and page_break_between_files:
            chunks.append(_OPENXML_PAGEBREAK)
            chunks.append("")  # línea en blanco

        # Opcional: marca de origen (comentario, no ensucia el doc visible)
        # chunks.append(f"<!-- source: {f.as_posix()} -->\n")

        chunks.append(text)
        chunks.append("")  # línea en blanco

        first = False

    out_md.parent.mkdir(parents=True, exist_ok=True)
    out_md.write_text("\n".join(chunks).strip() + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description="Exporta docs Markdown a DOCX (Pandoc).")
    parser.add_argument("--scope", choices=["spec", "kit", "all"], default="spec")
    parser.add_argument("--output", default="exports/output.docx")
    parser.add_argument("--title", default=None)
    parser.add_argument("--toc", action="store_true", help="Incluye tabla de contenidos (Pandoc --toc). (Por defecto: NO)")
    parser.add_argument("--no-page-break", action="store_true", help="No insertar saltos de página entre archivos. (Por defecto: SÍ)")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    docs_dir = repo_root / "docs"

    if not docs_dir.exists():
        _die("No existe la carpeta 'docs/'. Ejecuta desde un repo spec-kit válido.")

    pandoc = shutil.which("pandoc")
    if not pandoc:
        _die("No se encuentra 'pandoc' en PATH. Instala Pandoc y reintenta. (Windows: choco install pandoc)")

    nav = _load_mkdocs_nav(repo_root)
    files = _collect_md_from_nav(nav, docs_dir, args.scope) if nav else []
    if not files:
        files = _collect_fallback(docs_dir, args.scope)

    if not files:
        _die(f"No se han encontrado archivos Markdown para scope='{args.scope}'.")

    combined_md = repo_root / "exports" / f"_combined_{args.scope}.md"
    _build_combined_md(
        files=files,
        out_md=combined_md,
        title=args.title,
        page_break_between_files=(not args.no_page_break),
    )

    out_docx = (repo_root / args.output).resolve()
    out_docx.parent.mkdir(parents=True, exist_ok=True)

    cmd = [
        pandoc,
        str(combined_md),
        "-f", "markdown",
        "-t", "docx",
        "-o", str(out_docx),
    ]
    if args.toc:
        cmd.append("--toc")

    subprocess.run(cmd, check=True)

    print(f"[export-docx] OK")
    print(f"[export-docx] scope: {args.scope}")
    print(f"[export-docx] output: {out_docx}")
    print(f"[export-docx] files: {len(files)}")
    print(f"[export-docx] page_break_between_files: {not args.no_page_break}")
    print(f"[export-docx] toc: {args.toc}")


if __name__ == "__main__":
    main()