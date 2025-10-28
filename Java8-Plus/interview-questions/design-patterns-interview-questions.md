# Java 8+ Design Patterns - Interview Questions

## Part 1: Behavioral Questions

### Question 1: Tell us about a time you refactored code to use modern Java patterns

**Why they ask:** Assess ability to recognize patterns and apply modernization

**How to answer:**

```
Situation: I had legacy code with 10+ Strategy pattern classes

Task: Refactor to reduce boilerplate and improve maintainability

Action:
1. Identified repetitive interface implementations
2. Converted to functional interfaces with lambdas
3. Reduced 500+ lines of code to 50 lines
4. Improved testability and composability
5. Wrote comprehensive tests

Result:
- 90% boilerplate reduction
- Faster development cycles
- Easier to add new strategies at runtime
- Team adopted pattern across codebase
```

**Sample Answer:**

```
In my previous role, I inherited a payment processing system with separate classes for:
- CreditCardPayment, PayPalPayment, ApplePayPayment, GooglePayPayment

Each class was 30-50 lines of boilerplate. I refactored to:

@FunctionalInterface
interface PaymentStrategy {
    void pay(double amount);
}

PaymentStrategy creditCard = amount ->
    System.out.println("Processing: $" + amount);

This reduced code by 95%, made it easier to test, and allowed runtime registration
of new payment strategies without modifying existing code. The team immediately
adopted this pattern for other parts of the system.
```

---

### Question 2: Describe a situation where you chose not to use a design pattern

**Why they ask:** Test judgment - not all patterns fit all situations

**How to answer:**

```
Acknowledge that patterns aren't always appropriate
- YAGNI: You Aren't Gonna Need It
- Over-engineering is a real problem
- Context matters

Example: When NOT to use Singleton
- In dependency injection containers
- In unit tests (makes mocking hard)
- When multiple instances might be needed later
```

**Sample Answer:**

```
My team wanted to use Singleton for a LoggingService, but I argued against it:

1. Dependency injection is more testable
2. Singletons are hard to mock in unit tests
3. Future requirements might need multiple instances
4. Hidden dependencies make code harder to understand

Instead, we used constructor injection with a single instance at startup.
This gave us the same behavior but with better testability and flexibility.

Lesson: Use patterns when they solve real problems, not just because they're patterns.
```

---

### Question 3: How do you stay updated with evolving Java patterns?

**Why they ask:** Growth mindset, continuous learning

**How to answer:**

```
- Follow Java Enhancement Proposals (JEPs)
- Read about each Java release (every 6 months)
- Practice with new features immediately
- Share knowledge with team
- Contribute to open source
```

**Sample Answer:**

```
1. Read release notes for each Java version (8, 11, 14, 16, 17, 21)
2. Subscribe to Java newsletters (Inside Java, Baeldung)
3. Experiment with new features in side projects
4. When Java 16 added Pattern Matching, I:
   - Read the JEP thoroughly
   - Built test applications
   - Wrote blog post explaining it
   - Shared knowledge with team

This proactive approach means I can immediately apply new patterns
when requirements call for them.
```

---

### Question 4: Tell us about a time you explained a complex pattern to a junior developer

**Why they ask:** Communication and mentoring skills

**How to answer:**

```
Show:
- Patience and clarity
- Breaking down complexity
- Using analogies and examples
- Building on fundamentals
```

**Sample Answer:**

```
A junior developer was confused about when to use different patterns.
I created a decision flowchart:

1. "Do you need to switch between implementations?" → Strategy
2. "Are you adding behavior to objects?" → Decorator
3. "Do you need flexible object creation?" → Factory
4. "Do you need to notify multiple listeners?" → Observer

I then walked through real code examples from our codebase where each pattern was used.
They started recognizing patterns naturally and could suggest them in code reviews within weeks.

The key was relating patterns to concrete problems they were already solving.
```

---

### Question 5: How would you transition a team from traditional to modern Java patterns?

**Why they ask:** Leadership and change management

**How to answer:**

