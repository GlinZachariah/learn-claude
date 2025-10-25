# Dependency Injection & IoC Container Deep Dive

## Spring IoC Container Architecture

The Spring IoC container is responsible for instantiating, configuring, and managing Spring beans.

```
┌─────────────────────────────────────────┐
│         Spring IoC Container            │
├─────────────────────────────────────────┤
│  Bean Definition Registry               │
│  ├─ BeanDefinition                      │
│  ├─ BeanDefinition                      │
│  └─ BeanDefinition                      │
├─────────────────────────────────────────┤
│  Bean Factory                           │
│  ├─ getBean()                           │
│  ├─ containsBean()                      │
│  └─ getBeansOfType()                    │
├─────────────────────────────────────────┤
│  Application Context                    │
│  ├─ Event Publishing                    │
│  ├─ Resource Loading                    │
│  └─ Message Resolution                  │
└─────────────────────────────────────────┘
```

## Bean Definition Resolution

```java
@Configuration
public class BeanDefinitionExample {

    // Explicit bean definition with lifecycle callbacks
    @Bean(initMethod = "init", destroyMethod = "destroy")
    public DataSource dataSource(DataSourceProperties props) {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(props.getUrl());
        config.setUsername(props.getUsername());
        config.setPassword(props.getPassword());
        config.setMaximumPoolSize(props.getMaxPoolSize());
        return new HikariDataSource(config);
    }

    // Bean with dependencies
    @Bean
    public UserRepository userRepository(DataSource dataSource,
                                        @Value("${app.schema}") String schema) {
        return new JdbcUserRepository(dataSource, schema);
    }

    // Conditional bean registration
    @Bean
    @ConditionalOnMissingBean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager();
    }

    // Bean factory method
    @Bean
    public List<String> supportedLocales() {
        return Arrays.asList("en", "es", "fr", "de");
    }
}

// Accessing BeanDefinition at runtime
@Component
public class BeanInspector {

    @Autowired
    private ConfigurableApplicationContext context;

    public void inspectBean(String beanName) {
        BeanDefinition def = context.getBeanFactory()
            .getBeanDefinition(beanName);

        System.out.println("Bean Class: " + def.getBeanClassName());
        System.out.println("Scope: " + def.getScope());
        System.out.println("Lazy Init: " + def.isLazyInit());
        System.out.println("Primary: " + def.isPrimary());

        // Get constructor arguments
        ConstructorArgumentValues args = def.getConstructorArgumentValues();
        System.out.println("Constructor Args: " + args.getArgumentCount());

        // Get property values
        MutablePropertyValues props = def.getPropertyValues();
        for (PropertyValue pv : props) {
            System.out.println("Property: " + pv.getName() + " = " + pv.getValue());
        }
    }
}
```

## Advanced Dependency Injection

### Circular Dependency Handling

```java
// Circular dependency: A depends on B, B depends on A
@Service
public class ServiceA {
    private ServiceB serviceB;

    @Autowired
    public ServiceA(ServiceB serviceB) {  // Fails with constructor injection
        this.serviceB = serviceB;
    }
}

@Service
public class ServiceB {
    private ServiceA serviceA;

    @Autowired
    public ServiceB(ServiceA serviceA) {  // Circular!
        this.serviceA = serviceA;
    }
}

// Solution 1: Use setter injection (enables lazy initialization)
@Service
public class ServiceA {
    private ServiceB serviceB;

    @Autowired
    public void setServiceB(ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}

// Solution 2: Use ObjectProvider for lazy resolution
@Service
public class ServiceA {
    private final ObjectProvider<ServiceB> serviceBProvider;

    public ServiceA(ObjectProvider<ServiceB> serviceBProvider) {
        this.serviceBProvider = serviceBProvider;
    }

    public void process() {
        ServiceB serviceB = serviceBProvider.getIfAvailable();
        if (serviceB != null) {
            serviceB.doSomething();
        }
    }
}

// Solution 3: Refactor to eliminate circular dependency
@Service
public class CommonService {
    // Shared logic used by both A and B
}

@Service
public class ServiceA {
    private final CommonService common;
    public ServiceA(CommonService common) { this.common = common; }
}

@Service
public class ServiceB {
    private final CommonService common;
    public ServiceB(CommonService common) { this.common = common; }
}
```

### Autowiring by Type vs Name

