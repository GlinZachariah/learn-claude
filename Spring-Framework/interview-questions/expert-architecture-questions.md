# Spring Framework - Expert Architecture Questions

## For Architects, Tech Leads, and Senior Engineers (8+ years)

This document contains 25+ advanced architectural questions addressing real-world system design challenges at enterprise scale.

---

## Section 1: System Design & Scalability

### Q1: Design a globally distributed e-commerce platform serving 100M+ users across 5 continents.

**Context:** You're architecting a Spring-based e-commerce system handling:
- 100M+ monthly active users
- Peak traffic: 1M concurrent users
- Multi-region deployment (US, EU, APAC, etc.)
- Multiple payment methods
- Real-time inventory across warehouses

**Architecture Considerations:**

```java
// 1. API Gateway Pattern with Load Balancing
@Configuration
public class GatewayConfiguration {

    @Bean
    public RouteLocator routes(RouteLocatorBuilder builder) {
        return builder.routes()
            // Geographic routing
            .route("product-service-us", r -> r
                .path("/api/products/**")
                .and()
                .header("X-Region", "US")
                .uri("lb://product-service-us"))
            .route("product-service-eu", r -> r
                .path("/api/products/**")
                .and()
                .header("X-Region", "EU")
                .uri("lb://product-service-eu"))
            .build();
    }
}

// 2. Distributed Caching Strategy
@Configuration
public class CacheStrategy {

    @Bean
    public CacheManager cacheManager() {
        // Primary: Redis cluster for hot data (1 hour TTL)
        // Secondary: Local cache for frequently accessed (5 min TTL)
        // Tertiary: CDN for static content
        return RedisCacheManager.create(redisClusterFactory);
    }

    // Cache warming strategy
    @Scheduled(fixedDelay = 3600000) // Every hour
    public void warmCache() {
        // Pre-load popular products, categories
        // Refresh trending items
        // Update regional pricing
    }
}

// 3. Event-Driven Architecture for Inventory Sync
@Component
public class InventoryEventPublisher {

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @Transactional
    public void reserveInventory(InventoryReservationRequest request) {
        // Reserve inventory locally
        Inventory inventory = inventoryRepository.findBySkuForUpdate(request.getSku());
        inventory.reserve(request.getQuantity());
        inventoryRepository.save(inventory);

        // Publish event for other regions
        eventPublisher.publishEvent(
            new InventoryReservedEvent(request.getSku(), request.getQuantity()));
    }
}

@Component
public class InventoryEventListener {

    @EventListener
    @Async
    public void onInventoryReserved(InventoryReservedEvent event) {
        // Sync inventory across regions
        kafkaTemplate.send("inventory-sync-topic", event);
    }
}

// 4. Data Consistency Strategy
@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private InventorySaga inventorySaga;

    @Transactional(propagation = Propagation.REQUIRES_NEW, timeout = 30)
    public OrderResponse createOrder(CreateOrderRequest request) {
        // Step 1: Create order in local region
        Order order = createOrderLocally(request);

        try {
            // Step 2: Reserve inventory (saga pattern)
            inventorySaga.reserveInventory(order.getId(), request.getItems());

            // Step 3: Process payment with retry
            paymentService.processPaymentWithRetry(order.getId(), request.getAmount());

            order.setStatus(OrderStatus.CONFIRMED);
            orderRepository.save(order);

            // Step 4: Publish order event for replicas
            publishOrderConfirmedEvent(order);

            return new OrderResponse(order.getId(), OrderStatus.CONFIRMED);

        } catch (InventoryUnavailableException e) {
            compensatingTransaction.rollbackOrder(order.getId());
            throw e;
        }
    }
}

// 5. Read Replicas and CQRS Pattern
@Service
public class ProductQueryService {

    @Autowired
    private ProductReadRepository readRepository; // Read replica

    @Cacheable(value = "products", key = "#id")
    public ProductDTO getProduct(Long id) {
        // Query from read replica
        return readRepository.findById(id);
    }
}

@Service
public class ProductCommandService {

    @Autowired
    private ProductWriteRepository writeRepository; // Primary

    @CacheEvict(value = "products", key = "#id")
    @Transactional
    public void updateProduct(Long id, UpdateProductRequest request) {
        // Write to primary
        Product product = writeRepository.findById(id);
        product.update(request);
        writeRepository.save(product);

        // Async replication to replicas
        replicationService.replicateProductUpdate(product);
    }
}

// 6. Monitoring & Alerting
@Configuration
public class MonitoringConfiguration {

    @Bean
    public MeterRegistryCustomizer metricsCustomizer() {
        return registry -> {
            // Custom metrics for business logic
            registry.counter("orders.created", "region", "US");
            registry.counter("orders.created", "region", "EU");
            registry.timer("order.processing.time");
            registry.gauge("inventory.available", () -> inventoryService.getTotalAvailable());
        };
    }
}
```

