# Spring Framework Fundamentals & Core Concepts

## Introduction to Spring Framework

Spring Framework is a comprehensive, enterprise-grade Java framework that provides a complete ecosystem for building production-ready applications. At its core, Spring simplifies enterprise application development through:

- **Inversion of Control (IoC)** - Framework manages object lifecycle
- **Dependency Injection (DI)** - Loose coupling between components
- **Aspect-Oriented Programming (AOP)** - Cross-cutting concerns
- **Template-based approach** - Reduces boilerplate code
- **Integration ecosystem** - Database, messaging, caching, security

```java
// Traditional approach: Tight coupling
public class OrderService {
    private PaymentProcessor processor = new StripeProcessor();

    public void processOrder(Order order) {
        processor.process(order);
    }
}

// Spring approach: Loose coupling with DI
@Service
public class OrderService {
    private final PaymentProcessor processor;

    @Autowired
    public OrderService(PaymentProcessor processor) {
        this.processor = processor;
    }

    public void processOrder(Order order) {
        processor.process(order);
    }
}
```

---

## The Spring Ecosystem

### Core Projects

**Spring Framework (Core)**
- IoC Container
- Dependency Injection
- AOP support
- Transaction management
- Web framework (MVC/Reactive)

**Spring Boot**
- Auto-configuration
- Embedded servers
- Opinionated defaults
- Simplified deployment
- Actuators & monitoring

**Spring Data**
- Unified data access abstraction
- JPA, MongoDB, Redis support
- Query generation
- Pagination & sorting

**Spring Security**
- Authentication & authorization
- OAuth2/OpenID Connect
- SAML support
- Method-level security

**Spring Cloud**
- Service discovery
- Circuit breakers
- Config servers
- API gateway
- Distributed tracing

**Spring Integration**
- Message-driven architecture
- Enterprise integration patterns
- Adapters for external systems

### Typical Spring Application Stack

```
┌─────────────────────────────────────┐
│     Spring Boot Application         │
├─────────────────────────────────────┤
│  Spring Web (MVC/Reactive)          │
│  Spring Security                    │
│  Spring AOP                         │
├─────────────────────────────────────┤
│  Spring Core (IoC/DI)               │
│  Spring Context                     │
├─────────────────────────────────────┤
│  Spring Data (JPA/MongoDB/Redis)    │
│  Spring Transaction Management      │
├─────────────────────────────────────┤
│  Spring Boot Auto-configuration     │
│  Embedded Server (Tomcat/Netty)     │
└─────────────────────────────────────┘
```

---

## Core Spring Concepts

### 1. Inversion of Control (IoC)

The IoC principle inverts the traditional flow of control: instead of your code controlling the instantiation and lifecycle of objects, the framework does.

```java
// Without IoC: You control object creation
public class Application {
    public static void main(String[] args) {
        Database db = new PostgresDatabase();
        UserRepository repo = new JpaUserRepository(db);
        UserService service = new UserService(repo);

        UserController controller = new UserController(service);
        controller.handleRequest();
    }
}

// With IoC: Spring controls object creation
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

@RestController
@RequestMapping("/users")
public class UserController {
    @Autowired
    private UserService userService;

    // Spring provides userService automatically
}
```

### 2. Dependency Injection (DI)

DI is a technique for achieving loose coupling by providing dependencies from outside.

**Three types of DI:**

```java
// Constructor Injection (Recommended)
@Service
public class OrderService {
    private final PaymentService paymentService;
    private final InventoryService inventoryService;

    public OrderService(PaymentService paymentService,
                        InventoryService inventoryService) {
        this.paymentService = paymentService;
        this.inventoryService = inventoryService;
    }
}

// Setter Injection (Less preferred)
@Service
public class OrderService {
    private PaymentService paymentService;

    @Autowired
    public void setPaymentService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}

// Field Injection (Anti-pattern but common)
@Service
public class OrderService {
    @Autowired
    private PaymentService paymentService;

    // Problems: Hard to test, hides dependencies, NullPointerException risks
}
```

### 3. Bean Lifecycle

Spring manages the complete lifecycle of beans (managed objects):

```
┌──────────────────────────┐
│  1. Bean Definition      │ Spring reads configuration, creates BeanDefinition
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│  2. Bean Instantiation   │ Constructor called (reflection)
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│  3. Dependency Injection │ Setter/Constructor injection
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│  4. Initialize Callbacks │ @PostConstruct, InitializingBean
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│  5. Bean Ready           │ Bean available for use
└────────────┬─────────────┘
             │
┌────────────▼─────────────┐
│  6. Destroy Callbacks    │ @PreDestroy, DisposableBean
└──────────────────────────┘
```

**Example:**

```java
@Component
public class DataService implements InitializingBean, DisposableBean {

    private DataSource dataSource;

    @PostConstruct
    public void init() {
        System.out.println("1. Initialize resources");
        dataSource = createDataSource();
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("2. Properties are set");
    }

    @PreDestroy
    public void cleanup() {
        System.out.println("3. Cleanup resources");
        dataSource.close();
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("4. Destroy bean");
    }
}
```

