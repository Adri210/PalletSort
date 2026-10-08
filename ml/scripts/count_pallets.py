"""Run pallet detection and print the visible pallet count per image/frame."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


ML_ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Detecta e conta pallets.")
    parser.add_argument("source", help="Imagem, vídeo, pasta ou câmera (ex.: 0).")
    parser.add_argument(
        "--weights",
        type=Path,
        default=ML_ROOT / "runs" / "pallet_detector" / "weights" / "best.pt",
    )
    parser.add_argument("--confidence", type=float, default=0.35)
    parser.add_argument("--iou", type=float, default=0.55)
    parser.add_argument("--imgsz", type=int, default=640)
    parser.add_argument("--max-detections", type=int, default=500)
    parser.add_argument("--name", default="pallet_counts")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    try:
        from ultralytics import YOLO
    except ImportError as exc:
        raise SystemExit(
            "Ultralytics não instalado. Execute: pip install -r ml/requirements.txt"
        ) from exc

    weights = args.weights.expanduser().resolve()
    if not weights.is_file():
        raise FileNotFoundError(f"Pesos não encontrados: {weights}")

    model = YOLO(str(weights))
    results = model.predict(
        source=args.source,
        conf=args.confidence,
        iou=args.iou,
        imgsz=args.imgsz,
        max_det=args.max_detections,
        classes=[0],
        stream=True,
        save=True,
        project=str(ML_ROOT / "outputs"),
        name=args.name,
        exist_ok=True,
        verbose=False,
    )

    for frame_index, result in enumerate(results):
        count = 0 if result.boxes is None else len(result.boxes)
        confidences = (
            []
            if result.boxes is None
            else [round(float(value), 4) for value in result.boxes.conf.cpu().tolist()]
        )
        print(
            json.dumps(
                {
                    "source": str(result.path),
                    "frame": frame_index,
                    "pallet_count": count,
                    "confidences": confidences,
                },
                ensure_ascii=False,
            )
        )


if __name__ == "__main__":
    main()
