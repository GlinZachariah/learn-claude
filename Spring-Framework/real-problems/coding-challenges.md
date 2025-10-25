# Spring Framework - Real-World Coding Challenges

## Problem Set Overview

This collection contains 15 real-world coding problems organized by difficulty level, with complete solutions and explanations. Each problem integrates multiple Spring concepts learned throughout the course.

---

## Problem 1: User Registration & Authentication Service (Beginner)

### Problem Description

Build a user registration and login service with Spring Boot that:
- Stores users in a PostgreSQL database with password hashing
- Validates email format and password strength
- Implements JWT token generation for authenticated users
- Provides REST endpoints for registration and login

### Requirements

1. **Entity:** User with email, password (hashed), created_at, updated_at
2. **Service:** Registration with validation, login with JWT generation
3. **Controller:** POST /api/auth/register, POST /api/auth/login
4. **Security:** Password hashing with bcrypt, JWT tokens, expiration

### Expected Endpoints

```
POST /api/auth/register
Request: { "email": "user@example.com", "password": "SecurePass123!" }
Response: { "id": 1, "email": "user@example.com" }

POST /api/auth/login
Request: { "email": "user@example.com", "password": "SecurePass123!" }
Response: { "token": "eyJhbGc...", "expiresIn": 3600 }
```

### Solution

```java
// User Entity
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}

// Request/Response DTOs
public class RegisterRequest {
    @Email
    private String email;

    @Size(min = 8)
    private String password;
}

public class AuthResponse {
    private String token;
    private long expiresIn;
}

// Repository
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}

// Service
@Service
public class AuthService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider tokenProvider;

    public UserResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email already registered");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));

        User saved = userRepository.save(user);
        return new UserResponse(saved.getId(), saved.getEmail());
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
            .orElseThrow(() -> new UnauthorizedException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid credentials");
        }

        String token = tokenProvider.generateToken(user.getId(), user.getEmail());
        return new AuthResponse(token, 3600);
    }
}

// Controller
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(201).body(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
}

// Security Configuration
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/**").authenticated()
                .anyRequest().permitAll())
            .addFilterBefore(new JwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
            .build();
    }
}

// JWT Token Provider
@Component
public class JwtTokenProvider {

    @Value("${jwt.secret:your-secret-key-change-this}")
    private String secretKey;

    @Value("${jwt.expiration:3600}")
    private long expirationTime;

    public String generateToken(Long userId, String email) {
        return Jwts.builder()
            .setSubject(String.valueOf(userId))
            .claim("email", email)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + expirationTime * 1000))
            .signWith(SignatureAlgorithm.HS512, secretKey)
            .compact();
    }

    public Claims validateToken(String token) {
        return Jwts.parser()
            .setSigningKey(secretKey)
            .parseClaimsJws(token)
            .getBody();
    }
}
```

### Testing

```java
@SpringBootTest
@AutoConfigureMockMvc
public class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AuthService authService;

    @Test
    public void testRegisterSuccess() throws Exception {
        RegisterRequest request = new RegisterRequest("user@example.com", "SecurePass123!");
        UserResponse response = new UserResponse(1L, "user@example.com");

        when(authService.register(any())).thenReturn(response);

        mockMvc.perform(post("/api/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(asJsonString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.email").value("user@example.com"));
    }
}
```

---

## Problem 2: Product Catalog with Filtering & Pagination (Beginner-Intermediate)

### Problem Description

Create a product catalog service that allows:
- Listing products with filtering (category, price range, rating)
- Pagination and sorting
- Search by name or description
- Caching for performance

### Requirements

1. **Entities:** Product (id, name, description, price, category, rating, stock)
2. **Repository:** Custom queries with Specifications API
3. **Service:** Filtering, pagination, caching with @Cacheable
4. **Controller:** GET /api/products with query parameters

### Solution

