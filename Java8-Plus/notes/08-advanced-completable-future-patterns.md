# Advanced CompletableFuture Patterns

## Overview

This chapter builds on CompletableFuture fundamentals to cover production-grade patterns, advanced composition techniques, and real-world case studies for building robust asynchronous systems.

## Table of Contents

1. CompletionStage Interface Deep Dive
2. Exception Handling Strategies (5 Patterns)
3. Async Composition Chains
4. Handling Slow Operations & Timeouts
5. Memory & Resource Management
6. Context Propagation in Async Operations
7. Testing Async Code
8. Production Debugging & Monitoring
9. Real-World Case Studies

---

## 1. CompletionStage Interface Deep Dive

### Understanding CompletionStage vs CompletableFuture

```java
// CompletionStage - interface for composing dependent actions
public interface CompletionStage<T> {
    <U> CompletionStage<U> thenApply(Function<? super T, ? extends U> fn);
    CompletionStage<Void> thenAccept(Consumer<? super T> action);
    // ... more methods
}

// CompletableFuture - concrete implementation of CompletionStage
// Plus ability to manually complete the future
public class CompletableFuture<T> implements CompletionStage<T>, Future<T> {
    public boolean complete(T value);
    public boolean completeExceptionally(Throwable ex);
    // ... inherits all CompletionStage methods
}

// Best practice: Return CompletionStage, not CompletableFuture
public CompletionStage<String> fetchData(String id) {
    return CompletableFuture.supplyAsync(() -> "data");
}
```

### Order of Execution Guarantees

```java
public class ExecutionOrder {

    /**
     * Dependent stages execute in order
     */
    public static void demonstrateOrdering() {
        CompletableFuture.supplyAsync(() -> {
            System.out.println("1. First stage");
            return 1;
        })
        .thenApply(n -> {
            System.out.println("2. Second stage: " + n);
            return n + 1;
        })
        .thenApply(n -> {
            System.out.println("3. Third stage: " + n);
            return n + 1;
        });

        // Output order guaranteed:
        // 1. First stage
        // 2. Second stage: 1
        // 3. Third stage: 2
    }

    /**
     * Parallel stages have no guaranteed order
     */
    public static void demonstrateParallel() {
        CompletableFuture<Integer> stage1 = CompletableFuture.supplyAsync(() -> {
            System.out.println("Stage 1");
            return 1;
        });

        CompletableFuture<Integer> stage2 = CompletableFuture.supplyAsync(() -> {
            System.out.println("Stage 2");
            return 2;
        });

        // Order of stage1 and stage2 not guaranteed
        // Both execute concurrently
    }

    /**
     * applyToEither - First to complete wins
     */
    public static void demonstrateApplyToEither() {
        CompletableFuture<String> fast = CompletableFuture.supplyAsync(() -> {
            sleep(100);
            return "Fast";
        });

        CompletableFuture<String> slow = CompletableFuture.supplyAsync(() -> {
            sleep(1000);
            return "Slow";
        });

        // Executes with whichever completes first
        fast.applyToEither(slow, Function.identity())
            .thenAccept(System.out::println);  // "Fast"
    }
}
```

### Custom CompletionStage Implementation

```java
/**
 * Custom CompletionStage wrapping a value with metadata
 */
public class TrackedCompletionStage<T> implements CompletionStage<T> {
    private final CompletableFuture<T> delegate;
    private final long createdAt = System.currentTimeMillis();

    public TrackedCompletionStage(T value) {
        this.delegate = CompletableFuture.completedFuture(value);
    }

    public long getAgeMs() {
        return System.currentTimeMillis() - createdAt;
    }

    @Override
    public <U> CompletionStage<U> thenApply(Function<? super T, ? extends U> fn) {
        return delegate.thenApply(fn);
    }

    // ... implement other methods by delegating
}
```

---

## 2. Exception Handling Strategies (5 Patterns)

### Pattern 1: exceptionally() - Simple Fallback

