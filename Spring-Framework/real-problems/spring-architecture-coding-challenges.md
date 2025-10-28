# Spring Architecture Coding Challenges

## Challenge 1: Build a Complete Microservice with Circuit Breaker (Intermediate, 3 hours)

### Problem Description
Create an Order microservice that integrates with external Payment and Inventory services using resilience patterns.

### Requirements
1. Create OrderService with async order processing
2. Implement circuit breaker for Payment Service calls
3. Implement retry logic with exponential backoff
4. Add timeout management
5. Create comprehensive error handling
6. Implement saga pattern for distributed transaction

### Starter Code
```java
@SpringBootApplication
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}

@Service
public class OrderService {
    // TODO: Implement with circuit breaker, retry, timeout
}

@Repository
public interface OrderRepository extends JpaRepository<Order, String> {
}
```

### Expected Solution Structure
```
- Create Order entity with proper JPA mapping
- Implement OrderService with @CircuitBreaker, @Retry, @Timeout
- Create PaymentClient with resilience configuration
- Implement saga for order processing
- Add comprehensive exception handling
- Create integration tests with mock external services
```

### Bonus Features
- Implement event sourcing for orders
- Add request/response caching
- Create health checks for external services
- Implement bulkhead pattern for resource isolation

---

## Challenge 2: Implement CQRS Pattern for E-Commerce Platform (Advanced, 4 hours)

### Problem Description
Design and implement CQRS pattern with separate read and write models for a complex e-commerce system.

### Requirements
1. Create command side (OrderCommandService)
2. Create query side (OrderQueryService)
3. Implement event handlers to keep read model in sync
4. Create separate databases for write and read models
5. Implement eventually consistent updates
6. Add compensation logic for failed commands

### Starter Code
```java
// Command
@Data
public class PlaceOrderCommand {
    private String customerId;
    private List<OrderItemDTO> items;
    private String shippingAddress;
}

// Query
public interface OrderReadModelRepository extends JpaRepository<OrderReadModel, String> {
}

@Service
public class OrderCommandService {
    // TODO: Implement command handling
}

@Service
public class OrderQueryService {
    // TODO: Implement queries
}
```

### Expected Solution
- Write model: Optimized for consistency and transactions
- Read model: Denormalized for query performance
- Event handlers: Sync read model from domain events
- Separate EntityManagers for read/write
- Compensation for failed operations

### Bonus Features
- Implement multiple read models for different queries
- Add read model versioning
- Create snapshots for event replay optimization
- Implement eventual consistency validation

---

## Challenge 3: Design DDD-Based Domain with Aggregates (Intermediate, 3 hours)

### Problem Description
Implement a domain-driven design system with proper aggregates, value objects, and domain services.

### Requirements
1. Create Order aggregate root
2. Create OrderItem value object
3. Implement domain logic in aggregates
4. Create repository interface (domain port)
5. Create repository implementation (infrastructure)
6. Publish domain events
7. Create application service

### Starter Code
```java
@Embeddable
public class Money {
    private BigDecimal amount;
    private String currency;
    // TODO: Implement value object logic
}

@Entity
public class Order extends AggregateRoot {
    // TODO: Implement aggregate root with business logic
}

public interface OrderRepository {
    Order findById(OrderId id);
    void save(Order order);
}

@Service
public class PlaceOrderUseCase {
    // TODO: Implement application service
}
```

### Expected Solution
- Immutable value objects
- Aggregates with encapsulated business logic
- Repository pattern for persistence
- Domain events for state changes
- Application service orchestration
- Clear separation of concerns

### Bonus Features
- Implement aggregate versioning
- Add audit trail for aggregates
- Create snapshot mechanism
- Implement aggregate rebuilding from events

---

## Challenge 4: API Gateway with Spring Cloud Gateway (Intermediate, 2.5 hours)

### Problem Description
Build a resilient API Gateway that routes requests to multiple microservices with advanced features.

