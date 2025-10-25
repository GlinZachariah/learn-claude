# Java 8+ Interview Questions

Comprehensive interview questions covering Java 8 and modern Java features.

---

## Question 1: Lambda Expressions and Performance

**Question:** "In your experience, how do lambda expressions impact performance compared to anonymous inner classes?"

**Suggested Answer:**

Lambda expressions are **syntactic sugar** compiled into anonymous inner classes, so performance is similar. However:

**Advantages:**
1. **Better Optimization** - The JVM can optimize lambdas more effectively
2. **Smaller Code** - Less bytecode generated compared to full class definition
3. **Inlining** - JVM can inline lambda calls more easily

**Example:**
```java
// Anonymous inner class
Runnable r1 = new Runnable() {
    @Override
    public void run() {
        System.out.println("Hello");
    }
};

// Lambda - compiled similarly but with better optimization opportunities
Runnable r2 = () -> System.out.println("Hello");
```

**Points to mention:**
- Lambdas use invokedynamic bytecode instruction
- This allows flexible implementation strategies
- JVM team can improve performance without changing source code
- No significant performance difference for most use cases

**Related Topics:** Anonymous classes, invokedynamic, JVM optimization

---

## Question 2: Streams vs Collections - When to Use Each

**Question:** "When would you use streams instead of traditional collections iteration, and are there situations where collections are better?"

**Suggested Answer:**

**Use Streams when:**
1. **Chaining operations** - Multiple transformations (filter, map, etc.)
2. **Functional operations** - Using predicates, functions
3. **Conciseness** - Code is cleaner and more readable
4. **Parallel processing** - Built-in parallelization with `parallelStream()`

```java
// Streams - elegant and readable
List<String> uppercase = names.stream()
    .filter(n -> n.length() > 3)
    .map(String::toUpperCase)
    .collect(Collectors.toList());
```

**Use Collections when:**
1. **Simple iterations** - Just looping through items
2. **Multiple passes** - Need to iterate multiple times
3. **Reusability** - Need to keep data for later use
4. **Performance critical** - Some overhead with streams

```java
// Collections - good for simple iteration
List<String> names = new ArrayList<>();
for (String name : people) {
    names.add(name);
}
```

**Key Differences:**
| Aspect | Stream | Collection |
|--------|--------|-----------|
| Iteration | One-time | Reusable |
| Evaluation | Lazy | Eager |
| Functional | Yes | No |
| Parallel | Easy | Complex |

**Experience to share:** "I use streams when I have multiple operations to chain. For simple iterations, I still use collections or for-each loops for clarity."

---

## Question 3: Optional - Null Handling Best Practices

**Question:** "How do you use Optional effectively in production code? What are common mistakes?"

**Suggested Answer:**

**Best Practices:**

```java
// DO: Use Optional for return types
public Optional<User> findUserById(int id) {
    return userRepository.findById(id);
}

// DON'T: Use Optional for optional parameters
// Instead, use method overloading or builder pattern
public void processUser(User user) { } // Good
// public void processUser(Optional<User> user) { } // Avoid

// DO: Chain operations
Optional<String> email = findUser(id)
    .map(User::getEmail)
    .filter(e -> e.contains("@"))
    .map(String::toUpperCase);

// DON'T: Check isPresent() every time
// if (email.isPresent()) { /* use email */ }

// DO: Use ifPresent or ifPresentOrElse
email.ifPresent(System.out::println);
email.ifPresentOrElse(
    System.out::println,
    () -> System.out.println("No email")
);

// DO: Use orElse or orElseThrow
String result = email.orElse("unknown@example.com");
String result2 = email.orElseThrow(() ->
    new IllegalStateException("Email required")
);

// DON'T: Optional.get() without checking
// email.get(); // Can throw NoSuchElementException
```

**Common Mistakes:**
1. Using Optional for parameters
2. Using `get()` without checking
3. Using `isPresent()` instead of functional methods
4. Using Optional for collections (use empty list instead)

**Real-world example:**
```java
// Good - handle absence gracefully
public String getUserEmail(int id) {
    return findUserById(id)
        .map(User::getEmail)
        .orElse("no-email@example.com");
}
```