```java
public CompletableFuture<String> getDataWithFallback(String id) {
    return CompletableFuture.supplyAsync(() -> {
        if (id.equals("invalid")) {
            throw new IllegalArgumentException("Invalid ID");
        }
        return "Data for " + id;
    })
    .exceptionally(ex -> {
        logger.error("Failed to get data", ex);
        return "Default value";  // Fallback
    });
}

// Usage
getDataWithFallback("invalid")
    .thenAccept(System.out::println);  // Prints "Default value"
```

### Pattern 2: handle() - Symmetric Error/Success

```java
public CompletableFuture<String> processWithHandling(int value) {
    return CompletableFuture.supplyAsync(() -> {
        if (value < 0) {
            throw new IllegalArgumentException("Must be positive");
        }
        return "Processed: " + value;
    })
    .handle((result, ex) -> {
        if (ex != null) {
            logger.error("Error occurred", ex);
            return "Error: " + ex.getMessage();
        }
        return result;
    });
}

// Usage
processWithHandling(-5)
    .thenAccept(System.out::println);  // "Error: Must be positive"
```

### Pattern 3: whenComplete() - Side Effects

```java
public CompletableFuture<String> getDataWithCleanup(String id) {
    return CompletableFuture.supplyAsync(() -> {
        System.out.println("Acquiring resource");
        return "Data: " + id;
    })
    .whenComplete((result, ex) -> {
        System.out.println("Cleanup (success=" + (ex == null) + ")");
        // Cleanup code - logging, metrics, etc.
    });
}

// Output:
// Acquiring resource
// Cleanup (success=true)
```

### Pattern 4: Nested Try-Catch in Stages

```java
public CompletableFuture<String> complexChain(String input) {
    return CompletableFuture.supplyAsync(() -> validateInput(input))
        .thenCompose(validated -> {
            try {
                return fetchData(validated);
            } catch (Exception e) {
                return CompletableFuture.failedFuture(e);
            }
        })
        .thenCompose(data -> {
            try {
                return transformData(data);
            } catch (Exception e) {
                return CompletableFuture.failedFuture(e);
            }
        })
        .exceptionally(ex -> {
            logger.error("Pipeline failed", ex);
            return "Default";
        });
}

private String validateInput(String input) throws Exception {
    if (input.isEmpty()) {
        throw new IllegalArgumentException("Empty input");
    }
    return input.trim();
}

private CompletableFuture<String> fetchData(String input) {
    return CompletableFuture.supplyAsync(() -> "fetched-" + input);
}

private CompletableFuture<String> transformData(String data) {
    return CompletableFuture.supplyAsync(() -> data.toUpperCase());
}
```

### Pattern 5: Custom Exception Wrapper with Retry

```java
public class RetryableCompletableFuture {

    private final int maxRetries;
    private final long delayMs;
    private final Predicate<Throwable> retryable;

    public <T> CompletableFuture<T> executeWithRetry(
            Supplier<CompletableFuture<T>> operation) {

        return executeWithRetryInternal(operation, 0);
    }

    private <T> CompletableFuture<T> executeWithRetryInternal(
            Supplier<CompletableFuture<T>> operation,
            int attemptNumber) {

        return operation.get()
            .exceptionally(ex -> {
                if (attemptNumber < maxRetries && retryable.test(ex)) {
                    logger.info("Retrying after exception (attempt {})", attemptNumber + 1);

                    // Schedule retry with delay
                    CompletableFuture<T> delayed = new CompletableFuture<>();
                    ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

                    scheduler.schedule(() -> {
                        try {
                            executeWithRetryInternal(operation, attemptNumber + 1)
                                .whenComplete((result, retryEx) -> {
                                    if (retryEx != null) {
                                        delayed.completeExceptionally(retryEx);
                                    } else {
                                        delayed.complete(result);
                                    }
                                });
                        } catch (Exception e) {
                            delayed.completeExceptionally(e);
                        }
                    }, delayMs * (attemptNumber + 1), TimeUnit.MILLISECONDS);

                    return delayed;
                }
                throw new CompletionException(ex);
            });
    }
}

// Usage
RetryableCompletableFuture retry = new RetryableCompletableFuture(
    3,  // maxRetries
    100,  // delayMs
    ex -> ex instanceof SocketTimeoutException  // retryable condition
);

retry.executeWithRetry(() -> callUnstableService())
    .thenAccept(System.out::println)
    .exceptionally(ex -> {
        logger.error("Failed after retries", ex);
        return null;
    });
```

