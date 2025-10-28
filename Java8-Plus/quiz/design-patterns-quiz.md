# Java 8+ Design Patterns - Self-Assessment Quiz

## Part 1: Pattern Recognition (Questions 1-25)

### Question 1: Identify the Pattern

```java
@FunctionalInterface
interface PaymentStrategy {
    void pay(double amount);
}

PaymentStrategy creditCard = amount ->
    System.out.println("Credit card: " + amount);

PaymentStrategy paypal = amount ->
    System.out.println("PayPal: " + amount);
```

Which pattern is demonstrated?

**A)** Builder Pattern
**B)** Strategy Pattern ✅
**C)** Factory Pattern
**D)** Decorator Pattern

**Explanation:** This shows the Strategy Pattern using functional interfaces. Each strategy encapsulates a different payment algorithm.

---

### Question 2: Builder Pattern Recognition

```java
HttpRequest request = new HttpRequestBuilder()
    .url("https://api.example.com")
    .addHeader("Auth", "token")
    .addHeader("Type", "json")
    .timeout(Duration.ofSeconds(30))
    .build();
```

What pattern is this?

**A)** Strategy Pattern
**B)** Factory Pattern
**C)** Builder Pattern ✅
**D)** Decorator Pattern

**Explanation:** Fluent API with method chaining returning `this` is characteristic of Builder Pattern.

---

### Question 3: Pattern Matching Recognition

```java
public String describe(Object obj) {
    return switch (obj) {
        case String s -> "String: " + s;
        case Integer i -> "Integer: " + i;
        case null -> "Null value";
        default -> "Unknown";
    };
}
```

Which Java 8+ feature is shown?

**A)** Lambda Expressions
**B)** Stream API
**C)** Pattern Matching ✅
**D)** Optional

**Explanation:** Switch expressions with pattern matching (Java 16+) for type-safe extraction.

---

### Question 4: Sealed Classes Purpose

```java
public sealed class Vehicle permits Car, Truck, Motorcycle {
    public abstract void drive();
}
```

What's the main benefit?

**A)** Reduces memory usage
**B)** Controls inheritance hierarchy ✅
**C)** Improves performance
**D)** Enables lazy loading

**Explanation:** Sealed classes restrict who can extend a class, enabling exhaustive pattern matching.

---

### Question 5: Record Usage

```java
public record User(String name, int age, String email) {}
```

What problem does this solve?

**A)** Lazy initialization
**B)** Circular dependencies
**C)** Boilerplate reduction ✅
**D)** Memory management

**Explanation:** Records provide immutable data carriers with auto-generated equals, hashCode, toString, etc.

---

### Question 6: Observer Pattern with Lambdas

```java
EventBus bus = new EventBus();
bus.subscribe(UserLoggedIn.class, event ->
    System.out.println("User logged in: " + event.userId())
);
```

Which pattern is this?

**A)** Observer Pattern ✅
**B)** Pub-Sub Pattern (same thing)
**C)** Both A and B
**D)** Factory Pattern

**Explanation:** Modern Observer Pattern using functional interfaces for event handling.

---

### Question 7: Factory Pattern with Streams

```java
public class ProcessorFactory {
    private static final Map<String, Supplier<Processor>> processors =
        new HashMap<>();

    public static Processor create(String type) {
        return processors
            .getOrDefault(type, () -> {
                throw new IllegalArgumentException("Unknown");
            })
            .get();
    }
}
```

What improvement does this make?

**A)** Type-safe
**B)** Runtime registration ✅
**C)** Better performance
**D)** Automatic caching

**Explanation:** Using Map + Supplier allows dynamic factory registration without modifying code.

---

### Question 8: Decorator Pattern Composition

```java
Coffee coffee = new MilkDecorator(
    new SugarDecorator(
        new SimpleCoffee()
    )
);
```

What can this pattern do?

**A)** Switch algorithms
**B)** Add behavior dynamically ✅
**C)** Control inheritance
**D)** Lazy load objects

**Explanation:** Decorator Pattern adds functionality to objects at runtime through composition.

---

### Question 9: Dependency Injection with Records

```java
public record UserService(UserRepository repository) {
    public List<User> getAll() {
        return repository.findAll();
    }
}
```

What's the benefit?

**A)** Testability ✅
**B)** Performance
**C)** Memory usage
**D)** Lazy loading

**Explanation:** DI makes testing easier by allowing mock dependencies injection.

---

### Question 10: Custom Functional Interface

```java
@FunctionalInterface
interface Validator<T> {
    boolean validate(T input);

    default Validator<T> and(Validator<T> other) {
        return input -> this.validate(input) && other.validate(input);
    }
}
```

What pattern is demonstrated?

