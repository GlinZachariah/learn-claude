# Expert & Architect Level Questions - Java 8+

These questions are designed for experienced developers and architects. They focus on system design, architectural decisions, design patterns, scalability, reliability, and production-grade concerns.

---

## System Design & Architecture

### Question 1: Designing a High-Performance Caching Layer

**Question:** Design a multi-level caching system for a microservices architecture handling 100K requests/second. Include considerations for:
- Cache invalidation strategies
- Consistency guarantees
- Partition tolerance
- Fallback mechanisms

**Answer:**

```java
/**
 * Multi-level cache architecture for high-traffic systems
 * L1: In-process cache (Caffeine) - Local, fast
 * L2: Distributed cache (Redis) - Shared, reliable
 * L3: Persistent storage (Database) - Ultimate source of truth
 */

public class MultiLevelCacheArchitecture {

    // L1: Local cache with automatic expiration
    private final LoadingCache<String, CacheData> l1Cache = Caffeine.newBuilder()
        .maximumSize(10000)
        .expireAfterWrite(5, TimeUnit.MINUTES)
        .recordStats()
        .build(key -> l2Cache.get(key));

    // L2: Distributed Redis cache
    private final RedisCache l2Cache;

    // Cache invalidation event bus
    private final EventBus cacheInvalidationBus;

    public <T> T get(String key, Class<T> type, long ttlMinutes) {
        try {
            // Try L1
            CacheData cached = l1Cache.getIfPresent(key);
            if (cached != null && !cached.isExpired()) {
                return cached.getValue();
            }

            // Try L2
            String l2Value = l2Cache.get(key);
            if (l2Value != null) {
                T value = deserialize(l2Value, type);
                l1Cache.put(key, new CacheData(value, ttlMinutes));
                return value;
            }

            return null;
        } catch (Exception e) {
            logger.error("Cache retrieval failed, using fallback", e);
            return null;  // Fallback to database
        }
    }

    public <T> void put(String key, T value, long ttlMinutes) {
        try {
            // Write to L2 first (most reliable)
            String serialized = serialize(value);
            l2Cache.setex(key, ttlMinutes * 60, serialized);

            // Then to L1
            l1Cache.put(key, new CacheData(value, ttlMinutes));

            // Publish invalidation event for cache coherency
            cacheInvalidationBus.post(new CacheUpdatedEvent(key));
        } catch (Exception e) {
            logger.error("Cache write failed", e);
            // Still accessible from database, degraded but functional
        }
    }

    /**
     * Cache invalidation with eventual consistency
     * - Immediate: Local cache
     * - 100-500ms: Distributed cache across cluster
     * - Eventually consistent
     */
    public void invalidate(String key) {
        l1Cache.invalidate(key);
        l2Cache.delete(key);
        cacheInvalidationBus.post(new CacheInvalidatedEvent(key));
    }

    /**
     * Handle cache stampede/thundering herd
     * Only one thread loads the value, others wait
     */
    private final Map<String, CompletableFuture<?>> loadingFutures = new ConcurrentHashMap<>();

    public <T> CompletableFuture<T> getAsync(String key, Class<T> type) {
        return (CompletableFuture<T>) loadingFutures.compute(key, (k, existing) -> {
            if (existing != null) return existing;  // Wait for ongoing load

            return CompletableFuture.supplyAsync(() -> {
                // Load from L2 or database
                return l2Cache.get(key);
            });
        });
    }
}

// Cache data with metadata
class CacheData {
    private final Object value;
    private final long expiryTime;

    public CacheData(Object value, long ttlMinutes) {
        this.value = value;
        this.expiryTime = System.currentTimeMillis() + ttlMinutes * 60000;
    }

    public boolean isExpired() {
        return System.currentTimeMillis() > expiryTime;
    }

    public <T> T getValue() {
        return (T) value;
    }
}
```

**Key Considerations:**
- **Consistency:** Use event-driven invalidation (eventual consistency)
- **Scalability:** L2 cache distributes load across cluster
- **Reliability:** Graceful degradation - fallback to database if cache fails
- **Thundering Herd:** Use CompletableFuture to serialize cache loading