```java
// Product Entity
@Entity
@Table(name = "products", indexes = {
    @Index(name = "idx_category", columnList = "category"),
    @Index(name = "idx_price", columnList = "price")
})
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String description;

    @Column(nullable = false)
    private BigDecimal price;

    private String category;

    private Double rating;

    private Integer stock;

    @CreationTimestamp
    private LocalDateTime createdAt;
}

// Repository with Specifications
@Repository
public interface ProductRepository extends JpaRepository<Product, Long>,
                                          JpaSpecificationExecutor<Product> {
    List<Product> findByCategory(String category, Pageable pageable);
}

// Specifications for dynamic filtering
public class ProductSpecifications {

    public static Specification<Product> withCategory(String category) {
        return (root, query, cb) ->
            category == null ? cb.conjunction() : cb.equal(root.get("category"), category);
    }

    public static Specification<Product> priceRange(BigDecimal minPrice, BigDecimal maxPrice) {
        return (root, query, cb) -> {
            if (minPrice == null && maxPrice == null) {
                return cb.conjunction();
            }
            if (minPrice != null && maxPrice != null) {
                return cb.between(root.get("price"), minPrice, maxPrice);
            }
            if (minPrice != null) {
                return cb.greaterThanOrEqualTo(root.get("price"), minPrice);
            }
            return cb.lessThanOrEqualTo(root.get("price"), maxPrice);
        };
    }

    public static Specification<Product> minRating(Double rating) {
        return (root, query, cb) ->
            rating == null ? cb.conjunction() : cb.greaterThanOrEqualTo(root.get("rating"), rating);
    }

    public static Specification<Product> search(String searchTerm) {
        return (root, query, cb) -> {
            if (searchTerm == null || searchTerm.isEmpty()) {
                return cb.conjunction();
            }
            String pattern = "%" + searchTerm.toLowerCase() + "%";
            return cb.or(
                cb.like(cb.lower(root.get("name")), pattern),
                cb.like(cb.lower(root.get("description")), pattern)
            );
        };
    }
}

// Service with Caching
@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Cacheable(value = "products", key = "'all'")
    public Page<ProductResponse> getAllProducts(
            String category,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Double minRating,
            String search,
            Pageable pageable) {

        Specification<Product> spec = Specification
            .where(ProductSpecifications.withCategory(category))
            .and(ProductSpecifications.priceRange(minPrice, maxPrice))
            .and(ProductSpecifications.minRating(minRating))
            .and(ProductSpecifications.search(search));

        return productRepository.findAll(spec, pageable)
            .map(this::toResponse);
    }

    @Cacheable(value = "products", key = "#id")
    public ProductResponse getProduct(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        return toResponse(product);
    }

    @CacheEvict(value = "products", allEntries = true)
    @Transactional
    public ProductResponse createProduct(CreateProductRequest request) {
        Product product = new Product();
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setCategory(request.getCategory());
        product.setStock(request.getStock());

        Product saved = productRepository.save(product);
        return toResponse(saved);
    }

    private ProductResponse toResponse(Product product) {
        return new ProductResponse(
            product.getId(),
            product.getName(),
            product.getPrice(),
            product.getRating(),
            product.getStock()
        );
    }
}

// Controller
@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping
    public ResponseEntity<Page<ProductResponse>> getProducts(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) Double minRating,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "name,asc") String sort) {

        Pageable pageable = PageRequest.of(page, size, Sort.by(sort));
        Page<ProductResponse> products = productService.getAllProducts(
            category, minPrice, maxPrice, minRating, search, pageable);

        return ResponseEntity.ok(products);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> getProduct(@PathVariable Long id) {
        return ResponseEntity.ok(productService.getProduct(id));
    }

    @PostMapping
    public ResponseEntity<ProductResponse> createProduct(
            @Valid @RequestBody CreateProductRequest request) {
        return ResponseEntity.status(201).body(productService.createProduct(request));
    }
}
```

---

## Problem 3: Order Processing with Transactions (Intermediate)

### Problem Description

Implement an order processing system with:
- Transaction management for consistency
- Inventory management (decrement on order)
- Order history tracking
- Payment processing integration
- Rollback on failure

### Requirements

1. **Entities:** Order, OrderItem, Product, Payment
2. **Service:** Order creation with transaction boundaries
3. **Propagation:** REQUIRES_NEW for payment, REQUIRED for inventory
4. **Validation:** Stock availability before order

