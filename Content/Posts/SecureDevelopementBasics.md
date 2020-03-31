---
date: 2020-03-31 23:00
readingTime: 10
section: Security
---

# Mobile application secure development basics

When it comes to mobile app development, first thing developers are dependent on is the **platform**. In this article, I will try to cover basic security principles for mobile app development in general with concrete examples in iOS. I highly recommend reading the [security manual](https://manuals.info.apple.com/MANUALS/1000/MA1902/en_US/apple-platform-security-guide.pdf) by Apple which covers how the iOS platform works and protects user data.


## Application Sandbox 

First thing you need to get a good grasp of are platform-specific basics and what your platform has to offer. Apple’s App Sandbox is powered by UNIX’s user permissions.

> **<sup>[2]</sup>** For security reasons, iOS places each app (including its preferences and data) in a sandbox at install time. A sandbox is a set of fine-grained controls that limit the app’s access to files, preferences, network resources, hardware, and so on. As part of the sandboxing process, the system installs each app in its own sandbox directory, which acts as the home for the app and its data. 

![Sandbox](/images/Sandbox.png)
Source<sup>[3]</sup> 


This means that your app **cannot access** data from other apps, as well as the other way around. If your app wants to use some system provided features such as getting user location or using bluetooth, user has to give consent. For more information, please check Apple's [security manual](https://manuals.info.apple.com/MANUALS/1000/MA1902/en_US/apple-platform-security-guide.pdf).


## Collecting data

Every mobile app gathers user relevant information. Personal information such as date of birth, usernames and passwords are usually stored on the client side to allow better personalisation content personalisation and user experience. Collecting data brings a lot of responsibility which leads us to the first point :

> ### **The most secure data is the data you don’t collect.**

The point you can get from this is:

- Don't collect data that is not _really necessary_.
- If you have to collect data, be very cautios how you store it.

If you need to store the data, consider your options. Store only data you need, always store encrypted if possible.

### **Storing data**

Two storages for small chunks of data exist in the iOS world :

- UserDefaults
- Keychain

The most important difference between these two is that **Keychain is encrypted** and **UserDefaults is not**. According to that, you should be really careful where you store your secrets <sup>[1]</sup> . 

Accessing UserDefaults is rather simple. Just use the provided singleton:

```swift
	UserDefaults.standard.set("Caterpillar", forKey: "dev")
```

When it comes to Keychain that is where it starts getting problematic. API that is available from Apple has been around since iOS 2.0 and the API is not really _swifty_. That is why developers mostly rely on using third party libraries which allow storage in a similar form to UserDefaults example above. One of the most commonly used libraries is [KeychainAccess](https://cocoapods.org/pods/KeychainAccess). 

I will write about implementing your own personal wrapper in one of the next posts, and I am planning to open-source the solutions I am currently working on.
Another limitation when it comes to these Keychain libraries is they are only able to store **strings**. 

Other cryptographic secrets like _keys, certificates and identites_ are not storable, which can be a really huge problem if you are using some of more advanced security practices.

## Secure transport over the internet

After you have stored your data securely, you will probably need to transfer it over the network. Most communications use HTTP protocol, which is _not encrypted_ by default.

Since iOS 9.0, the _App Transport Security (ATS)_ blocks insecure communication by default and requires all communication to be performed using **HTTPS secured with TLS**. 	

Most security breaches happen through the network. That's why this is the most security sensitive part of your app. If you had to have a communication with server which doesn't support _https_, you have probably done something like this:

![DisableHTTPS](/images/DisableHTTPS.png)


You should never do this. The right approach to this is increasing level of security on your server and using SSL/TLS communication to ensure at least _basic security_. This approach increases probability of many attacks and makes hackers life way easier to perform attacks like [Man in the middle(MITM) attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack).

## Hardcoded secret values

Even if you are using HTTPS, there are still ways to do things wrong. When communicating to a server, you are using some kind of authentication token. If those tokens are static, the easiest approach is to hard code them somewhere in the app :

```swift
enum Secrets {
    static let apiKey = "someRandomApiKey"
}
```
This is a very bad and dangerous practice. For a couple of reasons:

- You are using some version control system and storing your code somewhere. These secrets are easily accessible from here. This is very well described [here](https://www.ndss-symposium.org/ndss-paper/how-bad-can-it-git-characterizing-secret-leakage-in-public-github-repositories/).
- There are ways to get .ipa file of your app and read source code from there. If someone is able to do this, they have your authentication token and could possibly login and pretend to be you. How to defend against this is very well described in this [article](https://nshipster.com/secrets/) by NSHipster.

## Third party libraries

You should really aim to **avoid** using any third party libraries. They are extreme depenencies to your project and you depend on something you have no control over. If you have to use a third party library due to time-constraints or for some other reason, first thing you should do is to evaluate your options. 

Before even starting the evaluation, test your choice by list of known vulnerabilities. These are reliable sources:

1. [Common Vulnerabilities and Exposures](https://cve.mitre.org/cve/search_cve_list.html)
2. [Natonal vulnerability database](https://nvd.nist.gov/vuln)

If there are known issues with current version number, you must not include this into your project or you are putting all your user's data at risk. Other factors to consider:

- Is there industry standard implementation (e.g. [Alamofire](https://cocoapods.org/pods/Alamofire), [Reactive Cocoa](https://cocoapods.org/pods/ReactiveCocoa)...)
- Community behind the library (number of contributors)
- Engagement (release frequency, open issues and pull requests)





## Resources
[1] - Secret is every piece of information considered confidential/restricted. [Data classification example.](https://www.cmu.edu/iso/governance/guidelines/data-classification.html)

[2,3] - [Sandbox](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AboutAppSandbox/AboutAppSandbox.html)