---

### Question 2: CompletableFuture vs Virtual Threads (Project Loom)

**Question:** When designing a reactive system to handle 1M concurrent connections, what are the tradeoffs between:
1. CompletableFuture with thread pools
2. Virtual threads (when available)
3. Reactive libraries (RxJava, Project Reactor)

**Answer:**

```java
// APPROACH 1: CompletableFuture with bounded thread pools
public class CompletableFutureApproach {
    private final ExecutorService ioExecutor = Executors.newFixedThreadPool(100);
    private final ExecutorService cpuExecutor = Executors.newFixedThreadPool(
        Runtime.getRuntime().availableProcessors()
    );

    public CompletableFuture<Response> handleRequest(Request req) {
        return CompletableFuture
            .supplyAsync(() -> validateRequest(req), cpuExecutor)
            .thenCompose(validated -> fetchDataAsync(validated, ioExecutor))
            .thenCompose(data -> enrichDataAsync(data, ioExecutor))
            .thenApply(enriched -> formatResponse(enriched))
            .exceptionally(ex -> {
                logger.error("Request failed", ex);
                return Response.error(ex);
            });
    }

    // Tradeoffs:
    // ✅ Composable, readable, non-blocking
    // ✅ Works on Java 8+
    // ❌ Thread pool management complexity
    // ❌ Fixed thread counts limit scalability
    // ❌ Context switching overhead with many threads
}

// APPROACH 2: Virtual Threads (Java 19+)
public class VirtualThreadApproach {
    private final ExecutorService virtualThreadExecutor =
        Executors.newVirtualThreadPerTaskExecutor();

    public Response handleRequest(Request req) {
        Future<Response> future = virtualThreadExecutor.submit(() -> {
            // Can use blocking I/O naturally
            Response response = blockingFetch(req);
            response = enrich(response);
            return response;
        });

        return future.get();
    }

    // Tradeoffs:
    // ✅ Millions of lightweight threads possible
    // ✅ Natural, blocking-style code
    // ✅ Minimal context switching overhead
    // ❌ Java 19+ requirement
    // ❌ Requires careful handling of pinned carriers
    // ❌ Still uses OS threads under the hood for pinning cases
}

// APPROACH 3: Reactive Library (Project Reactor)
public class ReactiveApproach {
    private final WebClient webClient;

    public Mono<Response> handleRequest(Request req) {
        return Mono.just(req)
            .flatMap(this::validateAsync)
            .flatMap(validated -> fetchDataMono(validated))
            .flatMap(data -> enrichDataMono(data))
            .map(enriched -> formatResponse(enriched))
            .onErrorResume(ex -> {
                logger.error("Request failed", ex);
                return Mono.just(Response.error(ex));
            });
    }

    // Tradeoffs:
    // ✅ Truly non-blocking (no threads for each operation)
    // ✅ Efficient backpressure handling
    // ✅ Pure asynchronous
    // ❌ Steep learning curve
    // ❌ Must use reactive libraries throughout stack
    // ❌ Debugging more complex
}

// RECOMMENDATION MATRIX:
// High concurrency (1M+), Java 19+  → Virtual Threads
// High concurrency, Java 8-18       → Reactive Libraries
// Moderate load, blocking code OK   → CompletableFuture
// Greenfield project, heavy I/O     → Virtual Threads or Reactive
```

**Decision Factors:**
- **Connection count:** Virtual Threads (millions) > CompletableFuture (thousands)
- **Code style:** CompletableFuture (imperative) vs Reactive (declarative)
- **Ecosystem maturity:** CompletableFuture, Reactive (stable) vs Virtual Threads (new)
- **Pinning risk:** Consider CPU-bound blocking in virtual threads

---

## Design Patterns & Reliability

### Question 3: Circuit Breaker Pattern with CompletableFuture

**Question:** Implement a resilient service client using the Circuit Breaker pattern. Handle cascading failures, timeouts, and provide observability.

