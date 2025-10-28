# Design Patterns in Java 8+ - Modern Approaches

## Overview

Java 8+ introduced functional programming features that revolutionized how classic design patterns are implemented. This chapter explores how traditional Gang of Four patterns have evolved with lambdas, streams, and modern Java features.

**Key Paradigm Shift:** From object-oriented to functional-first approaches while maintaining backward compatibility.

---

## Part 1: Builder Pattern (Fluent API with Lambdas)

### Traditional Builder Pattern

```java
// Without lambdas - verbose
HttpRequest request = new HttpRequest.Builder()
    .url("https://api.example.com/users")
    .method("GET")
    .header("Authorization", "Bearer token123")
    .header("Content-Type", "application/json")
    .timeout(Duration.ofSeconds(30))
    .build();
```

### Enhanced Builder with Consumer Pattern

```java
// Builder with Consumer for cleaner API
public class HttpRequestBuilder {
    private String url;
    private String method = "GET";
    private Map<String, String> headers = new HashMap<>();
    private Duration timeout = Duration.ofSeconds(60);

    public HttpRequestBuilder url(String url) {
        this.url = url;
        return this;
    }

    public HttpRequestBuilder method(String method) {
        this.method = method;
        return this;
    }

    public HttpRequestBuilder addHeader(String key, String value) {
        headers.put(key, value);
        return this;
    }

    public HttpRequestBuilder timeout(Duration duration) {
        this.timeout = duration;
        return this;
    }

    // Configure with lambda/consumer
    public HttpRequestBuilder configure(Consumer<HttpRequestBuilder> config) {
        config.accept(this);
        return this;
    }

    public HttpRequest build() {
        return new HttpRequest(url, method, headers, timeout);
    }
}

// Usage with lambda
HttpRequest request = new HttpRequestBuilder()
    .url("https://api.example.com/users")
    .configure(builder -> {
        builder.addHeader("Authorization", "Bearer token123");
        builder.addHeader("Content-Type", "application/json");
        builder.timeout(Duration.ofSeconds(30));
    })
    .build();

// Or traditional fluent style
HttpRequest request2 = new HttpRequestBuilder()
    .url("https://api.example.com/users")
    .addHeader("Authorization", "Bearer token123")
    .addHeader("Content-Type", "application/json")
    .timeout(Duration.ofSeconds(30))
    .build();
```

### Real-World Example: Java 11 HttpClient

```java
// Java 11+ HttpClient uses Builder pattern
HttpClient client = HttpClient.newBuilder()
    .version(HttpClient.Version.HTTP_2)
    .connectTimeout(Duration.ofSeconds(10))
    .executor(ForkJoinPool.commonPool())
    .build();

HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://api.example.com/users"))
    .timeout(Duration.ofSeconds(30))
    .header("Authorization", "Bearer token")
    .POST(HttpRequest.BodyPublishers.ofString("{\"name\": \"John\"}"))
    .build();

// Send with lambda callback
client.sendAsync(request, HttpResponse.BodyHandlers.ofString())
    .thenApply(HttpResponse::body)
    .thenAccept(System.out::println)
    .join();
```

### Builder with Method Reference Composition

```java
public class RequestBuilder {
    private List<Consumer<HttpRequestBuilder>> configs = new ArrayList<>();

    public RequestBuilder add(Consumer<HttpRequestBuilder> config) {
        configs.add(config);
        return this;
    }

    public HttpRequest build(String baseUrl) {
        HttpRequestBuilder builder = new HttpRequestBuilder().url(baseUrl);

        // Apply all configurations in order
        configs.forEach(config -> config.accept(builder));

        return builder.build();
    }
}

// Composable builder
RequestBuilder requestBuilder = new RequestBuilder()
    .add(b -> b.addHeader("Authorization", "Bearer token"))
    .add(b -> b.addHeader("Content-Type", "application/json"))
    .add(b -> b.timeout(Duration.ofSeconds(30)))
    .add(b -> b.method("POST"));

HttpRequest request = requestBuilder.build("https://api.example.com/users");
```

