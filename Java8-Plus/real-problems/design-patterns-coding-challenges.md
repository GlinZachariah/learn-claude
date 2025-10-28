# Java 8+ Design Patterns - Coding Challenges

## Challenge 1: Build a Fluent HTTP Request Builder

**Difficulty:** Intermediate
**Estimated Time:** 2 hours
**Concepts:** Builder Pattern, Fluent APIs, Lambdas

### Requirements

Create a `HttpRequest` builder that:
1. Supports fluent API (method chaining)
2. Allows adding headers with multiple calls
3. Supports body/payload setting
4. Validates URL before building
5. Supports Consumer-based configuration
6. Provides sensible defaults

### Starter Code

```java
public class HttpRequest {
    private final String url;
    private final String method;
    private final Map<String, String> headers;
    private final String body;
    private final Duration timeout;

    // Private constructor - use builder
    private HttpRequest(String url, String method, Map<String, String> headers,
                       String body, Duration timeout) {
        this.url = url;
        this.method = method;
        this.headers = headers;
        this.body = body;
        this.timeout = timeout;
    }

    public String getUrl() { return url; }
    public String getMethod() { return method; }
    public Map<String, String> getHeaders() { return headers; }
    public String getBody() { return body; }
    public Duration getTimeout() { return timeout; }
}

public class HttpRequestBuilder {
    // TODO: Implement builder
}
```

### Expected Usage

```java
// Fluent style
HttpRequest request = new HttpRequestBuilder()
    .url("https://api.example.com/users")
    .method("POST")
    .addHeader("Authorization", "Bearer token123")
    .addHeader("Content-Type", "application/json")
    .body("{\"name\": \"John\"}")
    .timeout(Duration.ofSeconds(30))
    .build();

// Consumer style
HttpRequest request2 = new HttpRequestBuilder()
    .url("https://api.example.com/users")
    .configure(builder -> {
        builder.addHeader("Authorization", "Bearer token123");
        builder.addHeader("Content-Type", "application/json");
        builder.timeout(Duration.ofSeconds(30));
    })
    .body("{\"name\": \"John\"}")
    .build();

// Defaults
HttpRequest minimal = new HttpRequestBuilder()
    .url("https://api.example.com/data")
    .build();
// GET method, no headers, no body, 60s timeout
```

### Key Features

- ✅ All methods return `this` for chaining
- ✅ `url()` validates URL format
- ✅ Multiple `addHeader()` calls accumulate headers
- ✅ `configure(Consumer<HttpRequestBuilder>)` for complex setups
- ✅ Default values: GET, empty headers, no body, 60s timeout
- ✅ Immutable HttpRequest after building
- ✅ Proper error handling for invalid URLs

### Bonus Features

1. **Request Copy** - Clone builder from existing request
2. **Header Overwrite** - `setHeader()` instead of just `addHeader()`
3. **Validation** - Validate headers, body size, etc.
4. **URL Query Params** - Helper method for query parameters
5. **Authentication Helper** - `bearerToken()`, `basicAuth()` shortcuts

---

## Challenge 2: Implement a Type-Safe Event Bus

**Difficulty:** Advanced
**Estimated Time:** 3 hours
**Concepts:** Observer Pattern, Generics, Functional Interfaces, Sealed Classes

### Requirements

Create an event system that:
1. Supports multiple event types (sealed classes)
2. Type-safe event subscription
3. Publish events to all subscribers
4. Unsubscribe capability
5. Handle errors in handlers gracefully
6. Async event processing option

### Starter Code

```java
// Define events using sealed classes
public sealed interface Event permits UserLoggedIn, UserLoggedOut,
                                      OrderCreated, OrderShipped {}

public record UserLoggedIn(String userId, LocalDateTime timestamp)
    implements Event {}

public record UserLoggedOut(String userId)
    implements Event {}

public record OrderCreated(String orderId, double amount)
    implements Event {}

public record OrderShipped(String orderId, String carrier)
    implements Event {}

// Handler interface
@FunctionalInterface
interface EventHandler<T extends Event> {
    void handle(T event);
}

public class EventBus {
    // TODO: Implement event bus
}
```

### Expected Usage

```java
EventBus bus = new EventBus();

// Subscribe to events
bus.subscribe(UserLoggedIn.class, event ->
    System.out.println("User logged in: " + event.userId())
);

bus.subscribe(OrderCreated.class, event ->
    System.out.println("Order $" + event.amount() + " created")
);

bus.subscribe(OrderShipped.class, event ->
    System.out.println("Order shipped via " + event.carrier())
);

// Publish events
bus.publish(new UserLoggedIn("user123", LocalDateTime.now()));
bus.publish(new OrderCreated("order456", 99.99));
bus.publish(new OrderShipped("order456", "FedEx"));

// Unsubscribe
Subscription subscription = bus.subscribe(UserLoggedOut.class,
    event -> System.out.println("User logged out: " + event.userId())
);
subscription.unsubscribe();

bus.publish(new UserLoggedOut("user123")); // No output
```

