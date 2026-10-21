const EMULATOR_COLLECTION_PATTERNS: Array<[string, RegExp]> = [
  ["retroarch", /\bretroarch\b/i],
  ["dolphin", /\bdolphin(?:[-_.]?emu)?\b/i],
  ["pcsx2", /\bpcsx2(?:[-_.]?qt)?\b/i],
  ["rpcs3", /\brpcs3\b/i],
  ["duckstation", /\bduckstation\b/i],
  ["cemu", /\bcemu\b/i],
  ["eden", /\beden\b/i],
  ["citron", /\bcitron\b/i],
  ["xenia", /\bxenia(?:[-_.]?(?:qt|canary))?\b/i],
  ["xemu", /\bxemu\b/i],
  ["ppsspp", /\bppsspp(?:[-_.]?qt)?\b/i],
];

export function getCollectionEmulator(name: string): string | null {
  return (
    EMULATOR_COLLECTION_PATTERNS.find(([, pattern]) =>
      pattern.test(name),
    )?.[0] ?? null
  );
}