**A)** Chain of Responsibility
**B)** Decorator Pattern
**C)** Composition Pattern ✅
**D)** Template Method

**Explanation:** Functional composition through default methods for combining validators.

---

### Question 11: Singleton with Enum

```java
public enum DatabaseConnection {
    INSTANCE;

    private final Connection connection = initConnection();

    public void execute(String sql) {
        // ...
    }
}
```

What's the advantage over traditional Singleton?

**A)** More instances allowed
**B)** Thread-safe by design ✅
**C)** Faster performance
**D)** Easier to extend

**Explanation:** Enum Singleton is guaranteed thread-safe and prevents reflection attacks.

---

### Question 12: Pattern Matching with Sealed Classes

```java
sealed interface Result permits Success, Failure {}
record Success(String data) implements Result {}
record Failure(String error) implements Result {}

String msg = switch (result) {
    case Success(String d) -> "OK: " + d;
    case Failure(String e) -> "ERROR: " + e;
};
```

What's guaranteed by compiler?

**A)** All cases are handled ✅
**B)** No NullPointerException
**C)** Better performance
**D)** Less memory

**Explanation:** Sealed classes + pattern matching enable exhaustiveness checking by compiler.

---

### Question 13: Chain of Responsibility

```java
RequestChain chain = new RequestChain()
    .add(request -> request.needsAuth(), authHandler)
    .add(request -> request.needsLog(), logHandler)
    .add(request -> true, mainHandler);
```

What does this pattern do?

**A)** Decouples senders from receivers ✅
**B)** Switches between algorithms
**C)** Adds functionality to objects
**D)** Controls object creation

**Explanation:** Chain of Responsibility passes requests through a chain of handlers.

---

### Question 14: Template Method Pattern

```java
Function<String, String> clean = String::trim;
Function<String, String> validate = s -> s.isEmpty() ? null : s;
Function<String, String> transform = String::toUpperCase;

public void process(String data) {
    save.accept(transform.apply(validate.apply(clean.apply(data))));
}
```

What pattern is this?

**A)** Builder
**B)** Template Method ✅
**C)** Strategy
**D)** Decorator

**Explanation:** Function composition implements Template Method Pattern functionally.

---

### Question 15: Comparing Patterns

```java
// Pattern A
List<String> names = new ArrayList<>();
Runnable handler = () -> names.add("John");

// Pattern B
List<String> names = new CopyOnWriteArrayList<>();
EventHandler handler = name -> names.add(name);
```

Which is better for multi-threaded event handling?

**A)** Pattern A
**B)** Pattern B ✅
**C)** Both equal
**D)** Neither

**Explanation:** Pattern B uses thread-safe collection and functional handler for better concurrency.

---

### Question 16: Optional as Monad

```java
Optional<String> email = user.getEmail();

String result = email
    .map(String::toUpperCase)
    .filter(e -> e.contains("@"))
    .orElse("invalid");
```

What pattern is this?

**A)** Monadic Pattern ✅
**B)** Iterator Pattern
**C)** Composite Pattern
**D)** Proxy Pattern

**Explanation:** Optional implements monadic operations (map, flatMap, filter).

---

### Question 17: Stream API Pattern

```java
List<String> result = users.stream()
    .filter(u -> u.age() >= 18)
    .map(User::email)
    .distinct()
    .sorted()
    .limit(10)
    .collect(toList());
```

What's being used?

**A)** Template Method
**B)** Pipeline Pattern ✅
**C)** Observer Pattern
**D)** Factory Pattern

**Explanation:** Streams use pipeline pattern for functional data processing.

---

### Question 18: Sealed Interface

```java
public sealed interface Payment permits CreditCard, PayPal {}

record CreditCard(String cardNumber) implements Payment {}
record PayPal(String email) implements Payment {}
```

What advantage does this provide?

**A)** Better encapsulation ✅
**B)** Faster execution
**C)** Less memory
**D)** Easier testing

**Explanation:** Sealed interfaces provide better encapsulation and enable exhaustive pattern matching.

---

### Question 19: Method Reference vs Lambda

```java
// A: Lambda
list.forEach(item -> System.out.println(item));

// B: Method Reference
list.forEach(System.out::println);
```

Which is better practice?

**A)** A is always better
**B)** B is cleaner when possible ✅
**C)** Both equal
**D)** Neither works

**Explanation:** Method references are cleaner and more readable than lambdas when applicable.

---

### Question 20: Composition vs Inheritance

```java
// A: Inheritance
class PayPalPayment extends Payment { }

// B: Composition
interface PaymentProcessor {
    void process(Payment payment);
}
```

Which is better for strategy?

