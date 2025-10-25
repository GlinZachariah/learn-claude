# Concurrent Collections & Performance

## ConcurrentHashMap Deep Dive

```java
public class ConcurrentHashMapOptimization {

    /**
     * Bucket-level locking provides better concurrency than whole-map locking
     */
    public static class ConcurrentHashMapVsSynchronized {
        // ConcurrentHashMap: Segment-level locking (16 segments by default)
        // Multiple threads can write to different segments simultaneously

        // synchronized HashMap: Whole-map lock
        // Only one thread can access at a time

        public void compare() {
            ConcurrentHashMap<String, String> concurrent = new ConcurrentHashMap<>();
            Map<String, String> sync = Collections.synchronizedMap(new HashMap<>());

            // Benchmark: 10K concurrent reads/writes
            // ConcurrentHashMap: ~50K ops/sec
            // Synchronized: ~5K ops/sec (10x slower)
        }
    }

    /**
     * Atomic operations in ConcurrentHashMap
     */
    public void atomicOperations() {
        ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

        // putIfAbsent: Atomic check-then-act
        map.putIfAbsent("count", 0);
        map.putIfAbsent("count", 5);  // No-op (already exists)

        // computeIfAbsent: Lazy initialization
        Integer value = map.computeIfAbsent("lazy", k -> expensiveComputation());

        // merge: Atomic update
        map.merge("count", 1, Integer::sum);

        // forEach: Concurrent iteration
        map.forEach((k, v) -> System.out.println(k + "=" + v));
    }

    private Integer expensiveComputation() {
        return 42;
    }
}
```

## BlockingQueue Family

```java
public class BlockingQueuePatterns {

    /**
     * Producer-Consumer pattern
     */
    public static void producerConsumer() throws InterruptedException {
        BlockingQueue<String> queue = new LinkedBlockingQueue<>(100);

        // Producer
        Thread producer = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                try {
                    queue.put("item-" + i);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        });

        // Consumer
        Thread consumer = new Thread(() -> {
            try {
                while (true) {
                    String item = queue.take();  // Blocks if empty
                    processItem(item);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });

        producer.start();
        consumer.start();
    }

    /**
     * Work Queue pattern
     */
    public static class WorkQueue {
        private final BlockingQueue<Task> queue = new LinkedBlockingQueue<>();
        private final ExecutorService workers = Executors.newFixedThreadPool(10);

        public void submit(Task task) throws InterruptedException {
            queue.put(task);
        }

        public void start() {
            for (int i = 0; i < 10; i++) {
                workers.submit(() -> {
                    try {
                        while (true) {
                            Task task = queue.take();
                            task.execute();
                        }
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                });
            }
        }

        static class Task {
            void execute() {}
        }
    }

    /**
     * Different queue types
     */
    public void queueComparison() {
        // LinkedBlockingQueue: Unlimited (or bounded), links nodes
        BlockingQueue<String> linked = new LinkedBlockingQueue<>();

        // ArrayBlockingQueue: Fixed size, array-based, better memory efficiency
        BlockingQueue<String> array = new ArrayBlockingQueue<>(100);

        // SynchronousQueue: 0-capacity, direct handoff
        BlockingQueue<String> sync = new SynchronousQueue<>();

        // PriorityBlockingQueue: Ordered by priority
        BlockingQueue<String> priority = new PriorityBlockingQueue<>();
    }

    private static void processItem(String item) {}
}
```

## ConcurrentSkipListMap

```java
public class ConcurrentSkipListExample {

    /**
     * Sorted concurrent map using skip lists
     */
    public void skippListOperations() {
        ConcurrentSkipListMap<Integer, String> leaderboard = new ConcurrentSkipListMap<>();

        // Insert scores
        leaderboard.put(100, "Player1");
        leaderboard.put(95, "Player2");
        leaderboard.put(88, "Player3");

        // Get range (top 10)
        NavigableMap<Integer, String> top10 = leaderboard
            .descendingMap()
            .headMap(95, false);  // Exclusive

        // Iterate in order
        leaderboard.forEach((score, name) ->
            System.out.println(name + ": " + score)
        );

        // Benefits over TreeMap:
        // - Thread-safe without locking
        // - Concurrent iteration
        // - O(log n) operations
    }
}
```

## Synchronization Primitives

