# Spring Web MVC - Comprehensive Guide

## DispatcherServlet & Request Flow

The `DispatcherServlet` is the central component that handles all HTTP requests.

```
HTTP Request
     │
     ▼
┌──────────────────────────────┐
│  DispatcherServlet           │
├──────────────────────────────┤
│ 1. Receives HTTP request     │
│ 2. Maps to handler           │
│ 3. Executes handler          │
│ 4. Resolves view             │
│ 5. Renders response          │
└──────────────────────────────┘
     │
     ▼
HTTP Response
```

### Complete Request Processing Pipeline

```java
// Step 1: DispatcherServlet receives request
// Step 2: HandlerMapping finds matching controller
// Step 3: HandlerAdapter executes controller method
// Step 4: ViewResolver resolves view name to View
// Step 5: View renders response

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Bean
    public DispatcherServlet dispatcherServlet() {
        DispatcherServlet servlet = new DispatcherServlet();
        servlet.setThrowExceptionIfNoHandlerFound(true);
        return servlet;
    }

    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        registry.jsp("/WEB-INF/views/", ".jsp");
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new TimingInterceptor())
            .addPathPatterns("/**");
    }
}
```

## Controllers Deep Dive

```java
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "http://localhost:3000")
public class UserController {

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(
            @PathVariable Long id,
            @RequestParam(defaultValue = "true") boolean includeOrders) {

        User user = userService.findById(id);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        UserResponse response = userMapper.toResponse(user);
        if (includeOrders) {
            response.setOrders(user.getOrders());
        }

        return ResponseEntity.ok()
            .cacheControl(CacheControl.maxAge(1, TimeUnit.MINUTES))
            .body(response);
    }

    @PostMapping
    public ResponseEntity<UserResponse> createUser(
            @Valid @RequestBody CreateUserRequest request,
            UriComponentsBuilder uriBuilder) {

        User user = userService.create(request);

        return ResponseEntity
            .created(uriBuilder.path("/api/users/{id}")
                .buildAndExpand(user.getId())
                .toUri())
            .body(userMapper.toResponse(user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRequest request) {

        User user = userService.update(id, request);
        return ResponseEntity.ok(userMapper.toResponse(user));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

## Request/Response Handling

### Content Negotiation

```java
@Configuration
public class ContentNegotiationConfig implements WebMvcConfigurer {

    @Override
    public void configureContentNegotiation(ContentNegotiationConfigurer config) {
        config
            .defaultContentType(MediaType.APPLICATION_JSON)
            .favorParameter(true)
            .parameterName("format")
            .ignoreAcceptHeader(false)
            .useRegisteredExtensionsOnly(false)
            .mediaType("json", MediaType.APPLICATION_JSON)
            .mediaType("xml", MediaType.APPLICATION_XML)
            .mediaType("csv", MediaType.valueOf("text/csv"));
    }
}

@RestController
@RequestMapping("/api/data")
public class DataController {

    @GetMapping
    public ResponseEntity<List<Data>> getData() {
        // Returns JSON, XML, or CSV based on Accept header or ?format=xml
        return ResponseEntity.ok(dataService.getAll());
    }
}
```

### Message Converters

```java
@Configuration
public class MessageConverterConfig implements WebMvcConfigurer {

    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        // Add custom converters
        converters.add(new MappingJackson2HttpMessageConverter(
            jacksonObjectMapper()
        ));

        converters.add(new HttpMessageConverter<Data>() {
            @Override
            public boolean canRead(Class<?> clazz, MediaType mediaType) {
                return clazz.equals(Data.class) &&
                       mediaType.equals(MediaType.valueOf("text/plain"));
            }

            @Override
            public Data read(Class<? extends Data> clazz,
                           HttpInputMessage message) throws IOException {
                // Custom parsing logic
                return parseData(message.getBody());
            }

            @Override
            public boolean canWrite(Class<?> clazz, MediaType mediaType) {
                return clazz.equals(Data.class);
            }

            @Override
            public void write(Data data, MediaType contentType,
                            HttpOutputMessage message) throws IOException {
                message.getBody().write(customSerialize(data).getBytes());
            }
        });
    }

    @Bean
    public ObjectMapper jacksonObjectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        mapper.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        return mapper;
    }
}
```

## Interceptors & Filters

```java
public class AuthenticationInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request,
                            HttpServletResponse response,
                            Object handler) throws Exception {
        String token = request.getHeader("Authorization");

        if (token == null || !validateToken(token)) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            return false;
        }

        // Store in request for later use
        request.setAttribute("userId", extractUserId(token));
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request,
                          HttpServletResponse response,
                          Object handler,
                          ModelAndView modelAndView) throws Exception {
        // Log response status
        System.out.println("Response Status: " + response.getStatus());
    }

    @Override
    public void afterCompletion(HttpServletRequest request,
                               HttpServletResponse response,
                               Object handler,
                               Exception ex) throws Exception {
        if (ex != null) {
            System.err.println("Exception occurred: " + ex.getMessage());
        }
    }
}

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new AuthenticationInterceptor())
            .addPathPatterns("/**")
            .excludePathPatterns("/api/auth/login", "/api/auth/register");
    }
}

