# Cloud & Microservices Integration

## Spring Cloud Configuration

```java
@Configuration
@EnableDiscoveryClient
@EnableCircuitBreaker
public class CloudConfig {

    // Service discovery: Eureka, Consul, Kubernetes
    // Circuit breaker: Hystrix/Resilience4j
    // Config server: Centralized configuration
    // Load balancer: Ribbon, LoadBalancer
}

// Resilience4j Circuit Breaker
@Configuration
public class CircuitBreakerConfig {

    @Bean
    public CircuitBreaker circuitBreaker() {
        CircuitBreakerConfig config = CircuitBreakerConfig.custom()
            .failureThreshold(50)
            .slowCallRateThreshold(50)
            .slowCallDurationThreshold(Duration.ofSeconds(2))
            .waitDurationInOpenState(Duration.ofSeconds(10))
            .build();

        return CircuitBreaker.of("userService", config);
    }
}

@Service
public class UserService {

    @CircuitBreaker(name = "userService")
    @Retry(name = "userService")
    @Timeout(name = "userService")
    public UserDTO getUser(Long id) {
        return remoteUserService.getUser(id);
    }
}
```

## Service-to-Service Communication

```java
@Configuration
public class FeignClientConfig {

    @Bean
    public RequestInterceptor requestInterceptor() {
        return requestTemplate -> {
            requestTemplate.header("Authorization", getToken());
        };
    }
}

@FeignClient(name = "user-service", url = "http://localhost:8081")
public interface UserServiceClient {

    @GetMapping("/api/users/{id}")
    UserDTO getUser(@PathVariable Long id);

    @PostMapping("/api/users")
    UserDTO createUser(@RequestBody CreateUserRequest request);
}

@Service
public class OrderService {

    @Autowired
    private UserServiceClient userServiceClient;

    public OrderDTO createOrder(CreateOrderRequest request) {
        UserDTO user = userServiceClient.getUser(request.getUserId());
        // Create order...
    }
}
```

## Observability

```java
@Configuration
public class ObservabilityConfig {

    @Bean
    public MeterBinder customMetrics() {
        return (registry) -> {
            Counter.builder("orders.created")
                .register(registry);
        };
    }
}

@Service
public class OrderService {

    @Autowired
    private MeterRegistry meterRegistry;

    public OrderDTO createOrder(CreateOrderRequest request) {
        try {
            OrderDTO order = doCreateOrder(request);
            meterRegistry.counter("orders.created").increment();
            return order;
        } catch (Exception e) {
            meterRegistry.counter("orders.failed").increment();
            throw e;
        }
    }
}
```

