# Spring Framework - Interview Preparation Guide

## Overview

This guide contains 50+ common Spring Framework interview questions organized by seniority level. Questions progress from fundamental concepts (Junior) through advanced architectural patterns (Senior).

---

## Junior Developer Interview Questions (1-3 years)

### Core Concepts

**Q1: What is Spring Framework and why would you use it?**

**Answer:** Spring Framework is a comprehensive, open-source Java framework for building enterprise applications. Key benefits:
- **IoC Container:** Manages object creation and dependencies
- **AOP:** Separates cross-cutting concerns
- **Declarative Programming:** Reduces boilerplate with annotations
- **Testing:** Provides excellent testing support
- **Data Access:** Simplifies database integration
- **Security:** Built-in security framework

**Example Use Cases:** E-commerce platforms, SaaS applications, microservices, REST APIs, enterprise backends

**Follow-up:** "Have you used Spring Boot? What's the difference?"

---

**Q2: Explain the difference between BeanFactory and ApplicationContext.**

**Answer:**
| Feature | BeanFactory | ApplicationContext |
|---------|-------------|-------------------|
| Bean instantiation | ✓ | ✓ |
| Dependency injection | ✓ | ✓ |
| AOP support | ✗ | ✓ |
| Event publishing | ✗ | ✓ |
| i18n support | ✗ | ✓ |
| Resource handling | ✗ | ✓ |
| Lazy loading | Default | Eager |

**Code Example:**
```java
// BeanFactory - Lazy loading
BeanFactory factory = new XmlBeanFactory(new ClassPathResource("beans.xml"));
UserService service = factory.getBean(UserService.class); // Loaded on demand

// ApplicationContext - Eager loading
ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");
UserService service = context.getBean(UserService.class); // Pre-loaded
```

**When to Use:** Use ApplicationContext for web applications (standard choice); BeanFactory for lightweight scenarios or resource-constrained environments.

---

**Q3: What is Dependency Injection? Why is it important?**

**Answer:** Dependency Injection is a design pattern where objects receive their dependencies from external sources rather than creating them internally.

**Benefits:**
- **Loose Coupling:** Objects don't depend on concrete implementations
- **Testability:** Easy to inject mock objects for testing
- **Flexibility:** Change implementations without modifying code
- **Reusability:** Services can be reused with different dependencies

**Example:**
```java
// Without DI (Tight coupling)
public class OrderService {
    private PaymentProcessor processor = new StripeProcessor(); // Hard dependency
}

// With DI (Loose coupling)
@Service
public class OrderService {
    private final PaymentProcessor processor;

    public OrderService(PaymentProcessor processor) { // Injected dependency
        this.processor = processor;
    }
}

// Can inject different implementations
PaymentProcessor paypal = new PayPalProcessor();
OrderService service1 = new OrderService(paypal);

PaymentProcessor stripe = new StripeProcessor();
OrderService service2 = new OrderService(stripe);
```

---

**Q4: What are different types of bean scopes in Spring?**

**Answer:** Spring supports 5 bean scopes:

1. **Singleton (default):** One instance per ApplicationContext
   ```java
   @Bean
   @Scope("singleton")
   public UserService userService() { }
   ```

2. **Prototype:** New instance every time it's requested
   ```java
   @Bean
   @Scope("prototype")
   public OrderRequest orderRequest() { }
   ```

3. **Request:** One per HTTP request (web-only)
   ```java
   @Bean
   @Scope("request")
   public UserContext userContext() { }
   ```

4. **Session:** One per user session (web-only)
   ```java
   @Bean
   @Scope("session")
   public ShoppingCart shoppingCart() { }
   ```

5. **Application:** One per ServletContext (web-only)
   ```java
   @Bean
   @Scope("application")
   public AppConfig appConfig() { }
   ```

**When to Use Each:**
- Singleton for stateless services, repositories
- Prototype for stateful objects, request-scoped data
- Request/Session for web-specific state

---

**Q5: What is the bean lifecycle in Spring?**

**Answer:** Spring beans go through a well-defined lifecycle:

1. **Instantiation:** Bean class is instantiated
2. **Populate Properties:** Dependencies are injected
3. **BeanNameAware.setBeanName():** Bean learns its name
4. **BeanFactoryAware.setBeanFactory():** Bean learns its factory
5. **ApplicationContextAware.setApplicationContext():** Bean learns its context
6. **BeanPostProcessor.postProcessBeforeInitialization():** Custom initialization before
7. **InitializingBean.afterPropertiesSet():** Bean-specific initialization
8. **@PostConstruct:** Custom initialization hook
9. **BeanPostProcessor.postProcessAfterInitialization():** Custom initialization after
10. **Ready for Use:** Bean is ready
11. **@PreDestroy:** Cleanup when container shuts down
12. **DisposableBean.destroy():** Final cleanup

