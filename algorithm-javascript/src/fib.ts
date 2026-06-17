type Memo = { [key: number]: number };

export function fib(n: number, acc: Memo = { [0]: 0, [1]: 1 }): [number, Memo] {
  if (n in acc) return [acc[n], acc];
  const [a, aacc] = fib(n - 2, acc);
  const [b, bacc] = fib(n - 1, aacc);
  const c = a + b;
  return [c, { [n]: c, ...bacc }];
}
