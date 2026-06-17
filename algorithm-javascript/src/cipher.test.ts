import { expect, test } from "vitest";
import { findSignatureCounts } from "./cipher";

test("findSignatureCounts", () => {
  expect(findSignatureCounts([2, 1])).toEqual([2, 2]);
  expect(findSignatureCounts([1, 2])).toEqual([1, 1]);
});
