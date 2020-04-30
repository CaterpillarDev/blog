---
date: 2020-04-30 23:00
readingTime: 10
section: Security
---

# Secure Password Storage in iOS

Login and sign up are now integral parts of every app. It's required to authenticate your user, adjust the content presented, and a lot more. Login is by itself a huge killer for UX, that's why it's one of the most important parts of your app. If a user has to type `username` and **`password`** every time they use your app, you can expect low level of long term adoption.

That's why you have to do all you can to `decrease the fraction` here. One of the most common ways is to store your user's credentials and log them in automatically when your app gets launched. Since these pieces of information are highly sensitive, it's very important to store them encrypted. In case you want to find out more about storage in general, you can check [one of my previous articles](https://caterpillardev.com/posts/SecureDevelopementBasics/).

## Basics and comparison to UserDefaults

When it comes to iOS and encrypted storage, your best option is `Keychain`. But, here comes the hard part.

Lets take a look at how you get used to doing storage with _UserDefaults_ :

```swift
UserDefaults.standard.set(25, forKey: "UserAgeKey")
```

This is rather simple. But if you take a look at `Keychain` API, you cannot do it as simple as with UserDefaults. That's why most of the developers, especially under time pressure, opt for using a Cocoapod (e.g [KeychainSwift](https://cocoapods.org/pods/KeychainSwift)).
I highly recommend you not to go down this path, since this is **`the most sensitive`** information you can store.

That's why I explained the basics of Keychain API in a simple way in my previous [article](https://caterpillardev.com/posts/Keychain%20Module%20introduction/).

##  Password definition

Today, we are taking off where we left off in the above-stated article. We will build storage for passwords.

First, let's define a basic representation of the password and its attributes:

```swift
public struct Password {
    let value: String
    let attributes: PasswordAttributes
}
```

Always default to `structs instead of classes` to avoid tons of bugs which happen due to mutation in a multithreaded environment. You can find more detail about this in this awesome [article](https://www.avanderlee.com/swift/struct-class-differences/).  

### **`Password attributes`**

Now we can define set of attributes that will determine our password. These attributes will later be used for `searching` and `retrieving`, as well as `deleting` passwords.

```swift
/// Attributes used for password CRUD operations
public struct PasswordAttributes: SecretAttributesProtocol {
    ///Value is indicating the password's label.
    let label: String
    ///Represents the service associated with password. Available only for generic password.
    let serviceTag: String?
    /// Password type. Either generic or internet.
    let type: PasswordType
    /// If set to true, user will be asked to authenticate using Face/Touch ID.
    /// Mechanism picked and presented by system automatically.
    let demandsUserAutentication: Bool
    //If set to true, password is synced through iCloud. Available only for generic password
    var isICloudSyncable: Bool = false
    ///The server's domain name or IP address. Available only for internet password.
    let server: String?

        
    public init(label: String, serviceTag: String?, type: PasswordType, demandsUserAutentication: Bool, server: String?) {
        self.label = label
        self.serviceTag = serviceTag
        self.type = type
        self.demandsUserAutentication = demandsUserAutentication
        self.server = server
}
```

This list is extensive, and can be shortened quite a bit. In case you want to find out more about these attributes and other keychain storing attributes, you can checkout official Apple documentation [here](https://developer.apple.com/documentation/security/keychain_services/keychain_items/item_attribute_keys_and_values#1679100) under "Password attribute keys".

Now we need to use these provided attributes to assemble `storeAttributes`:

```swift
extension Password {
    var storeAttributes: [String : Any] {
        var attrs: [String : Any] = [
            kSecClass as String: self.type == .generic ? kSecClassGenericPassword : kSecClassInternetPassword,
            kSecAttrLabel as String: self.label,
            kSecAttrSynchronizable as String: self.isICloudSyncable as CFBoolean
        ]
        if self.type == .generic, let tag = self.serviceTag {
            attrs[kSecAttrService as String] = tag
        }
        if self.type == .internet, let server = self.server {
            attrs[kSecAttrServer as String] = server
        }
    }
    attrs[kSecValueData as String] = Data(self.value.utf8)
    return attrs
}

```

Here we can see conversion between provided attributes in a more user-friendly form, as defined in `PasswordAttributes` to API specific `storeAttributes`. When designing an API like this one, you should always define the outside-facing things as simple as possible and deal with complexity inside. That's why we are hiding everything related to `kSec`.

Now we can create a simple struct which will do storing password to `Keychain`, as well as check if it was successful or not :

```swift
struct StorageService {
    func add(attributes: [String: Any], result: UnsafeMutablePointer<CFTypeRef?>?) throws {
        let status = SecItemAdd(attributes as CFDictionary, result)
        guard status == errSecSuccess else {
            //throw error here
        }
    }
}
```

Now we can just use this struct and store our password in a simple fashion.

## Conclusion

Some of you, who are more experienced, might notice that there are no protocols wrapping our implementations and it would be hard to avoid dependencies between components and do Unit tests. We will take care of this in one of the next articles, where I will dive deeper into these specific topics and extend our so far simple Keychain wrapper. If you find anything unclear, feel free to reach me on [LinkedIn](https://www.linkedin.com/in/nikolamatijevic) or [Twitter](https://twitter.com/nmatijevic1) or take a look in official Apple documentation. Also, in case you have any questions or feedback, I will be more than glad to hear.



## Resources

- [Security basics article](https://caterpillardev.com/posts/SecureDevelopementBasics/)  (different storage types explained) 
- [Keychain basics article](https://caterpillardev.com/posts/Keychain%20Module%20introduction/)
- [KeychainSwift CocoaPod](https://cocoapods.org/pods/KeychainSwift)
- [Classes and structs in depth](https://www.avanderlee.com/swift/struct-class-differences/)
- [Keychain item attributes](https://developer.apple.com/documentation/security/keychain_services/keychain_items/item_attribute_keys_and_values#1679100)