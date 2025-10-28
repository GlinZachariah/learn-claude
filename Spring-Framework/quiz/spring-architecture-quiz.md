# Spring Architecture Self-Assessment Quiz

## Part 1: Microservices Fundamentals (15 Questions, 4 points each = 60 points)

### Question 1: Service Boundaries
What is the primary benefit of using bounded contexts from DDD to define microservice boundaries?
- A) Reduces code complexity
- B) Ensures each service has a single responsibility and clear ownership
- C) Improves database performance
- D) Simplifies testing

**Answer: B** - Bounded contexts align with microservices boundaries, preventing scattered responsibilities.

---

### Question 2: Inter-Service Communication
Which communication pattern is best for real-time queries in microservices?
- A) Message queues
- B) Event sourcing
- C) REST/gRPC (synchronous)
- D) Email notifications

**Answer: C** - Synchronous communication provides immediate responses for queries.

---

### Question 3: Data Consistency
In the saga pattern, what is a compensating transaction?
- A) A transaction that confirms success
- B) A transaction that undoes previous changes if later steps fail
- C) A transaction that caches data
- D) A transaction that encrypts data

**Answer: B** - Compensating transactions handle rollback in distributed transactions.

---

### Question 4: Service Discovery
Which tool automatically registers services and provides load balancing?
- A) Docker
- B) Consul/Eureka
- C) Jenkins
- D) Git

**Answer: B** - Service discovery tools manage dynamic service registration and discovery.

---

### Question 5: Circuit Breaker States
What does the HALF_OPEN state represent in a circuit breaker?
- A) Service is completely down
- B) Testing if service has recovered after being open
- C) Normal operation
- D) Service is being cached

**Answer: B** - HALF_OPEN allows testing recovery after service failure.

---

### Question 6: Resilience Patterns
Which pattern isolates resources to prevent cascading failures?
- A) Circuit Breaker
- B) Retry Pattern
- C) Bulkhead Pattern
- D) Timeout Pattern

**Answer: C** - Bulkhead isolates critical resources from failures.

---

### Question 7: API Gateway
What is the primary responsibility of an API Gateway?
- A) Business logic processing
- B) Database operations
- C) Request routing, rate limiting, authentication
- D) Data transformation

**Answer: C** - API Gateway provides cross-cutting concerns for all requests.

---

### Question 8: Event-Driven Architecture
Which benefit does event-driven architecture provide?
- A) Tighter coupling
- B) Easier debugging
- C) Loose coupling and scalability
- D) Stronger consistency

**Answer: C** - Events decouple services, improving scalability.

---

### Question 9: Distributed Transactions
Why is 2-phase commit unsuitable for microservices?
- A) It's too fast
- B) It doesn't support transactions
- C) It causes long locks and poor availability
- D) It requires no network calls

**Answer: C** - 2PC blocks resources, unsuitable for distributed systems.

---

### Question 10: Configuration Management
What is the advantage of centralized configuration in Spring Cloud Config?
- A) Improves performance
- B) Allows updates without restarting services
- C) Reduces code lines
- D) Improves database queries

**Answer: B** - @RefreshScope enables runtime configuration updates.

---

### Question 11: Health Checks
Which health check type indicates service readiness to accept traffic?
- A) Startup probe
- B) Liveness probe
- C) Readiness probe
- D) Availability check

**Answer: C** - Readiness probes indicate when service is ready for traffic.

---

### Question 12: Event Sourcing
What is the primary advantage of event sourcing?
- A) Faster database queries
- B) Complete audit trail and temporal queries
- C) Simpler code
- D) Better security

**Answer: B** - Event sourcing provides complete history and point-in-time state.

---

### Question 13: CQRS Pattern
Why separate read and write models in CQRS?
- A) To reduce code
- B) To optimize each model independently
- C) To improve security
- D) To simplify transactions

**Answer: B** - Read and write models have different optimization requirements.

---

### Question 14: Monitoring
Which metric is critical for microservices observability?
- A) Application size
- B) Distributed traces with latency and errors
- C) Git commits
- D) Code comments

