type AskForHelpData: void {
    .sid: string
    .needHelp: bool
    .amount?: double
}

type RefundHelperData: void {
    .sid: string
    .amount: double
}

type CloseData: void {
    .sid: string
    .message: string
    .errors: bool
}

interface Helper {
OneWay:
    askForHelp(AskForHelpData),
    sendRefund(RefundHelperData),
    close(CloseData)
}