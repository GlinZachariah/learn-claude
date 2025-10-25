# CompletableFuture: Asynchronous Programming in Java

## Overview

`CompletableFuture` is a powerful API introduced in Java 8 for handling asynchronous computations. It provides a way to write non-blocking code that is more readable and manageable than traditional callback-based approaches.

## Key Concepts

### What is CompletableFuture?

CompletableFuture is a class that represents a future result of an asynchronous computation. Unlike the older `Future` interface, it can be:
- Manually completed
- Combined with other futures
- Transformed through functional operations

### Basic Structure

```java
// Create an already-completed future
CompletableFuture<String> future = CompletableFuture.completedFuture("Hello");

// Create a future that will be completed later
CompletableFuture<String> future = new CompletableFuture<>();
future.complete("Result");
```

## Creating CompletableFutures

### 1. Static Creation Methods

```java
// Completed immediately with value
CompletableFuture<String> cf1 = CompletableFuture.completedFuture("Done");

// Completed with exception
CompletableFuture<String> cf2 = CompletableFuture.failedFuture(
    new RuntimeException("Error")
);

// Empty future that can be completed manually
CompletableFuture<String> cf3 = new CompletableFuture<>();
```

### 2. Running Asynchronous Code

```java
// Run without result (ForkJoinPool.commonPool())
CompletableFuture<Void> future1 = CompletableFuture.runAsync(() -> {
    System.out.println("Async task executed");
});

// Supply a result (ForkJoinPool.commonPool())
CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> {
    return "Result from async computation";
});

// Using custom executor
ExecutorService executor = Executors.newFixedThreadPool(10);
CompletableFuture<String> future3 = CompletableFuture.supplyAsync(
    () -> "Custom executor result",
    executor
);
```

## Chaining Operations

### 1. thenApply() - Transform Result

```java
CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> 10)
    .thenApply(x -> x * 2)        // Transforms 10 to 20
    .thenApply(x -> x + 5);       // Transforms 20 to 25

// Result: 25
```

### 2. thenAccept() - Consume Result

```java
CompletableFuture.supplyAsync(() -> "Hello")
    .thenAccept(result -> System.out.println("Result: " + result));
    // No return value, just side effects
```

### 3. thenRun() - Execute After Completion

```java
CompletableFuture.supplyAsync(() -> "Task")
    .thenRun(() -> System.out.println("Task completed!"));
    // Doesn't care about the result
```

### 4. Chain Multiple Futures

```java
// Dependent futures - second waits for first
CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> {
    sleep(1000);
    return "First task";
});

CompletableFuture<String> result = future1
    .thenCompose(first -> {
        // second task depends on first task's result
        return CompletableFuture.supplyAsync(() -> first + " - Second task");
    });
```

## Combining Multiple Futures

### 1. thenCombine() - Combine Two Results

```java
CompletableFuture<Integer> future1 = CompletableFuture.supplyAsync(() -> 10);
CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(() -> 20);

CompletableFuture<Integer> combined = future1
    .thenCombine(future2, (a, b) -> a + b);
    // Result: 30
```

### 2. allOf() - Wait for All Futures

```java
CompletableFuture<Integer> cf1 = CompletableFuture.supplyAsync(() -> 1);
CompletableFuture<Integer> cf2 = CompletableFuture.supplyAsync(() -> 2);
CompletableFuture<Integer> cf3 = CompletableFuture.supplyAsync(() -> 3);

// Wait for all to complete
CompletableFuture.allOf(cf1, cf2, cf3)
    .thenRun(() -> {
        System.out.println("All tasks completed");
    });
```

### 3. anyOf() - Wait for First to Complete

```java
CompletableFuture<Integer> cf1 = CompletableFuture.supplyAsync(() -> 1);
CompletableFuture<Integer> cf2 = CompletableFuture.supplyAsync(() -> 2);

// Completes as soon as any future completes
CompletableFuture<Object> first = CompletableFuture.anyOf(cf1, cf2);
```

## Error Handling

### 1. exceptionally() - Handle Exception

```java
CompletableFuture.supplyAsync(() -> {
    throw new RuntimeException("Error occurred");
})
.exceptionally(ex -> {
    System.out.println("Caught: " + ex.getMessage());
    return "Default value";
});
```

### 2. handle() - Handle Both Success and Failure

```java
CompletableFuture.supplyAsync(() -> 10 / 0)  // Division by zero
    .handle((result, ex) -> {
        if (ex != null) {
            System.out.println("Error: " + ex.getMessage());
            return -1;
        }
        return result;
    });
```

### 3. whenComplete() - Side Effect for Both Cases

```java
CompletableFuture.supplyAsync(() -> "Success")
    .whenComplete((result, ex) -> {
        if (ex == null) {
            System.out.println("Success: " + result);
        } else {
            System.out.println("Failed: " + ex.getMessage());
        }
    });
```

## Practical Examples

### Example 1: Fetching Data from Multiple Sources

