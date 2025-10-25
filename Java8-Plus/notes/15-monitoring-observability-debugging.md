# Monitoring, Observability & Debugging

## Core Metrics Collection

```java
public class MetricsFramework {

    /**
     * Custom metrics with Micrometer
     */
    public static class MicrometerMetrics {
        private final MeterRegistry registry;

        public MicrometerMetrics(MeterRegistry registry) {
            this.registry = registry;
        }

        /**
         * Counter: Track discrete events
         */
        public void countedOperation() {
            Counter counter = Counter.builder("api.requests")
                .description("Total API requests")
                .tag("endpoint", "/users")
                .register(registry);

            counter.increment();  // Count each request
        }

        /**
         * Timer: Measure operation duration
         */
        public void timedOperation() {
            Timer timer = Timer.builder("api.latency")
                .description("API response time")
                .publishPercentiles(0.5, 0.95, 0.99)  // p50, p95, p99
                .register(registry);

            timer.recordCallable(() -> {
                // Some operation
                return "result";
            });
        }

        /**
         * Gauge: Measure current value
         */
        public void gaugeMetric() {
            AtomicInteger activeConnections = new AtomicInteger(0);

            Gauge.builder("connections.active", activeConnections::get)
                .description("Active database connections")
                .register(registry);
        }

        /**
         * DistributionSummary: Track distribution of values
         */
        public void distributionMetric() {
            DistributionSummary summary = DistributionSummary.builder("request.payload")
                .description("Request payload size")
                .baseUnit("bytes")
                .register(registry);

            summary.record(1024);  // Record payload size
        }
    }

    /**
     * Custom MetricCollector for async operations
     */
    public static class AsyncMetricsCollector {
        private final ConcurrentHashMap<String, OperationMetrics> metrics =
            new ConcurrentHashMap<>();

        static class OperationMetrics {
            long count = 0;
            long totalTime = 0;
            long maxTime = 0;
            long minTime = Long.MAX_VALUE;
        }

        public <T> CompletableFuture<T> track(String operation,
                                              Supplier<CompletableFuture<T>> supplier) {
            long start = System.nanoTime();

            return supplier.get()
                .whenComplete((result, exception) -> {
                    long duration = System.nanoTime() - start;
                    OperationMetrics ops = metrics.computeIfAbsent(operation,
                        k -> new OperationMetrics());

                    synchronized (ops) {
                        ops.count++;
                        ops.totalTime += duration;
                        ops.maxTime = Math.max(ops.maxTime, duration);
                        ops.minTime = Math.min(ops.minTime, duration);
                    }
                });
        }

        public void printMetrics() {
            metrics.forEach((op, stats) -> {
                double avgMs = stats.totalTime / 1_000_000.0 / stats.count;
                System.out.printf("%s: count=%d, avg=%.2fms, max=%.2fms%n",
                    op, stats.count, avgMs, stats.maxTime / 1_000_000.0);
            });
        }
    }
}
```

## Distributed Tracing with OpenTelemetry

