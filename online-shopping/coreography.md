# Online shopping

## Problem description
A buyer wants to buy some items from a seller.
For each of them, if the price is low he sends the money to the seller and receives the item back.
If the price is too high he can decide to buy the item together with an helper.
Both the buyer and the helper send half of the needed money to the seller.
When the seller receives the needed money he sends back the item to the buyer.

## Formal choreography
C ::= ((*askForHelp*: buyer -> helper | *willUseHelp*: buyer -> seller); *sendPayment*: buyer -> seller + (*sendPaymentHelped*: buyer -> seller | *sendPaymentHelper*: helper -> seller); *sendItem*: seller -> buyer | *close*: seller -> helper)*

### Projections
proj(C, buyer) = ((<span style="text-decoration: overline">*askForHelp*</span>@helper | <span style="text-decoration: overline">*willUseHelp*</span>@seller); <span style="text-decoration: overline">*sendPayment*</span>@seller + (<span style="text-decoration: overline">*sendPaymentHelped*</span>@seller | 1); *sendItem*@seller | 1)*

proj(C, seller) = ((1 | *willUseHelp*@buyer); *sendPayment*@buyer + (*sendPaymentHelped*@buyer | *sendPaymentHelper*@helper); <span style="text-decoration: overline">*sendItem*</span>@buyer | <span style="text-decoration: overline">*close*</span>@helper)*

proj(C, helper) = ((*askForHelp*@buyer | 1); 1 + (1 | <span style="text-decoration: overline">*sendPaymentHelper*</span>@seller); 1 | *close*@seller)*

## Operation mappings: formal choreography to Jolie operations
- *askForHelp* will be a Helper operation, OneWay;
- *willUseHelp* will be a Seller operation, OneWay;
- *sendPayment* will be a Seller operation, OneWay;
- *sendPaymentHelped* will be a Seller operation, OneWay;
- *sendPaymentHelper* will be a Seller operation, OneWay;
- *sendItem* will be a Buyer operation, OneWay;
- *close* will be a Helper operation, OneWay.