### Key Features

- ✅ Type-safe subscriptions with generics
- ✅ Multiple handlers for same event
- ✅ Unsubscribe capability (return `Subscription` object)
- ✅ Handle exceptions in handlers without crashing bus
- ✅ Thread-safe (ConcurrentHashMap, CopyOnWriteArrayList)
- ✅ Pattern matching for event handling (bonus)

### Bonus Features

1. **Async Publishing** - `publishAsync()` for non-blocking
2. **Event Filtering** - Subscribe with predicate
3. **Priority Handlers** - Handlers execute in priority order
4. **Dead Letter Queue** - Capture unhandled events
5. **Event History** - Replay events
6. **Error Handling** - `onError()` callback

---

## Challenge 3: Create a Strategy-Based Data Processor

**Difficulty:** Intermediate
**Estimated Time:** 2 hours
**Concepts:** Strategy Pattern, Sealed Classes, Pattern Matching

### Requirements

Create a data processor that:
1. Supports multiple file formats (CSV, JSON, XML)
2. Extensible strategy pattern
3. Use sealed classes for data results
4. Handle processing errors gracefully
5. Chain multiple processors (decorator pattern)
6. Configurable via factory

### Starter Code

```java
// Result types
public sealed interface ProcessingResult permits
    ProcessingSuccess, ProcessingFailure {}

public record ProcessingSuccess(List<Map<String, String>> data)
    implements ProcessingResult {}

public record ProcessingFailure(String error, Exception cause)
    implements ProcessingResult {}

// Strategy interface
@FunctionalInterface
interface DataProcessor {
    ProcessingResult process(String content);
}

public class DataProcessorFactory {
    // TODO: Implement factory with strategies
}
```

### Expected Usage

```java
// Use factory to get processors
DataProcessor csvProcessor = DataProcessorFactory.getProcessor("csv");
DataProcessor jsonProcessor = DataProcessorFactory.getProcessor("json");

// Process data
String csvContent = "name,age\nJohn,30\nAlice,25";
ProcessingResult result = csvProcessor.process(csvContent);

// Pattern match on result
String output = switch (result) {
    case ProcessingSuccess(List<Map<String, String>> data) ->
        "Processed " + data.size() + " records";

    case ProcessingFailure(String error, Exception cause) ->
        "Error: " + error;
};

System.out.println(output);

// Add custom processor
DataProcessorFactory.register("yaml", content ->
    // Custom YAML processing logic
    new ProcessingSuccess(parseYaml(content))
);

// Use custom processor
DataProcessor yamlProcessor = DataProcessorFactory.getProcessor("yaml");
```

### File Formats to Support

**CSV:**
```
name,age,email
John,30,john@example.com
Alice,25,alice@example.com
```

**JSON:**
```json
[
  {"name": "John", "age": 30, "email": "john@example.com"},
  {"name": "Alice", "age": 25, "email": "alice@example.com"}
]
```

**XML:**
```xml
<users>
  <user>
    <name>John</name>
    <age>30</age>
    <email>john@example.com</email>
  </user>
</users>
```

### Key Features

- ✅ Separate processor for each format
- ✅ Factory pattern for processor retrieval
- ✅ Runtime processor registration
- ✅ Error handling with detailed messages
- ✅ Consistent output format (List<Map>)
- ✅ Pattern matching for results

### Bonus Features

1. **Chained Processing** - Process through multiple formats
2. **Validation Processor** - Validate data after processing
3. **Transformation Processor** - Transform fields
4. **Caching** - Cache parsed results
5. **Streaming** - Handle large files with streams
6. **Custom Fields** - Support custom field parsing

---

## Challenge 4: Build a Decorator-Based Logger

**Difficulty:** Intermediate
**Estimated Time:** 2 hours
**Concepts:** Decorator Pattern, Functional Composition, Function.andThen()

### Requirements

Create a configurable logger using decorators:
1. Base logger that outputs to console
2. Timestamp decorator
3. Log level decorator
4. JSON formatting decorator
5. File output decorator
6. Compose decorators together

### Starter Code

