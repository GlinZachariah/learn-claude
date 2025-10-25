# Caching Strategies in Java

## Overview

Caching is a critical performance optimization technique for modern applications. It reduces database hits, API calls, and computational overhead by storing frequently accessed data in memory.

## Caching Fundamentals

### What is Caching?

Caching is storing data in a temporary location (typically memory) so that future requests for that data can be served faster. It's based on the principle of **temporal locality** - if data is accessed once, it's likely to be accessed again soon.

### Cache Hierarchy

```
L1: Application Level Cache (In-Memory)
    ↓
L2: Distributed Cache (Redis, Memcached)
    ↓
L3: Database Cache (Query Cache)
    ↓
L4: Persistent Storage (Database)
```

## Cache Eviction Policies

### 1. LRU (Least Recently Used)

```java
// Using LinkedHashMap to implement LRU
class LRUCache<K, V> extends LinkedHashMap<K, V> {
    private final int capacity;

    public LRUCache(int capacity) {
        super(capacity, 0.75f, true);  // Access-order map
        this.capacity = capacity;
    }

    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        return size() > capacity;
    }
}

// Usage
LRUCache<String, String> cache = new LRUCache<>(100);
cache.put("key1", "value1");
```

### 2. LFU (Least Frequently Used)

```java
public class LFUCache<K, V> {
    private final int capacity;
    private final Map<K, V> cache;
    private final Map<K, Integer> frequency;
    private final Map<Integer, LinkedHashSet<K>> frequencyList;
    private int minFrequency;

    public LFUCache(int capacity) {
        this.capacity = capacity;
        this.cache = new HashMap<>();
        this.frequency = new HashMap<>();
        this.frequencyList = new HashMap<>();
        this.minFrequency = 1;
    }

    public V get(K key) {
        if (!cache.containsKey(key)) {
            return null;
        }
        updateFrequency(key);
        return cache.get(key);
    }

    public void put(K key, V value) {
        if (capacity <= 0) return;

        if (cache.containsKey(key)) {
            cache.put(key, value);
            updateFrequency(key);
            return;
        }

        if (cache.size() >= capacity) {
            evictLFU();
        }

        cache.put(key, value);
        frequency.put(key, 1);
        frequencyList.computeIfAbsent(1, k -> new LinkedHashSet<>()).add(key);
        minFrequency = 1;
    }

    private void updateFrequency(K key) {
        int freq = frequency.get(key);
        frequency.put(key, freq + 1);

        frequencyList.get(freq).remove(key);
        if (frequencyList.get(freq).isEmpty() && freq == minFrequency) {
            minFrequency++;
        }

        frequencyList.computeIfAbsent(freq + 1, k -> new LinkedHashSet<>()).add(key);
    }

    private void evictLFU() {
        K keyToRemove = frequencyList.get(minFrequency).iterator().next();
        frequencyList.get(minFrequency).remove(keyToRemove);
        cache.remove(keyToRemove);
        frequency.remove(keyToRemove);
    }
}
```

### 3. TTL (Time-To-Live)

```java
public class TTLCache<K, V> {
    private static class CacheEntry<V> {
        V value;
        long expiryTime;

        CacheEntry(V value, long ttlMs) {
            this.value = value;
            this.expiryTime = System.currentTimeMillis() + ttlMs;
        }

        boolean isExpired() {
            return System.currentTimeMillis() > expiryTime;
        }
    }

    private final Map<K, CacheEntry<V>> cache = new ConcurrentHashMap<>();
    private final long ttlMs;

    public TTLCache(long ttlMs) {
        this.ttlMs = ttlMs;
    }

    public void put(K key, V value) {
        cache.put(key, new CacheEntry<>(value, ttlMs));
    }

    public V get(K key) {
        CacheEntry<V> entry = cache.get(key);
        if (entry == null) return null;

        if (entry.isExpired()) {
            cache.remove(key);
            return null;
        }
        return entry.value;
    }

    public void cleanup() {
        cache.entrySet().removeIf(e -> e.getValue().isExpired());
    }
}
```

## Caching Libraries

### 1. Guava Cache