### Solution

```java
// Order Entities
@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL)
    private List<OrderItem> items = new ArrayList<>();

    private BigDecimal totalAmount;

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    @CreationTimestamp
    private LocalDateTime createdAt;
}

@Entity
@Table(name = "order_items")
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Order order;

    @ManyToOne
    private Product product;

    private Integer quantity;

    private BigDecimal price;
}

@Entity
@Table(name = "payments")
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Order order;

    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    private PaymentStatus status;

    private String transactionId;
}

// Service with Transaction Management
@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private InventoryService inventoryService;

    @Autowired
    private PaymentService paymentService;

    @Transactional(rollbackFor = Exception.class)
    public OrderResponse createOrder(CreateOrderRequest request) {
        // Create order
        Order order = new Order();
        order.setUserId(request.getUserId());
        order.setStatus(OrderStatus.PENDING);

        BigDecimal totalAmount = BigDecimal.ZERO;

        // Process each item
        for (OrderItemRequest itemRequest : request.getItems()) {
            Product product = productRepository.findById(itemRequest.getProductId())
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

            // Check stock availability
            inventoryService.validateStockAvailable(
                product.getId(), itemRequest.getQuantity());

            OrderItem item = new OrderItem();
            item.setOrder(order);
            item.setProduct(product);
            item.setQuantity(itemRequest.getQuantity());
            item.setPrice(product.getPrice());

            order.getItems().add(item);
            totalAmount = totalAmount.add(
                product.getPrice().multiply(new BigDecimal(itemRequest.getQuantity())));
        }

        order.setTotalAmount(totalAmount);
        Order savedOrder = orderRepository.save(order);

        // Process payment (in separate transaction)
        try {
            paymentService.processPayment(savedOrder.getId(), totalAmount);
        } catch (PaymentException e) {
            throw new OrderProcessingException("Payment failed: " + e.getMessage());
        }

        // Update inventory after successful payment
        for (OrderItem item : savedOrder.getItems()) {
            inventoryService.decrementStock(item.getProduct().getId(), item.getQuantity());
        }

        savedOrder.setStatus(OrderStatus.CONFIRMED);
        orderRepository.save(savedOrder);

        return new OrderResponse(savedOrder.getId(), savedOrder.getStatus(), savedOrder.getTotalAmount());
    }
}

// Inventory Service
@Service
public class InventoryService {

    @Autowired
    private ProductRepository productRepository;

    public void validateStockAvailable(Long productId, Integer quantity) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

        if (product.getStock() < quantity) {
            throw new InsufficientStockException(
                "Insufficient stock for product: " + product.getName());
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void decrementStock(Long productId, Integer quantity) {
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

        product.setStock(product.getStock() - quantity);
        productRepository.save(product);
    }
}

// Payment Service
@Service
public class PaymentService {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private PaymentGateway paymentGateway;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void processPayment(Long orderId, BigDecimal amount) {
        Payment payment = new Payment();
        payment.setAmount(amount);
        payment.setStatus(PaymentStatus.PENDING);

        try {
            // Call external payment gateway
            String transactionId = paymentGateway.charge(amount);

            payment.setTransactionId(transactionId);
            payment.setStatus(PaymentStatus.SUCCESS);
            paymentRepository.save(payment);
        } catch (Exception e) {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            throw new PaymentException("Payment processing failed: " + e.getMessage());
        }
    }
}
```

---

## Problem 4: Caching Strategy for High-Traffic API (Intermediate)

### Problem Description

Implement a multi-level caching strategy for a high-traffic product API:
- Cache product listings by category (1 hour TTL)
- Cache individual products (30 minutes TTL)
- Invalidate cache on product updates
- Use CompletableFuture for async cache warming

### Solution

