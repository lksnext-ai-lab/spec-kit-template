# tools/close_iteration.py
from __future__ import annotations

import argparse
import re
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Final, Iterable, NoReturn

CLOSED_STATUS_TOKENS: Final[set[str]] = {
    "cerrada",
    "cerrado",
    "resuelta",
    "resuelto",
    "completada",
    "completado",
    "hecha",
    "hecho",
    "done",
    "closed",
    "resolved",
    "complete",
    "completed",
    "ok",
}

OPEN_STATUS_TOKENS: Final[set[str]] = {
    "abierta",
    "abierto",
    "open",
    "pendiente",
    "pending",
    "deferida",
    "deferred",
    "en curso",
    "in progress",
}


def die(msg: str, code: int = 1) -> NoReturn:
    raise SystemExit(f"[close-iteration] {msg}")


def find_repo_root(start: Path) -> Path:
    """Heurística: subir hasta encontrar mkdocs.yml o .git y docs/."""
    p = start.resolve()
    for cur in [p, *p.parents]:
        mkdocs = cur / "mkdocs.yml"
        docs = cur / "docs"
        git = cur / ".git"
        if docs.exists() and mkdocs.exists():
            return cur
        if docs.exists() and git.exists():
            return cur
    # fallback: cwd
    if (pмн := p / "docs").exists():  # type: ignore[name-defined]
        return p
    die("No puedo detectar la raíz del repo. Ejecuta el script desde la raíz o desde dentro del repo.")


def read_text(path: Path) -> str:
    if not path.exists():
        die(f"No existe el archivo requerido: {path.as_posix()}")
    return path.read_text(encoding="utf-8", errors="ignore")


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip() + "\n", encoding="utf-8")


def normalize_iteration(raw: str) -> str:
    m = re.search(r"I\s*0*(\d{1,3})", raw.strip(), flags=re.IGNORECASE)
    if not m:
        die(f"No puedo normalizar iteración desde: {raw!r}")
    n = int(m.group(1))
    return f"I{n:02d}"


def detect_iteration_from_plan(plan_text: str) -> str | None:
    # Preferencia: campos tipo "Iteración: I01"
    m = re.search(r"(?im)^\s*iteraci[oó]n\s*[:\-]\s*(I\s*\d{1,3})\s*$", plan_text)
    if m:
        return normalize_iteration(m.group(1))

    # Alternativa: "Iteración I01" o "I01" cerca del inicio del documento
    head = plan_text[:2000]
    m2 = re.search(r"\bI\s*\d{1,3}\b", head)
    if m2:
        return normalize_iteration(m2.group(0))

    return None


def infer_next_iteration(ixx: str) -> str:
    m = re.match(r"^I(\d{2,3})$", ixx)
    if m is None:
        die("No puedo inferir Iyy automáticamente. Pasa --next I02.")
    assert m is not None  # para Pylance (evita OptionalMemberAccess)
    n = int(m.group(1))
    return f"I{n + 1:02d}"


def ensure_unique_history_dir(base: Path) -> Path:
    if not base.exists():
        return base
    # Si ya existe, sufijo incremental: I01-2, I01-3...
    for k in range(2, 100):
        cand = base.parent / f"{base.name}-{k}"
        if not cand.exists():
            return cand
    die(f"No puedo crear un histórico único (demasiados sufijos) para {base.as_posix()}")


@dataclass(frozen=True)
class MdTable:
    header_lines: list[str]   # 2 líneas: header + separator
    rows: list[list[str]]     # celdas ya recortadas
    prelude: list[str]        # líneas antes de la tabla (incluye título, intro)
    epilogue: list[str]       # líneas después de la tabla


def _is_table_line(line: str) -> bool:
    s = line.strip()
    return s.startswith("|") and s.endswith("|") and "|" in s[1:-1]


def _split_row(line: str) -> list[str]:
    # "| a | b |" -> ["a","b"]
    parts = [p.strip() for p in line.strip()[1:-1].split("|")]
    return parts


