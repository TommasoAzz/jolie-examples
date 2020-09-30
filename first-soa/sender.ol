include "interface.iol"

// Deployment part
outputPort Receiver {
Location: "socket://localhost:8000"
Protocol: sodep // Proprietary protocol used by Jolie (HTTP or SOAP can also be used, the important thing is that the protocols in the client and the server match)
Interfaces: MyInterface
}

// Behaviour part
main {
    sendNumber@Receiver(5)
}