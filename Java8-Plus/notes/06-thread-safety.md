# Thread Safety in Java

## Overview

Thread safety is a critical aspect of multi-threaded programming. It ensures that data shared between threads is accessed and modified in a controlled manner to prevent race conditions, data corruption, and unpredictable behavior.

## Core Concepts

### What is Thread Safety?

A piece of code is thread-safe if it functions correctly even when multiple threads execute it simultaneously. Thread safety requires proper synchronization and coordination between threads.

### Race Condition Example

```java
// NOT thread-safe
public class Counter {
    private int count = 0;

    public void increment() {
        count++;  // This is NOT atomic!
        // Read, Modify, Write - three steps
    }

    public int getCount() {
        return count;
    }
}

// Problem scenario:
// Thread 1: Read (5), Modify (6), Write (6)
// Thread 2: Read (5), Modify (6), Write (6)  <- Lost update!
// Expected: 7, Actual: 6
```

## Synchronization Mechanisms

### 1. Synchronized Keyword

```java
// Synchronizing methods
public class SynchronizedCounter {
    private int count = 0;

    public synchronized void increment() {
        count++;
    }

    public synchronized int getCount() {
        return count;
    }
}

// Synchronizing blocks
public class OptimizedCounter {
    private int count = 0;
    private final Object lock = new Object();

    public void increment() {
        // Only the critical section is synchronized
        synchronized(lock) {
            count++;
        }
    }

    public int getCount() {
        synchronized(lock) {
            return count;
        }
    }
}
```

### 2. Volatile Keyword

```java
public class VolatileFlag {
    private volatile boolean flag = false;

    // Ensures all threads see the latest value
    public void setFlag(boolean value) {
        flag = value;
    }

    public boolean isFlag() {
        return flag;
    }
}

// Use volatile for:
// - Flags (shutdown signals)
// - Simple state changes
// - Visibility only (not atomicity)
```

### 3. Atomic Classes

```java
import java.util.concurrent.atomic.*;

public class AtomicCounter {
    private final AtomicInteger count = new AtomicInteger(0);

    public void increment() {
        count.incrementAndGet();
    }

    public int getCount() {
        return count.get();
    }

    // Atomic operations
    public void compareAndSwap() {
        count.compareAndSet(0, 5);  // Atomic compare-and-swap
    }
}

// Available atomic classes:
// - AtomicInteger, AtomicLong, AtomicBoolean
// - AtomicReference<T>
// - AtomicIntegerArray, AtomicLongArray
// - AtomicMarkableReference
// - AtomicStampedReference
```

## Locks and Synchronization

### 1. ReentrantLock

```java
import java.util.concurrent.locks.ReentrantLock;

public class ReentrantLockExample {
    private final ReentrantLock lock = new ReentrantLock();
    private int count = 0;

    public void increment() {
        lock.lock();
        try {
            count++;
        } finally {
            lock.unlock();
        }
    }

    // Try lock with timeout
    public boolean tryIncrement(long timeoutMs) {
        try {
            if (lock.tryLock(timeoutMs, TimeUnit.MILLISECONDS)) {
                try {
                    count++;
                    return true;
                } finally {
                    lock.unlock();
                }
            }
            return false;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return false;
        }
    }
}
```

### 2. ReadWriteLock

```java
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class CacheWithReadWriteLock {
    private final Map<String, String> cache = new HashMap<>();
    private final ReadWriteLock lock = new ReentrantReadWriteLock();

    public String get(String key) {
        lock.readLock().lock();
        try {
            return cache.get(key);
        } finally {
            lock.readLock().unlock();
        }
    }

    public void put(String key, String value) {
        lock.writeLock().lock();
        try {
            cache.put(key, value);
        } finally {
            lock.writeLock().unlock();
        }
    }
}

// Use ReadWriteLock when:
// - More reads than writes
// - Read operations are computationally heavy
// - You want to allow multiple concurrent readers
```

### 3. StampedLock (Java 8+)

