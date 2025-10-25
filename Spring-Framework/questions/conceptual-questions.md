# Spring Framework - Conceptual Questions

## IoC & Dependency Injection

### Q1: Explain the difference between IoC and traditional object creation
**Question:** What is the fundamental difference between Inversion of Control (IoC) and traditional object creation patterns? Why is this important?

**Answer:**
- **Traditional:** Application code controls object creation and lifecycle
- **IoC:** Framework controls object creation and lifecycle
- **Importance:** Decoupling, testability, flexibility, centralized configuration

**Example:**
```java
// Traditional: Tight coupling
public class OrderService {
    private PaymentProcessor processor = new StripeProcessor();
}

// IoC: Spring manages dependency
@Service
public class OrderService {
    private final PaymentProcessor processor;
    @Autowired
    public OrderService(PaymentProcessor processor) {
        this.processor = processor;
    }
}
```

**Difficulty:** Beginner | **Tags:** #IoC #DependencyInjection

---

### Q2: Why is constructor injection preferred over field injection?
**Question:** Explain the advantages of constructor injection compared to field injection in Spring applications.

**Answer:**
- **Immutability:** Dependencies are final
- **Testability:** Easy to provide test doubles
- **Fail-Fast:** Detects missing dependencies at startup
- **Clarity:** Dependencies explicit in constructor signature
- **Circular Dependency Detection:** Caught immediately

**Example:**
```java
// Constructor injection - PREFERRED
@Service
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;

    public UserService(UserRepository repository, EmailService emailService) {
        this.repository = repository;
        this.emailService = emailService;
    }
}

// Field injection - ANTI-PATTERN
@Service
public class UserService {
    @Autowired
    private UserRepository repository;

    @Autowired
    private EmailService emailService;

    // Problems: Hard to test, NullPointerException risks, not immutable
}
```

**Difficulty:** Beginner | **Tags:** #DependencyInjection #BestPractices

---

### Q3: Explain bean scopes and when to use each one
**Question:** What are the different bean scopes in Spring? Provide scenarios where you would use each scope.

**Answer:**
- **Singleton** (default): One instance per ApplicationContext
  - Use for: Stateless services, repositories
- **Prototype**: New instance for each injection
  - Use for: Stateful objects, objects with mutable state
- **Request**: One per HTTP request
  - Use for: Request-scoped data, web controllers
- **Session**: One per user session
  - Use for: User session data, shopping cart
- **Application**: One per ServletContext
  - Use for: Shared application resources

**Difficulty:** Intermediate | **Tags:** #BeanScopes #Spring

---

### Q4: What is the bean lifecycle and why is it important?
**Question:** Describe the complete bean lifecycle in Spring and why understanding it is crucial for application development.

**Answer:**
1. **Bean Definition:** Spring reads configuration
2. **Instantiation:** Constructor called via reflection
3. **Dependency Injection:** Dependencies injected
4. **Initialize Callbacks:** @PostConstruct or InitializingBean
5. **Bean Ready:** Available for use
6. **Destroy Callbacks:** @PreDestroy or DisposableBean

**Importance:**
- Resource initialization (database connections, thread pools)
- Configuration validation
- Cache warm-up
- Proper cleanup and shutdown
- Coordination between beans

**Difficulty:** Intermediate | **Tags:** #BeanLifecycle #Spring

---

## Spring Web MVC

### Q5: How does DispatcherServlet work?
**Question:** Explain the request flow through DispatcherServlet and the roles of HandlerMapping, HandlerAdapter, and ViewResolver.

**Answer:**
1. **DispatcherServlet** receives HTTP request
2. **HandlerMapping** finds matching controller method
3. **HandlerAdapter** executes the controller
4. **Controller** processes request, returns model/view
5. **ViewResolver** finds the actual view
6. **View** renders response

**Difficulty:** Intermediate | **Tags:** #SpringMVC #DispatcherServlet

---

### Q6: What's the difference between @Controller and @RestController?
**Question:** Explain the differences between @Controller and @RestController and when to use each.

**Answer:**
- **@Controller:** Returns view names (JSP, Thymeleaf, etc.)
  - Requires @ResponseBody on methods to return JSON
- **@RestController:** Automatically applies @ResponseBody
  - Returns JSON/XML directly
  - Combination of @Controller + @ResponseBody

