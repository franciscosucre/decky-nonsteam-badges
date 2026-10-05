import test from "node:test";
import assert from "node:assert/strict";
import { getCollectionEmulator } from "../.test-dist/utils/emulatorCollections.js";

test("specific emulator collections select an identity without launch metadata", () => {
  for (const [name, expected] of [
    ["RetroArch", "retroarch"],
    ["Dolphin", "dolphin"],
    ["GC", "dolphin"],
    ["GameCube", "dolphin"],
    ["PCSX2", "pcsx2"],
    ["RPCS3", "rpcs3"],
    ["PS3", "rpcs3"],
    ["PlayStation 3", "rpcs3"],
    ["DuckStation", "duckstation"],
    ["PS1", "duckstation"],
    ["PlayStation 1", "duckstation"],
    ["Eden", "eden"],
    ["Switch", "eden"],
    ["Nintendo Switch", "eden"],
    ["Xenia", "xenia"],
    ["xemu", "xemu"],
    ["Xenia Canary", "xenia"],
    ["xenia_canary", "xenia"],
    ["My PCSX2 games", "pcsx2"],
    ["PS2", "pcsx2"],
    ["PlayStation 2", "pcsx2"],
    ["Xbox360", "xenia"],
    ["Xbox 360 games", "xenia"],
    ["PPSSPP", "ppsspp"],
    ["PSP", "ppsspp"],
  ])
    assert.equal(getCollectionEmulator(name), expected);
});

test("generic and unrelated collections do not select an individual emulator", () => {
  for (const name of [
    "Xbox",
    "Emulators",
    "PlayStation Portable",
    "mygc",
    "myps3",
    "myps1",
    "myeden",
    "myxenia",
    "retroarchived",
    "",
  ]) {
    assert.equal(getCollectionEmulator(name), null);
  }
});