---

## 3. Async Composition Chains

### Pipeline Pattern - Sequential Transformations

```java
public class PipelinePattern {

    /**
     * Process data through multiple stages
     * Validate → Transform → Enrich → Serialize
     */
    public CompletableFuture<String> processPipeline(String rawData) {
        return CompletableFuture.completedFuture(rawData)
            .thenApplyAsync(this::validate)
            .thenApplyAsync(this::transform)
            .thenApplyAsync(this::enrich)
            .thenApplyAsync(this::serialize);
    }

    private String validate(String data) {
        if (data.isEmpty()) throw new IllegalArgumentException("Empty data");
        return data;
    }

    private String transform(String data) {
        return data.trim().toLowerCase();
    }

    private String enrich(String data) {
        return data + "-enriched";
    }

    private String serialize(String data) {
        return "\"" + data + "\"";
    }

    // Benchmark
    public void benchmark() {
        long start = System.currentTimeMillis();

        processPipeline("  HELLO  ")
            .thenAccept(result -> {
                long elapsed = System.currentTimeMillis() - start;
                System.out.println("Result: " + result + ", Time: " + elapsed + "ms");
            })
            .join();
    }
}
```

### Parallel Composition - Multiple Independent Operations

```java
public class ParallelComposition {

    /**
     * Fetch from 3 independent sources in parallel
     */
    public CompletableFuture<AggregatedData> fetchFromMultipleSources(String id) {
        CompletableFuture<User> userFuture = fetchUserAsync(id);
        CompletableFuture<Account> accountFuture = fetchAccountAsync(id);
        CompletableFuture<Preferences> prefsFuture = fetchPreferencesAsync(id);

        // Combine all three
        return CompletableFuture.allOf(userFuture, accountFuture, prefsFuture)
            .thenApply(v -> new AggregatedData(
                userFuture.join(),
                accountFuture.join(),
                prefsFuture.join()
            ));
    }

    private CompletableFuture<User> fetchUserAsync(String id) {
        return CompletableFuture.supplyAsync(() -> {
            sleep(100);
            return new User(id, "John Doe");
        });
    }

    private CompletableFuture<Account> fetchAccountAsync(String id) {
        return CompletableFuture.supplyAsync(() -> {
            sleep(150);
            return new Account(id, 1000.0);
        });
    }

    private CompletableFuture<Preferences> fetchPreferencesAsync(String id) {
        return CompletableFuture.supplyAsync(() -> {
            sleep(80);
            return new Preferences(id, "dark-mode");
        });
    }

    // Records for data
    record User(String id, String name) {}
    record Account(String id, double balance) {}
    record Preferences(String id, String theme) {}
    record AggregatedData(User user, Account account, Preferences prefs) {}
}
```

### Fan-Out/Fan-In Pattern

```java
public class FanOutFanInPattern {

    /**
     * Process multiple items in parallel, aggregate results
     */
    public CompletableFuture<List<Result>> processBatch(List<String> items) {
        // Fan-out: Create futures for each item
        List<CompletableFuture<Result>> futures = items.stream()
            .map(item -> CompletableFuture.supplyAsync(() -> processItem(item)))
            .collect(Collectors.toList());

        // Fan-in: Wait for all and aggregate
        return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
            .thenApply(v -> futures.stream()
                .map(CompletableFuture::join)
                .collect(Collectors.toList()));
    }

    private Result processItem(String item) {
        sleep(50);
        return new Result(item, "processed-" + item);
    }

    record Result(String input, String output) {}
}
```

### Scatter-Gather Pattern

```java
public class ScatterGatherPattern {

    /**
     * Send request to multiple servers, return fastest response
     */
    public CompletableFuture<Response> scatterGather(String query) {
        List<String> servers = List.of("server1", "server2", "server3");

        // Scatter: Send to all servers
        List<CompletableFuture<Response>> futures = servers.stream()
            .map(server -> sendQueryAsync(server, query))
            .collect(Collectors.toList());

        // Gather: Combine and return first successful
        return CompletableFuture.anyOf(futures.toArray(new CompletableFuture[0]))
            .thenApply(result -> (Response) result);
    }

    private CompletableFuture<Response> sendQueryAsync(String server, String query) {
        return CompletableFuture.supplyAsync(() -> {
            long latency = (long) (Math.random() * 100);
            sleep(latency);
            return new Response(server, "Result from " + server);
        });
    }

    record Response(String server, String data) {}
}
```

