"""Validate pairing, YOLO boxes and split leakage in the prepared dataset."""

from __future__ import annotations

import argparse
import json
import statistics
from pathlib import Path


ML_ROOT = Path(__file__).resolve().parents[1]
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def source_group(stem: str) -> str:
    for marker in ("_jpg.rf.", "_png.rf.", "_jpeg.rf."):
        if marker in stem:
            return stem.split(marker, 1)[0]
    return stem


def percentile(sorted_values: list[float], fraction: float) -> float:
    if not sorted_values:
        return 0.0
    index = round((len(sorted_values) - 1) * fraction)
    return sorted_values[index]


def validate_split(root: Path, split: str) -> tuple[dict[str, object], set[str], list[str]]:
    image_dir = root / "images" / split
    label_dir = root / "labels" / split
    images = {
        path.stem.lower(): path
        for path in image_dir.iterdir()
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    }
    labels = {path.stem.lower(): path for path in label_dir.glob("*.txt")}
    errors: list[str] = []
    areas: list[float] = []
    boxes = 0
    empty_labels = 0
    maximum_boxes = 0

    missing_labels = sorted(set(images) - set(labels))
    missing_images = sorted(set(labels) - set(images))
    if missing_labels:
        errors.append(f"{split}: {len(missing_labels)} imagens sem label")
    if missing_images:
        errors.append(f"{split}: {len(missing_images)} labels sem imagem")

    for stem in sorted(set(images) & set(labels)):
        file_boxes = 0
        content = labels[stem].read_text(encoding="utf-8").splitlines()
        if not any(line.strip() for line in content):
            empty_labels += 1
        for line_number, line in enumerate(content, start=1):
            if not line.strip():
                continue
            parts = line.split()
            if len(parts) != 5:
                errors.append(f"{labels[stem]}:{line_number}: esperado 5 campos")
                continue
            try:
                class_id = int(parts[0])
                x_center, y_center, width, height = map(float, parts[1:])
            except ValueError:
                errors.append(f"{labels[stem]}:{line_number}: valor inválido")
                continue
            if class_id != 0:
                errors.append(f"{labels[stem]}:{line_number}: classe {class_id}, esperado 0")
            if not all(0 <= value <= 1 for value in (x_center, y_center, width, height)):
                errors.append(f"{labels[stem]}:{line_number}: coordenada fora de 0..1")
            if width <= 0 or height <= 0:
                errors.append(f"{labels[stem]}:{line_number}: caixa sem área")
            areas.append(width * height)
            boxes += 1
            file_boxes += 1
        maximum_boxes = max(maximum_boxes, file_boxes)

    areas.sort()
    summary: dict[str, object] = {
        "images": len(images),
        "labels": len(labels),
        "boxes": boxes,
        "empty_negative_labels": empty_labels,
        "max_boxes_in_image": maximum_boxes,
        "mean_boxes_per_image": round(boxes / len(images), 3) if images else 0,
        "box_area": {
            "min": round(areas[0], 8) if areas else 0,
            "p10": round(percentile(areas, 0.10), 8),
            "median": round(statistics.median(areas), 8) if areas else 0,
            "p90": round(percentile(areas, 0.90), 8),
            "max": round(areas[-1], 8) if areas else 0,
        },
    }
    groups = {source_group(stem) for stem in images}
    return summary, groups, errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Valida o dataset de pallets preparado.")
    parser.add_argument(
        "--data",
        type=Path,
        default=ML_ROOT / "data" / "pallet_detection",
    )
    args = parser.parse_args()
    root = args.data.expanduser().resolve()
    yaml_path = root / "dataset.yaml"
    if not yaml_path.is_file():
        raise FileNotFoundError(f"Dataset preparado não encontrado: {root}")

    report: dict[str, object] = {"dataset": str(root), "splits": {}, "leakage": {}}
    groups_by_split: dict[str, set[str]] = {}
    errors: list[str] = []

    configured_root: Path | None = None
    for line in yaml_path.read_text(encoding="utf-8").splitlines():
        if line.strip().startswith("path:"):
            configured_root = Path(line.split(":", 1)[1].strip()).expanduser().resolve()
            break
    report["configured_path"] = str(configured_root) if configured_root else None
    if configured_root is None:
        errors.append("dataset.yaml: campo path ausente")
    elif configured_root != root:
        errors.append(
            f"dataset.yaml: path aponta para {configured_root}, esperado {root}"
        )

    for split in ("train", "val", "test"):
        summary, groups, split_errors = validate_split(root, split)
        report["splits"][split] = summary  # type: ignore[index]
        groups_by_split[split] = groups
        errors.extend(split_errors)

    for left, right in (("train", "val"), ("train", "test"), ("val", "test")):
        overlap = sorted(groups_by_split[left] & groups_by_split[right])
        report["leakage"][f"{left}_{right}"] = {  # type: ignore[index]
            "overlapping_source_groups": len(overlap),
            "examples": overlap[:10],
        }
        if overlap:
            errors.append(
                f"Possível vazamento entre {left} e {right}: {len(overlap)} grupos"
            )

    report["errors"] = errors
    report_path = root / "validation_report.json"
    report_path.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))
    print(f"\nRelatório: {report_path}")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