### 4. Bean Scopes

```java
// Singleton (default) - One instance per context
@Component
@Scope("singleton")
public class SingletonService {
    // One instance for entire application
}

// Prototype - New instance each time
@Component
@Scope("prototype")
public class PrototypeService {
    // New instance each time it's injected
}

// Request (Web) - One per HTTP request
@Component
@Scope("request")
public class RequestService {
    // New instance for each HTTP request
}

// Session (Web) - One per HTTP session
@Component
@Scope("session")
public class SessionService {
    // One instance per user session
}

// Application (Web) - One per ServletContext
@Component
@Scope("application")
public class ApplicationService {
    // Shared across entire web application
}
```

### 5. Configuration Styles

**Java-based Configuration (Preferred):**

```java
@Configuration
public class AppConfig {

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource(hikariConfig());
    }

    @Bean
    public UserRepository userRepository(DataSource dataSource) {
        return new JpaUserRepository(dataSource);
    }

    @Bean
    public UserService userService(UserRepository userRepository) {
        return new UserService(userRepository);
    }
}
```

**Annotation-based Configuration:**

```java
@Configuration
@ComponentScan(basePackages = "com.example.app")
@EnableTransactionManagement
public class AppConfig {
    // Use @Component, @Service, @Repository annotations
}
```

**XML Configuration (Legacy):**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans">

    <bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource">
        <property name="jdbcUrl" value="${db.url}"/>
        <property name="username" value="${db.user}"/>
    </bean>

    <bean id="userRepository" class="com.example.JpaUserRepository">
        <constructor-arg ref="dataSource"/>
    </bean>
</beans>
```

---

## Spring Annotations Overview

### Component Definition

```java
@Component           // Generic component
@Service            // Business logic layer
@Repository         // Data access layer
@Controller         // Web controller
@RestController     // REST endpoint (combines @Controller + @ResponseBody)
@Configuration      // Configuration class
```

### Dependency Injection

```java
@Autowired          // Inject by type (field, setter, constructor)
@Qualifier("name")  // Specify which bean to inject
@Inject             // Standard annotation (similar to @Autowired)
@Value("${prop}")   // Inject configuration values
```

### Configuration

```java
@Bean               // Define bean in @Configuration class
@Scope              // Set bean scope
@Lazy               // Lazy initialization
@Primary            // Primary bean when multiple candidates
@Conditional        // Conditional bean registration
```

### Lifecycle

```java
@PostConstruct      // Execute after bean creation
@PreDestroy         // Execute before bean destruction
InitializingBean    // Implement afterPropertiesSet()
DisposableBean      // Implement destroy()
```

---

## Spring ApplicationContext

The ApplicationContext is the core container that manages all beans and their lifecycle.

```java
// Creating ApplicationContext
ApplicationContext context =
    new AnnotationConfigApplicationContext(AppConfig.class);

// Retrieving beans
UserService userService = context.getBean(UserService.class);
UserService service2 = context.getBean("userService", UserService.class);

// Checking if bean exists
boolean exists = context.containsBean("userService");

// Getting all beans of a type
Map<String, UserService> allServices =
    context.getBeansOfType(UserService.class);

// Closing context (triggers @PreDestroy)
context.close();
```

**ApplicationContext Hierarchy:**

```
ApplicationContext (Interface)
├─ ConfigurableApplicationContext
│  ├─ AbstractApplicationContext
│  │  ├─ AnnotationConfigApplicationContext
│  │  ├─ ClassPathXmlApplicationContext
│  │  ├─ FileSystemXmlApplicationContext
│  │  └─ AbstractRefreshableApplicationContext
│  └─ GenericApplicationContext
├─ WebApplicationContext
│  ├─ ConfigurableWebApplicationContext
│  │  └─ AbstractRefreshableWebApplicationContext
│  └─ GenericWebApplicationContext
└─ ReactiveWebApplicationContext
```

---

## Common Patterns & Best Practices

### 1. Constructor Injection Pattern

```java
@Service
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;
    private final LoggingService logger;

    // All dependencies in constructor
    public UserService(UserRepository repository,
                      EmailService emailService,
                      LoggingService logger) {
        this.repository = repository;
        this.emailService = emailService;
        this.logger = logger;
    }

    // Benefits:
    // - All dependencies explicit
    // - Immutability (final fields)
    // - Easy to test
    // - No NullPointerException risks
}
```

### 2. Configuration Properties Pattern

```java
@Configuration
@ConfigurationProperties(prefix = "app")
@Getter
@Setter
public class AppProperties {
    private String name;
    private int maxConnections;
    private String databaseUrl;

    @NestedConfigurationProperty
    private Security security = new Security();

    @Getter
    @Setter
    public static class Security {
        private String jwtSecret;
        private long tokenExpiration;
    }
}

// application.properties
// app.name=MyApp
// app.max-connections=100
// app.database-url=jdbc:postgresql://localhost:5432/db
// app.security.jwt-secret=secret
// app.security.token-expiration=3600000