def parse_first_md_table(text: str) -> MdTable | None:
    lines = text.splitlines()
    # localizar primer header de tabla
    for i in range(len(lines) - 1):
        if _is_table_line(lines[i]) and _is_table_line(lines[i + 1]):
            header = _split_row(lines[i])
            sep = lines[i + 1].strip()
            if not re.match(r"^\|\s*[:\- ]+\|", sep):
                continue

            prelude = lines[:i]
            header_line = lines[i]
            sep_line = lines[i + 1]

            rows: list[list[str]] = []
            j = i + 2
            while j < len(lines) and _is_table_line(lines[j]):
                rows.append(_split_row(lines[j]))
                j += 1
            epilogue = lines[j:]
            return MdTable(
                header_lines=[header_line, sep_line],
                rows=rows,
                prelude=prelude,
                epilogue=epilogue,
            )
    return None


def _find_col_index(header_line: str, candidates: Iterable[str]) -> int | None:
    hdr = [h.strip().lower() for h in _split_row(header_line)]
    for cand in candidates:
        c = cand.lower()
        if c in hdr:
            return hdr.index(c)
    return None


def _status_is_closed(status: str) -> bool:
    s = status.strip().lower()
    if not s:
        return False
    # match por tokens
    for tok in CLOSED_STATUS_TOKENS:
        if tok in s:
            return True
    return False


def _status_is_open(status: str) -> bool:
    s = status.strip().lower()
    if not s:
        return True  # si no hay estado, lo tratamos como "pendiente"
    for tok in OPEN_STATUS_TOKENS:
        if tok in s:
            return True
    # si no es claramente open, y tampoco closed, lo conservamos (conservador)
    return not _status_is_closed(s)


def filter_table_keep_open(text: str) -> tuple[str, list[str], bool]:
    """
    Devuelve:
      - texto filtrado (manteniendo la primera tabla pero con filas abiertas)
      - lista de IDs que se conservan (si se puede inferir)
      - bool indicando si se pudo filtrar realmente
    """
    t = parse_first_md_table(text)
    if t is None:
        return text, [], False

    header_line = t.header_lines[0]
    id_idx = _find_col_index(header_line, ["id", "openq", "todo", "ticket"])
    status_idx = _find_col_index(header_line, ["estado", "status", "state"])

    # si no tenemos columna de estado, no podemos filtrar con fiabilidad
    if status_idx is None:
        return text, [], False

    kept_rows: list[list[str]] = []
    kept_ids: list[str] = []

    for row in t.rows:
        # normalizar longitudes por si hay celdas faltantes
        if status_idx >= len(row):
            # fila rara; conservar por seguridad
            kept_rows.append(row)
            continue

        st = row[status_idx]
        if _status_is_open(st):
            kept_rows.append(row)
            if id_idx is not None and id_idx < len(row):
                rid = row[id_idx].strip()
                if rid:
                    kept_ids.append(rid)

    # reconstruir
    out_lines: list[str] = []
    out_lines.extend(t.prelude)
    # asegurar una línea en blanco antes de tabla si no la hay
    if out_lines and out_lines[-1].strip() != "":
        out_lines.append("")
    out_lines.extend(t.header_lines)
    for r in kept_rows:
        out_lines.append("| " + " | ".join(r) + " |")
    # si no quedan filas, mantener tabla vacía (solo header)
    out_lines.extend(t.epilogue)

    return "\n".join(out_lines).rstrip() + "\n", kept_ids, True


def extract_ids(text: str, prefix: str) -> list[str]:
    # OPENQ-001 / TODO-001 etc.
    rx = re.compile(rf"\b{re.escape(prefix)}-\d{{3,4}}\b", flags=re.IGNORECASE)
    seen: set[str] = set()
    out: list[str] = []
    for m in rx.finditer(text):
        v = m.group(0).upper()
        if v not in seen:
            seen.add(v)
            out.append(v)
    return out


