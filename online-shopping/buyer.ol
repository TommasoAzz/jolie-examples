include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "buyer.iol"
include "seller.iol"
include "helper.iol"

inputPort BuyerInput {
    Location: "socket://localhost:8000"
    Protocol: sodep
    Interfaces: Buyer
}

outputPort SellerOutput {
    Location: "socket://localhost:8100"
    Protocol: sodep
    Interfaces: Seller
}

outputPort HelperOutput {
    Location: "socket://localhost:8200"
    Protocol: sodep
    Interfaces: Helper
}

init {
    println@Console("Online shopping - Buyer is running...")()
}

main {
    showInputDialog@SwingUI("Insert your username:")(userData.username)
    
    initPaymentProcess@SellerOutput(userData)(paymentInfo)

    showYesNoQuestionDialog@SwingUI("The price of the product is " + paymentInfo.price + ". Do you need help paying for it?")(userChoice)

    helpRequest.sid = noticeToSeller.sid = productRequest.sid = paymentInfo.sid
    
    helpIsRequested = userChoice == 0 // 0 means YES, 1 means NO

    helpRequest.needHelp = helpIsRequested
    if(helpIsRequested) {
        helpRequest.amount = paymentInfo.price * 0.5
        noticeToSeller.amount = helpRequest.amount
    }
    askForHelp@HelperOutput(helpRequest)
    willUseHelp@SellerOutput(noticeToSeller)

    if(helpIsRequested) {
        // For simplicity this client allows only the price to be cut in half.
        println@Console("You requested to be helped by an Helper. The Helper will take care of half the amount.")()

        productRequest.amount = paymentInfo.price * 0.5
        sendPaymentHelped@SellerOutput(productRequest)
    } else {
        println@Console("You did not request to be helped by an Helper. You will take care of the whole amount.")()
        
        productRequest.amount = paymentInfo.price
        sendPayment@SellerOutput(productRequest)
    }

    [sendItem(sendItemData)] {
        println@Console("Seller with sid=" + sendItemData.sid + " sent the product.")()

        if(sendItemData.errors) {
            println@Console("There was an error processing the request: " + sendItemData.message)()
        } else {
            println@Console("The product was shipped. The tracking code is: " + sendItemData.shippingTrackingCode)()
        }
    }
}