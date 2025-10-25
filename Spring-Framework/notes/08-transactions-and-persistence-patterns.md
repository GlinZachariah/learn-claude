# Transactions & Persistence Patterns

## Transaction Management

```java
@Service
public class OrderService {

    @Transactional  // Default: REQUIRED, READ_WRITE, TIMEOUT 30s
    public OrderDTO createOrder(CreateOrderRequest request) {
        // All operations in one transaction
        // Rolled back if exception occurs
        Order order = new Order();
        order.setUserId(request.getUserId());
        Order saved = orderRepository.save(order);

        for (OrderItem item : request.getItems()) {
            OrderItem oi = new OrderItem();
            oi.setOrderId(saved.getId());
            oi.setProductId(item.getProductId());
            orderItemRepository.save(oi);
        }

        return orderMapper.toDTO(saved);
    }

    @Transactional(readOnly = true)  // Optimized for reading
    public OrderDTO getOrder(Long id) {
        return orderRepository.findById(id)
            .map(orderMapper::toDTO)
            .orElseThrow();
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void processPayment(Long orderId) {
        // New transaction, separate from caller
    }

    @Transactional(noRollbackFor = ValidationException.class)
    public void process() {
        // Don't rollback on ValidationException
    }

    @Transactional(rollbackFor = Exception.class)
    public void process() {
        // Rollback on any exception
    }

    @Transactional(isolation = Isolation.SERIALIZABLE)
    public void criticalOperation() {
        // Highest isolation level
        // Prevents dirty read, non-repeatable read, phantom read
    }
}
```

## Propagation Behavior

```java
@Service
public class TransactionService {

    @Autowired
    private AuditService auditService;

    // REQUIRED (default): Use existing or create new
    @Transactional(propagation = Propagation.REQUIRED)
    public void operation1() {
        auditService.log("Operation 1");  // Uses same transaction
    }

    // REQUIRES_NEW: Always create new transaction
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void operation2() {
        // Even if called from operation1, runs in separate transaction
    }

    // NESTED: Create savepoint in same transaction
    @Transactional(propagation = Propagation.NESTED)
    public void operation3() {
        // Can rollback independently
    }

    // NOT_SUPPORTED: Suspend current transaction
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void operation4() {
        // Runs outside transaction
    }

    // MANDATORY: Fail if no transaction exists
    @Transactional(propagation = Propagation.MANDATORY)
    public void operation5() {
        // Must be called from transactional context
    }
}
```

## Optimistic Locking

```java
@Entity
public class Product {
    @Version  // Optimistic lock version
    private Long version;

    // ... other fields
}

@Service
public class ProductService {

    public void updateProduct(Product product) {
        Product existing = productRepository.findById(product.getId()).orElseThrow();

        // Version incremented on save
        existing.setPrice(product.getPrice());
        existing.setName(product.setName());

        try {
            productRepository.save(existing);
        } catch (OptimisticLockingFailureException e) {
            // Handle concurrent modification
            // Version mismatch detected
        }
    }
}
```

## Persistence Context

```java
@Service
@Transactional
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public void demonstratePersistence() {
        // 1. Transient: Not managed
        User user = new User();
        user.setName("John");

        // 2. Persistent: In persistence context
        userRepository.save(user);

        user.setName("Jane");  // Changes tracked

        // 3. Flush: Changes written to DB
        entityManager.flush();

        // 4. Detached: Outside transaction
    }

    // Each transaction creates new persistence context
    @Transactional
    public void processUsers() {
        List<User> users = userRepository.findAll();

        for (User user : users) {
            user.setActive(true);  // Tracked
        }
        // Auto-flush on commit
    }
}
```

