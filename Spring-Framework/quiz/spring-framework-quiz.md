# Spring Framework - Self-Assessment Quiz

## Quiz Instructions

This quiz is organized by chapter to help you self-assess your understanding. Answer each question honestly to identify knowledge gaps.

**Scoring Guide:**
- **80-100%:** Excellent understanding, ready to move to next chapter
- **60-79%:** Good understanding, review weak areas before moving on
- **40-59%:** Moderate understanding, review chapter thoroughly
- **<40%:** Needs more study, consider re-reading the chapter

---

## Chapter 1: Fundamentals & Core Concepts (10 Questions)

### Q1.1: What is the primary benefit of Inversion of Control (IoC)?
**A)** Faster application startup time
**B)** Loose coupling and better testability
**C)** Reduced memory footprint
**D)** Automatic performance optimization

**Answer:** B
**Explanation:** IoC allows dependencies to be injected rather than created internally, resulting in loose coupling and code that's easier to test with mock objects.

---

### Q1.2: Which of the following is NOT a valid bean scope in Spring?
**A)** singleton
**B)** prototype
**C)** transient
**D)** request

**Answer:** C
**Explanation:** Spring supports singleton, prototype, request, session, and application scopes. "Transient" is a Java keyword but not a Spring bean scope.

---

### Q1.3: What does ApplicationContext provide that BeanFactory does not?
**A)** Bean instantiation
**B)** Bean creation from definitions
**C)** AOP, message resources, and event publishing
**D)** Object pooling

**Answer:** C
**Explanation:** ApplicationContext extends BeanFactory and adds features like AOP support, message resources (i18n), and application event publishing.

---

### Q1.4: Which annotation is used to mark a class as a Spring component?
**A)** @Bean
**B)** @Component
**C)** @Autowired
**D)** @Configuration

**Answer:** B
**Explanation:** @Component marks a class for automatic detection and registration as a Spring bean during classpath scanning.

---

### Q1.5: What is the correct order of bean lifecycle events?
**A)** Create → Inject → PostConstruct → Ready → PreDestroy → Destroy
**B)** Create → Inject → Initialize → Ready → Destroy → PreDestroy
**C)** Inject → Create → PostConstruct → Ready → PreDestroy → Destroy
**D)** Create → PostConstruct → Inject → Ready → Destroy → PreDestroy

**Answer:** A
**Explanation:** Beans follow: instantiation → dependency injection → @PostConstruct callbacks → ready for use → @PreDestroy callbacks → destruction.

---

### Q1.6: How many times is a singleton bean instantiated in a Spring application?
**A)** Once per method call
**B)** Once per request
**C)** Once per ApplicationContext
**D)** Once per JVM

**Answer:** C
**Explanation:** A singleton bean is instantiated exactly once per ApplicationContext. Each context gets its own instance.

---

### Q1.7: Which configuration style is considered most modern?
**A)** XML-based configuration
**B)** Java-based configuration
**C)** Annotation-based configuration
**D)** Properties file configuration

**Answer:** C
**Explanation:** Annotation-based configuration (@SpringBootApplication, @Bean, @Component) is most modern and convenient for Spring Boot applications.

---

### Q1.8: What happens if a required dependency cannot be injected?
**A)** Application starts with null dependency
**B)** ApplicationContext initialization fails
**C)** Runtime NullPointerException on first use
**D)** Dependency is automatically created

**Answer:** B
**Explanation:** Spring fails fast during ApplicationContext initialization if required dependencies cannot be resolved, preventing runtime errors.

---

### Q1.9: Which interface should be implemented for bean initialization?
**A)** InitializingBean
**B)** Initializable
**C)** BeanInitializer
**D)** AfterPropertiesSet

**Answer:** A
**Explanation:** InitializingBean interface provides afterPropertiesSet() method, though @PostConstruct annotation is preferred in modern Spring.

---

### Q1.10: What is the purpose of a BeanPostProcessor?
**A)** Process HTTP requests
**B)** Modify bean instances before/after initialization
**C)** Cache bean definitions
**D)** Manage bean destruction

**Answer:** B
**Explanation:** BeanPostProcessor allows modification of bean instances through postProcessBeforeInitialization() and postProcessAfterInitialization() methods.

---

## Chapter 2: Dependency Injection & IoC Container (10 Questions)

### Q2.1: What is constructor injection preferred over field injection?
**A)** It's faster
**B)** Immutability, testability, fail-fast detection
**C)** It uses less memory
**D)** It's easier to read

**Answer:** B
**Explanation:** Constructor injection enables immutable beans (final fields), easier testing (no need for reflection), and immediate detection of missing dependencies.

---

### Q2.2: Which of these will cause a circular dependency issue?
**A)** A depends on B, B depends on A
**B)** A depends on B, B depends on C, C depends on A
**C)** Both A and B
**D)** Neither - Spring always resolves circular dependencies

**Answer:** C
**Explanation:** Both direct (A→B→A) and transitive (A→B→C→A) circular dependencies are problematic unless using setter injection or proxies.