```
- Gradual migration
- Education first
- Show benefits with metrics
- Lead by example
- Build consensus
```

**Sample Answer:**

```
1. Education Phase:
   - Internal workshop on Java 8+ features
   - Real code examples from our codebase
   - Show before/after comparisons

2. Pilot Projects:
   - Start with new features, not refactoring
   - Apply modern patterns in controlled way
   - Document decisions

3. Metrics:
   - Track lines of code reduction
   - Measure test coverage improvement
   - Monitor bug reduction

4. Scaling:
   - Code reviews enforce new patterns
   - Update coding standards
   - Celebrate wins

Result: Team gradually adopted modern patterns, reducing boilerplate by 40%
and improving test coverage from 60% to 85%.
```

---

## Part 2: Technical Questions

### Question 6: When should you use a Functional Interface vs a regular Interface?

**Answer:**

```
Use Functional Interface when:
✅ Single abstract method
✅ Will be used with lambdas
✅ Represents a behavior/action
✅ Examples: Runnable, Callable, Consumer, Function

Use Regular Interface when:
✅ Multiple methods needed
✅ Multiple related behaviors
✅ Not typically used with lambdas
✅ Examples: List, Comparable, Serializable
```

**Code Example:**

```java
// Good - Single responsibility
@FunctionalInterface
interface PaymentProcessor {
    void process(double amount);
}

PaymentProcessor processor = amount ->
    System.out.println("Processing $" + amount);

// Bad - Multiple methods, not functional interface
@FunctionalInterface
interface PaymentService {  // ERROR: can't have multiple methods
    void process(double amount);
    String getTransactionId();
}

// Correct - Use regular interface
interface PaymentService {
    void process(double amount);
    String getTransactionId();
}
```

---

### Question 7: Explain how Records improve upon traditional data classes

**Answer:**

```
Records automatically provide:
✅ Constructor (all fields)
✅ Getters (no "get" prefix)
✅ equals() implementation
✅ hashCode() implementation
✅ toString() implementation
✅ Immutability

Boilerplate reduction: ~90%
```

**Code Example:**

```java
// Traditional - 40+ lines
public class User {
    private final String name;
    private final int age;
    private final String email;

    public User(String name, int age, String email) {
        this.name = name;
        this.age = age;
        this.email = email;
    }

    public String getName() { return name; }
    public int getAge() { return age; }
    public String getEmail() { return email; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return age == user.age &&
            Objects.equals(name, user.name) &&
            Objects.equals(email, user.email);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, age, email);
    }

    @Override
    public String toString() {
        return "User{" + "name='" + name + ", age=" + age +
            ", email='" + email + '}';
    }
}

// Record - 1 line
public record User(String name, int age, String email) {}

// Usage - identical
User user = new User("John", 30, "john@example.com");
System.out.println(user.name()); // John
System.out.println(user); // User[name=John, age=30, email=john@example.com]
```

---

### Question 8: How would you implement Factory Pattern with Java 8+ features?

**Answer:**

```java
// Modern Factory using Map and Supplier
public class DatabaseFactory {
    private static final Map<String, Supplier<Database>> factories =
        new HashMap<>();

    static {
        factories.put("mysql", MySQLDatabase::new);
        factories.put("postgres", PostgresDatabase::new);
        factories.put("mongodb", MongoDatabase::new);
    }

    public static Database create(String type) {
        return factories
            .getOrDefault(type, () -> {
                throw new IllegalArgumentException("Unknown type: " + type);
            })
            .get();
    }

    // Add factories dynamically
    public static void register(String type, Supplier<Database> factory) {
        factories.put(type, factory);
    }
}

// Usage
Database mysql = DatabaseFactory.create("mysql");
Database postgres = DatabaseFactory.create("postgres");

// Runtime registration
DatabaseFactory.register("custom", CustomDatabase::new);
Database custom = DatabaseFactory.create("custom");
```

**Benefits:**
- No new classes for new types
- Easy to add factories at runtime
- Type-safe with generics
- Cleaner than traditional factory pattern

---