// Usage:
@Service
public class AppService {
    public AppService(AppProperties props) {
        System.out.println("App: " + props.getName());
    }
}
```

### 3. Factory Pattern with Spring

```java
@Configuration
public class DataSourceConfig {

    @Bean
    @Profile("!test")  // Not in test profile
    public DataSource productionDataSource() {
        return createHikariDataSource("prod");
    }

    @Bean
    @Profile("test")
    public DataSource testDataSource() {
        return new EmbeddedDatabaseBuilder()
            .setType(EmbeddedDatabaseType.H2)
            .build();
    }

    @Bean
    @Conditional(PostgresCondition.class)
    public Database postgresDatabase() {
        return new PostgresDatabase();
    }
}
```

### 4. Event-Driven Pattern

```java
// Event definition
public class UserCreatedEvent extends ApplicationEvent {
    private final String userId;

    public UserCreatedEvent(Object source, String userId) {
        super(source);
        this.userId = userId;
    }

    public String getUserId() {
        return userId;
    }
}

// Publisher
@Service
public class UserService {
    @Autowired
    private ApplicationEventPublisher eventPublisher;

    public void createUser(String userId) {
        // Create user...
        eventPublisher.publishEvent(new UserCreatedEvent(this, userId));
    }
}

// Listener
@Service
public class EmailNotificationService {

    @EventListener
    public void onUserCreated(UserCreatedEvent event) {
        String userId = event.getUserId();
        // Send welcome email
    }
}
```

---

## Exception Handling in Spring

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleEntityNotFound(
            EntityNotFoundException ex, HttpServletRequest request) {

        ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            "Resource not found",
            ex.getMessage(),
            request.getRequestURI(),
            LocalDateTime.now()
        );

        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(error);
    }

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            ValidationException ex) {

        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            ex.getErrors()
        );

        return ResponseEntity.badRequest().body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "Internal server error",
            "An unexpected error occurred"
        );

        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(error);
    }
}

@Getter
@AllArgsConstructor
public class ErrorResponse {
    private int status;
    private String message;
    private String details;
    private String path;
    private LocalDateTime timestamp;
}
```

---

## Spring vs Other Frameworks

| Feature | Spring | Quarkus | Micronaut | Jakarta EE |
|---------|--------|---------|-----------|------------|
| Startup Time | 2-3s | 0.2-0.5s | 0.5-1s | 2-3s |
| Memory Usage | 300-400MB | 100-150MB | 150-200MB | 300-400MB |
| Native Build | ✓ (GraalVM) | ✓ | ✓ | Limited |
| Ecosystem | Massive | Growing | Growing | Standard |
| Learning Curve | Moderate | Steep | Steep | Moderate |
| Production Ready | ✓ | ✓ | ✓ | ✓ |
| Cloud Native | ✓ | ✓ | ✓ | Limited |

---

## Setting Up Your First Spring Application

### Using Spring Initializr

```bash
# Via web: https://start.spring.io

# Via CLI:
curl https://start.spring.io/starter.zip \
  -d dependencies=web,jpa,h2,lombok \
  -d name=myapp \
  -d packageName=com.example.myapp \
  -o myapp.zip

unzip myapp.zip
cd myapp
mvn spring-boot:run
```

### Project Structure

```
spring-app/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/
│   │   │       ├── Application.java
│   │   │       ├── config/
│   │   │       │   └── AppConfig.java
│   │   │       ├── controller/
│   │   │       │   └── UserController.java
│   │   │       ├── service/
│   │   │       │   └── UserService.java
│   │   │       ├── repository/
│   │   │       │   └── UserRepository.java
│   │   │       └── entity/
│   │   │           └── User.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── application-dev.properties
│   └── test/
│       └── java/
│           └── com/example/
│               └── UserServiceTest.java
├── pom.xml
└── README.md
```

### Minimal Spring Boot Application

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(userService.findById(id));
    }

    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody CreateUserRequest req) {
        User user = userService.create(req);
        return ResponseEntity.created(URI.create("/api/users/" + user.getId()))
            .body(user);
    }
}
```

---

## Key Takeaways

✅ Spring provides IoC/DI for decoupled, testable code
✅ Constructor injection is the preferred dependency injection method
✅ ApplicationContext manages bean lifecycle and configuration
✅ Annotations simplify configuration compared to XML
✅ Spring Boot provides opinionated defaults and auto-configuration
✅ Profiles allow environment-specific configuration
✅ Global exception handling with @RestControllerAdvice
✅ Event-driven architecture for loose coupling
✅ Configuration properties for externalized settings

---

## Summary

Spring Framework is the de facto standard for Java enterprise applications. It provides a comprehensive ecosystem that handles:
- Dependency management (IoC/DI)
- Lifecycle management
- Configuration management
- Cross-cutting concerns (AOP)
- Web development (MVC/Reactive)
- Data persistence
- Security
- Transaction management

Mastering Spring fundamentals is essential for building scalable, maintainable enterprise applications.