---

## Part 2: Strategy Pattern with Lambdas

### Traditional Strategy Pattern

```java
// Old way with interfaces
interface PaymentStrategy {
    void pay(double amount);
}

class CreditCardPayment implements PaymentStrategy {
    @Override
    public void pay(double amount) {
        System.out.println("Paying " + amount + " via credit card");
    }
}

class PayPalPayment implements PaymentStrategy {
    @Override
    public void pay(double amount) {
        System.out.println("Paying " + amount + " via PayPal");
    }
}

PaymentStrategy strategy = new CreditCardPayment();
strategy.pay(100.0);
```

### Modern Strategy with Lambdas and Functional Interface

```java
// Functional interface for strategies
@FunctionalInterface
interface PaymentStrategy {
    void pay(double amount);
}

// Using lambdas - no need for multiple classes
PaymentStrategy creditCard = amount -> System.out.println("Paying " + amount + " via credit card");
PaymentStrategy paypal = amount -> System.out.println("Paying " + amount + " via PayPal");
PaymentStrategy applePay = amount -> System.out.println("Paying " + amount + " via Apple Pay");

// Switch strategies at runtime
public class PaymentProcessor {
    private PaymentStrategy strategy;

    public void setPaymentStrategy(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public void processPayment(double amount) {
        strategy.pay(amount);
    }
}

// Usage
PaymentProcessor processor = new PaymentProcessor();
processor.setPaymentStrategy(creditCard);
processor.processPayment(100.0);

processor.setPaymentStrategy(paypal);
processor.processPayment(50.0);
```

### Advanced Strategy with Result Handling

```java
// Strategy that returns a result
@FunctionalInterface
interface ValidationStrategy<T, R> {
    R validate(T input);
}

public class DataValidator {
    private List<ValidationStrategy<String, Boolean>> strategies = new ArrayList<>();

    public DataValidator addStrategy(ValidationStrategy<String, Boolean> strategy) {
        strategies.add(strategy);
        return this;
    }

    public boolean validate(String data) {
        return strategies.stream()
            .allMatch(strategy -> strategy.validate(data));
    }
}

// Usage
DataValidator validator = new DataValidator()
    .addStrategy(input -> !input.isEmpty()) // not empty
    .addStrategy(input -> input.length() <= 100) // length check
    .addStrategy(input -> input.matches("^[a-zA-Z0-9_]*$")); // alphanumeric only

boolean isValid = validator.validate("validUsername123");
```

---

## Part 3: Factory Pattern Enhanced with Java 8+

### Traditional Factory Pattern

```java
// Old factory pattern
interface Database {
    void connect(String url);
    void query(String sql);
}

class MySQLDatabase implements Database {
    @Override
    public void connect(String url) {
        System.out.println("Connecting to MySQL: " + url);
    }

    @Override
    public void query(String sql) {
        System.out.println("Executing MySQL query: " + sql);
    }
}

class PostgresDatabase implements Database {
    @Override
    public void connect(String url) {
        System.out.println("Connecting to Postgres: " + url);
    }

    @Override
    public void query(String sql) {
        System.out.println("Executing Postgres query: " + sql);
    }
}

class DatabaseFactory {
    public static Database create(String type) {
        switch (type) {
            case "mysql": return new MySQLDatabase();
            case "postgres": return new PostgresDatabase();
            default: throw new IllegalArgumentException("Unknown type");
        }
    }
}
```

### Modern Factory with Lambdas and Map