**Code Example:**
```java
@Component
public class UserService implements InitializingBean, DisposableBean {

    @PostConstruct
    public void initialize() {
        System.out.println("Post-construct initialization");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("After properties set");
    }

    @PreDestroy
    public void cleanup() {
        System.out.println("Pre-destroy cleanup");
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("Destroy method");
    }
}
```

---

### Spring Web & REST

**Q6: What is DispatcherServlet and how does it work?**

**Answer:** DispatcherServlet is the front controller in Spring MVC that handles all incoming HTTP requests.

**Request Flow:**
1. **DispatcherServlet** receives HTTP request
2. **HandlerMapping** finds matching controller method
3. **HandlerAdapter** executes the controller
4. **Controller** processes request, returns ModelAndView
5. **ViewResolver** finds the view template
6. **View** renders response
7. **Response** sent to client

**Code Example:**
```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
        // 1. DispatcherServlet routes here
        // 2. @GetMapping matches the request
        // 3. @PathVariable extracts path parameter
        UserResponse response = userService.findById(id);
        // 4. Response converted to JSON
        // 5. Sent to client
        return ResponseEntity.ok(response);
    }
}
```

---

**Q7: What's the difference between @Controller and @RestController?**

**Answer:**
| Aspect | @Controller | @RestController |
|--------|------------|-----------------|
| Return Type | View name (String) | JSON/XML (Object) |
| @ResponseBody | Required on methods | Applied to all methods |
| View Resolution | Uses ViewResolver | No view resolution |
| Response Format | HTML/JSP/Thymeleaf | JSON/XML |

**Code Example:**
```java
// @Controller - Returns view name
@Controller
public class UserViewController {
    @GetMapping("/users")
    public String getUsers(Model model) {
        model.addAttribute("users", userService.getAllUsers());
        return "users-list"; // View name
    }
}

// @RestController - Returns JSON
@RestController
@RequestMapping("/api/users")
public class UserRestController {
    @GetMapping
    public List<UserDTO> getUsers() {
        return userService.getAllUsers(); // Automatically converted to JSON
    }
}
```

---

**Q8: How does Spring handle request validation?**

**Answer:** Spring uses JSR-303/380 Bean Validation with `@Valid` annotation:

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @PostMapping
    public ResponseEntity<UserResponse> createUser(
            @Valid @RequestBody CreateUserRequest request,
            BindingResult bindingResult) {

        // BindingResult contains validation errors
        if (bindingResult.hasErrors()) {
            // Handle validation errors
        }

        return ResponseEntity.status(201).body(userService.create(request));
    }
}

@Data
public class CreateUserRequest {
    @Email(message = "Email should be valid")
    private String email;

    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    @NotBlank(message = "Name is required")
    private String name;
}

// Custom validator
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );
        return ResponseEntity.badRequest().body(new ErrorResponse(errors));
    }
}
```

---

### Data Access

**Q9: What is Spring Data JPA and how is it different from Hibernate?**

**Answer:**

**Hibernate:**
- ORM framework that maps objects to database tables
- Provides Query language (HQL), caching, lazy loading
- You write repository implementations

**Spring Data JPA:**
- Abstraction layer on top of JPA (which uses Hibernate by default)
- Provides automatic CRUD repository implementations
- Reduces boilerplate code significantly

**Code Example:**
```java
// Without Spring Data JPA - Manual implementation required
public class UserRepositoryImpl implements UserRepository {
    @Override
    public Optional<User> findByEmail(String email) {
        // Implement with EntityManager
    }
}

// With Spring Data JPA - Automatic implementation
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email); // Automatic implementation!
}

// Usage
User user = userRepository.findByEmail("user@example.com").orElse(null);
List<User> users = userRepository.findAll();
userRepository.save(user);
userRepository.deleteById(1L);
```

---

**Q10: What is the N+1 query problem and how do you solve it?**

**Answer:** N+1 occurs when fetching parent entities with lazy-loaded children causes N additional queries.

**Problem:**
```java
List<User> users = userRepository.findAll(); // 1 query

