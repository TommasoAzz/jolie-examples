include "calculator_wsdl.iol"
include "console.iol"

outputPort CalcOutput {
Location: "socket://localhost:10000"
Protocol: soap
Interfaces: CalculatorWSDL
}

init {
    // Set up for input.
    registerForInput@Console()()

    // Header.
    println@Console("Simple calculator\n")()
}

main {
    // Checking preconditions.
    if(#args > 0 && (args[0] == "sum" || args[0] == "prod" || args[0] == "avg")) {
        op -> args[0]
        if(op != "avg") {
            // Input number 1.
            print@Console("Insert num1: ")()
            in(cin)
            numbers.num1 = double(cin)

            // Input number 2.
            print@Console("Insert num2: ")()
            in(cin)
            numbers.num2 = double(cin)

            if(op == "sum") {
                sum@CalcOutput(numbers)(sumResponse)
                println@Console("Sum: " + sumResponse.output)()
            } else {
                product@CalcOutput(numbers)(prodResponse)
                println@Console("Product: " + prodResponse.output)()
            }
        } else {
            // Input numbers.
            cin = ""
            i = 0
            println@Console("Type \"q\" and press ENTER to stop the insertion of numbers.\n")()
            while(cin != "q") {
                // Input number.
                print@Console("Insert num: ")()
                in(cin)
                if(cin != "q") {
                    avgNumbers.nums[i] = double(cin)
                    i++
                }
            }
            average@CalcOutput(avgNumbers)(avgResponse)
            println@Console("Average: " + avgResponse.output)()
        }
    } else {
        println@Console("The program requires an argument to be passed. Execute the program with the following command:\njolie calc_client.ol sum|prod|avg otherwise it will not work.")()
    }
}