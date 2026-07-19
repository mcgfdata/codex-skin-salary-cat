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
        "composition": "focus-crop",
        "size": (2560, 1440),
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
    {
        "slug": "preset-yuexinmiao-payday",
        "name": "月薪喵 · 今日营业",
        "brandSubtitle": "CODE · COFFEE · PAYDAY",
        "tagline": "代码会写完，工资也会到账的喵",
        "quote": "等工资中...",
        "statusText": "薪资到账了吗？",
        "appearance": "auto",
        "focusX": 0.76,
        "focusY": 0.86,
        "safeArea": "left",
        "taskMode": "banner",
        "composition": "full-width-bottom",
        "size": (2240, 1600),
        "canvasColor": "#fdf0d2",
        "palette": {
            "background": "#fff8e5",
            "panel": "#fffdf3",
            "panelAlt": "#f8edca",
            "accent": "#d99032",
            "accentAlt": "#efad4d",
            "secondary": "#8aa35b",
            "highlight": "#b06a2c",
            "text": "#4e3827",
            "muted": "#806b52",
            "line": "rgba(190, 143, 56, .30)",
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


def compose_variant(source: Image.Image, config: dict[str, object]) -> Image.Image:
    composition = config["composition"]
    target_size = config.get("size", SIZE)
    if not isinstance(target_size, tuple) or len(target_size) != 2:
        raise ValueError(f"Invalid target size: {target_size!r}")
    if composition == "focus-crop":
        return ImageOps.fit(
            source,
            target_size,
            method=Image.Resampling.LANCZOS,
            centering=CENTERING,
        ).convert("RGB")

    if composition == "full-width-bottom":
        width = target_size[0]
        height = round(source.height * width / source.width)
        resized = source.resize((width, height), Image.Resampling.LANCZOS)
        fill = (*hex_to_rgb(str(config["canvasColor"])), 255)
        canvas = Image.new("RGBA", target_size, fill)
        canvas.alpha_composite(resized, (0, target_size[1] - height))
        return canvas.convert("RGB")

    raise ValueError(f"Unknown composition: {composition!r}")


def build_variant(source: Image.Image, config: dict[str, object]) -> tuple[Image.Image, dict[str, object]]:
    composed = compose_variant(source, config)

    result = {
        "schemaVersion": 1,
        "id": config["slug"],
        "name": config["name"],
        "brandSubtitle": config.get("brandSubtitle", "月薪喵"),
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