---

## 4. Handling Slow Operations & Timeouts

### Timeout Pattern 1: orTimeout()

```java
public CompletableFuture<String> fetchWithTimeout(String url) {
    return CompletableFuture.supplyAsync(() -> {
        // Simulate slow network call
        sleep(5000);
        return "Data from " + url;
    })
    .orTimeout(2, TimeUnit.SECONDS);
    // Completes exceptionally if not done in 2 seconds
}

// Usage
fetchWithTimeout("http://example.com")
    .exceptionally(ex -> {
        if (ex instanceof TimeoutException) {
            logger.warn("Request timed out");
            return "default-value";
        }
        return "error-value";
    })
    .thenAccept(System.out::println);
```

### Timeout Pattern 2: applyToEither()

```java
public <T> CompletableFuture<T> withTimeout(
        CompletableFuture<T> future,
        long timeoutMs) {

    CompletableFuture<T> timeout = new CompletableFuture<>();

    ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    ScheduledFuture<?> task = scheduler.schedule(() -> {
        timeout.completeExceptionally(
            new TimeoutException("Operation exceeded " + timeoutMs + "ms")
        );
    }, timeoutMs, TimeUnit.MILLISECONDS);

    return future
        .applyToEither(timeout, Function.identity())
        .whenComplete((result, ex) -> task.cancel(false));
}

// Usage
withTimeout(slowAsyncOperation(), 2000)
    .thenAccept(System.out::println)
    .exceptionally(ex -> {
        logger.error("Timeout or error", ex);
        return null;
    });
```

### Timeout Pattern 3: completeOnTimeout()

```java
public CompletableFuture<String> fetchWithFallback(String url) {
    return CompletableFuture.supplyAsync(() -> {
        sleep(3000);
        return "Data from " + url;
    })
    .completeOnTimeout("cached-value", 1, TimeUnit.SECONDS);
    // Returns fallback value if not done in time
}
```

### Circuit Breaker Integration

```java
public class CircuitBreakerTimeout {

    private volatile boolean circuitOpen = false;
    private volatile long lastFailureTime = 0;
    private final long resetTimeMs = 30_000;  // 30 seconds

    public <T> CompletableFuture<T> callWithCircuitBreaker(
            Supplier<CompletableFuture<T>> operation,
            String serviceName) {

        if (circuitOpen && !shouldAttemptReset()) {
            return CompletableFuture.failedFuture(
                new Exception("Circuit breaker open for " + serviceName)
            );
        }

        return operation.get()
            .orTimeout(5, TimeUnit.SECONDS)
            .exceptionally(ex -> {
                lastFailureTime = System.currentTimeMillis();
                circuitOpen = true;
                logger.error("Service {} failed", serviceName, ex);
                return null;
            });
    }

    private boolean shouldAttemptReset() {
        return System.currentTimeMillis() - lastFailureTime >= resetTimeMs;
    }
}
```

---

## 5. Memory & Resource Management

### Memory Leaks in Async Operations

```java
public class MemoryLeakExample {

    // PROBLEM: Memory leak
    public CompletableFuture<String> leakyChain() {
        List<String> largeData = new ArrayList<>();
        for (int i = 0; i < 1_000_000; i++) {
            largeData.add("data-" + i);  // Large list captured
        }

        return CompletableFuture.supplyAsync(() -> {
            // largeData is captured in closure, kept in memory!
            return largeData.size() + " items";
        });
    }

    // SOLUTION: Extract data early
    public CompletableFuture<String> fixedChain() {
        List<String> largeData = new ArrayList<>();
        for (int i = 0; i < 1_000_000; i++) {
            largeData.add("data-" + i);
        }

        int size = largeData.size();
        largeData = null;  // Release reference

        return CompletableFuture.supplyAsync(() -> {
            return size + " items";  // size is primitive, not captured
        });
    }

    // SOLUTION: Use CompletableFuture in scope
    public void properResourceManagement() {
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            byte[] largeBuffer = new byte[10 * 1024 * 1024];  // 10MB
            Arrays.fill(largeBuffer, (byte) 1);
            return "processed";
        });

        future.thenAccept(System.out::println);
        // Future goes out of scope, can be GC'd after completion
    }
}
```

