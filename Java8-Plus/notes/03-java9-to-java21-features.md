# Java 9+ Features (Java 9 to Java 21)

Comprehensive overview of important features introduced after Java 8.

## Java 9 (September 2017)

### 1. Module System (Project Jigsaw)

The most significant change - introducing modules for better encapsulation:

```java
// module-info.java
module com.example.app {
    requires java.base;
    requires com.example.utils;

    exports com.example.app.api;
    exports com.example.app.service to com.example.testing;
}
```

**Benefits:**
- Strong encapsulation beyond packages
- Explicit dependencies
- Reduced classpath issues
- Better performance through optimization

### 2. Private Interface Methods

Interfaces can now have private methods:

```java
public interface Logger {
    void log(String message);

    // Private method in interface
    private void formatAndLog(String message) {
        String formatted = formatMessage(message);
        System.out.println(formatted);
    }

    private String formatMessage(String msg) {
        return "[LOG] " + msg;
    }
}
```

### 3. Try-with-Resources Enhancement

```java
// Java 9+ - effectively final variables
BufferedReader reader = new BufferedReader(new FileReader("file.txt"));
try (reader) {
    // Use reader
} catch (IOException e) {
    // Handle exception
}

// Works with multiple resources
try (
    BufferedReader r = new BufferedReader(new FileReader("file.txt"));
    BufferedWriter w = new BufferedWriter(new FileWriter("output.txt"))
) {
    // Use r and w
}
```

### 4. Enhanced Stream API

```java
// takeWhile - take elements while condition is true
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
numbers.stream()
    .takeWhile(n -> n < 4)
    .forEach(System.out::println); // 1, 2, 3

// dropWhile - drop elements while condition is true
numbers.stream()
    .dropWhile(n -> n < 3)
    .forEach(System.out::println); // 3, 4, 5

// ofNullable
Stream<String> stream = Stream.ofNullable(value);
```

---

## Java 10 (March 2018)

### 1. Local Variable Type Inference (var)

```java
// Instead of
List<String> names = new ArrayList<>();

// Can now use
var names = new ArrayList<String>();

// Works with streams
var result = numbers.stream()
    .filter(n -> n > 5)
    .map(n -> n * 2)
    .collect(Collectors.toList());

// var is NOT dynamic - it's type inference
var x = 5;      // int
var y = "text"; // String
// x = "text";  // Compile error

// Where var helps readability
var iterator = collection.iterator(); // Type is inferred
var entry = map.entrySet().iterator().next(); // Complex type
```

### 2. Unmodifiable Collections

```java
// Collections.unmodifiableList() now factory methods exist
List<String> immutable = List.of("a", "b", "c");
// immutable.add("d"); // Throws UnsupportedOperationException

Set<String> immutableSet = Set.of("a", "b", "c");

Map<String, Integer> immutableMap = Map.of(
    "a", 1,
    "b", 2,
    "c", 3
);
```

---

## Java 11 (September 2018) - LTS

### 1. String Methods

```java
String text = "  Hello World  \n";

// isBlank() - checks if empty or whitespace
System.out.println(text.isBlank()); // true

// strip() - removes leading/trailing whitespace
System.out.println(text.strip()); // "Hello World"

// stripLeading() / stripTrailing()
System.out.println(text.stripLeading());

// repeat() - repeat string
System.out.println("ab".repeat(3)); // "ababab"

// lines() - split into stream
String multiline = "line1\nline2\nline3";
multiline.lines()
    .forEach(System.out::println);
```

### 2. HTTP Client API (New)

```java
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

// Synchronous request
var client = HttpClient.newHttpClient();
var request = HttpRequest.newBuilder()
    .uri(URI.create("https://api.example.com/data"))
    .GET()
    .build();

var response = client.send(request,
    HttpResponse.BodyHandlers.ofString());

System.out.println(response.statusCode());
System.out.println(response.body());

// Asynchronous request
client.sendAsync(request, HttpResponse.BodyHandlers.ofString())
    .thenApply(HttpResponse::body)
    .thenAccept(System.out::println)
    .join();
```

### 3. File Reading Convenience

```java
// Read entire file
String content = Files.readString(Path.of("file.txt"));

// Write entire file
Files.writeString(Path.of("file.txt"), "content");
```

---

## Java 14 (March 2020)

### 1. Records (Preview, finalized in Java 16)

```java
// Traditional class
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
    public boolean equals(Object o) { ... }

    @Override
    public int hashCode() { ... }

    @Override
    public String toString() { ... }
}

// With Record (Java 14+)
record Person(String name, int age) {}

// Automatic:
// - Constructor
// - Getters (name(), age())
// - equals(), hashCode(), toString()

// Usage
var person = new Person("Alice", 30);
System.out.println(person.name());  // "Alice"
System.out.println(person.age());   // 30

// Custom constructor
record Point(int x, int y) {
    public Point(int x, int y) {
        if (x < 0 || y < 0) {
            throw new IllegalArgumentException("Coordinates must be positive");
        }
        this.x = x;
        this.y = y;
    }
}
```

### 2. Switch Expressions (Finalized in Java 14)

```java
// Traditional switch
int days;
switch (month) {
    case 1, 3, 5, 7, 8, 10, 12:
        days = 31;
        break;
    case 4, 6, 9, 11:
        days = 30;
        break;
    default:
        days = 28;
}

// Switch expression
int days = switch (month) {
    case 1, 3, 5, 7, 8, 10, 12 -> 31;
    case 4, 6, 9, 11 -> 30;
    default -> 28;
};

// With complex logic
String result = switch (status) {
    case "SUCCESS" -> "Operation completed";
    case "ERROR" -> {
        log("An error occurred");
        yield "Failed";
    }
    case "PENDING" -> "Please wait";
    default -> "Unknown";
};
```