---

### Q2.3: What does @Qualifier annotation do?
**A)** Qualifies a class for Spring scanning
**B)** Specifies which bean to inject when multiple candidates exist
**C)** Qualifies a method as a bean factory method
**D)** Marks a field as optional

**Answer:** B
**Explanation:** @Qualifier disambiguates when multiple beans of the same type exist, specifying which one to inject.

---

### Q2.4: How does Spring resolve generic type information?
**A)** It ignores generic types
**B)** Through runtime type introspection (ResolvableType)
**C)** Generic types must be explicitly specified in XML
**D)** Spring doesn't support generic types

**Answer:** B
**Explanation:** Spring uses ResolvableType to introspect and resolve generic type information at runtime, enabling smart injection based on actual types.

---

### Q2.5: What is ObjectProvider used for?
**A)** Providing object instances
**B)** Lazy initialization and optional dependency handling
**C)** Storing objects in a pool
**D)** Providing metadata about objects

**Answer:** B
**Explanation:** ObjectProvider provides lazy access to beans and can handle optional dependencies gracefully with getIfAvailable(), getIfPresent(), etc.

---

### Q2.6: Which annotation marks a dependency as optional?
**A)** @Optional
**B)** @Required(false)
**C)** @Autowired(required = false)
**D)** @Nullable

**Answer:** C
**Explanation:** @Autowired(required = false) marks a dependency as optional; if not found, it won't cause initialization failure.

---

### Q2.7: How does Spring handle setter injection with circular dependencies?
**A)** It fails immediately
**B)** Through proxies and lazy initialization
**C)** By requiring explicit @Lazy annotation
**D)** It doesn't support setter injection

**Answer:** B
**Explanation:** Setter injection can work with circular dependencies because property setting happens after object creation, unlike constructor injection.

---

### Q2.8: What is a scoped proxy?
**A)** A proxy that limits request scope
**B)** A proxy that manages bean visibility
**C)** A proxy that injects a shorter-lived bean into a longer-lived bean
**D)** A proxy for ProxyFactoryBean

**Answer:** C
**Explanation:** Scoped proxies allow injecting request/session-scoped beans into singleton beans by wrapping them in proxies.

---

### Q2.9: What does @Primary annotation do?
**A)** Makes a bean primary in the classpath
**B)** Sets bean priority for initialization
**C)** Marks a bean as the preferred choice when multiple candidates exist
**D)** Marks a bean as read-only

**Answer:** C
**Explanation:** @Primary designates a bean as the default choice when multiple beans of the same type exist and no @Qualifier is specified.

---

### Q2.10: How are constructor parameters matched to bean definitions?
**A)** By order only
**B)** By type first, then by name
**C)** By name only
**D)** Requires explicit @Qualifier on each parameter

**Answer:** B
**Explanation:** Spring matches constructor parameters by type first, then by name if multiple candidates of the same type exist.

---

## Chapter 3: Spring Web MVC (10 Questions)

### Q3.1: What is the first step in DispatcherServlet request processing?
**A)** Execute the controller
**B)** Find the HandlerMapping
**C)** Render the view
**D)** Validate the request

**Answer:** B
**Explanation:** DispatcherServlet first consults HandlerMapping to determine which handler (controller) can handle the request.

---

### Q3.2: What does a HandlerAdapter do?
**A)** Adapts HTTP requests
**B)** Converts handlers to HTTP responses
**C)** Invokes the appropriate handler method
**D)** Adapts multiple handlers into one

**Answer:** C
**Explanation:** HandlerAdapter invokes the handler (controller method) with appropriate argument resolution and returns a ModelAndView.

---

### Q3.3: Which annotation indicates a method returns JSON instead of a view name?
**A)** @JSON
**B)** @ResponseBody
**C)** @RestMapping
**D)** @APIEndpoint

**Answer:** B
**Explanation:** @ResponseBody indicates the return value should be serialized directly to the response body (typically JSON/XML) rather than treated as a view name.

---

### Q3.4: What is the purpose of ViewResolver?
**A)** Resolves request URLs
**B)** Finds the actual view file based on view name
**C)** Resolves model attributes
**D)** Resolves bean definitions

**Answer:** B
**Explanation:** ViewResolver takes a logical view name (e.g., "users") and resolves it to an actual view file (e.g., "users.jsp" or "users.html").

---

### Q3.5: How are request parameters bound to method arguments?
**A)** Automatically by name matching
**B)** Through @RequestParam annotation
**C)** Both A and B
**D)** They cannot be bound automatically

**Answer:** C
**Explanation:** Spring binds request parameters by name matching automatically, or you can explicitly use @RequestParam for clarity and validation.

---

### Q3.6: What does @ExceptionHandler do?
**A)** Handles exceptions thrown in handlers
**B)** Catches all application exceptions
**C)** Marks a method to handle specific exceptions
**D)** Suppresses exceptions

