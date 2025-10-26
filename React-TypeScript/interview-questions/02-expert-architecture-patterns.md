# React with TypeScript - Expert Architecture Patterns

## Pattern 1: Feature-Based Folder Structure with Module Boundaries

**Problem:** As applications grow, it becomes difficult to maintain clear module boundaries and dependencies between features.

**Solution:** Organize code by features with clear entry points and internal/external boundaries.

```typescript
// src/features/auth/
├── index.ts              # Public API - only export what's needed
├── components/           # Components only used in this feature
│   ├── LoginForm.tsx
│   └── RegisterForm.tsx
├── hooks/               # Custom hooks for this feature
│   └── useAuth.ts
├── services/            # API calls for this feature
│   └── authService.ts
├── types/              # Types used in this feature
│   └── auth.types.ts
├── context/            # Context providers for this feature
│   └── AuthContext.tsx
└── store/              # State management for this feature
    └── authSlice.ts

// src/features/auth/index.ts
export { AuthProvider } from './context/AuthContext';
export { useAuth } from './hooks/useAuth';
export type { User, AuthState } from './types/auth.types';

// Other modules can only import from index.ts
// ✅ import { useAuth, AuthProvider } from 'features/auth';
// ❌ import { useAuth } from 'features/auth/hooks/useAuth';
```

**Benefits:**
- Clear module boundaries
- Easy to identify what's exported
- Prevents circular dependencies
- Easy to move or delete features
- Scalable organization

---

## Pattern 2: Container and Presentational Components

**Problem:** Components mix business logic with presentation, making them hard to test and reuse.

**Solution:** Separate smart (container) and dumb (presentational) components.

```typescript
// Presentational Component (Pure, reusable, testable)
interface UserListProps {
    users: User[];
    loading: boolean;
    onSelectUser: (user: User) => void;
    onDeleteUser: (id: string) => void;
}

const UserListPresentation: React.FC<UserListProps> = ({
    users,
    loading,
    onSelectUser,
    onDeleteUser,
}) => {
    if (loading) return <Spinner />;

    return (
        <ul className="user-list">
            {users.map(user => (
                <li key={user.id} className="user-item">
                    <span onClick={() => onSelectUser(user)}>{user.name}</span>
                    <button onClick={() => onDeleteUser(user.id)}>Delete</button>
                </li>
            ))}
        </ul>
    );
};

// Container Component (Smart, manages state and logic)
const UserListContainer: React.FC = () => {
    const { users, loading, selectUser, deleteUser } = useUserStore();

    const handleSelectUser = React.useCallback((user: User) => {
        selectUser(user.id);
    }, [selectUser]);

    const handleDeleteUser = React.useCallback(async (id: string) => {
        if (window.confirm('Delete user?')) {
            await deleteUser(id);
        }
    }, [deleteUser]);

    return (
        <UserListPresentation
            users={users}
            loading={loading}
            onSelectUser={handleSelectUser}
            onDeleteUser={handleDeleteUser}
        />
    );
};

// Export container, hide presentational component
export { UserListContainer as UserList };
```

**Benefits:**
- Presentational components are highly reusable
- Easy to test (no dependencies)
- Easy to refactor UI without touching logic
- Clear separation of concerns
- Easier to style components

---

## Pattern 3: Custom Hooks for Logic Reusability

**Problem:** Replicating similar state and effect logic across components leads to duplication.

**Solution:** Extract common logic into custom hooks.