### Requirements
1. Create route configuration for 3+ microservices
2. Implement rate limiting
3. Add request/response transformation
4. Implement authentication filter
5. Add circuit breaker integration
6. Create comprehensive logging

### Starter Code
```java
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
        // TODO: Configure routes with filters
    }
}
```

### Expected Solution
- Dynamic routing based on paths
- Rate limiter with different limits per service
- Request header manipulation
- Authentication validation
- Circuit breaker for downstream services
- Structured logging with correlation IDs

### Bonus Features
- Implement OAuth2 integration
- Add request tracing headers
- Create custom rate limiting based on user
- Implement load balancing strategies

---

## Challenge 5: Event Sourcing Implementation (Advanced, 4 hours)

### Problem Description
Implement complete event sourcing system with event store, event replay, and temporal queries.

### Requirements
1. Create DomainEvent base class
2. Implement EventStore (database)
3. Create aggregate reconstruction from events
4. Implement event publishing
5. Create event subscribers/handlers
6. Implement temporal queries (state at time T)
7. Add event versioning support

### Starter Code
```java
public interface DomainEvent {
    LocalDateTime getOccurredAt();
    String getAggregateId();
}

public interface EventStore {
    void append(String aggregateId, List<DomainEvent> events);
    List<DomainEvent> getEventsForAggregate(String aggregateId);
    List<DomainEvent> getEventsSince(LocalDateTime time);
}

@Service
public class EventSourcingService {
    // TODO: Implement event sourcing logic
}
```

### Expected Solution
- Event storage in database
- Event replay mechanism
- Aggregate reconstruction
- Event publication to subscribers
- Temporal query support
- Concurrency handling with version numbers
- Event migration/versioning

### Bonus Features
- Implement snapshot mechanism
- Create event upcasting for versioning
- Add event analytics
- Implement event compaction
- Create debugging tools for event stream

---

## Challenge 6: Distributed Tracing with Spring Cloud Sleuth & Zipkin (Intermediate, 2.5 hours)

### Problem Description
Implement distributed tracing across microservices using Spring Cloud Sleuth and Zipkin.

### Requirements
1. Configure Sleuth for all services
2. Setup Zipkin server
3. Implement custom spans
4. Create trace context propagation
5. Add trace-specific logging
6. Implement sampling strategy

### Starter Code
```java
@Configuration
public class TracingConfig {
    // TODO: Configure Sleuth and Zipkin
}

@Service
public class OrderService {
    @Autowired
    private Tracer tracer;

    public void processOrder(String orderId) {
        // TODO: Add custom spans
    }
}
```

### Expected Solution
- Automatic trace ID generation
- Cross-service trace propagation
- Custom span creation
- Trace visualization in Zipkin
- Sampling for high-traffic scenarios
- Correlation ID logging

### Bonus Features
- Implement custom span tags
- Add business event tracking
- Create trace analysis queries
- Implement alerting on trace data
- Build dashboard for trace metrics

---

## Challenge 7: Build Configuration Server with Git Backend (Easy-Intermediate, 2 hours)

### Problem Description
Create a Spring Cloud Config server with Git backend for centralized configuration management.

### Requirements
1. Setup Config Server with Git
2. Create profile-specific configurations
3. Implement dynamic refresh (@RefreshScope)
4. Add encryption for sensitive data
5. Create configuration versioning
6. Implement validation

### Starter Code
```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}

@Configuration
public class SecurityConfig {
    // TODO: Configure encryption keys
}
```

### Expected Solution
- Git repository setup
- Environment-specific configurations
- Property refresh without restart
- Sensitive data encryption
- Version history tracking
- Configuration validation

### Bonus Features
- Implement custom property sources
- Add webhook for config refresh
- Create configuration audit trail
- Implement property encryption UI
- Add configuration versioning UI

---

## Challenge 8: Build Resilient Service Discovery with Health Checks (Intermediate, 3 hours)

