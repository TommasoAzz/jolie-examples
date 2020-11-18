type SendItemData: void {
    .sid: string
    .shippingTrackingCode?: string
    .errors: bool
    .message?: string
}

interface Buyer {
OneWay:
    sendItem(SendItemData)
}