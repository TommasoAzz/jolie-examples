type SendItemData: void {
    .sid: string
    .shippingTrackingCode?: string
    .errors: bool
    .message?: string
}

type RefundBuyerData: void {
    .sid: string
    .amount: double
}

interface Buyer {
OneWay:
    sendItem(SendItemData),
    sendRefund(RefundBuyerData)
}