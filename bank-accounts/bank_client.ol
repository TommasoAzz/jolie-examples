include "console.iol"
include "ui/ui.iol"
include "ui/swing_ui.iol"
include "bank.iol"

outputPort BankServer {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: Bank
}

main {
    // LOGIN
	showInputDialog@SwingUI("Insert your username:")(loginRequest.username);
    showInputDialog@SwingUI("Insert the password for " + loginRequest.username + ":")(loginRequest.password);
	login@BankServer(loginRequest)(loginResponse);

    if(loginResponse.success) {
	    keepRunning = true;
        println@Console(loginResponse.message)()
	    logoutRequest.sid = withdrawalRequest.sid = depositRequest.sid = reportRequest.sid = loginResponse.sid

        while(keepRunning) {
            showInputDialog@SwingUI("Type w for withdrawal, d for deposit, r for account report and l for logout.")(actionRequested)

            if(actionRequested == "w") {
                showInputDialog@SwingUI("Type the amount you want to withdraw:")(cash)
                withdrawalRequest.cashAmount = double(cash)

                withdrawal@BankServer(withdrawalRequest)(withdrawalResponse)
                if(withdrawalResponse.errors) {
                    println@Console(withdrawalResponse.message)()
                } else {
                    println@Console("You withdrew " + withdrawalRequest.cashAmount + "and your new balance is: " + withdrawalResponse.newBalance)()
                }
            }

            if(actionRequested == "d") {
                showInputDialog@SwingUI("Type the amount you want to deposit:")(cash)
                depositRequest.cashAmount = double(cash)

                deposit@BankServer(depositRequest)(depositResponse)
                if(depositResponse.errors) {
                    println@Console(depositResponse.message)()
                } else {
                    println@Console("You deposited " + depositRequest.cashAmount + "and your new balance is: " + depositResponse.newBalance)()
                }
            }
            
            if(actionRequested == "r") {
                accountReport@BankServer(reportRequest)(reportResponse)
                if(reportResponse.errors) {
                    println@Console(reportResponse.message)()
                } else {
                    println@Console("Your balance is: " + reportResponse.balance)()
                }
            }
            
            if(actionRequested == "l") {
                logout@BankServer(logoutRequest)(logoutResponse)
                println@Console(logoutResponse.message)()
                keepRunning = false
            }
        }
    }
}