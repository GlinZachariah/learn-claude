# Testing & Quality Assurance

## Unit Testing with Mockito

```java
@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private UserService userService;

    @Test
    public void testCreateUser() {
        CreateUserRequest request = new CreateUserRequest("john@example.com");
        User user = new User();
        user.setId(1L);
        user.setEmail("john@example.com");

        when(userRepository.save(any(User.class))).thenReturn(user);

        UserDTO result = userService.create(request);

        assertThat(result.getId()).isEqualTo(1L);
        verify(userRepository).save(any(User.class));
        verify(emailService).sendWelcomeEmail("john@example.com");
    }
}
```

## Integration Testing

```java
@SpringBootTest
@AutoConfigureMockMvc
public class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Test
    public void testGetUser() throws Exception {
        User user = new User();
        user.setEmail("test@example.com");
        userRepository.save(user);

        mockMvc.perform(get("/api/users/" + user.getId())
                .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }
}

@WebMvcTest(UserController.class)
public class UserControllerWebMvcTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    public void testCreateUser() throws Exception {
        CreateUserRequest request = new CreateUserRequest("john@example.com");
        UserDTO user = new UserDTO();
        user.setId(1L);

        when(userService.create(any())).thenReturn(user);

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(new ObjectMapper().writeValueAsString(request)))
            .andExpect(status().isCreated());
    }
}
```