```typescript
// Custom hook encapsulating async data fetching logic
interface UseAsyncDataOptions<T> {
    url: string;
    enabled?: boolean;
    cacheTime?: number;
}

interface UseAsyncDataState<T> {
    data: T | null;
    loading: boolean;
    error: Error | null;
    refetch: () => Promise<void>;
}

const cache = new Map<string, { data: any; timestamp: number }>();

function useAsyncData<T>({
    url,
    enabled = true,
    cacheTime = 5 * 60 * 1000, // 5 minutes
}: UseAsyncDataOptions<T>): UseAsyncDataState<T> {
    const [state, setState] = React.useState<Omit<UseAsyncDataState<T>, 'refetch'>>({
        data: null,
        loading: true,
        error: null,
    });

    const refetch = React.useCallback(async () => {
        if (!enabled) return;

        // Check cache
        const cached = cache.get(url);
        if (cached && Date.now() - cached.timestamp < cacheTime) {
            setState({ data: cached.data, loading: false, error: null });
            return;
        }

        try {
            setState(prev => ({ ...prev, loading: true }));
            const response = await fetch(url);
            if (!response.ok) throw new Error('Fetch failed');
            const data: T = await response.json();
            cache.set(url, { data, timestamp: Date.now() });
            setState({ data, loading: false, error: null });
        } catch (error) {
            setState({
                data: null,
                loading: false,
                error: error instanceof Error ? error : new Error(String(error)),
            });
        }
    }, [url, enabled, cacheTime]);

    React.useEffect(() => {
        refetch();
    }, [refetch]);

    return { ...state, refetch };
}

// Usage in multiple components
const UserProfile: React.FC<{ userId: string }> = ({ userId }) => {
    const { data: user, loading, error } = useAsyncData<User>({
        url: `/api/users/${userId}`,
    });

    if (loading) return <Spinner />;
    if (error) return <Error message={error.message} />;
    return <div>{user?.name}</div>;
};

const ProductList: React.FC = () => {
    const { data: products, loading, refetch } = useAsyncData<Product[]>({
        url: '/api/products',
        cacheTime: 10 * 60 * 1000,
    });

    return (
        <div>
            {loading ? <Spinner /> : products?.map(p => <ProductCard key={p.id} product={p} />)}
            <button onClick={refetch}>Refresh</button>
        </div>
    );
};
```

**Benefits:**
- Eliminates code duplication
- Logic is testable in isolation
- Easy to update logic in one place
- Reusable across components
- Clear single responsibility

---

## Pattern 4: Compound Components with Scoped State

**Problem:** Components need to share internal state, but props drilling makes it cumbersome.

**Solution:** Use compound component pattern with context for local state.

```typescript
// Compound component for Tab functionality
interface TabsContextType {
    activeTab: string;
    setActiveTab: (tabId: string) => void;
}

const TabsContext = React.createContext<TabsContextType | undefined>(undefined);

// Main Tabs component
interface TabsProps {
    defaultTab: string;
    children: React.ReactNode;
    onChange?: (tabId: string) => void;
}

const Tabs: React.FC<TabsProps> = ({ defaultTab, children, onChange }) => {
    const [activeTab, setActiveTab] = React.useState(defaultTab);

    const handleTabChange = (tabId: string) => {
        setActiveTab(tabId);
        onChange?.(tabId);
    };

    return (
        <TabsContext.Provider value={{ activeTab, setActiveTab: handleTabChange }}>
            {children}
        </TabsContext.Provider>
    );
};

// TabList compound component
const TabList: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <div role="tablist" className="tab-list">
        {children}
    </div>
);

// TabButton compound component
interface TabButtonProps {
    id: string;
    label: string;
}

const TabButton: React.FC<TabButtonProps> = ({ id, label }) => {
    const context = React.useContext(TabsContext);
    if (!context) throw new Error('TabButton must be used within Tabs');

    const { activeTab, setActiveTab } = context;
    const isActive = activeTab === id;

    return (
        <button
            role="tab"
            aria-selected={isActive}
            className={isActive ? 'active' : ''}
            onClick={() => setActiveTab(id)}
        >
            {label}
        </button>
    );
};

// TabPanel compound component
interface TabPanelProps {
    id: string;
    children: React.ReactNode;
}

const TabPanel: React.FC<TabPanelProps> = ({ id, children }) => {
    const context = React.useContext(TabsContext);
    if (!context) throw new Error('TabPanel must be used within Tabs');

    const { activeTab } = context;
    if (activeTab !== id) return null;

    return (
        <div role="tabpanel" className="tab-panel">
            {children}
        </div>
    );
};

// Attach compound components
Tabs.List = TabList;
Tabs.Button = TabButton;
Tabs.Panel = TabPanel;

// Usage - Simple and readable API
<Tabs defaultTab="tab1" onChange={(id) => console.log('Tab changed:', id)}>
    <Tabs.List>
        <Tabs.Button id="tab1" label="Overview" />
        <Tabs.Button id="tab2" label="Details" />
        <Tabs.Button id="tab3" label="Settings" />
    </Tabs.List>
    <Tabs.Panel id="tab1">Overview content</Tabs.Panel>
    <Tabs.Panel id="tab2">Details content</Tabs.Panel>
    <Tabs.Panel id="tab3">Settings content</Tabs.Panel>
</Tabs>
```

