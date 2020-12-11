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

cset {
	sid: WillUseHelpData.sid
         SendPaymentRequest.sid
         SendPaymentHelperRequest.sid
         SendPaymentHelpedRequest.sid
         InitPaymentProcessResponse.sid
         AskForHelpData.sid
         RefundHelperData.sid
         CloseData.sid
}

init {
    println@Console("Online shopping - Helper is running...")()
}

main {
    // Waiting for incoming requests to operation: askForHelp
    askForHelp(askForHelpData)
    println@Console("\nInvoked operation \"askForHelp\".")()
    // --- //
    if(askForHelpData.needHelp) {
        println@Console("The Buyer requested help.")()
        sendPaymentHelperRequest.sid = csets.sid = askForHelpData.sid
        if(askForHelpData.amount >= 0) {
            sendPaymentHelperRequest.amount = askForHelpData.amount
        } else {
            sendPaymentHelperRequest.amount = 0.0
        }
        sendPaymentHelper@SellerOutput(sendPaymentHelperRequest)
        println@Console("A total amount of " + sendPaymentHelperRequest.amount + " was given to the Seller for helping the Buyer.")()
    } else {
        println@Console("The Buyer did not request any help.")()
    }

    // Waiting for incoming requests to operation: close
    [close(closeData)] {
        println@Console("\nInvoked operation \"close\".")()
        // --- //
        if(closeData.errors) {
            println@Console(closeData.message)()
        } else {
            println@Console("The product was correctly shipped to the Buyer.")()
        }
    }
    
    [sendRefund(refundData)] {
        println@Console("\nInvoked operation \"sendRefund\".")()
        // --- //
        println@Console("The payment could not be processed. Refund amount: " + refundData.amount)()
    }
}