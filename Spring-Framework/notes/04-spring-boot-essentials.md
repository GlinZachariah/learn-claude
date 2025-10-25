# Spring Boot Essentials

## Spring Boot Overview

Spring Boot simplifies Spring application development through:
- Auto-configuration
- Embedded servers
- Opinionated defaults
- Starter dependencies
- Production-ready features

## Auto-Configuration

```java
@SpringBootApplication  // Equivalent to @Configuration + @ComponentScan + @EnableAutoConfiguration
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

// @EnableAutoConfiguration analyzes classpath and:
// - Finds spring-boot-starter-* dependencies
// - Auto-configures beans based on presence of classes
// - Applies sensible defaults

// Example: If spring-boot-starter-data-jpa is present:
// - DataSource bean created
// - EntityManagerFactory configured
// - TransactionManager registered
// - JPA repositories enabled
```

## Starter Dependencies

```xml
<!-- spring-boot-starter-web -->
<!-- Includes: Spring Web, Tomcat, Jackson, Validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- spring-boot-starter-data-jpa -->
<!-- Includes: Spring Data JPA, Hibernate, Database driver -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- spring-boot-starter-security -->
<!-- Includes: Spring Security, Authentication, Authorization -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

## Application Configuration

```properties
# Server Configuration
server.port=8080
server.servlet.context-path=/api
server.error.include-message=always

# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=root
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.properties.hibernate.format_sql=true

# Logging Configuration
logging.level.root=INFO
logging.level.com.example=DEBUG
logging.pattern.console=%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n

# Application-specific
app.name=MyApplication
app.version=1.0.0
app.security.jwt-secret=your-secret-key
app.security.jwt-expiration=3600000
```

## Profiles

```properties
# application-dev.properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# application-prod.properties
spring.datasource.url=jdbc:postgresql://prod-db:5432/mydb
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQL10Dialect
spring.jpa.hibernate.ddl-auto=validate
```

```java
@Configuration
@Profile("dev")
public class DevConfig {
    @Bean
    public DataSource devDataSource() {
        return new EmbeddedDatabaseBuilder()
            .setType(EmbeddedDatabaseType.H2).build();
    }
}

@Configuration
@Profile("prod")
public class ProdConfig {
    @Bean
    public DataSource prodDataSource() {
        return createProductionDataSource();
    }
}

// Run with profile:
// java -jar app.jar --spring.profiles.active=prod
```

## Embedded Server Configuration

```java
@Configuration
public class ServerConfig implements WebServerFactoryCustomizer<TomcatServletWebServerFactory> {

    @Override
    public void customize(TomcatServletWebServerFactory factory) {
        factory.setPort(8080);
        factory.setContextPath("/api");
        factory.addErrorPages(new ErrorPage(HttpStatus.NOT_FOUND, "/error"));
        
        factory.addConnectorCustomizers(connector -> {
            Http11NioProtocol protocol = (Http11NioProtocol) connector.getProtocolHandler();
            protocol.setMaxThreads(200);
            protocol.setMinSpareThreads(10);
        });
    }
}
```

## Application Events

```java
@Component
public class ApplicationStartupListener implements ApplicationListener<ApplicationReadyEvent> {

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        System.out.println("Application started successfully");
        initializeCaches();
        warmupConnections();
    }
}

@Service
public class ApplicationEventPublisher {
    
    @Autowired
    private org.springframework.context.ApplicationEventPublisher eventPublisher;

    public void publishCustomEvent() {
        eventPublisher.publishEvent(new CustomEvent("Event data"));
    }
}

public class CustomEvent extends ApplicationEvent {
    private String data;

    public CustomEvent(String data) {
        super(this);
        this.data = data;
    }

    public String getData() { return data; }
}

@Component
public class CustomEventListener implements ApplicationListener<CustomEvent> {

    @Override
    public void onApplicationEvent(CustomEvent event) {
        System.out.println("Custom event: " + event.getData());
    }
}
```

## Actuators for Production

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

```properties
management.endpoints.web.exposure.include=health,metrics,info,env
management.endpoint.health.show-details=when-authorized
management.metrics.export.prometheus.enabled=true
```

```java
@Configuration
public class ActuatorConfig {

    @Bean
    public MeterBinder customMetrics() {
        return (registry) -> {
            Counter.builder("custom.requests")
                .description("Custom request counter")
                .register(registry);
        };
    }
}

// Available endpoints:
// GET  /actuator/health           - Application health
// GET  /actuator/metrics          - All metrics
// GET  /actuator/env              - Environment properties
// GET  /actuator/beans            - All beans
// POST /actuator/shutdown         - Graceful shutdown
```

## Custom Properties

```java
@Configuration
@ConfigurationProperties(prefix = "app")
@Getter
@Setter
public class AppProperties {
    private String name;
    private String version;
    
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
// app.version=1.0.0
// app.security.jwt-secret=secret
// app.security.token-expiration=3600000
```

---

## Summary

Spring Boot provides opinionated defaults and auto-configuration, reducing boilerplate and allowing faster development. Key features include auto-configuration, starter dependencies, embedded servers, profiles, and production-ready monitoring.