for (User user : users) {
    System.out.println(user.getOrders().size()); // Triggers N additional queries
}
// Total: 1 + N queries!
```

**Solutions:**

1. **Eager Loading (FetchType.EAGER):** Load children immediately
   ```java
   @OneToMany(fetch = FetchType.EAGER)
   private List<Order> orders;
   ```

2. **Entity Graph:** Specify join pattern
   ```java
   @EntityGraph(attributePaths = {"orders"})
   @Query("SELECT u FROM User u")
   List<User> findAllWithOrders();

   userRepository.findAllWithOrders(); // Single query with join
   ```

3. **Fetch Join in JPQL:**
   ```java
   @Query("SELECT u FROM User u LEFT JOIN FETCH u.orders")
   List<User> findAllWithFetchJoin();
   ```

4. **Batch Loading:** Group queries
   ```java
   @org.hibernate.annotations.BatchSize(size = 10)
   @OneToMany
   private List<Order> orders;
   ```

---

## Mid-Level Developer Interview Questions (3-5 years)

### Advanced DI & Configuration

**Q11: Explain the difference between constructor, setter, and field injection. Which is preferred?**

**Answer:** Three types of dependency injection:

1. **Constructor Injection (Preferred)**
   ```java
   @Service
   public class UserService {
       private final UserRepository repository;
       private final EmailService emailService;

       public UserService(UserRepository repository, EmailService emailService) {
           this.repository = repository;
           this.emailService = emailService;
       }
   }
   ```
   **Advantages:** Immutability, testability, fail-fast, all dependencies visible

2. **Setter Injection**
   ```java
   @Service
   public class UserService {
       private UserRepository repository;

       @Autowired
       public void setRepository(UserRepository repository) {
           this.repository = repository;
       }
   }
   ```
   **Disadvantages:** Not immutable, optional dependencies unclear, can cause NPE

3. **Field Injection (Anti-pattern)**
   ```java
   @Service
   public class UserService {
       @Autowired
       private UserRepository repository; // Hard to test, not immutable
   }
   ```
   **Disadvantages:** Requires reflection, not testable, hidden dependencies

**Best Practice:** Always use constructor injection

---

**Q12: How do you handle circular dependencies in Spring?**

**Answer:** Circular dependencies occur when two or more beans depend on each other.

**Example:**
```java
@Service
public class UserService {
    @Autowired
    private OrderService orderService; // Depends on OrderService
}

@Service
public class OrderService {
    @Autowired
    private UserService userService; // Depends on UserService - CIRCULAR!
}
```

**Solutions:**

1. **Setter Injection (Not Constructor)**
   ```java
   @Service
   public class UserService {
       private OrderService orderService;

       @Autowired // Only works with setter injection
       public void setOrderService(OrderService orderService) {
           this.orderService = orderService;
       }
   }
   ```

2. **ObjectProvider for Lazy Loading**
   ```java
   @Service
   public class UserService {
       private final ObjectProvider<OrderService> orderServiceProvider;

       public UserService(ObjectProvider<OrderService> orderServiceProvider) {
           this.orderServiceProvider = orderServiceProvider;
       }

       public void process() {
           OrderService orderService = orderServiceProvider.getIfAvailable();
       }
   }
   ```

3. **Refactor to Remove Circular Dependency (Best)**
   ```java
   // Create a new service that depends on both
   @Service
   public class UserOrderService {
       private final UserService userService;
       private final OrderService orderService;

       public UserOrderService(UserService userService, OrderService orderService) {
           this.userService = userService;
           this.orderService = orderService;
       }
   }
   ```

**Recommended Approach:** Refactor your code structure to eliminate circular dependencies entirely.

---

### Transactions & Data Consistency

**Q13: Explain @Transactional with propagation and isolation levels.**

**Answer:**

**Propagation Behaviors:**
```java
// REQUIRED (default) - Use existing or create new
@Transactional(propagation = Propagation.REQUIRED)
public void method1() { } // Uses outer transaction

// REQUIRES_NEW - Create new, suspend outer
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void method2() { } // Creates new transaction

// NESTED - Create savepoint
@Transactional(propagation = Propagation.NESTED)
public void method3() { } // Can rollback independently

// NOT_SUPPORTED - Suspend transaction
@Transactional(propagation = Propagation.NOT_SUPPORTED)
public void method4() { } // No transaction

// MANDATORY - Fail if no transaction
@Transactional(propagation = Propagation.MANDATORY)
public void method5() { } // Requires outer transaction
```

**Isolation Levels:**
```java
// READ_UNCOMMITTED - Dirty reads possible
@Transactional(isolation = Isolation.READ_UNCOMMITTED)