```java
// Functional factory using Map
public class DatabaseFactory {
    private static final Map<String, Supplier<Database>> factories = new HashMap<>();

    static {
        // Register factories as lambdas
        factories.put("mysql", MySQLDatabase::new);
        factories.put("postgres", PostgresDatabase::new);
        factories.put("mongodb", MongoDatabase::new);
    }

    public static Database create(String type) {
        return factories
            .getOrDefault(type, () -> {
                throw new IllegalArgumentException("Unknown database type: " + type);
            })
            .get();
    }

    // Add factory dynamically
    public static void registerFactory(String type, Supplier<Database> factory) {
        factories.put(type, factory);
    }
}

// Usage
Database db1 = DatabaseFactory.create("mysql");
Database db2 = DatabaseFactory.create("postgres");

// Register custom factory at runtime
DatabaseFactory.registerFactory("custom", () -> new CustomDatabase());
```

### Generic Factory with Type Mapping

```java
// Generic factory pattern
public class GenericFactory<T> {
    private final Map<String, Supplier<? extends T>> creators = new HashMap<>();

    public void register(String type, Supplier<? extends T> creator) {
        creators.put(type, creator);
    }

    public T create(String type) {
        return creators
            .getOrDefault(type, () -> {
                throw new IllegalArgumentException("Unknown type: " + type);
            })
            .get();
    }

    public static <T> GenericFactory<T> of(Class<T> type) {
        return new GenericFactory<>();
    }
}

// Usage
GenericFactory<Database> dbFactory = GenericFactory.of(Database.class);
dbFactory.register("mysql", MySQLDatabase::new);
dbFactory.register("postgres", PostgresDatabase::new);

Database db = dbFactory.create("mysql");
```

---

## Part 4: Decorator Pattern with Lambdas

### Traditional Decorator

```java
// Without lambdas
interface Coffee {
    double getCost();
    String getDescription();
}

class SimpleCoffee implements Coffee {
    @Override
    public double getCost() { return 1.0; }
    @Override
    public String getDescription() { return "Simple Coffee"; }
}

abstract class CoffeeDecorator implements Coffee {
    protected Coffee coffee;
    protected CoffeeDecorator(Coffee coffee) { this.coffee = coffee; }
}

class Milk extends CoffeeDecorator {
    public Milk(Coffee coffee) { super(coffee); }
    @Override
    public double getCost() { return coffee.getCost() + 0.5; }
    @Override
    public String getDescription() { return coffee.getDescription() + ", Milk"; }
}

Coffee coffee = new Milk(new SimpleCoffee());
```

### Modern Decorator with Functional Composition

```java
// Functional approach using Function composition
@FunctionalInterface
interface CoffeeDecorator {
    Coffee decorate(Coffee coffee);
}

// Decorators as lambdas
CoffeeDecorator addMilk = coffee -> new DecoratedCoffee(
    coffee,
    () -> coffee.getCost() + 0.5,
    () -> coffee.getDescription() + ", Milk"
);

CoffeeDecorator addSugar = coffee -> new DecoratedCoffee(
    coffee,
    () -> coffee.getCost() + 0.2,
    () -> coffee.getDescription() + ", Sugar"
);

CoffeeDecorator addWhippedCream = coffee -> new DecoratedCoffee(
    coffee,
    () -> coffee.getCost() + 0.7,
    () -> coffee.getDescription() + ", Whipped Cream"
);

// Composable decorators
Coffee coffee = addMilk
    .decorate(addSugar
        .decorate(addWhippedCream
            .decorate(new SimpleCoffee())));
```

### Decorator with Stream API

```java
// Composable decorators using streams
List<Function<Coffee, Coffee>> decorators = Arrays.asList(
    coffee -> new DecoratedCoffee(coffee,
        () -> coffee.getCost() + 0.5,
        () -> coffee.getDescription() + ", Milk"),

    coffee -> new DecoratedCoffee(coffee,
        () -> coffee.getCost() + 0.2,
        () -> coffee.getDescription() + ", Sugar"),

    coffee -> new DecoratedCoffee(coffee,
        () -> coffee.getCost() + 0.7,
        () -> coffee.getDescription() + ", Whipped Cream")
);

// Apply all decorators
Coffee finalCoffee = decorators.stream()
    .reduce(
        Function.identity(),
        Function::andThen
    )
    .apply(new SimpleCoffee());
```

---

