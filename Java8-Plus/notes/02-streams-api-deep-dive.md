# Streams API Deep Dive

A comprehensive exploration of Java's Streams API for functional data processing.

## Understanding Streams

### Stream vs Collection

**Collections:**
- Store data in memory
- You access data by iterating
- External iteration (you control the loop)
- Eager evaluation

**Streams:**
- Compute on demand
- Describe transformations
- Internal iteration (framework controls the loop)
- Lazy evaluation

```java
// Collection approach
List<String> names = Arrays.asList("Alice", "Bob", "Charlie");
for (String name : names) {
    if (name.length() > 3) {
        System.out.println(name.toUpperCase());
    }
}

// Stream approach
names.stream()
    .filter(name -> name.length() > 3)
    .map(String::toUpperCase)
    .forEach(System.out::println);
```

---

## Stream Pipeline Structure

A stream pipeline consists of three parts:

```
Data Source → Intermediate Operations → Terminal Operation
```

### 1. Data Source
Where the stream originates:

```java
// From collection
List<String> list = Arrays.asList("a", "b");
Stream<String> stream1 = list.stream();

// From array
String[] array = {"a", "b"};
Stream<String> stream2 = Arrays.stream(array);

// Static factory methods
Stream<String> stream3 = Stream.of("a", "b");
Stream<Integer> stream4 = Stream.iterate(0, n -> n + 1).limit(5);
Stream<String> stream5 = Stream.generate(() -> "value").limit(5);

// From file
Stream<String> stream6 = Files.lines(Paths.get("file.txt"));

// From resources
Stream<String> stream7 = Stream.empty();
```

### 2. Intermediate Operations
Transform the stream (lazy - nothing happens until terminal operation):

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

Stream<Integer> stream = numbers.stream()
    .filter(n -> n > 2)        // Intermediate: filter
    .map(n -> n * 2)            // Intermediate: map
    .distinct()                 // Intermediate: remove duplicates
    .skip(1)                    // Intermediate: skip first element
    .limit(2);                  // Intermediate: limit to 2 elements
// Nothing happens yet! Stream not executed
```

### 3. Terminal Operations
Trigger execution and produce a result:

```java
// Executed after terminal operation
numbers.stream()
    .filter(n -> n > 2)
    .map(n -> n * 2)
    .forEach(System.out::println); // Terminal: forEach

// After terminal operation, stream is consumed and cannot be reused
```

---

## Intermediate Operations

### filter(Predicate)
Keep elements that match a condition:

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6);

numbers.stream()
    .filter(n -> n % 2 == 0)
    .forEach(System.out::println); // 2, 4, 6
```

### map(Function)
Transform each element:

```java
List<String> words = Arrays.asList("Java", "Stream");

words.stream()
    .map(String::toUpperCase)
    .forEach(System.out::println); // JAVA, STREAM

// Map to different type
List<Integer> lengths = words.stream()
    .map(String::length)
    .collect(Collectors.toList()); // [4, 6]
```

### flatMap(Function)
Map and flatten nested streams:

```java
List<List<String>> listOfLists = Arrays.asList(
    Arrays.asList("a", "b"),
    Arrays.asList("c", "d")
);

// Without flatMap - nested structure
List<List<String>> unchanged = listOfLists.stream()
    .collect(Collectors.toList());

// With flatMap - flattened
List<String> flattened = listOfLists.stream()
    .flatMap(List::stream)
    .collect(Collectors.toList());
// Result: [a, b, c, d]

// Real world: multiple arrays to single stream
int[][] arrays = {{1, 2}, {3, 4}, {5, 6}};
int[] flattened = Arrays.stream(arrays)
    .flatMapToInt(Arrays::stream)
    .toArray();
```

### sorted()
Sort elements:

```java
List<String> words = Arrays.asList("Java", "Stream", "API");

// Default order (String natural order)
words.stream()
    .sorted()
    .forEach(System.out::println); // API, Java, Stream

// Custom comparator
words.stream()
    .sorted(Comparator.comparingInt(String::length))
    .forEach(System.out::println); // API, Java, Stream

// Reverse order
words.stream()
    .sorted(Comparator.reverseOrder())
    .forEach(System.out::println); // Stream, Java, API
```

### distinct()
Remove duplicate elements:

```java
List<Integer> numbers = Arrays.asList(1, 2, 2, 3, 3, 3);

numbers.stream()
    .distinct()
    .forEach(System.out::println); // 1, 2, 3
```

### peek(Consumer)
Perform action without consuming stream (for debugging):

```java
List<Integer> numbers = Arrays.asList(1, 2, 3);

numbers.stream()
    .filter(n -> n > 1)
    .peek(n -> System.out.println("Filtered: " + n))
    .map(n -> n * 2)
    .peek(n -> System.out.println("Mapped: " + n))
    .forEach(System.out::println);

// Output:
// Filtered: 2
// Mapped: 4
// 4
// Filtered: 3
// Mapped: 6
// 6
```

### skip(long) and limit(long)
Skip and limit elements:

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Skip first 2, limit to 2 more
numbers.stream()
    .skip(2)
    .limit(2)
    .forEach(System.out::println); // 3, 4
```

---

## Terminal Operations

### forEach(Consumer)
Perform action for each element:

```java
List<String> words = Arrays.asList("Java", "Stream");
words.stream()
    .forEach(System.out::println);
```

### collect(Collector)
Gather into a collection:

```java
List<String> words = Arrays.asList("Java", "Stream", "API");

// To List
List<String> upper = words.stream()
    .map(String::toUpperCase)
    .collect(Collectors.toList());

// To Set
Set<String> unique = words.stream()
    .collect(Collectors.toSet());