**Benefits:**
- Intuitive API with clear structure
- No props drilling within compound
- Encapsulated state management
- Flexible composition
- Type-safe relationships

---

## Pattern 5: Render Props for Advanced Composition

**Problem:** HOCs cause wrapper hell and poor TypeScript inference.

**Solution:** Use render props pattern for more flexible composition.

```typescript
// Generic render props component for data fetching
interface RenderPropsProps<T> {
    data: T;
    loading: boolean;
    error: Error | null;
    retry: () => void;
}

interface DataFetcherProps<T> {
    url: string;
    render: (props: RenderPropsProps<T>) => React.ReactNode;
    onSuccess?: (data: T) => void;
    onError?: (error: Error) => void;
}

const DataFetcher = <T,>({
    url,
    render,
    onSuccess,
    onError,
}: DataFetcherProps<T>): React.ReactElement => {
    const [state, setState] = React.useState<{
        data: T | null;
        loading: boolean;
        error: Error | null;
    }>({
        data: null,
        loading: true,
        error: null,
    });

    const retry = React.useCallback(async () => {
        try {
            setState({ data: null, loading: true, error: null });
            const response = await fetch(url);
            const data = (await response.json()) as T;
            setState({ data, loading: false, error: null });
            onSuccess?.(data);
        } catch (error) {
            const err = error instanceof Error ? error : new Error(String(error));
            setState({ data: null, loading: false, error: err });
            onError?.(err);
        }
    }, [url, onSuccess, onError]);

    React.useEffect(() => {
        retry();
    }, [retry]);

    return (
        <>
            {render({
                data: state.data as T,
                loading: state.loading,
                error: state.error,
                retry,
            })}
        </>
    );
};

// Usage - Very flexible
<DataFetcher<User>
    url="/api/user/123"
    render={({ data, loading, error, retry }) => (
        <>
            {loading && <Spinner />}
            {error && (
                <div>
                    Error: {error.message}
                    <button onClick={retry}>Retry</button>
                </div>
            )}
            {data && <UserProfile user={data} />}
        </>
    )}
    onSuccess={(user) => console.log('Loaded:', user)}
    onError={(error) => console.error('Error:', error)}
/>
```

**Benefits:**
- More flexible than HOCs
- Better TypeScript inference
- No wrapper component overhead
- Access to parent props in render function
- Clear data flow

---

## Pattern 6: Higher-Order Components for Cross-Cutting Concerns

**Problem:** Need to add functionality like authentication, theme, or analytics to many components.

**Solution:** Use HOCs for consistent functionality across components.

```typescript
// HOC for authentication
interface WithAuthProps {
    user: User | null;
}

function withAuth<P extends WithAuthProps>(
    WrappedComponent: React.ComponentType<P>,
    requiredRole?: string
) {
    return (props: Omit<P, 'user'>) => {
        const { user } = useAuth();

        // Check authentication
        if (!user) {
            return <Navigate to="/login" />;
        }

        // Check role if specified
        if (requiredRole && user.role !== requiredRole) {
            return <Unauthorized />;
        }

        return <WrappedComponent {...(props as P)} user={user} />;
    };
}

// HOC for theme
interface WithThemeProps {
    theme: Theme;
    toggleTheme: () => void;
}

function withTheme<P extends WithThemeProps>(WrappedComponent: React.ComponentType<P>) {
    return (props: Omit<P, 'theme' | 'toggleTheme'>) => {
        const { theme, toggleTheme } = useTheme();

        return (
            <WrappedComponent
                {...(props as P)}
                theme={theme}
                toggleTheme={toggleTheme}
            />
        );
    };
}

// HOC for error boundary
function withErrorBoundary<P,>(
    WrappedComponent: React.ComponentType<P>,
    fallback?: React.ReactNode
) {
    return (props: P) => (
        <ErrorBoundary fallback={fallback}>
            <WrappedComponent {...props} />
        </ErrorBoundary>
    );
}

// HOC for loading state
interface WithLoadingProps {
    isLoading: boolean;
}

function withLoading<P extends WithLoadingProps>(WrappedComponent: React.ComponentType<P>) {
    return (props: Omit<P, 'isLoading'> & { isLoading: boolean }) => {
        if (props.isLoading) return <Spinner />;
        return <WrappedComponent {...(props as P)} isLoading={false} />;
    };
}

// Composing HOCs
const Dashboard: React.FC<WithAuthProps & WithThemeProps> = ({ user, theme }) => (
    <div style={{ background: theme.background }}>
        <h1>Welcome, {user.name}</h1>
    </div>
);

// Apply HOCs in order
const ProtectedDashboard = withAuth(
    withTheme(
        withErrorBoundary(Dashboard, <div>Dashboard Error</div>)
    ),
    'admin'
);

// Usage
<ProtectedDashboard />
```