```java
import com.google.common.cache.*;

// Simple cache
Cache<String, String> cache = CacheBuilder.newBuilder()
    .maximumSize(1000)
    .build();

cache.put("key", "value");
String value = cache.getIfPresent("key");

// With loading capability
LoadingCache<String, String> loadingCache = CacheBuilder.newBuilder()
    .maximumSize(100)
    .expireAfterWrite(10, TimeUnit.MINUTES)
    .build(new CacheLoader<String, String>() {
        @Override
        public String load(String key) throws Exception {
            return fetchDataFromDatabase(key);
        }
    });

// Automatic loading
String value = loadingCache.get("key");  // Loads if missing
```

### 2. Caffeine Cache

```java
import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;

// Basic cache with expiration
Cache<String, String> cache = Caffeine.newBuilder()
    .expireAfterWrite(10, TimeUnit.MINUTES)
    .maximumSize(1000)
    .build();

cache.put("key", "value");
String value = cache.getIfPresent("key");

// Loading cache
LoadingCache<String, String> loadingCache = Caffeine.newBuilder()
    .maximumSize(500)
    .expireAfterAccess(5, TimeUnit.MINUTES)
    .build(key -> loadFromDatabase(key));

String value = loadingCache.get("key");

// Async loading
AsyncLoadingCache<String, String> asyncCache = Caffeine.newBuilder()
    .maximumSize(1000)
    .buildAsync(key -> CompletableFuture.supplyAsync(() -> loadData(key)));

CompletableFuture<String> future = asyncCache.get("key");
```

### 3. Redis as Distributed Cache

```java
import redis.clients.jedis.Jedis;

public class RedisCache {
    private final Jedis jedis;

    public RedisCache() {
        this.jedis = new Jedis("localhost", 6379);
    }

    public void set(String key, String value, int ttlSeconds) {
        jedis.setex(key, ttlSeconds, value);
    }

    public String get(String key) {
        return jedis.get(key);
    }

    public void delete(String key) {
        jedis.del(key);
    }

    public void increment(String key) {
        jedis.incr(key);
    }
}
```

## Caching Patterns

### 1. Cache-Aside Pattern

```java
public class CacheAsideUserService {
    private final Cache<String, User> cache;
    private final UserRepository repository;

    public User getUser(String userId) {
        // Check cache first
        User user = cache.getIfPresent(userId);

        if (user == null) {
            // Cache miss - fetch from database
            user = repository.findById(userId);
            if (user != null) {
                cache.put(userId, user);
            }
        }
        return user;
    }

    public void updateUser(User user) {
        // Update database
        repository.save(user);

        // Invalidate cache
        cache.invalidate(user.getId());
    }
}
```

### 2. Write-Through Pattern

```java
public class WriteThroughCache {
    private final Cache<String, String> cache;
    private final Database database;

    public void put(String key, String value) {
        // Write to database first
        database.save(key, value);

        // Then update cache
        cache.put(key, value);
    }

    public String get(String key) {
        String value = cache.getIfPresent(key);

        if (value == null) {
            value = database.get(key);
            if (value != null) {
                cache.put(key, value);
            }
        }
        return value;
    }
}
```

### 3. Write-Back (Write-Behind) Pattern

```java
public class WriteBackCache {
    private final Cache<String, String> cache;
    private final Database database;
    private final Queue<CacheWrite> writeQueue;
    private final ExecutorService executor;

    public WriteBackCache() {
        this.writeQueue = new ConcurrentLinkedQueue<>();
        this.executor = Executors.newSingleThreadExecutor();
        startAsyncWriter();
    }

    public void put(String key, String value) {
        // Update cache immediately
        cache.put(key, value);

        // Queue for async write to database
        writeQueue.offer(new CacheWrite(key, value));
    }

    private void startAsyncWriter() {
        executor.submit(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                CacheWrite write = writeQueue.poll();
                if (write != null) {
                    database.save(write.key, write.value);
                }
            }
        });
    }
}
```

## Cache Invalidation Strategies

### 1. Time-Based Invalidation

```java
Cache<String, String> cache = Caffeine.newBuilder()
    .expireAfterWrite(5, TimeUnit.MINUTES)
    .build();
```

### 2. Event-Based Invalidation

