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
    // The following instrunctions are just dummy instructions.
    // The user is asked to insert a username (which is actually useful for collecting the tracking codes linked to the usernmame),
    // but the price of the product is given by the Seller.
    // No choice what so ever is made for the product.
    // Moreover, this showInputDialog operation could be exchanged with something else (CLI input for example).
    showInputDialog@SwingUI("Insert your username:")(userData.username)
    
    // Initializing the session and requesting the price of the product.
    initPaymentProcess@SellerOutput(userData)(paymentInfo)

    // The user is asked if it needs help buying the product or not.
    // Again, this is just a dummy question to try the system and moreover the showYesNoQuestionDialog operation could be also changed to a CLI input.
    showYesNoQuestionDialog@SwingUI("The price of the product is " + paymentInfo.price + ". Do you need help paying for it?")(userChoice)

    // Initializing all session ids.
    helpRequest.sid = noticeToSeller.sid = productRequest.sid = paymentInfo.sid
    
    helpIsRequested = userChoice == 0 // 0 means YES, 1 means NO

    helpRequest.needHelp = helpIsRequested
    noticeToSeller.amount = 0.0 // By default 0.0 means no help is requested
    if(helpIsRequested) {
        // For simplicity this client allows only the price to be cut in half.
        helpRequest.amount = paymentInfo.price * 0.5
        noticeToSeller.amount = helpRequest.amount
    };
    {willUseHelp@SellerOutput(noticeToSeller) | askForHelp@HelperOutput(helpRequest)}

    if(helpIsRequested) {
        println@Console("You requested to be helped by an Helper. The Helper will take care of half the amount.")()

        productRequest.amount = paymentInfo.price * 0.5
        sendPaymentHelped@SellerOutput(productRequest)
    } else {
        println@Console("You did not request to be helped by an Helper. You will take care of the whole amount.")()
        
        productRequest.amount = paymentInfo.price
        sendPayment@SellerOutput(productRequest)
    }

    // Waiting for incoming requests to operation: sendItem
    sendItem(sendItemData)
    println@Console("Invoked operation \"willUseHelp\".")()
    // --- //
    if(sendItemData.errors) {
        println@Console("There was an error processing the request: " + sendItemData.message)()
    } else {
        println@Console("The product was shipped. The tracking code is: " + sendItemData.shippingTrackingCode)()
    }
}