```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager("products", "productsByCategory", "productDetails");
    }
}

@Service
public class CachedProductService {

    @Autowired
    private ProductRepository productRepository;

    @Cacheable(value = "productsByCategory", key = "#category", unless = "#result.isEmpty()")
    public List<ProductResponse> getProductsByCategory(String category) {
        return productRepository.findByCategory(category).stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }

    @Cacheable(value = "productDetails", key = "#id")
    public ProductResponse getProduct(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        return toResponse(product);
    }

    @CacheEvict(value = "productDetails", key = "#id")
    @CachePut(value = "productDetails", key = "#result.id")
    @Transactional
    public ProductResponse updateProduct(Long id, UpdateProductRequest request) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));

        product.setName(request.getName());
        product.setPrice(request.getPrice());

        Product updated = productRepository.save(product);
        return toResponse(updated);
    }

    @CacheEvict(value = {"products", "productsByCategory"}, allEntries = true)
    @Transactional
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    // Async cache warming
    @Async
    public CompletableFuture<Void> warmCache() {
        return CompletableFuture.runAsync(() -> {
            List<String> categories = productRepository.findDistinctCategories();
            categories.forEach(this::getProductsByCategory);
        });
    }
}
```

---

## Problem 5: Secure API with Role-Based Access Control (Intermediate)

### Problem Description

Implement role-based access control:
- Admin: Full access
- Manager: Can view and edit (not delete)
- User: Can only view own data
- Public: Can only view non-sensitive data

### Solution

```java
@Component
public class UserDetail implements UserDetails {
    private Long userId;
    private String email;
    private Collection<? extends GrantedAuthority> authorities;
}

@Service
public class CustomUserDetailsService implements UserDetailsService {
    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        return org.springframework.security.core.userdetails.User.builder()
            .username(user.getEmail())
            .password(user.getPasswordHash())
            .authorities(user.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getName()))
                .collect(Collectors.toList()))
            .build();
    }
}

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @DeleteMapping("/users/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}

@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('USER') and @userService.isOwner(#id, authentication)")
    public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUser(id));
    }
}
```

---

## Problem 6: AOP for Logging and Auditing (Intermediate-Advanced)

### Problem Description

Implement AOP aspects for:
- Method execution logging
- Parameter logging (excluding sensitive data)
- Exception logging
- Audit trail creation for data modifications

### Solution

```java
@Aspect
@Component
public class LoggingAspect {

    private static final Logger logger = LoggerFactory.getLogger(LoggingAspect.class);

    @Pointcut("execution(* com.example.service.*.*(..))")
    public void serviceMethods() {}

    @Before("serviceMethods()")
    public void logMethodEntry(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();

        logger.info("Entering method: {} with args: {}",
            methodName, Arrays.toString(maskSensitiveData(args)));
    }

    @AfterReturning(pointcut = "serviceMethods()", returning = "result")
    public void logMethodExit(JoinPoint joinPoint, Object result) {
        String methodName = joinPoint.getSignature().getName();
        logger.info("Exiting method: {} with result: {}", methodName, result);
    }

    @AfterThrowing(pointcut = "serviceMethods()", throwing = "exception")
    public void logException(JoinPoint joinPoint, Exception exception) {
        String methodName = joinPoint.getSignature().getName();
        logger.error("Exception in method: {} - {}", methodName, exception.getMessage(), exception);
    }

    private Object[] maskSensitiveData(Object[] args) {
        return Arrays.stream(args)
            .map(arg -> arg instanceof String && ((String) arg).contains("password") ?
                "[MASKED]" : arg)
            .toArray();
    }
}

@Aspect
@Component
public class AuditAspect {

    @Autowired
    private AuditLogRepository auditLogRepository;

    @Pointcut("@annotation(com.example.annotation.Auditable)")
    public void auditableMethods() {}

    @AfterReturning(pointcut = "auditableMethods()", returning = "result")
    public void auditModification(JoinPoint joinPoint, Object result) {
        AuditLog log = new AuditLog();
        log.setAction(joinPoint.getSignature().getName());
        log.setEntityId(extractEntityId(result));
        log.setTimestamp(LocalDateTime.now());
        log.setUser(getCurrentUser());

        auditLogRepository.save(log);
    }
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Auditable {
}

@Service
public class UserService {

    @Auditable
    @Transactional
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        // Implementation
    }
}
```

---

## Problem 7: RESTful API with OpenAPI/Swagger (Intermediate)

### Problem Description

