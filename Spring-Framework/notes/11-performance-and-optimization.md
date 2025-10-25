# Performance & Optimization

## Caching Strategies

```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager("users", "products", "orders");
    }
}

@Service
public class UserService {

    @Cacheable("users")
    public UserDTO getUser(Long id) {
        return userRepository.findById(id)
            .map(userMapper::toDTO)
            .orElseThrow();
    }

    @CachePut(value = "users", key = "#result.id")
    public UserDTO updateUser(Long id, UpdateRequest request) {
        User user = userRepository.findById(id).orElseThrow();
        user.setName(request.getName());
        return userMapper.toDTO(userRepository.save(user));
    }

    @CacheEvict("users")
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    @Caching(evict = {
        @CacheEvict(value = "users", allEntries = true),
        @CacheEvict(value = "orders", allEntries = true)
    })
    public void clearAllCaches() {}
}
```

## Database Optimization

```java
// N+1 Problem Solution
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @EntityGraph(attributePaths = {"company", "roles"})
    List<User> findAll();

    @Query("SELECT u FROM User u " +
           "LEFT JOIN FETCH u.company c " +
           "LEFT JOIN FETCH u.roles r")
    List<User> findAllWithRelations();
}

// Projection for large datasets
@Repository
public interface UserProjection {
    Long getId();
    String getEmail();
}

public interface UserRepository extends JpaRepository<User, Long> {
    List<UserProjection> findAllProjectedBy();
}
```

## Async Processing

```java
@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(500);
        return executor;
    }
}

@Service
public class EmailService {

    @Async
    public CompletableFuture<Void> sendEmailAsync(String to, String subject) {
        try {
            // Send email
            return CompletableFuture.completedFuture(null);
        } catch (Exception e) {
            return CompletableFuture.failedFuture(e);
        }
    }
}
```