```java
// Multiple beans of same type
@Configuration
public class PaymentConfig {

    @Bean
    public PaymentProcessor stripeProcessor() {
        return new StripeProcessor();
    }

    @Bean
    public PaymentProcessor paypalProcessor() {
        return new PayPalProcessor();
    }

    @Bean
    @Primary  // This is the default choice
    public PaymentProcessor squareProcessor() {
        return new SquareProcessor();
    }
}

// Injection scenarios
@Service
public class OrderService {

    // Case 1: Uses @Primary bean
    @Autowired
    private PaymentProcessor processor;

    // Case 2: Use @Qualifier to specify exact bean
    @Autowired
    @Qualifier("stripeProcessor")
    private PaymentProcessor stripeProcessor;

    // Case 3: Inject all beans of type
    @Autowired
    private List<PaymentProcessor> allProcessors;

    // Case 4: Inject as map with bean names as keys
    @Autowired
    private Map<String, PaymentProcessor> processorMap;

    // Case 5: ObjectProvider for lazy, safe access
    @Autowired
    private ObjectProvider<PaymentProcessor> processorProvider;

    public void process(Order order) {
        // Safe access with fallback
        PaymentProcessor p = processorProvider
            .getIfAvailable(() -> new DefaultProcessor());
        p.process(order);
    }
}
```

### Generic Type Resolution

```java
// Generic service interface
public interface GenericService<T> {
    void process(T item);
    List<T> getAll();
}

// Concrete implementations
@Service
public class UserService implements GenericService<User> {
    @Override
    public void process(User user) { /* ... */ }

    @Override
    public List<User> getAll() { /* ... */ }
}

@Service
public class OrderService implements GenericService<Order> {
    @Override
    public void process(Order order) { /* ... */ }

    @Override
    public List<Order> getAll() { /* ... */ }
}

// Generic injection with type resolution
@Component
public class DataProcessor {

    private final GenericService<User> userService;
    private final GenericService<Order> orderService;

    // Spring resolves generic types correctly
    public DataProcessor(GenericService<User> userService,
                        GenericService<Order> orderService) {
        this.userService = userService;
        this.orderService = orderService;
    }
}
```

## Advanced Bean Configuration

### ObjectFactory & ObjectProvider

```java
@Service
public class EmailService {
    private final ObjectProvider<EmailTemplate> templateProvider;
    private final ObjectProvider<MailSender> mailSenderProvider;

    public EmailService(ObjectProvider<EmailTemplate> templateProvider,
                       ObjectProvider<MailSender> mailSenderProvider) {
        this.templateProvider = templateProvider;
        this.mailSenderProvider = mailSenderProvider;
    }

    public void sendEmail(String to, String subject) {
        // Lazy resolution - only get if available
        EmailTemplate template = templateProvider.getIfAvailable();
        MailSender sender = mailSenderProvider.getIfAvailable(
            () -> new DefaultMailSender()
        );

        if (template != null && sender != null) {
            String content = template.render(subject);
            sender.send(to, subject, content);
        }
    }

    public void sendAllTemplates() {
        // Process all available implementations
        templateProvider.orderedStream()
            .forEach(template -> System.out.println(template.getName()));
    }
}
```

### Autowire Candidates

```java
@Configuration
public class BeanConfiguration {

    @Bean
    public DataSource primaryDataSource() {
        return createDataSource("primary");
    }

    @Bean
    public DataSource secondaryDataSource() {
        return createDataSource("secondary");
    }

    // Mark as autowire candidate (default)
    @Bean
    public DataSource cacheDataSource() {
        return createDataSource("cache");
    }

    // Exclude from autowiring
    @Bean(autowireCandidate = false)
    public DataSource backupDataSource() {
        return createDataSource("backup");
    }
}

@Service
public class DataService {
    // Only gets one of primary, secondary, or cache
    // Never gets backup (autowireCandidate=false)
    @Autowired
    private DataSource dataSource;
}
```

## Scope Deep Dive

### Singleton Scope Issues

```java
@Component
@Scope("singleton")
public class CacheService {
    private final Map<String, Object> cache = new ConcurrentHashMap<>();
    private long accessCount = 0;  // NOT thread-safe!

    public void put(String key, Object value) {
        cache.put(key, value);
        accessCount++;  // Race condition!
    }

    // Solution: Use thread-safe structures
    private final AtomicLong accessCount = new AtomicLong(0);

    public void put(String key, Object value) {
        cache.put(key, value);
        accessCount.incrementAndGet();  // Thread-safe
    }
}
```

### Scoped Proxy Pattern