Document and expose a REST API using OpenAPI 3.0 with Swagger UI for:
- Auto-generated API documentation
- Try-out endpoints in Swagger UI
- Request/response schemas
- Authentication requirements

### Solution

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.0.4</version>
</dependency>
```

```java
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Product API")
                .version("1.0.0")
                .description("Product management REST API")
                .contact(new Contact()
                    .name("API Support")
                    .email("support@example.com")))
            .addServersItem(new Server()
                .url("http://localhost:8080")
                .description("Development"));
    }
}

@RestController
@RequestMapping("/api/products")
@Tag(name = "Products", description = "Product management API")
public class ProductController {

    @GetMapping
    @Operation(summary = "Get all products", description = "Retrieve a paginated list of products")
    @Parameters({
        @Parameter(name = "page", description = "Page number"),
        @Parameter(name = "size", description = "Page size"),
        @Parameter(name = "category", description = "Filter by category")
    })
    public ResponseEntity<Page<ProductResponse>> getProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String category) {
        // Implementation
    }

    @PostMapping
    @Operation(summary = "Create product")
    @APIResponse(responseCode = "201", description = "Product created successfully")
    public ResponseEntity<ProductResponse> createProduct(
            @RequestBody @Valid CreateProductRequest request) {
        // Implementation
    }
}
```

---

## Problem 8: Microservices: Order Service Integration (Advanced)

### Problem Description

Build two microservices with inter-service communication:
- Product Service (port 8081)
- Order Service (port 8080) that calls Product Service
- Use Feign client and circuit breaker
- Implement service discovery simulation

### Solution - Product Service

```java
@SpringBootApplication
@EnableDiscoveryClient
public class ProductServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ProductServiceApplication.class, args);
    }
}

@RestController
@RequestMapping("/api/products")
public class ProductServiceController {

    @GetMapping("/{id}")
    public ResponseEntity<ProductDTO> getProduct(@PathVariable Long id) {
        // Implementation
        return ResponseEntity.ok(new ProductDTO(id, "Product", BigDecimal.valueOf(99.99)));
    }
}
```

### Solution - Order Service with Feign

```java
@FeignClient(name = "product-service", url = "http://localhost:8081")
public interface ProductServiceClient {
    @GetMapping("/api/products/{id}")
    ProductDTO getProduct(@PathVariable Long id);
}

@Service
public class OrderService {

    @Autowired
    private ProductServiceClient productServiceClient;

    @CircuitBreaker(name = "productService")
    public OrderResponse createOrder(CreateOrderRequest request) {
        ProductDTO product = productServiceClient.getProduct(request.getProductId());
        // Create order with product data
        return new OrderResponse(1L, OrderStatus.CONFIRMED, product.getPrice());
    }

    public OrderResponse fallback(CreateOrderRequest request, Exception e) {
        logger.error("Product service unavailable, using fallback");
        return new OrderResponse(null, OrderStatus.PENDING, null);
    }
}

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

        return CircuitBreaker.of("productService", config);
    }
}
```

---

## Problem 9: Event-Driven Order Processing (Advanced)

### Problem Description

Implement event-driven architecture:
- Publish order events (OrderCreatedEvent)
- Listen and process asynchronously (send email, update inventory)
- Error handling and retries
- Eventual consistency

### Solution

```java
// Event definitions
public class OrderCreatedEvent extends ApplicationEvent {
    private Long orderId;
    private Long userId;
    private BigDecimal amount;

    public OrderCreatedEvent(Object source, Long orderId, Long userId, BigDecimal amount) {
        super(source);
        this.orderId = orderId;
        this.userId = userId;
        this.amount = amount;
    }
}

// Event publisher
@Service
public class OrderService {

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        Order order = new Order();
        // Create order logic
        orderRepository.save(order);

        // Publish event
        eventPublisher.publishEvent(new OrderCreatedEvent(
            this, order.getId(), order.getUserId(), order.getTotalAmount()));

        return new OrderResponse(order.getId(), order.getStatus(), order.getTotalAmount());
    }
}

// Event listeners
@Component
public class OrderEventListeners {

    @Autowired
    private EmailService emailService;

