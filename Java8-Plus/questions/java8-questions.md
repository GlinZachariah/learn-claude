# Java 8 Fundamental Questions

## Question 1: Lambda Expression Syntax

**Question:** What is the correct syntax for a lambda expression that takes two integers and returns their sum?

**Answer:**
```java
(a, b) -> a + b
```

Or with explicit return statement:
```java
(a, b) -> { return a + b; }
```

**Explanation:**
A lambda expression has the syntax: `(parameters) -> expression` or `(parameters) -> { statements; }`. If there's only one parameter, parentheses are optional: `x -> x * 2`. The arrow `->` separates parameters from the body.

**Difficulty:** Basic
**Tags:** #lambda-expressions #syntax

---

## Question 2: Functional Interface Requirement

**Question:** What defines a Functional Interface in Java?

**Answer:**
A Functional Interface is an interface with **exactly one abstract method**. It can have multiple default methods or static methods, but only one abstract method.

**Explanation:**
The `@FunctionalInterface` annotation helps enforce this contract at compile time. Examples include:
- `Runnable` (no parameters, no return)
- `Callable<T>` (no parameters, returns T)
- `Function<T, R>` (parameter T, returns R)
- `Consumer<T>` (parameter T, no return)

**Difficulty:** Basic
**Tags:** #functional-interface #annotations

---

## Question 3: Method References

**Question:** What is a method reference and how does it relate to lambda expressions?

**Answer:**
A method reference is a shorthand notation for calling a specific method. It's functionally equivalent to a lambda expression but is more concise.

**Examples:**
```java
// Lambda
Function<String, Integer> lambda = s -> Integer.parseInt(s);

// Method reference - equivalent
Function<String, Integer> reference = Integer::parseInt;
```

**Four types:**
1. Static method: `ClassName::staticMethod`
2. Instance method: `instance::method`
3. Constructor: `ClassName::new`
4. Array constructor: `Type[]::new`

**Difficulty:** Intermediate
**Tags:** #method-references #conciseness

---

## Question 4: Stream vs Iterator

**Question:** What are the key differences between a Stream and a traditional Iterator?

**Answer:**

| Aspect | Stream | Iterator |
|--------|--------|----------|
| Iteration | Internal (framework) | External (you control) |
| Evaluation | Lazy | Eager |
| Reusability | One-time use | Can iterate multiple times |
| Functional | Supports functional operations | Traditional imperative |
| Parallelization | Built-in support | Not straightforward |

**Explanation:**
Streams provide a more functional and elegant way to process data compared to traditional iterators. Streams are lazy, meaning operations only execute when a terminal operation is called. Streams cannot be reused once consumed.

**Difficulty:** Intermediate
**Tags:** #streams #iteration-styles

---

## Question 5: Filter vs Map

**Question:** What is the difference between `filter()` and `map()` in the Streams API?

**Answer:**

**filter(Predicate):**
- Keeps or removes elements based on a condition
- Returns a boolean predicate
- Does not transform elements

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
numbers.stream()
    .filter(n -> n % 2 == 0)  // Keep even numbers
    .forEach(System.out::println); // Output: 2, 4
```

**map(Function):**
- Transforms each element to a different value
- Returns a function that transforms T to R
- Changes the elements

```java
numbers.stream()
    .map(n -> n * 2)  // Double each number
    .forEach(System.out::println); // Output: 2, 4, 6, 8, 10
```

**Difficulty:** Basic
**Tags:** #streams #intermediate-operations

---

## Question 6: Optional Purpose

**Question:** Why was Optional introduced in Java 8, and what problem does it solve?

**Answer:**
Optional was introduced to handle the problem of `NullPointerException` and explicitly represent the absence of a value.

**Problems it solves:**
1. **Null Safety** - Makes nullability explicit in the API
2. **Code Clarity** - Clearly signals that a value might be absent
3. **Functional Operations** - Provides methods like `map()`, `filter()`, `orElse()`

**Example:**
```java
// Without Optional
String getName() {
    return person != null ? person.getName() : null;
}

// With Optional
Optional<String> getName() {
    return Optional.ofNullable(person)
        .map(Person::getName);
}

// Usage
getName().ifPresent(System.out::println);
```

**Difficulty:** Intermediate
**Tags:** #optional #null-safety

---

## Question 7: FlatMap Use Case

**Question:** When should you use `flatMap()` instead of `map()` in streams?

**Answer:**
Use `flatMap()` when your mapping function returns a Stream (or other container) and you want to flatten the result into a single stream.

**Example:**
```java
// Without flatMap - nested
List<List<Integer>> listOfLists = Arrays.asList(
    Arrays.asList(1, 2),
    Arrays.asList(3, 4)
);
List<List<Integer>> result = listOfLists.stream()
    .collect(Collectors.toList());