**Answer:** C
**Explanation:** @ExceptionHandler marks a method to handle specific exception types, providing custom error responses.

---

### Q3.7: What is an interceptor in Spring MVC?
**A)** A request validator
**B)** A component that intercepts requests before/after handler execution
**C)** A view renderer
**D)** A bean post-processor

**Answer:** B
**Explanation:** HandlerInterceptor intercepts requests before (preHandle) and after (postHandle) handler execution, useful for logging, security, etc.

---

### Q3.8: How is content negotiation handled in Spring MVC?
**A)** By file extensions only
**B)** By Accept header, URL suffix, or parameter
**C)** By request method
**D)** Manually in controller code

**Answer:** B
**Explanation:** ContentNegotiationStrategy uses Accept header, URL suffixes (.json, .xml), or parameters to determine response format.

---

### Q3.9: What does @Valid annotation do on a method parameter?
**A)** Validates the parameter is not null
**B)** Triggers validation of the parameter object using JSR-303/380 validators
**C)** Validates the request method
**D)** Marks parameter as required

**Answer:** B
**Explanation:** @Valid triggers bean validation using JSR-303/380 annotations, binding validation errors to BindingResult.

---

### Q3.10: How are model attributes made available to views?
**A)** Through @ModelAttribute parameters
**B)** Added to Model object in controller
**C)** Both A and B
**D)** Views cannot access model attributes

**Answer:** C
**Explanation:** Model attributes can be added via @ModelAttribute methods or explicitly added to the Model object in controllers.

---

## Chapter 4: Spring Boot Essentials (10 Questions)

### Q4.1: What does @SpringBootApplication do?
**A)** Enables Spring Security
**B)** Combines @Configuration, @EnableAutoConfiguration, and @ComponentScan
**C)** Enables Boot actuators
**D)** Starts the embedded server

**Answer:** B
**Explanation:** @SpringBootApplication is a convenience annotation that combines configuration, auto-configuration, and component scanning.

---

### Q4.2: What is auto-configuration?
**A)** Automatic database configuration
**B)** Conditional configuration based on classpath dependencies
**C)** Configuration without application.properties
**D)** Automatic REST endpoint creation

**Answer:** B
**Explanation:** Auto-configuration uses @ConditionalOnClass, @ConditionalOnMissingBean, etc. to auto-configure beans based on what's on the classpath.

---

### Q4.3: How do you override a Spring Boot auto-configuration?
**A)** Modify application.properties
**B)** Define your own @Bean with @Primary
**C)** Both A and B
**D)** Auto-configurations cannot be overridden

**Answer:** C
**Explanation:** Auto-configs can be overridden through properties (application.properties/yml) or by defining your own beans (which take precedence).

---

### Q4.4: What is a Spring Boot Starter?
**A)** The main application class
**B)** A dependency that groups related dependencies together
**C)** An embedded server
**D)** A component that starts the application

**Answer:** B
**Explanation:** Starters (like spring-boot-starter-web) are convenience dependencies that bundle related libraries, simplifying pom.xml.

---

### Q4.5: How do you define environment-specific properties in Boot?
**A)** application-{profile}.properties files
**B)** Separate @Configuration classes
**C)** Both A and B
**D)** Cannot be done in Boot

**Answer:** C
**Explanation:** Boot supports profile-specific property files (application-dev.properties, application-prod.properties) and @Profile-annotated configurations.

---

### Q4.6: What does the Actuator module provide?
**A)** Web server functionality
**B)** Database access
**C)** Production-ready monitoring endpoints
**D)** Security configuration

**Answer:** C
**Explanation:** Actuator provides endpoints like /health, /metrics, /env for monitoring and managing Boot applications in production.

---

### Q4.7: How are external configurations loaded in order of precedence?
**A)** application.properties, application.yml, environment variables
**B)** Environment variables, application.yml, application.properties
**C)** All treated equally
**D)** Alphabetical order

**Answer:** B
**Explanation:** Boot loads configurations in order: environment variables (highest), application.yml, then application.properties (lowest).

---

### Q4.8: What is the difference between server.port and management.server.port?
**A)** No difference
**B)** server.port is for the main app, management.server.port is for actuator endpoints
**C)** They must be the same
**D)** management.server.port is deprecated

**Answer:** B
**Explanation:** server.port configures the main web server port, while management.server.port configures a separate port for actuator management endpoints.

---

### Q4.9: How do you disable auto-configuration for a specific class?
**A)** @SpringBootApplication(exclude = SomeAutoConfig.class)
**B)** spring.autoconfigure.exclude property
**C)** Both A and B
**D)** Cannot be disabled

**Answer:** C
**Explanation:** Specific auto-configs can be excluded either via the annotation or via the spring.autoconfigure.exclude property.

---

### Q4.10: What is the purpose of application events in Boot?
**A)** Record application metrics
**B)** Trigger execution at certain lifecycle points
**C)** Create scheduled tasks
**D)** Handle HTTP events