**Answer:**

```java
public class ResilientServiceClient {

    public enum CircuitState {
        CLOSED,        // Normal operation
        OPEN,          // Failing, reject requests
        HALF_OPEN      // Testing if service recovered
    }

    private volatile CircuitState state = CircuitState.CLOSED;
    private volatile long lastFailureTime;
    private volatile int failureCount;
    private volatile int successCount;

    private final int failureThreshold = 5;
    private final int successThreshold = 2;
    private final long timeout = 30_000;  // 30 seconds before retry
    private final long callTimeout = 5_000;  // 5 second call timeout

    private final ExecutorService executor = Executors.newFixedThreadPool(10);
    private final Metrics metrics = new Metrics();

    /**
     * Call with circuit breaker protection
     */
    public <T> CompletableFuture<T> callWithCircuitBreaker(
            String serviceName,
            Supplier<CompletableFuture<T>> operation) {

        if (state == CircuitState.OPEN) {
            if (shouldAttemptReset()) {
                state = CircuitState.HALF_OPEN;
                successCount = 0;
            } else {
                return failedFuture(
                    new CircuitBreakerOpenException(
                        "Circuit breaker is OPEN for " + serviceName
                    )
                );
            }
        }

        return callWithTimeout(operation)
            .thenApply(result -> {
                onSuccess();
                metrics.recordSuccess(serviceName);
                return result;
            })
            .exceptionally(ex -> {
                onFailure(serviceName, ex);
                return null;
            });
    }

    /**
     * Add timeout protection
     */
    private <T> CompletableFuture<T> callWithTimeout(
            Supplier<CompletableFuture<T>> operation) {

        CompletableFuture<T> result = operation.get();
        CompletableFuture<T> timeout = new CompletableFuture<>();

        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
        ScheduledFuture<?> task = scheduler.schedule(() -> {
            timeout.completeExceptionally(
                new TimeoutException("Operation timed out after " + callTimeout + "ms")
            );
        }, callTimeout, TimeUnit.MILLISECONDS);

        return result
            .applyToEither(timeout, Function.identity())
            .whenComplete((r, ex) -> task.cancel(false));
    }

    private void onSuccess() {
        failureCount = 0;

        if (state == CircuitState.HALF_OPEN) {
            successCount++;
            if (successCount >= successThreshold) {
                state = CircuitState.CLOSED;
                successCount = 0;
                logger.info("Circuit breaker CLOSED - Service recovered");
            }
        }
    }

    private void onFailure(String serviceName, Throwable ex) {
        failureCount++;
        lastFailureTime = System.currentTimeMillis();
        metrics.recordFailure(serviceName, ex);

        if (failureCount >= failureThreshold) {
            state = CircuitState.OPEN;
            logger.error("Circuit breaker OPEN for " + serviceName, ex);
        }
    }

    private boolean shouldAttemptReset() {
        return System.currentTimeMillis() - lastFailureTime >= timeout;
    }

    private <T> CompletableFuture<T> failedFuture(Throwable ex) {
        CompletableFuture<T> failed = new CompletableFuture<>();
        failed.completeExceptionally(ex);
        return failed;
    }
}

// Retry policy with exponential backoff
public class RetryPolicy {
    private final int maxRetries = 3;
    private final long initialDelay = 100;  // ms
    private final double backoffMultiplier = 2.0;
    private final long maxDelay = 10_000;  // ms

    public <T> CompletableFuture<T> executeWithRetry(
            Supplier<CompletableFuture<T>> operation) {

        return executeWithRetry(operation, 0);
    }

    private <T> CompletableFuture<T> executeWithRetry(
            Supplier<CompletableFuture<T>> operation,
            int retryCount) {

        return operation.get()
            .exceptionally(ex -> {
                if (retryCount < maxRetries && isRetryable(ex)) {
                    long delay = calculateDelay(retryCount);
                    return CompletableFuture.failedFuture(ex);
                }
                throw new CompletionException(ex);
            })
            .exceptionally(ex -> {
                if (retryCount < maxRetries && isRetryable(ex.getCause())) {
                    long delay = calculateDelay(retryCount);
                    return scheduleRetry(operation, retryCount + 1, delay).join();
                }
                throw (CompletionException) ex;
            });
    }

    private <T> CompletableFuture<T> scheduleRetry(
            Supplier<CompletableFuture<T>> operation,
            int retryCount,
            long delay) {

        CompletableFuture<T> delayed = new CompletableFuture<>();
        Executors.newScheduledThreadPool(1).schedule(() -> {
            executeWithRetry(operation, retryCount)
                .thenAccept(delayed::complete)
                .exceptionally(ex -> {
                    delayed.completeExceptionally(ex);
                    return null;
                });
        }, delay, TimeUnit.MILLISECONDS);
        return delayed;
    }

    private long calculateDelay(int retryCount) {
        long delay = (long) (initialDelay * Math.pow(backoffMultiplier, retryCount));
        return Math.min(delay, maxDelay);
    }

    private boolean isRetryable(Throwable ex) {
        return ex instanceof TimeoutException
            || ex instanceof ConnectException
            || ex instanceof SocketTimeoutException;
    }
}

// Metrics for observability
public class Metrics {
    private final Map<String, AtomicLong> successCounts = new ConcurrentHashMap<>();
    private final Map<String, AtomicLong> failureCounts = new ConcurrentHashMap<>();

    public void recordSuccess(String service) {
        successCounts.computeIfAbsent(service, k -> new AtomicLong()).incrementAndGet();
    }

    public void recordFailure(String service, Throwable ex) {
        failureCounts.computeIfAbsent(service, k -> new AtomicLong()).incrementAndGet();
    }

    public double getSuccessRate(String service) {
        long success = successCounts.getOrDefault(service, new AtomicLong()).get();
        long failure = failureCounts.getOrDefault(service, new AtomicLong()).get();
        long total = success + failure;
        return total == 0 ? 0 : (double) success / total;
    }
}
```

