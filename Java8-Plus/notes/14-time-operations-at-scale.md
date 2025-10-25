# Time Operations at Scale: Scheduling & Distributed Systems

## ScheduledExecutorService Deep Dive

```java
public class SchedulingPatterns {

    /**
     * Fixed-rate scheduling: Execute every N time units
     */
    public void fixedRateScheduling() {
        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(5);

        scheduler.scheduleAtFixedRate(
            () -> System.out.println("Fixed rate execution"),
            0,           // Initial delay
            1,           // Period
            TimeUnit.SECONDS
        );

        // Use case: Regular polling, health checks, metric collection
    }

    /**
     * Fixed-delay scheduling: Wait N time units after completion
     */
    public void fixedDelayScheduling() {
        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(5);

        scheduler.scheduleWithFixedDelay(
            () -> {
                System.out.println("Work started");
                sleep(500);
                System.out.println("Work completed");
            },
            0,    // Initial delay
            2,    // Delay after completion
            TimeUnit.SECONDS
        );

        // Execution timeline:
        // T=0: Work starts
        // T=500ms: Work ends
        // T=2500ms: Next execution (2s after end)
    }

    /**
     * One-time delayed execution
     */
    public void delayedExecution() {
        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

        ScheduledFuture<String> future = scheduler.schedule(
            () -> "Task result",
            5,
            TimeUnit.SECONDS
        );

        // Get result or wait for timeout
        try {
            String result = future.get(6, TimeUnit.SECONDS);
            System.out.println(result);
        } catch (TimeoutException e) {
            System.out.println("Timeout waiting for task");
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
    }

    /**
     * Exception handling in scheduled tasks
     */
    public void robustScheduling() {
        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

        scheduler.scheduleAtFixedRate(
            () -> {
                try {
                    riskyOperation();
                } catch (Exception e) {
                    logger.error("Task failed, will retry", e);
                    // Scheduler continues despite exception
                }
            },
            0,
            5,
            TimeUnit.SECONDS
        );
    }

    private void riskyOperation() throws Exception {
        if (Math.random() < 0.3) {
            throw new RuntimeException("Random failure");
        }
    }

    private static final Logger logger = LoggerFactory.getLogger(SchedulingPatterns.class);
}
```

## Quartz Scheduler Integration

```java
public class QuartzScheduling {

    /**
     * Schedule jobs with Cron expressions
     */
    public void scheduleWithQuartz() throws SchedulerException {
        JobDetail job = JobBuilder.newJob(MyJob.class)
            .withIdentity("job1", "group1")
            .build();

        // Cron: "0 0 * * * ?" = Every hour
        CronTrigger trigger = TriggerBuilder.newTrigger()
            .withIdentity("trigger1", "group1")
            .withSchedule(CronScheduleBuilder.cronSchedule("0 0 * * * ?"))
            .build();

        Scheduler scheduler = new StdSchedulerFactory().getScheduler();
        scheduler.start();
        scheduler.scheduleJob(job, trigger);
    }

    /**
     * Custom Job implementation
     */
    public static class MyJob implements Job {
        @Override
        public void execute(JobExecutionContext context) throws JobExecutionException {
            System.out.println("Job executed at " + new Date());
        }
    }

    /**
     * Common Cron patterns
     */
    public void cronPatterns() {
        String everyMinute = "0 * * * * ?";              // Every minute
        String everyHour = "0 0 * * * ?";                // Every hour
        String everyDay = "0 0 0 * * ?";                 // Every day
        String everyWeekday = "0 0 * * MON-FRI ?";      // Weekdays
        String firstOfMonth = "0 0 0 1 * ?";             // 1st of month
        String quarterHourly = "0 0/15 * * * ?";         // Every 15 minutes
    }
}
```

## Time-Based Event Ordering in Distributed Systems

