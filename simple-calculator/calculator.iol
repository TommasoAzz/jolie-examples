// type ITwoNumbers: void {
type TwoNumbers: void {
    .num1: double
    .num2: double
}

// type TwoNumbers: ITwoNumbers

// type IManyNumbers: void {
type ManyNumbers: void {
    .nums*: double
}

// type ManyNumbers: IManyNumbers

interface Calculator {
RequestResponse:
    sum(TwoNumbers)(double),
    prod(TwoNumbers)(double),
    avg(ManyNumbers)(double)
}