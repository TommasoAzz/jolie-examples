type LoginRequest: void {
    .username: string
    .password: string
}
type LoginResponse: void {
    .sid: string
    .success: bool
    .message?: string
}

type LogoutRequest: void {
    .sid: string
}
type LogoutResponse: void {
    .message?: string
}

type WithdrawalRequest: void {
    .sid: string
    .cashAmount: double
}
type WithdrawalResponse: void {
    .errors: bool
    .newBalance: double
    .message?: string
}

type DepositRequest: void {
    .sid: string
    .cashAmount: double
}
type DepositResponse: void {
    .errors: bool
    .newBalance: double
    .message?: string
}

type ReportRequest: void {
    .sid: string
}
type ReportResponse: void {
    .balance: double
    .message?: string
}

interface Bank {
RequestResponse:
    login(LoginRequest)(LoginResponse),
    logout(LogoutRequest)(LogoutResponse),
    withdrawal(WithdrawalRequest)(WithdrawalResponse),
    deposit(DepositRequest)(DepositResponse),
    accountReport(ReportRequest)(ReportResponse)
}