**A)** A
**B)** B ✅
**C)** Both equal
**D)** Neither

**Explanation:** Composition is more flexible for strategy pattern than inheritance.

---

### Question 21: When to Use Functional Interface

```java
@FunctionalInterface
interface DataProcessor {
    List<Data> process(String input);
}
```

When should you use this?

**A)** Single method, used with lambdas ✅
**B)** Multiple related methods
**C)** Stateful operations
**D)** Never

**Explanation:** Functional interfaces with single methods enable lambda usage.

---

### Question 22: Error Handling Patterns

```java
public sealed interface Result<T> permits Success, Failure {}
record Success<T>(T value) implements Result<T> {}
record Failure<T>(String error) implements Result<T> {}
```

What advantage does this have?

**A)** Prevents exceptions ✅
**B)** Faster execution
**C)** Automatic retry
**D)** Better logging

**Explanation:** Using sealed result types forces error handling at compile time.

---

### Question 23: Comparing Builder Styles

```java
// A: Traditional
builder.url(url).header(k, v).header(k2, v2).build();

// B: Consumer
builder.url(url).configure(b -> {
    b.header(k, v);
    b.header(k2, v2);
}).build();
```

When is Consumer style better?

**A)** Always
**B)** For complex configurations ✅
**C)** Never
**D)** Performance critical

**Explanation:** Consumer style groups related configurations better for readability.

---

### Question 24: Sealed Classes Exhaustiveness

```java
sealed class Animal permits Dog, Cat {}
record Dog() extends Animal {}
record Cat() extends Animal {}

// Without default case - will this compile?
String sound = switch(animal) {
    case Dog d -> "Woof";
    case Cat c -> "Meow";
};
```

**A)** No, needs default case
**B)** Yes, compiler verifies exhaustiveness ✅
**C)** Depends on JVM version
**D)** Only if abstract

**Explanation:** Sealed classes enable exhaustiveness checking, eliminating need for default case.

---

### Question 25: Functional Composition

```java
Function<Integer, Integer> addOne = x -> x + 1;
Function<Integer, Integer> double = x -> x * 2;

Function<Integer, Integer> composed = addOne.andThen(double);
// or
Function<Integer, Integer> composed2 = double.compose(addOne);
```

Which computes (x + 1) * 2?

**A)** First only
**B)** Second only
**C)** Both do
**D)** Neither

**Explanation:** Both andThen and compose work, just in different order.

---

## Part 2: Code Analysis (Questions 26-40)

### Question 26: Code Analysis - Which Pattern?

```java
public class PaymentProcessor {
    private Map<String, Supplier<Payment>> methods = new HashMap<>();

    public void register(String type, Supplier<Payment> factory) {
        methods.put(type, factory);
    }

    public Payment create(String type) {
        return methods.getOrDefault(type, () -> null).get();
    }
}
```

Which pattern is implemented?

**A)** Strategy
**B)** Factory ✅
**C)** Observer
**D)** Decorator

---

### Question 27: Code Analysis - Issue?

```java
PaymentStrategy strategy = null;
// later
strategy.pay(100.0); // NPE!
```

How would Optional help?

**A)** Prevent compile
**B)** Require explicit null handling ✅
**C)** Automatic initialization
**D)** Nothing

---

### Question 28: Code Analysis - What's wrong?

```java
// Not using lambda capabilities
List<Integer> nums = Arrays.asList(1, 2, 3);
nums.forEach(new Consumer<Integer>() {
    public void accept(Integer n) {
        System.out.println(n);
    }
});
```

Better way?

**A)** Use lambda: `forEach(n -> System.out.println(n))`
**B)** Use method ref: `forEach(System.out::println)` ✅
**C)** Use stream: `nums.stream().forEach(...)`
**D)** All above

---

### Question 29: Code Analysis - Pattern?

```java
public void validate(User user) {
    if (user == null) {
        throw new IllegalArgumentException("Null user");
    }
    // process
}
```

Which pattern is missing?

**A)** Optional pattern ✅
**B)** Strategy pattern
**C)** Factory pattern
**D)** Decorator pattern

---

### Question 30: Code Analysis - Improvement?

```java
class DatabaseService {
    private static DatabaseService instance;

    public static DatabaseService getInstance() {
        if (instance == null) {
            instance = new DatabaseService();
        }
        return instance;
    }
}
```

Better implementation?

**A)** Use enum ✅
**B)** Use Spring
**C)** Use DI container
**D)** All above

---

### Question 31-40: Short Answer Questions

### Question 31: What makes Sealed Classes better for pattern matching?

**Answer:** Sealed classes restrict permitted implementations, enabling compiler to verify exhaustiveness in switch statements without needing a default case.

---