```java
public class DistributedTracing {

    /**
     * OpenTelemetry integration for async operations
     */
    public static class TracedAsyncOperation {
        private final Tracer tracer;
        private final Span rootSpan;

        public TracedAsyncOperation(Tracer tracer) {
            this.tracer = tracer;
            this.rootSpan = tracer.spanBuilder("async-operation")
                .setSpanKind(SpanKind.INTERNAL)
                .startSpan();
        }

        /**
         * Create child spans for sub-operations
         */
        public CompletableFuture<String> executeWithTracing() {
            try (Scope scope = rootSpan.makeCurrent()) {
                Span dbSpan = tracer.spanBuilder("database-call")
                    .setParent(Context.current().with(rootSpan))
                    .startSpan();

                return CompletableFuture.supplyAsync(() -> {
                    try (Scope dbScope = dbSpan.makeCurrent()) {
                        dbSpan.setAttribute("db.system", "postgresql");
                        dbSpan.setAttribute("db.operation", "SELECT");

                        // Database operation
                        return "query result";
                    } finally {
                        dbSpan.end();
                    }
                }).thenApply(result -> {
                    Span processSpan = tracer.spanBuilder("data-processing")
                        .setParent(Context.current().with(rootSpan))
                        .startSpan();

                    try (Scope procScope = processSpan.makeCurrent()) {
                        processSpan.addEvent("processing_start");
                        String processed = result.toUpperCase();
                        processSpan.addEvent("processing_complete");
                        return processed;
                    } finally {
                        processSpan.end();
                    }
                });
            }
        }

        /**
         * Span context propagation across services
         */
        public void propagateContext(String serviceUrl, String traceId) {
            Span span = tracer.spanBuilder("remote-call")
                .setAttribute("http.url", serviceUrl)
                .startSpan();

            try (Scope scope = span.makeCurrent()) {
                // Inject trace context into HTTP headers
                Map<String, String> headers = new HashMap<>();
                W3CTraceContextPropagator propagator = new W3CTraceContextPropagator();
                propagator.inject(Context.current(), headers,
                    (map, key, value) -> map.put(key, value));

                // Call remote service with trace headers
                callRemoteService(serviceUrl, headers);
            } finally {
                span.end();
            }
        }

        private void callRemoteService(String url, Map<String, String> headers) {
            // HTTP call with trace headers
        }
    }
}
```

## Profiling Async Operations with JFR

```java
public class JFRProfiling {

    /**
     * Java Flight Recorder for async performance analysis
     */
    public void profileAsyncOperations() throws IOException {
        // Start JFR recording
        Recording recording = new Recording();
        recording.enable("jdk.ExecutionSample");       // CPU profiling
        recording.enable("jdk.ThreadPark");            // Thread blocking
        recording.enable("jdk.ObjectAllocationInNewTLAB");  // Memory allocation
        recording.enable("jdk.GarbageCollection");     // GC events
        recording.start();

        // Run async operations
        ExecutorService executor = Executors.newFixedThreadPool(10);

        for (int i = 0; i < 1000; i++) {
            executor.submit(() -> {
                CompletableFuture.supplyAsync(() -> heavyComputation())
                    .thenApply(result -> result * 2)
                    .join();
            });
        }

        executor.shutdown();
        executor.awaitTermination(1, TimeUnit.MINUTES);

        // Stop and dump recording
        recording.stop();
        recording.dumpToFile("/tmp/async-profile.jfr");
        System.out.println("JFR recording saved");
    }

    /**
     * Analyze JFR recording for hotspots
     */
    public void analyzeRecording(String recordingFile) throws IOException {
        RecordingFile file = new RecordingFile(Paths.get(recordingFile));

        while (file.hasMoreEvents()) {
            RecordedEvent event = file.readEvent();

            if ("jdk.ExecutionSample".equals(event.getEventType().getName())) {
                RecordedStackTrace stack = event.getStackTrace();
                System.out.println("CPU hotspot: " + stack.getFrames().get(0));
            }

            if ("jdk.ThreadPark".equals(event.getEventType().getName())) {
                long duration = event.getDuration("duration").toNanos();
                if (duration > 1_000_000) {  // > 1ms
                    System.out.println("Thread parked for " + duration + "ns");
                }
            }
        }

        file.close();
    }

    private long heavyComputation() {
        long sum = 0;
        for (int i = 0; i < 1_000_000; i++) {
            sum += i;
        }
        return sum;
    }
}
```

## Thread Dump Analysis & Deadlock Detection

