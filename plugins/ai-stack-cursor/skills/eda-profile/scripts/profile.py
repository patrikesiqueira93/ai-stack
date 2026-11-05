#!/usr/bin/env python3
"""Profile a dataset before anyone models it.

Usage:
    python scripts/profile.py data/file.csv --out reports/profile
    python scripts/profile.py data/file.parquet --out reports/profile --sample 500000

Writes <out>.md and <out>.json. Reads CSV/TSV/Parquet/JSONL.
No dependency beyond pandas (+ pyarrow for parquet).
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import date, datetime
from pathlib import Path

import pandas as pd


def load(path: Path, sample: int | None) -> pd.DataFrame:
    suffix = path.suffix.lower()
    if suffix in {".csv", ".tsv"}:
        sep = "\t" if suffix == ".tsv" else ","
        df = pd.read_csv(path, sep=sep, nrows=sample, low_memory=False)
    elif suffix in {".parquet", ".pq"}:
        df = pd.read_parquet(path)
        if sample:
            df = df.head(sample)
    elif suffix in {".jsonl", ".ndjson"}:
        df = pd.read_json(path, lines=True, nrows=sample)
    elif suffix == ".json":
        df = pd.read_json(path)
    else:
        raise SystemExit(f"formato nao suportado: {suffix}")
    return df


def safe_scalar(v):
    if isinstance(v, (pd.Timestamp, datetime, date)):
        return v.isoformat()
    if pd.isna(v):
        return None
    if isinstance(v, bool):
        return v
    if isinstance(v, float):
        return round(v, 6) if abs(v) < 1e6 else float(f"{v:.6g}")
    if isinstance(v, (int, str)):
        return v
    return str(v)


DATE_HINTS = ("data", "date", "dt", "dia", "criado", "created", "updated", "atualizado", "ts")


def profile_column(s: pd.Series, name: str = "") -> dict:
    total = len(s)
    nulls = int(s.isna().sum())
    non_null = s.dropna()
    out: dict = {
        "dtype": str(s.dtype),
        "nulls": nulls,
        "null_pct": round(nulls / total * 100, 2) if total else 0.0,
        "distinct": int(non_null.nunique()),
        "examples": [safe_scalar(v) for v in non_null.head(3).tolist()],
        "flags": [],
    }
    if nulls == total:
        out["flags"].append("all-null")
    elif out["distinct"] <= 1:
        out["flags"].append("constant")
    if out["null_pct"] >= 50:
        out["flags"].append("mostly-null")

    # dates read as text are the most common CSV trap: try to recover them
    if pd.api.types.is_string_dtype(non_null) and len(non_null):
        parsed = pd.to_datetime(non_null, errors="coerce", format="mixed", utc=False)
        if parsed.notna().mean() >= 0.95 and parsed.dt.year.nunique() > 0:
            non_null = parsed.dropna()
            out["dtype"] = "datetime64 (era texto)"
            out["flags"].append("date-as-string")
            out["distinct"] = int(non_null.nunique())

    if pd.api.types.is_numeric_dtype(non_null) and not pd.api.types.is_bool_dtype(non_null):
        desc = non_null.describe(percentiles=[0.5, 0.9, 0.99]).round(4)
        out.update(
            {
                "min": safe_scalar(desc.get("min")),
                "p50": safe_scalar(desc.get("50%")),
                "p90": safe_scalar(desc.get("90%")),
                "p99": safe_scalar(desc.get("99%")),
                "max": safe_scalar(desc.get("max")),
                "mean": safe_scalar(desc.get("mean")),
            }
        )
        q1, q3 = non_null.quantile(0.25), non_null.quantile(0.75)
        iqr = q3 - q1
        if iqr > 0:
            outliers = int(((non_null < q1 - 3 * iqr) | (non_null > q3 + 3 * iqr)).sum())
            out["outliers_3iqr"] = outliers
            if outliers:
                out["flags"].append(f"outliers:{outliers}")

    if pd.api.types.is_datetime64_any_dtype(non_null):
        out["time_min"] = safe_scalar(non_null.min())
        out["time_max"] = safe_scalar(non_null.max())
        span_days = (non_null.max() - non_null.min()).days if len(non_null) else 0
        out["span_days"] = int(span_days)
        if span_days > 0:
            per_day = non_null.dt.date.value_counts()
            out["gaps_days"] = int(span_days + 1 - len(per_day))
        future = int((non_null > pd.Timestamp.now()).sum())
        if future:
            out["flags"].append(f"future_dates:{future}")

    if 0 < non_null.nunique() <= 12 and pd.api.types.is_string_dtype(non_null):
        out["top_values"] = {str(k): int(v) for k, v in non_null.value_counts().head(12).items()}

    if out["distinct"] > 0.9 * max(1, len(non_null)) and (
        pd.api.types.is_string_dtype(non_null) or pd.api.types.is_integer_dtype(non_null)
    ):
        out["flags"].append("high-cardinality-id?")
        out["_maybe_id"] = True

    if pd.api.types.is_string_dtype(non_null) and out["distinct"] > 0:
        numeric_like = pd.to_numeric(non_null, errors="coerce").notna().mean()
        if numeric_like > 0.9:
            out["flags"].append("numeric-as-string")

    return out


def find_key(df: pd.DataFrame) -> dict:
    best = {"column": None, "duplicates": None}
    for col in df.columns:
        s = df[col]
        if s.isna().all():
            continue
        if s.nunique() == len(df) and s.notna().all():
            return {"column": col, "duplicates": 0, "unique": True}
        dup = int(s.duplicated().sum())
        if best["duplicates"] is None or dup < best["duplicates"]:
            best = {"column": col, "duplicates": dup, "unique": dup == 0}
    return best


def build_report(df: pd.DataFrame, path: Path) -> dict:
    cols = {c: profile_column(df[c], c) for c in df.columns}
    key = find_key(df)
    kcol = key.get("column")
    if kcol and cols.get(kcol, {}).get("_maybe_id"):
        cols[kcol]["flags"] = [f for f in cols[kcol]["flags"] if f != "high-cardinality-id?"]
    for c in cols.values():
        c.pop("_maybe_id", None)
    return {
        "source": str(path),
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "shape": {"rows": int(len(df)), "columns": int(len(df.columns))},
        "memory_mb": round(float(df.memory_usage(deep=True).sum()) / 1e6, 2),
        "size_bytes": path.stat().st_size if path.exists() else None,
        "duplicate_rows": int(df.duplicated().sum()),
        "candidate_key": key,
        "columns": cols,
    }


def render_md(rep: dict) -> str:
    lines: list[str] = []
    a = lines.append
    a(f"# Profile — {Path(rep['source']).name}")
    a("")
    a(f"Gerado em {rep['generated_at']}. Script: `scripts/profile.py`.")
    a("")
    a("## Forma")
    a("")
    a(f"- Linhas: **{rep['shape']['rows']:,}**")
    a(f"- Colunas: **{rep['shape']['columns']}**")
    a(f"- Memoria: {rep['memory_mb']} MB")
    a(f"- Linhas duplicadas: {rep['duplicate_rows']:,}")
    k = rep["candidate_key"]
    a(f"- Candidata a chave: `{k['column']}` — duplicatas: {k['duplicates']}")
    a("")
    a("## Grain")
    a("")
    a("> _Escreva em uma frase o que uma linha significa._ Se nao der, o dataset nao esta pronto.")
    a("")
    a("## Colunas")
    a("")
    a("| Coluna | Tipo | Nulos | % nulo | Distintos | Flags |")
    a("|---|---|---|---|---|---|")
    for name, c in rep["columns"].items():
        flags = ", ".join(c["flags"]) or "—"
        a(f"| `{name}` | {c['dtype']} | {c['nulls']:,} | {c['null_pct']}% | {c['distinct']:,} | {flags} |")
    a("")
    nums = {n: c for n, c in rep["columns"].items() if "p50" in c}
    if nums:
        a("## Distribuicao numerica")
        a("")
        a("| Coluna | min | p50 | p90 | p99 | max | outliers (3 IQR) |")
        a("|---|---|---|---|---|---|---|")
        for n, c in nums.items():
            a(
                f"| `{n}` | {c.get('min')} | {c.get('p50')} | {c.get('p90')} | "
                f"{c.get('p99')} | {c.get('max')} | {c.get('outliers_3iqr', 0)} |"
            )
        a("")
    times = {n: c for n, c in rep["columns"].items() if "time_min" in c}
    if times:
        a("## Tempo")
        a("")
        for n, c in times.items():
            a(f"- `{n}`: {c['time_min']} -> {c['time_max']} ({c['span_days']} dias, {c.get('gaps_days', 0)} dias sem dado)")
        a("")
    flagged = {n: c for n, c in rep["columns"].items() if c["flags"]}
    a("## Flagheads")
    a("")
    if not flagged:
        a("Nenhuma coluna levantou flag automatico.")
    else:
        for n, c in flagged.items():
            a(f"- `{n}`: {', '.join(c['flags'])}")
    a("")
    a("## Plano de limpeza")
    a("")
    a("1. ")
    a("")
    a("> Cada passo numerado precisa dizer quantas linhas remove.")
    return "\n".join(lines) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("path", type=Path)
    ap.add_argument("--out", type=Path, default=Path("reports/profile"), help="prefixo de saida")
    ap.add_argument("--sample", type=int, default=None, help="limita linhas lidas")
    args = ap.parse_args()

    if not args.path.exists():
        print(f"arquivo nao encontrado: {args.path}", file=sys.stderr)
        return 1

    df = load(args.path, args.sample)
    if df.empty:
        print("dataset vazio", file=sys.stderr)
        return 1

    rep = build_report(df, args.path)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    md_path = args.out.with_suffix(".md")
    json_path = args.out.with_suffix(".json")
    md_path.write_text(render_md(rep), encoding="utf-8")
    json_path.write_text(json.dumps(rep, indent=2, ensure_ascii=False, default=str), encoding="utf-8")

    print(f"{rep['shape']['rows']:,} linhas x {rep['shape']['columns']} colunas")
    print(f"chave candidata: {rep['candidate_key']['column']} ({rep['candidate_key']['duplicates']} duplicatas)")
    flagged = [n for n, c in rep["columns"].items() if c["flags"]]
    print(f"flags: {', '.join(flagged) if flagged else 'nenhum'}")
    print(f"escrito: {md_path} e {json_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
