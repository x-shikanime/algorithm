function scoreOneAway(a: string, b: string, scores: number[]): number {
  if (a.length === 0) {
    return scores.reduce((a, b) => a + b);
  }
  return scoreOneAwayCompare(a, b, scores);
}

function scoreOneAwayCompare(a: string, b: string, scores: number[]): number {
  if (a[0] === b[0]) {
    return scoreOneAway(a.slice(1), b.slice(1), [...scores, 1]);
  }
  return scoreOneAwayEdition(a, b, scores);
}

function scoreOneAwayEdition(a: string, b: string, scores: number[]): number {
  const nextScores = scoreOneAwayReplace(a, b, scores);
  if (nextScores === null) {
    return scoreOneAwayDeletion(a, b, scores);
  }
  return nextScores;
}

function scoreOneAwayReplace(
  a: string,
  b: string,
  scores: number[],
): number | null {
  const next = b.indexOf(a[0]);
  if (next !== -1) {
    const deleteIdx = scores.findIndex((x) => x !== -1);
    return scoreOneAway(
      a,
      b.slice(next),
      deleteIdx !== -1
        ? scores.slice(next >= deleteIdx ? deleteIdx : next)
        : [],
    );
  }
  return null;
}

function scoreOneAwayDeletion(a: string, b: string, scores: number[]): number {
  return scoreOneAway(a.slice(1), b, [...scores, -1]);
}

export function oneAway(a: string, b: string, factor: number): boolean {
  return scoreOneAway(a, b, []) >= b.length - factor;
}