```java
@Component
@Scope(value = "request", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class RequestContext {
    private String userId;
    private String requestId = UUID.randomUUID().toString();

    public String getRequestId() { return requestId; }
    public void setUserId(String userId) { this.userId = userId; }
}

@Service
public class UserAuditService {
    // Receives proxy, not the actual request-scoped bean
    // Proxy delegates to correct instance for each request
    private final RequestContext requestContext;

    @Autowired
    public UserAuditService(RequestContext requestContext) {
        this.requestContext = requestContext;
    }

    public void auditAction(String action) {
        // Each request gets correct RequestContext instance
        System.out.println("Request: " + requestContext.getRequestId());
    }
}
```

## BeanPostProcessor & BeanFactoryPostProcessor

```java
// Modify bean instances after creation
@Component
public class LoggingPostProcessor implements BeanPostProcessor {

    @Override
    public Object postProcessBeforeInitialization(Object bean, String name) {
        System.out.println("Before init: " + name);
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String name) {
        if (bean instanceof UserRepository) {
            // Wrap with logging proxy
            return createLoggingProxy((UserRepository) bean);
        }
        System.out.println("After init: " + name);
        return bean;
    }

    private UserRepository createLoggingProxy(UserRepository repo) {
        return new UserRepository() {
            @Override
            public Optional<User> findById(Long id) {
                System.out.println("Finding user: " + id);
                return repo.findById(id);
            }
        };
    }
}

// Modify BeanDefinitions before instantiation
@Component
public class BeanDefinitionPostProcessor implements BeanFactoryPostProcessor {

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory factory) {
        if (factory.containsBeanDefinition("userService")) {
            BeanDefinition def = factory.getBeanDefinition("userService");
            def.setLazyInit(true);  // Make lazy
            def.setScope("prototype");  // Change to prototype

            ConstructorArgumentValues args = def.getConstructorArgumentValues();
            // Modify constructor arguments...
        }
    }
}
```

## Profiles & Conditional Beans

```java
@Configuration
@Profile({"dev", "test"})
public class DevelopmentConfig {

    @Bean
    public DataSource devDataSource() {
        return new EmbeddedDatabaseBuilder()
            .setType(EmbeddedDatabaseType.H2)
            .build();
    }

    @Bean
    @Profile("dev")
    public LogLevel devLogLevel() {
        return LogLevel.DEBUG;
    }
}

@Configuration
@Profile("prod")
public class ProductionConfig {

    @Bean
    public DataSource prodDataSource(DataSourceProperties props) {
        return createHikariDataSource(props);
    }
}

// Conditional on properties
@Configuration
@ConditionalOnProperty(
    name = "app.cache.enabled",
    havingValue = "true",
    matchIfMissing = true
)
public class CacheConfig {
    @Bean
    public CacheManager cacheManager() { /* ... */ }
}

// Conditional on missing bean
@Configuration
public class DefaultsConfig {
    @Bean
    @ConditionalOnMissingBean
    public ErrorHandler defaultErrorHandler() {
        return new DefaultErrorHandler();
    }
}
```

## Lazy Initialization & Eager Loading

```java
@Configuration
public class InitializationConfig {

    // Eager initialization (default) - created at startup
    @Bean
    public HeavyService heavyService() {
        return new HeavyService();  // Created immediately
    }

    // Lazy initialization - created on first access
    @Bean
    @Lazy
    public ExpensiveComputation computation() {
        return new ExpensiveComputation();  // Created only when injected
    }

    // Conditional lazy
    @Bean
    @Lazy(value = false)  // Eager, even if marked lazy elsewhere
    public CriticalService criticalService() {
        return new CriticalService();
    }
}

// Lazy injection at dependency level
@Service
public class MyService {
    // This bean is fetched lazily when accessed
    @Autowired
    @Lazy
    private ExpensiveService expensive;

    public void process() {
        // Service instantiated here on first access
        expensive.doWork();
    }
}
```

---

## Key Takeaways

✅ ApplicationContext is the central component managing all beans
✅ Constructor injection is preferred for dependencies
✅ Use @Qualifier or @Primary for bean disambiguation
✅ ObjectProvider enables lazy, safe dependency resolution
✅ Scoped proxies handle request/session scopes correctly
✅ BeanPostProcessor allows bean modification after creation
✅ Profiles enable environment-specific configurations
✅ Understand circular dependency solutions
✅ Use thread-safe structures for singleton scoped beans

---

## Advanced Resources

- Spring Framework Reference Manual - Bean Definition
- Spring Bean Lifecycle Documentation
- Understanding Spring IoC Container
- Dependency Injection Patterns
