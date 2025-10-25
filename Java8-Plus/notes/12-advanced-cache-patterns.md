# Advanced Cache Patterns

## Cache-Aside with Stampede Prevention

```java
public class CacheAsidePatterns {

    /**
     * Double-check locking to prevent cache stampede
     */
    public static class StampedePreventingCache {
        private final Map<String, String> cache = new ConcurrentHashMap<>();
        private final Map<String, CompletableFuture<String>> loading = new ConcurrentHashMap<>();

        public String get(String key, Function<String, String> loader) {
            String cached = cache.get(key);
            if (cached != null) return cached;

            // Check if already loading (prevent duplicate loads)
            if (loading.containsKey(key)) {
                try {
                    return loading.get(key).join();  // Wait for loading
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            }

            // Start loading
            CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
                try {
                    String value = loader.apply(key);
                    cache.put(key, value);
                    return value;
                } finally {
                    loading.remove(key);
                }
            });

            loading.put(key, future);

            try {
                return future.join();
            } catch (Exception e) {
                loading.remove(key);
                throw new RuntimeException(e);
            }
        }
    }

    /**
     * Probabilistic early expiration (XFetch)
     */
    public static class ProbabilisticCache {
        private final Map<String, CacheEntry> cache = new ConcurrentHashMap<>();
        private final double recomputeProbability;

        public ProbabilisticCache(double recomputeProbability) {
            this.recomputeProbability = recomputeProbability;
        }

        public String get(String key, Function<String, String> loader) {
            CacheEntry entry = cache.get(key);

            if (entry == null) {
                return refreshEntry(key, loader);
            }

            // Probabilistically refresh before expiration
            if (entry.shouldRecompute(recomputeProbability)) {
                CompletableFuture.supplyAsync(() -> refreshEntry(key, loader));
            }

            return entry.value;
        }

        private String refreshEntry(String key, Function<String, String> loader) {
            String value = loader.apply(key);
            cache.put(key, new CacheEntry(value));
            return value;
        }

        static class CacheEntry {
            String value;
            long createdAt = System.currentTimeMillis();

            CacheEntry(String value) {
                this.value = value;
            }

            boolean shouldRecompute(double probability) {
                return Math.random() < probability;
            }
        }
    }
}
```

## Write-Through vs Write-Back vs Write-Around

```java
public class WritePatternsComparison {

    /**
     * Write-Around: Database-centric, cache reads
     */
    public static class WriteAroundCache {
        public void put(String key, String value) {
            database.save(key, value);  // Direct to DB
            cache.invalidate(key);       // Invalidate
        }

        public String get(String key) {
            String cached = cache.get(key);
            if (cached != null) return cached;

            String value = database.get(key);
            cache.put(key, value);
            return value;
        }

        // Use when: Infrequent reads after writes
    }

    /**
     * Refresh-Ahead: Proactive refresh before expiration
     */
    public static class RefreshAheadCache {
        private final long refreshWindowMs = 1000;  // Refresh 1s before expiry

        public String get(String key, Function<String, String> loader) {
            CacheEntry entry = cache.get(key);

            if (entry == null) {
                return loadAndCache(key, loader);
            }

            // Refresh if entering expiration window
            if (System.currentTimeMillis() > entry.expiryTime - refreshWindowMs) {
                CompletableFuture.supplyAsync(() -> loadAndCache(key, loader));
            }

            return entry.value;
        }

        private String loadAndCache(String key, Function<String, String> loader) {
            String value = loader.apply(key);
            cache.put(key, new CacheEntry(value, System.currentTimeMillis() + 5000));
            return value;
        }

        static class CacheEntry {
            String value;
            long expiryTime;

            CacheEntry(String value, long expiryTime) {
                this.value = value;
                this.expiryTime = expiryTime;
            }
        }
    }
}
```

## Hierarchical Caching (L1, L2, L3)

```java
public class HierarchicalCaching {

    /**
     * Multi-level cache architecture
     */
    public static class MultiLevelCache {
        // L1: In-process (Caffeine)
        private final Cache<String, String> l1 = Caffeine.newBuilder()
            .maximumSize(1000)
            .expireAfterWrite(5, TimeUnit.MINUTES)
            .build();

        // L2: Distributed (Redis)
        private final Jedis l2 = new Jedis();

        // L3: Database
        private final Database l3 = new Database();

        public String get(String key) {
            // Try L1 first
            String value = l1.getIfPresent(key);
            if (value != null) {
                return value;
            }

            // Try L2
            value = l2.get(key);
            if (value != null) {
                l1.put(key, value);
                return value;
            }

            // Try L3
            value = l3.get(key);
            if (value != null) {
                l2.set(key, value);
                l1.put(key, value);
            }

            return value;
        }

        public void put(String key, String value) {
            // Write-through: L3 first
            l3.put(key, value);
            l2.set(key, value);
            l1.put(key, value);
        }

        // Hit ratio optimization:
        // L1: 70% hit rate (small, fast)
        // L2: 20% hit rate (shared, medium)
        // L3: 10% miss rate (database)
        // Overall: 99% L1+L2 hit rate
    }
}
```

## Cache Warming

```java
public class CacheWarming {

    /**
     * Pre-load hot keys during startup
     */
    public static class WarmingStrategy {
        private final Cache<String, String> cache;
        private final Database database;

        public void warmCache() {
            // Identify hot keys from analytics
            List<String> hotKeys = database.getTopNAccessedKeys(1000);

            hotKeys.parallelStream().forEach(key -> {
                String value = database.get(key);
                cache.put(key, value);
            });

            System.out.println("Warmed " + hotKeys.size() + " keys");
        }

        /**
         * Gradual warming to avoid cache miss spike
         */
        public void gradualWarm() {
            List<String> hotKeys = database.getTopNAccessedKeys(10000);

            ExecutorService executor = Executors.newFixedThreadPool(10);

            for (int i = 0; i < hotKeys.size(); i += 100) {
                int start = i;
                int end = Math.min(i + 100, hotKeys.size());

                executor.submit(() -> {
                    List<String> batch = hotKeys.subList(start, end);
                    batch.forEach(key -> {
                        String value = database.get(key);
                        cache.put(key, value);
                    });
                });
            }
        }
    }
}
```

## Cache Migration

```java
public class CacheMigration {

    /**
     * Dual-write pattern for migration
     */
    public static class DualWriteMigration {
        private final Cache<String, String> oldCache;
        private final Cache<String, String> newCache;
        private volatile boolean migrateReads = false;

        public String get(String key) {
            if (migrateReads) {
                return newCache.get(key);
            }
            return oldCache.get(key);
        }

        public void put(String key, String value) {
            oldCache.put(key, value);
            newCache.put(key, value);  // Dual-write
        }

        /**
         * Migrate in phases
         */
        public void migrate() {
            // Phase 1: Dual-write (2 weeks)
            System.out.println("Phase 1: Dual-write enabled");

            // Phase 2: Migrate reads (gradual)
            migrateReads = true;
            System.out.println("Phase 2: Reading from new cache");

            // Phase 3: Stop dual-write
            // Stop writing to old cache

            // Phase 4: Decommission old cache
            oldCache.clear();
        }
    }
}
```

## Summary

Advanced cache patterns enable:
- ✅ Stampede prevention
- ✅ Optimized write strategies
- ✅ Multi-level hierarchical caching
- ✅ Efficient cache warming
- ✅ Zero-downtime migration
- ✅ Production-grade reliability

Key metrics: Hit ratio >95%, latency <5ms, consistent state
