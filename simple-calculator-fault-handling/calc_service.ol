include "calculator.iol"
include "console.iol"

// Execution can be:
// - "single" (one shot, then it shuts down);
// - "concurrent" (can elaborate concurrent requests);
// - "sequential" (can elaborate requests one after one other).
execution{ concurrent }

inputPort CalcInput {
Location: "socket://localhost:8000"
Protocol: sodep
Interfaces: Calculator
}

init {
    println@Console("Simple Calculator service is running...")()

    install(
        IOException => println@Console("The client has disconnected.")(),
        DivisionByZero => println@Console("Division by 0 is not possible!")()
    )
}

main {
    [sum(numbers)(response) {
        println@Console("Sum request of the following numbers: " + numbers.num1 + ", " + numbers.num2 + ".")()
        response = numbers.num1 + numbers.num2
    }]

    [prod(numbers)(response) {
        println@Console("Product request of the following numbers: " + numbers.num1 + ", " + numbers.num2 + ".")()
        response = numbers.num1 * numbers.num2
    }]

    [idiv(numbers)(response) {
        println@Console("Integer division request of the following numbers: " + numbers.num1 + ", " + numbers.num2 + ".")()
        if(numbers.num2 == 0) {
            throw(DivisionByZero)
        }
        response = numbers.num1 / numbers.num2
    }]

    [avg(numbers)(response) {
        print@Console("Average request of the following " + #numbers.nums + " numbers: ")()
        if(#numbers.nums > 0) {
            manyNums -> numbers.nums
            // Printing manyNums.
            printArray 

            // Calculation of the average.
            sum = 0.0
            for(n in manyNums) {
                sum += (n / #manyNums)
            }
            response = sum
        } else {
            print@Console("0 items received.\n")()
            response = 0
        }
    }]
}

// An object named manyNums must be declared before the invoking this procedure.
define printArray {
    print@Console(manyNums[0])()
    for(i = 1, i < #manyNums, i++) {
        print@Console(", " + manyNums[i])()
    }
    print@Console("\n")()
}