def update_index_with_history(index_text: str, ixx: str, hist_rel: str) -> str:
    """
    Añade (si no existe) una sección "Histórico de iteraciones" y una entrada para ixx.
    hist_rel es ruta relativa desde docs/spec/index.md, p.ej. "history/I01/00-summary.md"
    """
    lines = index_text.splitlines()
    # ya existe entrada?
    if re.search(rf"(?im)^\s*-\s*\*\*{re.escape(ixx)}\*\*", index_text):
        return index_text.rstrip() + "\n"

    section_title = "## Histórico de iteraciones"
    if section_title not in index_text:
        # añadir al final con un bloque limpio
        lines.append("")
        lines.append(section_title)
        lines.append("")
        lines.append(f"- **{ixx}**")
        lines.append(f"  - Resumen: {hist_rel.replace('00-summary.md', '00-summary.md')}")
        lines.append(f"  - Plan: history/{ixx}/01-plan.md")
        lines.append(f"  - OPENQ: history/{ixx}/95-open-questions.md")
        lines.append(f"  - TODO: history/{ixx}/96-todos.md")
        lines.append(f"  - Review: history/{ixx}/97-review-notes.md")
        return "\n".join(lines).rstrip() + "\n"

    # insertar debajo del título
    out: list[str] = []
    inserted = False
    for i, line in enumerate(lines):
        out.append(line)
        if not inserted and line.strip() == section_title:
            out.append("")
            out.append(f"- **{ixx}**")
            out.append(f"  - Resumen: {hist_rel.replace('00-summary.md', '00-summary.md')}")
            out.append(f"  - Plan: history/{ixx}/01-plan.md")
            out.append(f"  - OPENQ: history/{ixx}/95-open-questions.md")
            out.append(f"  - TODO: history/{ixx}/96-todos.md")
            out.append(f"  - Review: history/{ixx}/97-review-notes.md")
            inserted = True

    return "\n".join(out).rstrip() + "\n"


def make_plan_skeleton(iyy: str, ixx: str, hist_dir_name: str) -> str:
    today = datetime.now().strftime("%Y-%m-%d")
    return f"""# Plan de iteración {iyy}

## Metadatos
- Iteración: {iyy}
- Fecha inicio: {today}
- Responsable: TODO
- Estado: Draft

## Objetivo de iteración
TODO: describe en 1 párrafo el objetivo concreto de {iyy}.

## Alcance
### IN
- TODO

### OUT
- TODO

## Entregables (docs/spec/)
- docs/spec/01-plan.md
- TODO: añade aquí los docs que deben quedar actualizados en {iyy}

## Tareas (tareas atómicas + DoD)

| ID | Tarea | Archivos | Resultado / DoD |
| --- | --- | --- | --- |
| T01 | TODO | docs/spec/... | - TODO |

## Decisiones y preguntas abiertas (gates)
- TODO: enlaza OPENQ-### y/o DECISION: relevantes para {iyy}

## Histórico
- Iteración anterior ({ixx}): docs/spec/history/{hist_dir_name}/01-plan.md
"""


def make_review_template(iyy: str, ixx: str, hist_dir_name: str) -> str:
    return f"""# Review notes — {iyy}

> Histórico {ixx}: docs/spec/history/{hist_dir_name}/97-review-notes.md

## Bloqueantes

## Contradicciones

## Ambigüedades

## Riesgos

## Sugerencias no bloqueantes
"""