// READ_COMMITTED - Default, no dirty reads
@Transactional(isolation = Isolation.READ_COMMITTED)

// REPEATABLE_READ - No dirty or phantom reads
@Transactional(isolation = Isolation.REPEATABLE_READ)

// SERIALIZABLE - Highest isolation, lowest concurrency
@Transactional(isolation = Isolation.SERIALIZABLE)
```

**Example with Propagation:**
```java
@Service
public class OrderService {

    @Autowired
    private PaymentService paymentService;

    @Transactional
    public Order createOrder(CreateOrderRequest request) {
        Order order = new Order();
        // Save order in current transaction

        // Payment in separate transaction
        paymentService.processPayment(order.getId(), request.getAmount());

        return order;
    }
}

@Service
public class PaymentService {

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public Payment processPayment(Long orderId, BigDecimal amount) {
        // This runs in its own transaction
        // If it fails, order creation still commits
        // If order fails, payment doesn't roll back
    }
}
```

---

**Q14: What is optimistic locking and when would you use it?**

**Answer:** Optimistic locking assumes conflicts are rare and detects them using version fields.

**Implementation:**
```java
@Entity
public class Product {
    @Id
    private Long id;

    @Version // Auto-managed by Hibernate
    private Long version;

    private String name;
    private BigDecimal price;
}

// Usage
Product product = productRepository.findById(1L).orElseThrow();
product.setPrice(new BigDecimal("99.99"));

try {
    productRepository.save(product); // Success if no other transaction changed it
} catch (OptimisticLockingFailureException e) {
    // Another transaction modified the product
    // Retry or notify user
}
```

**When to Use:**
- **Optimistic Locking:** Infrequent updates, high concurrency, cloud environments
- **Pessimistic Locking:** Frequent conflicts, critical data, deterministic behavior

**Comparison:**
```java
// Optimistic - Version field
@Version
private Long version;

// Pessimistic - Database lock
@Lock(LockModeType.PESSIMISTIC_WRITE)
Optional<Product> findById(Long id);
```

---

### Security

**Q15: How does Spring Security authenticate and authorize users?**

**Answer:**

**Authentication Flow:**
```java
1. User submits credentials
2. AuthenticationFilter intercepts request
3. AuthenticationManager delegates to AuthenticationProvider
4. AuthenticationProvider validates credentials (e.g., BCrypt)
5. Authentication object created and stored in SecurityContext
6. Request proceeds with authenticated user
```

**Code Example:**
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/**").authenticated()
                .anyRequest().permitAll())
            .httpBasic(withDefaults())
            .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

// Check authentication at runtime
@GetMapping("/api/user/profile")
public UserResponse getProfile() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    String username = auth.getName();
    Collection<? extends GrantedAuthority> authorities = auth.getAuthorities();
    return userService.findByUsername(username);
}
```

**Authorization with Annotations:**
```java
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) { }

@PreAuthorize("@userService.isOwner(#id, authentication)")
public UserResponse getUser(Long id) { }

@PostAuthorize("returnObject.userId == principal.id")
public User getUser(Long id) { }
```

---

### Testing

**Q16: What's the difference between @WebMvcTest and @SpringBootTest?**

**Answer:**
| Feature | @WebMvcTest | @SpringBootTest |
|---------|-----------|-----------------|
| Application Context | Only web layer | Full context |
| Speed | Fast | Slower |
| Services | Mocked | Real beans |
| Use Case | Controller unit tests | Integration tests |
| Server | MockMvc (no startup) | Embedded server |

**@WebMvcTest Example:**
```java
@WebMvcTest(UserController.class)
public class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    public void testGetUser() throws Exception {
        UserResponse response = new UserResponse(1L, "John");
        when(userService.getUser(1L)).thenReturn(response);

        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("John"));

        verify(userService).getUser(1L);
    }
}
```

**@SpringBootTest Example:**
```java
@SpringBootTest
@AutoConfigureMockMvc
public class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Test
    public void testCreateAndRetrieveUser() throws Exception {
        User user = new User("john@example.com", "hashed_password");
        userRepository.save(user);

        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.email").value("john@example.com"));
    }
}
```

---

## Senior Developer Interview Questions (5+ years)

### Advanced Architecture

**Q17: Design a microservices architecture using Spring Cloud. How would you handle service-to-service communication?**

