import { expect, test } from "vitest";
import { oneAway } from "./oneAway";

test("oneAway", () => {
  expect(oneAway("pale", "ple", 1)).toBe(true);
  expect(oneAway("pales", "pale", 1)).toBe(true);
  expect(oneAway("pale", "bale", 1)).toBe(true);
  expect(oneAway("pale", "bake", 1)).toBe(false);
});
