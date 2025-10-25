# AOP & Cross-Cutting Concerns

## Aspect-Oriented Programming

```java
// Pointcut: Where to apply
// Advice: What to do

@Aspect
@Component
public class LoggingAspect {

    @Pointcut("execution(* com.example.service.*.*(..))")
    public void serviceLayer() {}

    @Before("serviceLayer()")
    public void logBefore(JoinPoint joinPoint) {
        System.out.println("Calling: " + joinPoint.getSignature());
    }

    @AfterReturning(pointcut = "serviceLayer()", returning = "result")
    public void logAfterReturning(JoinPoint joinPoint, Object result) {
        System.out.println("Returned: " + result);
    }

    @AfterThrowing(pointcut = "serviceLayer()", throwing = "ex")
    public void logAfterThrowing(JoinPoint joinPoint, Exception ex) {
        System.err.println("Exception: " + ex.getMessage());
    }

    @Around("serviceLayer()")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();

        try {
            Object result = joinPoint.proceed();
            return result;
        } finally {
            long duration = System.currentTimeMillis() - start;
            System.out.println("Duration: " + duration + "ms");
        }
    }
}
```

## Common AOP Patterns

```java
// Performance Monitoring
@Aspect
@Component
public class PerformanceAspect {

    @Around("@annotation(com.example.Monitored)")
    public Object monitor(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.nanoTime();
        try {
            return joinPoint.proceed();
        } finally {
            long duration = (System.nanoTime() - start) / 1_000_000;
            System.out.println(joinPoint.getSignature() + " took " + duration + "ms");
        }
    }
}

// Security Aspect
@Aspect
@Component
public class SecurityAspect {

    @Before("@annotation(com.example.RequireAdmin)")
    public void checkAdmin() {
        if (!isAdmin()) {
            throw new SecurityException("Admin access required");
        }
    }

    private boolean isAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth.getAuthorities().stream()
            .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
    }
}

// Caching Aspect
@Aspect
@Component
public class CachingAspect {

    private final Map<String, Object> cache = new ConcurrentHashMap<>();

    @Around("@annotation(com.example.Cacheable)")
    public Object cache(ProceedingJoinPoint joinPoint) throws Throwable {
        String key = getCacheKey(joinPoint);

        Object cached = cache.get(key);
        if (cached != null) {
            return cached;
        }

        Object result = joinPoint.proceed();
        cache.put(key, result);
        return result;
    }
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequireAdmin {}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Monitored {}
```

