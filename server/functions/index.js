const functions = require('firebase-functions');
const admin = require('firebase-admin')
const express = require("express");
const cors = require('cors');
const app = express();
const { resolve } = require("path");
admin.initializeApp();
let db = admin.firestore();

// Set your secret key. Remember to switch to your live secret key in production!
// See your keys here: https://dashboard.stripe.com/account/apikeys
const stripe = require('stripe')("sk_test_rOOmAgYSAm9kKwzuJdIgeV2D00IjSJPiRX");

exports.createStripeCustomer = functions.firestore.document('users/{username}').onCreate(async (snap, context) => {
    const data = snap.data();
    const email = data.username.concat('@seda.com');
    const customer = await stripe.customers.create({email: email})
    const paymentIntent = await stripe.paymentIntents.create({
        amount: 1400,
        currency: "usd"
    });
    return db.collection('users').doc(String(data.uid)).set({stripeId: customer.id }, {merge: true});
});

//exports.helloWorld = functions.https.onRequest((request, response) => {
//    console.log('This is the console message')
// response.send("Hello from Firebase!");
//});

exports.createPaymentIntent = functions.https.onRequest( async (req, res) => {
    //const { items } = req.body;
    // Create a PaymentIntent with the order amount and currency
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 19200,
      currency: "usd"
    });
    res.send({
      clientSecret: paymentIntent.client_secret
    });
});
/*
app.use(cors({ origin: true }));
app.use(express.static("."));
app.use(express.json());
const calculateOrderAmount = items => {
  // Replace this constant with a calculation of the order's amount
  // Calculate the order total on the server to prevent
  // people from directly manipulating the amount on the client
  return 1900;
};
app.post("/create-payment-intent", async (req, res) => {
  const { items } = req.body;
  // Create a PaymentIntent with the order amount and currency
  const paymentIntent = await stripe.paymentIntents.create({
    amount: 1900,
    currency: "usd",
    description: 'Firebase123 Example'
  });
  res.send({
    clientSecret: paymentIntent.client_secret
  });
});

exports.widgets = functions.https.onRequest(app);
*/