**Answer:** B
**Explanation:** Application events (ApplicationStartedEvent, ContextRefreshedEvent, etc.) are published at specific lifecycle points and can be listened to with @EventListener.

---

## Chapter 5: Data Access & JPA (10 Questions)

### Q5.1: What does Spring Data JPA provide?
**A)** Hibernate ORM
**B)** Automatic repository implementation based on interfaces
**C)** Database connection pooling
**D)** SQL query language

**Answer:** B
**Explanation:** Spring Data JPA provides automatic CRUD repository implementations from simple interface declarations.

---

### Q5.2: How are query methods named in Spring Data repositories?
**A)** Any name works
**B)** Must follow specific conventions (findBy, getBy, readBy, queryBy, countBy, deleteBy)
**C)** Must match database column names
**D)** Must be explicitly annotated

**Answer:** B
**Explanation:** Spring Data uses method naming conventions like findByEmail, findByAgeGreaterThan to automatically generate queries.

---

### Q5.3: What is the N+1 query problem?
**A)** Performance issue when fetching N rows plus 1 aggregate query
**B)** 1 query fetches parents, then N queries fetch each parent's children
**C)** N queries are always slower than 1 query
**D)** A limitation of SQL that cannot be solved

**Answer:** B
**Explanation:** N+1 occurs when fetching parent entities with lazy-loaded collections causes N additional queries (one per parent).

---

### Q5.4: How can you solve the N+1 problem?
**A)** Eager loading with FetchType.EAGER
**B)** Using @EntityGraph or fetch joins
**C)** Batch loading configuration
**D)** All of the above

**Answer:** D
**Explanation:** Multiple solutions exist: @EntityGraph specifies join patterns, JPQL can use FETCH JOIN, or batch loading can group queries.

---

### Q5.5: What does @Transactional(readOnly = true) optimize?
**A)** Query execution speed
**B)** Removes change tracking overhead
**C)** Reduces network latency
**D)** Enables query caching

**Answer:** B
**Explanation:** readOnly=true tells Hibernate to skip change tracking (dirty checking), improving performance for read-only operations.

---

### Q5.6: What is Specifications API used for?
**A)** Defining bean specifications
**B)** Building dynamic queries at runtime
**C)** Specifying bean scopes
**D)** Database schema specifications

**Answer:** B
**Explanation:** JpaSpecificationExecutor enables building dynamic queries using Criteria API without needing method names for every query variant.

---

### Q5.7: How should relationships be typically loaded?
**A)** Eager loading for simplicity
**B)** Lazy loading for performance
**C)** Depends on access patterns
**D)** Spring decides automatically

**Answer:** C
**Explanation:** Choice depends on usage: lazy load large collections but eager load frequently accessed relationships.

---

### Q5.8: What is pagination in Spring Data?
**A)** Dividing results into pages
**B)** Defined using Pageable interface
**C)** Both A and B
**D)** Pagination is not supported

**Answer:** C
**Explanation:** Pageable interface supports pagination with page number, size, and sorting, returning Page<T> with metadata.

---

### Q5.9: What does @Query annotation allow?
**A)** Using custom JPQL or SQL queries
**B)** Specifying method naming conventions
**C)** Defining entity relationships
**D)** Mapping query results

**Answer:** A
**Explanation:** @Query allows writing custom JPQL or SQL queries when method naming conventions are insufficient.

---

### Q5.10: How are entity relationships defined in JPA?
**A)** @OneToMany, @ManyToOne, @ManyToMany
**B)** Through foreign keys in SQL
**C)** Automatically detected from database schema
**D)** Cannot be defined, must be manual

**Answer:** A
**Explanation:** JPA relationships are defined through annotations @OneToMany, @ManyToOne, @ManyToMany, @OneToOne with appropriate configuration.

---

## Chapter 6: REST APIs & Web Services (10 Questions)

### Q6.1: What does RESTful mean?
**A)** An API that uses HTTP
**B)** Representational State Transfer - using standard HTTP methods and URIs as resources
**C)** A real-time data service
**D)** Remote Execution Service

**Answer:** B
**Explanation:** REST is an architectural style using HTTP methods (GET, POST, PUT, DELETE) on resource URIs (e.g., /api/users/123).

---

### Q6.2: What HTTP status code indicates successful resource creation?
**A)** 200 OK
**B)** 201 Created
**C)** 202 Accepted
**D)** 204 No Content

**Answer:** B
**Explanation:** 201 Created indicates successful creation and typically includes the Location header with the new resource URL.

---

### Q6.3: Which status code is appropriate for a resource not found?
**A)** 400 Bad Request
**B)** 403 Forbidden
**C)** 404 Not Found
**D)** 500 Internal Server Error

**Answer:** C
**Explanation:** 404 Not Found indicates the requested resource doesn't exist.

---

### Q6.4: What is API versioning?
**A)** Version numbers in code
**B)** Tracking API changes over time
**C)** Both A and B
**D)** Not applicable to REST