---

## Java 15 (September 2020)

### 1. Sealed Classes (Preview, finalized in Java 17)

Restrict which classes can extend a sealed class:

```java
// Sealed class - only specific classes can extend it
public sealed class Shape
    permits Circle, Rectangle, Triangle {
    public abstract double area();
}

// Permitted subclass
public final class Circle extends Shape {
    private double radius;

    @Override
    public double area() {
        return Math.PI * radius * radius;
    }
}

public final class Rectangle extends Shape {
    private double width, height;

    @Override
    public double area() {
        return width * height;
    }
}

public final class Triangle extends Shape {
    private double base, height;

    @Override
    public double area() {
        return base * height / 2;
    }
}

// This would NOT compile
// public final class Pentagon extends Shape {} // Not permitted
```

### 2. Text Blocks (Preview, finalized in Java 15)

```java
// Traditional multi-line string
String html = "<html>\n" +
    "  <body>\n" +
    "    <h1>Hello</h1>\n" +
    "  </body>\n" +
    "</html>";

// Text block (""")
String html = """
    <html>
      <body>
        <h1>Hello</h1>
      </body>
    </html>
    """;

// JSON example
String json = """
    {
        "name": "Alice",
        "age": 30,
        "city": "New York"
    }
    """;

// SQL example
String query = """
    SELECT id, name, email
    FROM users
    WHERE age > 18
    ORDER BY name
    """;
```

---

## Java 16 (March 2021)

### 1. Pattern Matching for instanceof (Preview, finalized in Java 16)

```java
// Traditional instanceof
Object obj = "Hello";
if (obj instanceof String) {
    String str = (String) obj;
    System.out.println(str.length());
}

// Pattern matching
if (obj instanceof String str) {
    System.out.println(str.length()); // str is already a String
}

// With method calls
if (obj instanceof String str && str.length() > 5) {
    System.out.println(str.toUpperCase());
}

// Pattern matching in records
record Person(String name, int age) {}

Object o = new Person("Alice", 30);
if (o instanceof Person(String name, int age)) {
    System.out.println(name + " is " + age);
}
```

---

## Java 17 (September 2021) - LTS

### Sealed Classes and Pattern Matching (Finalized)

See Java 15 for details.

---

## Java 19 (September 2023)

### 1. Virtual Threads (Preview)

Lightweight threads for better concurrency:

```java
// Traditional thread
Thread thread = new Thread(() -> {
    System.out.println("Running in thread");
});
thread.start();

// Virtual thread (Java 19+)
Thread vthread = Thread.ofVirtual()
    .name("virtual-1")
    .start(() -> {
        System.out.println("Running in virtual thread");
    });

// Or using ExecutorService
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
for (int i = 0; i < 1000000; i++) {
    executor.submit(() -> {
        System.out.println("Virtual thread task");
    });
}
executor.shutdown();
```

### 2. Structured Concurrency (Preview)

Better handling of concurrent tasks:

```java
// API for managing related threads
class StructuredConcurrency {
    // Simulated - requires special JVM flag
    void example() throws Exception {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
            // Submit tasks
            var future1 = scope.fork(() -> /* task1 */);
            var future2 = scope.fork(() -> /* task2 */);

            // Wait for all to complete
            scope.join();

            // Get results
        }
    }
}
```

---

## Java 21 (September 2023) - LTS

### 1. Virtual Threads (Finalized)

See Java 19 for details.

### 2. Record Patterns (Preview)

Enhanced pattern matching with records:

```java
record Point(int x, int y) {}
record Circle(Point center, int radius) {}

Object obj = new Circle(new Point(10, 20), 5);

// Pattern matching on nested records
if (obj instanceof Circle(Point(int x, int y), int r)) {
    System.out.println("Circle at (" + x + "," + y + ") with radius " + r);
}
```

### 3. Generics with Wildcard Instantiation

```java
// Before: raw types
List list = new ArrayList();

// Java 21: Better inference
var list = new ArrayList<String>(); // Type is clear

// Using type variables
class Generic<T> {
    T value;
    Generic(T t) { this.value = t; }
}

var generic = new Generic<>("value"); // Inferred
```

---

## Summary of Key Releases

| Release | Type | Key Features |
|---------|------|--------------|
| Java 9  | LTS | Modules, Private Interface Methods |
| Java 10 | - | Local Variable Type Inference (var) |
| Java 11 | LTS | String improvements, HTTP Client |
| Java 14 | - | Records (preview), Switch expressions |
| Java 15 | - | Sealed Classes, Text Blocks |
| Java 16 | - | Pattern Matching instanceof |
| Java 17 | LTS | Sealed Classes (final), Pattern Matching (final) |
| Java 19 | - | Virtual Threads (preview) |
| Java 21 | LTS | Virtual Threads (final), Record Patterns |

---

## LTS (Long Term Support) Versions

- **Java 8** (March 2014)
- **Java 11** (September 2018)
- **Java 17** (September 2021)
- **Java 21** (September 2023)

These versions receive long-term support and are recommended for production use.

---

## Next Steps

1. Explore pattern matching deeply
2. Experiment with records
3. Learn about virtual threads for concurrency
4. Study sealed classes for better design

