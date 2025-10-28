# React Architecture Interview Questions

## Part 1: Behavioral & System Design Questions

### Question 1: Design Component Architecture for Large App

**Question:** You're building a large dashboard application with 200+ components. How would you organize the architecture to ensure scalability, maintainability, and team collaboration?

**Answer:**

```
Architecture Strategy:

1. Feature-Based Structure:
   src/
   ├── features/
   │   ├── auth/
   │   ├── dashboard/
   │   ├── orders/
   │   └── users/
   ├── shared/
   │   ├── components/
   │   ├── hooks/
   │   ├── services/
   │   └── types/

2. Component Hierarchy:
   - Atomic Design (Atoms, Molecules, Organisms)
   - Smart/Container components for state
   - Presentational components for UI
   - Custom hooks for logic reuse

3. State Management:
   - Redux for global state
   - Context for feature-local state
   - Custom hooks for component state
   - Clear data flow (unidirectional)

4. Code Sharing:
   - Shared utilities and hooks
   - Component library/design system
   - Type definitions in shared/types
   - Service layer for API calls

5. Testing Strategy:
   - Unit tests for components
   - Integration tests for features
   - E2E tests for critical paths

6. Performance:
   - Code splitting by feature
   - Lazy loading components
   - Memoization for expensive renders
   - Bundle analysis

7. Team Collaboration:
   - Clear API boundaries
   - Storybook for component docs
   - Feature flag system
   - Shared linting/formatting
```

---

### Question 2: State Management Architecture Decision

**Question:** Compare Redux, Context API, and custom hooks. When would you choose each for different scenarios?

**Answer:**

| Scenario | Solution | Reason |
|----------|----------|--------|
| Global authentication | Redux | Persistence, DevTools, logging |
| Theme (light/dark) | Context + Hooks | Simple, lightweight |
| Component-local form state | useState | Simplest, no overkill |
| Complex domain state | Redux + Selectors | Normalization, derived state |
| Real-time data (WebSocket) | Custom Hook | Subscription pattern |
| Multi-step wizard | Custom Hook | Encapsulated logic |

---

### Question 3: Performance Optimization Architecture

**Question:** Your React dashboard with 10,000+ list items is rendering slowly. Design a complete optimization solution.

**Answer:**

```
Optimization Strategy:

1. Code Splitting:
   - Route-based lazy loading
   - Component code splitting
   - Async bundling

2. Rendering Optimization:
   - Virtual scrolling for lists
   - React.memo for expensive components
   - useMemo for expensive calculations
   - useCallback for stable references

3. State Management:
   - Selector memoization
   - Derived state calculation
   - Separate concerns (normalize data)
   - Avoid object creation in render

4. Data Fetching:
   - Caching strategy
   - Request deduplication
   - Pagination vs infinite scroll
   - Background updates

5. Bundle Optimization:
   - Tree shaking
   - Dynamic imports
   - Library replacements
   - Minification

6. Monitoring:
   - Lighthouse scores
   - Runtime metrics
   - User experience metrics
```

---

### Question 4: Micro-Frontends Strategy

**Question:** Your company has 5 teams building a large platform. Propose a micro-frontend architecture.

**Answer:**

```
Micro-Frontend Design:

1. Module Federation (Webpack 5):
   - Each team owns independent app
   - Shared libraries (React, utilities)
   - Dynamic module loading
   - Version compatibility management

2. Service Isolation:
   - Own routing
   - Own state management
   - Own styling
   - Own deployment

3. Communication:
   - Props for parent-child
   - Custom events for sibling
   - Shared state for global
   - URL parameters for navigation

4. Deployment:
   - Independent CI/CD
   - Feature flags for rollout
   - Versioning strategy
   - Rollback procedure

5. Challenges:
   - Dependency duplication
   - Version conflicts
   - Bundle size management
   - Testing across boundaries
```

---

### Question 5: Error Handling Architecture

**Question:** Design a comprehensive error handling strategy covering component errors, API errors, and runtime errors.

**Answer:**

