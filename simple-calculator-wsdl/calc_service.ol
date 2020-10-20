include "calculator_wsdl.iol"
include "console.iol"

// Execution can be:
// - "single" (one shot, then it shuts down);
// - "concurrent" (can elaborate concurrent requests);
// - "sequential" (can elaborate requests one after one other).
execution{ concurrent }

inputPort CalcInput {
Location: "socket://localhost:10000"
Protocol: soap {
    .wsdl = "./calculator.wsdl";
    .wsdl.port = "CalcInput";
    .dropRootValue = true
}
Interfaces: CalculatorWSDL
}

init {
    println@Console("Simple Calculator WSDL service is running...")()
}

main {
    [sum(request)(response) {
        println@Console("Sum request of the following numbers: " + request.num1 + ", " + request.num2 + ".")()
        response.output = request.num1 + request.num2
    }]

    [product(request)(response) {
        println@Console("Product request of the following numbers: " + request.num1 + ", " + request.num2 + ".")()
        response.output = request.num1 * request.num2
    }]

    [average(request)(response) {
        print@Console("Average request of the following " + #request.nums + " numbers: ")()
        if(#request.nums > 0) {
            manyNums -> request.nums
            // Printing manyNums.
            printArray 

            // Calculation of the average.
            sum = 0.0
            for(n in manyNums) {
                sum += (n / #manyNums)
            }
            response.output = sum
        } else {
            print@Console("0 items received.\n")()
            response.output = 0
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