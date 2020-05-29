---
date: 2020-05-19 23:00
readingTime: 15
section: Advanced programming knowledge
---


#	SOLID Principles - Open Closed Principle (2/2)

This article is a continuation of the introductory [article](https://caterpillardev.com/posts/OCP/) to the Open-Closed principle. In case you haven't read that one, I highly recommend doing that prior to reading this one. In my prior article, I focused more on the theoretical foundation of this principle. So let's take a look at the example we began with last time: 

![](/images/OCP_example_flow.png)


## Problem

Changes in the way we generate Web reports **affect** PDF report generation and vice versa. This should be avoided if possible. By affect, what I mean is that changes in code of `web report generation` could cause `bugs/crashes` when we generate a `PDF report`. Let's see how we can avoid these issues.


If we take a look at our feature again, we can divide it into two segments:

- report calculation
- result presentation

Our initial code structure could look something like this:
```swift
struct DataProvider {
    func fetchDataFromServer(completion:  @escaping (Result<Data, Error>) -> Void) {
        // call to the server
        // fetch data
        // parse response
    }
}
```
This component `talks to our web server via internet` and gets the latest data for a specific user. We will then use this data to feed it into our logic component.

> For simplicity purposes, I will just use function signatures and skip all the logic inside, since it's irrelevant for our topic.


```swift
struct FinancialAnalyzer {
    let dataProvider = DataProvider()

    func analyzeData(completion:  @escaping (Result<FinancialData, Error>) -> Void) {
        dataProvider.fetchDataFromServer { result in
            switch  result {
            case .success(let data):
                // perform logic here
                // completion with success
            case .failure(let error):
                // completion with failure
            }
        }
    }
}
```
This is where the most important piece of our code is. It does all the **`logic`** of our app. It basically represents what the business would look like if it wasn't an app.

```swift
struct PDFReportGenerator {
    let analyzer = FinancialAnalyzer()

    func generateReport() {
        // call analyzer.analyzeData
        // get result
        // present report||error
        }
}
```
```swift
struct WebReportGenerator {
    let analyzer = FinancialAnalyzer()

    func generateReport() {
        // call analyzer.analyzeData
        // get result
        // present report||error
        }
}
```

These are two components that use our logic component, generate the report and present it to the user.

Now we can discuss our problems in more detail.

First thing is that now our `FinancialAnalyzer` provides a `FinancialData` struct in case of success. In case our Web report now needs some more/less data, we would need to change the signature of this function and all the logic inside it. Even though this seems obvious and logical, what now happens is that `PDFGenerator is broken`. The code won't even compile. 

The second issue is that all our components are tightly coupled and directly referencing each other. This is really hard to test because you cannot mock any of these components. It's hard to maintain because changes in one component affect all the components in the stream below, as we could see in the first issue also.

**This is just the tip of the issues iceberg**. Let's see how we can solve these issues quite easily.

## Solution

Let's first solve the second issue, since its solution will help us solve the first issue too. The issue we have is 

> we are referencing concrete implementations (classes/structs) instead of abstractions (protocols).


How do we solve this? By simply wrapping all of our components in protocols. For example, our `DataProvider` could now look something like:

```swift
protocol DataProviderProtocol {
    func fetchDataFromServer(completion:  @escaping (Result<Data, Error>) -> Void)
}
struct DataProvider: DataProviderProtocol {
    func fetchDataFromServer(completion:  @escaping (Result<Data, Error>) -> Void) {
        // call to the server
        // fetch data
        // parse response
    }
}
```
The next step is adjusting our `Interactor` so it doesn't use the concrete implementation (DataProvider) but use the newly created protocol.

> **The following code samples are showing diffs instead of full code. Rest of the code either stays the same or is intuitively substitutable.**

```swift
struct FinancialAnalyzer {
    let dataProvider: DataProviderProtocol

    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
    }

}
```

What advantages does this bring to us? 
- we now have two isolated components that **do not depend** on each other
- we can now test and changes these components in isolation without it affecting other components
- we can change internal implementation of one component, without other components even knowing
- another benefit, which may not be really obvious is that we could entirely swap our data provider (e.g move from web server to local file storage provider) without our `Interactor` knowing, just by applying protocol conformance to our new provider.
- we are also now doing dependency injection. You can read about the benefits of it [here](https://en.wikipedia.org/wiki/Dependency_injection).

The last one is really huge, and it will soon bring us to another design pattern, which is called `Dependency composition`, also known as `Composition root`. In case you are interested, you can find more information [here](https://www.youtube.com/watch?v=cnHo2-gxqIQ&t=194s).

**`Dependency injection`** and **`Composition root`** together bring a way looser code and improve your code quality drastically. I highly suggest applying these to your architecture right away, it's impossible not to see the benefits.


### Next steps

We should now apply the same exact process to the Interactor and other components. Proper naming of the components can be found in the graph in my [previous article](https://caterpillardev.com/posts/OCP/).

Let me explain the components we haven't touched so far.

- **Entity** is the most important component of your app. Interactor is the place where all the business logic is, but entity is a data structure that represents data used in that logic. Therefore, the **Interactor depends on the Entity**. Entity is the least likely to change out of all the components, if you plan it well. In our example, it would be data representation of the report we want to present later, `in the form most appropriate for applying logic`. It is really important not to define your entities according to your UI representation, because then entity will change when your UI changes which will lead to whole app indirectly depending on your UI. The whole point is to avoid this. We will change our Entity into UI representable object inside of our UI layer, more concretely in our `ViewModel`.

- **ViewModel** is part of UI layer. Its purpose is to take results from interactor and adjust them to be in accordance with the way we want to present them.

- **View** is the Xib or Storyboard we are using to present data from `ViewModel`. You should default to Xibs always, due to many advantages. All the things discussed above would not be possible with Storyboards (without workarounds).

- **WebServer component** is the component communicating with the server, fetching the data, parsing it (also known as creating a DTO), turning that DTO into an entity and passing it along to `Interactor` component.

- **Controller** is not necessary in case of this feature, so we will leave it out. 

Let's adjust our code to match these rules. This means that our `DataProvider` cannot simply return data as `Data`. It has to transfer data into an entity that will be consumed by Interactor. For simplicity purposes, I will use an empty struct, since those details are irrelevant for this topic.

```swift
protocol DataProviderProtocol {
    func fetchDataFromServer(completion:  @escaping (Result<EntityToBeConsumedByInteractor, Error>) -> Void)
}
struct DataProvider: DataProviderProtocol {
    func fetchDataFromServer(completion:  @escaping (Result<EntityToBeConsumedByInteractor, Error>) -> Void) {
        // call to the server
        // fetch data
        // parse response
    }
}
```

Now we will use it in our interactor to turn it to new entity which is result of calculations performed, and pass that new entity down the stream to our `ViewModel`.

First, we need to rename our FinancialAnalyzer to an `Interactor` and then define a protocol to wrap around our `Interactor`. Those protocols are usually named `UseCases`.

```swift
protocol FinancialAnalyzisUseCase {
	func analyzeData(completion:  @escaping (Result<FinancialData, Error>) -> Void) 
}
struct FinancialAnalyzisInteractor: FinancialAnalyzisUseCase {
    let dataProvider: DataProviderProtocol

    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
    }
}
```

Even though it may seem component only got wrapped by a protocol and renamed, by having constant naming conventions such as `Interactors` being logic components, it's quite simple to pinpoint issues when they arise and find your way around the project overall.

We now have a way clearer **separation of concerns** and responsibilities of each layer are perfectly defined.

When it comes to doing the UI work itself, we still have two different presentations. What I would suggest in this case is starting with the **single ViewModel**. ViewModels are more characteristic for reactive programming, but since it is future of iOS development with `Combine` and `SwiftUI`, I consider this an appropriate example.

What we need to do is inject the `UseCase` as a dependency to our `ViewModel` and communicate with it. This substitutes all the logic that was earlier done in the view components.

When it comes to `Views`, they should be one of your `dumbest` components, so to say. Absolutely zero logic should be in your views. All their responsibilities are **reflecting changes in ViewModel on the screen**. Nothing else. 

If you are not familiar with how MVVM works, I would suggest this [article](https://medium.com/swlh/getting-started-with-swiftui-and-combine-using-mvvm-and-protocols-for-ios-d8c37731a1d9) if you have basic theoretical understanding. If not, please check out my prior [article](https://caterpillardev.com/posts/MVVM/) about MVVM in general.

```swift
struct ViewModel: PDFViewModelProtocol, WebReportViewModelProtocol {
    let dependencies: ViewModelDependencies

    init(dependencies: ViewModelDependencies) {
        self.dependencies = dependencies
    }

    func fetchUserFinancialData(completion:  @escaping (Result<FinancialData, Error>) -> Void) {
        // call use case
        // get data
        // pass it to the view
    }
}

protocol PDFViewModelProtocol {
    func fetchUserFinancialData(completion:  @escaping (Result<FinancialData, Error>) -> Void)
}

struct PDFView {
    let viewModel: ViewModel

    // use view model to fetch data
    // present result
}
```

# Conclusion

This is a huge one, but I certainly assure you, it will be really valuable once you get the full grasp of it.

> **If I could pick one thing I learned so far in my career, it would be this principle.**

I advise you to once again go and read both articles from scratch. Take notes, compare it with your own code. Fix your own code to be in accordance with this principle. Nothing beats the actual work.

If some stuff here is not clear enough, feel free to reach me on  [LinkedIn](https://www.linkedin.com/in/nikolamatijevic) or [Twitter](https://twitter.com/nmatijevic1) or even change my mind. 

Happy reading!


# References

- [Intro OCP article](https://caterpillardev.com/posts/OCP/)
- [Composition root](https://www.youtube.com/watch?v=cnHo2-gxqIQ&t=194s)
- [Dependency injection](https://en.wikipedia.org/wiki/Dependency_injection)
- [MVVM - theoretical basics](https://caterpillardev.com/posts/MVVM/) 
- [MVVM with SwiftUI and Combine](https://medium.com/swlh/getting-started-with-swiftui-and-combine-using-mvvm-and-protocols-for-ios-d8c37731a1d9)

# Abbreviations

- DTO -> Data Transfer Object