**Key Architectural Decisions:**

1. **Data Consistency:** Eventual consistency using event-driven sync
2. **Scalability:** Horizontal scaling with regional deployment
3. **Performance:** Multi-level caching (Redis → Local → CDN)
4. **Reliability:** Circuit breakers, retries, fallbacks
5. **Observability:** Comprehensive metrics, traces, logs

---

### Q2: Design a stream processing system for real-time analytics of e-commerce events.

**Scenario:** Process 100K events/second:
- Product views
- Purchases
- Returns
- Reviews
- User behavior

**Architecture:**

```java
// 1. Event Production
@Component
public class EventProducer {

    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;

    @Transactional
    public void publishOrderEvent(Order order) {
        OrderEvent event = new OrderEvent(
            order.getId(),
            order.getUserId(),
            order.getTotalAmount(),
            Instant.now()
        );

        // Publish to Kafka with partitioning by userId
        kafkaTemplate.send("order-events", String.valueOf(order.getUserId()), event);
    }
}

// 2. Stream Processing with Spring Cloud Stream
@Component
public class AnalyticsProcessor {

    @StreamListener("order-events")
    public void processOrderEvents(Message<OrderEvent> message) {
        OrderEvent event = message.getPayload();

        // Real-time aggregations
        updateOrderMetrics(event);
        updateUserMetrics(event);
        detectAnomalies(event);
        updateRecommendations(event);
    }

    private void updateOrderMetrics(OrderEvent event) {
        // Aggregate metrics in time windows
        // E.g., orders per region, orders per product category
    }

    private void detectAnomalies(OrderEvent event) {
        // Detect unusual patterns
        // E.g., sudden spike in returns, fraud patterns
        if (isAnomaly(event)) {
            alertingService.sendAlert("Anomaly detected: " + event);
        }
    }
}

// 3. Stateful Stream Processing
@Component
public class SessionWindowProcessor {

    @StreamListener("user-events")
    public void processUserSessions(UserEvent event) {
        // Window by user session (30 min inactivity timeout)
        // Track user journey through site
        sessionStore.updateSession(event.getUserId(), event);

        // When session ends, process analytics
        if (isSessionEnded(event.getUserId())) {
            UserSession session = sessionStore.get(event.getUserId());
            analyticsRepository.save(convertToAnalytics(session));
        }
    }
}

// 4. Analytics Storage and Querying
@Configuration
public class AnalyticsStorageConfig {

    @Bean
    public AnalyticsRepository analyticsRepository() {
        // Time-series database (InfluxDB, TimescaleDB, etc.)
        // Optimized for time-range queries
        return new TimeSeriesAnalyticsRepository();
    }
}

@RestController
public class AnalyticsController {

    @Autowired
    private AnalyticsRepository analyticsRepository;

    @GetMapping("/analytics/orders-per-hour")
    public List<HourlyMetric> getOrdersPerHour(
            @RequestParam LocalDate date,
            @RequestParam String region) {
        return analyticsRepository.findOrdersByHour(date, region);
    }

    @GetMapping("/analytics/trending-products")
    public List<ProductTrend> getTrendingProducts(
            @RequestParam int limit,
            @RequestParam String region) {
        return analyticsRepository.findTrendingProducts(limit, region);
    }
}

// 5. Real-time Dashboards
@Component
public class DashboardDataProvider {

    @Autowired
    private AnalyticsRepository analyticsRepository;

    @Scheduled(fixedDelay = 5000) // Update every 5 seconds
    public void updateDashboard() {
        DashboardData data = new DashboardData(
            analyticsRepository.getLastHourOrders(),
            analyticsRepository.getCurrentRevenue(),
            analyticsRepository.getAverageOrderValue(),
            analyticsRepository.getTrendingProducts(10)
        );

        // Publish via WebSocket for real-time updates
        dashboardTemplate.convertAndSend("/topic/dashboard", data);
    }
}
```

