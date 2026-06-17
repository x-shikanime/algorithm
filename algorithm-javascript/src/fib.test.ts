import { expect, test } from "vitest";
import { fib } from "./fib";

test("fib", () => {
  expect(fib(10)[0]).toBe(55);
});
