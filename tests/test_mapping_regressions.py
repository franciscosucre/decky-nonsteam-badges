import io
import json
import types
import unittest
from unittest import mock

from test_main import import_main


class MappingRegressionTests(unittest.TestCase):
    def get_mapping(self, shortcut, tags=()):
        main = import_main()
        appid = 3000000000
        shortcut = {"appid": appid, "AppName": "Regression fixture", **shortcut}
        apps = {str(appid): {"tags": dict(enumerate(tags))}}
        fake_vdf = types.SimpleNamespace(
            load=lambda _: {"UserLocalConfigStore": {"Software": {"Valve": {"Steam": {"apps": apps}}}}},
            binary_load=lambda _: {"shortcuts": {"0": shortcut}},
        )

        def fake_open(path, mode="r", *args, **kwargs):
            if str(path).endswith("store_mappings.json"):
                return io.StringIO(json.dumps({"gog": ["gog"], "epic": ["epic"]}))
            return io.BytesIO(b"") if "b" in mode else io.StringIO("")

        with (
            mock.patch.object(main, "vdf", fake_vdf),
            mock.patch.object(main.Plugin, "_find_shortcuts_vdf", return_value="/fake/shortcuts.vdf"),
            mock.patch.object(main.Path, "is_file", return_value=True),
            mock.patch("builtins.open", side_effect=fake_open),
        ):
            mapping = main.Plugin._get_games_mapping()
        return mapping[str(appid)]

    def test_numbered_storefront_collections_keep_priority(self):
        for collection, expected, conflicting_exe in (
            ("GOG 2026", "gog", "/games/epic/game.exe"),
            ("Epic 2025", "epic", "/games/gog/game.exe"),
        ):
            with self.subTest(collection=collection):
                entry = self.get_mapping({"Exe": conflicting_exe}, [collection])
                self.assertEqual(entry["store"], expected)

    def test_numbered_storefront_launch_metadata_still_matches(self):
        for alias, expected in (("gog", "gog"), ("epic", "epic")):
            for field, value in (
                ("LaunchOptions", f"--provider {alias} 2026"),
                ("Exe", f"/games/{alias} 2026/game.exe"),
                ("StartDir", f"/games/{alias} 2026"),
            ):
                with self.subTest(alias=alias, field=field):
                    self.assertEqual(self.get_mapping({field: value})["store"], expected)

    def test_ppssppqt_selects_dedicated_ppsspp_badge(self):
        for exe in ("/apps/PPSSPPQt", "/apps/ppssppqt.AppImage"):
            with self.subTest(exe=exe):
                entry = self.get_mapping({"Exe": exe})
                self.assertEqual(entry["store"], "emulators")
                self.assertEqual(entry.get("emulator"), "ppsspp")
