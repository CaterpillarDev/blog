---
date: 2020-05-19 23:00
readingTime: 15
section: Advanced programming knowledge
---


#	SOLID Principles - Open Closed Principle (1/2)


Setting a **SOLID** foundation is really hard, but in the end it has a huge payoff. After some time, you will understand that building a good foundation following these rules is even faster than building it without them. When you start noticing bottlenecks and where you broke these rules, you will see how much time you could have spared if they were properly implemented. If you never heard of SOLID before, I'd recommend reading my previous [article](https://caterpillardev.com/posts/SRP/) which is an introduction to SOLID principles and an explanation of the first ( Single Responsibility ) principle.


## Open-Closed Principle ( OCP )

OCP was defined back in 1988 by [Bertrand Meyer](https://en.wikipedia.org/wiki/Bertrand_Meyer):

> **“ A software artefact should be open for extension but closed for modification ”**

What does this even mean? This principle says that adding new features to your code should require minimal effort possible. So, for example, if you are building a financial report app, adding a new report should not affect existing code. **You shouldn't have to change existing code.**

In an ideal case, this means that you should only add code when building new features and put no effort into moving old ones around to make this possible. You have probably found yourself breaking this principle if you take a retroactive look. It's very important to accept mistakes and work on fixing them, rather than ignoring them.

## Example

Let's iterate over the above-stated example of an app that generates financial reports. We are going to analyze a simple feature that generates a report in two forms - PDF or Web Report.

![](/images/OCP_example_flow.png)

### **PROBLEM**

Here we can see a high-level overview of our feature. What our goal should be here is to structure source code so that changes in generating a PDF report don't affect the Web Report and vice versa.

If we take a look at our feature again, we can divide it into two segments:
- report calculation
- result presentation

### **SOLUTION**

![](/images/OCP.png)


I know this looks scary, but I will break it down to the tiniest detail so that you can understand it as well as I do.

First, let's take a look at the arrows. If you take a closer look, you can notice two types of arrows (empty and filled top):

- **Empty top** arrows represent **conformance** ( on the other side is always an `Interface/Protocol`)
- **Filled top** arrows represent **dependency** ( if class A points to class B, which means that class A has a reference to class B - usually in the form of a variable/constant). If you don't fully understand what is a `dependency`, you can check out [this discussion](https://www.quora.com/What-is-a-dependency-in-coding?share=1). Understanding dependencies is very important for else of this article, so I would suggest looking it up.


The graph above shows us **source code dependencies and relationships between objects**. The whole flow is separated into four components, also called `layers`:

- Interactor/Use Case
- Web server 
- Controller
- Presenter/View

These components are separated in double frame boxes. We will break down OCP into a set of rules:

1) First important thing is that **arrows leave a component in only one direction**. This is also known as `unidirectional data flow`. Following this can highly increase you code quality and conformance to OCP.

2) Which direction should arrows point to? This is determined based on component stability. In our case, the most stable part of our feature is how we calculate the report. After some time doing analysis like this, you will notice that `the most stable part of your feature/app is logic that actually represents a business you are trying to automate`. In our example, this logic is encapsulated inside of the **Interactor** module. What you can notice that 

> **all the arrows point towards this module and none come out of it**. This means that **our logic has no dependencies and doesn't know that any other components exist**. 

I cannot express the importance of this enough!

3) Arrows are always pointing towards stable components. We can notice that the `Controller` is more stable than the `Presenter`, and that's why the Presenter has a dependency on the Controller layer. We never do direct dependencies between components, we always use `protocols` as wrappers. This has multiple reasons behind it, but for now it's really important to know that this highly increases testability and stability of your code.

4) **Arrows decide the importance** of your components. In our case we can rank them as such:
	1. Interactor
	2. Controller
	3. Web server
	4. Presenter


> **Dependencies determine privileges.**

Let's take a look at protocols a bit and why they are positioned in the way they are. If we take a look at our Interactor, we can see that it has a dependency to the `DataProvider` **interface**. What is important is to 
> never depend on concrete implementations, always point to abstractions.

What this allows us is not to depend on internal implementations of functions defined in protocols. As long as input (function attributes) and output (return type) are the same, the component that implements the protocol can be tested and even deployed separately.

# Conclusion
This article covers in-depth theoretical analysis (highly applicable one). In my next article I will move into implementation, starting from the first described approach (one that breaks OCP) and explain how you could improve from there to respect this principle. I will also go into further detail about each layer and their responsibilities.

If some stuff here is not clear enough, feel free to reach me on  [LinkedIn](https://www.linkedin.com/in/nikolamatijevic) or [Twitter](https://twitter.com/nmatijevic1) or even change my mind. 


# References

- [SOLID introduction article](https://caterpillardev.com/posts/SRP/)
- [Bertrand Meyer](https://en.wikipedia.org/wiki/Bertrand_Meyer)
- [Dependency explanation](https://www.quora.com/What-is-a-dependency-in-coding?share=1)