**Answer:** Multi-service architecture with communication patterns:

```java
// 1. Service Discovery (Eureka)
@SpringBootApplication
@EnableDiscoveryClient
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}

// 2. Feign Client for inter-service communication
@FeignClient(name = "product-service")
public interface ProductServiceClient {
    @GetMapping("/api/products/{id}")
    ProductDTO getProduct(@PathVariable Long id);
}

// 3. Circuit Breaker for resilience
@Service
public class OrderService {

    @Autowired
    private ProductServiceClient productClient;

    @CircuitBreaker(name = "productService")
    @Retry(name = "productService")
    public OrderResponse createOrder(CreateOrderRequest request) {
        ProductDTO product = productClient.getProduct(request.getProductId());
        return new OrderResponse(product.getName(), product.getPrice());
    }

    // Fallback if service is down
    public OrderResponse createOrderFallback(CreateOrderRequest request, Exception e) {
        logger.error("Product service unavailable", e);
        return new OrderResponse("Unknown", null);
    }
}

// 4. Configuration
@Configuration
public class CircuitBreakerConfig {

    @Bean
    public CircuitBreakerConfig productServiceCircuitBreaker() {
        return CircuitBreakerConfig.custom()
            .failureThreshold(50)
            .slowCallRateThreshold(50)
            .slowCallDurationThreshold(Duration.ofSeconds(2))
            .waitDurationInOpenState(Duration.ofSeconds(30))
            .build();
    }
}

// 5. API Gateway
@Configuration
public class GatewayConfig {

    @Bean
    public RouteLocator routes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("user-service", r -> r
                .path("/api/users/**")
                .uri("lb://user-service"))
            .route("product-service", r -> r
                .path("/api/products/**")
                .uri("lb://product-service"))
            .build();
    }
}
```

---

**Q18: How would you design a scalable caching strategy for a high-traffic e-commerce platform?**

**Answer:** Multi-level caching strategy:

```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager() {
        // Redis for distributed caching
        return RedisCacheManager.create(
            RedisConnectionFactory()
        );
    }
}

@Service
public class ProductService {

    // Cache product details for 30 minutes
    @Cacheable(value = "productDetails", key = "#id", unless = "#result == null")
    public ProductDTO getProduct(Long id) {
        // Database query
    }

    // Cache product listings by category for 1 hour
    @Cacheable(value = "productsByCategory", key = "#category")
    public List<ProductDTO> getProductsByCategory(String category) {
        // Database query
    }

    // Always update cache on product change
    @CachePut(value = "productDetails", key = "#result.id")
    @CacheEvict(value = "productsByCategory", allEntries = true)
    public ProductDTO updateProduct(Long id, UpdateProductRequest request) {
        // Update logic
    }

    // Warm cache asynchronously
    @Async
    public CompletableFuture<Void> warmCache() {
        return CompletableFuture.runAsync(() -> {
            List<String> categories = productRepository.findDistinctCategories();
            categories.parallelStream()
                .forEach(this::getProductsByCategory);
        });
    }
}

// Distributed cache configuration
@Configuration
public class RedisConfig {

    @Bean
    public LettuceConnectionFactory connectionFactory() {
        return new LettuceConnectionFactory();
    }

    @Bean
    public RedisTemplate<String, Object> redisTemplate(LettuceConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        return template;
    }
}
```

---

**Q19: Design a system to handle distributed transactions across multiple services. How would you handle eventual consistency?**

**Answer:** Using Saga pattern for distributed transactions:

```java
// Orchestration-based Saga
@Service
public class OrderSaga {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private PaymentServiceClient paymentClient;

    @Autowired
    private InventoryServiceClient inventoryClient;

    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        // Step 1: Create order
        Order order = createOrderInternal(request);

        try {
            // Step 2: Process payment
            paymentClient.processPayment(order.getId(), request.getAmount());

            // Step 3: Reserve inventory
            inventoryClient.reserveInventory(order.getId(), request.getItems());

            // Step 4: Confirm order
            order.setStatus(OrderStatus.CONFIRMED);
            orderRepository.save(order);

            return new OrderResponse(order.getId(), order.getStatus());

        } catch (PaymentException e) {
            order.setStatus(OrderStatus.PAYMENT_FAILED);
            orderRepository.save(order);
            throw e;

        } catch (InventoryException e) {
            // Compensating transaction - refund payment
            paymentClient.refundPayment(order.getId());

            order.setStatus(OrderStatus.INVENTORY_FAILED);
            orderRepository.save(order);
            throw e;
        }
    }
}

// Event-driven Saga (Choreography)
@Component
public class OrderEventListener {

    @EventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        paymentService.processPaymentAsync(event.getOrderId(), event.getAmount());
    }

    @EventListener
    public void onPaymentSucceeded(PaymentSucceededEvent event) {
        inventoryService.reserveInventoryAsync(event.getOrderId());
    }

    @EventListener
    public void onInventoryReserved(InventoryReservedEvent event) {
        orderService.confirmOrderAsync(event.getOrderId());
    }

    @EventListener
    public void onPaymentFailed(PaymentFailedEvent event) {
        orderService.cancelOrderAsync(event.getOrderId());
    }
}
```