---

## Question 4: Stream Intermediate vs Terminal Operations

**Question:** "Explain the difference between intermediate and terminal operations in streams, and why does it matter?"

**Suggested Answer:**

**Intermediate Operations:**
- Return a Stream
- Lazy - not executed until terminal operation
- Can be chained

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Nothing happens here
numbers.stream()
    .filter(n -> n > 2)
    .map(n -> n * 2);
```

**Terminal Operations:**
- Return a non-Stream result (or void)
- Trigger execution of entire pipeline
- End the stream

```java
// Terminal operation triggers execution
numbers.stream()
    .filter(n -> n > 2)
    .map(n -> n * 2)
    .forEach(System.out::println); // Terminal
```

**Why It Matters:**

1. **Performance** - Operations only compute what's needed
2. **Short-circuiting** - Some terminals stop early (findFirst, limit)
3. **One-time use** - Stream can't be reused after terminal operation

```java
Stream<Integer> stream = numbers.stream();

stream.forEach(System.out::println);      // OK
// stream.forEach(System.out::println);  // ERROR - stream consumed
```

**Real-world impact:**
```java
// Inefficient - creates multiple streams
numbers.stream().filter(n -> n > 2).count();
numbers.stream().map(n -> n * 2).forEach(...);

// Better - single stream
numbers.stream()
    .filter(n -> n > 2)
    .forEach(n -> {
        System.out.println(n * 2);
        count++;
    });
```

---

## Question 5: FlatMap Use Cases

**Question:** "Give me a real-world scenario where you'd use flatMap instead of map."

**Suggested Answer:**

**Scenario 1: Multiple relationships**
```java
// Finding all orders for all customers
record Customer(int id, List<Order> orders) {}
record Order(int id, String description) {}

List<Customer> customers = getCustomers();

// flatMap - unwrap each customer's orders into single stream
List<Order> allOrders = customers.stream()
    .flatMap(c -> c.orders().stream())
    .collect(Collectors.toList());

// vs map - would give List<List<Order>>
List<List<Order>> nested = customers.stream()
    .map(Customer::orders)
    .collect(Collectors.toList());
```

**Scenario 2: Multiple search results**
```java
// Finding files in multiple directories
List<String> directories = Arrays.asList("/home", "/opt", "/var");

// Get all files flattened
List<String> files = directories.stream()
    .flatMap(dir -> Files.list(Paths.get(dir)))
    .map(Path::toString)
    .collect(Collectors.toList());
```

**Scenario 3: Optional unwrapping**
```java
List<Optional<String>> optionals = Arrays.asList(
    Optional.of("A"),
    Optional.empty(),
    Optional.of("B")
);

// Unwrap optionals
List<String> values = optionals.stream()
    .flatMap(Optional::stream)  // Java 9+
    .collect(Collectors.toList());
// Result: [A, B]
```

**Key insight:** "Use flatMap when your mapping function returns a Stream (or Optional) and you want to flatten the result into a single stream."

---

## Question 6: Collectors.groupingBy with Custom Logic

**Question:** "How would you group items by a property and apply custom logic to each group?"

**Suggested Answer:**

```java
record Employee(String department, String name, double salary) {}

List<Employee> employees = getEmployees();

// Simple grouping
Map<String, List<Employee>> byDept = employees.stream()
    .collect(Collectors.groupingBy(Employee::department));

// Counting in each group
Map<String, Long> deptSizes = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::department,
        Collectors.counting()
    ));

// Sum salaries per department
Map<String, Double> deptBudgets = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::department,
        Collectors.summingDouble(Employee::salary)
    ));

// Get highest salary employee in each department
Map<String, Optional<Employee>> deptLeads = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::department,
        Collectors.maxBy(
            Comparator.comparingDouble(Employee::salary)
        )
    ));

// Complex: Map department to names string
Map<String, String> deptNames = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::department,
        Collectors.mapping(
            Employee::name,
            Collectors.joining(", ")
        )
    ));