**Example:**
```java
// Traditional controller returning views
@Controller
public class ViewController {
    @GetMapping("/users")
    public String getUsers(Model model) {
        model.addAttribute("users", userService.getAll());
        return "users";  // View name
    }
}

// REST controller returning JSON
@RestController
@RequestMapping("/api/users")
public class UserRestController {
    @GetMapping
    public List<UserDTO> getUsers() {
        return userService.getAll();  // Automatically converted to JSON
    }
}
```

**Difficulty:** Beginner | **Tags:** #SpringMVC #REST

---

## Transactions

### Q7: Explain @Transactional and transaction propagation
**Question:** What does @Transactional do? Explain the different propagation behaviors and when to use each.

**Answer:**
- **@Transactional:** Wraps method in transaction
- **Propagation behaviors:**
  - **REQUIRED:** Use existing or create new (default)
  - **REQUIRES_NEW:** Always create new
  - **NESTED:** Create savepoint
  - **NOT_SUPPORTED:** Suspend transaction
  - **MANDATORY:** Fail if no transaction exists

**Importance:**
- Data consistency
- Atomicity (all or nothing)
- Rollback on exceptions
- Performance optimization with read-only

**Difficulty:** Advanced | **Tags:** #Transactions #Spring

---

### Q8: What is optimistic locking and when is it needed?
**Question:** Explain optimistic locking and how it differs from pessimistic locking. When would you use each?

**Answer:**
- **Optimistic Locking:** Assume conflicts are rare, use version field
  - Pros: High concurrency, no locks
  - Cons: Must handle OptimisticLockException
  - Use: Infrequent updates, high concurrency

- **Pessimistic Locking:** Lock resource while updating
  - Pros: Guaranteed consistency
  - Cons: Lower concurrency, potential deadlocks
  - Use: Frequent conflicts, critical data

**Example:**
```java
@Entity
public class Product {
    @Version
    private Long version;  // Optimistic lock
}
```

**Difficulty:** Advanced | **Tags:** #Transactions #Concurrency

---

## Spring Security

### Q9: How does Spring Security handle authentication and authorization?
**Question:** Explain how Spring Security authenticates users and authorizes access to resources.

**Answer:**
- **Authentication:** Verifies identity (username/password)
- **Authorization:** Checks permissions for resources
- **Process:**
  1. AuthenticationFilter intercepts request
  2. AuthenticationManager authenticates credentials
  3. SecurityContext stores authenticated principal
  4. AccessDecisionManager checks authorization
  5. Request proceeds or denied

**Difficulty:** Intermediate | **Tags:** #Security #Authentication

---

### Q10: What is the difference between @PreAuthorize and @PostAuthorize?
**Question:** Explain the differences between @PreAuthorize and @PostAuthorize annotations.

**Answer:**
- **@PreAuthorize:** Checks authorization BEFORE method execution
  - Use: Most scenarios
  - Example: Check role before deleting user

- **@PostAuthorize:** Checks authorization AFTER method returns
  - Use: When result needs to be evaluated
  - Example: Return only user's own data

**Example:**
```java
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) { }

@PostAuthorize("returnObject.userId == principal.id")
public User getUser(Long id) { }
```

**Difficulty:** Intermediate | **Tags:** #Security #Authorization

---

## Data Access & JPA

### Q11: What is the N+1 query problem and how do you solve it?
**Question:** Explain the N+1 query problem and provide solutions.

**Answer:**
**Problem:**
- 1 query to fetch users
- N additional queries to fetch each user's company

**Solutions:**
1. **Fetch Join:** `LEFT JOIN FETCH u.company`
2. **Entity Graph:** @EntityGraph(attributePaths = {"company"})
3. **Batch Loading:** Configure fetch size
4. **Projection:** Only fetch needed columns

**Difficulty:** Intermediate | **Tags:** #JPA #Performance

---

### Q12: Explain Specifications API and when to use it
**Question:** What is the Specifications API in Spring Data JPA? When would you use it instead of custom query methods?

**Answer:**
- **Specifications:** Build dynamic queries at runtime
- **Benefits:** Reusable criteria, no method explosion
- **When to use:** Complex filtering, user-defined search

**Example:**
```java
Specification<User> spec = Specification
    .where(hasStatus(ACTIVE))
    .and(createdAfter(LocalDateTime.now().minusMonths(1)))
    .and(emailLike("test@"));

List<User> users = repository.findAll(spec);
```

**Difficulty:** Advanced | **Tags:** #JPA #SpringData

---

## AOP

### Q13: What is Aspect-Oriented Programming and what problems does it solve?
**Question:** Explain AOP and its use cases. What cross-cutting concerns can be addressed with AOP?