### Question 9: What are sealed classes and how do they improve pattern matching?

**Answer:**

```java
// Sealed class restricts who can extend it
public sealed class Shape permits Circle, Rectangle, Triangle {
    public abstract double area();
}

public final class Circle extends Shape {
    private double radius;
    // ...
    @Override
    public double area() { return Math.PI * radius * radius; }
}

public final class Rectangle extends Shape {
    private double width, height;
    // ...
    @Override
    public double area() { return width * height; }
}

public final class Triangle extends Shape {
    private double base, height;
    // ...
    @Override
    public double area() { return (base * height) / 2; }
}

// Pattern Matching - Compiler ensures exhaustiveness
public double calculateArea(Shape shape) {
    return switch (shape) {
        case Circle c -> c.area();
        case Rectangle r -> r.area();
        case Triangle t -> t.area();
        // No default needed - compiler verifies all cases covered
    };
}
```

**Benefits:**
- Compiler verifies exhaustive pattern matching
- No need for `default` case
- Safer code - compiler catches missing cases
- Intent is explicit

---

### Question 10: How do you decide between Strategy pattern and Decorator pattern?

**Answer:**

```
Strategy Pattern:
- Encapsulates algorithms
- Lets algorithm vary independently
- Example: Payment strategies, sorting strategies
- Used for alternative behaviors
- "What algorithm to use?"

Decorator Pattern:
- Adds behavior to objects
- Composes objects dynamically
- Example: Coffee + milk, input + buffering
- Used for enhancement/modification
- "What features to add?"
```

**Code Example:**

```java
// Strategy - Different algorithms
@FunctionalInterface
interface SortStrategy<T> {
    List<T> sort(List<T> items);
}

SortStrategy<Integer> ascending = items ->
    items.stream().sorted().collect(toList());

SortStrategy<Integer> descending = items ->
    items.stream().sorted(Collections.reverseOrder()).collect(toList());

// Decorator - Adding features
interface Coffee {
    double getCost();
    String getDescription();
}

class SimpleCoffee implements Coffee {
    public double getCost() { return 1.0; }
    public String getDescription() { return "Coffee"; }
}

class MilkDecorator implements Coffee {
    private Coffee coffee;
    public MilkDecorator(Coffee coffee) { this.coffee = coffee; }
    public double getCost() { return coffee.getCost() + 0.5; }
    public String getDescription() { return coffee.getDescription() + ", Milk"; }
}

// Usage
Coffee coffee = new MilkDecorator(new SimpleCoffee());
// Coffee, Milk - $1.50
```

---

### Question 11: Explain the Builder Pattern with Consumer composition

**Answer:**

```java
public class HttpRequestBuilder {
    private String url;
    private String method = "GET";
    private Map<String, String> headers = new HashMap<>();
    private Duration timeout = Duration.ofSeconds(60);

    public HttpRequestBuilder url(String url) {
        this.url = url;
        return this;
    }

    public HttpRequestBuilder addHeader(String key, String value) {
        headers.put(key, value);
        return this;
    }

    // Key innovation: Configure with Consumer
    public HttpRequestBuilder configure(
        Consumer<HttpRequestBuilder> config) {
        config.accept(this);
        return this;
    }

    public HttpRequest build() {
        return new HttpRequest(url, method, headers, timeout);
    }
}

// Traditional fluent style
HttpRequest req1 = new HttpRequestBuilder()
    .url("https://api.example.com/users")
    .addHeader("Authorization", "Bearer token")
    .addHeader("Content-Type", "application/json")
    .build();

// Consumer style - cleaner grouping
HttpRequest req2 = new HttpRequestBuilder()
    .url("https://api.example.com/users")
    .configure(builder -> {
        builder.addHeader("Authorization", "Bearer token");
        builder.addHeader("Content-Type", "application/json");
    })
    .build();

// Real-world: Java 11 HttpClient
HttpClient client = HttpClient.newBuilder()
    .version(HttpClient.Version.HTTP_2)
    .connectTimeout(Duration.ofSeconds(10))
    .build();
```

