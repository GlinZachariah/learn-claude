# Spring Architecture Interview Questions

## Part 1: Behavioral & System Design Questions

### Question 1: Design a Scalable Microservices Architecture

**Question:** You're tasked with designing an e-commerce platform expected to handle millions of transactions. Walk me through how you would architect this using Spring Boot microservices. What services would you create and how would they communicate?

**Answer:**

```
Service Design:
1. User Service - Authentication, profiles, preferences
2. Product Service - Catalog, inventory, pricing
3. Order Service - Order processing, fulfillment
4. Payment Service - Payment processing, transactions
5. Notification Service - Email, SMS, push notifications
6. Analytics Service - User behavior, trends
7. API Gateway - Route requests, rate limiting, auth
8. Configuration Server - Centralized configuration

Communication Strategy:
- Synchronous: REST/gRPC for real-time queries
- Asynchronous: Event-driven using message brokers
- Service Discovery: Consul/Eureka for dynamic registration
- Load Balancing: Round-robin or custom algorithms

Database Strategy:
- Database per service pattern
- Event sourcing for audit trails
- CQRS for read-heavy operations
- Eventual consistency model

Resilience:
- Circuit breakers (Hystrix/Resilience4j)
- Retry mechanisms with exponential backoff
- Bulkheads for resource isolation
- Health checks and monitoring
```

**Discussion Points:**
- Trade-offs between monolith and microservices
- Data consistency challenges in distributed systems
- Operational complexity and monitoring requirements
- Team structure and Conway's Law
- Cost implications of microservices

---

### Question 2: Database Strategy for Microservices

**Question:** In a microservices architecture, how do you handle distributed transactions and maintain data consistency? Compare event sourcing with saga pattern.

**Answer:**

**Event Sourcing:**
```
Advantages:
- Complete audit trail of all changes
- Temporal queries - state at any point in time
- Event replay and debugging
- Natural alignment with event-driven systems

Disadvantages:
- Increased storage requirements
- Complex event versioning and migration
- Learning curve for team
- Eventual consistency model

Best For:
- Financial systems requiring audit
- Complex domain logic
- Systems needing complete history
```

**Saga Pattern:**
```
Choreography-Based:
- Events trigger next step
- Decentralized coordination
- Simpler for small number of services

Orchestration-Based:
- Central saga coordinator
- Clear workflow definition
- Easier to debug and monitor
- Better for complex transactions

Advantages:
- Supports distributed transactions
- No distributed locking needed
- Natural to implement compensating transactions

Disadvantages:
- Eventual consistency
- Complexity in handling failures
- Testing challenges
```

---

### Question 3: Cache Strategy at Scale

**Question:** Describe a comprehensive caching strategy for a high-traffic e-commerce platform with multiple data types and varying update frequencies.

**Answer:**

```
Multi-Level Caching:

L1 - Application Cache (In-Memory):
- Caffeine for small, frequently accessed data
- Short TTL (minutes)
- User preferences, session data

L2 - Distributed Cache (Redis):
- Product catalog (12 hours)
- User profiles (2 hours)
- Shopping carts (session duration)

L3 - Database:
- Source of truth
- Full data

Strategies by Data Type:
1. Static Data (Products, Categories)
   - Cache-aside with long TTL
   - Pre-warm cache on startup

2. User-Specific Data (Preferences, Orders)
   - Session cache
   - Invalidate on update

3. Real-Time Data (Inventory)
   - Short TTL or write-through
   - Critical path bypass cache

4. Aggregate Data (Statistics)
   - Batch refresh
   - Background jobs

Cache Invalidation:
- Event-driven invalidation
- Time-based expiration
- Manual invalidation for urgent updates
- Dependency tracking

Monitoring:
- Hit/miss ratios
- Eviction rates
- Memory usage
- Performance impact
```

---

### Question 4: API Gateway Design

**Question:** Design an API Gateway for a microservices ecosystem. What responsibilities should it have and what should it NOT have?

**Answer:**

**Should Have:**
- Request routing based on path/host
- Rate limiting and quota management
- API versioning support
- Request/response transformation
- Authentication and authorization checks
- Request logging and monitoring
- SSL/TLS termination
- CORS handling
- Circuit breaker integration

**Should NOT Have:**
- Business logic
- Database access
- Complex data transformation
- Service-specific validation
- Long-running operations

