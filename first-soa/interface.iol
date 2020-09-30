// Defining an interface for the application
interface MyInterface {
OneWay: // OnewWay means that data flows in one way only, from the client to the server (and not the other way around)
    sendNumber(int) // Operation that the client can invoke on the server
}