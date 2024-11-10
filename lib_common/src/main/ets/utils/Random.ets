export function getRandomNextNumber(n: number, m: number) {
  return Math.floor(Math.random() * (m - n) + n)
}