---
date: 2020-04-17 23:00
readingTime: 6
section: Design patterns
---

# MVVM - Model View ViewModel

Model-View-ViewModel, also known as MVVM, is a similar three-layered [_design pattern_](https://en.wikipedia.org/wiki/Software_design_pattern) as MVC used for handling user interactions with your software. As you will see, MVVM solves the same problem as MVC in a different way, but with pretty much the same problems.

Let's take a look at how these three layers fit together:

![MVVM](/images/MVVM.jpg)

## Basics

First difference we can see is that `View` doesn't have a **direct** reference to the `ViewModel`, which is different from MVC which you can see in my [previous article](https://caterpillardev.com/posts/MVC/).

Also, responsibilities are now split a bit differently. **`Model`** still stays you [single source of truth](https://en.wikipedia.org/wiki/Single_source_of_truth), which is responsible for encapsulating all of your business logic. All your logic should be here, independent of all external sources in your app (e.g server/database). 

> **Your source of truth should never care about external dependencies**

I cannot express importance of this separation enough. It leads to easier maintenance, improved testability and overall increase in stability and speed. However that is not possible with MVVM and you are about to find out why.

Responsibility of formatting has now been moved to `ViewModel`. You can see `ViewModel` as an interpreter between user interactions with a view and changes that your `Model` makes. Also, as you can see from the image, it also handles user events.

## Problems

What happens with other responsibilities of your app is the crucial thing. To list just some of them :

- Networking
- Routing
- Parsing
- Persistent storage

But, what most people don't know is that these **are not** problems MVVM is trying to solve. 

> **MVVM is a UI design pattern meant to handle user interactions with your app.**

The problem behind building your whole app in `MVVM` is that all of these bits and pieces still have to exist somewhere in your app and developer is the one who decides how and where do they fit the best.

This may vary based on example but how it usually looks in the end is something like this:


![](/images/MVVM2.jpg)


What this leads to is huge and monolithical components which are impossible to maintain, scale and test. Also, as they grow, adding features becomes harder and harder until it becomes impossible. Been there.

## Conclusion

If you are following the latest trends in iOS development, you know about `SwiftUI` and `Combine`. Even though they are kind of built for MVVM, it's still possible to use them with a proper architectural solutions. If some stuff here is not clear enough, feel free to reach me on  [LinkedIn](https://www.linkedin.com/in/nikolamatijevic) or [Twitter](https://twitter.com/nmatijevic1) or even change my mind. 

In my next article I will explain basis of architecture I have been working with for a couple of years now on some huge projects (~300k LoC). Stay tuned!


## Resources

Resources recommended in this article:

- [Design pattern](https://en.wikipedia.org/wiki/Software_design_pattern)
- My previous MVC [article](https://caterpillardev.com/posts/MVC/)
- [Single source of truth](https://en.wikipedia.org/wiki/Single_source_of_truth)

