include "interface.iol"
include "console.iol"

// Deployment part
inputPort MyInput {
Location: "socket://localhost:8000"
Protocol: sodep
Interfaces: MyInterface
}

// Behaviour part
main {
    sendNumber(x)
    println@Console("Received: " + x)()
}