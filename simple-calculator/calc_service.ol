include "calculator.iol"
include "console.iol"

inputPort CalcInput {
Location: "socket://localhost:8000"
Protocol: sodep
Interfaces: Calculator
}

main {
    while(true) {
        [sum(numbers)(response) {
            response = numbers.num1 + numbers.num2
        }]

        [prod(numbers)(response) {
            response = numbers.num1 * numbers.num2
        }]

        [avg(numbers)(response) {
            sum = 0.0
            manyNums -> numbers.nums
            for(n in manyNums) {
                sum += n
            }
            response = (sum / #manyNums)
        }]
    }
}