**Answer:** C
**Explanation:** API versioning manages backward compatibility when APIs change, using URI paths (/v1/, /v2/), headers, or parameters.

---

### Q6.5: What is a DTO (Data Transfer Object)?
**A)** A database table definition
**B)** A simplified object for transferring data between layers
**C)** A persistence entity
**D)** A controller method

**Answer:** B
**Explanation:** DTOs are lightweight objects used to transfer data between client and server, avoiding direct exposure of entity objects.

---

### Q6.6: How should POST requests indicate the response location?
**A)** In the response body
**B)** In the Location header
**C)** As a query parameter
**D)** Cannot be indicated

**Answer:** B
**Explanation:** The Location header should contain the URI of the newly created resource, following REST conventions.

---

### Q6.7: What is content negotiation?
**A)** Negotiating API contracts
**B)** Determining response format (JSON, XML, etc.) based on Accept header
**C)** Caching content
**D)** Compressing response data

**Answer:** B
**Explanation:** Content negotiation uses the Accept header to determine which format (JSON, XML, etc.) to return to the client.

---

### Q6.8: What is OpenAPI/Swagger documentation for?
**A)** API authentication
**B)** Automatic API documentation and client generation
**C)** API rate limiting
**D)** API caching

**Answer:** B
**Explanation:** OpenAPI (Swagger) provides machine-readable API specifications enabling automatic documentation and client library generation.

---

### Q6.9: How should you handle validation errors in a REST API?
**A)** Return 500 error
**B)** Return 400 Bad Request with error details
**C)** Return 200 with error message
**D)** Ignore validation

**Answer:** B
**Explanation:** Validation errors should return 400 Bad Request with details about which fields failed validation.

---

### Q6.10: What is HATEOAS?
**A)** HTTP authentication
**B)** Including links to related resources in responses
**C)** Request timeout mechanism
**D)** API versioning strategy

**Answer:** B
**Explanation:** HATEOAS (Hypermedia As The Engine Of Application State) includes links to related resources, enabling API clients to discover endpoints dynamically.

---

## Chapter 7: Security & Authentication (10 Questions)

### Q7.1: What is the difference between authentication and authorization?
**A)** Authentication is faster
**B)** Authentication verifies identity, authorization checks permissions
**C)** They're the same thing
**D)** Authorization happens first

**Answer:** B
**Explanation:** Authentication answers "who are you?" (identity), authorization answers "what can you do?" (permissions).

---

### Q7.2: What does Spring Security filter chain do?
**A)** Filters HTTP responses
**B)** Applies security filters to requests before they reach controllers
**C)** Filters database queries
**D)** Caches security configurations

**Answer:** B
**Explanation:** SecurityFilterChain applies authentication, authorization, and protection filters to incoming requests.

---

### Q7.3: How are roles different from authorities in Spring Security?
**A)** They're the same
**B)** Roles are granted authorities with ROLE_ prefix
**C)** Roles are for users, authorities are for admins
**D)** Authorities are deprecated

**Answer:** B
**Explanation:** GrantedAuthority is the general interface; roles are a specific type starting with "ROLE_" prefix (e.g., ROLE_ADMIN).

---

### Q7.4: What does JWT token contain?
**A)** Only user ID
**B)** Header (algorithm), Payload (claims), Signature
**C)** Random token string
**D)** Encrypted password

**Answer:** B
**Explanation:** JWT has three base64-encoded parts separated by dots: header, payload (with claims), and HMAC signature.

---

### Q7.5: How are JWT tokens validated?
**A)** By looking up in database
**B)** By verifying signature and checking expiration
**C)** Tokens cannot be validated
**D)** Server must store all tokens

**Answer:** B
**Explanation:** JWT validation checks the signature (using secret key) and expiration claim without database lookup.

---

### Q7.6: What is OAuth2 used for?
**A)** Encrypting passwords
**B)** Authorization delegation (using third-party providers)
**C)** Rate limiting
**D)** API versioning

**Answer:** B
**Explanation:** OAuth2 enables users to authorize applications to access their resources on other services (e.g., "login with Google").

---

### Q7.7: What does @PreAuthorize annotation do?
**A)** Allows pre-loading of resources
**B)** Checks authorization before method execution
**C)** Marks methods as public
**D)** Pre-compiles authorization rules

**Answer:** B
**Explanation:** @PreAuthorize evaluates security expressions before the method runs, denying access if conditions aren't met.

---

### Q7.8: How are passwords safely stored?
**A)** Plaintext in database
**B)** Encrypted with reversible encryption
**C)** Hashed with bcrypt/argon2
**D)** Not stored at all

**Answer:** C
**Explanation:** Passwords should be hashed using bcrypt, scrypt, or argon2 - one-way functions preventing password recovery.

---

### Q7.9: What is CORS and why is it needed?
**A)** Secure request encoding
**B)** Allows cross-origin requests when explicitly configured
**C)** Caches remote resources
**D)** Compresses request bodies