**Answer:**
- **AOP:** Separates cross-cutting concerns from business logic
- **Problems solved:**
  - Logging
  - Performance monitoring
  - Security checks
  - Transaction management
  - Caching
  - Error handling

**Benefits:**
- Reduced code duplication
- Cleaner business logic
- Centralized concern management
- Easy to modify/disable

**Difficulty:** Advanced | **Tags:** #AOP #Spring

---

### Q14: Explain pointcut expressions and advice types
**Question:** What are pointcuts and advice in Spring AOP? Explain different advice types.

**Answer:**
- **Pointcut:** Where to apply aspect (which methods)
- **Advice:** What to do (the action)

**Advice types:**
- **@Before:** Execute before method
- **@After:** Execute after method (always)
- **@AfterReturning:** Execute after successful return
- **@AfterThrowing:** Execute on exception
- **@Around:** Execute before and after (most flexible)

**Difficulty:** Advanced | **Tags:** #AOP #Aspects

---

## Performance & Optimization

### Q15: What caching strategies exist and when would you use each?
**Question:** Explain different caching strategies (@Cacheable, @CachePut, @CacheEvict) and use cases.

**Answer:**
- **@Cacheable:** Cache result of method
  - Use: Expensive reads
- **@CachePut:** Always execute and update cache
  - Use: Updates that should refresh cache
- **@CacheEvict:** Remove from cache
  - Use: Deletions, invalidations

**Difficulty:** Intermediate | **Tags:** #Caching #Performance

---

## Testing

### Q16: What's the difference between @WebMvcTest and @SpringBootTest?
**Question:** When would you use @WebMvcTest versus @SpringBootTest for testing?

**Answer:**
- **@WebMvcTest:** Lightweight, only web layer
  - Fast
  - Mock services
  - Use: Controller unit tests

- **@SpringBootTest:** Full application context
  - Slower
  - Real components
  - Use: Integration tests

**Difficulty:** Intermediate | **Tags:** #Testing #SpringBoot

---

## Cloud & Microservices

### Q17: What is service discovery and why is it important in microservices?
**Question:** Explain service discovery and its importance in microservice architecture.

**Answer:**
- **Service Discovery:** Automatically locate service instances
- **Why needed:** Services scale dynamically, IPs change
- **Examples:** Eureka, Consul, Kubernetes

**Benefits:**
- Automatic load balancing
- Fault tolerance
- Scalability
- No hardcoded URLs

**Difficulty:** Advanced | **Tags:** #Microservices #SpringCloud

---

### Q18: What is a circuit breaker and how does Resilience4j implement it?
**Question:** Explain the circuit breaker pattern and how it prevents cascading failures.

**Answer:**
- **States:**
  - **CLOSED:** Normal operation
  - **OPEN:** Failing, reject requests
  - **HALF_OPEN:** Testing if service recovered

- **Benefits:**
  - Prevents cascading failures
  - Fast fail instead of hanging
  - Automatic recovery

**Difficulty:** Advanced | **Tags:** #Microservices #Resilience4j

---

## Summary Questions

### Q19: Compare Spring Framework with other Java frameworks
**Question:** How does Spring compare to Jakarta EE, Quarkus, and Micronaut?

**Answer:**
| Feature | Spring | Jakarta EE | Quarkus | Micronaut |
|---------|--------|------------|---------|-----------|
| Startup | 2-3s | 2-3s | 0.2-0.5s | 0.5-1s |
| Memory | 300-400MB | 300-400MB | 100-150MB | 150-200MB |
| Native Build | ✓ | Limited | ✓ | ✓ |
| Ecosystem | Massive | Standard | Growing | Growing |

**Difficulty:** Advanced | **Tags:** #Frameworks #Comparison

---

### Q20: What are the key principles for designing Spring applications?
**Question:** List and explain key design principles for enterprise Spring applications.

**Answer:**
1. **Dependency Injection:** Loose coupling
2. **Single Responsibility:** One reason to change
3. **SOLID Principles:** Design patterns
4. **DRY:** Don't repeat yourself
5. **Separation of Concerns:** Clear layer boundaries
6. **Composition over Inheritance:** Flexibility
7. **Interface Segregation:** Specific contracts

**Difficulty:** Advanced | **Tags:** #DesignPrinciples #SOLID

---

**Total Questions:** 20
**Difficulty Levels:** Beginner (3), Intermediate (9), Advanced (8)
**Topics:** IoC/DI (3), MVC (2), Transactions (2), Security (2), JPA (2), AOP (2), Caching (1), Testing (1), Microservices (2), General (0)