**Answer: B** - Traces show request flow across services.

---

### Question 15: Deployment Strategy
Which deployment strategy allows zero-downtime updates?
- A) Big bang deployment
- B) Rolling deployment
- C) Manual deployment
- D) Scheduled maintenance

**Answer: B** - Rolling deployment updates instances gradually.

---

## Part 2: Advanced Patterns & Techniques (20 Questions, 4 points each = 80 points)

### Question 16: Domain-Driven Design
What is an aggregate root's primary responsibility?
- A) Manage all objects in the system
- B) Enforce business rules and consistency within aggregate boundary
- C) Cache frequently accessed data
- D) Route requests to services

**Answer: B** - Aggregate root enforces invariants within aggregate.

---

### Question 17: Value Objects
Which characteristic defines a value object?
- A) Must be persistent
- B) Has an ID
- C) Immutable and comparable by value
- D) Requires database mapping

**Answer: C** - Value objects are immutable and lack identity.

---

### Question 18: Repository Pattern
What should a repository interface NOT do?
- A) Persist aggregates
- B) Retrieve aggregates
- C) Contain business logic
- D) Map domain to persistence

**Answer: C** - Business logic belongs in domain, not repository.

---

### Question 19: Saga Pattern - Choreography vs Orchestration
Which approach has more visible workflow?
- A) Choreography
- B) Orchestration
- C) Event sourcing
- D) CQRS

**Answer: B** - Orchestration has explicit workflow in coordinator.

---

### Question 20: Cache Invalidation Strategies
Which strategy is suitable for data with frequent updates?
- A) Long TTL
- B) Write-through or event-driven invalidation
- C) Never invalidate
- D) Invalidate on schedule only

**Answer: B** - Frequent changes need immediate or event-driven invalidation.

---

### Question 21: Distributed Tracing
What does a trace span represent?
- A) Complete request from start to end
- B) Single operation within a request
- C) Error log entry
- D) Database transaction

**Answer: B** - Span is unit of work within trace.

---

### Question 22: Container Orchestration
Which tool manages container deployment, scaling, and networking?
- A) Docker
- B) Kubernetes
- C) Jenkins
- D) Maven

**Answer: B** - Kubernetes orchestrates containerized workloads.

---

### Question 23: API Versioning
Why implement API versioning?
- A) To complicate client code
- B) To support backward compatibility
- C) To increase API size
- D) To reduce documentation

**Answer: B** - Versioning allows evolution without breaking clients.

---

### Question 24: Idempotency
Why is idempotency important in distributed systems?
- A) Improves performance
- B) Allows safe retries without side effects
- C) Reduces database size
- D) Improves security

**Answer: B** - Idempotent operations can be safely retried.

---

### Question 25: Graceful Shutdown
What should a service do before shutting down?
- A) Immediately terminate
- B) Stop accepting new requests and complete in-flight ones
- C) Clear cache aggressively
- D) Force clients to reconnect

**Answer: B** - Graceful shutdown prevents request loss.

---

### Question 26: Database per Service Pattern
What challenge does this pattern create?
- A) No challenges
- B) Distributed data consistency complexity
- C) Performance improvement
- D) Security enhancement

**Answer: B** - Separate databases require eventual consistency management.

---

### Question 27: Event Bus Implementation
Which is a valid event bus technology?
- A) RabbitMQ/Kafka
- B) Spring ApplicationEventPublisher
- C) AWS SNS/SQS
- D) All of above

**Answer: D** - Multiple technologies can implement event bus.

---

### Question 28: Rate Limiting Strategy
Which rate limiting type limits per user?
- A) Global rate limit
- B) Per-service limit
- C) Token bucket algorithm with per-user bucket
- D) No limits

**Answer: C** - Per-user rate limiting prevents individual abuse.

---

### Question 29: Polyglot Persistence
When is using multiple database types beneficial?
- A) Always
- B) Never
- C) When different data has different optimal storage
- D) For complexity

