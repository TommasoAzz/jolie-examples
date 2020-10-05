include "calculator.iol"
include "console.iol"

outputPort CalcOutput {
Location: "socket://localhost:8000"
Protocol: sodep
Interfaces: Calculator
}

main {
    // Set up for input
    registerForInput@Console()()

    // Input number 1
    print@Console("Insert num1: ")()
    in(cin)
    numbers.num1 = double(cin)

    // Input number 2
    print@Console("Insert num2: ")()
    in(cin)
    numbers.num2 = double(cin)

    // Definition of array
    avgNumbers.nums[0] = numbers.num1
    avgNumbers.nums[1] = numbers.num2
    
    sum@CalcOutput(numbers)(sumResponse)
    prod@CalcOutput(numbers)(prodResponse)
    avg@CalcOutput(avgNumbers)(avgResponse)

    println@Console("Sum: " + sumResponse)()
    println@Console("Product: " + prodResponse)()
    println@Console("Average: " + avgResponse)()
}