---

### Question 12: How would you implement Chain of Responsibility with modern Java?

**Answer:**

```java
// Functional approach using predicates and handlers
public class RequestChain {
    private List<Predicate<Request>> predicates = new ArrayList<>();
    private List<Consumer<Request>> handlers = new ArrayList<>();

    public RequestChain add(
        Predicate<Request> condition,
        Consumer<Request> handler) {
        predicates.add(condition);
        handlers.add(handler);
        return this;
    }

    public void process(Request request) {
        for (int i = 0; i < predicates.size(); i++) {
            if (predicates.get(i).test(request)) {
                handlers.get(i).accept(request);
                return;
            }
        }
        throw new RequestProcessingException("No handler found");
    }
}

// Usage
RequestChain chain = new RequestChain()
    .add(
        request -> request.needsAuthentication(),
        request -> System.out.println("Authenticating")
    )
    .add(
        request -> request.needsAuthorization(),
        request -> System.out.println("Authorizing")
    )
    .add(
        request -> true, // fallback
        request -> System.out.println("Processing")
    );

chain.process(new Request());
```

---

### Question 13: What's the difference between Optional and null checking?

**Answer:**

```java
// Traditional null checking
String email = user.getEmail();
if (email != null && email.contains("@")) {
    System.out.println("Valid email");
}

// Optional approach
Optional.ofNullable(user.getEmail())
    .filter(email -> email.contains("@"))
    .ifPresent(email -> System.out.println("Valid email"));

// Chaining operations
Optional<String> result = Optional.of("  hello  ")
    .map(String::trim)
    .map(String::toUpperCase)
    .filter(s -> s.length() > 3)
    .flatMap(s -> s.length() > 5 ? Optional.of(s) : Optional.empty());

result.ifPresent(System.out::println);
```

**Benefits of Optional:**
- Forces explicit null handling
- Chainable operations
- Cleaner, more functional code
- Prevents NullPointerException
- Intent is explicit

---

### Question 14: How do you test code that uses lambdas?

**Answer:**

```java
// Functional interface for strategies
@FunctionalInterface
interface PaymentStrategy {
    void process(double amount);
}

// Mock implementation for testing
@Test
public void testPaymentProcessing() {
    List<String> calls = new ArrayList<>();

    PaymentStrategy mockPayment = amount ->
        calls.add("Processing: $" + amount);

    PaymentProcessor processor = new PaymentProcessor(mockPayment);
    processor.pay(100.0);

    assertEquals(1, calls.size());
    assertTrue(calls.get(0).contains("100.0"));
}

// Testing with Mockito
@Test
public void testWithMockito() {
    PaymentStrategy mockStrategy = mock(PaymentStrategy.class);
    PaymentProcessor processor = new PaymentProcessor(mockStrategy);

    processor.pay(100.0);

    verify(mockStrategy).process(100.0);
}

// Testing streams
@Test
public void testStreamProcessing() {
    List<Integer> input = Arrays.asList(1, 2, 3, 4, 5);

    List<Integer> result = input.stream()
        .filter(n -> n % 2 == 0)
        .map(n -> n * 2)
        .collect(Collectors.toList());

    assertEquals(Arrays.asList(4, 8), result);
}
```

---

### Question 15: When should you NOT use the Singleton pattern?

**Answer:**

```
DON'T use Singleton when:
❌ Using dependency injection framework (Spring, Guice, etc.)
❌ In unit tests (hard to mock)
❌ When multiple instances might be needed later
❌ When hidden dependencies are problematic
❌ In multi-threaded systems (subtle issues)

DO use Singleton when:
✅ Single shared resource (connection pool, thread pool)
✅ Stateless utility (logging, configuration)
✅ Not using DI framework
✅ Instance must be globally accessible
✅ Guaranteed single instance

Better alternatives:
1. Dependency Injection (preferred)
2. Enum Singleton (thread-safe)
3. Static methods (for utilities)
4. Factory pattern (more flexible)
```

**Code Example:**

