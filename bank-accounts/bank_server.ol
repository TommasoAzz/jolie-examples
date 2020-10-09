include "bank.iol"
include "console.iol"


inputPort BankInput {
Location: "socket://localhost:8000"
Protocol: sodep
Interfaces: Bank
}

cset {
	sid: LoginResponse.sid LogoutRequest.sid WithdrawalRequest.sid DepositRequest.sid ReportRequest.sid
}

execution{ concurrent }

init {
    println@Console("Bank server is running...")()
    keepRunning = true
}

main {
    login(loginRequest)(loginResponse){
		username = loginRequest.username
        password = loginRequest.password
        balance = 0.0
		loginResponse.sid = csets.sid = new;
        loginResponse.success = true
		loginResponse.message = "You are correctly logged in."
	};

	while(keepRunning) {
        [logout(logoutRequest)(logoutResponse) {
            println@Console("User with username: " + username + " has requested to log out.")()
            keepRunning = false
            logoutResponse.message = "You are now logged out."
        }] {
           println@Console(username + " was logged out.")() 
        }

        [withdrawal(withdrawalRequest)(withdrawalResponse) {
            println@Console("User with username: " + username + " has requested a withdrawal.")()
            if(balance < withdrawalRequest.cashAmount) {
                withdrawalResponse.errors = true
                withdrawalResponse.newBalance = balance
                withdrawalResponse.message = "Your balance is smaller than the amount of cash you requested to withdraw."
            } else {
                balance -= withdrawalRequest.cashAmount
                withdrawalResponse.errors = false
                withdrawalResponse.newBalance = balance
                withdrawalResponse.message = "Here are your " + withdrawalRequest.cashAmount + " euros you requested."
            }
        }] {
           println@Console(username + " has completed the withdrawal operation.")() 
        }

        [deposit(depositRequest)(depositResponse) {
            println@Console("User with username: " + username + " has requested a deposit.")()
            if(depositRequest.cashAmount <= 0.0) {
                depositResponse.errors = true
                depositResponse.newBalance = balance
                depositResponse.message = "You cannot deposit 0 or less euros."
            } else {
                balance += depositRequest.cashAmount
                depositResponse.errors = false
                depositResponse.newBalance = balance
                depositResponse.message = "Money deposited successfully."
            }
        }] {
           println@Console(username + " has completed the deposit operation.")() 
        }

        [accountReport(reportRequest)(reportResponse) {
            println@Console("User with username: " + username + " has requested an account report.")()
            reportResponse.balance = balance
            reportResponse.message = "Your current balance is " + reportResponse.balance + " euros."
        }] {
           println@Console(username + " has completed the account report operation.")() 
        }
	}
}