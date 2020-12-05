include "calculator.iol"
include "console.iol"
include "time.iol"

outputPort CalcOutput {
Location: "socket://localhost:8000"
Protocol: sodep
Interfaces: Calculator
}

init {
    // Set up for input.
    registerForInput@Console()()

    // Header.
    println@Console("Simple calculator\n")()
}

main {
    install(
        IOException => println@Console("The Simple Calculator Service is offline.")()
    )
    
    // Checking preconditions.
    if(#args > 0 && (args[0] == "sum" || args[0] == "prod" || args[0] == "avg" || args[0] == "idiv")) {
        op -> args[0]
        if(op == "idiv") {
            scope(idiv_scope) {
                install(
                    DivisionByZero => println@Console("Division by 0 is not possible!")()
                )
                // Input number 1.
                print@Console("Insert (integer) num1: ")()
                in(cin)
                numbers.num1 = int(cin)

                // Input number 2.
                print@Console("Insert (integer) num2: ")()
                in(cin)
                numbers.num2 = int(cin)

                idiv@CalcOutput(numbers)(divResponse)
                println@Console("Integer division: " + divResponse)()                
            }
        } else {
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
                    println@Console("Sum: " + sumResponse)()
                } else {
                    prod@CalcOutput(numbers)(prodResponse)
                    println@Console("Product: " + prodResponse)()
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
                avg@CalcOutput(avgNumbers)(avgResponse)
                println@Console("Average: " + avgResponse)()
            }
        }
    } else {
        println@Console("The program requires an argument to be passed. Execute the program with the following command:\njolie calc_client.ol sum|prod|idiv|avg otherwise it will not work.")()
    }
}