# Online shopping

## Problem description
A buyer wants to buy some items from a seller.
For each of them, if the price is low he sends the money to the seller and receives the item back.
If the price is too high he can decide to buy the item together with an helper.
Both the buyer and the helper send half of the needed money to the seller.
When the seller receives the needed money he sends back the item to the buyer.

## Formal choreography
C ::= (*initPaymentProcess*: Buyer -> Seller; (*askForHelp*: Buyer -> Helper | *willUseHelp*: Buyer -> Seller); *sendPayment*: Buyer -> Seller + (*sendPaymentHelped*: Buyer -> Seller | *sendPaymentHelper*: Helper -> Seller); *sendItem*: Seller -> Buyer | *close*: Seller -> Helper)*

### Projections
proj(C, Buyer) = (<span style="text-decoration: overline">*initPaymentProcess*</span>@Seller; (<span style="text-decoration: overline">*askForHelp*</span>@Helper | <span style="text-decoration: overline">*willUseHelp*</span>@Seller); <span style="text-decoration: overline">*sendPayment*</span>@Seller + (<span style="text-decoration: overline">*sendPaymentHelped*</span>@Seller | 1); *sendItem*@Seller | 1)*

proj(C, Seller) = (*initPaymentProcess*@Buyer; (1 | *willUseHelp*@Buyer); *sendPayment*@Buyer + (*sendPaymentHelped*@Buyer | *sendPaymentHelper*@Helper); <span style="text-decoration: overline">*sendItem*</span>@Buyer | <span style="text-decoration: overline">*close*</span>@Helper)*

proj(C, Helper) = (1; (*askForHelp*@Buyer | 1); 1 + (1 | <span style="text-decoration: overline">*sendPaymentHelper*</span>@Seller); 1 | *close*@Seller)*

## Operation mappings: formal choreography to Jolie operations
- *askForHelp* will be a Helper operation, OneWay;
- *willUseHelp* will be a Seller operation, OneWay;
- *sendPayment* will be a Seller operation, OneWay;
- *sendPaymentHelped* will be a Seller operation, OneWay;
- *sendPaymentHelper* will be a Seller operation, OneWay;
- *sendItem* will be a Buyer operation, OneWay;
- *close* will be a Helper operation, OneWay.