### Thread Pool Exhaustion

```java
public class ThreadPoolExhaustion {

    private final ExecutorService executor = Executors.newFixedThreadPool(10);

    // PROBLEM: Queue grows unbounded
    public void badApproach(List<Item> items) {
        for (Item item : items) {
            // If processing is slow, queue grows
            executor.execute(() -> processItem(item));
        }
    }

    // SOLUTION: Rate limiting with semaphore
    public void goodApproach(List<Item> items) throws InterruptedException {
        Semaphore semaphore = new Semaphore(100);  // Max 100 pending

        for (Item item : items) {
            semaphore.acquire();
            executor.execute(() -> {
                try {
                    processItem(item);
                } finally {
                    semaphore.release();
                }
            });
        }
    }

    // SOLUTION: Batch processing
    public CompletableFuture<Void> batchProcessing(List<Item> items) {
        final int BATCH_SIZE = 100;
        List<CompletableFuture<Void>> batches = new ArrayList<>();

        for (int i = 0; i < items.size(); i += BATCH_SIZE) {
            int end = Math.min(i + BATCH_SIZE, items.size());
            List<Item> batch = items.subList(i, end);

            CompletableFuture<Void> batchFuture = CompletableFuture.runAsync(() -> {
                batch.forEach(this::processItem);
            }, executor);

            batches.add(batchFuture);
        }

        return CompletableFuture.allOf(batches.toArray(new CompletableFuture[0]));
    }

    private void processItem(Item item) {
        // Processing logic
    }

    static class Item {}
}
```

### Stack Overflow with Deep Nesting

```java
public class DeepNestingProblem {

    // PROBLEM: Deep chain causes stack overflow
    public CompletableFuture<Integer> deepChain(int depth) {
        if (depth == 0) {
            return CompletableFuture.completedFuture(0);
        }
        return deepChain(depth - 1)
            .thenApply(n -> n + 1);  // Each thenApply adds to stack
    }

    // SOLUTION: Use iteration instead of recursion
    public CompletableFuture<Integer> iterativeChain(int iterations) {
        CompletableFuture<Integer> result = CompletableFuture.completedFuture(0);

        for (int i = 0; i < iterations; i++) {
            result = result.thenApply(n -> n + 1);
        }

        return result;
    }

    // SOLUTION: Use thenCompose for flat chaining
    public CompletableFuture<Integer> flatChain(int iterations) {
        CompletableFuture<Integer> result = CompletableFuture.completedFuture(0);

        for (int i = 0; i < iterations; i++) {
            result = result.thenCompose(n ->
                CompletableFuture.completedFuture(n + 1)
            );
        }

        return result;
    }
}
```

---

## 6. Context Propagation in Async Operations

### ThreadLocal Propagation

```java
public class ContextPropagation {

    private static final ThreadLocal<String> userId = new ThreadLocal<>();
    private static final ThreadLocal<String> requestId = new ThreadLocal<>();

    public CompletableFuture<String> processWithContext(String id) {
        // Capture context in main thread
        String capturedUserId = userId.get();
        String capturedRequestId = requestId.get();

        return CompletableFuture.supplyAsync(() -> {
            // In async thread, context is lost!
            // Solution: Restore it manually
            userId.set(capturedUserId);
            requestId.set(capturedRequestId);

            try {
                logger.info("Processing for user: {}, request: {}",
                    userId.get(), requestId.get());
                return performWork();
            } finally {
                userId.remove();
                requestId.remove();
            }
        });
    }

    private String performWork() {
        return "work done";
    }

    // Wrapper for automatic context propagation
    public <T> CompletableFuture<T> withContext(
            Supplier<CompletableFuture<T>> operation) {

        String capturedUserId = userId.get();
        String capturedRequestId = requestId.get();

        return CompletableFuture.supplyAsync(() -> {
            userId.set(capturedUserId);
            requestId.set(capturedRequestId);
            return null;
        }).thenCompose(v -> operation.get())
          .whenComplete((result, ex) -> {
              userId.remove();
              requestId.remove();
          });
    }
}
```

