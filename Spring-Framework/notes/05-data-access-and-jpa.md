# Data Access & JPA - Comprehensive Guide

## Spring Data JPA

Spring Data JPA simplifies data access layer development.

```java
// Entity Definition
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_email", columnList = "email", unique = true),
    @Index(name = "idx_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 255)
    private String email;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserStatus status;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Order> orders = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id")
    private Company company;
}

// Repository Interface
@Repository
public interface UserRepository extends JpaRepository<User, Long>,
                                       JpaSpecificationExecutor<User>,
                                       QuerydslPredicateExecutor<User> {

    Optional<User> findByEmail(String email);

    List<User> findByStatus(UserStatus status);

    @Query("SELECT u FROM User u WHERE u.status = :status AND u.createdAt > :date")
    List<User> findActiveUsersSince(@Param("status") UserStatus status,
                                    @Param("date") LocalDateTime date);

    @Query(value = "SELECT * FROM users WHERE status = ? AND active = true", nativeQuery = true)
    List<User> findActiveUsersNative(String status);

    @Modifying
    @Query("UPDATE User u SET u.status = :status WHERE u.id = :id")
    void updateStatus(@Param("id") Long id, @Param("status") UserStatus status);

    Page<User> findByStatus(UserStatus status, Pageable pageable);
}

// Usage
@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public List<User> getActiveUsers() {
        return userRepository.findByStatus(UserStatus.ACTIVE);
    }

    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public Page<User> getPaginatedUsers(int page, int size) {
        return userRepository.findByStatus(UserStatus.ACTIVE,
            PageRequest.of(page, size, Sort.by("createdAt").descending()));
    }

    public List<User> findCustom() {
        return userRepository.findActiveUsersSince(UserStatus.ACTIVE,
            LocalDateTime.now().minusMonths(1));
    }
}
```

## Specifications for Dynamic Queries

```java
public class UserSpecifications {

    public static Specification<User> hasStatus(UserStatus status) {
        return (root, query, cb) ->
            cb.equal(root.get("status"), status);
    }

    public static Specification<User> createdAfter(LocalDateTime date) {
        return (root, query, cb) ->
            cb.greaterThan(root.get("createdAt"), date);
    }

    public static Specification<User> emailLike(String email) {
        return (root, query, cb) ->
            cb.like(cb.lower(root.get("email")), "%" + email.toLowerCase() + "%");
    }

    public static Specification<User> inCompany(Long companyId) {
        return (root, query, cb) ->
            cb.equal(root.get("company").get("id"), companyId);
    }
}

// Usage
@Service
public class UserSearchService {

    @Autowired
    private UserRepository userRepository;

    public List<User> searchUsers(UserStatus status, String email, Long companyId) {
        Specification<User> spec = Specification
            .where(UserSpecifications.hasStatus(status))
            .and(UserSpecifications.emailLike(email))
            .and(UserSpecifications.inCompany(companyId));

        return userRepository.findAll(spec);
    }
}
```

## Relationships & Lazy Loading

```java
// One-to-Many
@Entity
public class Company {
    @OneToMany(mappedBy = "company", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<User> users = new ArrayList<>();
}

// Many-to-One
@Entity
public class User {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id")
    private Company company;
}

// Many-to-Many
@Entity
public class User {
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id"))
    private Set<Role> roles = new HashSet<>();
}

// One-to-One
@Entity
public class User {
    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name = "profile_id")
    private UserProfile profile;
}

// N+1 Problem - AVOID!
@Service
public class BadService {
    public void badFetch() {
        List<User> users = userRepository.findAll();  // 1 query

        for (User user : users) {  // N additional queries
            System.out.println(user.getCompany().getName());
        }
    }
}

// Solution: Use Fetch Join
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Query("SELECT u FROM User u " +
           "LEFT JOIN FETCH u.company c " +
           "LEFT JOIN FETCH u.orders o")
    List<User> findAllWithRelations();

    @EntityGraph(attributePaths = {"company", "roles"})
    @Query("SELECT u FROM User u")
    List<User> findAllEager();
}
```

## Custom Queries

```java
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    // Method name queries (limited)
    List<Order> findByUserIdAndStatus(Long userId, OrderStatus status);

    // JPQL queries
    @Query("SELECT o FROM Order o WHERE o.user.id = :userId AND o.status = :status")
    List<Order> findUserOrders(@Param("userId") Long userId,
                               @Param("status") OrderStatus status);

    // Native SQL queries
    @Query(value = "SELECT * FROM orders WHERE total > ? ORDER BY created_at DESC",
           nativeQuery = true)
    List<Order> findExpensiveOrders(BigDecimal minTotal);

    // Count queries
    @Query("SELECT COUNT(o) FROM Order o WHERE o.status = :status")
    Long countByStatus(@Param("status") OrderStatus status);

    // Projection queries
    @Query("SELECT new map(o.id as id, o.total as total) FROM Order o")
    List<Map<String, Object>> findOrderSummaries();

    // Exists query
    @Query("SELECT CASE WHEN COUNT(o) > 0 THEN true ELSE false END " +
           "FROM Order o WHERE o.user.id = :userId")
    boolean userHasOrders(@Param("userId") Long userId);
}
```

## Pagination and Sorting

```java
@Service
public class OrderPaginationService {

    @Autowired
    private OrderRepository orderRepository;

    public Page<Order> getOrders(int page, int size, String sortBy) {
        Pageable pageable = PageRequest.of(
            page, size,
            Sort.by(sortBy).descending()
        );

        return orderRepository.findAll(pageable);
    }

    public List<Order> getAllSorted() {
        return orderRepository.findAll(
            Sort.by("createdAt").descending()
                .and(Sort.by("total").ascending())
        );
    }

    public Slice<Order> getSlice(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return orderRepository.findAll(pageable);
    }
}
```

---

## Summary

Spring Data JPA provides:
- CRUD operations out-of-the-box
- Query generation from method names
- Custom @Query support
- Specification API for dynamic queries
- Pagination and sorting
- Lazy loading with fetch joins
- Transaction management

Key practices: Use constructor injection, avoid N+1 queries, prefer Specifications over custom queries, use DTOs for projections.

