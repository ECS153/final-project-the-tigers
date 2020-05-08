**Proposal for the project: Seda**

Group member: Joshua Steubs, Dongjie Chen, Liusiyu Gao, Ryland Sepic

Digital financial transactions involve sensitive personal and private information being transferred. If someone’s banking information is stolen, they can lose wealth and private information. With the rise of technology digital wallets and peer-to-peer transactions have become a societal norm. However, these devices, in order to make user’s transactions more convenient, have sacrificed security. Applications such as Venmo store a lot of user information, including their bank card. In the event that someone’s account is breached, it is not only their money in their digital wallet that is potentially lost but their banking information as well. 

There is more than transactional information included with the wiring of money. Metadata associated with the transaction can be used to infer who the user is communicating with, their location, or their recent activity. Current digital wallets, such as Venmo, do not secure this data, but in fact, shares it much like a social media application.

Our plan is to make the digital financial transaction more similar to cash, by keeping the user anonymous and storing the least amount of user information as possible. In order to protect user-information, we do not want to store the card information but allow the user to upload money to their account, and refill by reverifying their card. This method will also allow for more protection against fraudulent credit cards. We also want to secure the metadata associated with transactions by providing protected communication and not sharing user’s information in any manner. 

We plan to simulate payments using the Stripe iOS SDK. The basic account information will be stored on Google’s Firebase and the CardScan library will be used to scan and verify user’s bank cards. All transactions will be protected using end-to-end encryption and a dead drop technique to communicate between users, similar to Vuvuzela, will be used to protect the user’s metadata. 