```java
// Bad: Singleton with DI
@Service
public class UserService {
    public static UserService getInstance() { // DI should handle this
        // ...
    }
}

// Good: DI handles singleton scope
@Service
public class UserService {
    @Autowired
    private UserRepository repository;
}

// Best: Enum Singleton
public enum DatabaseConnection {
    INSTANCE;

    private final Connection connection;

    DatabaseConnection() {
        this.connection = getConnection(); // Thread-safe initialization
    }

    public Connection getConnection() {
        return connection;
    }
}

// Usage
DatabaseConnection.INSTANCE.getConnection();
```

---

## Part 3: Architecture & Design Questions

### Question 16: How would you design a payment system using modern Java patterns?

**Answer:**

```java
// Use sealed classes for type safety
public sealed interface PaymentResult permits
    PaymentSuccess, PaymentFailure {}

public record PaymentSuccess(String transactionId, double amount)
    implements PaymentResult {}

public record PaymentFailure(String error, PaymentMethod method)
    implements PaymentResult {}

// Strategy pattern for payment methods
@FunctionalInterface
interface PaymentProcessor {
    PaymentResult process(PaymentMethod method, double amount);
}

// Factory for processors
public class PaymentProcessorFactory {
    private static final Map<String, Supplier<PaymentProcessor>> processors
        = new HashMap<>();

    static {
        processors.put("creditcard", CreditCardProcessor::new);
        processors.put("paypal", PayPalProcessor::new);
        processors.put("applepay", ApplePayProcessor::new);
    }

    public static PaymentProcessor getProcessor(String type) {
        return processors
            .getOrDefault(type, () -> {
                throw new IllegalArgumentException("Unknown processor");
            })
            .get();
    }
}

// Service using all patterns
public class PaymentService {
    public PaymentResult process(PaymentMethod method, double amount) {
        PaymentProcessor processor =
            PaymentProcessorFactory.getProcessor(method.type());

        try {
            return processor.process(method, amount);
        } catch (Exception e) {
            return new PaymentFailure(e.getMessage(), method);
        }
    }
}

// Pattern matching for results
public void handleResult(PaymentResult result) {
    switch (result) {
        case PaymentSuccess(String txId, double amount) ->
            System.out.println("Processed: $" + amount + " ID: " + txId);

        case PaymentFailure(String error, PaymentMethod method) ->
            System.out.println("Failed with " + method + ": " + error);
    }
}
```

---

### Question 17: Design a caching strategy that supports multiple implementations

**Answer:**

```java
// Strategy pattern with decorator composition
@FunctionalInterface
interface CacheStrategy<K, V> {
    V get(K key, Function<K, V> loader);
}

public class InMemoryCache<K, V> implements CacheStrategy<K, V> {
    private final Map<K, V> cache = new ConcurrentHashMap<>();

    @Override
    public V get(K key, Function<K, V> loader) {
        return cache.computeIfAbsent(key, loader);
    }
}

// Decorator for TTL functionality
public class TTLCacheDecorator<K, V> implements CacheStrategy<K, V> {
    private final CacheStrategy<K, V> delegate;
    private final Map<K, Long> timestamps = new ConcurrentHashMap<>();
    private final long ttlMs;

    public TTLCacheDecorator(CacheStrategy<K, V> delegate, long ttlMs) {
        this.delegate = delegate;
        this.ttlMs = ttlMs;
    }

    @Override
    public V get(K key, Function<K, V> loader) {
        long now = System.currentTimeMillis();
        Long timestamp = timestamps.get(key);

        if (timestamp != null && (now - timestamp) > ttlMs) {
            timestamps.remove(key);
        }

        timestamps.putIfAbsent(key, now);
        return delegate.get(key, loader);
    }
}

// Decorator for size limiting
public class LimitedCache<K, V> implements CacheStrategy<K, V> {
    private final CacheStrategy<K, V> delegate;
    private final int maxSize;

    public LimitedCache(CacheStrategy<K, V> delegate, int maxSize) {
        this.delegate = delegate;
        this.maxSize = maxSize;
    }

    @Override
    public V get(K key, Function<K, V> loader) {
        // Size limiting logic
        return delegate.get(key, loader);
    }
}

// Factory pattern for cache creation
public class CacheFactory {
    public static <K, V> CacheStrategy<K, V> createCache(
        CacheType type,
        long ttlMs,
        int maxSize) {

        CacheStrategy<K, V> cache = switch (type) {
            case IN_MEMORY -> new InMemoryCache<>();
            case REDIS -> new RedisCache<>();
            case DISK -> new DiskCache<>();
        };

        // Compose decorators
        cache = new TTLCacheDecorator<>(cache, ttlMs);
        cache = new LimitedCache<>(cache, maxSize);

        return cache;
    }
}

// Usage
CacheStrategy<String, User> cache = CacheFactory.createCache(
    CacheType.IN_MEMORY,
    Duration.ofMinutes(5).toMillis(),
    1000
);

User user = cache.get("user:123", userId ->
    loadUserFromDatabase(userId)
);
```

