"""Train a one-class pallet detector with Ultralytics YOLO."""

from __future__ import annotations

import argparse
from pathlib import Path


ML_ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Treina o detector de pallets.")
    parser.add_argument(
        "--data",
        type=Path,
        default=ML_ROOT / "data" / "pallet_detection" / "dataset.yaml",
    )
    parser.add_argument("--model", default="yolo26n.pt")
    parser.add_argument("--epochs", type=int, default=100)
    parser.add_argument("--imgsz", type=int, default=640)
    parser.add_argument("--batch", type=int, default=-1)
    parser.add_argument("--device", default=None)
    parser.add_argument("--workers", type=int, default=2)
    parser.add_argument("--name", default="pallet_detector")
    parser.add_argument("--smoke-test", action="store_true")
    parser.add_argument("--resume", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    try:
        from ultralytics import YOLO
    except ImportError as exc:
        raise SystemExit(
            "Ultralytics não instalado. Execute: pip install -r ml/requirements.txt"
        ) from exc

    data_path = args.data.expanduser().resolve()
    if not data_path.is_file():
        raise FileNotFoundError(
            f"Dataset não preparado: {data_path}. Rode prepare_pallet_dataset.py primeiro."
        )

    if args.resume:
        model = YOLO(str(args.resume.expanduser().resolve()))
        model.train(resume=True)
        return

    epochs = 1 if args.smoke_test else args.epochs
    fraction = 0.02 if args.smoke_test else 1.0
    run_name = (
        "pallet_detector_smoke"
        if args.smoke_test and args.name == "pallet_detector"
        else args.name
    )
    model = YOLO(args.model)
    model.train(
        data=str(data_path),
        epochs=epochs,
        imgsz=args.imgsz,
        batch=args.batch,
        device=args.device,
        workers=args.workers,
        project=str(ML_ROOT / "runs"),
        name=run_name,
        exist_ok=False,
        pretrained=True,
        patience=20,
        close_mosaic=10,
        seed=42,
        deterministic=True,
        fraction=fraction,
        plots=True,
        verbose=True,
    )


if __name__ == "__main__":
    main()