### MDC (Mapped Diagnostic Context) Propagation

```java
public class MDCPropagation {

    /**
     * Propagate SLF4J MDC across async operations
     */
    public CompletableFuture<String> processMDC(String requestId) {
        // Capture MDC in current thread
        Map<String, String> mdc = MDC.getCopyOfContextMap();

        return CompletableFuture.supplyAsync(() -> {
            // Restore MDC in async thread
            if (mdc != null) {
                MDC.setContextMap(mdc);
            }

            try {
                logger.info("Processing request: {}", MDC.get("requestId"));
                return doWork();
            } finally {
                MDC.clear();
            }
        });
    }

    // Helper to create async futures with MDC propagation
    public <T> CompletableFuture<T> supplyAsyncWithMDC(
            Supplier<T> supplier) {

        Map<String, String> mdc = MDC.getCopyOfContextMap();

        return CompletableFuture.supplyAsync(() -> {
            if (mdc != null) {
                MDC.setContextMap(mdc);
            }

            try {
                return supplier.get();
            } finally {
                MDC.clear();
            }
        });
    }

    private String doWork() {
        return "work completed";
    }
}
```

---

## 7. Testing Async Code

### Unit Testing CompletableFuture

```java
public class AsyncTestingExample {

    @Test
    public void testAsyncCompletion() throws Exception {
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            sleep(100);
            return "result";
        });

        String result = future.get(2, TimeUnit.SECONDS);
        assertEquals("result", result);
    }

    @Test
    public void testAsyncException() throws Exception {
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            throw new RuntimeException("Error");
        });

        assertThrows(ExecutionException.class, () -> {
            future.get(2, TimeUnit.SECONDS);
        });
    }

    @Test
    public void testAsyncChain() throws Exception {
        CompletableFuture<Integer> result = CompletableFuture.supplyAsync(() -> 5)
            .thenApply(n -> n * 2)
            .thenApply(n -> n + 3);

        assertEquals(13, result.get(2, TimeUnit.SECONDS));
    }

    @Test
    public void testAsyncTimeout() {
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            sleep(5000);
            return "result";
        });

        assertThrows(TimeoutException.class, () -> {
            future.get(1, TimeUnit.SECONDS);
        });
    }
}
```

### Mocking Async Operations

```java
public class AsyncMockingExample {

    @Mock
    private UserService userService;

    @Test
    public void testWithMockedAsync() throws Exception {
        CompletableFuture<User> mockedFuture = CompletableFuture.completedFuture(
            new User(1, "John")
        );

        when(userService.fetchUserAsync(1)).thenReturn(mockedFuture);

        CompletableFuture<String> result = userService.fetchUserAsync(1)
            .thenApply(user -> user.name().toUpperCase());

        assertEquals("JOHN", result.get(2, TimeUnit.SECONDS));
    }

    @Test
    public void testWithFailedAsync() throws Exception {
        CompletableFuture<User> failedFuture = new CompletableFuture<>();
        failedFuture.completeExceptionally(new RuntimeException("Service error"));

        when(userService.fetchUserAsync(999)).thenReturn(failedFuture);

        CompletableFuture<String> result = userService.fetchUserAsync(999)
            .exceptionally(ex -> "error: " + ex.getMessage());

        assertEquals("error: Service error", result.get(2, TimeUnit.SECONDS));
    }

    record User(int id, String name) {}

    interface UserService {
        CompletableFuture<User> fetchUserAsync(int id);
    }
}
```

---

## 8. Production Debugging & Monitoring

### Monitoring Async Queue Depths