```java
public class EventDrivenCache {
    private final Cache<String, User> cache;
    private final EventBus eventBus;

    public EventDrivenCache(EventBus eventBus) {
        this.cache = Caffeine.newBuilder().build();
        this.eventBus = eventBus;
        eventBus.subscribe(UserUpdatedEvent.class, this::invalidateUser);
    }

    private void invalidateUser(UserUpdatedEvent event) {
        cache.invalidate(event.getUserId());
    }
}
```

### 3. Manual Invalidation

```java
public class ManualInvalidationCache {
    private final Cache<String, String> cache;

    public void invalidate(String key) {
        cache.invalidate(key);
    }

    public void invalidateAll() {
        cache.invalidateAll();
    }

    public void invalidateIf(Predicate<String> condition) {
        cache.asMap().keySet().removeIf(condition);
    }
}
```

## Advanced Caching Techniques

### 1. Cache Warming

```java
public class CacheWarmer {

    public static void warmCache(LoadingCache<String, String> cache) {
        // Pre-load frequently accessed keys
        List<String> keysToLoad = fetchFrequentlyAccessedKeys();

        keysToLoad.forEach(key -> {
            try {
                cache.get(key);
            } catch (Exception e) {
                logger.warn("Failed to warm cache for key: " + key, e);
            }
        });
    }
}
```

### 2. Multi-Level Cache

```java
public class MultiLevelCache<K, V> {
    private final Cache<K, V> l1Cache;  // In-memory
    private final RedisCache l2Cache;   // Redis

    public V get(K key) {
        // Try L1 first
        V value = l1Cache.getIfPresent(key);
        if (value != null) return value;

        // Try L2
        value = l2Cache.get(String.valueOf(key));
        if (value != null) {
            l1Cache.put(key, value);
            return value;
        }

        return null;
    }

    public void put(K key, V value) {
        l1Cache.put(key, value);
        l2Cache.set(String.valueOf(key), String.valueOf(value));
    }
}
```

### 3. Cache Stampede Prevention

```java
public class StampedePreventingCache<K, V> {
    private final Cache<K, V> cache;
    private final Map<K, CompletableFuture<V>> loading;

    public V get(K key, Function<K, V> loader) {
        V value = cache.getIfPresent(key);
        if (value != null) return value;

        // Prevent thundering herd
        CompletableFuture<V> future = loading.computeIfAbsent(key, k ->
            CompletableFuture.supplyAsync(() -> loader.apply(k))
        );

        try {
            value = future.get();
            cache.put(key, value);
            return value;
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            loading.remove(key);
        }
    }
}
```

## Performance Considerations

### Cache Hit Ratio

```java
public class CacheMetrics {
    private final AtomicLong hits = new AtomicLong();
    private final AtomicLong misses = new AtomicLong();

    public void recordHit() {
        hits.incrementAndGet();
    }

    public void recordMiss() {
        misses.incrementAndGet();
    }

    public double getHitRatio() {
        long total = hits.get() + misses.get();
        return total == 0 ? 0 : (double) hits.get() / total;
    }
}
```

### Memory Management

```java
// Monitor cache memory usage
Cache<String, String> cache = Caffeine.newBuilder()
    .maximumWeight(1024 * 1024)  // 1MB
    .weigher((String key, String value) -> value.length())
    .build();
```

## Common Pitfalls

### 1. Cache Invalidation Failures

```java
// PROBLEM: Cache gets out of sync
cache.put(key, value);
database.update(key, newValue);  // Database updated, cache not invalidated

// SOLUTION: Proper invalidation
database.update(key, newValue);
cache.invalidate(key);
```

### 2. Memory Leaks

```java
// PROBLEM: Unbounded cache
Cache<String, String> cache = new HashMap<>();  // No eviction!

// SOLUTION: Bounded cache
Cache<String, String> cache = Caffeine.newBuilder()
    .maximumSize(1000)
    .build();
```

## Summary

Key takeaways:
- ✅ Choose appropriate eviction policy (LRU, LFU, TTL)
- ✅ Use proven libraries (Caffeine, Guava, Redis)
- ✅ Implement proper invalidation strategy
- ✅ Monitor cache hit ratio
- ✅ Consider multi-level caching for high-performance systems
- ✅ Be aware of cache stampede and thundering herd problems
- ✅ Always measure and validate cache effectiveness
