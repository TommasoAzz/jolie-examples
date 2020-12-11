include "console.iol"
include "math.iol"
include "seller.iol"
include "buyer.iol"
include "helper.iol"
include "time.iol"

execution{ concurrent }

inputPort SellerInput {
    Location: "socket://localhost:8100"
    Protocol: sodep
    Interfaces: Seller
}

outputPort BuyerOutput {
    Location: "socket://localhost:8000"
    Protocol: sodep
    Interfaces: Buyer
}

outputPort HelperOutput {
    Location: "socket://localhost:8200"
    Protocol: sodep
    Interfaces: Helper
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
         SendItemData.sid
         RefundBuyerData.sid
}

init {
    println@Console("Online shopping - Seller is running...")()
    global.trackingCode = 0
}

main {
    // Waiting for incoming requests to operation: initPaymentProcess
    initPaymentProcess(userData)(response) {
        // Dynamic binding of the BuyerOutput.
        // BuyerOutput.location = userData.dynamicLocation
        username = userData.username
        sessionId = csets.sid = new
        response.sid = sessionId
        rnd = 0.0
        while(rnd == 0.0) {
            random@Math(_)(rnd)
        }
        productPrice = int(rnd * 100) // Cast to int to lose the decimal part.
        payedByBuyerAndOrHelper = 0.0
        helpRequested = false
        response.price = double(productPrice) // Cast to double to allow double operations.
    };

    // Waiting for incoming requests to operation: willUseHelp
    willUseHelp(willUseHelpData)
    println@Console("\nInvoked operation \"willUseHelp\".")()
    // --- //
    helpRequested = (willUseHelpData.amount != 0.0)

    print@Console("Buyer with sid=" + sessionId + " will ")()
    if(helpRequested) {
        print@Console("not ")()
    }
    println@Console("use help for buying the product.")()

    scope(payment_receival) {
        install(
            FaultAfterPayment => {
                println@Console("There was a problem during the payment process.")()

                if(helpRequested) {
                    comp(half_payment_receival_from_buyer)
                    comp(half_payment_receival_from_helper)
                } else {
                    comp(full_payment_receival_from_buyer)
                }
            }
        )

        if(helpRequested) {
            // Waiting for incoming requests to operations: sendPaymentHelped and sendPaymentHelper in parallel
            {
                sendPaymentHelped(sendPaymentHelpedRequest)
                scope(half_payment_receival_from_buyer) {
                    install(
                        this => {
                            refund.sid = sessionId
                            refund.amount = sendPaymentHelpedRequest.amount
                            sendRefund@BuyerOutput(refund)
                        }
                    )
                    println@Console("\nInvoked operation \"sendPaymentHelped\".")()
                    // --- //
                    println@Console("Buyer with sid=" + sessionId + " have just paid " + sendPaymentHelpedRequest.amount + " for the product.")()
                
                    synchronized(payedByBuyerAndOrHelper) {
                        payedByBuyerAndOrHelper += sendPaymentHelpedRequest.amount
                    }
                }
            } | {
                sendPaymentHelper(sendPaymentHelperRequest)
                scope(half_payment_receival_from_helper) {
                    install(
                        this => {
                            refund.sid = sessionId
                            refund.amount = sendPaymentHelperRequest.amount
                            sendRefund@HelperOutput(refund)
                        }
                    )
                    println@Console("\nInvoked operation \"sendPaymentHelper\".")()
                    // --- //
                    println@Console("Helper with sid=" + sessionId + " have just paid " + sendPaymentHelperRequest.amount + " for the product.")()

                    synchronized(payedByBuyerAndOrHelper) {
                        payedByBuyerAndOrHelper += sendPaymentHelperRequest.amount
                    }
                }
            }
        } else {
            // Waiting for incoming requests to operation: sendPayment
            sendPayment(sendPaymentRequest)
            scope(full_payment_receival_from_buyer) {
                install(
                    this => {
                        refund.sid = sessionId
                        refund.amount = sendPaymentRequest.amount
                        sendRefund@BuyerOutput(refund)
                    }
                )
                println@Console("\nInvoked operation \"sendPayment\".")()
                // --- //
                payedByBuyerAndOrHelper += sendPaymentRequest.amount
            }
        }

        if(payedByBuyerAndOrHelper != double(productPrice)) {
            throw (FaultAfterPayment)
        }

        // Default variable init: it will be overridden only in case of errors.
        sendItemData.sid = sessionId
        sendItemData.errors = false

        closeData.sid = sessionId
        closeData.errors = false
        closeData.message = "The product was shipped and the tracking code was sent to the Buyer."

        // This part could be expanded...
        global.trackingCode++
        index = 0
        if(is_defined(global.shippings.(username))) {
            index = (#global.shippings.(username)) - 1
        }
        global.shippings.(username)[index].tracking = "TRK-" + global.trackingCode

        sendItemData.shippingTrackingCode = global.shippings.(username)[index].tracking;
        
        {sendItem@BuyerOutput(sendItemData) | close@HelperOutput(closeData)}
    }
}