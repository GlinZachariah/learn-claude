# Java 8 Self-Assessment Quiz

Complete this quiz to test your understanding of Java 8 features. Time yourself and aim for 80%+ accuracy.

---

## Question 1: Lambda Syntax
**What will this code print?**
```java
Function<Integer, Integer> fn = x -> x * 2;
System.out.println(fn.apply(5));
```

A) 5
B) 10
C) Compilation Error
D) 25

**Answer:** B) 10
**Explanation:** The lambda multiplies the input by 2. 5 * 2 = 10.

---

## Question 2: Multiple Answers - Stream Operations

**Which of the following are intermediate operations in the Streams API?**

A) `filter()`
B) `forEach()`
C) `map()`
D) `collect()`
E) `sorted()`
F) `reduce()`

**Answer:** A, C, E
**Explanation:**
- Intermediate: filter(), map(), sorted() - they return a Stream
- Terminal: forEach(), collect(), reduce() - they produce a final result

---

## Question 3: Optional Behavior

**What will this code print?**
```java
Optional<String> opt = Optional.of("Hello");
String result = opt.map(String::toUpperCase)
                   .orElse("DEFAULT");
System.out.println(result);
```

A) Hello
B) HELLO
C) DEFAULT
D) null

**Answer:** B) HELLO
**Explanation:** `map()` applies `toUpperCase()` to "Hello" resulting in "HELLO". Since it's present, `orElse()` is not used.

---

## Question 4: Method References

**Which method reference is equivalent to `x -> x.length()`?**

A) `String::length`
B) `Integer::length`
C) `Object::length`
D) `length::method`

**Answer:** A) `String::length`
**Explanation:** The method reference `String::length` refers to the instance method of String class. This is equivalent to `s -> s.length()`.

---

## Question 5: FlatMap Behavior

**What will this code print?**
```java
List<List<Integer>> lists = Arrays.asList(
    Arrays.asList(1, 2),
    Arrays.asList(3, 4)
);

lists.stream()
    .flatMap(List::stream)
    .forEach(System.out::print);
```

A) [[1, 2], [3, 4]]
B) 1234
C) [1, 2][3, 4]
D) Compilation Error

**Answer:** B) 1234
**Explanation:** `flatMap()` flattens the nested lists into a single stream: 1, 2, 3, 4. `forEach()` prints each element.

---

## Question 6: Functional Interface

**True or False: An interface with one abstract method and two default methods is a Functional Interface.**

**Answer:** True
**Explanation:** A Functional Interface must have exactly one abstract method. Default methods don't count toward this requirement.

---

## Question 7: Stream Laziness

**What will this code print?**
```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

numbers.stream()
    .peek(n -> System.out.println("Peek: " + n))
    .filter(n -> n > 3);
```

A) Nothing
B) Peek: 1, Peek: 2, Peek: 3, Peek: 4, Peek: 5
C) Peek: 4, Peek: 5
D) Compilation Error

**Answer:** A) Nothing
**Explanation:** Streams are lazy. Without a terminal operation, nothing is executed. `filter()` is an intermediate operation.

---

## Question 8: Comparator Chaining

**What will this code output?**
```java
List<String> words = Arrays.asList("Java", "Go", "Python", "C");

words.stream()
    .sorted(Comparator.comparingInt(String::length)
                     .reversed())
    .forEach(System.out::print);
```

A) CGoJavaPython
B) PythonJavaGoC
C) CPythonGoJava
D) JavaPythonGoC

**Answer:** B) PythonJavaGoC
**Explanation:** Sorted by length in reverse (longest first): Python(6), Java(4), Go(2), C(1).

---

## Question 9: Collectors

**What will this code produce?**
```java
List<String> words = Arrays.asList("Java", "Stream", "API");

String result = words.stream()
    .collect(Collectors.joining(", "));

System.out.println(result);
```

A) [Java, Stream, API]
B) Java, Stream, API
C) "Java", "Stream", "API"
D) [JavaStreamAPI]

**Answer:** B) Java, Stream, API
**Explanation:** `joining()` with ", " separator concatenates the strings with that separator.

---

## Question 10: Reduce Operation

**What will this code print?**
```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4);

Optional<Integer> result = numbers.stream()
    .reduce((a, b) -> a + b);

System.out.println(result.get());
```

A) 10
B) 4
C) 1
D) NullPointerException

**Answer:** A) 10
**Explanation:** `reduce()` sums the elements: 1 + 2 + 3 + 4 = 10.

---

## Question 11: Default Methods

**What will this code print?**
```java
public interface A {
    default void method() {
        System.out.println("A");
    }
}

public class B implements A {
    public void method() {
        System.out.println("B");
    }
}

new B().method();
```

A) A
B) B
C) Compilation Error
D) AB

**Answer:** B) B
**Explanation:** Class B overrides the default method, so its implementation is used.

---

## Question 12: Stream Consumption

**How many times will the stream be consumed?**
```java
Stream<Integer> stream = Stream.of(1, 2, 3);

stream.forEach(System.out::println);
stream.forEach(System.out::println);
```

A) Two times
B) Once
C) Compilation Error
D) Runtime Error

**Answer:** D) Runtime Error (IllegalStateException)
**Explanation:** Streams are one-time use. After the first `forEach()`, the stream is consumed and cannot be reused. The second `forEach()` throws an exception.

---

## Scoring Guide

- **11-12 correct:** Excellent! You have mastered Java 8 concepts
- **9-10 correct:** Very Good! You understand most concepts well
- **7-8 correct:** Good! Review the weak areas
- **5-6 correct:** Needs improvement - review the fundamental sections
- **Below 5:** Go back to the notes and practice more

---

## Areas to Review (if needed)

- **Questions 1-2:** Lambda expressions and intermediate operations
- **Questions 3-4:** Optional and method references
- **Questions 5-7:** FlatMap and lazy evaluation
- **Questions 8-9:** Comparators and collectors
- **Questions 10-12:** Reduce, default methods, and stream consumption