---

## Scalability & Performance

### Question 4: Thread Pool Sizing and Context Switching

**Question:** How would you calculate optimal thread pool sizes for a service that performs:
- 30% CPU-intensive work
- 70% I/O-bound work (blocking calls to external services)

Consider the machine has 16 cores and 32GB RAM.

**Answer:**

```java
public class ThreadPoolSizingStrategy {

    /**
     * CPU-bound tasks: Pool Size = Number of Cores + 1
     *
     * Reasoning:
     * - Each core can run one thread efficiently
     * - +1 for OS context switches
     */
    public static int cpuBoundPoolSize() {
        int cores = Runtime.getRuntime().availableProcessors();
        return cores + 1;  // 16 + 1 = 17
    }

    /**
     * I/O-bound tasks: Pool Size = (Number of Cores * (1 + Wait Time / Compute Time))
     *
     * Formula from: "Java Concurrency in Practice" by Goetz et al.
     *
     * Example: If requests take 100ms total, 10ms compute, 90ms waiting:
     * Pool Size = 16 * (1 + 90/10) = 16 * 10 = 160
     */
    public static int ioBoundPoolSize() {
        int cores = Runtime.getRuntime().availableProcessors();
        int computeTimeMs = 10;
        int waitTimeMs = 90;

        return (int) (cores * (1 + (double) waitTimeMs / computeTimeMs));  // ~160
    }

    /**
     * Mixed workload (30% CPU, 70% I/O)
     * Weighted approach:
     */
    public static int mixedWorkloadPoolSize() {
        int cpuPoolSize = cpuBoundPoolSize();      // 17
        int ioPoolSize = ioBoundPoolSize();        // 160

        double cpuPercentage = 0.30;
        double ioPercentage = 0.70;

        return (int) (cpuPoolSize * cpuPercentage + ioPoolSize * ioPercentage);
        // = (17 * 0.30) + (160 * 0.70)
        // = 5 + 112
        // = 117
    }

    /**
     * Account for GC pauses and safety margin
     */
    public static int recommendedPoolSize() {
        int mixed = mixedWorkloadPoolSize();
        int safetyMargin = 10;  // Account for GC pauses
        return mixed + safetyMargin;  // ~127
    }
}

/**
 * Separate thread pools for different workload types
 * This is more sophisticated than a single pool
 */
public class SegmentedThreadPoolArchitecture {

    // CPU-intensive tasks
    private final ExecutorService cpuExecutor = Executors.newFixedThreadPool(17);

    // I/O-bound tasks (blocking network calls)
    private final ExecutorService ioExecutor = Executors.newFixedThreadPool(160);

    // Mixed background tasks
    private final ExecutorService backgroundExecutor = Executors.newFixedThreadPool(127);

    public <T> CompletableFuture<T> cpuIntensiveTask(Supplier<T> task) {
        return CompletableFuture.supplyAsync(task, cpuExecutor);
    }

    public <T> CompletableFuture<T> ioIntensiveTask(Supplier<T> task) {
        return CompletableFuture.supplyAsync(task, ioExecutor);
    }

    /**
     * Monitor thread pool health
     */
    public void monitorThreadPools() {
        ThreadPoolExecutor cpuPool = (ThreadPoolExecutor) cpuExecutor;
        ThreadPoolExecutor ioPool = (ThreadPoolExecutor) ioExecutor;

        ScheduledExecutorService monitor = Executors.newScheduledThreadPool(1);
        monitor.scheduleAtFixedRate(() -> {
            logger.info("CPU Pool: Active={}, Queue={}, Completed={}",
                cpuPool.getActiveCount(),
                cpuPool.getQueue().size(),
                cpuPool.getCompletedTaskCount());

            logger.info("IO Pool: Active={}, Queue={}, Completed={}",
                ioPool.getActiveCount(),
                ioPool.getQueue().size(),
                ioPool.getCompletedTaskCount());

            // Alert if queues are growing
            if (ioPool.getQueue().size() > 1000) {
                logger.warn("IO Pool queue is growing - consider scaling up");
            }
        }, 0, 10, TimeUnit.SECONDS);
    }
}

/**
 * Context switching cost analysis
 */
public class ContextSwitchAnalysis {

    /**
     * More threads than cores increases context switching
     *
     * Example: 16 cores, 160 threads
     * Context switch cost: ~1-5 microseconds
     *
     * With 160 threads on 16 cores:
     * - Each thread gets ~1ms CPU time per 10ms time slice
     * - Context switch overhead: ~0.1-0.5ms per thread per time slice
     * - Loss: 10-50% of time to context switching!
     *
     * BUT for I/O-bound tasks:
     * - While waiting for I/O, context switch is free (thread blocks)
     * - CPU handles other threads
     * - Overall throughput improves
     */

    public void illustrateTradeoff() {
        // Too few threads: CPU under-utilized, requests queue up
        // 16 threads on 16 cores for I/O task
        // While thread blocks for I/O, CPU sits idle
        // Throughput: Limited to ~1 request per I/O latency

        // Right number of threads: Good balance
        // 160 threads on 16 cores for I/O task (90ms I/O latency)
        // While thread blocks, CPU processes other threads
        // Throughput: Can handle many concurrent requests

        // Too many threads: Excessive context switching
        // 1000 threads on 16 cores
        // Constant context switching overhead
        // CPU time spent switching, not working
        // Throughput: Diminishing returns
    }
}
```

**Key Insights:**
- CPU-bound: 17 threads (cores + 1)
- I/O-bound: 160 threads (accounting for 90% wait time)
- Mixed: 127 threads (weighted average)
- Monitor queue depths and adjust
- Context switching has measurable overhead but is acceptable for I/O waits

---

## Continued Questions...

I'll continue with more expert questions. Would you like me to include more sections on:

1. Thread safety patterns in highly concurrent systems
2. Memory management and GC tuning for Java8+ applications
3. Distributed caching consistency challenges
4. Testing strategies for concurrent code
5. Performance profiling and optimization techniques

Should I continue adding more expert questions to this file?