## Part 5: Observer Pattern with Event Streams

### Traditional Observer

```java
// Old Observer pattern
interface Observer {
    void update(String event);
}

class EventPublisher {
    private List<Observer> observers = new ArrayList<>();

    public void subscribe(Observer observer) {
        observers.add(observer);
    }

    public void notify(String event) {
        observers.forEach(observer -> observer.update(event));
    }
}

EventPublisher publisher = new EventPublisher();
publisher.subscribe(event -> System.out.println("Listener 1: " + event));
publisher.subscribe(event -> System.out.println("Listener 2: " + event));
```

### Modern Observer with Functional Interfaces

```java
// Functional observer
@FunctionalInterface
interface EventListener {
    void onEvent(String event);
}

public class EventBus {
    private Map<String, List<EventListener>> listeners = new HashMap<>();

    public void subscribe(String eventType, EventListener listener) {
        listeners
            .computeIfAbsent(eventType, k -> new ArrayList<>())
            .add(listener);
    }

    public void publish(String eventType, String event) {
        listeners
            .getOrDefault(eventType, new ArrayList<>())
            .forEach(listener -> listener.onEvent(event));
    }
}

// Usage
EventBus eventBus = new EventBus();
eventBus.subscribe("user.created", event -> System.out.println("User created: " + event));
eventBus.subscribe("user.deleted", event -> System.out.println("User deleted: " + event));

eventBus.publish("user.created", "userId:123");
```

### Observer with Reactive Streams

```java
// Reactive observer using callbacks
public class ReactiveEventBus {
    private List<Consumer<String>> onNextListeners = new ArrayList<>();
    private List<Consumer<Exception>> onErrorListeners = new ArrayList<>();
    private List<Runnable> onCompleteListeners = new ArrayList<>();

    public void subscribe(Consumer<String> onNext) {
        onNextListeners.add(onNext);
    }

    public void onError(Consumer<Exception> handler) {
        onErrorListeners.add(handler);
    }

    public void onComplete(Runnable handler) {
        onCompleteListeners.add(handler);
    }

    public void emit(String event) {
        onNextListeners.forEach(listener -> listener.accept(event));
    }

    public void error(Exception exception) {
        onErrorListeners.forEach(listener -> listener.accept(exception));
    }

    public void complete() {
        onCompleteListeners.forEach(Runnable::run);
    }
}

// Usage
ReactiveEventBus bus = new ReactiveEventBus();
bus.subscribe(event -> System.out.println("Received: " + event));
bus.onError(error -> System.err.println("Error: " + error.getMessage()));
bus.onComplete(() -> System.out.println("Stream completed"));

bus.emit("Event 1");
bus.emit("Event 2");
bus.complete();
```

---

## Part 6: Chain of Responsibility with Functional Composition

### Traditional Chain of Responsibility

```java
// Old way
abstract class Handler {
    protected Handler nextHandler;

    public void setNext(Handler next) {
        this.nextHandler = next;
    }

    public void handle(Request request) {
        if (canHandle(request)) {
            processRequest(request);
        } else if (nextHandler != null) {
            nextHandler.handle(request);
        }
    }

    protected abstract boolean canHandle(Request request);
    protected abstract void processRequest(Request request);
}

class AuthenticationHandler extends Handler {
    @Override
    protected boolean canHandle(Request request) {
        return request.needsAuthentication();
    }

    @Override
    protected void processRequest(Request request) {
        System.out.println("Authenticating request");
    }
}
```

### Modern Chain with Lambdas

