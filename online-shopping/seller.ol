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
         CloseData.sid
         SendItemData.sid
}

init {
    println@Console("Online shopping - Seller is running...")()
    keepRunning = true
    global.trackingCode = 0
}

main {

    initPaymentProcess(userData)(response) {
        username = userData.username
        response.sid = csets.sid = new
        rnd = 0.0
        while(rnd == 0.0) {
            random@Math(_)(rnd)
        }
        productPrice = rnd * 100
        payedByBuyerAndOrHelper = productPrice
        helpRequested = false
        response.price = productPrice
    };

    while(keepRunning) {
        [willUseHelp(willUseHelpData)] {
            println@Console("Invoked operation \"willUseHelp\".")()
            // --- //
            helpRequested = (willUseHelpData.amount > 0.0)

            print@Console("Buyer with sid=" + willUseHelpData.sid + " will ")()
            if(helpRequested) {
                print@Console("not ")()
            }
            println@Console("use help for buying the product.")()
        }

        [sendPayment(sendPaymentRequest)] {
            println@Console("Invoked operation \"sendPayment\".")()
            // --- //

            // Default variable init: it will be overridden only in case of errors.
            closeData.sid = sendPaymentRequest.sid
            closeData.errors = false
            closeData.message = "The product was shipped and the tracking code was sent to the buyer."
            sendItemData.sid = sendPaymentRequest.sid
            sendItemData.errors = false

            payedByBuyerAndOrHelper -= sendPaymentRequest.amount

            if(payedByBuyerAndOrHelper == 0.0) {
                // Saving it for future uses
                trackingCode++
                index = 0
                if(is_defined(global.shippings.(username))) {
                    codesCardindality = #global.shippings.(username)
                    index = codesCardindality - 1
                }
                global.shippings.(username)[index].tracking = "TRK-" + trackingCode

                sendItemData.shippingTrackingCode = global.shippings.(username)[index].tracking
            } else {
                sendItemData.errors = true
                sendItemData.message = "The product cost is " + productPrice + " but you paid " + sendPaymentRequest.amount + ". You should have asked for a Helper!"
                
                closeData.errors = true
                closeData.message = "The product was not shipped and the tracking code was not sent to the buyer."
            }
            
            sendItem@BuyerOutput(sendItemData)
            close@HelperOutput(closeData)

            keepRunning = false
            
            println@Console("Buyer with sid=" + sendPaymentRequest.sid + " have just paid " + sendPaymentRequest.amount + " for the product.")()
        }

        [sendPaymentHelped(sendPaymentHelpedRequest)] {
            println@Console("Invoked operation \"sendPaymentHelped\".")()
            // --- //
            
            // Default variable init: it will be overridden only in case of errors.
            closeData.sid = sendPaymentHelpedRequest.sid
            closeData.errors = false
            closeData.message = "The product was shipped and the tracking code was sent to the buyer."
            sendItemData.sid = sendPaymentHelpedRequest.sid
            sendItemData.errors = false

            synchronized(payedByBuyerAndOrHelper) {
                payedByBuyerAndOrHelper -= sendPaymentHelpedRequest.amount
            }
            
            attempts = 10
            while(payedByBuyerAndOrHelper > 0.0 && attempts > 0) {
                println@Console("[Attempt " + (11 - attempts) + " of 10] Waiting for the Helper to pay...")(  )
                attempts--
                sleep@Time(1000)()
            }

            if(payedByBuyerAndOrHelper == 0.0) {
                println@Console("The Helper has paid its part.")()

                // Saving it for future uses
                trackingCode++
                index = 0
                if(is_defined(global.shippings.(username))) {
                    codesCardindality = #global.shippings.(username)
                    index = codesCardindality - 1
                }
                global.shippings.(username)[index].tracking = "TRK-" + trackingCode

                sendItemData.shippingTrackingCode = global.shippings.(username)[index].tracking
            } else {
                println@Console("Either the Helper has not paid its part or there was a problem.")()
                sendItemData.errors = true
                sendItemData.message = "The product cost is " + productPrice + " but you paid " + sendPaymentHelpedRequest.amount
                
                closeData.errors = true
                closeData.message = "The product was not shipped and the tracking code was not sent to the buyer."
            }

            sendItem@BuyerOutput(sendItemData)
            close@HelperOutput(closeData)

            keepRunning = false

            println@Console("Buyer with sid=" + sendPaymentHelpedRequest.sid + " have just paid " + sendPaymentHelpedRequest.amount + " for the product.")()
        }

        [sendPaymentHelper(sendPaymentHelperRequest)] {
            println@Console("Invoked operation \"sendPaymentHelper\".")()
            // --- //
            println@Console("Helper with sid=" + sendPaymentHelperRequest.sid + " have just paid " + sendPaymentHelperRequest.amount + " for the product.")()

            synchronized(payedByBuyerAndOrHelper) {
                payedByBuyerAndOrHelper -= sendPaymentHelperRequest.amount
            }
        }
    }
}