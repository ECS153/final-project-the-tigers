#! /usr/bin/env python3.7.3

# To run:
# export FLASK_APP=server.py
# (optional) export FLASK_ENV=development
# python3 -m flask run --port=4242

from flask import Flask, render_template, jsonify, request
import json
import os
import stripe
# This is your real test secret API key.
stripe.api_key = "sk_test_58mUMltmkovYLa8W1CvO3OQh00yCZpQdhZ"


app = Flask(__name__, static_folder=".",
            static_url_path="", template_folder=".")


def calculate_order_amount(items):
    # Replace this constant with a calculation of the order's amount
    # Calculate the order total on the server to prevent
    # people from directly manipulating the amount on the client
    return 1400


@app.route('/')
def server_is_running():
    return "Server is running."


@app.route('/create-payment-intent', methods=['POST'])
def create_payment():
    try:
        data = json.loads(request.data)
        print(data)
        intent = stripe.PaymentIntent.create(
            amount=calculate_order_amount(data['items']),
            currency='usd'
        )
        print("sending client secret")
        return jsonify({
            'clientSecret': intent['client_secret']
        })
    except Exception as e:
        return jsonify(error=str(e)), 403


if __name__ == '__main__':
    app.run()
