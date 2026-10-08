"""Prepare a pallet-only YOLO detection dataset from the warehouse dataset.

The source contains five classes and polygon annotations. This script keeps
only source class 1 (pallet), converts polygons to bounding boxes, remaps the
class to 0, and optionally keeps a deterministic sample of negative images.
The source dataset is never modified.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import sys
import uuid
from dataclasses import asdict, dataclass
from pathlib import Path


IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
SOURCE_SPLITS = {"train": "train", "valid": "val", "test": "test"}


@dataclass
class SplitStats:
    source_images: int = 0
    source_labels: int = 0
    positive_images: int = 0
    negative_images: int = 0
    skipped_negative_images: int = 0
    missing_labels: int = 0
    orphan_labels: int = 0
    pallet_boxes: int = 0
    filtered_other_boxes: int = 0
    polygon_boxes_converted: int = 0
    bbox_boxes_kept: int = 0
    invalid_lines: int = 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Unifica o dataset mantendo apenas pallets para detecção e contagem."
    )
    parser.add_argument(
        "--source",
        type=Path,
        help="Pasta warehouse.v1i.yolov8 do dataset original.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "data" / "pallet_detection",
        help="Pasta de saída do dataset preparado.",
    )
    parser.add_argument(
        "--source-class",
        type=int,
        default=1,
        help="ID original da classe pallet (padrão: 1).",
    )
    parser.add_argument(
        "--negative-ratio",
        type=float,
        default=0.15,
        help="Proporção determinística de imagens sem pallets mantida como negativos.",
    )
    parser.add_argument(
        "--link",
        action="store_true",
        help="Cria hard links das imagens em vez de copiá-las (somente mesmo disco).",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Substitui somente a pasta de saída informada, se ela já existir.",
    )
    return parser.parse_args()


def discover_source(explicit: Path | None) -> Path:
    candidates = []
    if explicit is not None:
        candidates.append(explicit)
    candidates.extend(
        [
            Path.cwd()
            / "backend"
            / "dataset"
            / "paletesAvariados"
            / "warehouse.v1i.yolov8",
            Path.home()
            / "Palletsort"
            / "backend"
            / "dataset"
            / "paletesAvariados"
            / "warehouse.v1i.yolov8",
        ]
    )
    for candidate in candidates:
        resolved = candidate.expanduser().resolve()
        if (resolved / "data.yaml").is_file():
            return resolved
    searched = "\n - ".join(str(path) for path in candidates)
    raise FileNotFoundError(f"Dataset YOLO não encontrado. Locais verificados:\n - {searched}")


def stable_fraction(value: str) -> float:
    digest = hashlib.sha256(value.encode("utf-8")).digest()
    return int.from_bytes(digest[:8], "big") / float(2**64 - 1)


def clamp(value: float) -> float:
    return max(0.0, min(1.0, value))


def convert_target_line(
    line: str,
    source_class: int,
) -> tuple[str | None, str, bool]:
    """Return converted line, status and whether the source line was a target."""
    parts = line.strip().split()
    if not parts:
        return None, "empty", False
    try:
        class_id = int(float(parts[0]))
        values = [float(value) for value in parts[1:]]
    except ValueError:
        return None, "invalid", False

    is_target = class_id == source_class
    if len(values) == 4:
        if not is_target:
            return None, "other", False
        x_center, y_center, width, height = values
        x_center, y_center = clamp(x_center), clamp(y_center)
        width, height = clamp(width), clamp(height)
        if width <= 0 or height <= 0:
            return None, "invalid", True
        converted = f"0 {x_center:.6f} {y_center:.6f} {width:.6f} {height:.6f}"
        return converted, "bbox", True

    if len(values) >= 6 and len(values) % 2 == 0:
        if not is_target:
            return None, "other", False
        xs = [clamp(value) for value in values[0::2]]
        ys = [clamp(value) for value in values[1::2]]
        x_min, x_max = min(xs), max(xs)
        y_min, y_max = min(ys), max(ys)
        width, height = x_max - x_min, y_max - y_min
        if width <= 0 or height <= 0:
            return None, "invalid", True
        x_center = x_min + width / 2
        y_center = y_min + height / 2
        converted = f"0 {x_center:.6f} {y_center:.6f} {width:.6f} {height:.6f}"
        return converted, "polygon", True

    return None, "invalid", is_target


def transfer_image(source: Path, destination: Path, use_link: bool) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if use_link:
        try:
            os.link(source, destination)
            return
        except OSError:
            pass
    shutil.copy2(source, destination)


def prepare_split(
    source_root: Path,
    staging_root: Path,
    source_split: str,
    output_split: str,
    source_class: int,
    negative_ratio: float,
    use_link: bool,
) -> SplitStats:
    stats = SplitStats()
    image_dir = source_root / source_split / "images"
    label_dir = source_root / source_split / "labels"
    output_images = staging_root / "images" / output_split
    output_labels = staging_root / "labels" / output_split
    output_images.mkdir(parents=True, exist_ok=True)
    output_labels.mkdir(parents=True, exist_ok=True)

    images = {
        path.stem.lower(): path
        for path in image_dir.iterdir()
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    }
    labels = {path.stem.lower(): path for path in label_dir.glob("*.txt")}
    stats.source_images = len(images)
    stats.source_labels = len(labels)
    stats.orphan_labels = len(set(labels) - set(images))

    for stem in sorted(images):
        image_path = images[stem]
        label_path = labels.get(stem)
        if label_path is None:
            stats.missing_labels += 1
            continue

        converted_lines: list[str] = []
        for raw_line in label_path.read_text(encoding="utf-8").splitlines():
            converted, status, was_target = convert_target_line(raw_line, source_class)
            if status == "other":
                stats.filtered_other_boxes += 1
            elif status == "invalid":
                stats.invalid_lines += 1
            elif status == "polygon":
                stats.polygon_boxes_converted += 1
            elif status == "bbox":
                stats.bbox_boxes_kept += 1
            if converted is not None:
                converted_lines.append(converted)
                stats.pallet_boxes += 1
            elif was_target and status != "invalid":
                stats.invalid_lines += 1

        is_positive = bool(converted_lines)
        keep_negative = stable_fraction(f"{source_split}/{stem}") < negative_ratio
        if not is_positive and not keep_negative:
            stats.skipped_negative_images += 1
            continue

        destination_image = output_images / image_path.name
        destination_label = output_labels / f"{image_path.stem}.txt"
        transfer_image(image_path, destination_image, use_link)
        destination_label.write_text(
            "\n".join(converted_lines) + ("\n" if converted_lines else ""),
            encoding="utf-8",
        )
        if is_positive:
            stats.positive_images += 1
        else:
            stats.negative_images += 1

    return stats


def write_dataset_yaml(destination_root: Path, dataset_root: Path) -> None:
    content = (
        f"path: {dataset_root.resolve().as_posix()}\n"
        "train: images/train\n"
        "val: images/val\n"
        "test: images/test\n\n"
        "names:\n"
        "  0: pallet\n"
    )
    (destination_root / "dataset.yaml").write_text(content, encoding="utf-8")


def validate_output_path(path: Path) -> None:
    resolved = path.resolve()
    forbidden = {Path(resolved.anchor).resolve(), Path.home().resolve(), Path.cwd().resolve()}
    if resolved in forbidden or len(resolved.parts) < 3:
        raise ValueError(f"Pasta de saída insegura: {resolved}")


def main() -> int:
    args = parse_args()
    if not 0 <= args.negative_ratio <= 1:
        raise ValueError("--negative-ratio deve estar entre 0 e 1")

    source_root = discover_source(args.source)
    output_root = args.output.expanduser().resolve()
    validate_output_path(output_root)
    staging_root = output_root.with_name(f".{output_root.name}.building-{uuid.uuid4().hex[:8]}")

    if output_root.exists() and not args.overwrite:
        raise FileExistsError(
            f"A saída já existe: {output_root}. Use --overwrite para recriá-la."
        )

    report: dict[str, object] = {
        "source": str(source_root),
        "output": str(output_root),
        "source_class": args.source_class,
        "output_classes": {"0": "pallet"},
        "negative_ratio": args.negative_ratio,
        "splits": {},
        "notes": [
            "Somente a classe pallet foi mantida.",
            "Polígonos YOLO foram convertidos em bounding boxes.",
            "O dataset sem anotações Paletes/dataset não foi usado.",
            "Não há anotações de avaria na fonte atual.",
        ],
    }

    try:
        for source_split, output_split in SOURCE_SPLITS.items():
            stats = prepare_split(
                source_root=source_root,
                staging_root=staging_root,
                source_split=source_split,
                output_split=output_split,
                source_class=args.source_class,
                negative_ratio=args.negative_ratio,
                use_link=args.link,
            )
            report["splits"][output_split] = asdict(stats)  # type: ignore[index]

        # O YAML é escrito dentro da pasta temporária, mas deve apontar para o
        # destino definitivo que existirá após a troca atômica abaixo.
        write_dataset_yaml(staging_root, output_root)
        (staging_root / "preparation_report.json").write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        for source_name, destination_name in (
            ("README.dataset.txt", "SOURCE_README.dataset.txt"),
            ("README.roboflow.txt", "SOURCE_README.roboflow.txt"),
        ):
            source_file = source_root / source_name
            if source_file.is_file():
                shutil.copy2(source_file, staging_root / destination_name)

        if output_root.exists():
            shutil.rmtree(output_root)
        staging_root.replace(output_root)
    except Exception:
        if staging_root.exists():
            shutil.rmtree(staging_root)
        raise

    print(json.dumps(report, ensure_ascii=False, indent=2))
    print(f"\nDataset preparado em: {output_root}")
    print(f"Configuração YOLO: {output_root / 'dataset.yaml'}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ERRO: {exc}", file=sys.stderr)
        raise