```java
// Functional approach
@FunctionalInterface
interface RequestHandler {
    boolean handle(Request request);
}

public class RequestChain {
    private List<RequestHandler> handlers = new ArrayList<>();

    public RequestChain addHandler(RequestHandler handler) {
        handlers.add(handler);
        return this;
    }

    public void process(Request request) {
        handlers.stream()
            .dropWhile(handler -> !handler.handle(request))
            .findFirst()
            .orElseThrow(() -> new RequestProcessingException("No handler found"));
    }
}

// Usage
RequestChain chain = new RequestChain()
    .addHandler(request -> {
        if (request.needsAuthentication()) {
            System.out.println("Authenticating");
            return true;
        }
        return false;
    })
    .addHandler(request -> {
        if (request.needsAuthorization()) {
            System.out.println("Authorizing");
            return true;
        }
        return false;
    })
    .addHandler(request -> {
        System.out.println("Processing request");
        return true;
    });

chain.process(new Request());
```

### Chain with Predicate Composition

```java
// Predicate-based chain
public class PredicateChain<T> {
    private List<Predicate<T>> predicates = new ArrayList<>();
    private List<Consumer<T>> actions = new ArrayList<>();

    public PredicateChain<T> add(Predicate<T> predicate, Consumer<T> action) {
        predicates.add(predicate);
        actions.add(action);
        return this;
    }

    public void execute(T input) {
        for (int i = 0; i < predicates.size(); i++) {
            if (predicates.get(i).test(input)) {
                actions.get(i).accept(input);
                return;
            }
        }
        throw new IllegalStateException("No matching predicate found");
    }
}

// Usage
PredicateChain<Integer> chain = new PredicateChain<Integer>()
    .add(n -> n < 0, n -> System.out.println("Negative number: " + n))
    .add(n -> n == 0, n -> System.out.println("Zero"))
    .add(n -> n > 0, n -> System.out.println("Positive number: " + n));

chain.execute(5);
```

---

## Part 7: Template Method Pattern with Lambdas

### Traditional Template Method

```java
// Old way with abstract class
abstract class DataProcessor {
    public final void process(String data) {
        String cleaned = clean(data);
        String validated = validate(cleaned);
        String transformed = transform(validated);
        save(transformed);
    }

    protected abstract String clean(String data);
    protected abstract String validate(String data);
    protected abstract String transform(String data);
    protected abstract void save(String data);
}

class CsvProcessor extends DataProcessor {
    @Override
    protected String clean(String data) { return data.trim(); }
    @Override
    protected String validate(String data) { return data; }
    @Override
    protected String transform(String data) { return data.toUpperCase(); }
    @Override
    protected void save(String data) { System.out.println("Saved: " + data); }
}
```

### Modern Template Method with Functions

```java
// Functional approach
public class TemplateProcessor {
    private Function<String, String> clean = Function.identity();
    private Function<String, String> validate = Function.identity();
    private Function<String, String> transform = Function.identity();
    private Consumer<String> save = System.out::println;

    public TemplateProcessor clean(Function<String, String> fn) {
        this.clean = fn;
        return this;
    }

    public TemplateProcessor validate(Function<String, String> fn) {
        this.validate = fn;
        return this;
    }

    public TemplateProcessor transform(Function<String, String> fn) {
        this.transform = fn;
        return this;
    }

    public TemplateProcessor save(Consumer<String> fn) {
        this.save = fn;
        return this;
    }

    public void process(String data) {
        save.accept(
            transform.apply(
                validate.apply(
                    clean.apply(data)
                )
            )
        );
    }
}

// Usage
new TemplateProcessor()
    .clean(String::trim)
    .validate(data -> data.isEmpty() ? null : data)
    .transform(String::toUpperCase)
    .save(System.out::println)
    .process("  hello world  ");
```

---

## Part 8: Pattern Matching (Java 16+)

### Pattern Matching for instanceof

```java
// Old way
if (obj instanceof String) {
    String str = (String) obj;
    System.out.println(str.toUpperCase());
}

// Java 16+ pattern matching
if (obj instanceof String str) {
    System.out.println(str.toUpperCase());
}

// With conditions
if (obj instanceof String str && str.length() > 5) {
    System.out.println("Long string: " + str);
}
```

### Pattern Matching with Switch (Java 17+)