```java
public class ThreadAnalysis {

    /**
     * Capture and analyze thread dumps
     */
    public static class ThreadDumpAnalyzer {
        private final ThreadMXBean threadBean;

        public ThreadDumpAnalyzer() {
            this.threadBean = ManagementFactory.getThreadMXBean();
        }

        /**
         * Detect deadlocks
         */
        public void detectDeadlocks() {
            long[] deadlockedThreads = threadBean.findDeadlockedThreads();

            if (deadlockedThreads != null && deadlockedThreads.length > 0) {
                System.out.println("DEADLOCK DETECTED!");
                ThreadInfo[] threadInfos = threadBean.getThreadInfo(deadlockedThreads, true, true);

                for (ThreadInfo info : threadInfos) {
                    System.out.println("Thread: " + info.getThreadName());
                    System.out.println("State: " + info.getThreadState());
                    System.out.println("Lock name: " + info.getLockName());

                    System.out.println("Stack trace:");
                    for (StackTraceElement elem : info.getStackTrace()) {
                        System.out.println("  " + elem);
                    }
                }
            }
        }

        /**
         * Monitor lock contention
         */
        public void analyzeLockContention() {
            ThreadInfo[] allThreads = threadBean.dumpAllThreads(false, false);

            Map<String, Integer> lockContention = new HashMap<>();

            for (ThreadInfo thread : allThreads) {
                if (thread.getThreadState() == Thread.State.BLOCKED) {
                    String lockName = thread.getLockName();
                    lockContention.merge(lockName, 1, Integer::sum);
                }
            }

            // Print most contended locks
            lockContention.entrySet().stream()
                .sorted((a, b) -> Integer.compare(b.getValue(), a.getValue()))
                .limit(10)
                .forEach(e -> System.out.printf("Lock: %s, Blocked threads: %d%n",
                    e.getKey(), e.getValue()));
        }

        /**
         * Generate full thread dump with stack traces
         */
        public String generateThreadDump() {
            StringBuilder dump = new StringBuilder();
            ThreadInfo[] allThreads = threadBean.dumpAllThreads(true, true);

            for (ThreadInfo thread : allThreads) {
                dump.append(String.format(
                    "Thread: %s (ID: %d, State: %s)%n",
                    thread.getThreadName(),
                    thread.getThreadId(),
                    thread.getThreadState()
                ));

                if (thread.getLockName() != null) {
                    dump.append(String.format("  Waiting on: %s%n", thread.getLockName()));
                }

                for (StackTraceElement elem : thread.getStackTrace()) {
                    dump.append(String.format("    at %s%n", elem));
                }

                dump.append("\n");
            }

            return dump.toString();
        }
    }

    /**
     * Custom deadlock detector for async code
     */
    public static class AsyncDeadlockDetector {
        private final ScheduledExecutorService scheduler =
            Executors.newScheduledThreadPool(1);
        private final Map<CompletableFuture<?>, Long> pendingFutures =
            new ConcurrentHashMap<>();

        public <T> CompletableFuture<T> track(CompletableFuture<T> future) {
            long trackingId = System.nanoTime();
            pendingFutures.put(future, trackingId);

            return future.whenComplete((result, exception) -> {
                pendingFutures.remove(future);
            });
        }

        public void startDeadlockDetection() {
            scheduler.scheduleAtFixedRate(() -> {
                long now = System.currentTimeMillis();

                pendingFutures.forEach((future, timestamp) -> {
                    if (!future.isDone()) {
                        long ageMs = now - timestamp;
                        if (ageMs > 30_000) {  // > 30 seconds
                            System.err.println("WARNING: Future pending for " +
                                ageMs + "ms, possible deadlock");

                            // Get stack trace of blocked thread
                            if (future instanceof CompletableFuture) {
                                System.err.println("Future: " + future);
                            }
                        }
                    }
                });
            }, 10, 10, TimeUnit.SECONDS);
        }
    }
}
```

## GC Tuning for Async Workloads