**Implementation Example:**
```java
// Spring Cloud Gateway configuration
@Configuration
public class GatewayConfig {
    @Bean
    public RouteLocator routes(RouteLocatorBuilder builder) {
        return builder.routes()
            .route("user-service",
                r -> r.path("/users/**")
                    .filters(f -> f.addRequestHeader("X-Service", "user-service"))
                    .uri("lb://user-service"))
            .route("order-service",
                r -> r.path("/orders/**")
                    .filters(f -> f.requestRateLimiter()
                        .configure(c -> c.setKeyResolver(ipKeyResolver())))
                    .uri("lb://order-service"))
            .build();
    }
}
```

---

### Question 5: Handling Eventual Consistency

**Question:** How do you handle eventual consistency issues in a microservices system? Give examples of failures and recovery strategies.

**Answer:**

**Failure Scenarios:**

1. **Duplicate Events:**
   ```
   Solution: Idempotent event handling
   - Event deduplication using event ID
   - Idempotency keys for API calls
   - Database constraints for uniqueness
   ```

2. **Out-of-Order Events:**
   ```
   Solution: Event versioning and ordering
   - Sequence numbers in events
   - Timestamp-based ordering
   - State machine validation
   ```

3. **Missing Events:**
   ```
   Solution: Event replay and reconciliation
   - Event store audit trail
   - Periodic reconciliation jobs
   - Consumer offset management (Kafka)
   ```

4. **Stale Read:**
   ```
   Solution: Read repair pattern
   - Serve cached data with caveat
   - Provide eventual consistency guarantee
   - Option to read from primary
   ```

---

## Part 2: Technical Deep-Dive Questions

### Question 6: Microservices Communication Patterns

**Question:** Compare synchronous (REST/gRPC) vs asynchronous (message queue) communication in microservices. When would you use each?

**Answer:**

| Aspect | REST/gRPC | Message Queue |
|--------|-----------|---------------|
| **Latency** | Lower | Higher |
| **Coupling** | Tighter | Looser |
| **Consistency** | Immediate | Eventual |
| **Failure Handling** | Retry logic | Deadletter queues |
| **Scalability** | Limited | Better for spike loads |
| **Complexity** | Lower | Higher |

**Use REST/gRPC When:**
- Real-time queries needed
- Request-response model
- Strongly consistent data
- Direct client feedback needed

**Use Message Queues When:**
- Decoupling services
- Asynchronous processing
- High-volume events
- Eventual consistency acceptable

---

### Question 7: Implementing Circuit Breaker Pattern

**Question:** Implement a circuit breaker pattern with retry logic and explain the state transitions.

**Answer:**

```java
// Using Resilience4j
@Service
public class ResilientPaymentService {

    @CircuitBreaker(name = "paymentCircuit",
                   fallbackMethod = "paymentFallback")
    @Retry(name = "paymentRetry")
    @Timeout(name = "paymentTimeout")
    public PaymentResponse processPayment(PaymentRequest request) {
        return paymentClient.process(request);
    }

    public PaymentResponse paymentFallback(PaymentRequest request, Exception e) {
        // Return cached payment status or mark as pending
        return PaymentResponse.pending();
    }
}

// Configuration
@Configuration
public class ResilienceConfig {

    @Bean
    public CircuitBreakerRegistry circuitBreakerRegistry() {
        CircuitBreakerConfig config = CircuitBreakerConfig.custom()
            .failureThreshold(50)  // 50% failure rate
            .waitDurationInOpenState(Duration.ofSeconds(30))
            .permittedNumberOfCallsInHalfOpenState(3)
            .recordExceptions(HttpServerErrorException.class,
                             TimeoutException.class)
            .ignoreExceptions(ValidationException.class)
            .build();

        return CircuitBreakerRegistry.of(config);
    }
}

// State Transitions:
// CLOSED → OPEN: Failure threshold exceeded
// OPEN → HALF_OPEN: After wait duration
// HALF_OPEN → CLOSED: All test calls succeed
// HALF_OPEN → OPEN: Test call fails
```

**State Machine:**
- **CLOSED:** Normal operation, calls go through
- **OPEN:** Threshold exceeded, fail fast
- **HALF_OPEN:** Testing if service recovered

---

### Question 8: Domain-Driven Design in Spring

**Question:** Implement a domain model using DDD principles in Spring. Show aggregates, value objects, and repositories.

