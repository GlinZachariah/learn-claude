# Distributed Caching & Consistency

## Redis Deep Dive

### Data Structures & Operations

```java
public class RedisOperations {

    private Jedis redis = new Jedis("localhost", 6379);

    // Strings
    public void stringOps() {
        redis.set("key", "value");
        redis.get("key");
        redis.mset("k1", "v1", "k2", "v2");
        redis.incr("counter");
        redis.append("str", "append");
    }

    // Lists - ordered collections
    public void listOps() {
        redis.lpush("list", "item1");      // Push left
        redis.rpush("list", "item2");      // Push right
        redis.lrange("list", 0, -1);       // Get all
        redis.lpop("list");                // Pop left
    }

    // Sets - unique unordered
    public void setOps() {
        redis.sadd("set", "member1", "member2");
        redis.smembers("set");
        redis.sinter("set1", "set2");      // Intersection
        redis.sunion("set1", "set2");      // Union
    }

    // Sorted Sets - ordered by score
    public void zsetOps() {
        redis.zadd("leaderboard", 100, "player1");
        redis.zadd("leaderboard", 95, "player2");
        redis.zrange("leaderboard", 0, -1);  // By rank
        redis.zrevrange("leaderboard", 0, -1);  // Reverse
    }

    // Hashes - maps
    public void hashOps() {
        redis.hset("user:1", "name", "John");
        redis.hget("user:1", "name");
        redis.hgetAll("user:1");
    }

    // Redis Streams - event log
    public void streamOps() {
        String id = redis.xadd("events", "*", "type", "login", "user", "john");
        redis.xlen("events");
        redis.xrange("events", "-", "+");
    }

    // Transactions
    public void transactions() {
        Transaction tx = redis.multi();
        tx.set("k1", "v1");
        tx.set("k2", "v2");
        tx.exec();
    }

    // Pub/Sub
    public void pubSub() {
        // Publisher
        redis.publish("channel", "message");

        // Subscriber
        JedisPubSub sub = new JedisPubSub() {
            @Override
            public void onMessage(String channel, String message) {
                System.out.println("Received: " + message);
            }
        };
        redis.subscribe(sub, "channel");
    }
}
```

## Memcached vs Redis

```java
public class CacheComparison {
    /**
     * Comparison Matrix
     *
     * Feature          | Memcached        | Redis
     * ─────────────────┼──────────────────┼──────────────
     * Data Types       | Strings          | Rich (5 types)
     * Persistence      | No               | Yes (RDB, AOF)
     * Replication      | None             | Master-Slave
     * Cluster          | None             | Yes (Redis Cluster)
     * Lua Scripting    | No               | Yes
     * TTL/Expiration   | Yes              | Yes
     * Memory Efficient | Excellent        | Good
     * Performance      | Ultra-fast       | Very fast
     *
     * Use Memcached when:
     * - Only need simple key-value caching
     * - Extreme performance needed
     * - No persistence required
     *
     * Use Redis when:
     * - Need complex data structures
     * - Persistence important
     * - Pub/Sub messaging needed
     * - Transactions required
     */
}
```

## Cache Coherence & Consistency

```java
public class CacheConsistency {

    /**
     * Write-Through: Update DB then cache
     */
    public class WriteThroughCache {
        public void put(String key, String value) {
            database.save(key, value);      // Write to DB first
            cache.set(key, value);          // Then cache
        }
    }

    /**
     * Write-Back: Update cache, async DB
     */
    public class WriteBackCache {
        private final Queue<WriteOperation> writeQueue = new ConcurrentLinkedQueue<>();

        public void put(String key, String value) {
            cache.set(key, value);                    // Cache immediately
            writeQueue.offer(new WriteOperation(key, value));  // Queue for DB
        }

        private void asyncWriter() {
            WriteOperation op;
            while ((op = writeQueue.poll()) != null) {
                database.save(op.key, op.value);
            }
        }
    }

    /**
     * Eventual Consistency: Accept temporary inconsistency
     */
    public class EventualConsistency {
        private static final long CONSISTENCY_WINDOW_MS = 5000;

        public String get(String key) {
            String cached = cache.get(key);
            if (cached != null) {
                return cached;  // Use cache even if possibly stale
            }

            String dbValue = database.get(key);
            cache.set(key, dbValue);
            return dbValue;
        }

        public void put(String key, String value) {
            long version = System.currentTimeMillis();
            database.save(key, value, version);

            // Async cache update - may lag
            asyncUpdateCache(key, value);
        }

        private void asyncUpdateCache(String key, String value) {
            CompletableFuture.runAsync(() -> {
                sleep(100);  // Eventual update
                cache.set(key, value);
            });
        }
    }
}
```