```java
// Pattern matching in switch
public String describe(Object obj) {
    return switch (obj) {
        case String s -> "String: " + s;
        case Integer i -> "Integer: " + i;
        case Double d -> "Double: " + d;
        case null -> "Null value";
        default -> "Unknown type";
    };
}

// With guards
public String categorize(Object obj) {
    return switch (obj) {
        case String s when s.isEmpty() -> "Empty string";
        case String s when s.length() < 10 -> "Short string";
        case String s -> "Long string";
        case Integer i when i < 0 -> "Negative integer";
        case Integer i when i == 0 -> "Zero";
        case Integer i -> "Positive integer";
        default -> "Unknown";
    };
}

// Sealed classes with pattern matching
sealed interface Animal permits Dog, Cat {}
record Dog(String breed) implements Animal {}
record Cat(String color) implements Animal {}

public void makeSound(Animal animal) {
    switch (animal) {
        case Dog(String breed) -> System.out.println("Woof! Breed: " + breed);
        case Cat(String color) -> System.out.println("Meow! Color: " + color);
    }
}
```

---

## Part 9: Records as Data Carriers (Java 14+)

### Records Simplifying Data Classes

```java
// Old way - verbose
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
    public boolean equals(Object o) { /* ... */ }
    @Override
    public int hashCode() { /* ... */ }
    @Override
    public String toString() { /* ... */ }
}

// Java 14+ Records - concise
public record User(String name, int age, String email) {}

// Usage
User user = new User("John", 30, "john@example.com");
System.out.println(user.name()); // John
System.out.println(user); // User[name=John, age=30, email=john@example.com]
```

### Records with Custom Methods

```java
// Records can have methods
public record Product(String id, String name, double price) {
    // Compact constructor for validation
    public Product {
        if (price < 0) {
            throw new IllegalArgumentException("Price must be positive");
        }
    }

    // Instance methods
    public double totalCost(int quantity) {
        return price * quantity;
    }

    // Static methods
    public static Product create(String id, String name, double price) {
        return new Product(id, name, price);
    }
}

// Usage
Product product = new Product("P1", "Laptop", 999.99);
System.out.println(product.totalCost(2)); // 1999.98
```

---

## Part 10: Sealed Classes for Controlled Inheritance (Java 15+)

### Sealed Classes Pattern

```java
// Sealed class restricts who can extend it
public sealed class Shape permits Circle, Rectangle, Triangle {
    protected String color;

    public abstract double area();
}

// Permitted subclasses
public final class Circle extends Shape {
    private double radius;

    public Circle(double radius, String color) {
        this.radius = radius;
        this.color = color;
    }

    @Override
    public double area() {
        return Math.PI * radius * radius;
    }
}

public final class Rectangle extends Shape {
    private double width, height;

    public Rectangle(double width, double height, String color) {
        this.width = width;
        this.height = height;
        this.color = color;
    }

    @Override
    public double area() {
        return width * height;
    }
}

public final class Triangle extends Shape {
    private double base, height;

    public Triangle(double base, double height, String color) {
        this.base = base;
        this.height = height;
        this.color = color;
    }

    @Override
    public double area() {
        return (base * height) / 2;
    }
}

// Usage with pattern matching
public double calculateArea(Shape shape) {
    return switch (shape) {
        case Circle c -> c.area();
        case Rectangle r -> r.area();
        case Triangle t -> t.area();
    };
}
```

### Sealed Interfaces for Type Hierarchies

```java
// Sealed interface
public sealed interface Payment permits CreditCardPayment, PayPalPayment, ApplePayPayment {
    void process(double amount);
    String getProvider();
}

// Implementations
public final class CreditCardPayment implements Payment {
    private String cardNumber;

    public CreditCardPayment(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    @Override
    public void process(double amount) {
        System.out.println("Processing " + amount + " via credit card");
    }

    @Override
    public String getProvider() {
        return "Credit Card";
    }
}

// More implementations...
public final class PayPalPayment implements Payment { /* ... */ }
public final class ApplePayPayment implements Payment { /* ... */ }
```

---

