# Updated Slides 

[link](https://docs.google.com/presentation/d/1rQv9g68kdYzwZZeUzQoziAHqYe9eTaeaaZwmLB0veOw/edit#slide=id.g8884b6f2ee_1_8)

## Server

The *Server* directory contains Firebase functions necessary to host and run the 
Stripe API remotely from Firebase.

## Seda

The code pertaining to the iOS app itself. 

### Classes

*FirebaseHelper* is a helper class designed to setup and maintain the user's information
and connection to Firebase. 

*Crypto* is the cryptography functions implemented using CryptoKit. The user creates 
a private key and it is stored within the key chain associated with the app and the device.

### Views and Controllers

**User enters app:**
* *LoginViewController* 
* *RegisterViewController* 

**Chat:**
User picks a target of who they would like to talk to, and then they can chat with 
that person. The chat is encrypted if the people talking have gone through the friending
process. 
* *TargetViewController* 
* *ChatViewController* 

**Profile:**
The main center for where a user will take care of 
their transfers. They can view their balance, load more money onto their account, 
add friends, make a transfer, or view their payment history. 
* *ProfileViewController* 

**Load money:**
If the user wants to add more money to their account they navigate through the 
set of view controllers, choosing how much money they wish to upload, and scanning 
their bank card using CardScan.
* *LoadBalanceViewController*
* *PaymentViewController*
* *ScanCardViewController*

**Friending:**
To exchange public keys user's friend one another. They enter the name of who they 
would like to friend and that person accepts the request.
* *AcceptFriendViewController*
* *DeleteFriendRequestViewController*
* *FriendsViewController*

**Sending money:** 
User chooses a recepient from their list of friends, specifies an amount, along with an optional message.
The payment is then sent encrypted to the receiver.
* *TransactionViewController*
* *TransferViewController*

**History:**
The user can view their transaction history. After the transaction is complete, the transaction is fully encrypted to hide the information that 
could not be encrypted during the standard transfer, username and recipient's name. 
The data is then encrypted and stored. When the user wants to view their history, it is decrypted and 
can be seen.
* *HistoryTableViewController*
* *TransactionDetailsViewController*