```java
import java.util.concurrent.locks.StampedLock;

public class OptimizedCache {
    private String value;
    private final StampedLock lock = new StampedLock();

    public String getValue() {
        // Optimistic read (no lock)
        long stamp = lock.tryOptimisticRead();
        String result = value;

        // If data changed, acquire read lock
        if (!lock.validate(stamp)) {
            stamp = lock.readLock();
            try {
                result = value;
            } finally {
                lock.unlockRead(stamp);
            }
        }
        return result;
    }

    public void setValue(String newValue) {
        long stamp = lock.writeLock();
        try {
            value = newValue;
        } finally {
            lock.unlockWrite(stamp);
        }
    }
}

// StampedLock advantages:
// - Faster than ReentrantReadWriteLock
// - Optimistic reads (no lock acquisition)
// - More memory efficient
```

## Thread-Safe Collections

### 1. ConcurrentHashMap

```java
import java.util.concurrent.ConcurrentHashMap;

public class ConcurrentHashMapExample {
    private final ConcurrentHashMap<String, String> map =
        new ConcurrentHashMap<>();

    public void putAndGet() {
        map.put("key", "value");
        String value = map.get("key");
    }

    // Atomic operations
    public void atomicUpdate(String key) {
        // Compute atomically
        map.compute(key, (k, v) -> v == null ? "new" : v + "updated");

        // Put if absent
        map.putIfAbsent(key, "default");

        // Get or create
        map.computeIfAbsent(key, k -> expensiveComputation());
    }
}

// Advantages over Collections.synchronizedMap:
// - Segment-level locking (not whole-map locking)
// - Better concurrency
// - No synchronization overhead for reads
```

### 2. CopyOnWriteArrayList

```java
import java.util.concurrent.CopyOnWriteArrayList;

public class CopyOnWriteExample {
    private final CopyOnWriteArrayList<String> list =
        new CopyOnWriteArrayList<>();

    public void addItems() {
        list.add("item1");
        list.add("item2");
    }

    public void iterateSafely() {
        // Safe iteration without synchronization
        for (String item : list) {
            System.out.println(item);
        }
    }
}

// Use CopyOnWriteArrayList when:
// - Writes are infrequent
// - Reads are frequent
// - You need safe iteration
```

### 3. Other Thread-Safe Collections

```java
import java.util.concurrent.*;

public class ThreadSafeCollections {
    // Queue for producer-consumer pattern
    private final BlockingQueue<String> queue =
        new LinkedBlockingQueue<>(100);

    // Set with concurrent operations
    private final ConcurrentSkipListSet<String> set =
        new ConcurrentSkipListSet<>();

    // Map with natural ordering
    private final ConcurrentSkipListMap<String, String> map =
        new ConcurrentSkipListMap<>();

    public void producerConsumer() throws InterruptedException {
        // Producer
        queue.put("item");

        // Consumer
        String item = queue.take();  // Blocks if empty
    }
}
```

## Immutability Pattern

```java
// Thread-safe through immutability
public final class ImmutableUser {
    private final String name;
    private final int age;
    private final List<String> emails;

    public ImmutableUser(String name, int age, List<String> emails) {
        this.name = name;
        this.age = age;
        // Defensive copy
        this.emails = new ArrayList<>(emails);
    }

    public String getName() {
        return name;
    }

    public int getAge() {
        return age;
    }

    public List<String> getEmails() {
        // Return unmodifiable copy
        return Collections.unmodifiableList(
            new ArrayList<>(emails)
        );
    }

    // No setters - immutable!
}
```

## ThreadLocal

```java
public class ThreadLocalExample {
    // Each thread gets its own instance
    private static final ThreadLocal<SimpleDateFormat> dateFormat =
        ThreadLocal.withInitial(() -> new SimpleDateFormat("yyyy-MM-dd"));

    // Safe because SimpleDateFormat is not thread-safe
    public String formatDate(Date date) {
        return dateFormat.get().format(date);
    }

    // Don't forget to clean up!
    public void cleanup() {
        dateFormat.remove();
    }
}

// Use ThreadLocal for:
// - Thread-unsafe objects (SimpleDateFormat, Connection)
// - Request-scoped data in web applications
// - Database connections per thread
```

