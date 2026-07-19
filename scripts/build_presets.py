from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source" / "salary-cat-source.png"
OUTPUT_ROOT = ROOT / "presets"
SIZE = (2560, 1440)
SOURCE_SIZE = (1942, 809)
CENTERING = (0.98, 0.50)


VARIANTS = [
    {
        "slug": "preset-yuexinmiao",
        "name": "月薪喵",
        "tagline": "月薪喵",
        "quote": "月薪喵",
        "statusText": "月薪喵 ONLINE",
        "appearance": "auto",
        "focusX": 0.72,
        "focusY": 0.48,
        "safeArea": "left",
        "taskMode": "ambient",
        "palette": {
            "background": "#fdf0d1",
            "panel": "#fffaf0",
            "panelAlt": "#f2dfc1",
            "accent": "#43527c",
            "accentAlt": "#5f7099",
            "secondary": "#6f6e3f",
            "highlight": "#a8752f",
            "text": "#4b3429",
            "muted": "#7c6a60",
            "line": "rgba(67, 82, 124, .24)",
        },
    },
]


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.strip()
    if value.startswith("#"):
        value = value[1:]
    if len(value) != 6:
        raise ValueError(f"Invalid color: {value!r}")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def build_variant(source: Image.Image, config: dict[str, object]) -> tuple[Image.Image, dict[str, object]]:
    composed = ImageOps.fit(
        source,
        SIZE,
        method=Image.Resampling.LANCZOS,
        centering=CENTERING,
    ).convert("RGB")

    result = {
        "schemaVersion": 1,
        "id": config["slug"],
        "name": config["name"],
        "brandSubtitle": "月薪喵",
        "tagline": config["tagline"],
        "projectPrefix": "选择项目 · ",
        "projectLabel": "◉  选择项目",
        "statusText": config["statusText"],
        "quote": config["quote"],
        "image": "background.jpg",
        "appearance": config["appearance"],
        "art": {
            "focusX": config["focusX"],
            "focusY": config["focusY"],
            "safeArea": config["safeArea"],
            "taskMode": config["taskMode"],
        },
        "colors": config["palette"],
    }
    return composed, result


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"Source image not found: {SOURCE}")

    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    with Image.open(SOURCE) as opened:
        if opened.size != SOURCE_SIZE:
            raise SystemExit(f"Unexpected source size: {opened.size}; expected {SOURCE_SIZE}")
        source = opened.convert("RGBA")

        for config in VARIANTS:
            theme_dir = OUTPUT_ROOT / config["slug"]
            theme_dir.mkdir(parents=True, exist_ok=True)
            image, theme = build_variant(source, config)
            image_path = theme_dir / "background.jpg"
            json_path = theme_dir / "theme.json"
            image.save(image_path, quality=94, subsampling=0, optimize=True)
            json_path.write_text(json.dumps(theme, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            print(f"wrote {image_path}")
            print(f"wrote {json_path}")


if __name__ == "__main__":
    main()