### Problem Description
Implement service discovery, load balancing, and health checks using Spring Cloud.

### Requirements
1. Setup Consul/Eureka server
2. Register services with health checks
3. Implement Ribbon load balancing
4. Create custom health indicators
5. Implement graceful shutdown
6. Add service availability monitoring

### Starter Code
```java
@SpringBootApplication
@EnableDiscoveryClient
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}

@Component
public class CustomHealthIndicator extends AbstractHealthIndicator {
    // TODO: Implement custom health checks
}

@Configuration
public class LoadBalancingConfig {
    // TODO: Configure load balancing
}
```

### Expected Solution
- Service registration in Consul/Eureka
- Health check endpoints
- Automatic service deregistration
- Load balancing between instances
- Custom health indicators
- Service availability metrics

### Bonus Features
- Implement weighted load balancing
- Add sticky session support
- Create service dependency health checks
- Implement gradual shutdown
- Add service version compatibility checks

---

## General Requirements for All Challenges

### Code Quality
- ✅ Proper exception handling
- ✅ Comprehensive logging
- ✅ Configuration management
- ✅ Unit tests (minimum 80% coverage)
- ✅ Integration tests
- ✅ Clear code comments

### Documentation
- ✅ Architecture diagram
- ✅ API documentation
- ✅ Configuration guide
- ✅ Deployment instructions
- ✅ Troubleshooting guide

### Deliverables
- ✅ Source code
- ✅ Unit test suite
- ✅ Integration test suite
- ✅ Docker configuration
- ✅ README with setup instructions
- ✅ Architecture documentation

---

## Evaluation Criteria

| Criteria | Points |
|----------|--------|
| **Functionality** | 30% |
| **Code Quality** | 25% |
| **Error Handling** | 20% |
| **Testing** | 15% |
| **Documentation** | 10% |

---

## Helpful Resources

### Technologies
- Spring Cloud (Gateway, Config, Consul)
- Resilience4j (Circuit Breaker, Retry, Timeout)
- Spring Data JPA
- Kafka/RabbitMQ for events
- Docker for containerization
- Zipkin for tracing

### Testing Tools
- JUnit 5
- Mockito
- WireMock for mocking
- TestContainers for integration tests
- Spring Boot Test

### Development Tools
- Postman/Insomnia for API testing
- Docker Compose for local environment
- Git for version control
- Maven/Gradle for build

---

## Common Pitfalls to Avoid

1. **Distributed Transactions:** Use saga pattern, not distributed 2PC
2. **Network Failures:** Always implement retry and circuit breaker
3. **Data Consistency:** Embrace eventual consistency
4. **Logging:** Use structured logging with correlation IDs
5. **Deployment:** Containerize and use container orchestration
6. **Monitoring:** Implement comprehensive observability
7. **Security:** Never hardcode secrets, use configuration server

---

## Time Estimates

| Challenge | Difficulty | Time | Total Points |
|-----------|-----------|------|--------|
| 1 | Intermediate | 3h | 20 |
| 2 | Advanced | 4h | 25 |
| 3 | Intermediate | 3h | 20 |
| 4 | Intermediate | 2.5h | 18 |
| 5 | Advanced | 4h | 25 |
| 6 | Easy-Int | 2h | 15 |
| 7 | Intermediate | 3h | 20 |
| 8 | Intermediate | 3h | 20 |
| **Total** | **Mixed** | **24.5h** | **163** |

---

## Success Indicators

After completing these challenges, you should be able to:

✅ Design and implement resilient microservices
✅ Use patterns: CQRS, Event Sourcing, Saga, DDD
✅ Configure Spring Cloud for distributed systems
✅ Implement proper error handling and resilience
✅ Setup and manage configuration across environments
✅ Implement distributed tracing and monitoring
✅ Design domain models using DDD principles
✅ Handle eventual consistency properly
✅ Write production-ready code with tests
✅ Deploy and monitor microservices

