# REST APIs & Web Services

## RESTful Design Principles

```java
// RESTful Resource Design
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    // GET /api/v1/users - List all
    @GetMapping
    public ResponseEntity<List<UserDTO>> listUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(userService.getUsers(page, size));
    }

    // GET /api/v1/users/{id} - Get one
    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    // POST /api/v1/users - Create
    @PostMapping
    public ResponseEntity<UserDTO> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserDTO user = userService.create(request);
        return ResponseEntity
            .created(URI.create("/api/v1/users/" + user.getId()))
            .body(user);
    }

    // PUT /api/v1/users/{id} - Update full
    @PutMapping("/{id}")
    public ResponseEntity<UserDTO> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRequest request) {
        return ResponseEntity.ok(userService.update(id, request));
    }

    // PATCH /api/v1/users/{id} - Partial update
    @PatchMapping("/{id}")
    public ResponseEntity<UserDTO> partialUpdate(
            @PathVariable Long id,
            @RequestBody Map<String, Object> updates) {
        return ResponseEntity.ok(userService.patch(id, updates));
    }

    // DELETE /api/v1/users/{id} - Delete
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

## API Versioning

```java
// URL-based versioning
@RestController
@RequestMapping("/api/v1/users")
public class UserControllerV1 { }

@RestController
@RequestMapping("/api/v2/users")
public class UserControllerV2 { }

// Header-based versioning
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    @ApiVersion("1")
    public ResponseEntity<UserDTOV1> getUserV1() { }

    @GetMapping
    @ApiVersion("2")
    public ResponseEntity<UserDTOV2> getUserV2() { }
}

@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface ApiVersion {
    String value();
}
```

## Request/Response DTOs

```java
@Getter
@Setter
@NoArgsConstructor
public class CreateUserRequest {
    @NotBlank
    private String email;

    @NotBlank
    private String name;

    @NotNull
    @Min(18)
    private Integer age;
}

@Getter
@Setter
public class UserDTO {
    private Long id;
    private String email;
    private String name;
    private Integer age;
    private LocalDateTime createdAt;
}

// Mapper
@Component
public class UserMapper {

    public UserDTO toDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setName(user.getName());
        dto.setAge(user.getAge());
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }

    public User toEntity(CreateUserRequest request) {
        User user = new User();
        user.setEmail(request.getEmail());
        user.setName(request.getName());
        user.setAge(request.getAge());
        return user;
    }
}
```

## HTTP Status Codes & Headers

```java
@RestController
public class ResponseController {

    // 200 OK - Successful GET
    @GetMapping("/users/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(userService.findById(id).orElseThrow());
    }

    // 201 Created - Successful POST
    @PostMapping("/users")
    public ResponseEntity<UserDTO> createUser(@RequestBody UserDTO dto) {
        UserDTO created = userService.save(dto);
        return ResponseEntity
            .created(URI.create("/users/" + created.getId()))
            .body(created);
    }

    // 204 No Content - Successful DELETE
    @DeleteMapping("/users/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.noContent().build();
    }

    // 400 Bad Request - Validation error
    @PostMapping("/users")
    public ResponseEntity<ErrorResponse> badRequest(@RequestBody UserDTO dto) {
        return ResponseEntity.badRequest()
            .body(new ErrorResponse("Invalid input"));
    }

    // 401 Unauthorized - Missing authentication
    @GetMapping("/secure")
    public ResponseEntity<String> secure() {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body("Authentication required");
    }

    // 403 Forbidden - Insufficient permissions
    @GetMapping("/admin")
    public ResponseEntity<String> admin() {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
            .body("Access denied");
    }

    // 404 Not Found
    @GetMapping("/users/{id}")
    public ResponseEntity<Void> notFound() {
        return ResponseEntity.notFound().build();
    }

    // 500 Internal Server Error
    @GetMapping("/error")
    public ResponseEntity<ErrorResponse> serverError() {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse("Server error"));
    }
}
```

## OpenAPI/Swagger Documentation

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.0.0</version>
</dependency>
```

```java
@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("User API")
                .version("1.0.0")
                .description("User management API"))
            .addServersItem(new Server().url("http://localhost:8080"))
            .addServersItem(new Server().url("https://api.example.com"));
    }
}

@RestController
@RequestMapping("/api/users")
@Tag(name = "Users", description = "User management endpoints")
public class UserController {

    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID", description = "Retrieve a user by their ID")
    @ApiResponse(responseCode = "200", description = "User found")
    @ApiResponse(responseCode = "404", description = "User not found")
    public ResponseEntity<UserDTO> getUser(
            @Parameter(description = "User ID", required = true)
            @PathVariable Long id) {
        return ResponseEntity.ok(userService.findById(id).orElseThrow());
    }
}
```