**Benefits:**
- Consistent functionality across components
- Separation of concerns
- Easy to test (can test HOC separately)
- Composable enhancements
- Clear intent through naming (with*)

---

## Pattern 7: Strategy Pattern for Flexible Algorithms

**Problem:** Different algorithms are needed based on runtime conditions.

**Solution:** Implement strategy pattern to switch algorithms dynamically.

```typescript
// Strategy interface
interface SortStrategy<T> {
    sort(items: T[]): T[];
}

// Concrete strategies
class AscendingSortStrategy<T> implements SortStrategy<T> {
    constructor(private compareFn: (a: T, b: T) => number) {}

    sort(items: T[]): T[] {
        return [...items].sort(this.compareFn);
    }
}

class DescendingSortStrategy<T> implements SortStrategy<T> {
    constructor(private compareFn: (a: T, b: T) => number) {}

    sort(items: T[]): T[] {
        return [...items].sort(this.compareFn).reverse();
    }
}

class RandomSortStrategy<T> implements SortStrategy<T> {
    sort(items: T[]): T[] {
        return [...items].sort(() => Math.random() - 0.5);
    }
}

// Context that uses strategy
interface SortableListProps<T> {
    items: T[];
    strategy: SortStrategy<T>;
    render: (items: T[]) => React.ReactNode;
}

function SortableList<T>({ items, strategy, render }: SortableListProps<T>) {
    const sortedItems = React.useMemo(() => strategy.sort(items), [items, strategy]);
    return <>{render(sortedItems)}</>;
}

// Usage
interface Product {
    name: string;
    price: number;
}

const products: Product[] = [
    { name: 'A', price: 100 },
    { name: 'B', price: 50 },
    { name: 'C', price: 150 },
];

const [sortBy, setSortBy] = React.useState<'asc' | 'desc' | 'random'>('asc');

const strategy = React.useMemo(() => {
    const compareFn = (a: Product, b: Product) => a.price - b.price;

    switch (sortBy) {
        case 'asc':
            return new AscendingSortStrategy(compareFn);
        case 'desc':
            return new DescendingSortStrategy(compareFn);
        case 'random':
            return new RandomSortStrategy();
    }
}, [sortBy]);

return (
    <div>
        <select value={sortBy} onChange={(e) => setSortBy(e.target.value as any)}>
            <option value="asc">Ascending</option>
            <option value="desc">Descending</option>
            <option value="random">Random</option>
        </select>

        <SortableList
            items={products}
            strategy={strategy}
            render={(sorted) =>
                sorted.map(p => <div key={p.name}>{p.name}: ${p.price}</div>)
            }
        />
    </div>
);
```

**Benefits:**
- Algorithms can be switched at runtime
- New algorithms can be added without modifying existing code
- Easy to test individual strategies
- Clear separation of algorithms
- Follows Open/Closed Principle

---

## Pattern 8: Observer Pattern for Event Management

**Problem:** Multiple components need to react to the same event without direct coupling.

**Solution:** Implement observer pattern for event management.