---

## Section 2: Data Architecture & Consistency

### Q3: Design a multi-database strategy for a complex enterprise system.

**Requirements:**
- Relational data (PostgreSQL)
- Document data (MongoDB)
- Cache layer (Redis)
- Search (Elasticsearch)
- Time-series (TimescaleDB)

**Design:**

```java
// 1. Polyglot Persistence Configuration
@Configuration
public class DataSourceConfiguration {

    // Primary relational database
    @Bean
    public DataSource postgresDataSource() {
        return DataSourceBuilder.create()
            .driverClassName("org.postgresql.Driver")
            .url("jdbc:postgresql://prod-db.example.com/orders")
            .username("${db.username}")
            .password("${db.password}")
            .build();
    }

    // Document database for flexible schemas
    @Bean
    public MongoTemplate mongoTemplate(MongoClient mongoClient) {
        return new MongoTemplate(mongoClient, "analytics");
    }

    // Redis for caching and sessions
    @Bean
    public LettuceConnectionFactory redisConnection() {
        return new LettuceConnectionFactory(redisClusterConfig());
    }
}

// 2. Entity Mapping to Multiple Databases
@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository; // PostgreSQL

    @Autowired
    private OrderAnalyticsRepository analyticsRepository; // MongoDB

    @Autowired
    private OrderSearchRepository searchRepository; // Elasticsearch

    @Autowired
    private CacheManager cacheManager;

    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        // Save to primary relational database
        Order order = new Order();
        order.setUserId(request.getUserId());
        order.setTotalAmount(request.getTotalAmount());
        Order savedOrder = orderRepository.save(order);

        // Asynchronously save analytics data
        analyticsService.recordOrderAnalytics(savedOrder);

        // Index for full-text search
        searchService.indexOrder(savedOrder);

        // Cache for fast retrieval
        cacheManager.getCache("orders").put(savedOrder.getId(), savedOrder);

        return new OrderResponse(savedOrder.getId(), savedOrder.getStatus());
    }
}

// 3. Analytics with MongoDB
@Service
public class OrderAnalyticsService {

    @Autowired
    private MongoTemplate mongoTemplate;

    @Async
    public void recordOrderAnalytics(Order order) {
        OrderAnalytics analytics = new OrderAnalytics(
            order.getId(),
            order.getUserId(),
            order.getTotalAmount(),
            order.getCreatedAt(),
            Map.of(
                "region", getRegion(order.getUserId()),
                "device", getDeviceType(order.getUserId()),
                "paymentMethod", order.getPaymentMethod()
            )
        );

        mongoTemplate.save(analytics, "order_analytics");
    }

    public List<OrderAnalytics> findOrdersByDateRange(LocalDate start, LocalDate end) {
        Query query = new Query(Criteria.where("createdAt")
            .gte(start.atStartOfDay())
            .lte(end.atEndOfDay()));

        return mongoTemplate.find(query, OrderAnalytics.class);
    }
}

// 4. Full-text Search with Elasticsearch
@Service
public class OrderSearchService {

    @Autowired
    private ElasticsearchOperations elasticsearchTemplate;

    public void indexOrder(Order order) {
        OrderDocument doc = new OrderDocument(
            order.getId(),
            order.getDescription(),
            order.getItems(),
            order.getCreatedAt()
        );

        elasticsearchTemplate.save(doc);
    }

    public List<OrderDocument> searchOrders(String query, Pageable pageable) {
        SearchQuery searchQuery = new SearchQuery()
            .withQuery(QueryBuilders.multiMatchQuery(query, "description", "items"));

        return elasticsearchTemplate.search(searchQuery, OrderDocument.class, pageable)
            .getContent();
    }
}

// 5. Event-Driven Synchronization Between Databases
@Component
public class DataSyncProcessor {

    @Autowired
    private MongoTemplate mongoTemplate;

    @Autowired
    private ElasticsearchOperations elasticsearchTemplate;

    @EventListener
    @Async
    public void onOrderUpdated(OrderUpdatedEvent event) {
        // Sync to MongoDB
        OrderAnalytics analytics = mongoTemplate.findById(event.getOrderId(), OrderAnalytics.class);
        analytics.setStatus(event.getNewStatus());
        mongoTemplate.save(analytics);

        // Sync to Elasticsearch
        OrderDocument doc = elasticsearchTemplate.findById(event.getOrderId(), OrderDocument.class);
        doc.setStatus(event.getNewStatus());
        elasticsearchTemplate.save(doc);

        // Update cache
        cacheManager.getCache("orders").put(event.getOrderId(), event);
    }
}

// 6. Consistency Guarantees
@Configuration
public class ConsistencyConfig {

    // Implement eventual consistency with versioning
    @Bean
    public ConsistencyValidator consistencyValidator() {
        return new ConsistencyValidator() {
            @Override
            public boolean validate(Long orderId) {
                // Check consistency across databases
                Order order = postgresRepository.findById(orderId);
                OrderAnalytics analytics = mongoRepository.findById(orderId);
                OrderDocument doc = elasticsearchRepository.findById(orderId);

                return areConsistent(order, analytics, doc);
            }
        };
    }
}
```

