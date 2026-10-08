from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "prepare_pallet_dataset.py"
SPEC = importlib.util.spec_from_file_location("prepare_pallet_dataset", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class ConversionTests(unittest.TestCase):
    def test_converts_polygon_to_box_and_remaps_class(self) -> None:
        converted, status, is_target = MODULE.convert_target_line(
            "1 0.2 0.3 0.8 0.3 0.8 0.7 0.2 0.7", 1
        )
        self.assertEqual(status, "polygon")
        self.assertTrue(is_target)
        self.assertEqual(converted, "0 0.500000 0.500000 0.600000 0.400000")

    def test_filters_non_pallet_class(self) -> None:
        converted, status, is_target = MODULE.convert_target_line(
            "2 0.5 0.5 0.2 0.2", 1
        )
        self.assertIsNone(converted)
        self.assertEqual(status, "other")
        self.assertFalse(is_target)

    def test_prepares_positive_and_negative_images(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source"
            output = root / "output"
            for split in ("train", "valid", "test"):
                (source / split / "images").mkdir(parents=True)
                (source / split / "labels").mkdir(parents=True)
                (source / split / "images" / "positive.jpg").write_bytes(b"jpg")
                (source / split / "labels" / "positive.txt").write_text(
                    "1 0.1 0.2 0.9 0.2 0.9 0.8 0.1 0.8\n", encoding="utf-8"
                )
                (source / split / "images" / "negative.jpg").write_bytes(b"jpg")
                (source / split / "labels" / "negative.txt").write_text(
                    "2 0.5 0.5 0.2 0.2\n", encoding="utf-8"
                )

            stats = MODULE.prepare_split(
                source_root=source,
                staging_root=output,
                source_split="train",
                output_split="train",
                source_class=1,
                negative_ratio=1.0,
                use_link=False,
            )
            self.assertEqual(stats.positive_images, 1)
            self.assertEqual(stats.negative_images, 1)
            self.assertEqual(stats.pallet_boxes, 1)
            self.assertEqual(
                (output / "labels" / "train" / "positive.txt").read_text(
                    encoding="utf-8"
                ),
                "0 0.500000 0.500000 0.800000 0.600000\n",
            )

    def test_yaml_points_to_final_dataset_not_staging_folder(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            staging = root / ".dataset.building"
            final_dataset = root / "dataset"
            staging.mkdir()

            MODULE.write_dataset_yaml(staging, final_dataset)

            yaml_text = (staging / "dataset.yaml").read_text(encoding="utf-8")
            self.assertIn(f"path: {final_dataset.resolve().as_posix()}", yaml_text)
            self.assertNotIn(".dataset.building\n", yaml_text)


if __name__ == "__main__":
    unittest.main()
