#!/usr/bin/env python3
"""Check multilingual documentation and internal Markdown links (stdlib only)."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent
DOCS = (
    "README.md",
    "INSTALL.md",
    "SECURITY.md",
    "RELEASE.md",
    "DEVELOPMENT_HISTORY.md",
    "lab/README.md",
)
LANGUAGES = ("English", "Українська", "Русский")
LINK = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")


def check() -> None:
    issues = []
    pages = []
    for rel in DOCS:
        pages.extend((ROOT / rel, ROOT / "docs/uk" / rel, ROOT / "docs/ru" / rel))
    for path in pages:
        relative = path.relative_to(ROOT)
        if not path.is_file():
            issues.append(f"missing document: {relative}")
            continue
        text = path.read_text(encoding="utf-8")
        for label in LANGUAGES:
            if label not in text:
                issues.append(f"{relative}: missing language navigation {label}")
        if text.count("```") % 2:
            issues.append(f"{relative}: unbalanced Markdown code fences")
        if "\\`" in text:
            issues.append(f"{relative}: escaped backticks instead of Markdown code")
        for match in LINK.finditer(text):
            url = match.group(1).strip().split(" ", 1)[0]
            if url.startswith(("https://", "http://", "mailto:", "#")):
                continue
            url = url.split("#", 1)[0].split("?", 1)[0]
            if not url:
                continue
            destination = (path.parent / url).resolve()
            if not destination.is_relative_to(ROOT) or not destination.is_file():
                issues.append(f"{relative}: unresolved relative link: {url}")
    license_file = ROOT / "LICENSE"
    if not license_file.is_file():
        issues.append("missing LICENSE")
    else:
        lic = license_file.read_text(encoding="utf-8")
        for must in ("MIT License", "Copyright (c) 2026 Altered Carbon LLC", "Permission is hereby granted", 'THE SOFTWARE IS PROVIDED "AS IS"'):
            if must not in lic:
                issues.append(f"LICENSE: missing {must}")
    if issues:
        for issue in issues:
            print(f"DOCS_ERROR: {issue}", file=sys.stderr)
        raise SystemExit(1)
    print("DOCS_TESTS_OK")


if __name__ == "__main__":
    check()