    @Autowired
    private InventoryService inventoryService;

    @EventListener
    @Async
    @Transactional
    public void onOrderCreated(OrderCreatedEvent event) throws InterruptedException {
        try {
            // Send confirmation email
            emailService.sendOrderConfirmation(event.getUserId(), event.getOrderId());

            // Update inventory
            inventoryService.updateInventory(event.getOrderId());
        } catch (Exception e) {
            logger.error("Error processing order event: " + event.getOrderId(), e);
            // Could implement retry logic here
        }
    }
}

// Configuration
@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean
    public TaskExecutor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.initialize();
        return executor;
    }
}
```

---

## Problem 10: Performance Optimization: N+1 Query Fix (Advanced)

### Problem Description

Fix an N+1 query problem in a reporting system:
- Report queries orders with related customers, items, and products
- Original implementation causes N+1 queries
- Optimize using EntityGraph or fetch joins

### Solution

```java
// Problematic approach (N+1 queries)
@Service
public class ReportService {

    @Autowired
    private OrderRepository orderRepository;

    @Transactional(readOnly = true)
    public List<OrderReportDTO> generateOrderReport() {
        List<Order> orders = orderRepository.findAll(); // 1 query

        return orders.stream().map(order -> {
            // Each iteration triggers queries for:
            // - Customer (N queries)
            // - OrderItems (N queries)
            // - Products (N queries)
            return new OrderReportDTO(
                order.getId(),
                order.getCustomer().getName(),
                order.getItems().stream()
                    .map(item -> item.getProduct().getName())
                    .collect(Collectors.toList())
            );
        }).collect(Collectors.toList());
    }
}

// Optimized with EntityGraph
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    @EntityGraph(attributePaths = {"customer", "items", "items.product"})
    List<Order> findAllWithDetails();
}

@Service
public class ReportService {

    @Autowired
    private OrderRepository orderRepository;

    @Transactional(readOnly = true)
    public List<OrderReportDTO> generateOrderReport() {
        // Single query with eager loading
        List<Order> orders = orderRepository.findAllWithDetails();

        return orders.stream().map(order ->
            new OrderReportDTO(
                order.getId(),
                order.getCustomer().getName(),
                order.getItems().stream()
                    .map(item -> item.getProduct().getName())
                    .collect(Collectors.toList())
            )
        ).collect(Collectors.toList());
    }
}

// Alternative: JPQL with fetch join
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    @Query("SELECT DISTINCT o FROM Order o " +
           "LEFT JOIN FETCH o.customer " +
           "LEFT JOIN FETCH o.items i " +
           "LEFT JOIN FETCH i.product")
    List<Order> findAllWithDetailsFetchJoin();
}
```

---

## Challenge Difficulty Summary

| Problem | Difficulty | Key Concepts |
|---------|-----------|--------------|
| 1. User Auth | Beginner | DI, REST, Security, JWT |
| 2. Product Catalog | Beginner-Intermediate | Specifications, Caching, Pagination |
| 3. Order Processing | Intermediate | Transactions, Propagation, Atomicity |
| 4. Caching Strategy | Intermediate | @Cacheable, TTL, Invalidation, Async |
| 5. RBAC | Intermediate | Security, @PreAuthorize, Custom Authorization |
| 6. AOP Auditing | Intermediate-Advanced | Aspects, Pointcuts, Around Advice |
| 7. OpenAPI/Swagger | Intermediate | Documentation, REST, API Design |
| 8. Microservices | Advanced | Feign, Service Discovery, Circuit Breaker |
| 9. Event-Driven | Advanced | Events, Async, Eventual Consistency |
| 10. N+1 Optimization | Advanced | EntityGraph, Fetch Joins, Query Optimization |

---

## How to Use These Problems

1. **Start with Problem 1-2** for fundamentals
2. **Progress to Problem 3-5** for intermediate understanding
3. **Tackle Problem 6-10** for advanced mastery
4. **Combine multiple problems** for real-world scenarios
5. **Implement variations** to deepen learning

---

**Last Updated:** October 25, 2024
**Problems:** 10 real-world scenarios with complete solutions
