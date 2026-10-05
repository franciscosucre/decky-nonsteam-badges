const EMULATOR_COLLECTION_PATTERNS: Array<[string, RegExp]> = [
  ["retroarch", /\bretroarch\b/i],
  ["dolphin", /\bdolphin(?:-emu)?\b/i],
  ["pcsx2", /\b(?:pcsx2(?:-qt)?|ps2|playstation\s+2)\b/i],
  ["rpcs3", /\brpcs3\b/i],
  ["xenia", /\b(?:xenia(?:[_-]canary)?|xbox\s*360)\b/i],
  ["xemu", /\bxemu\b/i],
  ["ppsspp", /\b(?:ppsspp|psp)\b/i],
];

export function getCollectionEmulator(name: string): string | null {
  return (
    EMULATOR_COLLECTION_PATTERNS.find(([, pattern]) =>
      pattern.test(name),
    )?.[0] ?? null
  );
}
