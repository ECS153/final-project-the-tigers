# Seda
Highly secure peer-to-peer payment app. Platform: iOS

## How to debug making Stripe payments on an iOS simulator
1. Run the server on localhost
	- Change to the directory with `server.py`
	- Run  `server.py` in development mode.
	```
	$ export FLASK_APP=server.py
	$ export FLASK_ENV=development
	$ python3 -m flask run --port=4242
	```
2. Make sure `PaymentViewController`  occurs before `CardScan`
	- Note: Since this is being run in an iOS simulator, CardScan is unable to scan cards, so we want to force `PaymentViewController` earlier.
	- Note: Where you do this doesn't matter too much (right now) as long as it happens before Card Scan is able to get called. I just had `PaymentViewController` get called when the app starts. 
	- What I did was add the following lines to `viewDidLoad()` in ` WelcomeViewController.swift`
		```python
		override func viewDidLoad() {
			super.viewDidLoad()
			#-->let storyboard = UIStoryboard(name: "Main", bundle: nil)
			#-->let vc1 = storyboard.instantiateViewController(withIdentifier: 	Constants.paymentStoryboard) as! PaymentViewController
			#-->self.present(vc1, animated: true)
3. Run the iOS simulator.
4. The option to add payment information should immediately appear.
5. Enter a Stripe test card for the payment info.
	- I used the following:
	```
	Card Number: 4242 4242 4242
	Expiration Date: Any future date (e.g. 01/25)
	CVC: Any three number (e.g. 123)
	Zip Code: Any zip code (e.g. 90275)
6. Tap the `Pay` button. You should get a popup with a huge amount of text saying the payment was successful. 
7. After you're finished debugging make sure to remove any code you changed in Step 2.
## Authors
Josh Steubs, Ryland Sepic, DJ Chen, Liusyu Gao