```

**Real-world application:** Product analytics, sales reporting, resource allocation.

---

## Question 7: Default Methods and Interface Evolution

**Question:** "Why were default methods introduced, and what challenges do they present?"

**Suggested Answer:**

**Why Introduced:**
The Java Collections API needed to evolve without breaking millions of existing implementations.

```java
// Before Java 8, adding method to interface broke all implementations
public interface Collection<E> {
    // Adding this would break all implementations
    default Stream<E> stream() {
        return StreamSupport.stream(spliterator(), false);
    }
}
```

**Benefits:**
1. **Backward compatibility** - Add methods without breaking implementations
2. **Mixin behavior** - Share utility methods
3. **Graceful evolution** - Interfaces can grow

**Challenges:**

1. **Diamond problem** - Multiple inheritance of same method
```java
interface A { default void method() { print("A"); } }
interface B { default void method() { print("B"); } }

class C implements A, B { } // Compilation error - ambiguity

// Solution: Override in implementing class
class C implements A, B {
    @Override
    public void method() {
        A.super.method(); // Call A's version
    }
}
```

2. **Breaks encapsulation** - Implementation details exposed
3. **Confusion** - Developers might forget method exists

**Best Practices:**
```java
// DO: Use for common utility methods
public interface Vehicle {
    void drive();

    default void honk() {
        System.out.println("Honk!");
    }
}

// DON'T: Add abstract methods as defaults without thought
// DON'T: Make abstract methods default just to avoid implementation
```

---

## Question 8: Stream Performance Considerations

**Question:** "What performance considerations should I keep in mind when using streams?"

**Suggested Answer:**

**When streams are efficient:**
```java
// Good: Chain multiple operations
List<String> result = largeList.stream()
    .filter(s -> s.length() > 3)
    .map(String::toUpperCase)
    .limit(100)
    .collect(Collectors.toList());
```

**When streams might be slow:**

1. **Boxing/Unboxing** - Use primitive streams
```java
// Slow - objects
List<Integer> integers = Arrays.asList(1, 2, 3);
int sum = integers.stream().reduce(0, Integer::sum);

// Fast - primitive stream
int sum = IntStream.of(1, 2, 3).sum();
```

2. **Unnecessary sorting** - Avoid if not needed
```java
// Slow - sorts entire stream
list.stream().sorted().limit(10)...

// Better - use Collections.sort if appropriate
```

3. **Large intermediate collections**
```java
// Might create large intermediate list
list.stream()
    .flatMap(...)
    .flatMap(...)
    .collect(Collectors.toList());
```

4. **Parallel streams overhead** - Only for large datasets
```java
// Overhead might outweigh benefits for small lists
smallList.parallelStream(); // Probably slower

// Good for large datasets
largeList.parallelStream(); // Likely faster
```

**Optimization techniques:**
```java
// Use peek() for debugging, remove in production
// Use short-circuit operations (findFirst, limit)
// Choose appropriate collectors
// Use primitive streams for primitives
// Use parallelStream() for large datasets (>10K items)
```

---

## Question 9: Comparing Records and Data Classes

**Question:** "How do records improve upon traditional Java classes?"

**Suggested Answer:**

**Traditional Class:**
```java
public class Person {
    private final String name;
    private final int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String name() { return name; }
    public int age() { return age; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Person)) return false;
        Person person = (Person) o;
        return age == person.age && name.equals(person.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, age);
    }

    @Override
    public String toString() {
        return "Person{" + "name='" + name + '\'' +
               ", age=" + age + '}';
    }
}
```

**With Record:**
```java
record Person(String name, int age) {}
// All of the above automatically generated!
```

**Benefits:**
1. **Less boilerplate** - No manual getters, equals, hashCode, toString
2. **Intent clear** - Obviously a data carrier
3. **Immutability** - Enforced by design
4. **Canonical constructor** - Simple validation

**Limitations:**
```java
// Can't extend records
// record Person(String name) extends Entity {} // ERROR

// Can't add instance fields
record Person(String name) {
    // int age; // ERROR - not allowed
}

