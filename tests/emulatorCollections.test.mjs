import test from "node:test";
import assert from "node:assert/strict";
import { getCollectionEmulator } from "../.test-dist/utils/emulatorCollections.js";

test("specific emulator collections select an identity without launch metadata", () => {
  for (const [name, expected] of [
    ["RetroArch", "retroarch"],
    ["Dolphin", "dolphin"],
    ["PCSX2", "pcsx2"],
    ["RPCS3", "rpcs3"],
    ["DuckStation", "duckstation"],
    ["Eden", "eden"],
    ["Xenia", "xenia"],
    ["xemu", "xemu"],
    ["Xenia Canary", "xenia"],
    ["xenia_canary", "xenia"],
    ["My PCSX2 games", "pcsx2"],
    ["PPSSPP", "ppsspp"],
  ])
    assert.equal(getCollectionEmulator(name), expected);
});

test("generic and unrelated collections do not select an individual emulator", () => {
  for (const name of ["Emulators", "myxenia", "retroarchived", ""]) {
    assert.equal(getCollectionEmulator(name), null);
  }
});