```java
public class GCTuningAsync {

    /**
     * GC analysis for async code
     */
    public static class GCMetrics {
        private final List<GarbageCollectorMXBean> gcBeans;
        private final MemoryMXBean memoryBean;
        private Map<String, Long> lastGcCount = new HashMap<>();

        public GCMetrics() {
            this.gcBeans = ManagementFactory.getGarbageCollectorMXBeans();
            this.memoryBean = ManagementFactory.getMemoryMXBean();
        }

        /**
         * Track GC frequency and impact
         */
        public void monitorGC() {
            for (GarbageCollectorMXBean gcBean : gcBeans) {
                long currentCount = gcBean.getCollectionCount();
                long lastCount = lastGcCount.getOrDefault(gcBean.getName(), 0L);
                long collectionTime = gcBean.getCollectionTime();

                System.out.printf("GC: %s, Collections: %d (new: %d), Time: %dms%n",
                    gcBean.getName(),
                    currentCount,
                    currentCount - lastCount,
                    collectionTime);

                lastGcCount.put(gcBean.getName(), currentCount);
            }

            // Check heap usage
            MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();
            double usagePercent = (double) heapUsage.getUsed() / heapUsage.getMax() * 100;

            System.out.printf("Heap: %.1f%% used (%dMB / %dMB)%n",
                usagePercent,
                heapUsage.getUsed() / 1024 / 1024,
                heapUsage.getMax() / 1024 / 1024);
        }

        /**
         * Identify allocation hotspots
         */
        public void detectAllocationPressure() {
            // High allocation pressure: frequent GC, high young gen collections
            long youngGenCollections = gcBeans.stream()
                .filter(b -> b.getName().contains("Young"))
                .mapToLong(GarbageCollectorMXBean::getCollectionCount)
                .sum();

            if (youngGenCollections > 1000 / 60) {  // > 1000 per minute
                System.err.println("High young gen GC rate detected!");
                System.err.println("Consider: object pooling, reduce allocations in hot paths");
            }
        }
    }

    /**
     * JVM tuning recommendations for async code
     */
    public void printGCTuningRecommendations() {
        System.out.println("""
            GC Tuning for Async Workloads:

            For CompletableFuture-heavy code:
            1. Use G1GC for large heaps (> 4GB):
               -XX:+UseG1GC -XX:MaxGCPauseMillis=200

            2. For reduced pause times:
               -XX:+UseG1GC -XX:MaxGCPauseMillis=50

            3. Monitor allocation rates:
               -XX:+UnlockDiagnosticVMOptions -XX:PrintInlining
               -XX:PrintCodeCache -XX:PrintNMethods

            4. Reduce object allocation:
               - Use object pooling for frequently created objects
               - Cache CompletableFuture suppliers
               - Reuse thread pools

            5. Monitor with jstat:
               jstat -gc -h10 <pid> 1000
            """);
    }
}
```

## APM Tools Integration

```java
public class APMIntegration {

    /**
     * DataDog integration
     */
    public static class DataDogTracing {
        private final Tracer tracer;

        public DataDogTracing() {
            // Initialize DataDog tracer
            this.tracer = DatadogTracer.builder().build();
        }

        public void traceAsyncOperation() {
            Span span = tracer.buildSpan("async-api-call")
                .withTag("service.name", "user-service")
                .withTag("span.kind", "client")
                .start();

            try (Scope scope = tracer.scopeManager().activate(span, true)) {
                CompletableFuture.supplyAsync(() -> {
                    Span childSpan = tracer.buildSpan("database-query")
                        .asChildOf(span)
                        .start();

                    try (Scope childScope = tracer.scopeManager().activate(childSpan, true)) {
                        childSpan.setTag("db.statement", "SELECT * FROM users");
                        return "query result";
                    }
                }).thenApply(result -> {
                    Span processSpan = tracer.buildSpan("data-processing")
                        .asChildOf(span)
                        .start();

                    try (Scope procScope = tracer.scopeManager().activate(processSpan, true)) {
                        return result.toUpperCase();
                    }
                }).join();
            }
        }
    }

    /**
     * New Relic integration
     */
    public static class NewRelicMonitoring {
        private final NewRelic newRelic;

        public NewRelicMonitoring() {
            this.newRelic = NewRelic.getAgent();
        }

        public void monitorAsyncPerformance() {
            Segment segment = newRelic.getAgent().getTransaction().startSegment("async-operation");

            CompletableFuture.supplyAsync(() -> {
                newRelic.getAgent().getMetricAggregator()
                    .recordMetric("Custom/AsyncOp/Execution", 1);
                return "result";
            }).whenComplete((result, exception) -> {
                if (exception != null) {
                    newRelic.noticeError(exception);
                }
                segment.end();
            }).join();
        }
    }

    /**
     * Jaeger integration for distributed tracing
     */
    public static class JaegerTracing {
        private final Tracer tracer;

        public JaegerTracing(String serviceName) {
            this.tracer = JaegerTracerFactory.create(serviceName);
        }

        public CompletableFuture<String> traceDistributedCall(String remoteService) {
            Span span = tracer.buildSpan("call-" + remoteService)
                .withTag("http.method", "POST")
                .start();

            try (Scope scope = tracer.scopeManager().activate(span, true)) {
                return CompletableFuture.supplyAsync(() -> {
                    // Call remote service
                    Span remoteSpan = tracer.buildSpan(remoteService + "-processing")
                        .asChildOf(span)
                        .start();

                    try (Scope remoteScope = tracer.scopeManager().activate(remoteSpan, true)) {
                        return "remote result";
                    }
                });
            }
        }
    }
}
```