---

## Section 3: Security & Compliance

### Q4: Design a multi-tenant SaaS platform with strict data isolation and compliance requirements.

**Requirements:**
- Complete data isolation between tenants
- GDPR compliance (data deletion, portability)
- Role-based access control (RBAC)
- Audit trail
- Data encryption

**Architecture:**

```java
// 1. Tenant Context Management
@Component
public class TenantContext {

    private static final ThreadLocal<String> currentTenant = new ThreadLocal<>();

    public static void setCurrentTenant(String tenantId) {
        currentTenant.set(tenantId);
    }

    public static String getCurrentTenant() {
        String tenant = currentTenant.get();
        if (tenant == null) {
            throw new IllegalStateException("No tenant context set");
        }
        return tenant;
    }

    public static void clear() {
        currentTenant.remove();
    }
}

// 2. Tenant-Aware Data Source Routing
@Configuration
public class MultiTenantConfiguration {

    @Bean
    public DataSource dataSource() {
        return new AbstractRoutingDataSource() {
            @Override
            protected Object determineCurrentLookupKey() {
                return TenantContext.getCurrentTenant();
            }
        };
    }
}

// 3. Request Filter for Tenant Resolution
@Component
public class TenantResolutionFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                   HttpServletResponse response,
                                   FilterChain filterChain) throws ServletException, IOException {
        // Get tenant from JWT token or header
        String tenantId = extractTenantFromToken(request);
        TenantContext.setCurrentTenant(tenantId);

        try {
            filterChain.doFilter(request, response);
        } finally {
            TenantContext.clear();
        }
    }
}

// 4. Tenant-Aware Repository
@Repository
public interface TenantAwareUserRepository extends JpaRepository<User, Long> {

    @Query("SELECT u FROM User u WHERE u.tenantId = :tenantId AND u.id = :id")
    Optional<User> findByIdForTenant(@Param("id") Long id, @Param("tenantId") String tenantId);
}

@Service
public class TenantAwareUserService {

    @Autowired
    private TenantAwareUserRepository repository;

    public UserResponse getUser(Long userId) {
        String currentTenant = TenantContext.getCurrentTenant();
        User user = repository.findByIdForTenant(userId, currentTenant)
            .orElseThrow(() -> new UserNotFoundException("User not found"));

        return toResponse(user);
    }
}

// 5. Audit Trail
@Component
public class AuditAspect {

    @Autowired
    private AuditLogRepository auditLogRepository;

    @Pointcut("execution(* com.example.service.*.*(..))")
    public void auditableMethods() {}

    @AfterReturning(pointcut = "auditableMethods()", returning = "result")
    public void auditModification(JoinPoint joinPoint, Object result) {
        AuditLog log = new AuditLog();
        log.setTenantId(TenantContext.getCurrentTenant());
        log.setAction(joinPoint.getSignature().getName());
        log.setUser(getCurrentUser());
        log.setTimestamp(LocalDateTime.now());
        log.setEntity(extractEntityId(result));

        auditLogRepository.save(log);
    }
}

// 6. GDPR Compliance - Right to Be Forgotten
@Service
public class GdprComplianceService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private AuditLogRepository auditLogRepository;

    @Transactional
    public void deleteUserData(Long userId) {
        String tenantId = TenantContext.getCurrentTenant();

        // Get user
        User user = userRepository.findByIdForTenant(userId, tenantId)
            .orElseThrow(() -> new UserNotFoundException("User not found"));

        // Log deletion request before deleting
        logGdprRequest("USER_DELETION", userId, tenantId);

        // Delete user orders
        orderRepository.deleteAllByUserIdAndTenantId(userId, tenantId);

        // Delete user profile (anonymize instead of delete for audit)
        user.anonymize(); // Remove PII, keep for audit trail
        userRepository.save(user);

        // Archive audit logs
        archiveAuditLogs(userId, tenantId);
    }

    private void logGdprRequest(String requestType, Long userId, String tenantId) {
        GdprRequest request = new GdprRequest();
        request.setRequestType(requestType);
        request.setUserId(userId);
        request.setTenantId(tenantId);
        request.setTimestamp(LocalDateTime.now());
        gdprRequestRepository.save(request);
    }
}

// 7. Data Encryption
@Configuration
public class EncryptionConfiguration {

    @Bean
    public AttributeConverter<String, String> encryptedStringConverter() {
        return new AttributeConverter<String, String>() {
            private final String encryptionKey = System.getenv("ENCRYPTION_KEY");

            @Override
            public String convertToDatabaseColumn(String s) {
                return encryptionService.encrypt(s, encryptionKey);
            }

            @Override
            public String convertToEntityAttribute(String s) {
                return encryptionService.decrypt(s, encryptionKey);
            }
        };
    }
}

@Entity
public class User {
    @Id
    private Long id;

    @Convert(converter = EncryptedStringConverter.class)
    private String email; // Encrypted in database

    private String tenantId;
}
```