```java
@FunctionalInterface
interface LogFormatter {
    String format(String level, String message);
}

public class Logger {
    private final LogFormatter formatter;

    public Logger(LogFormatter formatter) {
        this.formatter = formatter;
    }

    public void log(String level, String message) {
        String formatted = formatter.format(level, message);
        System.out.println(formatted);
    }
}

public class LoggerBuilder {
    // TODO: Implement decorator-based builder
}
```

### Expected Usage

```java
// Simple logger
Logger simpleLogger = new Logger((level, message) ->
    level + ": " + message
);

simpleLogger.log("INFO", "Application started");
// Output: INFO: Application started

// Decorated logger with timestamp
Logger timestampedLogger = LoggerBuilder.create()
    .withTimestamp()
    .build();

timestampedLogger.log("INFO", "User logged in");
// Output: [2024-10-26 08:45:30] INFO: User logged in

// Fully decorated logger
Logger fullLogger = LoggerBuilder.create()
    .withTimestamp()
    .withLevel()
    .withJsonFormat()
    .toFile("app.log")
    .build();

fullLogger.log("ERROR", "Database connection failed");
// Output to file: {"timestamp":"2024-10-26T08:45:30","level":"ERROR","message":"Database connection failed"}
```

### Decorators to Implement

1. **Timestamp Decorator** - Prepend current timestamp
2. **Level Decorator** - Format log level
3. **JSON Formatter** - Output as JSON
4. **File Writer** - Write to file instead of console
5. **Color Formatter** - Add ANSI colors for console (bonus)

### Key Features

- ✅ Fluent builder API
- ✅ Function composition for formatters
- ✅ Decorator pattern with functions
- ✅ Chainable decorators
- ✅ Thread-safe file writing
- ✅ Configurable levels

### Bonus Features

1. **Log Levels** - INFO, WARN, ERROR, DEBUG filtering
2. **Async Logging** - Non-blocking log writing
3. **Rotation** - Rotate log files by size
4. **Filtering** - Filter logs by pattern
5. **Colorized Output** - ANSI colors for terminals
6. **Performance Metrics** - Log execution time

---

## Challenge 5: Implement Factory Pattern with Sealed Classes

**Difficulty:** Advanced
**Estimated Time:** 2.5 hours
**Concepts:** Factory Pattern, Sealed Classes, Pattern Matching

### Requirements

Create a database connection factory:
1. Support multiple database types (MySQL, Postgres, MongoDB, Redis)
2. Sealed class for database configuration
3. Type-safe connection creation
4. Connection pooling
5. Configuration validation
6. Extensible design

### Starter Code

```java
// Sealed configuration
public sealed interface DatabaseConfig permits
    MySQLConfig, PostgresConfig, MongoConfig, RedisConfig {}

public record MySQLConfig(String host, int port, String database,
                         String username, String password)
    implements DatabaseConfig {}

public record PostgresConfig(String host, int port, String database,
                           String username, String password, int poolSize)
    implements DatabaseConfig {}

public record MongoConfig(String connectionString, String database)
    implements DatabaseConfig {}

public record RedisConfig(String host, int port, String password)
    implements DatabaseConfig {}

// Connection interface
interface DatabaseConnection {
    void execute(String query);
    void close();
}

public class DatabaseFactory {
    // TODO: Implement factory with pattern matching
}
```

### Expected Usage

```java
// Create configurations
DatabaseConfig mysqlConfig = new MySQLConfig(
    "localhost", 3306, "myapp", "root", "password"
);

DatabaseConfig postgresConfig = new PostgresConfig(
    "localhost", 5432, "myapp", "postgres", "password", 10
);

// Get connections using factory
DatabaseConnection mysqlConn = DatabaseFactory.createConnection(mysqlConfig);
DatabaseConnection postgresConn = DatabaseFactory.createConnection(postgresConfig);

// Use connections
mysqlConn.execute("SELECT * FROM users");
postgresConn.execute("INSERT INTO logs VALUES (...)");

// Validate configuration
DatabaseFactory.validateConfig(mysqlConfig);

// List supported types
DatabaseFactory.getSupportedTypes();
// Output: [MYSQL, POSTGRES, MONGO, REDIS]
```

### Configuration Validation Rules

- **MySQL:** host ≠ null, port ∈ (0, 65535], username ≠ null, password ≠ null
- **Postgres:** host ≠ null, port ∈ (0, 65535], username ≠ null, poolSize ≥ 1
- **MongoDB:** connectionString ≠ null, database ≠ null
- **Redis:** host ≠ null, port ∈ (0, 65535], password optional

### Key Features

- ✅ Sealed classes restrict config types
- ✅ Factory creates appropriate connections
- ✅ Pattern matching for config validation
- ✅ Connection pooling support
- ✅ Configuration validation
- ✅ Type-safe connections