## Custom Metrics with Micrometer

```java
public class MicrometerCustomMetrics {

    /**
     * Business metrics tracking
     */
    public static class BusinessMetricsCollector {
        private final MeterRegistry registry;

        public BusinessMetricsCollector(MeterRegistry registry) {
            this.registry = registry;
        }

        /**
         * Track order processing pipeline
         */
        public void setupOrderMetrics() {
            // Order throughput
            Counter orders = Counter.builder("orders.received")
                .description("Orders received")
                .tag("service", "order-service")
                .register(registry);

            // Order latency (p50, p95, p99)
            Timer orderLatency = Timer.builder("orders.processing.time")
                .description("Order processing duration")
                .publishPercentiles(0.5, 0.95, 0.99)
                .slo(Duration.ofSeconds(1), Duration.ofSeconds(5))
                .register(registry);

            // Active orders being processed
            AtomicInteger activeOrders = new AtomicInteger(0);
            Gauge.builder("orders.active", activeOrders::get)
                .description("Orders being processed")
                .register(registry);

            // Order values distribution
            DistributionSummary orderValue = DistributionSummary.builder("orders.value")
                .description("Order value distribution")
                .baseUnit("dollars")
                .scale(0.01)  // Convert cents to dollars
                .register(registry);
        }

        /**
         * Track async task pool metrics
         */
        public void setupThreadPoolMetrics(ExecutorService executor) {
            if (executor instanceof ThreadPoolExecutor) {
                ThreadPoolExecutor pool = (ThreadPoolExecutor) executor;

                Gauge.builder("threadpool.active", pool::getActiveCount)
                    .description("Active threads")
                    .register(registry);

                Gauge.builder("threadpool.queue.size",
                    () -> pool.getQueue().size())
                    .description("Queued tasks")
                    .register(registry);

                Gauge.builder("threadpool.completed", pool::getCompletedTaskCount)
                    .description("Completed tasks")
                    .register(registry);
            }
        }

        /**
         * Track async completion metrics
         */
        public <T> CompletableFuture<T> monitoredSupplyAsync(
                String name,
                Supplier<T> supplier) {

            Timer.Sample sample = Timer.start(registry);

            return CompletableFuture.supplyAsync(supplier)
                .whenComplete((result, exception) -> {
                    if (exception != null) {
                        Counter.builder(name + ".failures")
                            .register(registry)
                            .increment();
                    } else {
                        Counter.builder(name + ".successes")
                            .register(registry)
                            .increment();
                    }
                    sample.stop(Timer.builder(name + ".duration")
                        .register(registry));
                });
        }
    }
}
```

## Alerting Strategies