```
Error Handling Layers:

1. Component Level:
   - Error Boundaries for React errors
   - try-catch for async operations
   - Validation before submission
   - User-friendly error messages

2. API Level:
   - Status code handling
   - Timeout management
   - Retry with backoff
   - Error transformation

3. Global Level:
   - Centralized error handler
   - Error reporting service
   - User notification system
   - Fallback UI

4. Specific Patterns:
   - Form validation errors
   - Authentication errors
   - Permission errors
   - Business logic errors
   - Network errors

5. Recovery Strategies:
   - Automatic retry
   - User action required
   - Graceful degradation
   - Cache fallback
```

---

## Part 2: Technical Deep-Dive Questions

### Question 6: Custom Hooks Design

**Question:** Design a custom hook that manages data fetching with caching, error handling, and loading states.

**Answer:**

```typescript
const useDataFetch = <T>(url: string, options?: FetchOptions) => {
    const [data, setData] = useState<T | null>(null);
    const [error, setError] = useState<Error | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        let isMounted = true;

        const fetchData = async () => {
            const cached = cache.get(url);
            if (cached) {
                setData(cached);
                setLoading(false);
                return;
            }

            try {
                const result = await apiClient.get<T>(url);
                if (isMounted) {
                    setData(result);
                    cache.set(url, result);
                    setError(null);
                }
            } catch (err) {
                if (isMounted) {
                    setError(err as Error);
                }
            } finally {
                if (isMounted) {
                    setLoading(false);
                }
            }
        };

        fetchData();

        return () => {
            isMounted = false;
        };
    }, [url]);

    return { data, error, loading };
};
```

---

### Question 7: State Management with Redux

**Question:** Design Redux store structure for e-commerce app with users, products, and orders.

**Answer:**

```typescript
// Normalized state structure
const store = {
    user: {
        current: User | null,
        isLoading: boolean,
        error: string | null,
    },
    products: {
        byId: { [id: string]: Product },
        allIds: string[],
        filter: FilterState,
        isLoading: boolean,
    },
    orders: {
        byId: { [id: string]: Order },
        allIds: string[],
        isLoading: boolean,
    },
    ui: {
        sidebarOpen: boolean,
        notification: Notification | null,
    },
};

// Selectors for derived data
const selectFilteredProducts = (state) =>
    state.products.allIds
        .map(id => state.products.byId[id])
        .filter(product => matchesFilter(product, state.products.filter));

const selectUserOrders = (state) =>
    state.orders.allIds
        .map(id => state.orders.byId[id])
        .filter(order => order.userId === state.user.current?.id);
```

---

### Question 8: Component Composition Patterns

**Question:** Compare render props, HOCs, and hooks. Show examples of each pattern.

**Answer:**

```typescript
// Render Props Pattern
const withDataFetching = ({ url, children }) => {
    const { data, loading } = useDataFetch(url);
    return children({ data, loading });
};

// HOC Pattern
const withTheme = (Component) => (props) => {
    const { theme } = useTheme();
    return <Component {...props} theme={theme} />;
};

// Hooks Pattern (Modern approach)
const useDataFetch = (url) => {
    // hooks implementation
};

// Hooks is generally preferred for its simplicity
```

---

### Question 9: Testing Architecture

**Question:** Design comprehensive testing strategy covering unit, integration, and E2E tests.

**Answer:**

```typescript
// Unit Test
describe('LoginForm', () => {
    it('should validate email field', () => {
        render(<LoginForm />);
        const emailInput = screen.getByLabelText(/email/i);
        fireEvent.change(emailInput, { target: { value: 'invalid' } });
        expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
    });
});

// Integration Test
describe('LoginFlow', () => {
    it('should complete login workflow', async () => {
        render(<LoginPage />);
        await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
        await userEvent.click(screen.getByRole('button'));
        expect(screen.getByText(/welcome/i)).toBeInTheDocument();
    });
});

// E2E Test (Cypress/Playwright)
describe('User Login', () => {
    it('should login and redirect to dashboard', () => {
        cy.visit('/login');
        cy.get('input[type=email]').type('test@example.com');
        cy.get('input[type=password]').type('password123');
        cy.get('button[type=submit]').click();
        cy.url().should('include', '/dashboard');
    });
});
```