// Can customize with explicit constructor
record Point(int x, int y) {
    public Point {  // Compact constructor
        if (x < 0 || y < 0) {
            throw new IllegalArgumentException();
        }
    }
}
```

---

## Question 10: Virtual Threads and the Future of Concurrency

**Question:** "What are virtual threads in Java 21, and how do they change concurrent programming?"

**Suggested Answer:**

**Problem they solve:**
Traditional platform threads are expensive:
- Limited number (OS resources)
- Large memory footprint (1MB+ per thread)
- Context switching overhead

**Virtual Threads:**
- Lightweight threads (thousands or millions)
- Managed by JVM
- Non-blocking I/O compatible

```java
// Java 19+
// Traditional thread
Thread thread = new Thread(() -> {
    System.out.println("Hello from platform thread");
}).start();

// Virtual thread
Thread vthread = Thread.ofVirtual()
    .name("virtual-worker")
    .start(() -> {
        System.out.println("Hello from virtual thread");
    });

// With ExecutorService
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
for (int i = 0; i < 1_000_000; i++) {
    executor.submit(() -> {
        // This is now feasible - 1M virtual threads!
        System.out.println("Task " + i);
    });
}
```

**Impact:**
1. **Simplified concurrency** - No need for complex async frameworks
2. **Scalability** - Handle millions of concurrent operations
3. **Debugging** - Simpler stack traces
4. **Legacy code** - Thread pools become optional

**Limitations:**
- Pinned to platform thread if holding lock or running native code
- Not suitable for CPU-bound tasks (use regular threads)
- Still evolving (preview feature in Java 19)

---

## Question 11: What Would You Improve in Java?

**Question:** "If you could add one feature to Java, what would it be and why?"

**Suggested Answer Options:**

**Option 1: Non-nullable types**
```java
// Wouldn't need:
if (obj != null) { }

// Compiler would help prevent NPE
public String getName(String notNullName) { }
```

**Option 2: Better generics with specialization**
```java
// Remove boxing overhead
List<int> intList = new ArrayList<>(); // Not possible now
```

**Option 3: Pattern matching expansion**
```java
// Already improving in Java 16+
if (obj instanceof String(var len) && len > 5) { }
```

**Option 4: Coroutines or structured concurrency**
```java
// Better async/await style programming
```

**Strong answer format:**
"I would improve [feature] because [problem it solves]. This would help with [use case]."

---

## Behavioral Question

**Question:** "Tell me about a time you had to debug a complex stream pipeline. What went wrong and how did you fix it?"

**Suggested Answer Framework:**

1. **Situation:** Describe the scenario
   - "We were processing millions of records in our data pipeline using streams..."

2. **Problem:** What went wrong
   - "The pipeline was producing incorrect results..."
   - "Performance was unexpectedly slow..."

3. **Investigation:** How you debugged
   - "I used peek() to understand data flow"
   - "I added logging at each stage"
   - "I compared with non-stream implementation"

4. **Solution:** What you did
   - "Realized we needed to use flatMap instead of map"
   - "Switched to primitive streams to avoid boxing"
   - "Changed to parallel stream for large datasets"

5. **Learning:** What you learned
   - "Better understanding of lazy evaluation"
   - "Importance of performance testing streams"

---

## System Design Related Question

**Question:** "Design a service that processes millions of events. Which Java features would you use?"

**Suggested Answer:**

```java
// Virtual threads for handling connections
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

// Streams for data processing
events.parallelStream()
    .filter(e -> e.isValid())
    .map(Event::process)
    .collect(Collectors.groupingBy(
        Result::category,
        Collectors.summarizingDouble(Result::value)
    ));

// Records for data transfer
record Event(String id, String data, long timestamp) {}
record Result(String category, double value) {}

// Optional for safe null handling
Optional<Event> event = eventRepository.findById(id);
```

**Considerations:**
- Virtual threads for I/O
- Parallel streams for CPU-bound processing
- Collectors for aggregation
- Records for immutable data
- Optional for null safety

---

## Summary of Key Interview Takeaways

1. **Streams** - Understand lazy evaluation, intermediate vs terminal operations
2. **Optional** - Proper null handling patterns
3. **Functional Programming** - Lambdas, method references, functional interfaces
4. **Records** - Modern immutable data classes
5. **Performance** - Know when streams help and when they hurt
6. **Design** - Choose right tool for the job (streams vs collections)
7. **Real-world** - Have concrete examples from your experience

