type SumRequest: void {
    .num1: double
    .num2: double
}

type SumResponse: void {
    .output: double
}

type ProductRequest: void {
    .num1: double
    .num2: double
}

type ProductResponse: void {
    .output: double
}

type AverageRequest: void {
    .nums[0,*]: double
}

type AverageResponse: void {
    .output: double
}

interface CalculatorWSDL {
RequestResponse:
    sum(SumRequest)(SumResponse),
    product(ProductRequest)(ProductResponse),
    average(AverageRequest)(AverageResponse)
}