**Answer:** B
**Explanation:** CORS (Cross-Origin Resource Sharing) allows browsers to make requests to domains other than the origin when configured.

---

### Q7.10: How does Spring Security determine the current user?
**A)** From session ID
**B)** From SecurityContext.getAuthentication()
**C)** From HTTP Basic header
**D)** Must be manually tracked

**Answer:** B
**Explanation:** SecurityContext (thread-local) holds the current Authentication, accessible via SecurityContextHolder.getContext().getAuthentication().

---

## Chapter 8: Transactions & Persistence (10 Questions)

### Q8.1: What does @Transactional do?
**A)** Makes a method transactional (all-or-nothing execution)
**B)** Improves performance
**C)** Prevents concurrent access
**D)** Enables caching

**Answer:** A
**Explanation:** @Transactional wraps method execution in a database transaction, rolling back on exceptions for atomicity.

---

### Q8.2: What is the default propagation behavior?
**A)** REQUIRES_NEW (always create new)
**B)** REQUIRED (use existing or create new)
**C)** NESTED (create savepoint)
**D)** NOT_SUPPORTED (no transaction)

**Answer:** B
**Explanation:** REQUIRED is the default; it uses an existing transaction or creates a new one if none exists.

---

### Q8.3: What does REQUIRES_NEW propagation do?
**A)** Reuses current transaction
**B)** Creates a new transaction, suspending the current one
**C)** Fails if no transaction exists
**D)** Does not support transactions

**Answer:** B
**Explanation:** REQUIRES_NEW creates a separate transaction with its own commit/rollback, independent from any outer transaction.

---

### Q8.4: What is optimistic locking?
**A)** Locking pessimistically
**B)** Using version fields to detect conflicts
**C)** Not locking at all
**D)** Database-level locks

**Answer:** B
**Explanation:** Optimistic locking uses a version field; updates fail if another transaction changed the row, signaled by OptimisticLockException.

---

### Q8.5: What is pessimistic locking?
**A)** Version-based conflict detection
**B)** Database-level locks while reading/updating
**C)** Not using locks
**D)** Optimistic approach

**Answer:** B
**Explanation:** Pessimistic locking acquires database locks (SELECT FOR UPDATE) to prevent concurrent modifications.

---

### Q8.6: What does rollbackFor attribute do?
**A)** Specifies which exceptions trigger rollback
**B)** Automatically rolls back all exceptions
**C)** Prevents rollback
**D)** Configures retry logic

**Answer:** A
**Explanation:** rollbackFor specifies exceptions that should trigger rollback; by default only unchecked exceptions cause rollback.

---

### Q8.7: What is a persistence context?
**A)** Context for persisting data
**B)** EntityManager's cache of loaded entities
**C)** Database connection
**D)** Transaction manager

**Answer:** B
**Explanation:** Persistence context is EntityManager's first-level cache, tracking loaded entities and detecting changes for updates.

---

### Q8.8: What does flush() do?
**A)** Discards all changes
**B)** Synchronizes persistence context changes to database
**C)** Clears the cache
**D)** Commits the transaction

**Answer:** B
**Explanation:** flush() executes pending INSERT/UPDATE/DELETE statements to synchronize changes with the database within the transaction.

---

### Q8.9: What is isolation level?
**A)** Isolates databases
**B)** Controls transaction visibility and prevents concurrency issues
**C)** Isolates transactions from Spring
**D)** Database backup isolation

**Answer:** B
**Explanation:** Isolation levels (READ_UNCOMMITTED, READ_COMMITTED, REPEATABLE_READ, SERIALIZABLE) control concurrency vs. consistency tradeoffs.

---

### Q8.10: When should you use readOnly = true?
**A)** Only for SELECT queries
**B)** Disables write operations
**C)** For read-only operations to optimize performance
**D)** Never

**Answer:** C
**Explanation:** readOnly=true disables change tracking and flushes, optimizing performance for queries that don't need to persist changes.

---

## Chapter 9: AOP & Cross-Cutting Concerns (8 Questions)

### Q9.1: What is AOP?
**A)** Aspect-Oriented Programming
**B)** Aspect-Oriented Protocol
**C)** Another Object Pattern
**D)** Application-oriented Programming

**Answer:** A
**Explanation:** AOP is a programming paradigm that separates cross-cutting concerns (logging, security, transactions) from business logic.

---

### Q9.2: What is a pointcut?
**A)** A method in an aspect
**B)** A pattern matching where advice should be applied
**C)** The result of applying advice
**D)** An annotation for aspects

**Answer:** B
**Explanation:** Pointcut is an expression that matches join points (usually methods) where advice should be applied.

---

### Q9.3: What does @Before advice do?
**A)** Runs after method execution
**B)** Runs before method execution
**C)** Prevents method execution
**D)** Modifies method arguments

**Answer:** B
**Explanation:** @Before advice executes before the matched method runs, useful for pre-processing or validation.

---

### Q9.4: What is @Around advice?
**A)** Runs around the application
**B)** Most flexible advice, wrapping method execution
**C)** Configures aspect scope
**D)** Applied to all methods

