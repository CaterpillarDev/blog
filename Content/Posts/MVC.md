---
date: 2020-03-15 23:00
readingTime: 10
---

# MVC - model view controller 



Model-view-controller, more known under abbreviation **MVC**, is a [_design pattern_](https://en.wikipedia.org/wiki/Software_design_pattern), used for handling user interactions with your software. MVC separates entire system into three separated components interacting with each other: 

![MVC](/images/MVC.png)

## Basics


After user generates an action, like pressing a button, **controller** is the component that is in charge of handling these interactions. What controller does is manipulate[1] the **model**.  After that, model _notifies_ the **view**, which contains rendering and formatting logic required to present changes to the user.
There is a significant differnce in communication between Controller-Model and Model-View parts of MVC. 

Controller directly references the model, being dependent on it. Model is central part of the entire desing pattern, holding all the business logic of the software system itself. _Business logic_ presents real-world business rules you are trying to replicate in form of a software. That makes model the most important part of the system, absolutely _independent_ of all other components.

If you take a closer look at the graph itself, you notice that there is a discontinous line pointing from model to view. This doesn't mean that model actually references the view itself. The way model _updates_[2] the view is a blind communication, meaning that model doesn't have an idea about the view. One example of this type of communication is notification pattern which is presented in code samples below. Official apple documentation can be found [here](https://developer.apple.com/documentation/foundation/notificationcenter).

## Code Samples

In this part, I will present the above stated pattern through a very basic implementation letting you get a better understanding of how components work together.

#### Controller
```swift
struct Controller {
    let model = Model()
    //usually trigered by connection action to UI element, like a button
    //in iOS, more known under term IBAction
    
    func performSomeBusinessLogic() {
        print("performing some changes on self")
        //Notification pattern - posting a notification
        //represent action [2] on graph
        NotificationCenter.default.post(Notification(name: Notification.Name("businessLogicUpdated")))
    }
}

```

#### Model
```swift
struct Model {

    func performSomeBusinessLogic() {
        print("performing some changes on self")
        //Notification pattern - posting a notification
        //represent action [2] on graph
        NotificationCenter.default.post(Notification(name: Notification.Name("businessLogicUpdated")))
    }
}
```

### View
```swift
class View {
    
    init() {
        //Notification pattern - adding an observer
        NotificationCenter.default.addObserver(self, selector: #selector(performUIUpdates), name: Notification.Name("businessLogicUpdated"), object: nil)
    }
    
    @objc func performUIUpdates() {
        print("Updating UI")
    }
}
```

### Running example code in playground in Xcode:
```swift
let contoller = Controller()
let view = View()
contoller.userTappedButton()
```

### Output

Feel free to clone code samples from my GitHub [repo](https://github.com/nmatijevic1/BlogCodeSamples). You can see the output printed in console.


## Problems


When it comes to MVC and functionality belonging, the _separation of concerns_ is not clearly defined. MVC was invented in 1970s and was appropriate for that point in time. Most softwares at that point were just presenting data stored in databases. Modern software includes way more functionalities. Separation into three layers is simply not strict enough and leaves a lot of room for developers to decide. What happens is, as codebase grows, one of the layers ( usully model ) becomes huge, hard to understand and mantain. This problem _cannot be solved using MVC_. 

## Conclusion

MVC is useful approach if you are building a prototype or a project with small codebase.Therefore, as your project grows you will need to shift towards more detailed and strict architectural approraches that leave enough room to be flexible, yet not too much to make your project unmaintainable. Solution to this problem will be covered in a series coming soon. Stay tuned!