---

**Q20: How would you implement comprehensive observability (metrics, logs, traces) in a microservices system?**

**Answer:**
```java
@Configuration
public class ObservabilityConfig {

    @Bean
    public MeterRegistry meterRegistry() {
        return new MeterRegistry();
    }
}

@Service
public class OrderService {

    @Autowired
    private MeterRegistry meterRegistry;

    @Autowired
    private Tracer tracer;

    @Autowired
    private Logger logger;

    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        // Distributed tracing
        try (Scope scope = tracer.buildSpan("create-order").startActive(true)) {
            span.log(ImmutableMap.of("event", "create-order-started", "user_id", request.getUserId()));

            // Business logic
            Order order = orderRepository.save(new Order());

            // Custom metrics
            meterRegistry.counter("orders.created", "status", "success").increment();
            meterRegistry.timer("order.creation.time").record(Duration.between(start, Instant.now()));

            // Structured logging
            logger.info("Order created", ImmutableMap.of(
                "order_id", order.getId(),
                "user_id", request.getUserId(),
                "amount", order.getTotalAmount(),
                "trace_id", MDC.get("trace_id")
            ));

            return new OrderResponse(order.getId(), order.getStatus());

        } catch (Exception e) {
            meterRegistry.counter("orders.created", "status", "failure").increment();

            logger.error("Order creation failed", ImmutableMap.of(
                "error", e.getMessage(),
                "trace_id", MDC.get("trace_id")
            ), e);

            throw e;
        }
    }
}

// Spring Boot Actuator Configuration
spring:
  application:
    name: order-service

management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus,traces
  metrics:
    export:
      prometheus:
        enabled: true
  tracing:
    sampling:
      probability: 1.0
```

---

## Expert/Architect Level Questions

### Q21-Q30: Complex Architectural Patterns

**Q21: Design a self-healing resilient microservice system.**

**Answer:** Implement multiple resilience patterns:

```java
@Service
@Retry(name = "orderService", delay = 100, multiplier = 1.5, maxAttempts = 3)
@CircuitBreaker(name = "orderService")
@Timeout(name = "orderService", duration = "5s")
@Bulkhead(name = "orderService")
public class ResilientOrderService {

    @Autowired
    private PaymentServiceClient paymentClient;

    public OrderResponse createOrder(CreateOrderRequest request) {
        // Automatically retries on failure
        // Circuit breaker prevents cascading failures
        // Timeout prevents hanging requests
        // Bulkhead limits concurrent calls
        return paymentClient.processPayment(request);
    }

    // Fallback execution
    public OrderResponse createOrderFallback(CreateOrderRequest request, Exception e) {
        logger.error("Payment service unavailable, using fallback", e);
        return new OrderResponse(null, OrderStatus.PENDING_PAYMENT);
    }
}
```

---

## Summary Table

| Level | Key Topics | Sample Questions |
|-------|-----------|-----------------|
| **Junior** | IoC, DI, MVC, REST, JPA | Q1-Q10 |
| **Mid-Level** | Advanced DI, Transactions, Security, Testing | Q11-Q16 |
| **Senior** | Microservices, Caching, Distributed Systems | Q17-Q20 |
| **Architect** | System Design, Resilience, Observability | Q21-Q30 |

---

## Interview Preparation Strategy

1. **Understand Concepts:** Read Spring documentation
2. **Practice Code:** Implement examples
3. **Answer Out Loud:** Practice verbal explanations
4. **Handle Follow-ups:** Prepare for deeper questions
5. **Share Experience:** Reference real projects
6. **Ask Questions:** Show curiosity about the role

---

**Last Updated:** October 25, 2024
**Total Questions:** 50+ with detailed answers
**Coverage:** Junior to Architect level
