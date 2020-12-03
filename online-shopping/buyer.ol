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
    // Checking program arguments
    // if(#args > 0) {
    //     matchReq = -> args[0]
    //     matchReq.regex = "(socket\:\/\/)([a-z]|[0-9]|[\-\.])*\:[0-9]{1,5}"
    //     match@StringUtils(matchReq)(groups)
    //     if(groups > 1) {
    //         userData.dynamicLocation = groups.group[0]
    //     } else {
    //         println@Console("The input argument was not a valid location for a service. The service will be halted.")()
    //         request.status = 0
    //         halt@Runtime(request)(_)
    //     }
    // } else {
    //     userData.dynamicLocation = "socket://localhost:8000"
    // }

    // Setting Location of BuyerInput since it is dynamic.
    // BuyerInput.location = userData.dynamicLocation

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

    in(userChoice)
    if(userChoice != "y" && userChoice != "n") {
        print@Console("You typed " + userChoice + ". Correct choice is either \"y\" or \"n\": ")()
        in(userChoice)
    }

    // Initializing all session ids.
    helpRequest.sid = noticeToSeller.sid = productRequest.sid = paymentInfo.sid
    
    helpIsRequested = userChoice == NEED_HELP

    helpRequest.needHelp = helpIsRequested
    noticeToSeller.amount = 0.0 // By default 0.0 means no help is requested
    if(helpIsRequested) {
        // For simplicity this client allows only the price to be cut in half.
        helpRequest.amount = double(paymentInfo.price) * 0.5
        noticeToSeller.amount = helpRequest.amount
    };
    {willUseHelp@SellerOutput(noticeToSeller) | askForHelp@HelperOutput(helpRequest)}

    if(helpIsRequested) {
        println@Console("You requested to be helped by an Helper. The Helper will take care of half the amount.")()

        productRequest.amount = double(paymentInfo.price) * 0.5
        sendPaymentHelped@SellerOutput(productRequest)
    } else {
        println@Console("You did not request to be helped by an Helper. You will take care of the whole amount.")()
        
        productRequest.amount = double(paymentInfo.price)
        sendPayment@SellerOutput(productRequest)
    }

    // Waiting for incoming requests to operation: sendItem
    sendItem(sendItemData)
    println@Console("\nInvoked operation \"sendItem\".")()
    // --- //
    if(sendItemData.errors) {
        println@Console("There was an error processing the request: " + sendItemData.message)()
    } else {
        println@Console("The product was shipped. The tracking code is: " + sendItemData.shippingTrackingCode)()
    }
}