**Answer:**

```java
// Value Object - Immutable
@Embeddable
@Value
public class Money {
    private BigDecimal amount;
    private String currency;

    public Money add(Money other) {
        if (!currency.equals(other.currency)) {
            throw new CurrencyMismatchException();
        }
        return new Money(amount.add(other.amount), currency);
    }

    public Money multiply(int factor) {
        return new Money(amount.multiply(BigDecimal.valueOf(factor)), currency);
    }
}

// Aggregate Root
@Entity
@Data
public class Order extends AggregateRoot<OrderId> {
    @EmbeddedId
    private OrderId orderId;

    @Embedded
    private CustomerId customerId;

    @OneToMany(cascade = CascadeType.ALL)
    private List<OrderItem> items = new ArrayList<>();

    @Embedded
    private Money totalAmount;

    @Enumerated(EnumType.STRING)
    private OrderStatus status = OrderStatus.DRAFT;

    // Business logic encapsulated in aggregate
    public void addItem(OrderItem item) {
        if (!status.equals(OrderStatus.DRAFT)) {
            throw new OrderException("Cannot add items to non-draft order");
        }
        items.add(item);
        recalculateTotal();
    }

    public void placeOrder() {
        if (items.isEmpty()) {
            throw new OrderException("Order must have items");
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

// Repository Interface (Domain port)
public interface OrderRepository {
    Order findById(OrderId id);
    void save(Order order);
    void delete(OrderId id);
}

// Repository Implementation (Infrastructure adapter)
@Repository
public class JpaOrderRepository implements OrderRepository {
    @Autowired
    private OrderJpaRepository jpaRepository;

    @Override
    public Order findById(OrderId id) {
        return jpaRepository.findById(id)
            .map(this::toDomain)
            .orElse(null);
    }

    @Override
    public void save(Order order) {
        jpaRepository.save(toEntity(order));
    }
}

// Application Service
@Service
@Transactional
public class PlaceOrderService {
    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private PaymentService paymentService;

    public void execute(PlaceOrderCommand command) {
        Order order = orderRepository.findById(command.getOrderId());
        order.placeOrder();

        PaymentResult result = paymentService.pay(
            order.getCustomerId(),
            order.getTotalAmount()
        );

        if (!result.isSuccessful()) {
            throw new PaymentFailedException();
        }

        orderRepository.save(order);
        publishDomainEvents(order);
    }
}
```

---

### Question 9: CQRS Pattern Implementation

**Question:** Design and implement CQRS pattern for an analytics-heavy application.

**Answer:**

```java
// Command Side - Write Model
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateUserCommand {
    private String email;
    private String name;
    private String password;
}

@Service
public class UserCommandService {
    @Autowired
    private UserWriteRepository writeRepository;

    @Transactional
    public String handle(CreateUserCommand command) {
        User user = new User(
            UUID.randomUUID().toString(),
            command.getEmail(),
            command.getName(),
            hashPassword(command.getPassword())
        );

        writeRepository.save(user);

        // Publish event for read model update
        eventPublisher.publishEvent(new UserCreatedEvent(user.getId(), user.getEmail()));

        return user.getId();
    }
}

// Query Side - Read Model
@Entity
@Table(name = "user_read_model")
@Data
public class UserReadModel {
    @Id
    private String userId;
    private String email;
    private String name;
    private LocalDateTime createdAt;
    private int orderCount;
    private BigDecimal totalSpent;
}

@Repository
public interface UserReadModelRepository extends JpaRepository<UserReadModel, String> {
    List<UserReadModel> findByOrderCountGreaterThan(int count);
    List<UserReadModel> findByTotalSpentGreaterThan(BigDecimal amount);
}

@Service
public class UserQueryService {
    @Autowired
    private UserReadModelRepository readRepository;

    public UserReadModel findById(String userId) {
        return readRepository.findById(userId).orElse(null);
    }

    public List<UserReadModel> findHighValueCustomers(BigDecimal threshold) {
        return readRepository.findByTotalSpentGreaterThan(threshold);
    }
}

// Event Handler - Keeps read model in sync
@Component
public class UserEventHandler {
    @Autowired
    private UserReadModelRepository readRepository;

    @EventListener
    public void onUserCreated(UserCreatedEvent event) {
        UserReadModel readModel = new UserReadModel();
        readModel.setUserId(event.getUserId());
        readModel.setEmail(event.getEmail());
        readModel.setCreatedAt(LocalDateTime.now());
        readModel.setOrderCount(0);
        readModel.setTotalSpent(BigDecimal.ZERO);

        readRepository.save(readModel);
    }

    @EventListener
    public void onOrderPlaced(OrderPlacedEvent event) {
        UserReadModel readModel = readRepository.findById(event.getUserId()).orElseThrow();
        readModel.setOrderCount(readModel.getOrderCount() + 1);
        readModel.setTotalSpent(readModel.getTotalSpent().add(event.getTotalAmount()));
        readRepository.save(readModel);
    }
}

// Controller
@RestController
@RequestMapping("/api/users")
public class UserController {
    @Autowired
    private UserCommandService commandService;

    @Autowired
    private UserQueryService queryService;

    // Write endpoint
    @PostMapping
    public ResponseEntity<String> createUser(@RequestBody CreateUserCommand command) {
        String userId = commandService.handle(command);
        return ResponseEntity.status(HttpStatus.CREATED).body(userId);
    }

    // Read endpoint
    @GetMapping("/{userId}")
    public ResponseEntity<UserReadModel> getUser(@PathVariable String userId) {
        UserReadModel user = queryService.findById(userId);
        return user != null ? ResponseEntity.ok(user) : ResponseEntity.notFound().build();
    }
}
```