```typescript
// Observer interface
interface Observer<T> {
    update(data: T): void;
}

// Observable (Subject)
class EventBus<T> {
    private observers: Set<Observer<T>> = new Set();

    subscribe(observer: Observer<T>): () => void {
        this.observers.add(observer);
        return () => this.observers.delete(observer);
    }

    emit(data: T): void {
        this.observers.forEach(observer => observer.update(data));
    }

    unsubscribeAll(): void {
        this.observers.clear();
    }
}

// Type-safe event bus
type AppEvents =
    | { type: 'USER_LOGGED_IN'; userId: string }
    | { type: 'USER_LOGGED_OUT' }
    | { type: 'THEME_CHANGED'; theme: 'light' | 'dark' };

const eventBus = new EventBus<AppEvents>();

// Custom hook for subscribing to events
function useEvent<E extends AppEvents['type']>(
    eventType: E,
    handler: (event: AppEvents & { type: E }) => void
): void {
    React.useEffect(() => {
        const observer: Observer<AppEvents> = {
            update: (event) => {
                if (event.type === eventType) {
                    handler(event as AppEvents & { type: E });
                }
            },
        };

        const unsubscribe = eventBus.subscribe(observer);
        return unsubscribe;
    }, [eventType, handler]);
}

// Emit event
const handleLogin = (userId: string) => {
    eventBus.emit({ type: 'USER_LOGGED_IN', userId });
};

// Component subscribing to events
const NotificationCenter: React.FC = () => {
    const [message, setMessage] = React.useState('');

    useEvent('USER_LOGGED_IN', (event) => {
        setMessage(`User ${event.userId} logged in`);
    });

    useEvent('THEME_CHANGED', (event) => {
        setMessage(`Theme changed to ${event.theme}`);
    });

    return <div>{message}</div>;
};

const Header: React.FC = () => {
    const { user } = useAuth();

    React.useEffect(() => {
        if (user) {
            eventBus.emit({ type: 'USER_LOGGED_IN', userId: user.id });
        }
    }, [user]);

    return <header>{user?.name}</header>;
};
```

**Benefits:**
- Loose coupling between components
- Components don't need to know about each other
- Easy to add new subscribers
- Easy to test event handling
- Clear event flow

---

## Pattern 9: Facade Pattern for Complex APIs

**Problem:** Complex API with many operations is hard to use and understand.

**Solution:** Provide a simplified facade over complex subsystem.

```typescript
// Complex API operations spread across services
class UserService {
    async getUser(id: string): Promise<User> { /* ... */ }
    async updateUser(user: User): Promise<void> { /* ... */ }
}

class PermissionService {
    async checkPermission(userId: string, action: string): Promise<boolean> { /* ... */ }
}

class AuditService {
    async logAction(userId: string, action: string): Promise<void> { /* ... */ }
}

class NotificationService {
    async notifyUser(userId: string, message: string): Promise<void> { /* ... */ }
}

// Facade simplifies the API
class UserManagementFacade {
    private userService = new UserService();
    private permissionService = new PermissionService();
    private auditService = new AuditService();
    private notificationService = new NotificationService();

    async updateUserIfAllowed(userId: string, updates: Partial<User>): Promise<void> {
        // Check permission
        const hasPermission = await this.permissionService.checkPermission(userId, 'update_user');
        if (!hasPermission) {
            throw new Error('No permission');
        }

        // Get current user
        const user = await this.userService.getUser(userId);

        // Update user
        await this.userService.updateUser({ ...user, ...updates });

        // Log action
        await this.auditService.logAction(userId, 'update_user');

        // Notify user
        await this.notificationService.notifyUser(userId, 'Your profile was updated');
    }

    async deleteUserIfAllowed(userId: string): Promise<void> {
        // Check permission
        const hasPermission = await this.permissionService.checkPermission(userId, 'delete_user');
        if (!hasPermission) {
            throw new Error('No permission');
        }

        // More complex logic...
        await this.auditService.logAction(userId, 'delete_user');
        // etc.
    }
}

// Simple usage in React
const userManagement = new UserManagementFacade();

const UserEditor: React.FC<{ userId: string }> = ({ userId }) => {
    const [loading, setLoading] = React.useState(false);

    const handleUpdate = async (name: string) => {
        try {
            setLoading(true);
            await userManagement.updateUserIfAllowed(userId, { name });
        } catch (error) {
            console.error('Failed to update:', error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            <input
                type="text"
                onBlur={(e) => handleUpdate(e.target.value)}
                disabled={loading}
            />
        </div>
    );
};
```

**Benefits:**
- Simplified API for clients
- Encapsulates complexity
- Easy to refactor internal services
- Improves code readability
- Reduces dependencies

---

## Pattern 10: Dependency Injection for Testability

**Problem:** Hard-coded dependencies make testing difficult.

**Solution:** Inject dependencies to improve testability and flexibility.