### Question 32: Why use Records instead of classes for data?

**Answer:** Records auto-generate equals, hashCode, toString, getters - reducing boilerplate by 90% while providing immutability by default.

---

### Question 33: When would you NOT use Singleton?

**Answer:** When using dependency injection framework, in unit tests (hard to mock), or when multiple instances might be needed in the future.

---

### Question 34: Explain function composition with andThen vs compose

**Answer:** `f.andThen(g)` computes f then g (f→g). `f.compose(g)` computes g then f (g→f).

---

### Question 35: What's the advantage of sealed interfaces?

**Answer:** They control the type hierarchy, enabling exhaustive pattern matching and providing better encapsulation.

---

### Question 36: How does Optional.map differ from Optional.flatMap?

**Answer:** map applies function returning T, flatMap applies function returning Optional<T> (avoids Optional wrapping).

---

### Question 37: Why is enum Singleton better than traditional?

**Answer:** Enum is thread-safe by design, prevents reflection attacks, and serialization-safe.

---

### Question 38: What's functional composition?

**Answer:** Combining functions using andThen, compose, or chain them together to create pipeline operations.

---

### Question 39: When should you use sealed classes?

**Answer:** When you want to control who can implement/extend a class and enable exhaustive pattern matching.

---

### Question 40: How do records improve dependency injection?

**Answer:** Records with constructor injection parameters make DI explicit and type-safe with minimal boilerplate.

---

## Part 3: Application Questions (41-50)

### Question 41: Design Question

How would you implement a cache with decorator pattern that adds TTL support?

**Thinking Points:**
- Decorator wraps cache implementation
- Stores timestamp with values
- Checks expiration on get
- Composition over inheritance

---

### Question 42: Architecture Question

Design a payment system supporting multiple providers. Which pattern(s) would you use?

**Answer:** Strategy (for payment algorithms) + Factory (for provider creation) + Sealed classes (for result types) + Pattern matching (for result handling)

---

### Question 43: Testing Question

How would you test a logger that uses decorator pattern?

**Answer:** Test each decorator independently, then test combinations. Use composition to verify decorator order.

---

### Question 44: Performance Question

When should you use `CompletableFuture` vs `Optional`?

**Answer:** Optional for potentially null values. CompletableFuture for async operations.

---

### Question 45: Refactoring Question

Refactor this to use modern patterns:
```java
new Thread(() -> {
    User user = getUser("123");
    if (user != null) {
        System.out.println(user.getName());
    }
}).start();
```

**Answer:** Use CompletableFuture + Optional:
```java
CompletableFuture.supplyAsync(() -> getUser("123"))
    .thenAccept(user -> user.ifPresent(u ->
        System.out.println(u.getName())
    ));
```

---

### Question 46: Design Pattern Selection

Choose patterns for: "System that processes different file formats and validates data"

**Answer:** Strategy (format processing) + Decorator (validation layers) + Factory (format selection)

---

### Question 47: Error Handling

Design error handling using sealed classes and pattern matching

**Answer:**
```java
sealed interface FileResult permits FileSuccess, FileError {}
// Pattern match in switch for type-safe handling
```

---

### Question 48: Composition Question

Explain how to compose three validators into one

**Answer:** Use functional composition with default `and()` method combining predicates

---

### Question 49: Real-World Scenario

How would you implement notification system for multiple channels (email, SMS, push)?

**Answer:** Strategy pattern (channel algorithms) + Observer (subscribers) + Factory (channel creation)

---

### Question 50: Extension Question

The system needs to support a new payment provider. How would your factory design handle this?

**Answer:** Just register new supplier in factory map - no code changes needed, true Open/Closed principle

---

## Scoring Guide

**Questions 1-25:** 4 points each (100 points)
**Questions 26-30:** 4 points each (20 points)
**Questions 31-40:** 4 points each (40 points)
**Questions 41-50:** 6 points each (60 points)

**Total: 220 points**

**Scoring:**
- 0-100: Needs more study
- 100-150: Good understanding
- 150-200: Excellent understanding
- 200+: Expert level

---

## Study Recommendations

**If you scored poorly on:**
- Q1-5: Review pattern basics in Chapter 16
- Q6-10: Practice functional interface examples
- Q11-15: Study sealed classes and records
- Q16-20: Review optional and stream patterns
- Q21-25: Go through comparison table in chapter
- Q26-40: Re-read architecture section
- Q41-50: Complete coding challenges

---

**Last Updated:** October 26, 2024
**Level:** All Levels (Beginner to Expert)
**Total Questions:** 50
**Difficulty:** Progressive (Basic → Advanced)
**Estimated Time:** 2-3 hours
**Recommended Score:** 80%+
