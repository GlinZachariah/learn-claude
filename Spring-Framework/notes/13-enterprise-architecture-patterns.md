# Enterprise Architecture Patterns in Spring Framework

## Table of Contents
1. [Layered Architecture](#layered-architecture)
2. [Hexagonal Architecture (Ports & Adapters)](#hexagonal-architecture)
3. [Microservices Architecture](#microservices-architecture)
4. [API Gateway Pattern](#api-gateway-pattern)
5. [Domain-Driven Design (DDD)](#domain-driven-design)
6. [CQRS Pattern](#cqrs-pattern)
7. [Event Sourcing](#event-sourcing)
8. [Saga Pattern for Distributed Transactions](#saga-pattern)
9. [Circuit Breaker Pattern](#circuit-breaker-pattern)
10. [Service Discovery](#service-discovery)
11. [Configuration Management](#configuration-management)
12. [Database Patterns](#database-patterns)
13. [Caching Architecture](#caching-architecture)
14. [Security Architecture](#security-architecture)
15. [Monitoring & Observability](#monitoring--observability)
16. [API Versioning](#api-versioning)

---

## 1. Layered Architecture

The traditional three-tier architecture remains foundational for many Spring applications.

### Classic Layers Structure

```java
// Presentation Layer - REST Controllers
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping
    public ResponseEntity<UserDTO> createUser(@RequestBody CreateUserRequest request) {
        User user = userService.createUser(request.getName(), request.getEmail());
        return ResponseEntity.ok(mapToDTO(user));
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable String id) {
        return userService.getUserById(id)
            .map(this::mapToDTO)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}

// Business Logic Layer - Service
@Service
@Transactional
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmailNotificationService emailService;

    public User createUser(String name, String email) {
        // Validate business rules
        if (userRepository.existsByEmail(email)) {
            throw new UserAlreadyExistsException("Email already registered");
        }

        User user = new User(name, email);
        user = userRepository.save(user);

        // Send welcome email
        emailService.sendWelcomeEmail(user);

        return user;
    }

    public Optional<User> getUserById(String id) {
        return userRepository.findById(id);
    }
}

// Data Access Layer - Repository
@Repository
public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByStatus(UserStatus status);
}

// Domain Model Layer
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    private String id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Enumerated(EnumType.STRING)
    private UserStatus status;

    @CreationTimestamp
    private LocalDateTime createdAt;
}
```

### Cross-Cutting Concerns

```java
// Aspect for logging and monitoring
@Aspect
@Component
public class PerformanceAspect {

    private static final Logger logger = LoggerFactory.getLogger(PerformanceAspect.class);

    @Around("execution(* com.example.service.*.*(..))")
    public Object logExecutionTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();

        try {
            Object result = joinPoint.proceed();
            long endTime = System.currentTimeMillis();
            long executionTime = endTime - startTime;

            logger.info("Method {} executed in {} ms",
                joinPoint.getSignature().getName(), executionTime);

            return result;
        } catch (Exception e) {
            logger.error("Method {} threw exception: {}",
                joinPoint.getSignature().getName(), e.getMessage());
            throw e;
        }
    }
}

// Exception handling at application level
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(UserAlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleUserExists(UserAlreadyExistsException e) {
        ErrorResponse error = new ErrorResponse("USER_ALREADY_EXISTS", e.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception e) {
        ErrorResponse error = new ErrorResponse("INTERNAL_SERVER_ERROR",
            "An unexpected error occurred");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
```

---

## 2. Hexagonal Architecture (Ports & Adapters)

Isolate business logic from external dependencies.

### Core Domain with Ports

```java
// Domain Port - Interface
public interface UserRepository {
    User save(User user);
    Optional<User> findById(String id);
    List<User> findAll();
}

public interface EmailNotificationPort {
    void sendWelcomeEmail(User user);
}

// Domain Service - Business Logic (Technology-Independent)
@Service
public class UserDomainService {

    private UserRepository userRepository;
    private EmailNotificationPort emailPort;

    public UserDomainService(UserRepository userRepository,
                            EmailNotificationPort emailPort) {
        this.userRepository = userRepository;
        this.emailPort = emailPort;
    }

    // Pure business logic - no Spring annotations needed
    public void registerUser(String name, String email) {
        // Business rules
        if (name == null || name.trim().isEmpty()) {
            throw new InvalidUserException("Name cannot be empty");
        }

        if (!email.contains("@")) {
            throw new InvalidUserException("Invalid email format");
        }

        User user = new User(UUID.randomUUID().toString(), name, email);
        userRepository.save(user);
        emailPort.sendWelcomeEmail(user);
    }
}

// Adapter - Database Implementation
@Repository
public class JpaUserRepository implements UserRepository {

    @Autowired
    private UserJpaRepository jpaRepository;

    @Override
    public User save(User user) {
        UserEntity entity = mapToEntity(user);
        UserEntity saved = jpaRepository.save(entity);
        return mapToDomain(saved);
    }

    @Override
    public Optional<User> findById(String id) {
        return jpaRepository.findById(id).map(this::mapToDomain);
    }

    private UserEntity mapToEntity(User user) {
        return new UserEntity(user.getId(), user.getName(), user.getEmail());
    }

    private User mapToDomain(UserEntity entity) {
        return new User(entity.getId(), entity.getName(), entity.getEmail());
    }
}

// Adapter - Email Implementation
@Service
public class EmailNotificationAdapter implements EmailNotificationPort {

    @Autowired
    private JavaMailSender mailSender;

    @Override
    public void sendWelcomeEmail(User user) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(user.getEmail());
        message.setSubject("Welcome to Our Platform!");
        message.setText("Hello " + user.getName() + ", welcome aboard!");
        mailSender.send(message);
    }
}

// REST Controller - Adapter for HTTP
@RestController
@RequestMapping("/api/v1/users")
public class UserHttpAdapter {

    @Autowired
    private UserDomainService userDomainService;

    @PostMapping
    public ResponseEntity<UserResponse> registerUser(@RequestBody RegisterUserRequest request) {
        try {
            userDomainService.registerUser(request.getName(), request.getEmail());
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(new UserResponse("User registered successfully"));
        } catch (InvalidUserException e) {
            return ResponseEntity.badRequest()
                .body(new UserResponse(e.getMessage()));
        }
    }
}
```

---

## 3. Microservices Architecture

Breaking monoliths into independently deployable services.

### Service Structure

```java
// User Service (Independent Microservice)
@SpringBootApplication
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}

// Service Configuration
@Configuration
public class UserServiceConfig {

    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder
            .setConnectTimeout(Duration.ofSeconds(5))
            .setReadTimeout(Duration.ofSeconds(10))
            .build();
    }

    @Bean
    public WebClient webClient() {
        return WebClient.builder()
            .baseUrl("http://localhost:8081")
            .build();
    }
}

// Service with Inter-Service Communication
@Service
@Transactional
public class UserEnrollmentService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private WebClient webClient;

    // Synchronous call to Course Service
    public UserEnrollment enrollUserInCourse(String userId, String courseId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException("User not found"));

        // Call Course Service
        CourseDTO course = restTemplate.getForObject(
            "http://course-service/api/v1/courses/{courseId}",
            CourseDTO.class,
            courseId
        );

        if (course == null) {
            throw new CourseNotFoundException("Course not found");
        }

        UserEnrollment enrollment = new UserEnrollment(user, course);
        return userRepository.saveEnrollment(enrollment);
    }

    // Asynchronous call using WebClient (Non-blocking)
    public Mono<UserEnrollment> enrollUserAsync(String userId, String courseId) {
        return webClient.get()
            .uri("/api/v1/courses/{courseId}", courseId)
            .retrieve()
            .bodyToMono(CourseDTO.class)
            .flatMap(course -> {
                User user = userRepository.findById(userId)
                    .orElseThrow(() -> new UserNotFoundException("User not found"));
                UserEnrollment enrollment = new UserEnrollment(user, course);
                return Mono.just(userRepository.saveEnrollment(enrollment));
            });
    }
}

// Circuit Breaker Pattern
@Service
public class ResilientUserService {

    @Autowired
    private RestTemplate restTemplate;

    @CircuitBreaker(name = "courseService",
                   fallbackMethod = "courseServiceFallback")
    public CourseDTO getCourseInfo(String courseId) {
        return restTemplate.getForObject(
            "http://course-service/api/v1/courses/{courseId}",
            CourseDTO.class,
            courseId
        );
    }

    // Fallback when service is down
    public CourseDTO courseServiceFallback(String courseId, Exception e) {
        logger.warn("Course service unavailable, returning cached data");
        return CourseDTO.defaultCourse(); // Return cached or default data
    }
}
```

### Service Discovery Configuration

```yaml
# application.yml for User Service
spring:
  application:
    name: user-service
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        enabled: true
        register: true
        deregister-on-shutdown: true
        instance-id: ${spring.application.name}:${server.port}
        tags:
          - version=1.0
          - env=production

server:
  port: 8080
  servlet:
    context-path: /user-service
```

---

## 4. API Gateway Pattern

Central entry point for all client requests.

```java
// API Gateway Configuration
@SpringBootApplication
public class GatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(GatewayApplication.class, args);
    }
}

@Configuration
public class GatewayConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
            // Route to User Service
            .route("userService",
                r -> r.path("/api/v1/users/**")
                    .uri("http://user-service:8080"))

            // Route to Course Service with rate limiting
            .route("courseService",
                r -> r.path("/api/v1/courses/**")
                    .filters(f -> f.requestRateLimiter()
                        .configure(c -> c.setKeyResolver(pathKeyResolver())))
                    .uri("http://course-service:8081"))

            // Route with authentication
            .route("orderService",
                r -> r.path("/api/v1/orders/**")
                    .filters(f -> f.filter(authenticationFilter()))
                    .uri("http://order-service:8082"))

            .build();
    }

    @Bean
    public KeyResolver pathKeyResolver() {
        return exchange -> Mono.just(
            exchange.getRequest().getPath().toString()
        );
    }

    @Bean
    public GatewayFilter authenticationFilter() {
        return (exchange, chain) -> {
            String token = exchange.getRequest().getHeaders().getFirst("Authorization");

            if (token == null || token.isEmpty()) {
                exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                return exchange.getResponse().setComplete();
            }

            return chain.filter(exchange);
        };
    }
}
```

---

## 5. Domain-Driven Design (DDD)

Aligning code structure with business domains.

### Aggregate and Aggregate Root

```java
// Aggregate Root - Order
@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order extends AggregateRoot {

    @Id
    private String orderId;

    @Embedded
    private OrderId order;

    @Embedded
    private CustomerId customerId;

    @ElementCollection
    @CollectionTable(name = "order_items")
    private List<OrderItem> items;

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    @Embedded
    private Money totalAmount;

    @CreationTimestamp
    private LocalDateTime createdAt;

    // Business Logic Methods (Ubiquitous Language)
    public void addItem(OrderItem item) {
        if (status != OrderStatus.DRAFT) {
            throw new OrderException("Cannot add items to finalized order");
        }
        items.add(item);
        recalculateTotal();
    }

    public void placeOrder() {
        if (items.isEmpty()) {
            throw new OrderException("Order must have at least one item");
        }
        status = OrderStatus.PLACED;
        registerEvent(new OrderPlacedEvent(orderId, customerId, totalAmount));
    }

    private void recalculateTotal() {
        totalAmount = items.stream()
            .map(item -> item.getPrice().multiply(item.getQuantity()))
            .reduce(Money.ZERO, Money::add);
    }
}

// Value Object
@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderId {
    @Column(name = "order_id")
    private String value;

    // Encapsulates Order ID logic
    public static OrderId generate() {
        return new OrderId(UUID.randomUUID().toString());
    }

    public boolean isValid() {
        return value != null && !value.isEmpty();
    }
}

// Repository (Domain Interface)
public interface OrderRepository {
    Order findById(OrderId orderId);
    void save(Order order);
    void delete(OrderId orderId);
    List<Order> findByCustomer(CustomerId customerId);
}

// Application Service (Domain Service)
@Service
@Transactional
public class PlaceOrderUseCase {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private PaymentService paymentService;

    public void execute(PlaceOrderCommand command) {
        Order order = orderRepository.findById(command.getOrderId());

        if (order == null) {
            throw new OrderNotFoundException("Order not found");
        }

        // Business logic
        order.placeOrder();

        // Process payment
        PaymentResult result = paymentService.processPayment(
            order.getCustomerId(),
            order.getTotalAmount()
        );

        if (!result.isSuccessful()) {
            throw new PaymentFailedException("Payment declined");
        }

        orderRepository.save(order);
    }
}
```

### Domain Events

```java
// Domain Event
@Data
@AllArgsConstructor
public class OrderPlacedEvent implements DomainEvent {
    private String orderId;
    private CustomerId customerId;
    private Money totalAmount;
    private LocalDateTime occurredAt = LocalDateTime.now();
}

// Event Handler
@Component
public class OrderPlacedEventHandler implements ApplicationEventPublisher {

    @Autowired
    private EmailNotificationService emailService;

    @EventListener
    @Async
    public void onOrderPlaced(OrderPlacedEvent event) {
        // Send confirmation email
        emailService.sendOrderConfirmation(event.getCustomerId(), event.getOrderId());

        // Update analytics
        logger.info("Order placed: {} by customer: {}",
            event.getOrderId(), event.getCustomerId());
    }
}

// Event Publishing
@Service
public class OrderService {

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    public void processOrder(Order order) {
        // Process order...

        // Publish domain event
        eventPublisher.publishEvent(new OrderPlacedEvent(
            order.getId(),
            order.getCustomerId(),
            order.getTotalAmount()
        ));
    }
}
```

---

## 6. CQRS Pattern

Separate read and write models for scalability.

```java
// Command - Write Model
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateOrderCommand {
    private String customerId;
    private List<OrderItemDTO> items;
    private String shippingAddress;
}

@Service
public class OrderCommandService {

    @Autowired
    private OrderRepository writeRepository;

    @Autowired
    private EventStore eventStore;

    @Transactional
    public String handle(CreateOrderCommand command) {
        Order order = new Order(
            OrderId.generate(),
            CustomerId.of(command.getCustomerId()),
            command.getItems(),
            command.getShippingAddress()
        );

        order.placeOrder();
        writeRepository.save(order);

        // Store events for event sourcing
        eventStore.saveEvents(order.getDomainEvents());

        return order.getId().toString();
    }
}

// Query - Read Model
@Data
@NoArgsConstructor
public class OrderReadModel {
    private String orderId;
    private String customerId;
    private List<OrderItemDTO> items;
    private OrderStatus status;
    private Money totalAmount;
    private LocalDateTime createdAt;
}

@Repository
public interface OrderReadModelRepository extends JpaRepository<OrderReadModel, String> {
    List<OrderReadModel> findByCustomerId(String customerId);
    List<OrderReadModel> findByStatus(OrderStatus status);
}

// Query Service - Read Only
@Service
public class OrderQueryService {

    @Autowired
    private OrderReadModelRepository readRepository;

    public OrderReadModel findById(String orderId) {
        return readRepository.findById(orderId).orElse(null);
    }

    public List<OrderReadModel> findCustomerOrders(String customerId) {
        return readRepository.findByCustomerId(customerId);
    }

    public List<OrderReadModel> findOrdersByStatus(OrderStatus status) {
        return readRepository.findByStatus(status);
    }
}

// Controller separating commands and queries
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {

    @Autowired
    private OrderCommandService commandService;

    @Autowired
    private OrderQueryService queryService;

    // Write operation
    @PostMapping
    public ResponseEntity<String> createOrder(@RequestBody CreateOrderCommand command) {
        String orderId = commandService.handle(command);
        return ResponseEntity.status(HttpStatus.CREATED).body(orderId);
    }

    // Read operation
    @GetMapping("/{orderId}")
    public ResponseEntity<OrderReadModel> getOrder(@PathVariable String orderId) {
        OrderReadModel order = queryService.findById(orderId);
        return order != null ? ResponseEntity.ok(order) :
                               ResponseEntity.notFound().build();
    }

    // Read operation
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<OrderReadModel>> getCustomerOrders(
            @PathVariable String customerId) {
        return ResponseEntity.ok(queryService.findCustomerOrders(customerId));
    }
}
```

---

## 7. Event Sourcing

Storing state changes as a sequence of events.

```java
// Event Sourcing Implementation
@Service
public class EventSourcingService {

    @Autowired
    private EventStore eventStore;

    @Autowired
    private OrderRepository repository;

    // Reconstruct Order from events
    public Order reconstructOrder(String orderId) {
        List<DomainEvent> events = eventStore.getEventsForAggregate(orderId);

        Order order = new Order();

        for (DomainEvent event : events) {
            if (event instanceof OrderCreatedEvent) {
                OrderCreatedEvent e = (OrderCreatedEvent) event;
                order.initialize(e.getOrderId(), e.getCustomerId());
            }
            else if (event instanceof OrderItemAddedEvent) {
                OrderItemAddedEvent e = (OrderItemAddedEvent) event;
                order.addItem(e.getItem());
            }
            else if (event instanceof OrderPlacedEvent) {
                order.placeOrder();
            }
            else if (event instanceof OrderShippedEvent) {
                order.ship();
            }
        }

        return order;
    }

    // Store new events
    public void saveEvents(String aggregateId, List<DomainEvent> events) {
        eventStore.append(aggregateId, events);
    }
}

// Event Store Implementation
@Component
public class PostgresEventStore implements EventStore {

    @Autowired
    private EventStoreRepository repository;

    @Override
    public void append(String aggregateId, List<DomainEvent> events) {
        events.forEach(event -> {
            EventDocument doc = new EventDocument(
                UUID.randomUUID().toString(),
                aggregateId,
                event.getClass().getSimpleName(),
                serializeEvent(event),
                LocalDateTime.now()
            );
            repository.save(doc);
        });
    }

    @Override
    public List<DomainEvent> getEventsForAggregate(String aggregateId) {
        return repository.findByAggregateId(aggregateId)
            .stream()
            .map(doc -> deserializeEvent(doc.getEventData()))
            .collect(Collectors.toList());
    }

    private String serializeEvent(DomainEvent event) {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.writeValueAsString(event);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    private DomainEvent deserializeEvent(String eventData) {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.readValue(eventData, DomainEvent.class);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }
}

// Audit and Temporal Queries
@Service
public class OrderAuditService {

    @Autowired
    private EventStore eventStore;

    public List<AuditLog> getOrderAuditTrail(String orderId) {
        return eventStore.getEventsForAggregate(orderId)
            .stream()
            .map(event -> new AuditLog(
                event.getOccurredAt(),
                event.getClass().getSimpleName(),
                event.toString()
            ))
            .collect(Collectors.toList());
    }

    // Temporal query - state at specific point in time
    public Order getOrderState(String orderId, LocalDateTime asOfTime) {
        List<DomainEvent> events = eventStore.getEventsForAggregate(orderId)
            .stream()
            .filter(e -> e.getOccurredAt().isBefore(asOfTime))
            .collect(Collectors.toList());

        return reconstructFromEvents(events);
    }
}
```

---

## 8. Saga Pattern for Distributed Transactions

Managing distributed transactions across microservices.

```java
// Choreography-based Saga (Event-driven)
@Service
public class OrderSagaChoreography {

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @Autowired
    private OrderRepository orderRepository;

    // Step 1: Create Order
    public void createOrder(CreateOrderCommand command) {
        Order order = new Order(command);
        orderRepository.save(order);

        // Publish event for next step
        eventPublisher.publishEvent(new OrderCreatedEvent(order.getId()));
    }

    // Step 2: Reserve Inventory (listens to OrderCreatedEvent)
    @EventListener
    public void reserveInventory(OrderCreatedEvent event) {
        try {
            // Call Inventory Service
            inventoryService.reserve(event.getOrderId());

            // Publish success event
            eventPublisher.publishEvent(
                new InventoryReservedEvent(event.getOrderId())
            );
        } catch (InsufficientInventoryException e) {
            // Publish failure event
            eventPublisher.publishEvent(
                new InventoryReservationFailedEvent(event.getOrderId())
            );
        }
    }

    // Step 3: Process Payment (listens to InventoryReservedEvent)
    @EventListener
    public void processPayment(InventoryReservedEvent event) {
        try {
            // Call Payment Service
            paymentService.processPayment(event.getOrderId());

            // Publish success event
            eventPublisher.publishEvent(
                new PaymentProcessedEvent(event.getOrderId())
            );
        } catch (PaymentFailedException e) {
            // Publish failure event - triggers compensating transactions
            eventPublisher.publishEvent(
                new PaymentFailedEvent(event.getOrderId())
            );
        }
    }

    // Compensating Transaction: Rollback on payment failure
    @EventListener
    public void compensateOnPaymentFailure(PaymentFailedEvent event) {
        // Release reserved inventory
        inventoryService.release(event.getOrderId());

        // Update order status
        Order order = orderRepository.findById(event.getOrderId());
        order.setStatus(OrderStatus.CANCELLED);
        orderRepository.save(order);
    }
}

// Orchestration-based Saga (Centralized)
@Service
public class OrderSagaOrchestrator {

    @Autowired
    private OrderService orderService;

    @Autowired
    private InventoryService inventoryService;

    @Autowired
    private PaymentService paymentService;

    @Transactional
    public void executeOrderSaga(CreateOrderCommand command) {
        String orderId = null;

        try {
            // Step 1: Create Order
            Order order = orderService.createOrder(command);
            orderId = order.getId();

            // Step 2: Reserve Inventory
            inventoryService.reserve(orderId, command.getItems());

            // Step 3: Process Payment
            paymentService.processPayment(orderId, order.getTotalAmount());

            // Step 4: Confirm Order
            orderService.confirmOrder(orderId);

        } catch (InventoryUnavailableException e) {
            if (orderId != null) {
                orderService.cancelOrder(orderId);
            }
            throw new OrderProcessingException("Inventory unavailable", e);

        } catch (PaymentFailedException e) {
            if (orderId != null) {
                inventoryService.release(orderId);
                orderService.cancelOrder(orderId);
            }
            throw new OrderProcessingException("Payment failed", e);
        }
    }
}
```

---

## 9. Circuit Breaker Pattern

Preventing cascading failures in distributed systems.

```java
// Resilience4j Configuration
@Configuration
public class CircuitBreakerConfig {

    @Bean
    public CircuitBreakerRegistry circuitBreakerRegistry() {
        CircuitBreakerConfig config = CircuitBreakerConfig.custom()
            .failureThreshold(50)  // 50% failure rate triggers open
            .waitDurationInOpenState(Duration.ofSeconds(30))
            .permittedNumberOfCallsInHalfOpenState(3)
            .recordExceptions(HttpServerErrorException.class,
                             TimeoutException.class)
            .ignoreExceptions(IllegalArgumentException.class)
            .build();

        return CircuitBreakerRegistry.of(config);
    }
}

// Service with Circuit Breaker
@Service
public class PaymentServiceClient {

    @Autowired
    private RestTemplate restTemplate;

    private CircuitBreaker circuitBreaker;

    @PostConstruct
    public void init() {
        CircuitBreakerRegistry registry = CircuitBreakerRegistry.getInstance();
        this.circuitBreaker = registry.circuitBreaker("paymentService");
    }

    public PaymentResponse processPayment(String orderId, Money amount) {
        return circuitBreaker.executeSupplier(() ->
            attemptPayment(orderId, amount)
        );
    }

    private PaymentResponse attemptPayment(String orderId, Money amount) {
        try {
            return restTemplate.postForObject(
                "http://payment-service/api/payments",
                new PaymentRequest(orderId, amount),
                PaymentResponse.class
            );
        } catch (RestClientException e) {
            throw new PaymentServiceException("Payment service unavailable", e);
        }
    }
}

// With Retry and Fallback
@Service
public class ResilientPaymentService {

    @Retry(name = "paymentRetry",
           fallbackMethod = "paymentFallback")
    @CircuitBreaker(name = "paymentCircuitBreaker",
                   fallbackMethod = "paymentFallback")
    public PaymentResponse processPayment(PaymentRequest request) {
        return restTemplate.postForObject(
            "http://payment-service/api/payments",
            request,
            PaymentResponse.class
        );
    }

    public PaymentResponse paymentFallback(PaymentRequest request, Exception e) {
        logger.warn("Payment service unavailable, using fallback: {}", e.getMessage());

        // Return pending payment - retry later
        return new PaymentResponse(
            request.getOrderId(),
            PaymentStatus.PENDING,
            "Payment processing delayed. Will be retried."
        );
    }
}

// Monitoring Circuit Breaker State
@Component
public class CircuitBreakerMonitoring {

    @Autowired
    private CircuitBreakerRegistry registry;

    @Scheduled(fixedRate = 5000)
    public void monitorCircuitBreakers() {
        registry.getAllCircuitBreakers().forEach(cb -> {
            CircuitBreaker.State state = cb.getState();
            logger.info("Circuit Breaker: {}, State: {}", cb.getName(), state);

            if (state == CircuitBreaker.State.OPEN) {
                // Alert operations
                sendAlert("Circuit breaker " + cb.getName() + " is OPEN");
            }
        });
    }
}
```

---

## 10. Service Discovery

Dynamic service registration and discovery.

```yaml
# Consul Service Registration
spring:
  application:
    name: order-service
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        enabled: true
        register: true
        instance-id: ${spring.application.name}-${server.port}
        service-name: ${spring.application.name}
        healthCheckInterval: 10s
        healthCheckPath: /actuator/health
        tags:
          - version=1.0
          - environment=production
          - team=backend

server:
  port: 8082
```

```java
// Ribbon Load Balancing
@Configuration
@RibbonClient(name = "payment-service")
public class RibbonConfig {

    @Bean
    public IRule ribbonRule() {
        // Use round-robin load balancing
        return new RoundRobinRule();
    }
}

// Feign Client for Service Communication
@FeignClient("payment-service")
public interface PaymentServiceClient {

    @PostMapping("/api/v1/payments")
    PaymentResponse processPayment(@RequestBody PaymentRequest request);

    @GetMapping("/api/v1/payments/{paymentId}")
    PaymentResponse getPaymentStatus(@PathVariable String paymentId);
}

// Using Feign Client with fallback
@Service
public class PaymentServiceFacade {

    @Autowired
    private PaymentServiceClient paymentClient;

    public PaymentResponse processPayment(PaymentRequest request) {
        return paymentClient.processPayment(request);
    }
}

// Fallback implementation
@Component
public class PaymentServiceFallback implements PaymentServiceClient {

    @Override
    public PaymentResponse processPayment(PaymentRequest request) {
        logger.warn("Payment service unavailable, returning pending status");
        return new PaymentResponse(
            request.getOrderId(),
            PaymentStatus.PENDING,
            "Service unavailable"
        );
    }

    @Override
    public PaymentResponse getPaymentStatus(String paymentId) {
        return new PaymentResponse(paymentId, PaymentStatus.UNKNOWN, "Service unavailable");
    }
}
```

---

## 11. Configuration Management

Managing configurations across environments.

```java
// Spring Cloud Config Server
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}

// Config Server Configuration
@Configuration
public class ConfigServerConfig {

    @Bean
    public EnvironmentRepository environmentRepository() {
        // Git-backed configuration repository
        SearchPathLocator locator = new SearchPathLocator();
        return new CompositeEnvironmentRepository(
            new GitEnvironmentRepository("https://github.com/your-org/config-repo")
        );
    }
}

// Client Configuration
@Configuration
public class ClientConfig {

    // Refresh configuration without restart
    @RefreshScope
    @ConfigurationProperties(prefix = "app")
    public static class AppProperties {
        private String name;
        private String version;
        private DatabaseConfig database;

        // getters/setters
    }
}

@Service
public class ConfigurableService {

    @Autowired
    private AppProperties appProperties;

    public void processWithConfig() {
        logger.info("Using database host: {}", appProperties.getDatabase().getHost());
        // Configuration changes without restart via @RefreshScope
    }
}

// Dynamic Configuration Controller
@RestController
@RequestMapping("/actuator")
public class ConfigRefreshController {

    @PostMapping("/refresh")
    public ResponseEntity<String> refresh() {
        // Trigger configuration refresh
        return ResponseEntity.ok("Configuration refreshed");
    }
}
```

---

## 12. Database Patterns

Managing data in distributed systems.

### Database Per Service Pattern

```java
// User Service - Own Database
@Configuration
public class UserServiceDataConfig {

    @Bean
    @Primary
    public DataSource userDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:postgresql://user-db:5432/user_service");
        config.setUsername("user_service_user");
        config.setPassword("secure_password");
        config.setMaximumPoolSize(20);
        return new HikariDataSource(config);
    }

    @Bean
    @Primary
    public LocalContainerEntityManagerFactoryBean userEntityManagerFactory(
            DataSource userDataSource) {
        LocalContainerEntityManagerFactoryBean em = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(userDataSource);
        em.setPackagesToScan("com.example.user.entity");
        em.setJpaVendorAdapter(new HibernateJpaVendorAdapter());
        return em;
    }
}

// Order Service - Own Database
@Configuration
public class OrderServiceDataConfig {

    @Bean
    public DataSource orderDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:postgresql://order-db:5432/order_service");
        config.setUsername("order_service_user");
        config.setPassword("secure_password");
        config.setMaximumPoolSize(20);
        return new HikariDataSource(config);
    }
}
```

### Polyglot Persistence

```java
// Relational Database for transactional data
@Configuration
public class RelationalDataConfig {

    @Bean
    public DataSource relationDatabase() {
        return DataSourceBuilder.create()
            .driverClassName("org.postgresql.Driver")
            .url("jdbc:postgresql://postgres:5432/main_db")
            .username("user")
            .password("password")
            .build();
    }
}

// Document Database for flexible schema
@Configuration
public class MongoDBConfig {

    @Bean
    public MongoTemplate mongoTemplate(MongoClient mongoClient) {
        return new MongoTemplate(mongoClient, "app_db");
    }
}

// Cache for performance
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager() {
        return new RedisCacheManager(
            RedisCacheWriter.create(lettuceConnectionFactory()),
            RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(10))
        );
    }
}

// Service using polyglot persistence
@Service
public class HybridDataService {

    @Autowired
    private UserRepository userRepository;  // JPA/PostgreSQL

    @Autowired
    private MongoTemplate mongoTemplate;    // MongoDB

    @Autowired
    private CacheManager cacheManager;      // Redis

    @Cacheable(value = "user", key = "#userId")
    public User getUserWithCaching(String userId) {
        // Try cache first (Redis)
        Optional<User> cached = cacheManager.getCache("user")
            .get(userId, User.class);

        if (cached.isPresent()) {
            return cached.get();
        }

        // Fall back to relational database
        return userRepository.findById(userId).orElse(null);
    }

    public void storeAnalytics(String userId, AnalyticsData data) {
        // Store flexible analytics in MongoDB
        mongoTemplate.insert(data, "user_analytics");
    }
}
```

---

## 13. Caching Architecture

Multi-level caching strategy.

```java
@Configuration
@EnableCaching
public class CachingArchitecture {

    @Bean
    public CacheManager cacheManager() {
        return new RedisCacheManager(
            RedisCacheWriter.create(connectionFactory()),
            RedisCacheConfiguration.defaultCacheConfig()
                .withEntryTtl(Duration.ofMinutes(30))
                .withKeyPrefix("cache:")
                .disableCachingNullValues()
        );
    }

    @Bean
    public LettuceConnectionFactory connectionFactory() {
        return new LettuceConnectionFactory();
    }
}

@Service
public class CacheOptimizedUserService {

    @Autowired
    private UserRepository userRepository;

    // Cache-aside pattern
    @Cacheable(value = "user", key = "#userId")
    public User getUserById(String userId) {
        logger.info("Cache miss for user: {}", userId);
        return userRepository.findById(userId).orElse(null);
    }

    // Update cache on modification
    @CachePut(value = "user", key = "#user.id")
    public User updateUser(User user) {
        return userRepository.save(user);
    }

    // Invalidate cache
    @CacheEvict(value = "user", key = "#userId")
    public void deleteUser(String userId) {
        userRepository.deleteById(userId);
    }

    // Cache multiple values
    @Cacheable(value = "users", key = "#status")
    public List<User> getUsersByStatus(UserStatus status) {
        return userRepository.findByStatus(status);
    }

    // Cache warm-up
    @PostConstruct
    @CachePut(value = "activeUsers")
    public List<User> warmUpCache() {
        logger.info("Warming up cache with active users");
        return userRepository.findByStatus(UserStatus.ACTIVE);
    }
}

// Custom cache configuration
@Service
public class AdvancedCachingService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    public void setWithExpiry(String key, Object value, long expiryMinutes) {
        redisTemplate.opsForValue().set(key, value);
        redisTemplate.expire(key, Duration.ofMinutes(expiryMinutes));
    }

    public void setHashWithExpiry(String key, Map<String, Object> map, long expiryMinutes) {
        redisTemplate.opsForHash().putAll(key, map);
        redisTemplate.expire(key, Duration.ofMinutes(expiryMinutes));
    }

    public Object getFromCache(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    public void invalidatePattern(String pattern) {
        Set<String> keys = redisTemplate.keys(pattern);
        redisTemplate.delete(keys);
    }
}
```

---

## 14. Security Architecture

Implementing layered security.

```java
@Configuration
@EnableWebSecurity
public class SecurityArchitecture extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .authorizeRequests()
                .antMatchers("/public/**").permitAll()
                .antMatchers("/api/admin/**").hasRole("ADMIN")
                .antMatchers("/api/user/**").hasRole("USER")
                .anyRequest().authenticated()
            .and()
                .oauth2Login()
                    .loginPage("/login")
            .and()
                .exceptionHandling()
                    .accessDeniedPage("/access-denied");
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);  // Adaptive password encoding
    }
}

// Role-based Access Control
@Service
public class AuthorizationService {

    public boolean canAccessResource(String userId, String resourceId, String action) {
        // Check permissions
        return permissionRepository.hasPermission(userId, resourceId, action);
    }
}

// API Security with JWT
@Configuration
public class JwtSecurityConfig {

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter();
    }
}

public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                   HttpServletResponse response,
                                   FilterChain filterChain)
            throws ServletException, IOException {

        String token = getTokenFromRequest(request);

        if (token != null && tokenProvider.isValidToken(token)) {
            String userId = tokenProvider.getUserIdFromToken(token);
            UserDetails userDetails = loadUserDetails(userId);

            UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities()
                );

            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        filterChain.doFilter(request, response);
    }
}

// Audit Logging
@Aspect
@Component
public class SecurityAuditAspect {

    @Autowired
    private AuditLogRepository auditLogRepository;

    @Around("@annotation(audit)")
    public Object logSecurityEvent(ProceedingJoinPoint joinPoint, Audit audit)
            throws Throwable {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();

        AuditLog log = new AuditLog();
        log.setUsername(username);
        log.setAction(audit.value());
        log.setTimestamp(LocalDateTime.now());

        try {
            Object result = joinPoint.proceed();
            log.setStatus("SUCCESS");
            return result;
        } catch (Exception e) {
            log.setStatus("FAILURE");
            log.setErrorMessage(e.getMessage());
            throw e;
        } finally {
            auditLogRepository.save(log);
        }
    }
}
```

---

## 15. Monitoring & Observability

Complete observability stack.

```yaml
# Actuator Configuration
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
  endpoint:
    health:
      show-details: always

# Tracing Configuration
spring:
  sleuth:
    traces:
      sampling:
        probability: 0.1  # 10% sampling
  zipkin:
    base-url: http://zipkin:9411
    sender:
      type: web
```

```java
// Custom Metrics
@Service
public class MetricsService {

    @Autowired
    private MeterRegistry meterRegistry;

    private final AtomicInteger activeOrders = new AtomicInteger(0);

    @PostConstruct
    public void initMetrics() {
        meterRegistry.gauge("orders.active", activeOrders);
        meterRegistry.counter("orders.total").increment();
        meterRegistry.timer("orders.processing.time");
    }

    public void trackOrderProcessing(String orderId) {
        meterRegistry.timer("orders.processing.time").record(() -> {
            // Process order
        });
    }
}

// Distributed Tracing
@Service
public class TracedService {

    @Autowired
    private Tracer tracer;

    public void processOrder(String orderId) {
        Span span = tracer.startSpan("process-order");
        try {
            span.tag("order.id", orderId);

            // Business logic
            span.log("Order processing started");

        } finally {
            span.finish();
        }
    }
}

// Health Checks
@Component
public class CustomHealthIndicator extends AbstractHealthIndicator {

    @Autowired
    private PaymentServiceClient paymentService;

    @Override
    protected void doHealthCheck(Health.Builder builder) {
        try {
            PaymentResponse response = paymentService.healthCheck();
            builder.up()
                .withDetail("payment-service", "UP")
                .withDetail("latency", response.getLatency());
        } catch (Exception e) {
            builder.down()
                .withDetail("payment-service", "DOWN")
                .withException(e);
        }
    }
}
```

---

## 16. API Versioning

Managing API evolution.

```java
// URL-based versioning
@RestController
@RequestMapping("/api/v1/orders")
public class OrderControllerV1 {

    @GetMapping("/{orderId}")
    public ResponseEntity<OrderResponseV1> getOrder(@PathVariable String orderId) {
        // V1 response structure
        return ResponseEntity.ok(orderService.findById(orderId));
    }
}

@RestController
@RequestMapping("/api/v2/orders")
public class OrderControllerV2 {

    @GetMapping("/{orderId}")
    public ResponseEntity<OrderResponseV2> getOrder(@PathVariable String orderId) {
        // V2 response structure with additional fields
        return ResponseEntity.ok(orderService.findByIdV2(orderId));
    }
}

// Header-based versioning
@RestController
@RequestMapping("/api/orders")
public class OrderControllerHeader {

    @GetMapping("/{orderId}")
    public ResponseEntity<OrderResponse> getOrder(
            @PathVariable String orderId,
            @RequestHeader(value = "API-Version", defaultValue = "1") String version) {

        if ("1".equals(version)) {
            return ResponseEntity.ok(getOrderV1(orderId));
        } else if ("2".equals(version)) {
            return ResponseEntity.ok(getOrderV2(orderId));
        }

        return ResponseEntity.badRequest().build();
    }
}

// Deprecation Management
@Component
public class DeprecationHandler {

    @PostMapping("/api/v1/deprecated-endpoint")
    public ResponseEntity<?> deprecatedEndpoint() {
        return ResponseEntity
            .status(HttpStatus.OK)
            .header("Deprecation", "true")
            .header("Sunset", "Sun, 01 Jan 2025 00:00:00 GMT")
            .header("Link", "</api/v2/new-endpoint>; rel=\"successor-version\"")
            .body("Use /api/v2/new-endpoint instead");
    }
}
```

---

## Best Practices Summary

| Pattern | Use Case | Benefit |
|---------|----------|---------|
| **Layered** | Traditional monoliths | Clear separation of concerns |
| **Hexagonal** | Domain-focused apps | Technology independence |
| **Microservices** | Large systems | Independent scalability |
| **Event Sourcing** | Audit trails needed | Complete history preservation |
| **CQRS** | Read-heavy applications | Optimized queries |
| **Saga** | Distributed transactions | Eventual consistency |
| **Circuit Breaker** | Resilient systems | Failure prevention |
| **Cache-Aside** | High-traffic apps | Performance improvement |
| **API Gateway** | Microservices | Unified entry point |

---

## Comparison Table

| Architecture | Complexity | Scalability | Maintenance | Best For |
|-------------|-----------|------------|------------|----------|
| Layered | Low | Medium | Easy | Monolithic apps |
| Hexagonal | Medium | Medium | Moderate | Domain-rich apps |
| Microservices | High | High | Complex | Large systems |
| CQRS | High | Very High | Complex | Analytics systems |
| Event Sourcing | High | High | Complex | Audit-critical systems |

---

## Real-World Implementation Example

Complete order processing system combining multiple patterns:

```java
// Complete Order Management Service
@Service
@Transactional
public class OrderManagementService {

    @Autowired
    private OrderCommandService commandService;

    @Autowired
    private OrderQueryService queryService;

    @Autowired
    private OrderSagaOrchestrator sagaOrchestrator;

    @Autowired
    private CacheManager cacheManager;

    // Create and process order
    @Cacheable(value = "orders", key = "#customerId + ':' + #orderId")
    public Order createAndProcessOrder(CreateOrderCommand command) {
        // Validate
        validateOrder(command);

        // Create
        Order order = commandService.handle(command);

        // Process saga for distributed transaction
        sagaOrchestrator.executeOrderSaga(command);

        return queryService.findById(order.getId());
    }
}
```

---

This comprehensive chapter covers enterprise-grade architecture patterns essential for building scalable, maintainable Spring applications in production environments.

**Estimated Study Time:** 8-10 hours
**Code Examples:** 70+
**Patterns Covered:** 15 major patterns
**Real-World Focus:** Production-ready implementations

