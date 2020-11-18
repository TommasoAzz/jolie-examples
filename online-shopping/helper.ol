include "console.iol"
include "helper.iol"
include "seller.iol"

execution{ concurrent }

inputPort HelperInput {
    Location: "socket://localhost:8200"
    Protocol: sodep
    Interfaces: Helper
}

outputPort SellerOutput {
    Location: "socket://localhost:8100"
    Protocol: sodep
    Interfaces: Seller
}

init {
    println@Console("Online shopping - Helper is running...")()

    keepRunning = true
}

main {
    // askForHelp(askForHelpData) {
    //     if(askForHelpData.needHelp) {
    //         println@Console("The Buyer requested help.")()
    //         sendPaymentHelperRequest.sid = askForHelpData.sid
    //         sendPaymentHelperRequest.amount = askForHelpData.amount
    //         sendPaymentHelper@SellerOutput(sendPaymentHelperRequest)
    //     } else {
    //         println@Console("The Buyer did not request any help.")()   
    //     }
    // }

    // while(keepRunning) {
    //     [close(closeData)] {
    //         if(closeData.errors) {
    //             println@Console(closeData.message)()
    //         } else {
    //             println@Console("The product was correctly shipped to the Buyer.")()
    //         }

    //         keepRunning = false
    //         println@Console("Invoked operation \"close\".")()
    //     }
    // }
    [askForHelp(askForHelpData)] {
        println@Console("Invoked operation \"askForHelp\".")()
        // --- //
        if(askForHelpData.needHelp) {
            println@Console("The Buyer requested help.")()
            sendPaymentHelperRequest.sid = askForHelpData.sid
            sendPaymentHelperRequest.amount = askForHelpData.amount
            sendPaymentHelper@SellerOutput(sendPaymentHelperRequest)
            println@Console("The Helper's part was paid.")()
        } else {
            println@Console("The Buyer did not request any help.")()
        }
    }

    // while(keepRunning) {
        [close(closeData)] {
            println@Console("Invoked operation \"close\".")()
            // --- //
            if(closeData.errors) {
                println@Console(closeData.message)()
            } else {
                println@Console("The product was correctly shipped to the Buyer.")()
            }

            keepRunning = false
        }
    // }
}