```typescript
// Services with dependencies
interface IUserRepository {
    getUser(id: string): Promise<User>;
    saveUser(user: User): Promise<void>;
}

interface ILogger {
    log(message: string): void;
    error(message: string, error?: Error): void;
}

class UserRepository implements IUserRepository {
    async getUser(id: string): Promise<User> {
        const response = await fetch(`/api/users/${id}`);
        return response.json();
    }

    async saveUser(user: User): Promise<void> {
        await fetch(`/api/users/${user.id}`, {
            method: 'PUT',
            body: JSON.stringify(user),
        });
    }
}

class ConsoleLogger implements ILogger {
    log(message: string) {
        console.log(message);
    }

    error(message: string, error?: Error) {
        console.error(message, error);
    }
}

// Service that depends on injected dependencies
class UserService {
    constructor(private repo: IUserRepository, private logger: ILogger) {}

    async getAndLogUser(id: string): Promise<User | null> {
        try {
            this.logger.log(`Fetching user ${id}`);
            const user = await this.repo.getUser(id);
            this.logger.log(`User ${id} fetched successfully`);
            return user;
        } catch (error) {
            this.logger.error(`Failed to fetch user ${id}`, error instanceof Error ? error : undefined);
            return null;
        }
    }

    async updateUser(user: User): Promise<void> {
        this.logger.log(`Updating user ${user.id}`);
        await this.repo.saveUser(user);
        this.logger.log(`User ${user.id} updated`);
    }
}

// Context for dependency injection
interface DIContainer {
    userRepository: IUserRepository;
    logger: ILogger;
    userService: UserService;
}

const DIContext = React.createContext<DIContainer | undefined>(undefined);

// Provider
const DIProvider: React.FC<{ children: React.ReactNode; container?: DIContainer }> = ({
    children,
    container,
}) => {
    const defaultContainer: DIContainer = {
        userRepository: new UserRepository(),
        logger: new ConsoleLogger(),
        userService: new UserService(
            new UserRepository(),
            new ConsoleLogger()
        ),
    };

    return (
        <DIContext.Provider value={container || defaultContainer}>
            {children}
        </DIContext.Provider>
    );
};

// Hook to access services
function useDI(): DIContainer {
    const context = React.useContext(DIContext);
    if (!context) throw new Error('DIProvider not found');
    return context;
}

// Usage in component
const UserProfile: React.FC<{ userId: string }> = ({ userId }) => {
    const { userService } = useDI();
    const [user, setUser] = React.useState<User | null>(null);

    React.useEffect(() => {
        userService.getAndLogUser(userId).then(setUser);
    }, [userId, userService]);

    return <div>{user?.name}</div>;
};

// Testing with mock dependencies
describe('UserService', () => {
    it('should log and save user', async () => {
        const mockRepo: IUserRepository = {
            getUser: async () => ({ id: '1', name: 'John' }),
            saveUser: async () => {},
        };

        const mockLogger: ILogger = {
            log: jest.fn(),
            error: jest.fn(),
        };

        const service = new UserService(mockRepo, mockLogger);
        const user = await service.getAndLogUser('1');

        expect(mockLogger.log).toHaveBeenCalledWith('Fetching user 1');
        expect(user?.name).toBe('John');
    });
});
```

**Benefits:**
- Easy to test with mock dependencies
- Flexible to swap implementations
- Clear dependency graph
- Follows SOLID principles
- Better separation of concerns

---

## Pattern 11: Builder Pattern for Complex Objects

**Problem:** Creating complex objects with many optional parameters is tedious and error-prone.

**Solution:** Use builder pattern to construct objects step by step.

