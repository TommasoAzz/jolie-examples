include "console.iol"
include "string_utils.iol"
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

constants {
    NEED_HELP = 0,
    NOT_NEED_HELP = 1
}

init {
    println@Console("Online shopping - Buyer is running...")()

    // Set up for input.
    registerForInput@Console()()
}

main {

    // The following three operations are "dummy".
    // The user is asked to insert a username (which is actually useful for collecting the tracking codes linked to the usernmame),
    // but the price of the product is given by the Seller.
    // No choice what so ever is made for the product.
    print@Console("Insert your username: ")()
    in(userData.username)
    
    // Initializing the session and requesting the price of the product.
    initPaymentProcess@SellerOutput(userData)(paymentInfo)

    // The user is asked if it needs help buying the product or not.
    print@Console("The price of the product is " + paymentInfo.price + ". Do you need help paying for it [y/n]? ")()

    in(strUserChoice)
    if(strUserChoice != "y" && strUserChoice != "n") {
        print@Console("You typed " + strUserChoice + ". Correct choice is either \"y\" or \"n\": ")()
        in(strUserChoice)
    }
    if(strUserChoice == "y") {
        userChoice = NEED_HELP
    } else {
        userChoice = NOT_NEED_HELP
    }

    // The user is asked how much money she/he will pay.
    // Note that:
    // - typing the same amount as paymentInfo.price will lead to a successful payment;
    // - typing a smaller value with (userChoice == NEED_HELP) that evaluates to true will eventually lead to a successful payment;
    // - typing a smaller value with (userChoice == NEED_HELP) that evaluates to false will lead to a failed payment;
    // - typing a higher value will lead to a failed payment.
    print@Console("Type in the amount of money you will pay: ")()
    in(strUserMoney)
    productRequest.amount = double(strUserMoney)

    // Initializing all session ids.
    helpRequest.sid = noticeToSeller.sid = productRequest.sid = paymentInfo.sid
    
    helpIsRequested = (userChoice == NEED_HELP)

    helpRequest.needHelp = helpIsRequested
    noticeToSeller.amount = 0.0 // By default 0.0 means no help is requested
    if(helpIsRequested) {
        println@Console("You requested to be helped by an Helper. The Helper will take care of the amount you cannot pay.")()
        helpRequest.amount = double(paymentInfo.price) - productRequest.amount
        noticeToSeller.amount = helpRequest.amount
    } else {
        println@Console("You did not request to be helped by an Helper. You will take care of the whole amount.")()
    };

    {willUseHelp@SellerOutput(noticeToSeller) | askForHelp@HelperOutput(helpRequest)}

    if(helpIsRequested) {
        sendPaymentHelped@SellerOutput(productRequest)
    } else {
        sendPayment@SellerOutput(productRequest)
    }

    // Waiting for incoming requests to operation: sendItem
    [sendItem(sendItemData)] {
        println@Console("\nInvoked operation \"sendItem\".")()
        // --- //
        if(sendItemData.errors) {
            println@Console("There was an error processing the request: " + sendItemData.message)()
        } else {
            println@Console("The product was shipped. The tracking code is: " + sendItemData.shippingTrackingCode)()
        }
    }

    [sendRefund(refundData)] {
        println@Console("\nInvoked operation \"sendRefund\".")()
        // --- //
        println@Console("The payment could not be processed. Refund amount: " + refundData.amount)()
    }
}