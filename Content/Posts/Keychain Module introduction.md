---
date: 2020-04-11 23:00
readingTime: 15
section: Security
---

# Keychain implementation in iOS

As mentioned in my _[last post](https://caterpillardev.com/posts/SecureDevelopementBasics/)_, there are two ways to store data in your app. One is `UserDefaults` which is unencrypted, and the other is **`Keychain`** which is **encrypted**, and is the one we will focus on.

You may ask yourself, why do we even need the unencrypted one? Well, there is quite a huge variety of data which is not considered confidential and doesn’t require encryption. For example, let's say you are making a game. Storing a user preferred theme, volume settings, or if the user has already used an app before are some of the most used examples for `UserDefaults` storing.


Even though keychain provides encrypted storage, please make sure that you only store the data you **absolutely** need. 

> **The most secure data is the data you don’t collect.**

Also, if you must store a piece of data, your preferred way should be to do it on the client side, and avoid server storage and network traffic, since those are the highest reward targets for possible attackers.


## How keychain works

The keychain is implemented as _SQLite database_, stored on file system. All keychain items are encrypted using two [Advanced Encryption Standard(AES)](https://www.youtube.com/watch?v=O4xNJsjtN6E&t=163s) 256 bit keys and [Galois/Counter mode](https://en.wikipedia.org/wiki/Galois/Counter_Mode) (AES-256-GCM keys).

If you want to find out more about details of keychain encryption implementation, I highly advise you to read the **[security manual by Apple](https://manuals.info.apple.com/MANUALS/1000/MA1902/en_US/apple-platform-security-guide.pdf)**. Details for keychain can be found in **"Keychain data protection and data classes"** section.

## Secrets

A **secret** is anything used in cryptography that is ideally only known to communicants, usually used for converting plain text to [ciphertext](https://en.wikipedia.org/wiki/Ciphertext), identification or user verification. 

Some of the most common secret types are:

- passwords
- cryptographic keys
- cerificates
- identities 


#### Passwords

Password, or sometimes referred to as passcode, is a secret most commonly used to authenticate users. Usually comes in a form of string of characters. A good password includes characters, numbers and special characters. You should enforce users to create strong passwords, but it comes with a trade off. The more complex the password is, the user is more likely to forget it. That's why it's really important to increase UX quality by providing smooth storage of passwords for your users.

#### Cryptographic keys

Keys are usually split into two categories: 

- Symmetric
- Asymmetric

Cryptographic keys are strings that you combine with other data and use an algorithm to enhance security. The most common operations include data encryption and decryption, signing and verification.

Keys differentiate based on operation you need to perform. If you want to perform asymmetric encryption, you need a public and private key pair 
(e.g [RSA](https://tools.ietf.org/html/rfc3447#section-3.1)) and if you want to perform symmetric encryption you may use AES. Both have its pros and cons, which will be discussed in one of my future posts.


#### Cerificates

Even though asymmetric encryption "guarantees" the hard part is transfering the keys through the network between, for example, client app and a server. That is where digital certificates come into play. They are used for secure distribution of public part of the key.The most known format is X.509 which is presented in the image below:

![X.509.png](/images/X509.png)

Source: Apple <sup>[1]</sup>


Why do we need certificates? One of the most obvious reasons is the so-called "Man in the middle (MITM)" attack. Since a public key is published and usually accessible easily, an attacker could use that public key to decrypt the traffic, read it or even change it, encrypt it with its own private key and share its public key and forward it to the server. No one would even know that someone is reading/changing content. For more info on certificates you can check out Apple's
 [documentation](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/certificates).

#### Identities

Identity is a **combination of private key and certificate** combined together to ensure authenticity of public key. You can use the keychain to store the identity.

### Types of storable secrets in keychain

Using keychain, you can store next secret types: 

- password
- keys
- certificates
- identities

All of these use the same API, and I will explain them in next chapter.



## Keychain API

Keychain API allows all four CRUD operions. API has been available since iOS 2.0, so API isn't really _swifty_.

Store:

```swift
SecItemAdd(attributes: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>)
```
Update:
```swift
SecItemUpdate(query: CFDictionary, attributesToUpdate: CFDictionary)
```
Read:
```swift
SecItemCopyMatching(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>)
```
Delete:
```swift
SecItemDelete(query: CFDictionary)
```

API is part of the `Foundation` framework, so you don't need any additional `import` statements.

`CFDictionary` is a dictionary, which as all dictionaries, uses key and value pairs. It creates a static dictionary, so after you set a value for a key, it becomes immutable. Each key-value pair is called an entry, and the keys are unique for each value.

In case you are doing a _`read`_, it is very important to understand what comes back as a result. What you get back is a reference to a memory location, where the outcome of the read function is stored. It is basically a placeholder, since its definition is:

```swift
typealias CFTypeRef = AnyObject
```
This means that you can get back any object which is part of the `Foundation` framework and you have to take care of conversion. 

Return type of each CRUD function is **`OSStatus`**. I am describing OSStatus in a chapter below.


### OSStatus

OSStatus is an error code which describes the outcome of the function, which is part of the `Security` Framework. You get back an **Int**, which you can then compare to system result codes and understand what is the outcome. Example:

```swift
let result = SecItemDelete(query: query) //query constructed before
if result == errSecSuccess {
	// complete with success
} else {
	// complete with error
}
```

0 is OSStatus for success. In case you get something that is not a 0, you can use a built-in function for understanding the error code better:

```swift
SecCopyErrorMessageString(_ status: OSStatus,  _ reserved: UnsafeMutableRawPointer?) -> CFString?
```
Paramters:
- OSStatus is the outcome of your function
- Reserved is parameter for future use, pas NULL here.

This gives you a human readable description of your error code. You can also use [this](https://www.osstatus.com) online tool to convert your result code to an error which you can then look up in Apple documentation for better understanding.



## Additional protection

### Demanding user identification/presence

You can restrict access to keychain items by demanding user authentication. If a user wants to, for example, access a password stored in a keychain you can demand authentication via _Face/TouchID_ or using a _password_. You can pick a prefered way, but in the end, the system picks the best solution and presents it without you having to implement any screens, transitions or whatsoever. All of this is done by system, as well as handling success or failure cases.

This is a piece of code used in my solution, with explanations of each of the options available:
```swift
public enum SecretAccessibility {
    ///The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
    ///If value is one of `ThisDeviceOnly`, item cannot be synced through iCloud
    case accessibleWhenPhoneHasPasswordThisDeviceOnly
    ///The data in the keychain item can be accessed only while the device is unlocked by the user.
    ///If value is one of **ThisDeviceOnly**, item **cannot be synced** through iCloud
    case accessibleWhenUnlockedThisDeviceOnly
    ///The data in the keychain item can be accessed only while the device is unlocked by the user.
    ///Default value
    case accessibleWhenDeviceIsUnlocked
    ///The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    ///If value is one of **ThisDeviceOnly**, item cannot be synced through iCloud
    case accessibleAfterFirstUnlockThisDeviceOnly
    ///The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    case accessibleAfterFirstUnlock
}
```

You can then use one of these values as part of `CFDictionary` that you use to perform any of the CRUD operations.

### Accessibility based on device state

You can also restrict access based on device state. The easiest way to understand device state and possible options is from the code presented below:

```swift
enum DeviceState {
    ///    The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
    case accessibleWhenPasscodeSetThisDeviceOnly: CFString
///    The data in the keychain item can be accessed only while the device is unlocked by the user.
    case accessibleWhenUnlockedThisDeviceOnly: CFString
///    The data in the keychain item can be accessed only while the device is unlocked by the user.
    case accessibleWhenUnlocked: CFString
///    The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    case accessibleAfterFirstUnlockThisDeviceOnly: CFString
///    The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    case accessibleAfterFirstUnlock: CFString
}
```

If you pick a state which contains `thisDeviceOnly`, you are automatically disabling iCloud sync of the secret. iCloud sync is stated in the next chapter.

### iCloud sync

If a user uses your app on multiple devices with the same Apple ID, you can enrich UX by providing secrets to all devices in real time through iCloud. Only secret type which is syncable through iCloud is password, which means you can log in your user without them having to type username and password. You set iCloud sync by providing a `bool` value for a key ( _kSecAttrSynchronizable_ ) which is used for constructing a `CFDictionary` used in CRUD operations. This will be explained in more detail in the next article, where I will cover implementation of above stated operations.

## Conclusion

As you can see, the API is really low level and in C style. That's why it can be hard to understand, especially if you don't have any prior C experience. Even though it’s easier to use an external dependency and use a library or a swift package, it should be clear to you why you shouldn’t do it. In one of my future posts, I will take you through steps I took to design and implement a `generic` keychain wrapper which I use in my projects. In the end, I will open source this solution. If some stuff here is not clear enough, feel free to reach me on  [LinkedIn](https://www.linkedin.com/in/nikolamatijevic) or [Twitter](https://twitter.com/nmatijevic1) or take a look in official Apple documentation. Also, in case you have any questions or feedback, I will be more than glad to hear.



## Resources

-  AES -> [Computerphile](https://www.youtube.com/watch?v=O4xNJsjtN6E&t=163s)
- AES -> [Wiki](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)
- AES -> [Official RFC](https://tools.ietf.org/html/rfc3394)
- [Galois/Counter mode](https://en.wikipedia.org/wiki/Galois/Counter_Mode)
- [Apple security manual](https://manuals.info.apple.com/MANUALS/1000/MA1902/en_US/apple-platform-security-guide.pdf)
- [RSA](https://tools.ietf.org/html/rfc3447#section-3.1)
- [Certificates](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/certificates)

## Sources

[Certificates image <sup>[1]</sup>](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/certificates)

## Used abbreviations

- CF -> CoreFoundation
- Sec -> Security
- RFC -> Request for comments
