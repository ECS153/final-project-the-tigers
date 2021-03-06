# 5/26/2020

Milestone video [link](https://drive.google.com/file/d/1qbPz6FIEkKNNK1eehlJoo37HZgBaqtId/view?usp=sharing)

## Josh

Last week: Working on the UI and integrating Stripe, including setting up the server.
Worked on a PR with DJ [PR](https://github.com/ECS153/final-project-the-tigers/pull/5)

Next week: Working on the user experience and assisting on Stripe.

## Ryland Sepic

Last week: Working on creating a set of encryption functions that everyone can use in 
order to encrypt and decrypt messages being sent to and from Firebase. [PR](https://github.com/ECS153/final-project-the-tigers/pull/6) 
and [Design Doc](https://docs.google.com/document/d/17L7sCGY2r1CfZtjht2tPovifRarhnVrO5iAtdoJZc2A/edit)

Next week: The encryption library is working according to the tests, however, their 
needs to be a safe method for exchanging the public keys.

Stuck On: Efficient and safe method for exchanging public keys.

## DJ

Last week: implemented a chat function for the project and worked with Josh on implementing Stripe.
Has also been working with Liusiyu on integrating Stripe with Firebase. [PR](https://github.com/ECS153/final-project-the-tigers/pull/3)

Next week: Finish integrating Stripe with Firebase and have it working. 

## LIUSIYU

Last week: Working on setting up Stripe with Firebase. Finished the pay function. [Current branch](https://github.com/ECS153/final-project-the-tigers/tree/glsy)

Next week: Continue working on integrating stripe with Firebase

---
---
---

>>>>>>> Stashed changes
# 5/19/2020

Milestone video [link](https://drive.google.com/file/d/1NnZnNlRbVT2dfhaQEsFHAZvx76gaH-ew/view?usp=sharing)

## Josh

Last week: Working on the UI, assisting on Stripe, and merged PR for CardScan [PR](https://github.com/ECS153/final-project-the-tigers/pull/1) .

Next week: Finish the overall UI framework and continue assisting on Stripe


## Ryland Sepic 

Last week: Setup the database for Firebase, user information and transactions. Removed 
the necessity for storing an email. ProfileViewController, where the user will be taken after login. 
[PR](https://github.com/ECS153/final-project-the-tigers/pull/2). 

Next week: working on sending payment information from one user to the next.

Stuck on: push notifications


## DJ 

Last week: Improved register and login function, built a new view for Stripe payment, built a chat function

Next week: Use Firebase function to interact with Stripe, improve the security of the chat function

Struck on: Separate the card number type in part of pre-build UI 

## LIUSIYU 

Last week: Successfully solve the last week problem(connecting viewcontroller with the pay button), finish the client part of Stripe

Next week: try to connect with the server part (firebase), including learning how to use the firebase, getting the token for encryption

Struck on: how to place the files of firebase into our xcode, try to modify the code in order to match our project


---
---
---


# 5/11/2020

Milestone video [link](https://drive.google.com/file/d/1al8-9H5j6tfAxbMt9yCy2n3L_ePNk6WA/view)

## Josh  
Last week: I worked on the proposal with the group, setup our stripe account. I also implemented CardScan.  
Due next meeting: create mockup designs for login/register and payment screen UI. Implement "loading money" from card onto account and then removing traces of card.


## Ryland Sepic 

Last week: as a group we wrote and submitted our proposal, and I also worked on 
the milestone video as well as a design doc for Git. 
[link](https://docs.google.com/document/d/1KC-bvmwCAtns3nLVm-BU0GuggfeXqPYnq2Q69nNsqVo/edit)

Next week: I will be working on the transfer from account to account, making sure 
it is secure, and that the necessary information is in place to follow through with 
the transaction. 

Stuck on: Will we run into any trouble storing money? Can we use Stripe to put money 
onto a prepaid debit card?

## DJ 

Last week: learned the basic rules of Firebase and iOS segue and build a template with register and login function through Firebase
Next week: Improve register and login function as well as learning how to interact Firebase with Stripe.

## LIUSIYU 

I learned the basic concept of Stripe, and tried to apply Stripe into DJ’s template after the registration, which is a screen with a pay button, but I had a trouble in connecting my viewcontroller with the pay button. Hope I could solve it in the next week.