## Part 11: Singleton Pattern - Modern Approaches

### Traditional Singleton

```java
// Old way - not thread-safe
public class DatabaseConnection {
    private static DatabaseConnection instance;

    private DatabaseConnection() {}

    public static DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }
}

// Thread-safe with double-checked locking
public class DatabaseConnection {
    private static volatile DatabaseConnection instance;

    private DatabaseConnection() {}

    public static DatabaseConnection getInstance() {
        if (instance == null) {
            synchronized (DatabaseConnection.class) {
                if (instance == null) {
                    instance = new DatabaseConnection();
                }
            }
        }
        return instance;
    }
}
```

### Modern Singleton Approaches

```java
// Enum-based singleton (best approach)
public enum DatabaseConnection {
    INSTANCE;

    private final Connection connection;

    DatabaseConnection() {
        try {
            this.connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/db");
        } catch (SQLException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public Connection getConnection() {
        return connection;
    }

    public void execute(String sql) {
        try (Statement stmt = connection.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}

// Usage
DatabaseConnection.INSTANCE.execute("SELECT * FROM users");
```

### Record-based Singleton

```java
// Using records for immutable singletons
public record CacheManager(Map<String, String> data) {
    private static final CacheManager INSTANCE = new CacheManager(new ConcurrentHashMap<>());

    public static CacheManager getInstance() {
        return INSTANCE;
    }

    public void put(String key, String value) {
        data.put(key, value);
    }

    public String get(String key) {
        return data.get(key);
    }
}
```

---

## Part 12: Dependency Injection with Modern Java

### Service Locator Pattern

```java
// Service registry
public class ServiceRegistry {
    private static final Map<Class<?>, Object> services = new ConcurrentHashMap<>();

    public static <T> void register(Class<T> serviceClass, T implementation) {
        services.put(serviceClass, implementation);
    }

    @SuppressWarnings("unchecked")
    public static <T> T get(Class<T> serviceClass) {
        T service = (T) services.get(serviceClass);
        if (service == null) {
            throw new IllegalArgumentException("No service registered for: " + serviceClass.getName());
        }
        return service;
    }
}

// Usage
interface UserRepository {
    List<User> findAll();
}

class InMemoryUserRepository implements UserRepository {
    @Override
    public List<User> findAll() {
        return Arrays.asList(new User("John", 30, "john@example.com"));
    }
}

// Registration
ServiceRegistry.register(UserRepository.class, new InMemoryUserRepository());

// Usage
UserRepository repo = ServiceRegistry.get(UserRepository.class);
List<User> users = repo.findAll();
```

### Constructor Injection with Records

```java
// Using records for DI
public record UserService(UserRepository userRepository, Logger logger) {
    public List<User> getAllUsers() {
        logger.info("Fetching all users");
        return userRepository.findAll();
    }

    public void createUser(User user) {
        logger.info("Creating user: " + user.name());
        userRepository.save(user);
    }
}

// Usage
UserService service = new UserService(
    new InMemoryUserRepository(),
    new ConsoleLogger()
);

service.getAllUsers();
```

---

## Part 13: Functional Patterns - Monadic Operations

### Optional Monadic Pattern

```java
// Optional as a monad
Optional<String> name = Optional.of("John");

// Chaining operations
String result = name
    .map(String::toUpperCase)
    .map(s -> s + " DOE")
    .filter(s -> s.length() > 5)
    .orElse("Default");

// Functional composition
Optional<User> user = Optional.of(new User("John", 30, "john@example.com"));

Optional<String> email = user
    .map(User::email)
    .filter(e -> e.contains("@"));

// Chaining Optional operations
Optional<String> result2 = Optional.of("  hello  ")
    .map(String::trim)
    .map(String::toUpperCase)
    .filter(s -> !s.isEmpty())
    .flatMap(s -> s.length() > 3 ? Optional.of(s) : Optional.empty());
```

### Stream Monadic Operations

