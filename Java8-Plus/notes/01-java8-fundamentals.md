# Java 8 Fundamentals

Java 8 introduced revolutionary features that changed how modern Java is written. This chapter covers the essential Java 8+ features.

## What is Java 8?

Java 8 was released in March 2014 and introduced **Lambda Expressions**, **Functional Interfaces**, and the **Streams API** - fundamentally changing how we write Java code.

## Key Features Overview

| Feature | Release | Impact |
|---------|---------|--------|
| Lambda Expressions | Java 8 | Functional programming in Java |
| Streams API | Java 8 | Functional data processing |
| Functional Interfaces | Java 8 | Enable lambda expressions |
| Default Methods | Java 8 | Interface evolution |
| Optional | Java 8 | Null-safety |
| Method References | Java 8 | Concise function references |
| Date/Time API | Java 8 | Modern date handling |
| Records | Java 14 | Immutable data carriers |
| Sealed Classes | Java 15 | Controlled inheritance |
| Pattern Matching | Java 16+ | Cleaner conditionals |

---

## 1. Lambda Expressions

### What is a Lambda?

A lambda expression is an **anonymous function** that allows you to write functional code in Java.

**Syntax:**
```java
(parameters) -> expression
(parameters) -> { statements; }
```

### Basic Examples

**Without Lambda (Traditional):**
```java
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

// Old way with anonymous class
Runnable r = new Runnable() {
    @Override
    public void run() {
        System.out.println("Hello");
    }
};
```

**With Lambda:**
```java
// Lambda way - much cleaner
Runnable r = () -> System.out.println("Hello");
```

### Lambda with Parameters

```java
// Single parameter (no parentheses needed if one param)
Function<Integer, Integer> square = x -> x * x;
System.out.println(square.apply(5)); // Output: 25

// Multiple parameters
BiFunction<Integer, Integer, Integer> add = (a, b) -> a + b;
System.out.println(add.apply(3, 4)); // Output: 7

// Multiple statements
BiFunction<Integer, Integer, Integer> max = (a, b) -> {
    if (a > b) return a;
    return b;
};
```

### Common Functional Interfaces

```java
// Consumer - takes input, returns nothing
Consumer<String> print = str -> System.out.println(str);
print.accept("Hello");

// Supplier - returns value, takes no input
Supplier<String> getGreeting = () -> "Hello, World!";
String greeting = getGreeting.get();

// Function - transforms input to output
Function<String, Integer> length = str -> str.length();
Integer len = length.apply("Java");

// Predicate - returns boolean
Predicate<Integer> isEven = num -> num % 2 == 0;
boolean result = isEven.test(4); // true
```

---

## 2. Functional Interfaces

### What is a Functional Interface?

An interface with **exactly one abstract method**. They enable lambda expressions.

### Creating Custom Functional Interfaces

```java
@FunctionalInterface
public interface Calculator {
    int calculate(int a, int b);
}

// Usage
Calculator add = (a, b) -> a + b;
Calculator multiply = (a, b) -> a * b;

System.out.println(add.calculate(5, 3));      // Output: 8
System.out.println(multiply.calculate(5, 3)); // Output: 15
```

### Built-in Functional Interfaces

**java.util.function package provides:**

```java
// Function<T, R>
Function<String, Integer> stringLength = String::length;

// Predicate<T>
Predicate<Integer> isPositive = num -> num > 0;

// Consumer<T>
Consumer<String> printName = System.out::println;

// Supplier<T>
Supplier<LocalDateTime> getCurrentTime = LocalDateTime::now;

// BiFunction<T, U, R>
BiFunction<Integer, Integer, Integer> add = Integer::sum;

// UnaryOperator<T>
UnaryOperator<Integer> square = x -> x * x;

// BinaryOperator<T>
BinaryOperator<Integer> multiply = (a, b) -> a * b;
```

---

## 3. Method References

Method references provide a way to refer to methods without invoking them. They're shorthand for lambdas.

### Types of Method References

#### 1. Static Method Reference
```java
// Traditional lambda
Function<String, Integer> lambda = s -> Integer.parseInt(s);

// Method reference
Function<String, Integer> reference = Integer::parseInt;

// Usage
Integer result = reference.apply("42"); // 42
```

#### 2. Instance Method Reference
```java
String str = "Hello";

// Traditional lambda
Supplier<Integer> lambda = () -> str.length();

// Method reference
Supplier<Integer> reference = str::length;

Integer len = reference.get(); // 5
```

#### 3. Constructor Reference
```java
// Lambda that creates objects
Supplier<ArrayList> lambda = () -> new ArrayList();

// Constructor reference
Supplier<ArrayList> reference = ArrayList::new;

List<String> list = reference.get();
```

#### 4. Array Constructor Reference
```java
Function<Integer, int[]> lambda = size -> new int[size];
Function<Integer, int[]> reference = int[]::new;

int[] arr = reference.apply(5); // Array of size 5
```