**Answer: C** - Choose storage by data characteristics.

---

### Question 30: Eventual Consistency Handling
What technique ensures eventual consistency is achieved?
- A) Ignore failures
- B) Event replay and reconciliation
- C) Disable updates
- D) Increase timeouts

**Answer: B** - Reconciliation ensures delayed consistency converges.

---

### Question 31: Load Balancing Algorithm
Which algorithm distributes requests evenly?
- A) First available
- B) Round robin
- C) Sticky session
- D) Least connections

**Answer: B** - Round robin distributes evenly.

---

### Question 32: Fallback Mechanisms
What should a fallback return?
- A) Error immediately
- B) Stale cache, default, or degraded functionality
- C) Nothing
- D) Retry infinitely

**Answer: B** - Fallback provides best-effort response.

---

### Question 33: Timeout Management
What is a good timeout strategy?
- A) Very long timeout
- B) No timeout
- C) Context-dependent, fail fast on timeout
- D) Timeout all requests

**Answer: C** - Appropriate timeouts prevent resource exhaustion.

---

### Question 34: Database Migration in Microservices
How should migrations be handled?
- A) Disable service during migration
- B) Zero-downtime migration with backward compatibility
- C) Skip migrations
- D) Manual coordination

**Answer: B** - Services must remain available during migrations.

---

### Question 35: Cross-Service Authorization
How should services authorize requests from other services?
- A) Trust all internal requests
- B) Require bearer tokens or mutual TLS
- C) No authorization needed
- D) Use passwords

**Answer: B** - Service-to-service requires proper authentication.

---

## Part 3: Implementation & Architecture Decisions (15 Questions, 6 points each = 90 points)

### Question 36: Choosing Between Monolith and Microservices
A startup with 3 developers should choose:
- A) Microservices for future-proofing
- B) Modular monolith, migrate later
- C) Monolithic architecture immediately
- D) No architecture needed

**Answer: B/C** - Start simple, migrate when team grows.

---

### Question 37: Event Sourcing vs Traditional Persistence
Event sourcing is most beneficial when:
- A) All systems need it
- B) Audit trail and temporal queries are critical requirements
- C) It simplifies code
- D) Database is large

**Answer: B** - Event sourcing excels for audit requirements.

---

### Question 38: Implementing Circuit Breaker
Which configuration is most appropriate?
- A) failureThreshold=1%, waitDuration=1s
- B) failureThreshold=50%, waitDuration=30s
- C) No threshold, wait forever
- D) failureThreshold=100%

**Answer: B** - Reasonable thresholds prevent false positives.

---

### Question 39: Caching Strategy for High Traffic
A product catalog with read-heavy 10:1 ratio needs:
- A) No caching
- B) L1 (in-memory) + L2 (Redis) + DB with long TTLs
- C) Only database
- D) Cache invalidate on every change

**Answer: B** - Multi-level caching handles read-heavy workload.

---

### Question 40: API Gateway Placement
API Gateway should sit:
- A) Inside each microservice
- B) In front of all services as entry point
- C) In database layer
- D) Distributed across services

**Answer: B** - Centralized gateway provides uniform policy.

---

### Question 41: Transaction Boundaries
A successful order must: inventory reserved, payment processed, confirmation sent. Pattern?
- A) Single transaction
- B) Saga with compensating transactions
- C) No coordination needed
- D) Manual rollback

**Answer: B** - Saga handles distributed transaction.

---

### Question 42: Data Consistency Model Selection
Financial transactions require:
- A) Eventual consistency
- B) Strong consistency
- C) Causal consistency
- D) No consistency

**Answer: B** - Money requires immediate consistency.

---

### Question 43: Monitoring Microservices
What must be monitored to detect problems early?
- A) Only error rates
- B) Metrics, logs, traces, and custom business metrics
- C) No monitoring needed
- D) Database size only

**Answer: B** - Comprehensive observability is essential.

---

