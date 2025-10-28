# Enterprise React Architecture Patterns

## Table of Contents
1. [Component Architecture](#component-architecture)
2. [State Management Architecture](#state-management-architecture)
3. [Smart vs Presentational Components](#smart-vs-presentational-components)
4. [Container Pattern](#container-pattern)
5. [Compound Components](#compound-components)
6. [Render Props & Higher-Order Components](#render-props--higher-order-components)
7. [Micro-Frontends Architecture](#micro-frontends-architecture)
8. [Module Federation](#module-federation)
9. [Security Architecture](#security-architecture)
10. [Performance Architecture](#performance-architecture)
11. [Error Handling & Resilience](#error-handling--resilience)
12. [Testing Architecture](#testing-architecture)
13. [Real-time Data Synchronization](#real-time-data-synchronization)
14. [API Integration Patterns](#api-integration-patterns)
15. [Design Systems & Component Libraries](#design-systems--component-libraries)
16. [Progressive Web Apps](#progressive-web-apps)

---

## 1. Component Architecture

Organizing components for scalability and maintainability.

### Feature-Based Structure

```typescript
// Project structure
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── RegisterForm.tsx
│   │   │   └── AuthGuard.tsx
│   │   ├── hooks/
│   │   │   ├── useAuth.ts
│   │   │   └── useAuthGuard.ts
│   │   ├── services/
│   │   │   └── authService.ts
│   │   ├── types/
│   │   │   └── auth.types.ts
│   │   ├── store/
│   │   │   └── authSlice.ts
│   │   └── index.ts (public API)
│   │
│   ├── orders/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── ...
│   │
│   └── dashboard/
│       └── ...
│
├── shared/
│   ├── components/
│   │   ├── Button.tsx
│   │   ├── Modal.tsx
│   │   └── ...
│   ├── hooks/
│   │   ├── useLocalStorage.ts
│   │   └── ...
│   ├── services/
│   │   ├── apiClient.ts
│   │   └── logger.ts
│   └── types/
│       └── common.types.ts
│
└── App.tsx
```

### Component Boundaries

```typescript
// Feature index - control public API
// auth/index.ts
export { LoginForm } from './components/LoginForm';
export { RegisterForm } from './components/RegisterForm';
export { AuthGuard } from './components/AuthGuard';
export { useAuth } from './hooks/useAuth';
export type { AuthState, User } from './types/auth.types';

// Internal components not exported
// This ensures controlled access to feature internals
```

### Atomic Design Pattern

```typescript
// Atoms - Basic building blocks
const Button: React.FC<ButtonProps> = ({ children, variant, ...props }) => (
    <button className={`btn btn-${variant}`} {...props}>
        {children}
    </button>
);

// Molecules - Simple component combinations
interface InputFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
    label: string;
    error?: string;
}

const InputField: React.FC<InputFieldProps> = ({ label, error, ...props }) => (
    <div className="input-group">
        <label>{label}</label>
        <input {...props} className={error ? 'input-error' : ''} />
        {error && <span className="error-message">{error}</span>}
    </div>
);

// Organisms - Complex combinations
interface LoginFormProps {
    onSubmit: (email: string, password: string) => Promise<void>;
}

const LoginForm: React.FC<LoginFormProps> = ({ onSubmit }) => {
    const [formData, setFormData] = useState({ email: '', password: '' });
    const [errors, setErrors] = useState<Record<string, string>>({});
    const [isLoading, setIsLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);
        try {
            await onSubmit(formData.email, formData.password);
        } catch (error) {
            setErrors({ submit: 'Login failed' });
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <InputField
                label="Email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                error={errors.email}
            />
            <InputField
                label="Password"
                type="password"
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                error={errors.password}
            />
            <Button variant="primary" type="submit" disabled={isLoading}>
                {isLoading ? 'Logging in...' : 'Login'}
            </Button>
        </form>
    );
};

// Pages - Full page templates
const LoginPage: React.FC = () => {
    const navigate = useNavigate();

    const handleSubmit = async (email: string, password: string) => {
        await authService.login(email, password);
        navigate('/dashboard');
    };

    return (
        <div className="login-page">
            <LoginForm onSubmit={handleSubmit} />
        </div>
    );
};
```

---

## 2. State Management Architecture

Choosing and implementing state management at scale.

### Redux Pattern

```typescript
// Store setup with Redux Toolkit
import { configureStore, createSlice, createAsyncThunk } from '@reduxjs/toolkit';

// Async thunk for API calls
export const fetchUser = createAsyncThunk(
    'user/fetchUser',
    async (userId: string, { rejectWithValue }) => {
        try {
            const response = await apiClient.get(`/users/${userId}`);
            return response.data;
        } catch (error) {
            return rejectWithValue(error.response.data);
        }
    }
);

// Slice for user state
const userSlice = createSlice({
    name: 'user',
    initialState: {
        data: null as User | null,
        loading: false,
        error: null as string | null,
    },
    extraReducers: (builder) => {
        builder
            .addCase(fetchUser.pending, (state) => {
                state.loading = true;
                state.error = null;
            })
            .addCase(fetchUser.fulfilled, (state, action) => {
                state.data = action.payload;
                state.loading = false;
            })
            .addCase(fetchUser.rejected, (state, action) => {
                state.error = action.payload as string;
                state.loading = false;
            });
    },
});

// Order state management
const orderSlice = createSlice({
    name: 'orders',
    initialState: {
        items: [] as Order[],
        selectedOrder: null as Order | null,
        filter: 'all' as 'all' | 'pending' | 'completed',
    },
    reducers: {
        setSelectedOrder: (state, action) => {
            state.selectedOrder = action.payload;
        },
        setFilter: (state, action) => {
            state.filter = action.payload;
        },
        addOrder: (state, action) => {
            state.items.push(action.payload);
        },
        updateOrder: (state, action) => {
            const index = state.items.findIndex(o => o.id === action.payload.id);
            if (index >= 0) {
                state.items[index] = action.payload;
            }
        },
    },
});

// Store configuration
export const store = configureStore({
    reducer: {
        user: userSlice.reducer,
        orders: orderSlice.reducer,
    },
    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware()
            .concat(loggerMiddleware)
            .concat(crashReporterMiddleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### Custom Hooks for State Management

```typescript
// Encapsulate state logic in custom hooks
const useUser = (userId: string) => {
    const dispatch = useAppDispatch();
    const { data, loading, error } = useAppSelector((state) => state.user);

    useEffect(() => {
        dispatch(fetchUser(userId));
    }, [userId, dispatch]);

    return { user: data, loading, error };
};

// Component using custom hooks
const UserProfile: React.FC<{ userId: string }> = ({ userId }) => {
    const { user, loading, error } = useUser(userId);

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error}</div>;
    if (!user) return <div>User not found</div>;

    return <div>{user.name}</div>;
};
```

### Context + Hooks Pattern (Lightweight alternative)

```typescript
// Create context
interface ThemeContextType {
    theme: 'light' | 'dark';
    toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// Provider component
export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [theme, setTheme] = useState<'light' | 'dark'>(
        () => localStorage.getItem('theme') as 'light' | 'dark' || 'light'
    );

    const toggleTheme = useCallback(() => {
        setTheme((prev) => {
            const newTheme = prev === 'light' ? 'dark' : 'light';
            localStorage.setItem('theme', newTheme);
            return newTheme;
        });
    }, []);

    const value: ThemeContextType = { theme, toggleTheme };

    return (
        <ThemeContext.Provider value={value}>
            {children}
        </ThemeContext.Provider>
    );
};

// Custom hook for using context
export const useTheme = () => {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within ThemeProvider');
    }
    return context;
};
```

---

## 3. Smart vs Presentational Components

Clear component responsibilities.

```typescript
// Presentational Component - Pure, reusable
interface OrderListProps {
    orders: Order[];
    selectedOrderId?: string;
    onSelectOrder: (orderId: string) => void;
    isLoading?: boolean;
}

const OrderList: React.FC<OrderListProps> = ({
    orders,
    selectedOrderId,
    onSelectOrder,
    isLoading,
}) => {
    if (isLoading) return <div>Loading...</div>;
    if (orders.length === 0) return <div>No orders found</div>;

    return (
        <ul className="order-list">
            {orders.map((order) => (
                <li
                    key={order.id}
                    className={selectedOrderId === order.id ? 'selected' : ''}
                    onClick={() => onSelectOrder(order.id)}
                >
                    <span>{order.id}</span>
                    <span>{order.total}</span>
                </li>
            ))}
        </ul>
    );
};

// Smart Component - Manages state and logic
const OrderListContainer: React.FC<{ customerId: string }> = ({ customerId }) => {
    const [orders, setOrders] = useState<Order[]>([]);
    const [selectedOrderId, setSelectedOrderId] = useState<string>();
    const [isLoading, setIsLoading] = useState(false);

    useEffect(() => {
        const fetchOrders = async () => {
            setIsLoading(true);
            try {
                const data = await orderService.getCustomerOrders(customerId);
                setOrders(data);
            } catch (error) {
                console.error('Failed to fetch orders:', error);
            } finally {
                setIsLoading(false);
            }
        };

        fetchOrders();
    }, [customerId]);

    return (
        <OrderList
            orders={orders}
            selectedOrderId={selectedOrderId}
            onSelectOrder={setSelectedOrderId}
            isLoading={isLoading}
        />
    );
};
```

---

## 4. Container Pattern

Separating concerns with container components.

```typescript
// Container handles logic
interface OrderDetailsContainerProps {
    orderId: string;
}

const OrderDetailsContainer: React.FC<OrderDetailsContainerProps> = ({ orderId }) => {
    const [order, setOrder] = useState<Order | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const loadOrder = async () => {
            setLoading(true);
            try {
                const data = await orderService.getOrder(orderId);
                setOrder(data);
            } catch (err) {
                setError('Failed to load order');
            } finally {
                setLoading(false);
            }
        };

        loadOrder();
    }, [orderId]);

    return (
        <OrderDetailsPresentation
            order={order}
            loading={loading}
            error={error}
            onUpdateStatus={(status) => orderService.updateStatus(orderId, status)}
        />
    );
};

// Presentation component - Pure UI
interface OrderDetailsPresentationProps {
    order: Order | null;
    loading: boolean;
    error: string | null;
    onUpdateStatus: (status: OrderStatus) => Promise<void>;
}

const OrderDetailsPresentation: React.FC<OrderDetailsPresentationProps> = ({
    order,
    loading,
    error,
    onUpdateStatus,
}) => {
    const [isUpdating, setIsUpdating] = useState(false);

    if (loading) return <div>Loading order details...</div>;
    if (error) return <div className="error">{error}</div>;
    if (!order) return <div>Order not found</div>;

    const handleStatusChange = async (status: OrderStatus) => {
        setIsUpdating(true);
        try {
            await onUpdateStatus(status);
        } finally {
            setIsUpdating(false);
        }
    };

    return (
        <div className="order-details">
            <h2>Order {order.id}</h2>
            <p>Total: ${order.total}</p>
            <select
                value={order.status}
                onChange={(e) => handleStatusChange(e.target.value as OrderStatus)}
                disabled={isUpdating}
            >
                <option value="pending">Pending</option>
                <option value="processing">Processing</option>
                <option value="shipped">Shipped</option>
                <option value="delivered">Delivered</option>
            </select>
        </div>
    );
};
```

---

## 5. Compound Components

Flexible component composition.

```typescript
// Tabs compound component
interface TabsContextType {
    activeTab: string;
    setActiveTab: (id: string) => void;
}

const TabsContext = createContext<TabsContextType | undefined>(undefined);

interface TabsProps {
    defaultActive: string;
    children: React.ReactNode;
}

const Tabs: React.FC<TabsProps> = ({ defaultActive, children }) => {
    const [activeTab, setActiveTab] = useState(defaultActive);

    return (
        <TabsContext.Provider value={{ activeTab, setActiveTab }}>
            <div className="tabs">
                {children}
            </div>
        </TabsContext.Provider>
    );
};

// TabList compound component
interface TabListProps {
    children: React.ReactNode;
}

Tabs.List = ({ children }: TabListProps) => (
    <div className="tab-list" role="tablist">
        {children}
    </div>
);

// TabButton compound component
interface TabButtonProps {
    id: string;
    children: React.ReactNode;
}

Tabs.Button = ({ id, children }: TabButtonProps) => {
    const context = useContext(TabsContext);
    if (!context) throw new Error('TabButton must be used within Tabs');

    const { activeTab, setActiveTab } = context;

    return (
        <button
            role="tab"
            className={activeTab === id ? 'active' : ''}
            onClick={() => setActiveTab(id)}
        >
            {children}
        </button>
    );
};

// TabPanel compound component
interface TabPanelProps {
    id: string;
    children: React.ReactNode;
}

Tabs.Panel = ({ id, children }: TabPanelProps) => {
    const context = useContext(TabsContext);
    if (!context) throw new Error('TabPanel must be used within Tabs');

    const { activeTab } = context;

    return activeTab === id ? <div className="tab-panel">{children}</div> : null;
};

// Usage
const Dashboard: React.FC = () => (
    <Tabs defaultActive="overview">
        <Tabs.List>
            <Tabs.Button id="overview">Overview</Tabs.Button>
            <Tabs.Button id="analytics">Analytics</Tabs.Button>
            <Tabs.Button id="settings">Settings</Tabs.Button>
        </Tabs.List>

        <Tabs.Panel id="overview">
            <OverviewContent />
        </Tabs.Panel>
        <Tabs.Panel id="analytics">
            <AnalyticsContent />
        </Tabs.Panel>
        <Tabs.Panel id="settings">
            <SettingsContent />
        </Tabs.Panel>
    </Tabs>
);
```

---

## 6. Render Props & Higher-Order Components

Advanced composition patterns.

### Render Props Pattern

```typescript
// Render Props for code reuse
interface DataFetcherProps<T> {
    url: string;
    children: (data: T | null, loading: boolean, error: string | null) => React.ReactNode;
}

const DataFetcher = <T,>({ url, children }: DataFetcherProps<T>) => {
    const [data, setData] = useState<T | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await fetch(url);
                const result = await response.json();
                setData(result);
            } catch (err) {
                setError('Failed to fetch data');
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, [url]);

    return <>{children(data, loading, error)}</>;
};

// Usage
const UsersList: React.FC = () => (
    <DataFetcher<User[]> url="/api/users">
        {(users, loading, error) => (
            <>
                {loading && <p>Loading...</p>}
                {error && <p>Error: {error}</p>}
                {users && users.map((user) => <div key={user.id}>{user.name}</div>)}
            </>
        )}
    </DataFetcher>
);
```

### Higher-Order Component Pattern

```typescript
// HOC for auth protection
interface WithAuthProps {
    user: User | null;
}

const withAuth = <P extends WithAuthProps>(
    Component: React.ComponentType<P>
): React.FC<Omit<P, 'user'>> => {
    return (props) => {
        const { user, loading } = useAuth();

        if (loading) return <div>Loading...</div>;
        if (!user) return <div>Please log in</div>;

        return <Component {...(props as P)} user={user} />;
    };
};

// Usage
interface ProtectedPageProps extends WithAuthProps {
    title: string;
}

const ProtectedPage: React.FC<ProtectedPageProps> = ({ title, user }) => (
    <div>
        <h1>{title}</h1>
        <p>Welcome, {user.name}</p>
    </div>
);

export const ProtectedPageWithAuth = withAuth(ProtectedPage);
```

---

## 7. Micro-Frontends Architecture

Building scalable multi-team applications.

```typescript
// Host application
const App: React.FC = () => (
    <BrowserRouter>
        <Routes>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/orders/*" element={<OrdersMicroApp />} />
            <Route path="/analytics/*" element={<AnalyticsMicroApp />} />
        </Routes>
    </BrowserRouter>
);

// Micro-frontend wrapper component
interface MicroAppProps {
    appName: string;
    url: string;
}

const MicroAppContainer: React.FC<MicroAppProps> = ({ appName, url }) => {
    const containerRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        if (!containerRef.current) return;

        const scriptElement = document.createElement('script');
        scriptElement.src = url;
        scriptElement.type = 'text/javascript';
        scriptElement.async = true;

        scriptElement.onload = () => {
            // Initialize micro-frontend
            if (window[appName]) {
                window[appName].mount(containerRef.current);
            }
        };

        containerRef.current.appendChild(scriptElement);

        return () => {
            if (window[appName]) {
                window[appName].unmount();
            }
            if (containerRef.current?.contains(scriptElement)) {
                containerRef.current.removeChild(scriptElement);
            }
        };
    }, [appName, url]);

    return <div ref={containerRef} />;
};

// Micro-frontend module
const OrdersMicroApp: React.FC = () => (
    <MicroAppContainer
        appName="OrdersApp"
        url="/micro-apps/orders/app.js"
    />
);
```

---

## 8. Module Federation

Webpack 5 Module Federation for shared code.

```javascript
// webpack.config.js - Host app
module.exports = {
    mode: 'production',
    plugins: [
        new ModuleFederationPlugin({
            name: 'host',
            remotes: {
                orders: 'orders@http://localhost:3001/remoteEntry.js',
                analytics: 'analytics@http://localhost:3002/remoteEntry.js',
            },
            shared: {
                react: { singleton: true, requiredVersion: '^18.0.0' },
                'react-dom': { singleton: true, requiredVersion: '^18.0.0' },
                'react-router-dom': { singleton: true },
            },
        }),
    ],
};

// webpack.config.js - Orders micro-app
module.exports = {
    mode: 'production',
    plugins: [
        new ModuleFederationPlugin({
            name: 'orders',
            filename: 'remoteEntry.js',
            exposes: {
                './OrdersApp': './src/OrdersApp.tsx',
                './hooks': './src/hooks/index.ts',
            },
            shared: {
                react: { singleton: true, requiredVersion: '^18.0.0' },
                'react-dom': { singleton: true, requiredVersion: '^18.0.0' },
            },
        }),
    ],
};
```

---

## 9. Security Architecture

Protecting React applications.

```typescript
// Content Security Policy headers
const securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
};

// CSRF Token management
const useCSRFToken = () => {
    const [token, setToken] = useState<string>('');

    useEffect(() => {
        const tokenElement = document.querySelector('meta[name="csrf-token"]');
        if (tokenElement) {
            setToken(tokenElement.getAttribute('content') || '');
        }
    }, []);

    return token;
};

// Secure API client
const createSecureApiClient = () => {
    const csrfToken = useCSRFToken();

    return axios.create({
        headers: {
            'X-CSRF-Token': csrfToken,
        },
        withCredentials: true, // Include cookies
    });
};

// Input sanitization
import DOMPurify from 'dompurify';

const SanitizedHTML: React.FC<{ html: string }> = ({ html }) => {
    const sanitized = DOMPurify.sanitize(html);
    return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
};

// Secure secret management
interface SecretManagerProps {
    children: React.ReactNode;
}

export const SecretProvider: React.FC<SecretManagerProps> = ({ children }) => {
    const [secrets, setSecrets] = useState<Record<string, string>>({});

    useEffect(() => {
        // Never store secrets in localStorage/sessionStorage
        // Fetch from secure backend endpoint
        const fetchSecrets = async () => {
            const response = await fetch('/api/secrets', {
                credentials: 'include',
            });
            // Secrets should be in memory only
            const data = await response.json();
            setSecrets(data);
        };

        fetchSecrets();
    }, []);

    return <>{children}</>;
};
```

---

## 10. Performance Architecture

Optimizing React application performance.

```typescript
// Code splitting with lazy loading
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Orders = lazy(() => import('./pages/Orders'));
const Analytics = lazy(() => import('./pages/Analytics'));

const App: React.FC = () => (
    <Suspense fallback={<LoadingSpinner />}>
        <Routes>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/orders" element={<Orders />} />
            <Route path="/analytics" element={<Analytics />} />
        </Routes>
    </Suspense>
);

// Memoization strategy
interface ExpensiveComponentProps {
    data: DataType;
    onUpdate: (data: DataType) => void;
}

const ExpensiveComponent = memo(
    ({ data, onUpdate }: ExpensiveComponentProps) => {
        return <div>{/* Complex rendering logic */}</div>;
    },
    (prevProps, nextProps) => {
        // Custom comparison - return true if props are equal
        return (
            prevProps.data.id === nextProps.data.id &&
            prevProps.onUpdate === nextProps.onUpdate
        );
    }
);

// useCallback for stable function references
const ParentComponent: React.FC = () => {
    const [count, setCount] = useState(0);

    const handleUpdate = useCallback((newData: string) => {
        console.log('Update:', newData);
    }, []); // Empty dependency array - function never changes

    return <MemoizedChild onUpdate={handleUpdate} />;
};

// Virtual scrolling for large lists
import { FixedSizeList } from 'react-window';

const VirtualizedList: React.FC<{ items: Item[] }> = ({ items }) => (
    <FixedSizeList
        height={600}
        itemCount={items.length}
        itemSize={35}
        width="100%"
    >
        {({ index, style }) => (
            <div style={style}>
                {items[index].name}
            </div>
        )}
    </FixedSizeList>
);

// Web Workers for CPU-intensive tasks
const useWebWorker = (workerScript: string) => {
    const [result, setResult] = useState<any>(null);

    const runWorker = useCallback((data: any) => {
        const worker = new Worker(workerScript);
        worker.postMessage(data);
        worker.onmessage = (event) => {
            setResult(event.data);
            worker.terminate();
        };
    }, [workerScript]);

    return { result, runWorker };
};

// Intersection Observer for lazy loading
const LazyImage: React.FC<{ src: string; alt: string }> = ({ src, alt }) => {
    const [imageSrc, setImageSrc] = useState<string>();
    const observerTarget = useRef<HTMLDivElement>(null);

    useEffect(() => {
        const observer = new IntersectionObserver(([entry]) => {
            if (entry.isIntersecting) {
                setImageSrc(src);
                observer.unobserve(entry.target);
            }
        });

        if (observerTarget.current) {
            observer.observe(observerTarget.current);
        }

        return () => observer.disconnect();
    }, [src]);

    return <img ref={observerTarget} src={imageSrc} alt={alt} />;
};
```

---

## 11. Error Handling & Resilience

Robust error management strategies.

```typescript
// Error Boundary component
interface ErrorBoundaryProps {
    children: React.ReactNode;
    fallback?: (error: Error) => React.ReactNode;
}

interface ErrorBoundaryState {
    hasError: boolean;
    error: Error | null;
}

export class ErrorBoundary extends React.Component<
    ErrorBoundaryProps,
    ErrorBoundaryState
> {
    constructor(props: ErrorBoundaryProps) {
        super(props);
        this.state = { hasError: false, error: null };
    }

    static getDerivedStateFromError(error: Error) {
        return { hasError: true, error };
    }

    componentDidCatch(error: Error, info: React.ErrorInfo) {
        logger.error('Error caught:', error, info);
        // Report to error tracking service
        errorReportingService.captureException(error);
    }

    render() {
        if (this.state.hasError) {
            return (
                this.props.fallback?.(this.state.error!) || (
                    <div>
                        <h1>Something went wrong</h1>
                        <p>{this.state.error?.message}</p>
                    </div>
                )
            );
        }

        return this.props.children;
    }
}

// Try-catch hook for async operations
const useAsync = <T,>(
    asyncFunction: () => Promise<T>,
    immediate: boolean = true
) => {
    const [status, setStatus] = useState<'idle' | 'pending' | 'success' | 'error'>(
        'idle'
    );
    const [data, setData] = useState<T | null>(null);
    const [error, setError] = useState<Error | null>(null);

    const execute = useCallback(async () => {
        setStatus('pending');
        try {
            const response = await asyncFunction();
            setData(response);
            setStatus('success');
        } catch (err) {
            setError(err as Error);
            setStatus('error');
        }
    }, [asyncFunction]);

    useEffect(() => {
        if (immediate) {
            execute();
        }
    }, [execute, immediate]);

    return { execute, status, data, error };
};

// Retry with exponential backoff
const useRetry = (
    asyncFunction: () => Promise<any>,
    maxRetries: number = 3,
    delayMs: number = 1000
) => {
    const retryAsync = useCallback(async () => {
        let lastError: Error | null = null;

        for (let i = 0; i < maxRetries; i++) {
            try {
                return await asyncFunction();
            } catch (error) {
                lastError = error as Error;
                if (i < maxRetries - 1) {
                    const delay = delayMs * Math.pow(2, i);
                    await new Promise((resolve) => setTimeout(resolve, delay));
                }
            }
        }

        throw lastError;
    }, [asyncFunction, maxRetries, delayMs]);

    return { retryAsync };
};
```

---

## 12. Testing Architecture

Comprehensive testing strategy.

```typescript
// Component testing with React Testing Library
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('LoginForm', () => {
    it('should submit form with valid credentials', async () => {
        const handleSubmit = jest.fn();

        render(<LoginForm onSubmit={handleSubmit} />);

        const emailInput = screen.getByLabelText(/email/i);
        const passwordInput = screen.getByLabelText(/password/i);
        const submitButton = screen.getByRole('button', { name: /login/i });

        await userEvent.type(emailInput, 'test@example.com');
        await userEvent.type(passwordInput, 'password123');
        await userEvent.click(submitButton);

        await waitFor(() => {
            expect(handleSubmit).toHaveBeenCalledWith({
                email: 'test@example.com',
                password: 'password123',
            });
        });
    });

    it('should display error on submission failure', async () => {
        const handleSubmit = jest.fn().mockRejectedValue(new Error('Login failed'));

        render(<LoginForm onSubmit={handleSubmit} />);

        const submitButton = screen.getByRole('button', { name: /login/i });
        await userEvent.click(submitButton);

        const errorMessage = await screen.findByText(/login failed/i);
        expect(errorMessage).toBeInTheDocument();
    });
});

// Redux state testing
import { configureStore } from '@reduxjs/toolkit';
import userReducer from './userSlice';

describe('User slice', () => {
    it('should handle fetchUser fulfilled', () => {
        const initialState = { data: null, loading: false, error: null };

        const action = {
            type: fetchUser.fulfilled.type,
            payload: { id: '1', name: 'John Doe' },
        };

        const state = userReducer(initialState, action);
        expect(state.data).toEqual({ id: '1', name: 'John Doe' });
        expect(state.loading).toBe(false);
    });
});

// Integration testing
describe('Order flow', () => {
    it('should complete full order workflow', async () => {
        const { getByText, getByRole } = render(<OrderWorkflow />);

        // Start order
        fireEvent.click(getByText('New Order'));
        expect(screen.getByText('Order Details')).toBeInTheDocument();

        // Fill details and submit
        const submitButton = getByRole('button', { name: /submit/i });
        fireEvent.click(submitButton);

        // Verify completion
        await waitFor(() => {
            expect(screen.getByText('Order Confirmed')).toBeInTheDocument();
        });
    });
});

// Snapshot testing
describe('Dashboard', () => {
    it('should match snapshot', () => {
        const { container } = render(<Dashboard />);
        expect(container.firstChild).toMatchSnapshot();
    });
});
```

---

## 13. Real-time Data Synchronization

WebSocket and real-time data patterns.

```typescript
// WebSocket hook
const useWebSocket = (url: string) => {
    const [data, setData] = useState<any>(null);
    const [isConnected, setIsConnected] = useState(false);
    const wsRef = useRef<WebSocket | null>(null);

    useEffect(() => {
        const ws = new WebSocket(url);

        ws.onopen = () => {
            setIsConnected(true);
        };

        ws.onmessage = (event) => {
            const message = JSON.parse(event.data);
            setData(message);
        };

        ws.onerror = () => {
            setIsConnected(false);
        };

        ws.onclose = () => {
            setIsConnected(false);
        };

        wsRef.current = ws;

        return () => {
            ws.close();
        };
    }, [url]);

    const send = useCallback((message: any) => {
        if (wsRef.current?.readyState === WebSocket.OPEN) {
            wsRef.current.send(JSON.stringify(message));
        }
    }, []);

    return { data, isConnected, send };
};

// Real-time notifications
const NotificationCenter: React.FC = () => {
    const { data: notification, isConnected } = useWebSocket(
        'wss://api.example.com/notifications'
    );

    return (
        <div>
            <p>Status: {isConnected ? 'Connected' : 'Disconnected'}</p>
            {notification && (
                <div className="notification">
                    {notification.message}
                </div>
            )}
        </div>
    );
};

// Redux middleware for WebSocket
const socketMiddleware = (socket: WebSocket) => (store: any) => (next: any) => (action: any) => {
    if (action.type === 'SEND_MESSAGE') {
        socket.send(JSON.stringify(action.payload));
    }
    return next(action);
};

// Server-sent events (SSE) alternative
const useServerSentEvents = (url: string) => {
    const [data, setData] = useState<any>(null);

    useEffect(() => {
        const eventSource = new EventSource(url);

        eventSource.onmessage = (event) => {
            setData(JSON.parse(event.data));
        };

        eventSource.onerror = () => {
            eventSource.close();
        };

        return () => {
            eventSource.close();
        };
    }, [url]);

    return data;
};
```

---

## 14. API Integration Patterns

Clean API communication architecture.

```typescript
// API Client with interceptors
class ApiClient {
    private instance: AxiosInstance;

    constructor(baseURL: string) {
        this.instance = axios.create({ baseURL });

        // Request interceptor
        this.instance.interceptors.request.use(
            (config) => {
                const token = localStorage.getItem('auth_token');
                if (token) {
                    config.headers.Authorization = `Bearer ${token}`;
                }
                return config;
            },
            (error) => Promise.reject(error)
        );

        // Response interceptor
        this.instance.interceptors.response.use(
            (response) => response.data,
            async (error) => {
                if (error.response?.status === 401) {
                    // Handle token refresh
                    const newToken = await refreshToken();
                    localStorage.setItem('auth_token', newToken);
                    return this.instance(error.config);
                }
                return Promise.reject(error);
            }
        );
    }

    public get<T>(url: string): Promise<T> {
        return this.instance.get<T>(url);
    }

    public post<T>(url: string, data: any): Promise<T> {
        return this.instance.post<T>(url, data);
    }
}

// Service layer
class OrderService {
    private apiClient: ApiClient;

    constructor(apiClient: ApiClient) {
        this.apiClient = apiClient;
    }

    async getOrders(): Promise<Order[]> {
        return this.apiClient.get('/orders');
    }

    async getOrder(id: string): Promise<Order> {
        return this.apiClient.get(`/orders/${id}`);
    }

    async createOrder(data: CreateOrderRequest): Promise<Order> {
        return this.apiClient.post('/orders', data);
    }

    async updateOrder(id: string, data: UpdateOrderRequest): Promise<Order> {
        return this.apiClient.put(`/orders/${id}`, data);
    }
}

// React integration
const apiClient = new ApiClient(process.env.REACT_APP_API_URL || '');
const orderService = new OrderService(apiClient);

// Custom hook for API calls
const useOrderService = () => {
    return {
        getOrders: () => useAsync(() => orderService.getOrders()),
        getOrder: (id: string) => useAsync(() => orderService.getOrder(id)),
    };
};
```

---

## 15. Design Systems & Component Libraries

Building scalable component libraries.

```typescript
// Component library structure
// components/
//   ├── Button/
//   │   ├── Button.tsx
//   │   ├── Button.test.tsx
//   │   ├── Button.stories.tsx
//   │   └── Button.types.ts
//   ├── Modal/
//   ├── Form/
//   └── index.ts (public exports)

// Design tokens
export const tokens = {
    colors: {
        primary: '#2563eb',
        secondary: '#1e40af',
        success: '#10b981',
        error: '#ef4444',
    },
    spacing: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '32px',
    },
    typography: {
        h1: { fontSize: '32px', fontWeight: 'bold' },
        h2: { fontSize: '24px', fontWeight: 'bold' },
        body: { fontSize: '14px', fontWeight: 'normal' },
    },
};

// Component with theming
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'outline';
    size?: 'small' | 'medium' | 'large';
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
    ({ variant = 'primary', size = 'medium', className, ...props }, ref) => {
        const baseClass = 'btn';
        const variantClass = `btn-${variant}`;
        const sizeClass = `btn-${size}`;

        return (
            <button
                ref={ref}
                className={`${baseClass} ${variantClass} ${sizeClass} ${className}`}
                {...props}
            />
        );
    }
);

// Storybook documentation
export default {
    title: 'Components/Button',
    component: Button,
    argTypes: {
        variant: {
            options: ['primary', 'secondary', 'outline'],
            control: 'select',
        },
        size: {
            options: ['small', 'medium', 'large'],
            control: 'select',
        },
    },
};

export const Primary = (args: ButtonProps) => <Button {...args}>Click me</Button>;
Primary.args = { variant: 'primary' };

export const Secondary = (args: ButtonProps) => <Button {...args}>Click me</Button>;
Secondary.args = { variant: 'secondary' };
```

---

## 16. Progressive Web Apps

Building installable, offline-capable apps.

```typescript
// Service Worker registration
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/service-worker.js')
            .then((registration) => {
                console.log('SW registered:', registration);
            })
            .catch((error) => {
                console.log('SW registration failed:', error);
            });
    });
}

// PWA manifest
interface WebAppManifest {
    name: string;
    short_name: string;
    description: string;
    start_url: string;
    display: 'standalone' | 'fullscreen' | 'minimal-ui' | 'browser';
    theme_color: string;
    background_color: string;
    icons: Array<{
        src: string;
        sizes: string;
        type: string;
        purpose: 'any' | 'maskable';
    }>;
}

// Install prompt
const useInstallPrompt = () => {
    const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
    const [showPrompt, setShowPrompt] = useState(false);

    useEffect(() => {
        const handler = (e: Event) => {
            e.preventDefault();
            setDeferredPrompt(e);
            setShowPrompt(true);
        };

        window.addEventListener('beforeinstallprompt', handler);

        return () => {
            window.removeEventListener('beforeinstallprompt', handler);
        };
    }, []);

    const handleInstall = async () => {
        if (deferredPrompt) {
            deferredPrompt.prompt();
            const { outcome } = await deferredPrompt.userChoice;
            console.log(`User response: ${outcome}`);
            setDeferredPrompt(null);
            setShowPrompt(false);
        }
    };

    return { showPrompt, handleInstall };
};

// Offline support with service workers
export const handleInstallEvent = (event: ExtendableEvent) => {
    const urlsToCache = [
        '/',
        '/index.html',
        '/static/css/main.css',
        '/static/js/main.js',
    ];

    event.waitUntil(
        caches.open('app-v1').then((cache) => {
            return cache.addAll(urlsToCache);
        })
    );
};

export const handleFetchEvent = (event: FetchEvent) => {
    event.respondWith(
        caches.match(event.request).then((response) => {
            if (response) {
                return response;
            }

            return fetch(event.request).then((response) => {
                const clonedResponse = response.clone();

                caches.open('dynamic-cache').then((cache) => {
                    cache.put(event.request, clonedResponse);
                });

                return response;
            }).catch(() => {
                return caches.match('/offline.html');
            });
        })
    );
};
```

---

## Best Practices Summary

| Pattern | Use Case | Benefit |
|---------|----------|---------|
| **Smart/Presentational** | UI organization | Reusability and testability |
| **Container** | State management | Separation of concerns |
| **Compound Components** | Complex UIs | Flexible composition |
| **Micro-frontends** | Team scaling | Independent deployment |
| **Error Boundaries** | Error handling | Graceful degradation |
| **Code Splitting** | Performance | Faster initial load |
| **State Management** | Complex state | Predictable updates |
| **Design Systems** | Consistency | UI standardization |
| **PWA** | User experience | Offline capability |

---

## Architecture Decision Matrix

| Aspect | Best Practice |
|--------|---------------|
| **State Management** | Redux for complex, Context for simple |
| **Data Fetching** | API service layer abstraction |
| **Error Handling** | Error Boundaries + try-catch hooks |
| **Performance** | Code splitting + Memoization + Virtual scrolling |
| **Security** | Sanitization + CSP + CSRF tokens |
| **Testing** | Unit + Integration + E2E coverage |
| **Scalability** | Micro-frontends for large teams |
| **Offline Support** | Service Workers + PWA manifest |

---

This comprehensive architecture guide provides production-ready patterns for building enterprise-scale React applications.

**Estimated Study Time:** 8-10 hours
**Code Examples:** 80+
**Patterns Covered:** 16 major patterns
**Real-World Focus:** Scalable, maintainable applications