---

### Question 10: Real-time Data Synchronization

**Question:** Design architecture for real-time data synchronization with WebSocket.

**Answer:**

```typescript
// Hook for WebSocket
const useWebSocket = (url: string) => {
    const [data, setData] = useState(null);
    const [isConnected, setIsConnected] = useState(false);

    useEffect(() => {
        const ws = new WebSocket(url);

        ws.onopen = () => setIsConnected(true);
        ws.onmessage = (event) => {
            const message = JSON.parse(event.data);
            setData(message);
            // Update Redux store
            dispatch(updateData(message));
        };
        ws.onclose = () => setIsConnected(false);

        return () => ws.close();
    }, [url]);

    return { data, isConnected };
};

// Usage in component
const LiveDashboard = () => {
    const { data, isConnected } = useWebSocket('wss://api.example.com/live');
    return <div>{isConnected ? 'Connected' : 'Disconnected'}</div>;
};
```

---

## Part 3: Architecture Decisions (8 Questions)

### Question 11: Component Library Decision

**Question:** Build a design system/component library for 20 products. Architecture design?

**Answer:**

```
Design System Strategy:

1. Structure:
   - Design tokens (colors, spacing, typography)
   - Base components (Button, Input, Modal)
   - Compound components (Form, Card layouts)
   - Page templates

2. Documentation:
   - Storybook for component showcase
   - Props documentation
   - Usage examples
   - Design guidelines

3. Theming:
   - CSS-in-JS or CSS variables
   - Light/dark mode support
   - Brand customization

4. Distribution:
   - npm package
   - Versioning strategy
   - Changelog management
   - Migration guides

5. Quality:
   - Visual regression testing
   - Accessibility testing
   - Performance testing
   - Type safety (TypeScript)
```

---

### Question 12: Security Architecture

**Question:** Design secure authentication and authorization in React app.

**Answer:**

```
Security Strategy:

1. Authentication:
   - JWT tokens with short expiry
   - Refresh tokens in httpOnly cookies
   - Token refresh on 401

2. Authorization:
   - Role-based access control (RBAC)
   - Permission-based access
   - Protected routes
   - Lazy load based on permissions

3. Data Security:
   - Sanitize user input
   - CSRF token validation
   - CSP headers
   - Secure headers

4. Code Security:
   - Dependency scanning
   - XSS protection
   - SQL injection prevention
   - Secret management
```

---

### Question 13: PWA Implementation

**Question:** Convert existing React app to PWA. What changes needed?

**Answer:**

```
PWA Requirements:

1. Service Worker:
   - Cache assets
   - Offline support
   - Background sync

2. Web App Manifest:
   - App metadata
   - Icons
   - Theme colors
   - Display mode

3. HTTPS:
   - Secure connections
   - Certificate management

4. Responsive Design:
   - Mobile-first approach
   - Touch interactions

5. Performance:
   - Fast load time
   - Optimized assets
   - Code splitting
```

---

### Question 14-18: Additional Technical Questions

(Due to space, shown as summary)

These would cover:
- Form state management complexity
- Handling complex nested state
- Performance bottleneck identification
- Accessibility compliance
- CI/CD pipeline for React apps

---

## Best Practices

1. **Component Design:** Favor composition over inheritance
2. **State Management:** Keep state as local as possible
3. **Performance:** Profile before optimizing
4. **Testing:** Test behavior, not implementation
5. **Error Handling:** Provide recovery options
6. **Security:** Sanitize all user input
7. **Accessibility:** WCAG 2.1 AA compliance
8. **Documentation:** Code is for humans, not just machines

---

## Interview Tips

- Show understanding of trade-offs
- Discuss real problems you've solved
- Ask clarifying questions
- Mention monitoring and observability
- Discuss team collaboration
- Show awareness of security
- Mention testing strategy
- Explain your reasoning

---

**Estimated Study Time:** 2-3 hours
**Difficulty:** Intermediate to Advanced
**Topics Covered:** Component architecture, state management, performance, security, testing