```java
public class AsyncMonitoring {

    private final ThreadPoolExecutor executor = (ThreadPoolExecutor)
        Executors.newFixedThreadPool(10);

    public void monitorAsyncOperations() {
        ScheduledExecutorService monitor = Executors.newScheduledThreadPool(1);

        monitor.scheduleAtFixedRate(() -> {
            int activeCount = executor.getActiveCount();
            int queueSize = executor.getQueue().size();
            long completedCount = executor.getCompletedTaskCount();

            System.out.printf("Active: %d, Queue: %d, Completed: %d%n",
                activeCount, queueSize, completedCount);

            // Alert if queue is growing
            if (queueSize > 1000) {
                logger.warn("Async queue depth exceeding threshold: {}", queueSize);
            }
        }, 0, 10, TimeUnit.SECONDS);
    }

    public <T> CompletableFuture<T> executeWithMetrics(
            String operationName,
            Supplier<CompletableFuture<T>> operation) {

        long startTime = System.currentTimeMillis();

        return operation.get()
            .whenComplete((result, ex) -> {
                long duration = System.currentTimeMillis() - startTime;

                if (ex == null) {
                    logger.info("Operation {} completed in {}ms", operationName, duration);
                } else {
                    logger.error("Operation {} failed after {}ms", operationName, duration, ex);
                }
            });
    }
}
```

---

## 9. Real-World Case Studies

### Case Study 1: REST API Aggregation

```java
public class APIAggregationService {

    private final HttpClient httpClient;
    private final ExecutorService executor;

    /**
     * Fetch from 3-5 endpoints, combine results
     */
    public CompletableFuture<UserProfile> getUserProfile(String userId) {
        CompletableFuture<User> userFuture = fetchUserAsync(userId);
        CompletableFuture<Account> accountFuture = fetchAccountAsync(userId);
        CompletableFuture<Preferences> prefsFuture = fetchPreferencesAsync(userId);

        return CompletableFuture.allOf(userFuture, accountFuture, prefsFuture)
            .thenApply(v -> new UserProfile(
                userFuture.join(),
                accountFuture.join(),
                prefsFuture.join()
            ))
            .orTimeout(5, TimeUnit.SECONDS)
            .exceptionally(ex -> {
                logger.error("Failed to aggregate user profile", ex);
                return UserProfile.empty();
            });
    }

    private CompletableFuture<User> fetchUserAsync(String id) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                return httpClient.get("/users/" + id, User.class);
            } catch (Exception e) {
                throw new CompletionException(e);
            }
        }, executor)
        .exceptionally(ex -> {
            logger.warn("Failed to fetch user, using fallback");
            return User.empty();
        });
    }

    private CompletableFuture<Account> fetchAccountAsync(String id) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                return httpClient.get("/accounts/" + id, Account.class);
            } catch (Exception e) {
                throw new CompletionException(e);
            }
        }, executor)
        .orTimeout(3, TimeUnit.SECONDS)
        .exceptionally(ex -> Account.empty());
    }

    private CompletableFuture<Preferences> fetchPreferencesAsync(String id) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                return httpClient.get("/preferences/" + id, Preferences.class);
            } catch (Exception e) {
                throw new CompletionException(e);
            }
        }, executor);
    }

    // Domain objects
    record User(String id, String name) {
        static User empty() { return new User("", "N/A"); }
    }
    record Account(String id, double balance) {
        static Account empty() { return new Account("", 0); }
    }
    record Preferences(String id, String theme) {}
    record UserProfile(User user, Account account, Preferences prefs) {
        static UserProfile empty() {
            return new UserProfile(User.empty(), Account.empty(),
                new Preferences("", "default"));
        }
    }

    class HttpClient {
        <T> T get(String path, Class<T> type) throws Exception {
            sleep(50);  // Simulate network latency
            return type.getDeclaredConstructor().newInstance();
        }
    }
}
```

---

## Summary

This chapter covered advanced CompletableFuture patterns for production use:

- ✅ CompletionStage interface and composition guarantees
- ✅ 5 exception handling patterns for different scenarios
- ✅ Pipeline, parallel, fan-out/fan-in composition patterns
- ✅ Timeout handling with 3 different approaches
- ✅ Memory management and preventing leaks
- ✅ Context propagation across async boundaries
- ✅ Testing strategies for async code
- ✅ Production monitoring and debugging
- ✅ Real-world case studies with complete examples

Use these patterns to build robust, efficient, and maintainable asynchronous systems in Java.