## Synchronization Best Practices

### 1. Minimize Synchronized Scope

```java
// BAD - Entire method synchronized
public synchronized void processBatch(List<Item> items) {
    items.forEach(item -> {
        // Most of this work doesn't need synchronization
        processItem(item);
    });
    updateDatabase(items);
}

// GOOD - Only critical section synchronized
public void processBatch(List<Item> items) {
    items.forEach(item -> processItem(item));

    synchronized(this) {
        updateDatabase(items);
    }
}
```

### 2. Avoid Nested Locks (Deadlock Prevention)

```java
// DEADLOCK RISK
public synchronized void method1(Account other) {
    synchronized(other) {
        // Potential deadlock!
    }
}

// SOLUTION - Consistent lock ordering
public void transfer(Account from, Account to, double amount) {
    Account first = from.id < to.id ? from : to;
    Account second = from.id < to.id ? to : from;

    synchronized(first) {
        synchronized(second) {
            // Safe - always same order
            from.withdraw(amount);
            to.deposit(amount);
        }
    }
}
```

### 3. Use ReadWriteLock for Read-Heavy Operations

```java
public class CacheService {
    private final Map<String, String> cache = new HashMap<>();
    private final ReadWriteLock lock = new ReentrantReadWriteLock();

    public String get(String key) {
        lock.readLock().lock();
        try {
            return cache.get(key);  // Many readers allowed
        } finally {
            lock.readLock().unlock();
        }
    }

    public void put(String key, String value) {
        lock.writeLock().lock();
        try {
            cache.put(key, value);  // Exclusive access
        } finally {
            lock.writeLock().unlock();
        }
    }
}
```

## Common Thread Safety Issues

### 1. Double-Checked Locking (Broken Pattern)

```java
// BROKEN - Can initialize twice!
public class Singleton {
    private static Singleton instance;

    public static Singleton getInstance() {
        if (instance == null) {  // First check (not synchronized)
            synchronized(Singleton.class) {
                if (instance == null) {  // Second check
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}

// FIXED - Use volatile
public class Singleton {
    private static volatile Singleton instance;

    public static Singleton getInstance() {
        if (instance == null) {
            synchronized(Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}

// BEST - Use eager initialization or enum
public enum Singleton {
    INSTANCE;

    public void doSomething() {
        // ...
    }
}
```

### 2. Memory Visibility Issues

```java
// PROBLEM - Without volatile, changes may not be visible
public class StopFlag {
    private boolean shouldStop = false;

    public void stop() {
        shouldStop = true;
    }

    public void run() {
        while (!shouldStop) {
            doWork();
        }
    }
}

// SOLUTION - Use volatile
public class StopFlag {
    private volatile boolean shouldStop = false;

    public void stop() {
        shouldStop = true;
    }

    public void run() {
        while (!shouldStop) {
            doWork();
        }
    }
}
```

## Performance Considerations

### Synchronization Overhead

```java
// Benchmark: synchronized vs atomic vs volatile
public class SynchronizationBenchmark {
    // Synchronized - slowest
    private int syncCount = 0;
    public synchronized void syncIncrement() {
        syncCount++;
    }

    // Atomic - faster
    private AtomicInteger atomicCount = new AtomicInteger();
    public void atomicIncrement() {
        atomicCount.incrementAndGet();
    }

    // Volatile - fastest for simple cases
    private volatile int volatileCount = 0;
    public void volatileIncrement() {
        volatileCount++;  // Not atomic, but visible
    }
}
```

## Summary

Key principles:
- ✅ Identify shared mutable state
- ✅ Use appropriate synchronization mechanism
- ✅ Prefer immutability when possible
- ✅ Use thread-safe collections (ConcurrentHashMap, etc.)
- ✅ Minimize synchronized scope
- ✅ Avoid deadlocks through lock ordering
- ✅ Use volatile for visibility, atomic for atomicity
- ✅ Always measure performance impact
- ✅ Consider using CompletableFuture for async work
