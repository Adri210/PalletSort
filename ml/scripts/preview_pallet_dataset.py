"""Draw prepared pallet boxes on a small validation sample."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ML_ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    parser = argparse.ArgumentParser(description="Gera amostras visuais do dataset.")
    parser.add_argument(
        "--data", type=Path, default=ML_ROOT / "data" / "pallet_detection"
    )
    parser.add_argument("--split", choices=("train", "val", "test"), default="val")
    parser.add_argument("--samples", type=int, default=8)
    parser.add_argument(
        "--output", type=Path, default=ML_ROOT / "outputs" / "dataset_preview"
    )
    args = parser.parse_args()

    image_dir = args.data / "images" / args.split
    label_dir = args.data / "labels" / args.split
    output_dir = args.output
    output_dir.mkdir(parents=True, exist_ok=True)
    candidates = []
    for label_path in sorted(label_dir.glob("*.txt")):
        lines = [line for line in label_path.read_text(encoding="utf-8").splitlines() if line]
        if not lines:
            continue
        matches = list(image_dir.glob(f"{label_path.stem}.*"))
        if matches:
            candidates.append((matches[0], label_path, lines))

    if not candidates:
        raise RuntimeError(f"Nenhuma imagem positiva encontrada em {image_dir}")
    step = max(1, len(candidates) // args.samples)
    selected = candidates[::step][: args.samples]
    font = ImageFont.load_default()

    for image_path, label_path, lines in selected:
        with Image.open(image_path) as source:
            image = source.convert("RGB")
        draw = ImageDraw.Draw(image)
        width, height = image.size
        for line in lines:
            _, x_center, y_center, box_width, box_height = map(float, line.split())
            x1 = (x_center - box_width / 2) * width
            y1 = (y_center - box_height / 2) * height
            x2 = (x_center + box_width / 2) * width
            y2 = (y_center + box_height / 2) * height
            draw.rectangle((x1, y1, x2, y2), outline=(0, 255, 255), width=2)
        caption = f"pallets anotados: {len(lines)}"
        caption_box = draw.textbbox((0, 0), caption, font=font)
        draw.rectangle(
            (8, 8, caption_box[2] + 20, caption_box[3] + 20), fill=(6, 17, 31)
        )
        draw.text((14, 14), caption, fill=(255, 255, 255), font=font)
        destination = output_dir / f"{args.split}_{image_path.stem}.jpg"
        image.save(destination, quality=92)
        print(destination)


if __name__ == "__main__":
    main()