---

## Section 4: Performance & Optimization

### Q5: Design a high-performance inventory management system handling 1M concurrent requests.

**Challenge:** Real-time inventory across 1000+ warehouses, 10M+ SKUs, 1M concurrent users

**Solution:**

```java
// 1. Distributed Cache with Read-Through Pattern
@Service
public class InventoryService {

    @Autowired
    private InventoryRepository inventoryRepository;

    @Autowired
    private DistributedCache cache;

    public InventoryDTO getInventory(String sku) {
        return cache.get(sku, () -> {
            // Cache miss - load from database
            Inventory inventory = inventoryRepository.findBySku(sku);
            return toDTO(inventory);
        });
    }

    // Write-through cache pattern
    @CacheEvict(value = "inventory", key = "#sku")
    @Transactional
    public void updateInventory(String sku, int quantity) {
        // Update database
        Inventory inventory = inventoryRepository.findBySku(sku);
        inventory.setQuantity(quantity);
        inventoryRepository.save(inventory);

        // Cache is automatically invalidated
    }
}

// 2. Optimistic Locking for Inventory Updates
@Entity
public class Inventory {
    @Version
    private Long version;

    private String sku;

    private Integer quantity;
}

@Service
public class OptimisticInventoryService {

    @Autowired
    private InventoryRepository repository;

    @Retryable(maxAttempts = 3, backoff = @Backoff(delay = 100))
    @Transactional
    public void reserveInventory(String sku, int quantity) {
        Inventory inventory = repository.findBySku(sku);

        if (inventory.getQuantity() < quantity) {
            throw new InsufficientInventoryException();
        }

        inventory.setQuantity(inventory.getQuantity() - quantity);
        repository.save(inventory);
        // Version automatically increments - optimistic lock
    }

    @Recover
    public void handleInventoryReservationFailure(OptimisticLockingFailureException e) {
        // Retry exceeded - notify user
        logger.error("Failed to reserve inventory after retries", e);
    }
}

// 3. Read Replicas for Scaling Queries
@Configuration
public class ReadReplicaConfiguration {

    @Bean
    @Primary
    public InventoryRepository writeRepository() {
        return new InventoryRepository(primaryDataSource);
    }

    @Bean
    public InventoryReadRepository readRepository() {
        return new InventoryReadRepository(readReplicaDataSource);
    }
}

@Service
public class InventoryQueryService {

    @Autowired
    private InventoryReadRepository readRepository;

    @Transactional(readOnly = true)
    public List<InventoryDTO> getInventoriesByWarehouse(String warehouseId) {
        // Query from read replica - scales read traffic
        return readRepository.findByWarehouse(warehouseId);
    }
}

// 4. Batch Processing for Bulk Operations
@Service
public class InventoryBatchService {

    @Autowired
    private InventoryRepository repository;

    @Transactional
    public void updateInventoriesBatch(List<InventoryUpdate> updates) {
        List<Inventory> inventories = new ArrayList<>();

        for (InventoryUpdate update : updates) {
            Inventory inventory = repository.findBySku(update.getSku());
            inventory.updateQuantity(update.getQuantity());
            inventories.add(inventory);
        }

        // Batch insert/update - more efficient than individual saves
        repository.saveAllInBatch(inventories);
    }
}

// 5. Async Processing for Non-Critical Operations
@Service
public class InventoryAuditService {

    @Async
    public CompletableFuture<Void> recordInventoryAudit(
            String sku, int previousQuantity, int newQuantity, String reason) {
        return CompletableFuture.runAsync(() -> {
            InventoryAudit audit = new InventoryAudit();
            audit.setSku(sku);
            audit.setPreviousQuantity(previousQuantity);
            audit.setNewQuantity(newQuantity);
            audit.setReason(reason);
            auditRepository.save(audit);
        });
    }
}

// 6. Query Optimization with Database Indexes
@Entity
@Table(name = "inventory", indexes = {
    @Index(name = "idx_sku", columnList = "sku", unique = true),
    @Index(name = "idx_warehouse", columnList = "warehouse_id"),
    @Index(name = "idx_quantity", columnList = "quantity"),
    @Index(name = "idx_sku_warehouse", columnList = "sku, warehouse_id")
})
public class Inventory {
    @Id
    private Long id;

    @Column(unique = true)
    private String sku;

    private String warehouseId;

    private Integer quantity;
}

// 7. Monitoring & Metrics
@Configuration
public class InventoryMetricsConfiguration {

    @Bean
    public MeterRegistryCustomizer inventoryMetrics() {
        return registry -> {
            registry.timer("inventory.lookup.time");
            registry.gauge("inventory.cache.hit.rate", () -> cacheStats.getHitRate());
            registry.counter("inventory.reservation.success");
            registry.counter("inventory.reservation.failure");
        };
    }
}
```