```java
public class DistributedTimeOrdering {

    /**
     * Lamport Logical Clocks: Order events causally
     */
    public static class LamportClock {
        private long logicalTime = 0;

        public synchronized long increment() {
            return ++logicalTime;
        }

        public synchronized void receiveTimestamp(long remoteTime) {
            logicalTime = Math.max(logicalTime, remoteTime) + 1;
        }

        public long getTime() {
            return logicalTime;
        }

        // Usage:
        // Local event: local_clock.increment()
        // Receive message with timestamp T: local_clock.receiveTimestamp(T)
        // Ensures: if A → B causally, then time(A) < time(B)
    }

    /**
     * Vector Clocks: Track causality between processes
     */
    public static class VectorClock {
        private final int processId;
        private final long[] clock;
        private final int numProcesses;

        public VectorClock(int processId, int numProcesses) {
            this.processId = processId;
            this.numProcesses = numProcesses;
            this.clock = new long[numProcesses];
        }

        public void increment() {
            clock[processId]++;
        }

        public void receiveVector(long[] remoteVector) {
            for (int i = 0; i < numProcesses; i++) {
                clock[i] = Math.max(clock[i], remoteVector[i]);
            }
            clock[processId]++;
        }

        public long[] getVector() {
            return clock.clone();
        }
    }

    /**
     * Wall-clock time with UTC for cross-timezone coordination
     */
    public void coordinateAcrossTimezones() {
        // Always use UTC internally
        ZonedDateTime utcNow = ZonedDateTime.now(ZoneId.of("UTC"));

        // Convert to user's timezone for display
        ZoneId userZone = ZoneId.of("America/New_York");
        ZonedDateTime userTime = utcNow.withZoneSameInstant(userZone);

        System.out.println("UTC: " + utcNow);
        System.out.println("User: " + userTime);
    }
}
```

## Daylight Saving Time Handling

```java
public class DSTHandling {

    /**
     * Schedule job across DST transition
     */
    public void scheduleDuringDST() {
        LocalDateTime beforeDST = LocalDateTime.of(2024, 3, 10, 1, 0);  // Spring forward
        LocalDateTime afterDST = beforeDST.plusHours(1);

        ZoneId ny = ZoneId.of("America/New_York");
        ZonedDateTime before = ZonedDateTime.of(beforeDST, ny);
        ZonedDateTime after = ZonedDateTime.of(afterDST, ny);

        // During spring DST, 2:00 AM becomes 3:00 AM
        // Need to handle missing hour
        System.out.println("Before: " + before);  // 01:00:00-05:00
        System.out.println("After: " + after);   // 02:00:00-04:00 (skips to 03:00)
    }

    /**
     * Cron expression handling for DST
     */
    public void cronDuringDST() {
        // Quartz handles DST transitions automatically
        // "0 2 * * ?" (run at 2 AM daily)
        // During spring forward, skips that execution
        // During fall back, runs twice

        // Use caution with: daily, weekly, monthly jobs during DST transitions
    }
}
```

## Timezone-Aware Scheduling

```java
public class TimezoneAwareScheduling {

    /**
     * Schedule job in user's timezone
     */
    public CompletableFuture<Void> scheduleInUserTimezone(
            String cronExpression,
            ZoneId userZone,
            Runnable job) {

        ZoneId systemZone = ZoneId.systemDefault();

        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

        return CompletableFuture.runAsync(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                ZonedDateTime now = ZonedDateTime.now(userZone);
                ZonedDateTime nextExecution = calculateNext(now, cronExpression, userZone);
                long delayMs = ChronoUnit.MILLIS.between(now, nextExecution);

                if (delayMs > 0) {
                    try {
                        Thread.sleep(delayMs);
                        job.run();
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
            }
        }, scheduler);
    }

    private ZonedDateTime calculateNext(ZonedDateTime now, String cron, ZoneId zone) {
        // Parse cron and calculate next execution time in given timezone
        return now.plusHours(1);  // Simplified
    }

    /**
     * Business hours scheduling
     */
    public boolean isBusinessHours(ZoneId zone) {
        ZonedDateTime now = ZonedDateTime.now(zone);
        int hour = now.getHour();
        DayOfWeek day = now.getDayOfWeek();

        boolean isWeekday = day != DayOfWeek.SATURDAY && day != DayOfWeek.SUNDAY;
        boolean isBusinessHour = hour >= 9 && hour < 17;

        return isWeekday && isBusinessHour;
    }
}
```