### Bonus Features

1. **Connection Pooling** - Implement pooling per config type
2. **Configuration Builders** - Fluent builders for each config
3. **Health Checks** - Verify connection before returning
4. **Retry Logic** - Retry failed connections
5. **Metrics** - Track connection usage
6. **Encryption** - Encrypt passwords in config

---

## Challenge 6: Build a Sealed Class-Based Calculator

**Difficulty:** Easy to Intermediate
**Estimated Time:** 1.5 hours
**Concepts:** Sealed Classes, Records, Pattern Matching

### Requirements

Create a calculator that:
1. Supports multiple operations (Add, Subtract, Multiply, Divide)
2. Use sealed classes for operations
3. Pattern matching for evaluation
4. Error handling for division by zero
5. Support chaining operations

### Starter Code

```java
// Sealed operation classes
public sealed interface Operation permits
    Add, Subtract, Multiply, Divide, Negate, Power {}

public record Add(double a, double b) implements Operation {}
public record Subtract(double a, double b) implements Operation {}
public record Multiply(double a, double b) implements Operation {}
public record Divide(double a, double b) implements Operation {}
public record Negate(double value) implements Operation {}
public record Power(double base, double exponent) implements Operation {}

// Result type
public sealed interface CalculationResult permits
    Success, DivisionByZero, InvalidOperation {}

public record Success(double value) implements CalculationResult {}
public record DivisionByZero(String message) implements CalculationResult {}
public record InvalidOperation(String message) implements CalculationResult {}

public class Calculator {
    // TODO: Implement evaluate method with pattern matching
}
```

### Expected Usage

```java
Calculator calc = new Calculator();

// Evaluate operations
CalculationResult result1 = calc.evaluate(new Add(10, 5));
CalculationResult result2 = calc.evaluate(new Multiply(4, 3));
CalculationResult result3 = calc.evaluate(new Divide(10, 0));

// Pattern match results
String output = switch (result1) {
    case Success(double value) -> "Result: " + value;
    case DivisionByZero(String msg) -> "Error: " + msg;
    case InvalidOperation(String msg) -> "Invalid: " + msg;
};

System.out.println(output); // Result: 15.0

// Chaining
CalculationResult result4 = calc
    .evaluate(new Add(5, 3))
    .flatMap(val -> calc.evaluate(new Multiply(val, 2)));
// Result: (5 + 3) * 2 = 16
```

### Key Features

- ✅ Sealed classes for operation types
- ✅ Records for immutable operations
- ✅ Pattern matching for evaluation
- ✅ Error handling with result types
- ✅ Monadic chaining

### Bonus Features

1. **Expression Parser** - Parse "10 + 5 * 2"
2. **Operation History** - Track calculation history
3. **Undo/Redo** - Navigate through operations
4. **Custom Operations** - Allow user-defined operations
5. **Performance Optimization** - Cache results

---

## Challenge 7: Implement Custom Functional Interfaces

**Difficulty:** Intermediate
**Estimated Time:** 1.5 hours
**Concepts:** Functional Interfaces, Lambda Expressions, Type Parameters

### Requirements

Create custom functional interfaces:
1. `Transformer<T, R>` - Transform T to R
2. `Validator<T>` - Validate T, return boolean
3. `AsyncOperation<T>` - Async operation returning T
4. `Either<L, R>` - Either left or right value
5. Compose interfaces together

### Starter Code

```java
@FunctionalInterface
interface Transformer<T, R> {
    R transform(T input);

    default <U> Transformer<T, U> andThen(Transformer<R, U> after) {
        return input -> after.transform(this.transform(input));
    }
}

@FunctionalInterface
interface Validator<T> {
    boolean validate(T input);

    default Validator<T> and(Validator<T> other) {
        return input -> this.validate(input) && other.validate(input);
    }

    default Validator<T> or(Validator<T> other) {
        return input -> this.validate(input) || other.validate(input);
    }
}

// TODO: Implement other interfaces and compositions
```

### Expected Usage

```java
// Transformers
Transformer<String, Integer> stringToInt = Integer::parseInt;
Transformer<Integer, String> intToHex = Integer::toHexString;

Transformer<String, String> composed = stringToInt.andThen(intToHex);
String result = composed.transform("255"); // "ff"

// Validators
Validator<String> notEmpty = s -> !s.isEmpty();
Validator<String> lengthAtLeast5 = s -> s.length() >= 5;
Validator<String> alphanumeric = s -> s.matches("^[a-zA-Z0-9]*$");

Validator<String> stringValidator = notEmpty
    .and(lengthAtLeast5)
    .and(alphanumeric);

boolean isValid = stringValidator.validate("user123"); // true

// Async operations
AsyncOperation<Integer> fetchUserId = callback ->
    new Thread(() -> callback.accept(findUserIdInDB())).start();
```