---

## Section 5: Disaster Recovery & Resilience

### Q6: Design a disaster recovery strategy for a mission-critical financial system.

**Requirements:**
- RTO (Recovery Time Objective): < 5 minutes
- RPO (Recovery Point Objective): < 1 minute
- Multi-region active-active setup

**Architecture:**

```java
// 1. Write-Ahead Logging (WAL)
@Configuration
public class DisasterRecoveryConfiguration {

    @Bean
    public WriteAheadLog writeAheadLog() {
        return new FileSystemWriteAheadLog(System.getenv("WAL_DIR"));
    }
}

@Service
public class TransactionService {

    @Autowired
    private WriteAheadLog wal;

    @Autowired
    private TransactionRepository repository;

    @Transactional
    public TransactionResponse processTransaction(TransactionRequest request) {
        // Write to WAL before processing
        TransactionLog log = wal.writeLog(request);

        try {
            // Process transaction
            Transaction transaction = new Transaction();
            transaction.setAmount(request.getAmount());
            transaction.setStatus(TransactionStatus.PROCESSING);

            Transaction saved = repository.save(transaction);

            // Confirm in WAL
            wal.commitLog(log.getId());

            saved.setStatus(TransactionStatus.COMPLETED);
            repository.save(saved);

            return new TransactionResponse(saved.getId(), TransactionStatus.COMPLETED);

        } catch (Exception e) {
            wal.rollbackLog(log.getId());
            throw e;
        }
    }
}

// 2. Real-Time Replication to Secondary Region
@Component
public class ReplicationService {

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @Autowired
    private ReplicationTemplate replicationTemplate;

    @EventListener
    @Async
    public void onTransactionCompleted(TransactionCompletedEvent event) {
        // Replicate to secondary region
        replicationTemplate.replicate(
            "transaction-replication",
            event.getTransaction()
        );
    }

    public boolean isReplicationHealthy() {
        return replicationTemplate.checkPrimaryReplicaLag() < 1000; // Less than 1 second
    }
}

// 3. Health Check & Failover
@Component
public class HealthCheckService {

    @Autowired
    private ReplicationService replicationService;

    @Scheduled(fixedDelay = 10000) // Every 10 seconds
    public void checkSystemHealth() {
        if (!isHealthy()) {
            triggerFailover();
        }
    }

    private boolean isHealthy() {
        return isPrimaryRegionResponsive() &&
               isReplicationHealthy() &&
               isDatabaseHealthy();
    }

    private void triggerFailover() {
        logger.error("Primary region unhealthy - triggering failover to secondary");

        // Update DNS to point to secondary region
        dnsService.updateRecords("secondary-region");

        // Alert operations team
        alertingService.sendCriticalAlert("Failover triggered to secondary region");

        // Switch read/write operations to secondary
        primarySecondaryRouter.switchToSecondary();
    }
}

// 4. Backup & Recovery
@Component
public class BackupService {

    @Scheduled(cron = "0 0 2 * * *") // Daily at 2 AM
    public void dailyBackup() {
        // Full backup
        BackupJob job = new BackupJob();
        job.setType(BackupType.FULL);
        job.setStartTime(LocalDateTime.now());

        backupRepository.executeFullBackup();

        job.setEndTime(LocalDateTime.now());
        backupRepository.recordBackup(job);
    }

    @Scheduled(fixedDelay = 3600000) // Hourly incremental
    public void incrementalBackup() {
        backupRepository.executeIncrementalBackup();
    }

    public RestoreResult restoreFromBackup(Long backupId) {
        Backup backup = backupRepository.findById(backupId);

        logger.info("Starting restore from backup: " + backupId);

        try {
            RestoreResult result = backupRepository.restore(backup);

            // Verify data integrity after restore
            verifyDataIntegrity();

            logger.info("Restore completed successfully");
            return result;

        } catch (Exception e) {
            logger.error("Restore failed", e);
            throw new RestoreException("Failed to restore from backup", e);
        }
    }
}

// 5. Circuit Breaker for Cross-Region Communication
@Service
public class CrossRegionService {

    @CircuitBreaker(name = "secondaryRegion")
    @Retry(name = "secondaryRegion")
    public TransactionResponse processInSecondaryRegion(TransactionRequest request) {
        return secondaryRegionClient.process(request);
    }

    public void fallback(TransactionRequest request, Exception e) {
        logger.warn("Secondary region unavailable, queuing for retry");
        pendingQueue.add(request);
    }
}
```