```java
public class DataFetcher {

    public CompletableFuture<UserData> fetchUserData(int userId) {
        return CompletableFuture.supplyAsync(() -> {
            // Call API
            return getUserFromDatabase(userId);
        });
    }

    public CompletableFuture<UserProfile> fetchUserProfile(int userId) {
        return CompletableFuture.supplyAsync(() -> {
            // Call API
            return getUserProfile(userId);
        });
    }

    // Combine both
    public CompletableFuture<CombinedUserData> getUserCompleteInfo(int userId) {
        return fetchUserData(userId)
            .thenCombine(fetchUserProfile(userId), (userData, profile) -> {
                return new CombinedUserData(userData, profile);
            });
    }
}
```

### Example 2: Timeout Handling

```java
public <T> CompletableFuture<T> withTimeout(
        CompletableFuture<T> future,
        long timeoutMs) {

    CompletableFuture<T> timeout = new CompletableFuture<>();

    Executors.newScheduledThreadPool(1).schedule(() -> {
        timeout.completeExceptionally(
            new TimeoutException("Operation timed out")
        );
    }, timeoutMs, TimeUnit.MILLISECONDS);

    return future.applyToEither(timeout, Function.identity());
}
```

### Example 3: Retry Logic

```java
public <T> CompletableFuture<T> retryAsync(
        Supplier<CompletableFuture<T>> supplier,
        int retries) {

    return supplier.get()
        .exceptionally(ex -> {
            if (retries > 0) {
                return retryAsync(supplier, retries - 1).join();
            }
            throw new CompletionException(ex);
        });
}
```

## Advanced Patterns

### 1. Pipeline Pattern

```java
public class Pipeline {

    public static <T> CompletableFuture<String> process(T input) {
        return CompletableFuture
            .supplyAsync(() -> validate(input))
            .thenCompose(validated -> transform(validated))
            .thenCompose(transformed -> enrich(transformed))
            .thenApply(Object::toString);
    }
}
```

### 2. Sequential Execution

```java
public CompletableFuture<List<String>> processSequentially(List<Integer> ids) {
    List<CompletableFuture<String>> futures = ids.stream()
        .map(id -> fetchData(id))
        .collect(Collectors.toList());

    return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
        .thenApply(v -> futures.stream()
            .map(CompletableFuture::join)
            .collect(Collectors.toList()));
}
```

### 3. Fallback Pattern

```java
public <T> CompletableFuture<T> withFallback(
        CompletableFuture<T> primary,
        CompletableFuture<T> fallback) {

    return primary.exceptionally(ex -> {
        return fallback.join();
    });
}
```

## Best Practices

### 1. Always Provide Executor for I/O Operations

```java
// BAD - Uses default ForkJoinPool
CompletableFuture.supplyAsync(() -> blockingIOCall());

// GOOD - Uses dedicated executor
ExecutorService ioExecutor = Executors.newFixedThreadPool(20);
CompletableFuture.supplyAsync(() -> blockingIOCall(), ioExecutor);
```

### 2. Handle Exceptions Properly

```java
// BAD - Exception silently ignored
CompletableFuture.supplyAsync(() -> riskyOperation());

// GOOD - Exception handled
CompletableFuture.supplyAsync(() -> riskyOperation())
    .exceptionally(ex -> {
        logger.error("Operation failed", ex);
        return defaultValue;
    });
```

### 3. Don't Block on join() in Loops

```java
// BAD - Blocks main thread
for (int i = 0; i < 10; i++) {
    CompletableFuture.supplyAsync(() -> process(i))
        .join();  // BLOCKING!
}

// GOOD - Non-blocking
List<CompletableFuture<Result>> futures = new ArrayList<>();
for (int i = 0; i < 10; i++) {
    futures.add(CompletableFuture.supplyAsync(() -> process(i)));
}
CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();
```

### 4. Resource Management

```java
ExecutorService executor = Executors.newFixedThreadPool(10);
try {
    CompletableFuture.supplyAsync(() -> task(), executor)
        .thenAccept(System.out::println)
        .join();
} finally {
    executor.shutdown();
}
```

## Comparison with Other Approaches

| Aspect | Callback | Future | CompletableFuture |
|--------|----------|--------|-------------------|
| Readability | Poor (Callback Hell) | Moderate | Excellent |
| Composability | Difficult | Limited | Excellent |
| Error Handling | Manual | Limited | Built-in |
| Chaining | Complex | Moderate | Simple |
| Blocking | Yes (get()) | Yes (get()) | Optional |

## Common Pitfalls

### 1. Exception Swallowing

```java
// BAD - Exception lost
CompletableFuture.supplyAsync(() -> throwException())
    .thenApply(x -> x * 2);  // Exception not propagated

// GOOD - Exception handled
CompletableFuture.supplyAsync(() -> throwException())
    .thenApply(x -> x * 2)
    .exceptionally(ex -> {
        logger.error("Error", ex);
        return defaultValue;
    });
```

### 2. Using get() Without Timeout

```java
// BAD - Can hang indefinitely
CompletableFuture<String> future = CompletableFuture.supplyAsync(
    () -> veryLongRunningTask()
);
String result = future.get();  // What if it never completes?

// GOOD - Timeout protection
String result = future.get(5, TimeUnit.SECONDS);
```

## Summary

CompletableFuture provides:
- ✅ Non-blocking asynchronous operations
- ✅ Easy composition and chaining
- ✅ Functional programming support
- ✅ Built-in error handling
- ✅ Flexibility in combining multiple futures

Use it for:
- Parallel API calls
- Non-blocking I/O operations
- Event-driven programming
- Microservices communication