```java
// Streams as composable operations
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

String result = names.stream()
    .filter(n -> n.length() > 3)
    .map(String::toUpperCase)
    .reduce((a, b) -> a + ", " + b)
    .orElse("No names");

// Complex transformations
List<User> users = getUsers();

Map<Integer, List<String>> emailsByAge = users.stream()
    .filter(u -> u.age() >= 18)
    .collect(Collectors.groupingBy(
        User::age,
        Collectors.mapping(User::email, Collectors.toList())
    ));
```

---

## Part 14: Comparison Table

| Pattern | Traditional | Java 8+ Approach | Benefits |
|---------|------------|-----------------|----------|
| **Builder** | Multiple classes | Consumer lambdas | Cleaner API, composable |
| **Strategy** | Interface + implementations | Functional interfaces + lambdas | No class proliferation |
| **Factory** | Factory class | Map + Supplier | Flexible, easy to extend |
| **Decorator** | Abstract decorator class | Function composition | Cleaner, composable |
| **Observer** | Observer interface | Functional interfaces | Simpler subscription |
| **Chain of Responsibility** | Abstract handler | Lambdas + streams | Elegant composition |
| **Template Method** | Abstract class | Function composition | More flexible, testable |
| **Singleton** | Double-checked locking | Enum | Thread-safe, simple |
| **DI** | Container framework | Records + constructors | Type-safe, minimal |
| **Pattern Matching** | instanceof + casting | Switch expressions | Cleaner, safer code |

---

## Part 15: Best Practices

### 1. Prefer Functional Interfaces

```java
// Good
@FunctionalInterface
interface Handler<T> {
    void handle(T input);
}

// Bad
interface Handler<T> {
    void handle(T input);
    void cancel();
}
```

### 2. Use Method References

```java
// Verbose
list.forEach(item -> System.out.println(item));

// Better
list.forEach(System.out::println);

// Verbose
users.stream().map(u -> u.name()).collect(Collectors.toList());

// Better
users.stream().map(User::name).collect(Collectors.toList());
```

### 3. Leverage Records for Data

```java
// Good - Records are immutable, concise
public record DatabaseConfig(String host, int port, String username) {}

// Bad - Old mutable class
public class DatabaseConfig {
    private String host;
    private int port;
    private String username;
    // ... getters, setters, equals, hashCode, toString
}
```

### 4. Use Sealed Classes for Type Safety

```java
// Good - Exhaustive pattern matching
sealed interface Result permits Success, Failure {}
record Success(String data) implements Result {}
record Failure(String error) implements Result {}

String message = switch (result) {
    case Success(String data) -> "Success: " + data;
    case Failure(String error) -> "Error: " + error;
};

// Bad - No compile-time exhaustiveness checking
interface Result {}
class Success implements Result { String data; }
class Failure implements Result { String error; }
```

### 5. Chain Operations Fluently

```java
// Good - fluent, readable
result = source.stream()
    .filter(isValid())
    .map(transform())
    .sorted(comparator())
    .collect(toList());

// Bad - nested, hard to read
List<T> filtered = filter(source, isValid());
List<T> mapped = map(filtered, transform());
Collections.sort(mapped, comparator());
```

---

## Summary

Java 8+ revolutionized design patterns through:

1. **Lambdas** - Reduce boilerplate, enable functional composition
2. **Method References** - Cleaner, more readable code
3. **Functional Interfaces** - Type-safe lambda support
4. **Streams API** - Pipeline operations with functional style
5. **Optional** - Null-safe, monadic operations
6. **Records** - Immutable data carriers with minimal code
7. **Sealed Classes** - Controlled hierarchies, exhaustive pattern matching
8. **Pattern Matching** - Cleaner, safer type checking and extraction

These features enable more expressive, maintainable, and type-safe code while maintaining backward compatibility.

---

**Last Updated:** October 26, 2024
**Level:** Expert
**Topics Covered:** 14+ patterns with modern approaches
**Code Examples:** 85+
**Estimated Study Time:** 6-8 hours