```java
public class AlertingStrategies {

    /**
     * Alert thresholds and escalation
     */
    public static class AlertingFramework {
        private final AlertingService alertService;
        private final MetricsQuery metricsQuery;

        public AlertingFramework(AlertingService alertService, MetricsQuery metricsQuery) {
            this.alertService = alertService;
            this.metricsQuery = metricsQuery;
        }

        /**
         * Health check with multi-level thresholds
         */
        public void setupAlerts() {
            // Error rate > 1% - WARNING
            String errorRateWarning = "error_rate > 0.01";
            alertService.registerAlert(errorRateWarning, AlertSeverity.WARNING);

            // Error rate > 5% - CRITICAL
            String errorRateCritical = "error_rate > 0.05";
            alertService.registerAlert(errorRateCritical, AlertSeverity.CRITICAL);

            // Latency p99 > 1000ms - WARNING
            String latencyWarning = "latency_p99 > 1000";
            alertService.registerAlert(latencyWarning, AlertSeverity.WARNING);

            // Thread pool queue > 1000 tasks - CRITICAL
            String queueAlert = "threadpool.queue.size > 1000";
            alertService.registerAlert(queueAlert, AlertSeverity.CRITICAL);

            // GC pause > 200ms - WARNING
            String gcAlert = "gc_pause_max > 200";
            alertService.registerAlert(gcAlert, AlertSeverity.WARNING);
        }

        /**
         * Detect anomalies using baseline comparison
         */
        public void detectAnomalies() {
            double currentLatency = metricsQuery.getLatencyP95();
            double baselineLatency = metricsQuery.getHistoricalP95(Duration.ofDays(7));

            // If current is > 2x baseline, alert
            if (currentLatency > baselineLatency * 2) {
                alertService.send(
                    AlertSeverity.WARNING,
                    "Latency spike detected: " + currentLatency + "ms vs " + baselineLatency + "ms"
                );
            }
        }

        /**
         * Custom alert conditions for async operations
         */
        public void setupAsyncAlerts() {
            // Futures taking too long to complete
            String futureAlert = "completable_future.pending.max_age > 30000";
            alertService.registerAlert(futureAlert, AlertSeverity.CRITICAL);

            // Too many queued async tasks
            String queuedAlert = "async.queue.size > 10000";
            alertService.registerAlert(queuedAlert, AlertSeverity.WARNING);

            // Callback explosion (too many chained operations)
            String callbackAlert = "completable_future.chain.depth > 100";
            alertService.registerAlert(callbackAlert, AlertSeverity.WARNING);
        }
    }

    /**
     * Alert escalation policy
     */
    public enum AlertSeverity {
        INFO("Slack #alerts"),
        WARNING("Slack #alerts + PagerDuty"),
        CRITICAL("Slack #critical + PagerDuty + SMS + Call");

        private final String escalation;

        AlertSeverity(String escalation) {
            this.escalation = escalation;
        }

        public String getEscalationPath() {
            return escalation;
        }
    }
}
```

## Production Debugging Techniques

```java
public class ProductionDebugging {

    /**
     * Low-overhead debugging for async code
     */
    public static class AsyncDebugger {
        private final ThreadLocal<DebugContext> debugContext = new ThreadLocal<>();

        static class DebugContext {
            long startTime;
            List<String> events = new ArrayList<>();
        }

        /**
         * Trace async execution path
         */
        public <T> CompletableFuture<T> debugTrace(
                String operation,
                Supplier<CompletableFuture<T>> supplier) {

            long startTime = System.currentTimeMillis();

            return supplier.get()
                .thenApply(result -> {
                    long elapsed = System.currentTimeMillis() - startTime;
                    System.out.printf("[%s] Completed in %dms%n", operation, elapsed);
                    return result;
                })
                .exceptionally(exception -> {
                    long elapsed = System.currentTimeMillis() - startTime;
                    System.err.printf("[%s] Failed after %dms: %s%n",
                        operation, elapsed, exception.getMessage());
                    return null;
                });
        }

        /**
         * Conditional breakpoint simulation
         */
        public boolean shouldDebug(String operation, long durationMs) {
            // Only debug if taking longer than expected
            return durationMs > 1000;
        }

        /**
         * Capture thread context for debugging
         */
        public void captureContext(String contextInfo) {
            DebugContext ctx = new DebugContext();
            ctx.startTime = System.currentTimeMillis();
            ctx.events.add(contextInfo);
            debugContext.set(ctx);
        }

        /**
         * Dump context on exception
         */
        public void dumpContextOnException(Throwable exception) {
            DebugContext ctx = debugContext.get();
            if (ctx != null) {
                System.err.println("Debug context for exception: " + exception);
                System.err.println("Started: " + new Date(ctx.startTime));
                System.err.println("Events: " + ctx.events);
            }
        }
    }

    /**
     * Async call tree visualization
     */
    public static class AsyncCallTreeDebugger {
        private final ThreadLocal<CallNode> rootNode = new ThreadLocal<>();

        static class CallNode {
            String name;
            long startTime;
            long duration;
            List<CallNode> children = new ArrayList<>();
            Throwable exception;
        }

        public <T> CompletableFuture<T> traced(String name,
                                               Supplier<CompletableFuture<T>> supplier) {
            CallNode node = new CallNode();
            node.name = name;
            node.startTime = System.nanoTime();

            CallNode parent = rootNode.get();
            if (parent != null) {
                parent.children.add(node);
            } else {
                rootNode.set(node);
            }

            return supplier.get()
                .whenComplete((result, exception) -> {
                    node.duration = System.nanoTime() - node.startTime;
                    node.exception = exception;

                    if (parent == null && exception != null) {
                        printTree(node, 0);
                    }
                });
        }

        private void printTree(CallNode node, int depth) {
            String indent = "  ".repeat(depth);
            String durationMs = node.duration / 1_000_000.0 + "ms";

            if (node.exception != null) {
                System.err.printf("%s[%s] %s (FAILED: %s)%n",
                    indent, durationMs, node.name, node.exception.getClass().getSimpleName());
            } else {
                System.out.printf("%s[%s] %s%n",
                    indent, durationMs, node.name);
            }

            for (CallNode child : node.children) {
                printTree(child, depth + 1);
            }
        }
    }
}
```

