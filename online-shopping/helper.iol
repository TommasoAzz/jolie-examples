type AskForHelpData: void {
    .sid: string
    .needHelp: bool
    .amount?: double
}

type CloseData: void {
    .sid: string
    .message: string
    .errors: bool
}

interface Helper {
OneWay:
    askForHelp(AskForHelpData),
    close(CloseData)
}