// Filter vs Interceptor
@Component
public class LoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                   HttpServletResponse response,
                                   FilterChain chain) throws ServletException, IOException {

        long start = System.currentTimeMillis();

        try {
            chain.doFilter(request, response);
        } finally {
            long duration = System.currentTimeMillis() - start;
            System.out.println(request.getMethod() + " " + request.getRequestURI() +
                             " - " + duration + "ms");
        }
    }
}
```

## Validation & Exception Handling

```java
public class CreateUserRequest {
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be 2-100 characters")
    private String name;

    @NotNull(message = "Age is required")
    @Min(value = 18, message = "User must be at least 18")
    @Max(value = 120, message = "Age must be realistic")
    private Integer age;

    @Positive(message = "Balance must be positive")
    private BigDecimal balance;
}

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex) {

        Map<String, String> errors = new HashMap<>();

        ex.getBindingResult().getFieldErrors().forEach(error ->
            errors.put(error.getField(), error.getDefaultMessage())
        );

        ValidationErrorResponse response = new ValidationErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            errors,
            LocalDateTime.now()
        );

        return ResponseEntity.badRequest().body(response);
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(
                HttpStatus.NOT_FOUND.value(),
                "Not found",
                ex.getMessage(),
                LocalDateTime.now()
            ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "Internal error",
                "An unexpected error occurred",
                LocalDateTime.now()
            ));
    }
}
```

## Advanced MVC Features

### Content Caching

```java
@Configuration
public class CacheConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static/**")
            .addResourceLocations("classpath:/static/")
            .setCacheControl(CacheControl.maxAge(365, TimeUnit.DAYS))
            .resourceChain(true)
            .addResolver(new VersionResourceResolver()
                .addFixedVersionStrategy("1.0.0", "/**"))
            .addTransformer(new AppCacheManifestTransformer());
    }
}
```

### CORS Configuration

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
            .allowedOrigins("http://localhost:3000", "https://example.com")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("Content-Type", "Authorization")
            .exposedHeaders("X-Custom-Header")
            .allowCredentials(true)
            .maxAge(3600);
    }
}
```

### Async Request Processing

```java
@RestController
@RequestMapping("/api/reports")
public class ReportController {

    @GetMapping("/{id}")
    public CompletableFuture<ResponseEntity<ReportResponse>> generateReport(
            @PathVariable Long id) {

        return reportService.generateAsync(id)
            .thenApply(report -> ResponseEntity.ok(report))
            .exceptionally(ex -> ResponseEntity.status(500).build());
    }

    @GetMapping("/{id}")
    public DeferredResult<ResponseEntity<ReportResponse>> generateReportDeferred(
            @PathVariable Long id) {

        DeferredResult<ResponseEntity<ReportResponse>> result =
            new DeferredResult<>(5000L);

        executorService.execute(() -> {
            try {
                ReportResponse report = reportService.generate(id);
                result.setResult(ResponseEntity.ok(report));
            } catch (Exception ex) {
                result.setErrorResult(ResponseEntity.status(500).build());
            }
        });

        return result;
    }
}
```

---

## Summary

Spring Web MVC provides:
- DispatcherServlet for central request handling
- Annotation-driven controllers
- Flexible content negotiation
- Comprehensive exception handling
- Interceptors for cross-cutting concerns
- Validation framework integration
- Async request processing
- CORS & caching support

---

## Next Topics

- Spring Data for data persistence
- Spring Security for authentication
- Spring Integration for messaging
- Reactive Spring with WebFlux