def prepend_history_link(original: str, ixx: str, hist_rel_path: str) -> str:
    lines = original.splitlines()
    # buscar primer heading
    if lines and lines[0].lstrip().startswith("#"):
        title = lines[0]
        rest = lines[1:]
        return "\n".join(
            [
                title,
                "",
                f"> Histórico {ixx}: {hist_rel_path}",
                "",
                *rest,
            ]
        ).rstrip() + "\n"
    # si no hay título, crear uno genérico
    return "\n".join(
        [
            "# Documento",
            "",
            f"> Histórico {ixx}: {hist_rel_path}",
            "",
            original.rstrip(),
        ]
    ).rstrip() + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Cierra la iteración activa: snapshot a docs/spec/history/Ixx y prepara archivos activos para Iyy."
    )
    ap.add_argument("--repo-root", default=None, help="Ruta a la raíz del repo (opcional).")
    ap.add_argument("--ixx", default=None, help="Iteración a cerrar (ej. I01). Si no se pasa, se detecta desde 01-plan.md.")
    ap.add_argument("--next", dest="iyy", default=None, help="Siguiente iteración (ej. I02). Si no se pasa, se infiere.")
    ap.add_argument("--dry-run", action="store_true", help="No escribe cambios; solo muestra acciones.")
    ap.add_argument("--no-filter-openq", action="store_true", help="No intenta filtrar OPENQ; mantiene 95-open-questions.md tal cual.")
    ap.add_argument("--no-filter-todos", action="store_true", help="No intenta filtrar TODO; mantiene 96-todos.md tal cual.")
    args = ap.parse_args()

    start = Path(args.repo_root).resolve() if args.repo_root else Path.cwd()
    repo_root = find_repo_root(start)

    spec_dir = repo_root / "docs" / "spec"
    plan_path = spec_dir / "01-plan.md"
    openq_path = spec_dir / "95-open-questions.md"
    todos_path = spec_dir / "96-todos.md"
    review_path = spec_dir / "97-review-notes.md"
    index_path = spec_dir / "index.md"

    # Leer archivos requeridos
    plan_text = read_text(plan_path)
    openq_text = read_text(openq_path)
    todos_text = read_text(todos_path)
    review_text = read_text(review_path)
    index_text = read_text(index_path)

    # Detectar iteraciones
    ixx = normalize_iteration(args.ixx) if args.ixx else detect_iteration_from_plan(plan_text)
    if not ixx:
        die("No pude detectar la iteración activa desde docs/spec/01-plan.md. Pasa --ixx I01.")
    iyy = normalize_iteration(args.iyy) if args.iyy else infer_next_iteration(ixx)

    # Preparar history dir
    base_hist = spec_dir / "history" / ixx
    hist_dir = ensure_unique_history_dir(base_hist)
    hist_dir_name = hist_dir.name  # por si tiene sufijo -2

    # Paths de snapshot
    hist_plan = hist_dir / "01-plan.md"
    hist_openq = hist_dir / "95-open-questions.md"
    hist_todos = hist_dir / "96-todos.md"
    hist_review = hist_dir / "97-review-notes.md"
    hist_summary = hist_dir / "00-summary.md"

    actions: list[str] = []
    actions.append(f"Repo root: {repo_root.as_posix()}")
    actions.append(f"Cerrar: {ixx}  ->  Preparar: {iyy}")
    actions.append(f"History dir: {hist_dir.as_posix()}")

    # Filtrado (mejor esfuerzo)
    kept_openq_ids: list[str] = []
    kept_todo_ids: list[str] = []
    openq_filtered_ok = False
    todos_filtered_ok = False

    active_openq_new = openq_text
    active_todos_new = todos_text

    if not args.no_filter_openq:
        active_openq_new, kept_openq_ids, openq_filtered_ok = filter_table_keep_open(openq_text)

    if not args.no_filter_todos:
        active_todos_new, kept_todo_ids, todos_filtered_ok = filter_table_keep_open(todos_text)

    # Enlaces a histórico (para activos)
    active_openq_new = prepend_history_link(active_openq_new, ixx, f"docs/spec/history/{hist_dir_name}/95-open-questions.md")
    active_todos_new = prepend_history_link(active_todos_new, ixx, f"docs/spec/history/{hist_dir_name}/96-todos.md")

    # Plan + review “limpios” para Iyy
    active_plan_new = make_plan_skeleton(iyy, ixx, hist_dir_name)
    active_review_new = make_review_template(iyy, ixx, hist_dir_name)

    # Index: añadir entrada de histórico
    index_new = update_index_with_history(index_text, ixx, f"history/{hist_dir_name}/00-summary.md")

    # Summary histórico
    # (para el histórico usamos los IDs detectados, pero también ponemos nota si el filtrado no fue posible)
    openq_all_ids = extract_ids(openq_text, "OPENQ")
    todo_all_ids = extract_ids(todos_text, "TODO")

    summary_lines: list[str] = []
    summary_lines.append(f"# Resumen de cierre — {ixx}")
    summary_lines.append("")
    summary_lines.append(f"- Cerrada: **{ixx}**")
    summary_lines.append(f"- Siguiente iteración preparada: **{iyy}**")
    summary_lines.append(f"- Fecha de cierre: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    summary_lines.append("")
    summary_lines.append("## Snapshots")
    summary_lines.append(f"- Plan: docs/spec/history/{hist_dir_name}/01-plan.md")
    summary_lines.append(f"- OPENQ: docs/spec/history/{hist_dir_name}/95-open-questions.md")
    summary_lines.append(f"- TODO: docs/spec/history/{hist_dir_name}/96-todos.md")
    summary_lines.append(f"- Review: docs/spec/history/{hist_dir_name}/97-review-notes.md")
    summary_lines.append("")
    summary_lines.append("## OPENQs")
    if openq_filtered_ok:
        summary_lines.append(f"- OPENQs que pasan a {iyy} (según estado): {len(kept_openq_ids)}")
        if kept_openq_ids:
            summary_lines.append("  - " + ", ".join(kept_openq_ids))
    else:
        summary_lines.append("- No se pudo filtrar automáticamente por estado (formato no reconocido).")
        summary_lines.append(f"- OPENQs detectadas en el documento (sin interpretar estado): {len(openq_all_ids)}")
        if openq_all_ids:
            summary_lines.append("  - " + ", ".join(openq_all_ids[:50]) + (" ..." if len(openq_all_ids) > 50 else ""))
    summary_lines.append("")
    summary_lines.append("## TODOs")
    if todos_filtered_ok:
        summary_lines.append(f"- TODOs que pasan a {iyy} (según estado): {len(kept_todo_ids)}")
        if kept_todo_ids:
            summary_lines.append("  - " + ", ".join(kept_todo_ids))
    else:
        summary_lines.append("- No se pudo filtrar automáticamente por estado (formato no reconocido).")
        summary_lines.append(f"- TODOs detectados en el documento (sin interpretar estado): {len(todo_all_ids)}")
        if todo_all_ids:
            summary_lines.append("  - " + ", ".join(todo_all_ids[:50]) + (" ..." if len(todo_all_ids) > 50 else ""))
    summary_lines.append("")
    summary_lines.append("## Nota")
    summary_lines.append("- Este resumen es un snapshot de cierre. El trabajo de la siguiente iteración se planifica con /plan-iteration.")
    summary_text = "\n".join(summary_lines).rstrip() + "\n"

    # Ejecutar (o dry-run)
    if args.dry_run:
        print("\n".join(actions))
        print("")
        print("[dry-run] No se han escrito cambios. Acciones que se ejecutarían:")
        print(f"- Crear carpeta histórico: {hist_dir.as_posix()}")
        print("- Copiar snapshots: 01-plan.md, 95-open-questions.md, 96-todos.md, 97-review-notes.md")
        print("- Escribir 00-summary.md")
        print("- Reescribir activos: 01-plan.md, 95-open-questions.md, 96-todos.md, 97-review-notes.md")
        print("- Actualizar index.md con entrada de histórico")
        return 0

    # Crear histórico + copiar snapshots (copias exactas)
    hist_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(plan_path, hist_plan)
    shutil.copy2(openq_path, hist_openq)
    shutil.copy2(todos_path, hist_todos)
    shutil.copy2(review_path, hist_review)
    write_text(hist_summary, summary_text)

    # Reescribir activos
    write_text(plan_path, active_plan_new)
    write_text(openq_path, active_openq_new)
    write_text(todos_path, active_todos_new)
    write_text(review_path, active_review_new)
    write_text(index_path, index_new)

    # Output
    print("[close-iteration] OK")
    print(f"[close-iteration] closed: {ixx}")
    print(f"[close-iteration] next: {iyy}")
    print(f"[close-iteration] history: {hist_dir.as_posix()}")
    print(f"[close-iteration] filtered_openq: {openq_filtered_ok} (kept={len(kept_openq_ids)})")
    print(f"[close-iteration] filtered_todos: {todos_filtered_ok} (kept={len(kept_todo_ids)})")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        die("Interrumpido por el usuario.", code=130)