### Question 44: Service-to-Service Authentication
JWT tokens should:
- A) Be stored in URL
- B) Be sent in Authorization header with short expiry
- C) Never expire
- D) Be shared between services

**Answer: B** - Short-lived tokens in headers are secure.

---

### Question 45: Handling Partial Failures
When Payment service fails but Order service succeeds:
- A) Ignore the issue
- B) Compensating transaction + manual reconciliation
- C) Fail entire request
- D) Duplicate the order

**Answer: B** - Eventual consistency handling is required.

---

### Question 46: Configuration Sensitive Data
Database passwords should be:
- A) Hardcoded in application
- B) In Git repository
- C) Encrypted in Config Server or external vault
- D) In plaintext files

**Answer: C** - Vault or encrypted config server.

---

### Question 47: Service Deployment
Rolling deployment is chosen because:
- A) It's fast
- B) It enables zero-downtime updates
- C) It's simple
- D) It doesn't require orchestration

**Answer: B** - Rolling allows graceful updates.

---

### Question 48: Testing Microservices
Which testing approach is most comprehensive?
- A) Only unit tests
- B) Unit + Integration + Contract + E2E tests
- C) Manual testing only
- D) No testing

**Answer: B** - Comprehensive testing catches integration issues.

---

### Question 49: Message Queue Selection
For guaranteed order processing with high throughput:
- A) RabbitMQ
- B) Kafka
- C) Email
- D) REST calls

**Answer: B** - Kafka guarantees ordering and throughput.

---

### Question 50: Architecture Evolution
As system grows from 5 to 50 developers:
- A) No architecture change needed
- B) Gradual migration from monolith to microservices
- C) Immediate big-bang rewrite
- D) Accept system collapse

**Answer: B** - Strangler pattern for gradual migration.

---

## Scoring Guide

### Total Points: 240 (60 + 80 + 90)

| Score Range | Level | Recommendation |
|------------|-------|-----------------|
| 0-80 | Beginner | Review fundamentals chapter 13 |
| 80-120 | Intermediate | Focus on patterns and real-world scenarios |
| 120-160 | Advanced | Practice coding challenges |
| 160-200 | Expert | Interview preparation |
| 200+ | Master | Ready for architect role |

---

## Study Path by Performance

### If you scored 0-80 (Beginner)
1. Review layered vs hexagonal architecture
2. Understand microservices vs monolith trade-offs
3. Study service communication patterns
4. Review circuit breaker and retry patterns
5. Practice simple Spring Boot services

### If you scored 80-120 (Intermediate)
1. Deep dive into CQRS and event sourcing
2. Study saga patterns in detail
3. Implement DDD with Spring
4. Learn distributed tracing
5. Practice resilience patterns

### If you scored 120-160 (Advanced)
1. Complete all 8 coding challenges
2. Implement event sourcing system
3. Build microservices with Spring Cloud
4. Study operational concerns
5. Practice system design questions

### If you scored 160+ (Expert)
1. Review architecture best practices
2. Interview question practice
3. Design system architecture from scratch
4. Mentor others on patterns
5. Stay current with new technologies

---

## Related Topics to Study Further

- Spring Cloud Config: Configuration management
- Spring Cloud Netflix: Eureka, Hystrix (legacy patterns)
- Spring Cloud Bus: Dynamic refresh
- Spring Cloud Stream: Event-driven messaging
- Spring Data: Repository pattern implementation
- Spring Test: Testing microservices
- Docker & Kubernetes: Container orchestration
- Kafka/RabbitMQ: Message brokers

---

## Common Misconceptions to Avoid

1. **Microservices solve all problems** - They introduce new complexity
2. **Database per service = no shared data** - Eventual consistency needed
3. **Event sourcing always better** - Adds complexity, use when needed
4. **No downtime is always required** - Depends on SLA requirements
5. **Cache everything** - Cache strategically based on access patterns

---

**Total Study Time:** 1-2 hours
**Difficulty:** Intermediate to Advanced
**Topics Covered:** All 16 architecture patterns from Chapter 13