---

### Question 10: Spring Cloud Config Management

**Question:** Design a configuration management strategy for a multi-environment microservices architecture.

**Answer:**

```java
// Config Server Setup
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}

// application.yml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/company/config-repo
          basedir: /tmp/config-repo
          searchPaths: '{application}'
          default-label: main

# Client configuration
@Configuration
public class ConfigClientConfig {

    @Bean
    @RefreshScope  // Allows runtime refresh
    @ConfigurationProperties(prefix = "app")
    public AppProperties appProperties() {
        return new AppProperties();
    }
}

@RestControllerAdvice
public class ConfigRefreshController {

    @PostMapping("/actuator/refresh")
    public ResponseEntity<String> refresh() {
        // Trigger configuration refresh
        return ResponseEntity.ok("Configuration refreshed");
    }
}

// Properties with encryption
spring:
  cloud:
    config:
      server:
        encrypt:
          enabled: true
          key: {encrypted_key}

# Environment-specific configs
# application-dev.yml
server:
  port: 8080
logging:
  level:
    ROOT: DEBUG

# application-prod.yml
server:
  port: 8443
  ssl:
    enabled: true
logging:
  level:
    ROOT: WARN
```

---

### Question 11: Testing Strategy for Microservices

**Question:** Design a comprehensive testing strategy for microservices including unit, integration, and contract testing.

**Answer:**

```java
// Unit Testing
@DataJpaTest
public class OrderRepositoryTest {
    @Autowired
    private OrderRepository repository;

    @Test
    public void shouldFindOrderByCustomerId() {
        Order order = new Order("CUST123", List.of(), Money.of(100));
        repository.save(order);

        List<Order> result = repository.findByCustomerId("CUST123");

        assertThat(result).hasSize(1);
    }
}

// Integration Testing
@SpringBootTest
@ActiveProfiles("test")
public class OrderServiceIntegrationTest {
    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderRepository orderRepository;

    @Test
    public void shouldCompleteOrderWorkflow() {
        CreateOrderCommand command = new CreateOrderCommand("CUST123", List.of(), "123 Main St");

        String orderId = orderService.createOrder(command);

        Order order = orderRepository.findById(orderId);
        assertThat(order).isNotNull();
        assertThat(order.getStatus()).isEqualTo(OrderStatus.CREATED);
    }
}

// Contract Testing (Spring Cloud Contract)
@ExtendWith(SpringExtension.class)
@SpringBootTest
public class PaymentServiceContractTest {

    @RestClientTest(PaymentClient.class)
    public void shouldProcessPayment() {
        // Given
        stubFor(post(urlEqualTo("/payments"))
            .willReturn(aResponse()
                .withStatus(200)
                .withBody("{\"transactionId\":\"TXN123\",\"status\":\"SUCCESS\"}")));

        // When
        PaymentResponse response = paymentClient.process(new PaymentRequest("CUST123", 100));

        // Then
        assertThat(response.getTransactionId()).isEqualTo("TXN123");
    }
}

// End-to-End Testing
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class OrderFlowE2ETest {
    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void shouldCompleteFullOrderFlow() {
        // Create order
        ResponseEntity<String> createResponse = restTemplate.postForEntity(
            "/api/orders",
            new CreateOrderRequest("CUST123", List.of()),
            String.class
        );

        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        // Verify order status
        String orderId = createResponse.getBody();
        ResponseEntity<OrderDTO> getResponse = restTemplate.getForEntity(
            "/api/orders/" + orderId,
            OrderDTO.class
        );

        assertThat(getResponse.getBody().getStatus()).isEqualTo("CREATED");
    }
}

// Load Testing
@RunWith(JMeterRunner.class)
public class OrderServiceLoadTest {
    // Configuration for JMeter load testing
}
```

