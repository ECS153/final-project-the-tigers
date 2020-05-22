const functions = require('firebase-functions');
const admin = require('firebase-admin')

admin.initializeApp();
let db = admin.firestore();

// Set your secret key. Remember to switch to your live secret key in production!
// See your keys here: https://dashboard.stripe.com/account/apikeys
const stripe = require('stripe')(functions.config().stripe.test_payment_service_key);

exports.createStripeCustomer = functions.firestore.document('users/{username}').onCreate(async (snap, context) => {
    const data = snap.data();
    const email = data.username.concat('@seda.com');
    const customer = await stripe.customers.create({email: email})
    db.collection('users').doc(String(data.uid)).set({stripeId: customer.id }, {merge: true});
});

//exports.helloWorld = functions.https.onRequest((request, response) => {
//    console.log('This is the console message')
// response.send("Hello from Firebase!");
//});
  