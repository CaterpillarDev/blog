---
date: 2020-06-19 23:00
readingTime: 5
section: Advanced programming knowledge
---

# SOLID Principles - Liskov Substitution Principle (LSP)


Subclassing, more known as Inheritance is one of the basic principles of OOP. In modern programming world, especially in iOS world, there has been a huge trend of POP (Protocol Oriented Programming). Why is this? 

> People don't like inheritance


Why don't people like inheritance? Well mostly because it carries a lot with itself. You are taking over pretty much everything that superclass does and if you want to change something, you have to specifically use `override` keyword.

This is where we come to **LSP**.


## Definition

[Barbara Liskov](https://en.wikipedia.org/wiki/Barbara_Liskov) defined this principle that talks about subtypes in 1988. The definition:

> “If for each object o1 of type S there is an object o2 of type T such that for all programs P written in terms of T, the behaviour of P is unchanged when o1 is substituted by o2 then S is a subtype of T.”

This could be quite confusing, so let's take a look at an example.

## Example

One of the more commonly used examples when it comes to explaining inheritance is the shapes example:

![LSP](/images/LSP.png)

**So, what's wrong here?**

Well, square isn't really a good fit as subtype of Rectangle. Height and width in a rectangle are changed independently of each other, while **it's exactly the opposite** when it comes to a square. What could happen is that you think you are talking to a rectangle, while it's actually a square.

The result could be summed up in a couple of lines of code:

```swift
let rect = Rectangle()
rect.setW(5)
rect.setH(2)
assert(rect.area() == 10) // returns true
```
If you wrote the same test for a Square, the test would fail. Therefore, **`Square` is not an appropriate subclass of `Rectangle`**.


## Conclusion

You should be really careful when using inheritance. A nice solution to this is create a **`Shape` protocol** which all shapes conform to. This is how you avoid this issue. 

If some stuff here is not clear enough, feel free to reach me on  [LinkedIn](https://www.linkedin.com/in/nikolamatijevic) or [Twitter](https://twitter.com/nmatijevic1) or even change my mind. 

Happy reading!

# References

- [Barbara Liskov](https://en.wikipedia.org/wiki/Barbara_Liskov)
