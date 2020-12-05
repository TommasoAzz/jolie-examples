type TwoNumbers: void {
    .num1: double
    .num2: double
}

type TwoIntNumbers: void {
    .num1: int
    .num2: int
}

type ManyNumbers: void {
    .nums[0,*]: double
}

interface Calculator {
RequestResponse:
    sum(TwoNumbers)(double),
    prod(TwoNumbers)(double),
    idiv(TwoIntNumbers)(int) throws DivisionByZero,
    avg(ManyNumbers)(double)
}