## Idempotent Scheduling

```java
public class IdempotentScheduling {

    /**
     * Prevent duplicate job execution with distributed lock
     */
    public static class IdempotentJob {
        private final Jedis redis = new Jedis();

        public void executeOnce(String jobId) {
            String lockKey = "job-lock:" + jobId;

            // Try to acquire lock
            String result = redis.set(lockKey, "locked",
                SetParams.setParams().nx().ex(300));  // 5 minute TTL

            if (result != null) {  // Got lock
                try {
                    doWork();
                    recordExecution(jobId);
                } finally {
                    redis.del(lockKey);
                }
            } else {
                logger.info("Job already running, skipping");
            }
        }

        private void doWork() {
            System.out.println("Executing idempotent job");
        }

        private void recordExecution(String jobId) {
            redis.set("job-executed:" + jobId, System.currentTimeMillis() + "");
        }
    }

    /**
     * Deduplication with execution tracking
     */
    public static class JobDeduplication {
        private final Map<String, Long> executedJobs = new ConcurrentHashMap<>();

        public void executeIfNotDuplicate(String jobId, Runnable job) {
            Long lastExecution = executedJobs.get(jobId);
            long now = System.currentTimeMillis();

            if (lastExecution == null || (now - lastExecution) > 60_000) {  // 1 minute
                job.run();
                executedJobs.put(jobId, now);
            }
        }
    }

    private static final Logger logger = LoggerFactory.getLogger(IdempotentScheduling.class);
}
```

## Real-World Patterns

```java
public class SchedulingPatternExamples {

    /**
     * Retry with exponential backoff
     */
    public CompletableFuture<Void> retryableSchedule(
            Supplier<CompletableFuture<Void>> task,
            int maxRetries) {

        return executeWithRetry(task, maxRetries, 1);
    }

    private CompletableFuture<Void> executeWithRetry(
            Supplier<CompletableFuture<Void>> task,
            int retriesLeft,
            int attemptNumber) {

        return task.get()
            .exceptionally(ex -> {
                if (retriesLeft > 0) {
                    long delayMs = (long) Math.pow(2, attemptNumber - 1) * 100;

                    CompletableFuture<Void> delayed = new CompletableFuture<>();
                    Executors.newScheduledThreadPool(1).schedule(() -> {
                        executeWithRetry(task, retriesLeft - 1, attemptNumber + 1)
                            .whenComplete((r, e) -> {
                                if (e != null) {
                                    delayed.completeExceptionally(e);
                                } else {
                                    delayed.complete(null);
                                }
                            });
                    }, delayMs, TimeUnit.MILLISECONDS);

                    return delayed;
                }
                throw new CompletionException(ex);
            });
    }

    /**
     * Batch job scheduling with daily processing
     */
    public void scheduleDailyBatchJob() {
        ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

        scheduler.scheduleAtFixedRate(
            this::processDailyBatch,
            calculateInitialDelay(),
            1,
            TimeUnit.DAYS
        );
    }

    private void processDailyBatch() {
        System.out.println("Daily batch processing at " + LocalDateTime.now());
    }

    private long calculateInitialDelay() {
        // Schedule for 2 AM tomorrow
        LocalDateTime tomorrow = LocalDateTime.now().plusDays(1);
        LocalDateTime twoAM = tomorrow.withHour(2).withMinute(0).withSecond(0);

        return ChronoUnit.SECONDS.between(LocalDateTime.now(), twoAM);
    }
}
```

## Summary

Scheduling at scale involves:
- ✅ ScheduledExecutorService for simple cases
- ✅ Quartz for complex job management
- ✅ Logical clocks for event ordering
- ✅ UTC for cross-timezone coordination
- ✅ DST-aware scheduling
- ✅ Idempotent execution
- ✅ Retry mechanisms
- ✅ Distributed coordination

Best practices: Use UTC internally, handle DST explicitly, ensure idempotency