```typescript
// Complex query object
interface Query {
    filters: Record<string, any>;
    sorting: Array<{ field: string; order: 'asc' | 'desc' }>;
    pagination: { page: number; limit: number };
}

// Builder for query construction
class QueryBuilder {
    private filters: Record<string, any> = {};
    private sorting: Array<{ field: string; order: 'asc' | 'desc' }> = [];
    private page = 1;
    private limit = 10;

    addFilter(field: string, value: any): this {
        this.filters[field] = value;
        return this;
    }

    addSort(field: string, order: 'asc' | 'desc' = 'asc'): this {
        this.sorting.push({ field, order });
        return this;
    }

    setPage(page: number): this {
        this.page = page;
        return this;
    }

    setLimit(limit: number): this {
        this.limit = limit;
        return this;
    }

    build(): Query {
        return {
            filters: this.filters,
            sorting: this.sorting,
            pagination: { page: this.page, limit: this.limit },
        };
    }
}

// React component using builder
const SearchProducts: React.FC = () => {
    const [query, setQuery] = React.useState<Query | null>(null);

    const handleSearch = (filters: Record<string, any>, sortBy?: string) => {
        const built = new QueryBuilder()
            .addFilter('category', filters.category)
            .addFilter('priceMin', filters.priceMin)
            .addFilter('priceMax', filters.priceMax)
            .addSort(sortBy || 'name', 'asc')
            .setPage(1)
            .setLimit(20)
            .build();

        setQuery(built);
    };

    return (
        <div>
            <SearchForm onSearch={handleSearch} />
            {query && <ResultsList query={query} />}
        </div>
    );
};

// More fluent API using proxy pattern
class QueryBuilderProxy {
    private builder = new QueryBuilder();

    constructor(initializer?: (builder: QueryBuilder) => void) {
        initializer?.(this.builder);
    }

    static create(initializer?: (builder: QueryBuilder) => void): QueryBuilderProxy {
        return new QueryBuilderProxy(initializer);
    }

    filter(field: string, value: any): this {
        this.builder.addFilter(field, value);
        return this;
    }

    sort(field: string, order?: 'asc' | 'desc'): this {
        this.builder.addSort(field, order);
        return this;
    }

    page(page: number): this {
        this.builder.setPage(page);
        return this;
    }

    limit(limit: number): this {
        this.builder.setLimit(limit);
        return this;
    }

    build(): Query {
        return this.builder.build();
    }
}

// Usage
const query = QueryBuilderProxy.create()
    .filter('category', 'electronics')
    .filter('inStock', true)
    .sort('price', 'asc')
    .sort('rating', 'desc')
    .page(1)
    .limit(20)
    .build();
```

**Benefits:**
- Clear, readable object construction
- Type-safe
- Fluent API
- Easy to add validation
- Prevents invalid states

---

## Pattern 12: Adapter Pattern for Legacy Integration

**Problem:** Need to use legacy code or third-party APIs with incompatible interfaces.

**Solution:** Adapt interfaces using adapter pattern.

```typescript
// Legacy API with incompatible interface
class LegacyUserAPI {
    getInfo(userId: string): any {
        return {
            uID: userId,
            uName: 'John Doe',
            uEmail: 'john@example.com',
        };
    }

    setInfo(userId: string, info: any): void {
        console.log('Updating legacy system:', info);
    }
}

// Modern interface we want to use
interface ModernUserAPI {
    getUser(id: string): Promise<User>;
    updateUser(user: User): Promise<void>;
}

// Adapter to convert legacy to modern
class LegacyUserAPIAdapter implements ModernUserAPI {
    constructor(private legacy: LegacyUserAPI) {}

    async getUser(id: string): Promise<User> {
        const legacyData = this.legacy.getInfo(id);

        // Transform legacy data to modern interface
        return {
            id: legacyData.uID,
            name: legacyData.uName,
            email: legacyData.uEmail,
        };
    }

    async updateUser(user: User): Promise<void> {
        // Transform modern data to legacy format
        const legacyData = {
            uID: user.id,
            uName: user.name,
            uEmail: user.email,
        };

        this.legacy.setInfo(user.id, legacyData);
    }
}

// Use adapter in modern React code
const UserService: React.FC = () => {
    const [api] = React.useState<ModernUserAPI>(
        new LegacyUserAPIAdapter(new LegacyUserAPI())
    );

    const [user, setUser] = React.useState<User | null>(null);

    React.useEffect(() => {
        api.getUser('123').then(setUser);
    }, [api]);

    return <div>{user?.name}</div>;
};
```

**Benefits:**
- Integrates incompatible interfaces
- Isolates legacy code
- Easy to refactor away from legacy
- Type-safe wrapper
- Clean separation

---

## Summary of Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Feature-Based | Large apps hard to maintain | Module boundaries with index.ts |
| Container/Presentation | Mixed concerns | Separate smart and dumb components |
| Custom Hooks | Logic duplication | Extract to reusable hooks |
| Compound Components | Props drilling | Scoped state with context |
| Render Props | HOC wrapper hell | Flexible composition |
| Higher-Order | Cross-cutting concerns | Consistent functionality |
| Strategy | Multiple algorithms | Swap at runtime |
| Observer | Loose coupling | Event-driven architecture |
| Facade | Complex API | Simplified interface |
| Dependency Injection | Hard to test | Inject dependencies |
| Builder | Complex objects | Step-by-step construction |
| Adapter | Legacy integration | Interface conversion |

---

**Last Updated:** October 26, 2024
**Level:** Expert
**Patterns Covered:** 12 advanced architectural patterns
**Estimated Study Time:** 10-15 hours