**Answer:** B
**Explanation:** @Around is the most flexible; it receives ProceedingJoinPoint and controls whether/when the method executes.

---

### Q9.5: What does ProceedingJoinPoint.proceed() do?
**A)** Proceeds to next advice
**B)** Executes the target method
**C)** Skips method execution
**D)** Returns method metadata

**Answer:** B
**Explanation:** proceed() actually invokes the wrapped method, allowing pre/post processing in @Around advice.

---

### Q9.6: How is AOP implemented in Spring?
**A)** Bytecode manipulation during compilation
**B)** Runtime proxies (JDK or CGLIB)
**C)** Modifying source code
**D)** Native language features

**Answer:** B
**Explanation:** Spring creates runtime proxies - JDK proxies for interfaces or CGLIB proxies for classes.

---

### Q9.7: When would you use @AfterThrowing?
**A)** To log exceptions
**B)** To handle exceptions
**C)** Both A and B
**D)** To prevent exceptions

**Answer:** C
**Explanation:** @AfterThrowing runs after exception is thrown, allowing logging, metrics, or recovery actions.

---

### Q9.8: What is weaving?
**A)** Combining aspects with target code
**B)** Spring framework feature
**C)** Serialization mechanism
**D)** Configuration process

**Answer:** A
**Explanation:** Weaving is the process of integrating advice into application code, done by Spring through runtime proxy creation.

---

## Chapter 10: Testing & Quality (8 Questions)

### Q10.1: What does @SpringBootTest do?
**A)** Tests only the web layer
**B)** Loads full ApplicationContext for integration testing
**C)** Mocks all dependencies
**D)** Tests boot configuration

**Answer:** B
**Explanation:** @SpringBootTest creates the full application context, suitable for integration tests of multiple components.

---

### Q10.2: What does @WebMvcTest do?
**A)** Tests the entire application
**B)** Tests only web layer with mocked services
**C)** Tests MVC configuration
**D)** Tests view rendering

**Answer:** B
**Explanation:** @WebMvcTest is lightweight, testing only controllers with mocked services, perfect for unit testing controllers.

---

### Q10.3: What is MockMvc used for?
**A)** Mocking HTTP clients
**B)** Testing web controllers without server startup
**C)** Mocking databases
**D)** Testing services

**Answer:** B
**Explanation:** MockMvc simulates HTTP requests and tests controller responses without starting an embedded server.

---

### Q10.4: How do you verify a method was called in Mockito?
**A)** verify(mock).method()
**B)** assertCalled(mock)
**C)** mock.verifyCall()
**D)** Mockito doesn't support verification

**Answer:** A
**Explanation:** verify() in Mockito confirms a method was called, optionally with specific arguments or call counts.

---

### Q10.5: What is the difference between @Mock and @InjectMocks?
**A)** No difference
**B)** @Mock creates mocks; @InjectMocks injects mocks into tested class
**C)** @InjectMocks is deprecated
**D)** They're for different frameworks

**Answer:** B
**Explanation:** @Mock creates mocked instances; @InjectMocks automatically injects them into the class under test.

---

### Q10.6: How should you test @Transactional methods?
**A)** Regular unit tests
**B)** Integration tests with @SpringBootTest and database
**C)** Service layer mocking
**D)** Not testable

**Answer:** B
**Explanation:** @Transactional requires a real database and transaction manager; use @SpringBootTest with test databases (H2).

---

### Q10.7: What is a test fixture?
**A)** Testing framework
**B)** Setup/teardown data and state for tests
**C)** Test assertion library
**D)** Test execution engine

**Answer:** B
**Explanation:** Test fixtures are the setup (data, mocks) and teardown code that prepares tests to run consistently.

---

### Q10.8: How do you verify behavior in tests?
**A)** assertEquals on return values
**B)** verify() for mock interactions
**C)** Both A and B
**D)** Through logging

**Answer:** C
**Explanation:** Tests verify behavior by asserting on return values and verifying mock interactions using verify().

---

## Chapter 11: Performance & Optimization (8 Questions)

### Q11.1: What does @Cacheable do?
**A)** Marks a method for caching
**B)** Caches result if not in cache, returns cached value otherwise
**C)** Prevents caching
**D)** Clears cache

**Answer:** B
**Explanation:** @Cacheable checks cache first; if value exists, returns it; otherwise executes method and caches result.

---

### Q11.2: What does @CachePut do?
**A)** Retrieves from cache
**B)** Always executes method and updates cache
**C)** Conditionally caches
**D)** Deletes from cache

**Answer:** B
**Explanation:** @CachePut always executes the method and updates the cache, useful for updates that should refresh cached data.

---

### Q11.3: What does @CacheEvict do?
**A)** Adds to cache
**B)** Removes from cache
**C)** Reads from cache
**D)** Configures cache

**Answer:** B
**Explanation:** @CacheEvict removes entries from cache, useful after deletions or updates that invalidate cached data.