## Real-World Monitoring Setup

```java
public class ProductionMonitoringSetup {

    /**
     * Complete monitoring stack for async application
     */
    public static class MonitoredAsyncApplication {
        private final MeterRegistry meterRegistry;
        private final Tracer tracer;
        private final ThreadDumpAnalyzer threadAnalyzer;
        private final AsyncMetricsCollector metricsCollector;

        public void setupMonitoring() {
            // 1. Application metrics
            setupApplicationMetrics();

            // 2. JVM metrics
            setupJVMMetrics();

            // 3. Async-specific metrics
            setupAsyncMetrics();

            // 4. Distributed tracing
            setupDistributedTracing();

            // 5. Health checks
            setupHealthChecks();
        }

        private void setupApplicationMetrics() {
            // API endpoints
            Counter.builder("api.requests")
                .description("Total API requests")
                .tag("service", "user-service")
                .register(meterRegistry);

            // Business events
            Counter.builder("orders.created")
                .description("Orders created")
                .register(meterRegistry);
        }

        private void setupJVMMetrics() {
            // Automatically registered by Micrometer
            new JvmThreadMetrics().bindTo(meterRegistry);
            new JvmMemoryMetrics().bindTo(meterRegistry);
            new JvmGcMetrics().bindTo(meterRegistry);
            new ClassLoaderMetrics().bindTo(meterRegistry);
        }

        private void setupAsyncMetrics() {
            // CompletableFuture pool metrics
            // Thread pool monitoring
            // Task queue depth
            // Future completion rates
        }

        private void setupDistributedTracing() {
            // Context propagation
            // Span creation
            // Service-to-service tracing
        }

        private void setupHealthChecks() {
            // Cache health
            // Database connectivity
            // External service availability
        }

        /**
         * Periodic health check
         */
        public void startHealthChecks() {
            ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

            scheduler.scheduleAtFixedRate(() -> {
                threadAnalyzer.detectDeadlocks();
                threadAnalyzer.analyzeLockContention();

                System.out.println("Health check: OK");
            }, 0, 1, TimeUnit.MINUTES);
        }
    }
}
```

## Summary

Production observability involves:
- ✅ Custom metrics with Micrometer
- ✅ Distributed tracing with OpenTelemetry
- ✅ JFR profiling for async performance
- ✅ Thread dump analysis and deadlock detection
- ✅ GC tuning for async workloads
- ✅ APM tool integration (DataDog, New Relic, Jaeger)
- ✅ Alerting and anomaly detection
- ✅ Production debugging techniques
- ✅ Comprehensive health monitoring

Best practices: Instrument early, use low-overhead metrics, implement distributed tracing, automate alerts