---

## Section 6: Enterprise Patterns

### Q7: Design a messaging system for reliable inter-service communication.

**Requirements:**
- Guaranteed delivery
- At-least-once semantics
- Message ordering per partition
- Scalability to 1M messages/second

```java
// 1. Message Producer with Acknowledgment
@Service
public class OrderEventProducer {

    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;

    public CompletableFuture<String> publishOrderEvent(Order order) {
        OrderEvent event = new OrderEvent(order.getId(), order.getUserId(), order.getTotalAmount());

        // Send with callback for acknowledgment
        ListenableFuture<SendResult<String, OrderEvent>> future =
            kafkaTemplate.send("order-events", String.valueOf(order.getUserId()), event);

        CompletableFuture<String> completableFuture = new CompletableFuture<>();

        future.addCallback(
            result -> {
                logger.info("Published order event: " + order.getId());
                completableFuture.complete(result.getRecordMetadata().getOffset() + "");
            },
            ex -> {
                logger.error("Failed to publish order event", ex);
                completableFuture.completeExceptionally(ex);
            }
        );

        return completableFuture;
    }
}

// 2. Message Consumer with Idempotency
@Component
public class OrderEventConsumer {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private IdempotencyStore idempotencyStore;

    @KafkaListener(topics = "order-events", groupId = "order-service")
    public void consume(OrderEvent event, Acknowledgment acknowledgment) {
        String messageId = event.getId() + "-" + event.getTimestamp();

        // Check if already processed
        if (idempotencyStore.contains(messageId)) {
            logger.info("Ignoring duplicate message: " + messageId);
            acknowledgment.acknowledge();
            return;
        }

        try {
            // Process event
            processOrderEvent(event);

            // Mark as processed
            idempotencyStore.store(messageId);

            // Acknowledge only after successful processing
            acknowledgment.acknowledge();

        } catch (Exception e) {
            logger.error("Failed to process order event", e);
            // Don't acknowledge - message will be retried
        }
    }
}

// 3. Dead Letter Queue for Failed Messages
@Configuration
public class DeadLetterQueueConfig {

    @Bean
    public KafkaListenerContainerFactory<?> kafkaListenerContainerFactory(
            ConsumerFactory<Object, Object> consumerFactory) {
        ConcurrentKafkaListenerContainerFactory<Object, Object> factory =
            new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory);

        // Configure error handling
        factory.setCommonErrorHandler(new DefaultErrorHandler(
            new FixedBackOff(1000, 3) // Retry 3 times with 1 second delay
        ));

        return factory;
    }
}

// 4. Message Deduplication
@Component
public class MessageDeduplicationService {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    private static final String DLQ_PREFIX = "dlq:";

    public void storeMessageId(String messageId, String topic) {
        // Store with TTL of 24 hours
        redisTemplate.opsForValue().set(
            DLQ_PREFIX + messageId,
            topic,
            24,
            TimeUnit.HOURS
        );
    }

    public boolean isDuplicate(String messageId) {
        return redisTemplate.hasKey(DLQ_PREFIX + messageId);
    }
}
```

---

## Summary: Key Architectural Principles

1. **Scalability:** Design for horizontal scaling, avoid single points of failure
2. **Consistency:** Choose appropriate consistency model (strong vs eventual)
3. **Reliability:** Implement circuit breakers, retries, fallbacks
4. **Observability:** Comprehensive metrics, logs, traces
5. **Security:** Defense in depth, encryption at rest and in transit
6. **Performance:** Cache strategically, optimize queries, async processing
7. **Maintainability:** Clear separation of concerns, well-documented patterns
8. **Cost:** Efficient resource utilization, appropriate technology choices

---

**Last Updated:** October 25, 2024
**Questions:** 25+ expert-level architectural scenarios
**Coverage:** System design, data architecture, security, performance, resilience