---

## 4. Streams API

The Streams API provides a **functional approach to data processing**.

### Key Concepts

- **Stream** - A sequence of elements supporting sequential and parallel operations
- **Immutable** - Streams don't modify the source data
- **Lazy** - Operations are deferred until a terminal operation is called

### Basic Stream Operations

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// filter - keep elements matching a condition
numbers.stream()
    .filter(n -> n % 2 == 0)
    .forEach(System.out::println); // Output: 2, 4

// map - transform each element
numbers.stream()
    .map(n -> n * 2)
    .forEach(System.out::println); // Output: 2, 4, 6, 8, 10

// sorted - order elements
numbers.stream()
    .sorted(Comparator.reverseOrder())
    .forEach(System.out::println); // Output: 5, 4, 3, 2, 1
```

### Terminal Operations

Terminal operations produce a final result and end the stream:

```java
List<String> words = Arrays.asList("Java", "Stream", "API");

// collect - gather into collection
List<String> uppercase = words.stream()
    .map(String::toUpperCase)
    .collect(Collectors.toList());

// forEach - perform action for each element
words.stream()
    .forEach(System.out::println);

// reduce - combine elements
int sum = Arrays.asList(1, 2, 3, 4, 5).stream()
    .reduce(0, Integer::sum); // 15

// count - get count
long count = words.stream()
    .filter(w -> w.length() > 4)
    .count();

// findFirst - get first element
Optional<String> first = words.stream()
    .findFirst();

// anyMatch/allMatch - check conditions
boolean hasLong = words.stream()
    .anyMatch(w -> w.length() > 5);
```

---

## 5. Optional

**Optional** is a container that may or may not contain a value, helping avoid null pointer exceptions.

### Creating Optional

```java
// Empty optional
Optional<String> empty = Optional.empty();

// Optional with value
Optional<String> name = Optional.of("Java");

// Optional that might be null
Optional<String> nullable = Optional.ofNullable(someValue);
```

### Using Optional

```java
Optional<String> name = Optional.of("Alice");

// Check if present
if (name.isPresent()) {
    System.out.println(name.get()); // "Alice"
}

// ifPresent - execute if present
name.ifPresent(System.out::println);

// ifPresentOrElse - Java 9+
name.ifPresentOrElse(
    System.out::println,
    () -> System.out.println("No value")
);

// orElse - provide default
String value = name.orElse("Unknown");

// orElseGet - provide supplier
String value = name.orElseGet(() -> "Default");

// orElseThrow - throw exception if empty
String value = name.orElseThrow(() -> new RuntimeException("Empty"));

// map - transform if present
Optional<Integer> length = name.map(String::length);

// filter - keep if predicate matches
Optional<String> filtered = name.filter(n -> n.length() > 3);
```

---

## 6. Default Methods in Interfaces

Java 8 allowed interfaces to have **default implementations** of methods.

```java
public interface Vehicle {
    void drive();

    // Default method with implementation
    default void honk() {
        System.out.println("Beep beep!");
    }
}

public class Car implements Vehicle {
    @Override
    public void drive() {
        System.out.println("Car is driving");
    }

    // Can override default method
    @Override
    public void honk() {
        System.out.println("Car horn: HONK!");
    }
}

// Usage
Car car = new Car();
car.drive();  // "Car is driving"
car.honk();   // "Car horn: HONK!"
```

### Benefits

- **Backward Compatibility** - Add new methods to interfaces without breaking implementations
- **Mixin Behavior** - Share utility methods across interfaces
- **Evolution** - Evolve interfaces gracefully

---

## 7. Comparator Improvements

Java 8 made Comparators much more functional:

```java
List<String> words = Arrays.asList("Java", "Stream", "API");

// Traditional comparator
Comparator<String> traditional = new Comparator<String>() {
    @Override
    public int compare(String a, String b) {
        return a.length() - b.length();
    }
};

// With lambda
Comparator<String> lambda = (a, b) -> a.length() - b.length();

// Using comparingInt
Comparator<String> comparator = Comparator.comparingInt(String::length);

// Chain comparators
Comparator<String> chain = Comparator
    .comparingInt(String::length)
    .thenComparing(String::compareTo);

// Reverse order
Comparator<String> reverse = Comparator
    .comparingInt(String::length)
    .reversed();

// Using in sorted
List<String> sorted = words.stream()
    .sorted(Comparator.comparingInt(String::length))
    .collect(Collectors.toList());
```

---

## Summary

Java 8 transformed Java into a modern language supporting:
- **Functional Programming** with lambdas and functional interfaces
- **Concise Code** with method references and stream operations
- **Null Safety** with Optional
- **Interface Evolution** with default methods
- **Powerful Data Processing** with Streams API

These features became the foundation for all subsequent Java releases.

---

## Next Steps

1. Practice writing lambda expressions
2. Explore the Streams API deeply
3. Learn about parallelization
4. Study advanced stream operations