// To Map
Map<String, Integer> lengths = words.stream()
    .collect(Collectors.toMap(
        w -> w,                    // key
        String::length             // value
    ));

// Joining strings
String joined = words.stream()
    .collect(Collectors.joining(", "));
// Result: "Java, Stream, API"

// Grouping by
Map<Integer, List<String>> byLength = words.stream()
    .collect(Collectors.groupingBy(String::length));
// Result: {3: [API], 4: [Java], 6: [Stream]}
```

### reduce(BinaryOperator)
Combine elements into single value:

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// Sum
int sum = numbers.stream()
    .reduce(0, Integer::sum); // 15

// Product
int product = numbers.stream()
    .reduce(1, (a, b) -> a * b); // 120

// Without initial value (returns Optional)
Optional<Integer> result = numbers.stream()
    .reduce((a, b) -> a + b); // Optional[15]

// String concatenation
List<String> words = Arrays.asList("Java", "Stream", "API");
String concat = words.stream()
    .reduce("", (a, b) -> a + b); // "JavaStreamAPI"
```

### match operations
Check if elements match a condition:

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// anyMatch - at least one matches
boolean hasEven = numbers.stream()
    .anyMatch(n -> n % 2 == 0); // true

// allMatch - all match
boolean allPositive = numbers.stream()
    .allMatch(n -> n > 0); // true

// noneMatch - none match
boolean noZeros = numbers.stream()
    .noneMatch(n -> n == 0); // true
```

### find operations
Find elements:

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

// findFirst - first element (or empty if no match)
Optional<Integer> first = numbers.stream()
    .filter(n -> n % 2 == 0)
    .findFirst(); // Optional[2]

// findAny - any element (useful for parallel streams)
Optional<Integer> any = numbers.stream()
    .filter(n -> n % 2 == 0)
    .findAny(); // Optional[2 or 4]
```

### count()
Count elements:

```java
List<String> words = Arrays.asList("Java", "Stream", "API");

long count = words.stream()
    .filter(w -> w.length() > 3)
    .count(); // 2
```

### min() and max()
Find minimum and maximum:

```java
List<Integer> numbers = Arrays.asList(3, 1, 4, 1, 5);

Optional<Integer> min = numbers.stream()
    .min(Comparator.naturalOrder()); // Optional[1]

Optional<Integer> max = numbers.stream()
    .max(Comparator.naturalOrder()); // Optional[5]

// Custom comparator
List<String> words = Arrays.asList("Java", "Stream", "API");
Optional<String> longest = words.stream()
    .max(Comparator.comparingInt(String::length)); // Optional[Stream]
```

---

## Primitive Streams

Working with primitives efficiently:

```java
// IntStream
IntStream.range(1, 5)
    .forEach(System.out::println); // 1, 2, 3, 4

// LongStream
LongStream.rangeClosed(1, 5)
    .forEach(System.out::println); // 1, 2, 3, 4, 5

// DoubleStream
DoubleStream.of(1.0, 2.5, 3.7)
    .forEach(System.out::println);

// Converting object stream to primitive
List<String> words = Arrays.asList("Java", "Stream");
int[] lengths = words.stream()
    .mapToInt(String::length)
    .toArray(); // [4, 6]

// Statistics
IntStream.of(1, 2, 3, 4, 5)
    .summaryStatistics();
    // count=5, sum=15, min=1, max=5, average=3.0
```

---

## Collectors Deep Dive

### Basic Collectors

```java
List<String> words = Arrays.asList("Java", "Stream", "API");

// To different collections
Collectors.toList();     // List
Collectors.toSet();      // Set
Collectors.toCollection(TreeSet::new); // Specific collection

// Joining
Collectors.joining(", ", "[", "]");
// Result: "[Java, Stream, API]"

// Mapping and summing
Collectors.summingInt(String::length); // 13

// Average
Collectors.averagingInt(String::length); // 4.33
```

### Grouping and Partitioning

```java
List<String> words = Arrays.asList("Java", "Stream", "API", "Go");

// Grouping
Map<Integer, List<String>> byLength = words.stream()
    .collect(Collectors.groupingBy(String::length));
// {2: [Go], 3: [API], 4: [Java], 6: [Stream]}

// Partitioning (grouping into two: true/false)
Map<Boolean, List<String>> partitioned = words.stream()
    .collect(Collectors.partitioningBy(w -> w.length() > 3));
// {false: [API, Go], true: [Java, Stream]}

// Count by group
Map<Integer, Long> countByLength = words.stream()
    .collect(Collectors.groupingBy(
        String::length,
        Collectors.counting()
    ));
```

---

## Common Patterns

### Finding Duplicates
```java
List<String> words = Arrays.asList("Java", "Stream", "Java", "API");

Set<String> duplicates = words.stream()
    .filter(w -> Collections.frequency(words, w) > 1)
    .collect(Collectors.toSet());
// Result: [Java]
```

### Removing Nulls
```java
List<String> words = Arrays.asList("Java", null, "Stream", null);

List<String> clean = words.stream()
    .filter(Objects::nonNull)
    .collect(Collectors.toList());
```

### Transforming Lists
```java
List<String> words = Arrays.asList("Java", "Stream");

List<String> uppercase = words.stream()
    .map(String::toUpperCase)
    .collect(Collectors.toList());
```

---

## Performance Considerations

1. **Lazy Evaluation** - Operations don't execute until terminal operation
2. **Short-circuit** - Some operations (findFirst, limit) stop early
3. **Stateless** - Intermediate operations should be stateless
4. **Parallelization** - Can use parallel streams for large datasets

---

## Next Steps

1. Practice writing complex stream pipelines
2. Explore parallel streams
3. Learn advanced collectors
4. Master stream debugging with peek()

