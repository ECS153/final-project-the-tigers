//  Created by Ryland Sepic on 5/24/20.
//
//  This file implements CryptoKit in an easy to use fashion
//  It can be called as needed to encrypt and decrypt data

import CryptoKit
import Foundation

// The Crypto object should be created and used to maintain keys and call functions

// NOTE: ~~Currently~~ only one private key is created

/* Steps in order to encrypt your data:
    1. Generate a private key and store it in the enclave of the device
 
 */
class Crypto {
    // This is information on the keys being used
    // It is set in the code and is needed to create the key and
    // to decipher the public key when it is read as a string from the database
    // We want to use an EC type key because it is 256 bits so it can be stored in the enclave
    let keyType = kSecAttrKeyTypeEC    // Choose cryptography key to use (ex: RSA, EC, etc.)
    let keySize = 256  // Size of the key in bits
    let keyTag_raw: Data? = "SedaKey".data(using: .utf8)   // This is the name of the key to retrieve it from the key chain.
    let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA512   // The algorithm used to protect the message
    
    let keyTag: Data
    
    // Keys
    var priv_key: SecKey? = nil
    var pub_key: SecKey? = nil
    
    init() {
        guard let tag = self.keyTag_raw else {
            print("SOMETHING IS VERY WRONG: Can't unwrap a standard string in Crypto initializer")
            // The keyTag needs to be initialized in the event that this cannot be unwrapped
            // Something would have to be very wrong for us to end up here
            let bytesPointer = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
            self.keyTag = Data(bytes: bytesPointer, count: 1)
            return
        }

        self.keyTag = tag
        
        // Load the private key, if it doesn't exist, create a new one
        loadPrivKey()
        if priv_key == nil {
            createPrivKey() // Create the private key
        }
    }
    
    
    // Creates a private key and stores it in the enclave
    func createPrivKey() {
        let attributes: [String: Any] = [
            kSecAttrKeyType         as String:   keyType,
            kSecAttrKeySizeInBits   as String:   keySize,
            kSecAttrTokenID         as String:   kSecAttrTokenIDSecureEnclave, // Store the key in the enclave
            kSecPrivateKeyAttrs     as String: [
                kSecAttrIsPermanent     as String: true,   // Store the key in the keychain, so we will be able to get the key when the user logs back into the application
                kSecAttrApplicationTag  as String : keyTag
                
            ]
        ]
        
        var err: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &err) else {
            print("Error in creating the private key" + (err!.takeRetainedValue() as! String))
            return
        }
        
        priv_key = privateKey
    }
    
    // Creates a public key
    func createPublicKey() -> SecKey? {
        guard let key = priv_key else {
            print("The user does not have a private key")
            return nil
        }
        
        guard let publicKey = SecKeyCopyPublicKey(key) else {
            print("Unable to generate a public key")
            return nil
        }
        
        pub_key = publicKey
        return publicKey
    }
    
    /*
     1. Check to see if private key exists
     2. If private key does not exist create one
     */
    func loadPrivKey() {
        // Make a query to retrieve the key from the keychain
        let query: [String: Any] = [
            kSecClass               as String: kSecClassKey,
            kSecAttrApplicationTag  as String: keyTag,
            kSecAttrKeyType         as String: keyType,
            kSecReturnRef           as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Crypto.loadPrivKey(): Error in retrieving the private key")
            return
        }
        
        // For unwrap here is necessary.
        // The item is retrieved as a CFTypeRef, however, it is known that it is a SecKey as it was
        // set up in the CFDictionary. Also, the status error should return an error if there is some
        // issue in obtaining the SecKey
        // This force unwrap should never return an error
        priv_key = (item as! SecKey)
    }
    
    /*
     Paramaters
        publicKey: the public key you want to use to secure the message
        clearText: the text you want secured
     */
    func encrypt(publicKey: SecKey, clearText: String) -> Data? {
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            print("VERY BAD: The ecyrption algorithm is not supported")
            return nil
        }
        
        let clearTextData_wrapped: Data? = clearText.data(using: .utf8) // Convert the clearText to Data?
        guard let clearTextData: Data = clearTextData_wrapped else {
            print("Crypto.encrypt() Data? could not be unwrapped")
            return nil
        }
        
        var err: Unmanaged<CFError>?
        return SecKeyCreateEncryptedData(publicKey,
                                         algorithm,
                                         clearTextData as CFData,
                                         &err) as Data?

    }
}