---

### Q11.4: What is lazy loading?
**A)** Delaying loading until data is needed
**B)** Loading all data at once
**C)** Preloading cache
**D)** Asynchronous loading

**Answer:** A
**Explanation:** Lazy loading delays loading related data until accessed, reducing initial query size but causing N+1 problems if not careful.

---

### Q11.5: How can you optimize database queries?
**A)** Using indexes
**B)** Fetch joins and entity graphs
**C)** Query result pagination
**D)** All of the above

**Answer:** D
**Explanation:** Database optimization involves multiple strategies: indexes, fetch joins, pagination, and query specificity.

---

### Q11.6: What is @Async used for?
**A)** Synchronous processing
**B)** Asynchronous method execution in background threads
**C)** Async HTTP requests
**D)** Configuration

**Answer:** B
**Explanation:** @Async makes methods execute in background thread pools, returning CompletableFuture/Future for async results.

---

### Q11.7: How should you handle many-to-many relationships for performance?
**A)** Always eager load
**B)** Always lazy load
**C)** Use @EntityGraph to specify fetch strategy
**D)** Avoid many-to-many relationships

**Answer:** C
**Explanation:** @EntityGraph allows specifying which relationships to eagerly load, avoiding N+1 while preventing unnecessary joins.

---

### Q11.8: What is connection pooling?
**A)** Sharing single database connection
**B)** Reusing database connections from a pool
**C)** Pooling HTTP connections
**D)** Memory pooling

**Answer:** B
**Explanation:** Connection pooling maintains a pool of reusable connections, reducing overhead of creating new connections per request.

---

## Chapter 12: Cloud & Microservices (8 Questions)

### Q12.1: What is service discovery?
**A)** Finding bugs in services
**B)** Automatically locating service instances
**C)** Discovering API endpoints
**D)** Service monitoring

**Answer:** B
**Explanation:** Service discovery (Eureka, Consul, Kubernetes) automatically registers and locates service instances as they scale.

---

### Q12.2: What does a circuit breaker prevent?
**A)** Electrical failures
**B)** Cascading failures when services fail
**C)** Network timeouts
**D)** All network issues

**Answer:** B
**Explanation:** Circuit breaker prevents cascading failures by stopping requests to failing services, returning fast failures instead.

---

### Q12.3: What are the circuit breaker states?
**A)** Active, Inactive
**B)** Closed (normal), Open (failing), Half-open (testing)
**C)** Success, Failure
**D)** Start, Stop

**Answer:** B
**Explanation:** Circuit breakers have three states: CLOSED (normal flow), OPEN (reject requests), HALF_OPEN (testing recovery).

---

### Q12.4: What is Feign client?
**A)** HTTP client library
**B)** Declarative REST client for inter-service communication
**C)** Service registry
**D)** API gateway

**Answer:** B
**Explanation:** Feign provides declarative REST client interfaces, automatically implementing HTTP communication between services.

---

### Q12.5: What does Spring Cloud Config do?
**A)** Spring configuration
**B)** Centralized external configuration for distributed systems
**C)** Application configuration
**D)** Bean configuration

**Answer:** B
**Explanation:** Spring Cloud Config Server provides centralized, versioned configuration for microservices, enabling dynamic updates.

---

### Q12.6: What is observability?
**A)** Ability to observe code
**B)** Metrics, logs, and traces for understanding system behavior
**C)** System monitoring
**D)** API documentation

**Answer:** B
**Explanation:** Observability through metrics, logs, and traces enables understanding system behavior, debugging issues, and performance analysis.

---

### Q12.7: What is distributed tracing?
**A)** Tracing distributed memory
**B)** Following requests across multiple services
**C)** Network tracing
**D)** File tracing

**Answer:** B
**Explanation:** Distributed tracing (OpenTelemetry, Jaeger) follows requests through multiple services, showing latency and failure points.

---

### Q12.8: What is an API gateway?
**A)** RESTful API
**B)** Entry point for microservices, handling routing, authentication, rate limiting
**C)** Database gateway
**D)** Service discovery

**Answer:** B
**Explanation:** API Gateway (Spring Cloud Gateway) serves as single entry point, routing requests to microservices and providing cross-cutting concerns.

---

## Score Summary

- **Total Questions:** 136
- **Questions per Chapter:** 8-10
- **Difficulty Levels:** Basic, Intermediate, Advanced mixed throughout
- **Self-Paced:** Take at your own pace, track scores for weak areas

---

**Instructions for Self-Assessment:**

1. **Time Limit:** 30 seconds per question
2. **Honest Answers:** Answer without looking at solutions first
3. **Track Results:** Note which areas need more study
4. **Review:** Re-read chapters for questions you miss
5. **Progress:** Track your scores across chapters

**Recommended Study Pattern:**
- Chapter quiz → Review notes → Conceptual questions → Real problems → Interview prep

---

**Last Updated:** October 25, 2024
**Total Content:** 10 quizzes covering all 12 chapters