```java
public class SynchronizationPatterns {

    /**
     * Phaser: Flexible barrier for multiple phases
     */
    public static class PhaserExample {
        public void multiPhaseSync() throws InterruptedException {
            Phaser phaser = new Phaser(3);  // 3 participants

            Thread t1 = new Thread(() -> {
                System.out.println("T1: Phase 1");
                phaser.arriveAndAwaitAdvance();  // Wait for others

                System.out.println("T1: Phase 2");
                phaser.arriveAndDeregister();
            });

            Thread t2 = new Thread(() -> {
                System.out.println("T2: Phase 1");
                phaser.arriveAndAwaitAdvance();

                System.out.println("T2: Phase 2");
                phaser.arriveAndDeregister();
            });

            Thread t3 = new Thread(() -> {
                System.out.println("T3: Phase 1");
                phaser.arriveAndAwaitAdvance();

                System.out.println("T3: Phase 2");
                phaser.arriveAndDeregister();
            });

            t1.start();
            t2.start();
            t3.start();
            t1.join();
            t2.join();
            t3.join();
        }
    }

    /**
     * CyclicBarrier: Fixed-party synchronization
     */
    public static class CyclicBarrierExample {
        public void barrierSync() throws InterruptedException, BrokenBarrierException {
            CyclicBarrier barrier = new CyclicBarrier(3, () ->
                System.out.println("All threads reached barrier")
            );

            for (int i = 0; i < 3; i++) {
                new Thread(() -> {
                    try {
                        System.out.println("Thread " + Thread.currentThread().getId() + " waiting");
                        barrier.await();  // Wait for all
                        System.out.println("Thread " + Thread.currentThread().getId() + " proceeding");
                    } catch (InterruptedException | BrokenBarrierException e) {
                        e.printStackTrace();
                    }
                }).start();
            }
        }
    }

    /**
     * Semaphore: Resource pooling
     */
    public static class SemaphoreExample {
        private final Semaphore permits = new Semaphore(5);  // 5 permits

        public void accessLimitedResource() throws InterruptedException {
            permits.acquire();
            try {
                // Use resource (max 5 concurrent)
                System.out.println("Using resource");
                Thread.sleep(100);
            } finally {
                permits.release();
            }
        }
    }
}
```

## Performance Monitoring

```java
public class ConcurrentCollectionMetrics {

    /**
     * Monitor ConcurrentHashMap behavior
     */
    public void monitorConcurrentHashMap() {
        ConcurrentHashMap<String, String> map = new ConcurrentHashMap<>();

        // Add some data
        for (int i = 0; i < 10000; i++) {
            map.put("key" + i, "value" + i);
        }

        // Measure performance
        long start = System.currentTimeMillis();

        IntStream.range(0, 1_000_000).parallel()
            .forEach(i -> map.get("key" + (i % 10000)));

        long duration = System.currentTimeMillis() - start;

        System.out.println("1M gets in " + duration + "ms");
        System.out.println("Throughput: " + (1_000_000 / duration) + " ops/ms");
    }

    /**
     * Lock contention analysis
     */
    public void analyzeLockContention() {
        // Using ThreadMXBean to detect lock contention
        ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();

        for (ThreadInfo info : threadBean.dumpAllThreads(false, false)) {
            if (info.getThreadState() == Thread.State.BLOCKED) {
                System.out.println("Thread blocked on: " + info.getLockName());
            }
        }
    }
}
```

## Migration from Synchronized Collections

```java
public class CollectionMigration {

    public void migrateFromSynchronized() {
        // Before: Synchronized Map
        Map<String, String> oldMap = Collections.synchronizedMap(new HashMap<>());

        // After: ConcurrentHashMap
        Map<String, String> newMap = new ConcurrentHashMap<>();

        // Copy data
        newMap.putAll(oldMap);

        // Test before switching
        testPerformance(oldMap, newMap);
    }

    private void testPerformance(Map<String, String> oldMap, Map<String, String> newMap) {
        // Benchmark both implementations
        // Compare throughput, latency, resource usage

        System.out.println("Old: " + benchmarkMap(oldMap) + " ops/sec");
        System.out.println("New: " + benchmarkMap(newMap) + " ops/sec");
    }

    private long benchmarkMap(Map<String, String> map) {
        long start = System.nanoTime();
        for (int i = 0; i < 100000; i++) {
            map.get("key" + (i % 1000));
        }
        return (System.nanoTime() - start) / 100000;
    }
}
```

## Summary

Concurrent collections provide:
- ✅ Fine-grained locking
- ✅ Concurrent reads and writes
- ✅ Ordered data structures (SkipList)
- ✅ Blocking queues for coordination
- ✅ Synchronization primitives
- ✅ Thread-safe iteration

Choose based on: read/write ratio, ordering needs, blocking semantics