---

### Question 18: How would you implement an event system using modern Java?

**Answer:**

```java
// Type-safe event system
public sealed interface Event permits UserLoggedIn, UserLoggedOut,
                                       OrderCreated, OrderShipped {}

public record UserLoggedIn(String userId, LocalDateTime timestamp)
    implements Event {}

public record UserLoggedOut(String userId) implements Event {}

public record OrderCreated(String orderId, double amount) implements Event {}

// Event handler
@FunctionalInterface
interface EventHandler<T extends Event> {
    void handle(T event);
}

// Event bus using generics and type safety
public class EventBus {
    private final Map<Class<?>, List<EventHandler<?>>> handlers =
        new ConcurrentHashMap<>();

    @SuppressWarnings("unchecked")
    public <T extends Event> void subscribe(
        Class<T> eventType,
        EventHandler<T> handler) {
        handlers
            .computeIfAbsent(eventType, k -> new CopyOnWriteArrayList<>())
            .add(handler);
    }

    @SuppressWarnings("unchecked")
    public <T extends Event> void publish(T event) {
        List<EventHandler<?>> list =
            handlers.getOrDefault(event.getClass(), new ArrayList<>());

        list.stream()
            .map(h -> (EventHandler<T>) h)
            .forEach(h -> h.handle(event));
    }
}

// Usage
EventBus eventBus = new EventBus();

// Subscribe to events
eventBus.subscribe(UserLoggedIn.class, event ->
    System.out.println("User logged in: " + event.userId())
);

eventBus.subscribe(OrderCreated.class, event ->
    System.out.println("Order created: $" + event.amount())
);

// Publish events
eventBus.publish(new UserLoggedIn("user123", LocalDateTime.now()));
eventBus.publish(new OrderCreated("order456", 99.99));
```

---

## Summary

### Key Interview Takeaways

1. **Patterns are tools, not rules** - Use them when they solve real problems
2. **Modern Java simplifies patterns** - Lambdas, records, sealed classes reduce boilerplate
3. **Functional approach is powerful** - Composition over inheritance
4. **Type safety is important** - Use sealed classes, pattern matching, records
5. **Test-driven design** - Patterns should be testable and mockable
6. **Context matters** - No one-size-fits-all solution

### Common Interview Mistakes to Avoid

❌ Over-engineering with patterns
❌ Not understanding when NOT to use a pattern
❌ Using traditional approaches for Java 8+ code
❌ Ignoring testability when applying patterns
❌ Not explaining trade-offs

### Strong Interview Answers Include

✅ Real-world examples from your experience
✅ Before/after code comparisons
✅ Explanation of trade-offs
✅ Understanding when NOT to use pattern
✅ Discussion of team/project context
✅ Metrics or benefits achieved

---

**Last Updated:** October 26, 2024
**Level:** Intermediate to Expert
**Total Questions:** 18
**Difficulty:** Behavioral + Technical + Architecture
**Estimated Interview Prep Time:** 4-6 hours