---

## Part 3: Architecture Decision Questions

### Question 12: Monolith vs Microservices

**Question:** A startup is deciding between monolithic and microservices architecture. What factors would you consider in recommending one over the other?

**Answer:**

**Choose Monolith When:**
- Team size < 5-6 developers
- MVP/early stage product
- Simple, well-defined domain
- Tight SLAs for consistency
- Limited DevOps resources
- Cost-conscious deployment

**Choose Microservices When:**
- Team size > 10-15 developers
- Multiple independent features
- Different scaling requirements
- Technology diversity needed
- Complex domain requiring isolation
- Independent deployment needed

**Hybrid Approach:**
- Start with modular monolith
- Split into microservices when pain points emerge
- Strangler pattern for gradual migration

---

### Question 13: Data Consistency Models

**Question:** Compare strong consistency, eventual consistency, and causal consistency. When would you choose each?

**Answer:**

| Model | Guarantee | Example | Trade-off |
|-------|-----------|---------|-----------|
| **Strong** | Immediate consistency | Financial transactions | Performance impact |
| **Eventual** | Consistency within time window | Social media likes | Temporary inconsistency |
| **Causal** | Related events maintain order | Comment threads | Implementation complexity |

---

### Question 14: Failure Recovery Strategies

**Question:** Design failure recovery for critical business operations in microservices.

**Answer:**

```
Strategies:

1. Bulkhead Pattern:
   - Isolate critical resources
   - Prevent cascading failures

2. Timeout Management:
   - Set appropriate timeouts
   - Fail fast vs retry decision

3. Backpressure Handling:
   - Queue management
   - Flow control

4. Health Checks:
   - Liveness probes
   - Readiness probes
   - Startup probes

5. Graceful Degradation:
   - Fallback mechanisms
   - Feature flags for quick rollback

6. Chaos Engineering:
   - Inject failures in controlled manner
   - Test recovery procedures
```

---

### Question 15: Observability Implementation

**Question:** Design a complete observability solution covering metrics, logs, and traces.

**Answer:**

```
Metrics (Prometheus/Micrometer):
- Request latency
- Error rates
- Service health
- Resource utilization
- Business metrics

Logs (ELK Stack):
- Structured logging (JSON)
- Correlation IDs for request tracing
- Log levels by environment
- Retention policies

Traces (Jaeger/Zipkin):
- Distributed tracing across services
- Identify bottlenecks
- Visualize request flow
- Performance analysis

Alerting:
- Anomaly detection
- Threshold-based alerts
- Escalation policies
```

---

## Best Practices

1. **Service Boundaries:** Domain-driven design for service separation
2. **Data Management:** Database per service with eventual consistency
3. **Communication:** Async preferred, sync for critical paths
4. **Resilience:** Circuit breakers, retries, timeouts
5. **Observability:** Comprehensive logging, metrics, traces
6. **Testing:** Unit, integration, contract, and E2E tests
7. **Deployment:** CI/CD pipelines, blue-green deployments
8. **Documentation:** API contracts, architecture diagrams, runbooks

---

## Follow-up Questions to Ask

1. What's your monitoring and alerting strategy?
2. How do you handle database migrations in microservices?
3. What's your approach to version management?
4. How do you ensure security across microservices?
5. What testing challenges have you faced?

---

**Interview Tips:**
- Use concrete examples from your experience
- Discuss trade-offs, not just benefits
- Show understanding of operational complexity
- Mention lessons learned and failures
- Ask clarifying questions about system requirements
- Discuss monitoring and observability needs