## Failure Modes & Recovery

```java
public class FailureRecovery {

    public static class ResilientCache {
        private final RedisCluster redis;
        private final Database database;
        private final HealthCheck health;

        /**
         * Handle node failure with fallback
         */
        public String get(String key) {
            try {
                return redis.get(key);
            } catch (ConnectionException ex) {
                logger.warn("Cache unavailable, fallback to DB");
                return database.get(key);  // Fallback
            }
        }

        /**
         * Detect and recover from replication lag
         */
        public void handleReplicationLag() {
            long masterVersion = redis.getMaster().getVersion("key");
            long slaveVersion = redis.getSlave().getVersion("key");

            if (Math.abs(masterVersion - slaveVersion) > ACCEPTABLE_LAG) {
                logger.warn("Replication lag detected, forcing sync");
                redis.forceSync();
            }
        }

        /**
         * Circuit breaker pattern
         */
        private volatile boolean cacheHealthy = true;
        private volatile long lastFailure = 0;

        public String getWithCircuitBreaker(String key) {
            if (!cacheHealthy && System.currentTimeMillis() - lastFailure < 30_000) {
                return database.get(key);  // Circuit open
            }

            try {
                String value = redis.get(key);
                cacheHealthy = true;
                return value;
            } catch (Exception ex) {
                cacheHealthy = false;
                lastFailure = System.currentTimeMillis();
                return database.get(key);
            }
        }
    }
}
```

## Distributed Cache Testing

```java
public class CacheTestingStrategies {

    /**
     * Test cache consistency with chaos engineering
     */
    public void testWithFailureInjection() {
        RedisCache cache = new RedisCache();
        Database db = new Database();

        // Normal operations
        cache.put("key", "value1");
        assertEquals("value1", cache.get("key"));

        // Inject failure
        cache.simulateNodeFailure();
        assertEquals("value1", cache.getWithFallback("key"));  // Uses DB

        // Recover
        cache.recover();
        assertEquals("value1", cache.get("key"));
    }

    /**
     * Test eventual consistency
     */
    public void testEventualConsistency() throws InterruptedException {
        cache.put("key", "value1");

        // Immediately after update might be inconsistent
        assertNotEquals("value1", cache.get("key"));  // Cache lag

        // After consistency window
        Thread.sleep(1000);
        assertEquals("value1", cache.get("key"));  // Consistent
    }
}
```

## Monitoring & Metrics

```java
public class CacheMetrics {

    private final AtomicLong hits = new AtomicLong();
    private final AtomicLong misses = new AtomicLong();
    private final AtomicLong evictions = new AtomicLong();

    public String monitoredGet(String key) {
        String value = cache.get(key);
        if (value != null) {
            hits.incrementAndGet();
        } else {
            misses.incrementAndGet();
        }
        return value;
    }

    public double getHitRatio() {
        long total = hits.get() + misses.get();
        return total == 0 ? 0 : (double) hits.get() / total;
    }

    public void printMetrics() {
        System.out.printf("Hit Ratio: %.2f%%, Evictions: %d%n",
            getHitRatio() * 100,
            evictions.get());
    }
}
```

## Summary

Distributed caching provides:
- ✅ Redis data structures for complex scenarios
- ✅ Consistency models (strong, eventual)
- ✅ Failure handling and recovery
- ✅ Replication and clustering
- ✅ Performance monitoring
- ✅ Large-scale cache management

Key decisions: Persistence (Redis > Memcached), Complexity (Redis), Performance (Memcached)