### Key Features

- ✅ Custom functional interfaces
- ✅ Composition methods (andThen, and, or)
- ✅ Generic type parameters
- ✅ Default methods for composition
- ✅ Chain operations

### Bonus Features

1. **Either Monad** - Functional error handling
2. **Try Monad** - Exception handling
3. **Composition Operators** - Compose multiple validators
4. **Caching** - Memoize results
5. **Async Chains** - Chain async operations

---

## Challenge 8: Build a Type-Safe DI Container

**Difficulty:** Advanced
**Estimated Time:** 3 hours
**Concepts:** Dependency Injection, Generics, Factory Pattern

### Requirements

Create a dependency injection container:
1. Register singletons and factories
2. Type-safe retrieval with generics
3. Constructor injection
4. Circular dependency detection
5. Lazy initialization
6. Scope management

### Starter Code

```java
public interface ServiceProvider {
    <T> T get(Class<T> serviceClass);
    <T> void register(Class<T> serviceClass, T instance);
    <T> void registerFactory(Class<T> serviceClass,
                            Supplier<T> factory);
}

public class DIContainer implements ServiceProvider {
    private final Map<Class<?>, Object> singletons = new HashMap<>();
    private final Map<Class<?>, Supplier<?>> factories = new HashMap<>();
    private final Set<Class<?>> inProgress = new HashSet<>();

    // TODO: Implement DI container
}

// Example services
interface UserRepository {
    User findById(String id);
}

class InMemoryUserRepository implements UserRepository {
    @Override
    public User findById(String id) {
        return new User(id, "John");
    }
}

class UserService {
    private final UserRepository repository;

    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    public User getUser(String id) {
        return repository.findById(id);
    }
}
```

### Expected Usage

```java
DIContainer container = new DIContainer();

// Register implementations
container.register(UserRepository.class, new InMemoryUserRepository());

// Register factories
container.registerFactory(UserService.class, () ->
    new UserService(container.get(UserRepository.class))
);

// Retrieve services
UserRepository repo = container.get(UserRepository.class);
UserService service = container.get(UserService.class);

User user = service.getUser("123");
System.out.println(user.getName()); // John
```

### Key Features

- ✅ Type-safe registration and retrieval
- ✅ Singleton management
- ✅ Factory support
- ✅ Circular dependency detection
- ✅ Lazy initialization
- ✅ Scope management

### Bonus Features

1. **Auto-wiring** - Automatic constructor injection
2. **Annotation Support** - @Inject, @Singleton
3. **Lifecycle Hooks** - @PostConstruct, @PreDestroy
4. **Interceptors** - Logging, caching
5. **Multiple Implementations** - Named bindings
6. **Scope Types** - Singleton, Prototype, Request

---

## Testing Your Solutions

### Unit Testing Example

```java
@Test
public void testHttpRequestBuilder() {
    HttpRequest request = new HttpRequestBuilder()
        .url("https://api.example.com/users")
        .addHeader("Authorization", "Bearer token")
        .body("{\"name\": \"John\"}")
        .build();

    assertEquals("https://api.example.com/users", request.getUrl());
    assertEquals("Bearer token", request.getHeaders().get("Authorization"));
    assertEquals("{\"name\": \"John\"}", request.getBody());
    assertEquals("GET", request.getMethod()); // default
}

@Test
public void testEventBusSubscription() {
    EventBus bus = new EventBus();
    List<String> events = new ArrayList<>();

    bus.subscribe(UserLoggedIn.class, event ->
        events.add("Login: " + event.userId())
    );

    bus.publish(new UserLoggedIn("user123", LocalDateTime.now()));

    assertEquals(1, events.size());
    assertTrue(events.get(0).contains("user123"));
}
```

---

## Submission Checklist

- ✅ Code compiles without errors
- ✅ All functional requirements implemented
- ✅ Error handling in place
- ✅ Unit tests for main functionality
- ✅ Code follows Java best practices
- ✅ Comments explaining complex logic
- ✅ Bonus features attempted (optional)

---

**Last Updated:** October 26, 2024
**Level:** Intermediate to Advanced
**Total Challenges:** 8
**Estimated Total Time:** 18-20 hours
**Skills Covered:** Builder, Factory, Strategy, Decorator, Observer, DI, FI, Sealed Classes, Pattern Matching
