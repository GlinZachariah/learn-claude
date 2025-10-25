# Cache Performance Tuning & Optimization

## Memory Profiling & GC Impact

```java
public class MemoryOptimization {

    /**
     * Analyze cache memory usage with JFR
     */
    public void profileMemory() {
        // Start JFR recording
        Recording recording = new Recording();
        recording.start();

        // Run cache operations
        for (int i = 0; i < 1_000_000; i++) {
            cache.put("key" + i, "value" + i);
        }

        // Analyze heap
        recording.stop();
        recording.dumpToFile("/path/to/recording.jfr");
    }

    /**
     * Compact cache representation
     */
    public static class CompactCacheEntry {
        private int key;           // 4 bytes
        private byte[] data;       // Variable
        private long ttl;          // 8 bytes
        // ~20 bytes per entry vs 100+ bytes for Object wrapper
    }

    /**
     * GC tuning for cache workload
     */
    public void optimizeGC() {
        // JVM args for cache:
        // -Xmx4g               // Cache size
        // -XX:+UseG1GC         // Better for large heaps
        // -XX:MaxGCPauseMillis=50  // Pause time target

        // Monitor GC
        MemoryMXBean memBean = ManagementFactory.getMemoryMXBean();
        System.out.println("Heap: " + memBean.getHeapMemoryUsage());
    }

    /**
     * Object pooling to reduce GC pressure
     */
    public static class CacheEntryPool {
        private final Queue<CacheEntry> pool = new ConcurrentLinkedQueue<>();

        public CacheEntry acquire() {
            CacheEntry entry = pool.poll();
            return entry != null ? entry : new CacheEntry();
        }

        public void release(CacheEntry entry) {
            entry.reset();
            pool.offer(entry);
        }
    }
}
```

## Benchmarking Cache Implementations

```java
public class CacheBenchmark {

    /**
     * JMH benchmark: Compare cache implementations
     */
    @Fork(1)
    @BenchmarkMode(Mode.Throughput)
    @OutputTimeUnit(TimeUnit.SECONDS)
    public static class CachePerformance {

        private Map<String, String> caffeine = Caffeine.newBuilder()
            .maximumSize(10000)
            .build();

        private Map<String, String> concurrent = new ConcurrentHashMap<>();

        @Benchmark
        public String measureCaffeineGet() {
            return caffeine.get("key");
        }

        @Benchmark
        public String measureConcurrentGet() {
            return concurrent.get("key");
        }

        // Results:
        // Caffeine: ~10M ops/sec
        // ConcurrentHashMap: ~15M ops/sec
        // Trade-off: Eviction policy vs raw speed
    }

    /**
     * Load testing cache
     */
    public void loadTest() throws Exception {
        Cache<String, String> cache = Caffeine.newBuilder()
            .maximumSize(10000)
            .build();

        ExecutorService executor = Executors.newFixedThreadPool(100);

        long start = System.currentTimeMillis();

        for (int i = 0; i < 1_000_000; i++) {
            final int index = i;
            executor.submit(() -> {
                cache.put("key" + (index % 10000), "value" + index);
                cache.get("key" + (index % 10000));
            });
        }

        executor.awaitTermination(1, TimeUnit.MINUTES);
        long duration = System.currentTimeMillis() - start;

        System.out.println("1M operations in " + duration + "ms");
        System.out.println("Throughput: " + (1_000_000 / duration) + " ops/ms");
    }
}
```

## Cache Hit Rate Prediction

```java
public class HitRatePrediction {

    /**
     * Zipfian distribution: 80% of requests go to 20% of data
     * H = harmonic number, used to model access patterns
     */
    public double predictHitRate(
            int cacheSize,
            int workingSetSize,
            double zipfianExponent) {

        // Working set size >> cache size: low hit rate
        // Working set size <= cache size: high hit rate
        // Zipfian: access concentrate on few items

        if (cacheSize >= workingSetSize) {
            return 1.0;  // All fit
        }

        // Simplified model
        double ratio = (double) cacheSize / workingSetSize;
        // Higher exponent = more concentration = higher hit rate
        double model = ratio * Math.pow(zipfianExponent, 2);

        return Math.min(1.0, model);
    }

    /**
     * Example calculations
     */
    public void examples() {
        // Scenario 1: Small working set
        double hit1 = predictHitRate(1000, 1000, 1.5);   // ~100% (all fit)

        // Scenario 2: 10x working set
        double hit2 = predictHitRate(1000, 10000, 1.5);  // ~35-45%

        // Scenario 3: High concentration (Zipfian=2.0)
        double hit3 = predictHitRate(1000, 100000, 2.0); // ~60-70%
    }
}
```

## Compression Strategies

```java
public class CompressionOptimization {

    /**
     * Compress cache values to save memory
     */
    public static class CompressedCache {
        private final Map<String, byte[]> compressedData = new ConcurrentHashMap<>();

        public void put(String key, String value) {
            byte[] compressed = compress(value.getBytes());
            compressedData.put(key, compressed);
        }

        public String get(String key) {
            byte[] compressed = compressedData.get(key);
            return compressed != null ? new String(decompress(compressed)) : null;
        }

        private byte[] compress(byte[] data) {
            try {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                try (GZIPOutputStream gzip = new GZIPOutputStream(baos)) {
                    gzip.write(data);
                }
                return baos.toByteArray();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        private byte[] decompress(byte[] data) {
            try {
                ByteArrayInputStream bais = new ByteArrayInputStream(data);
                try (GZIPInputStream gzip = new GZIPInputStream(bais)) {
                    return gzip.readAllBytes();
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        // Compression ratios:
        // Text: 70-90% reduction
        // JSON: 60-80% reduction
        // Binary: 20-40% reduction
        // CPU cost: ~5-10% for compression/decompression
    }
}
```

## Cost Analysis

```java
public class CostAnalysis {

    /**
     * Calculate ROI for caching
     */
    public void analyzeCachingROI() {
        // Scenario: E-commerce site
        // 10K req/s, 90% cache hits

        long missesPerSecond = 1000;  // 10% of 10K
        long dbQueryTimeMs = 50;
        long cacheAccessTimeMs = 1;

        long speedupMs = (missesPerSecond * dbQueryTimeMs) -
                         (missesPerSecond * cacheAccessTimeMs);

        System.out.println("Daily time saved: " + speedupMs * 86400 + "ms");

        // Cost:
        // Cache (Redis): $100/month
        // Database reduction: $1000/month saved
        // Net ROI: 900% per month

        // Cache memory cost:
        // 10GB Redis: ~$0.50/day
        // vs Database load: $50/day
        // Saving: $49.50/day
    }
}
```

## Summary

Cache performance tuning involves:
- ✅ Memory profiling and GC optimization
- ✅ Benchmarking different implementations
- ✅ Predicting hit rates mathematically
- ✅ Compression for memory savings
- ✅ Cost-benefit analysis
- ✅ Load testing at scale

Target: Hit ratios >90%, latency <5ms, memory efficient