// [[1, 2], [3, 4]]

// With flatMap - flattened
List<Integer> result = listOfLists.stream()
    .flatMap(List::stream)
    .collect(Collectors.toList());
// [1, 2, 3, 4]
```

**Difficulty:** Intermediate
**Tags:** #flatmap #streams

---

## Question 8: Default Methods in Interfaces

**Question:** What is a default method in an interface, and why was it added?

**Answer:**
A default method is an interface method with an implementation (using the `default` keyword). It was added to enable interface evolution while maintaining backward compatibility.

**Example:**
```java
public interface Vehicle {
    void drive();

    default void honk() {
        System.out.println("Beep!");
    }
}

public class Car implements Vehicle {
    @Override
    public void drive() { ... }

    // Can use default honk() or override it
}
```

**Reasons for addition:**
1. **Backward Compatibility** - Add methods without breaking existing implementations
2. **Mixin Behavior** - Share utility methods across interfaces
3. **Interface Evolution** - Evolve interfaces gracefully

**Difficulty:** Intermediate
**Tags:** #interfaces #default-methods

---

## Question 9: Collector vs Reduce

**Question:** What is the difference between `collect()` and `reduce()` terminal operations?

**Answer:**

**reduce():**
- Combines elements into a **single value**
- Takes a `BinaryOperator` that combines two values
- Returns the combined result

```java
int sum = Stream.of(1, 2, 3).reduce(0, Integer::sum); // 6
```

**collect():**
- Combines elements into a **collection** or custom container
- Takes a `Collector` with more control
- Useful for grouping, mapping to collections, etc.

```java
List<Integer> list = Stream.of(1, 2, 3)
    .collect(Collectors.toList()); // [1, 2, 3]
```

**Difficulty:** Advanced
**Tags:** #terminal-operations #collectors

---

## Question 10: Lazy Evaluation in Streams

**Question:** What does "lazy evaluation" mean in the context of streams, and why is it important?

**Answer:**
Lazy evaluation means that intermediate operations (filter, map, etc.) are **not executed immediately**. They are only executed when a terminal operation is called.

**Example:**
```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Nothing printed yet - lazy evaluation
numbers.stream()
    .peek(n -> System.out.println("Processing: " + n))
    .filter(n -> n > 2);

// Now terminal operation triggers execution
numbers.stream()
    .peek(n -> System.out.println("Processing: " + n))
    .filter(n -> n > 2)
    .forEach(System.out::println);
```

**Benefits:**
1. **Performance** - Avoids unnecessary computations
2. **Short-circuiting** - Operations like `findFirst()` can stop early
3. **Efficiency** - Processes only what's needed

**Difficulty:** Advanced
**Tags:** #lazy-evaluation #performance

---

## Question 11: Comparator Chaining

**Question:** How can you chain multiple comparators to sort by multiple fields?

**Answer:**
Use the `thenComparing()` method to chain comparators.

**Example:**
```java
record Person(String name, int age) {}

List<Person> people = Arrays.asList(
    new Person("Alice", 30),
    new Person("Bob", 25),
    new Person("Alice", 25)
);

// Sort by name first, then by age
people.stream()
    .sorted(Comparator
        .comparing(Person::name)
        .thenComparing(Person::age))
    .forEach(System.out::println);

// Output:
// Person(name=Alice, age=25)
// Person(name=Alice, age=30)
// Person(name=Bob, age=25)
```

**Difficulty:** Intermediate
**Tags:** #comparators #sorting

---

## Question 12: Primitive Streams

**Question:** What are primitive streams (IntStream, LongStream, DoubleStream) and when should you use them?

**Answer:**
Primitive streams are specialized streams for primitive types that avoid boxing/unboxing overhead.

**Examples:**
```java
// IntStream
IntStream.range(1, 5)
    .forEach(System.out::println); // 1, 2, 3, 4

// From object stream
List<String> words = Arrays.asList("Java", "Stream");
int[] lengths = words.stream()
    .mapToInt(String::length)
    .toArray(); // [4, 6]

// Summary statistics
IntStream.of(1, 2, 3, 4, 5)
    .summaryStatistics()
    .getAverage(); // 3.0
```

**Benefits:**
1. **Performance** - No boxing overhead
2. **Convenience** - Special methods like `sum()`, `average()`, `max()`
3. **Memory** - Less memory usage than object streams

**Difficulty:** Intermediate
**Tags:** #primitive-streams #performance

