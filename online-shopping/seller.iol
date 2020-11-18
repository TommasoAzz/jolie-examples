type WillUseHelpData: void {
    .sid: string
    .amount?: double
}
type SendPaymentRequest: void {
    .sid: string
    .amount: double
}

type SendPaymentHelperRequest: void {
    .sid: string
    .amount: double
}

type SendPaymentHelpedRequest: void {
    .sid: string
    .amount: double
}

type InitPaymentProcessRequest: void {
    .username: string
}

type InitPaymentProcessResponse: void {
    .sid: string
    .price: double
}

interface Seller {
OneWay:
    willUseHelp(WillUseHelpData),
    sendPayment(SendPaymentRequest),
    sendPaymentHelper(SendPaymentHelperRequest),
    sendPaymentHelped(SendPaymentHelpedRequest)
RequestResponse:
    initPaymentProcess(InitPaymentProcessRequest)(InitPaymentProcessResponse)
}