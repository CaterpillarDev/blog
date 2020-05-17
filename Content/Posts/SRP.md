#	SOLID Principles with examples


![](/Users/nikolamatijevic/Downloads/christian-cagni-2DLXpYB9_SQ-unsplash.jpg)


As your project grows, having some really simple design patterns simply isn't going to be enough. If you don't know why, please check out my previous articles on [MVC](https://caterpillardev.com/posts/MVC/) and [MVVM](https://caterpillardev.com/posts/MVVM/). If you are interested in other design patterns like MVP or VIPER, please check out this youtube [series](https://www.youtube.com/playlist?list=PLyjgjmI1UzlSWtjAMPOt03L7InkCRlGzb). This was one of my first architectural knowledge sources.

If this problem doesn't seem big enough for you to invest effort into, you are wrong. Just trust me on this one. Architectural knowledge is the one I benefited the most from in my career so far.

So, from the above-stated articles and video series, you could find out why it's not enough to use some of these really simple patterns. So what's the solution to this problem? 

The solution will come in a series of articles, but what we need first is **`SOLID`** foundation.

This is where S.O.L.I.D principles come into play.

## Introduction to S.O.L.I.D

SOLID is an acronym for five software development principles that make your software more scalable, maintainable and flexible. 

What SOLID explains could be called "mid-level architecture". It helps decide what should each class/struct do, how it should be structured and what should be relations between them in a component. 

When speaking about higher-level architecture, we are speaking about modules and their relationships.

> “If the bricks aren’t well made, the architecture of the building doesn’t matter much. On the other hand, you can make a substantial mess with well made bricks. This is where the SOLID principles come in“ - Robert C. Martin 10

SOLID got its name in 2004, even though the idea started in the 80s. It represents five principles: 
- Single Responsibility Principles (SRP)
- Open-Closed Principle (OCP)
- Liskov Substitution Principle (LSP)
- Interface Segregation Principle (ISP)
- Dependency Inversion Principle


Let's dive right in.

## Single Responsibility Principle (SRP)

Out of all principles, SRP is one that's most mistakenly interpreted.
What you can mostly see as an interpretation is:

> ~~“ Module should have one, and only one, reason to change. ”~~

But, this is not entirely true. What is a the reason in this case? This is simply not deterministic enough. Your app shouldn't change for some random reason, it should change to please users or stakeholders. That's why a better explanation would be: 

> **“ Module should be responsible to one, and only one, user or stakeholder ”**

### Example

Looking at an example will probably make this a lot clearer for you. My preferred way is to look at what should **not** be done, and from there derive the right approach. Let's take a look at something you have probably done by now since all apps are communicating to servers nowadays. 

![](/Users/nikolamatijevic/Desktop/SRP.png)

In this example, we can see that this class has 3 separate functionalities. The problem is that these functionalities are used by 3 different actors.

#### PROBLEM

These functions would probably be called in the following order.

![](/Users/nikolamatijevic/Desktop/SRP_flow.png)

Now we have three different actors, each determining what their functionality does. This easily leads to breaking each other's code since functionalities are dependant on each other. This is a source of bugs that are hard to trace and make your software a lot more prone to bugs.

#### SOLUTION

The solution is quite simple. We can easily solve this issue by breaking down out `DataHandler` class into separate components that will then be used by another component which will assemble them together. 

![](/Users/nikolamatijevic/Desktop/SRP_solution.png)

What this gives us is a clear separation of concerns, classes being entirely standalone and having a `single responsibility`. They are also agnostic of all other components, which makes testing / adjusting / replacing these components really simple.


## Conclusion

In this article, you could see the importance of the first SOLID principle. In the next article, I will further try to explain other principles and their benefits. None of this is relevant if you don't apply what you learned. Go and analyze your existing projects, and start implementing the first principle. That's the only actual way to learn. I am also referencing one of the most amazing books I read in my life from computer science area. You can find it in References down below. This book was the first resource I had when it comes  to SOLID, and I always have a copy of it on my desk.

If some stuff here is not clear enough, feel free to reach me on  [LinkedIn](https://www.linkedin.com/in/nikolamatijevic) or [Twitter](https://twitter.com/nmatijevic1) or even change my mind. 


## References 

- [MVC article](https://caterpillardev.com/posts/MVC/)
- [MVVM article](https://caterpillardev.com/posts/MVVM/)


## Sources

- [Clean Architecture book](https://www.amazon.de/dp/0134494164?tag=duckduckgo-osx-de-21&linkCode=osi&th=1&psc=1)