# Web Technologies: Expert Architecture & Design Patterns

## Overview

This document contains 25+ advanced architectural questions and patterns for senior developers designing scalable, maintainable web applications. These questions focus on system design, performance optimization, and architectural decision-making.

---

## Part 1: Component Architecture & Design Patterns

### Q1: Design a Scalable Component System

**Question:**
Design a component system for a large-scale web application that multiple teams will use. How would you handle versioning, backward compatibility, and theme management?

**Solution Approach:**

**1. Component Organization:**
```
component-lib/
├── components/
│   ├── Button/
│   │   ├── index.ts           # Export
│   │   ├── Button.tsx         # Component
│   │   ├── Button.types.ts    # Props interface
│   │   ├── Button.styles.ts   # Styles
│   │   ├── Button.stories.ts  # Storybook
│   │   └── Button.test.tsx    # Tests
│   ├── Form/
│   ├── Card/
│   └── ...
├── hooks/
├── utils/
├── theme/
│   ├── tokens.ts              # Design tokens
│   ├── light.ts               # Light theme
│   └── dark.ts                # Dark theme
├── version.ts                  # Version info
└── index.ts                    # Main export
```

**2. Versioning Strategy:**
```typescript
// package.json
{
    "name": "@mycompany/component-lib",
    "version": "2.3.1",
    "exports": {
        ".": "./dist/index.js",
        "./v1": "./dist/v1/index.js",
        "./styles": "./dist/styles.css"
    }
}

// Support multiple versions
// apps/app1 uses ^2.0.0
// apps/app2 uses ^1.5.0
// Both work with minor version features
```

**3. Backward Compatibility:**
```typescript
// Deprecated component with fallback
export interface ButtonProps {
    /** @deprecated Use `variant` instead */
    type?: 'primary' | 'secondary';
    variant?: 'solid' | 'outline' | 'ghost';
    onClick?: (e: React.MouseEvent) => void;
}

export const Button: React.FC<ButtonProps> = ({
    type,
    variant = type === 'primary' ? 'solid' : 'outline',
    ...props
}) => {
    if (type) {
        console.warn('Button: `type` prop is deprecated, use `variant`');
    }
    // Render using new variant system
    return <button data-variant={variant} {...props} />;
};
```

**4. Theme Management:**
```typescript
// Design tokens
export const tokens = {
    colors: {
        primary: '#667eea',
        secondary: '#764ba2',
        success: '#27ae60',
        error: '#e74c3c',
    },
    typography: {
        fontFamily: 'Inter, sans-serif',
        sizes: { xs: '12px', sm: '14px', md: '16px', lg: '18px', xl: '20px' },
        weights: { regular: 400, medium: 500, bold: 700 },
    },
    spacing: { xs: '4px', sm: '8px', md: '16px', lg: '24px', xl: '32px' },
} as const;

// Theme provider
interface ThemeContextType {
    mode: 'light' | 'dark';
    tokens: typeof tokens;
    toggleMode: () => void;
}

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [mode, setMode] = useState<'light' | 'dark'>('light');

    const value: ThemeContextType = {
        mode,
        tokens,
        toggleMode: () => setMode(m => m === 'light' ? 'dark' : 'light'),
    };

    return (
        <ThemeContext.Provider value={value}>
            <div data-theme={mode}>{children}</div>
        </ThemeContext.Provider>
    );
};

// CSS custom properties for theming
export const themeStyles = css`
    :root {
        --color-primary: ${tokens.colors.primary};
        --color-secondary: ${tokens.colors.secondary};
        --font-family: ${tokens.typography.fontFamily};
    }

    [data-theme='dark'] {
        --color-primary: #7c8df0;
        --color-secondary: #9d6ec7;
    }
`;
```

**5. Documentation & Storybook:**
```typescript
// Button.stories.ts
import { Meta, StoryObj } from '@storybook/react';
import { Button, ButtonProps } from './Button';

const meta: Meta<ButtonProps> = {
    title: 'Components/Button',
    component: Button,
    argTypes: {
        variant: { control: 'select', options: ['solid', 'outline', 'ghost'] },
        size: { control: 'select', options: ['sm', 'md', 'lg'] },
        onClick: { action: 'clicked' },
    },
};

export default meta;
type Story = StoryObj<ButtonProps>;

export const Primary: Story = {
    args: { children: 'Primary Button', variant: 'solid' },
};

export const Disabled: Story = {
    args: { children: 'Disabled Button', disabled: true },
};
```

**Key Principles:**
- **Modular**: Each component is independent
- **Documented**: Every prop documented with Storybook
- **Tested**: Unit and visual regression tests
- **Versioned**: Semantic versioning with backward compatibility
- **Themed**: Design tokens for consistency
- **Accessible**: WCAG compliant by default

---

### Q2: Implement a Micro-Frontend Architecture

**Question:**
How would you architect a system where different teams develop and deploy independent frontend applications that work together?

**Solution Approach:**

**1. Module Federation (Webpack 5):**
```javascript
// host app webpack.config.js
const { ModuleFederationPlugin } = require('webpack').container;

module.exports = {
    plugins: [
        new ModuleFederationPlugin({
            name: 'host',
            remotes: {
                dashboard: 'dashboard@http://localhost:3001/remoteEntry.js',
                analytics: 'analytics@http://localhost:3002/remoteEntry.js',
                settings: 'settings@http://localhost:3003/remoteEntry.js',
            },
            shared: ['react', 'react-dom', '@shared/types'],
        }),
    ],
};

// remote (dashboard) webpack.config.js
new ModuleFederationPlugin({
    name: 'dashboard',
    filename: 'remoteEntry.js',
    exposes: {
        './Dashboard': './src/Dashboard.tsx',
        './hooks': './src/hooks/index.ts',
        './types': './src/types/index.ts',
    },
    shared: ['react', 'react-dom', '@shared/types'],
});
```

**2. Usage in Host App:**
```typescript
// app.tsx
import React, { Suspense } from 'react';

const Dashboard = React.lazy(() => import('dashboard/Dashboard'));
const Analytics = React.lazy(() => import('analytics/Analytics'));
const Settings = React.lazy(() => import('settings/Settings'));

export const App: React.FC = () => {
    const [currentApp, setCurrentApp] = useState<'dashboard' | 'analytics' | 'settings'>('dashboard');

    return (
        <div>
            <nav>
                <button onClick={() => setCurrentApp('dashboard')}>Dashboard</button>
                <button onClick={() => setCurrentApp('analytics')}>Analytics</button>
                <button onClick={() => setCurrentApp('settings')}>Settings</button>
            </nav>

            <Suspense fallback={<LoadingSpinner />}>
                {currentApp === 'dashboard' && <Dashboard />}
                {currentApp === 'analytics' && <Analytics />}
                {currentApp === 'settings' && <Settings />}
            </Suspense>
        </div>
    );
};
```

**3. Shared State Management:**
```typescript
// services/shared-store.ts
import { create } from 'zustand';

interface SharedState {
    userId: string;
    userRole: 'admin' | 'user';
    setUserId: (id: string) => void;
    setUserRole: (role: 'admin' | 'user') => void;
}

export const useSharedStore = create<SharedState>((set) => ({
    userId: '',
    userRole: 'user',
    setUserId: (id) => set({ userId: id }),
    setUserRole: (role) => set({ userRole: role }),
}));

// Expose shared store to remote apps
// remoteEntry.js includes store
```

**4. Communication Between Micro-Frontends:**
```typescript
// event-bus.ts
class EventBus {
    private listeners = new Map<string, Set<(data: any) => void>>();

    subscribe(event: string, handler: (data: any) => void) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, new Set());
        }
        this.listeners.get(event)!.add(handler);

        return () => {
            this.listeners.get(event)!.delete(handler);
        };
    }

    publish(event: string, data: any) {
        this.listeners.get(event)?.forEach(handler => handler(data));
    }
}

export const eventBus = new EventBus();

// Usage in dashboard micro-frontend
eventBus.subscribe('user:logout', () => {
    // Handle logout
});

// Usage in settings micro-frontend
eventBus.publish('user:logout', {});
```

**5. Deployment Strategy:**
```yaml
# docker-compose.yml
version: '3'
services:
    host:
        build: ./apps/host
        ports: ["3000:3000"]
        depends_on: [dashboard, analytics, settings]

    dashboard:
        build: ./apps/dashboard
        ports: ["3001:3000"]
        environment:
            REACT_APP_HOST_URL: http://host:3000

    analytics:
        build: ./apps/analytics
        ports: ["3002:3000"]

    settings:
        build: ./apps/settings
        ports: ["3003:3000"]

# Deploy independently:
# 1. Update dashboard code
# 2. Build and deploy dashboard container
# 3. Host app automatically loads new remoteEntry.js
```

**Advantages:**
- **Independent Deployment**: Each team deploys independently
- **Technology Agnostic**: Different frameworks possible (React, Vue, Angular)
- **Scalability**: Easy to add new features
- **Isolation**: Failures don't crash entire app

**Challenges:**
- **Version Management**: Ensure compatible versions
- **Bundle Size**: Shared dependencies increase size
- **Testing**: Complex integration testing
- **Debugging**: Harder to trace across boundaries

---

## Part 2: Performance Architecture

### Q3: Design a Performance Optimization Strategy

**Question:**
You're building a data-heavy dashboard with thousands of items. How would you optimize for performance?

**Solution Approach:**

**1. Code Splitting & Lazy Loading:**
```typescript
// pages/routes.tsx
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Reports = lazy(() => import('./pages/Reports'));
const Settings = lazy(() => import('./pages/Settings'));

export const routes = [
    { path: '/', component: Dashboard },
    { path: '/reports', component: Reports },
    { path: '/settings', component: Settings },
];

// Route-based code splitting
export const Router: React.FC = () => (
    <Suspense fallback={<Skeleton />}>
        <Routes>
            {routes.map(route => (
                <Route key={route.path} path={route.path} element={<route.component />} />
            ))}
        </Routes>
    </Suspense>
);
```

**2. Virtual Scrolling for Large Lists:**
```typescript
import { FixedSizeList as List } from 'react-window';

interface Item {
    id: string;
    title: string;
    description: string;
}

interface VirtualListProps {
    items: Item[];
}

const Row = ({ index, style, data }: any) => (
    <div style={style} className="item">
        <h4>{data[index].title}</h4>
        <p>{data[index].description}</p>
    </div>
);

export const VirtualList: React.FC<VirtualListProps> = ({ items }) => (
    <List
        height={600}
        itemCount={items.length}
        itemSize={80}
        width="100%"
        itemData={items}
    >
        {Row}
    </List>
);
```

**3. Memoization & Optimization:**
```typescript
// Memoize expensive computations
export const Dashboard = React.memo(
    ({ userId, filters }: Props) => {
        // Component render
        return <div>Dashboard</div>;
    },
    (prev, next) => {
        // Custom comparison for re-render
        return (
            prev.userId === next.userId &&
            JSON.stringify(prev.filters) === JSON.stringify(next.filters)
        );
    }
);

// useMemo for expensive calculations
const expensiveData = useMemo(() => {
    return items.filter(item => item.category === selectedCategory);
}, [items, selectedCategory]);

// useCallback for stable function references
const handleItemClick = useCallback((itemId: string) => {
    updateSelectedItem(itemId);
}, []);
```

**4. Image Optimization:**
```typescript
// Modern image formats with fallback
export const OptimizedImage: React.FC<{ src: string; alt: string }> = ({
    src,
    alt,
}) => (
    <picture>
        {/* WebP for modern browsers */}
        <source srcSet={`${src}.webp`} type="image/webp" />
        {/* Fallback to JPEG */}
        <img
            src={`${src}.jpg`}
            alt={alt}
            loading="lazy"
            decoding="async"
            style={{ width: '100%', height: 'auto' }}
        />
    </picture>
);

// Responsive images
<img
    srcSet={`small.jpg 480w, medium.jpg 800w, large.jpg 1200w`}
    sizes="(max-width: 480px) 100vw, (max-width: 800px) 75vw, 1200px"
    src="large.jpg"
    alt="Description"
/>
```

**5. Network Optimization:**
```typescript
// Request caching strategy
class CacheManager {
    private cache = new Map<string, { data: any; timestamp: number }>();
    private ttl = 5 * 60 * 1000; // 5 minutes

    async fetch<T>(url: string, fetcher: () => Promise<T>): Promise<T> {
        const cached = this.cache.get(url);
        if (cached && Date.now() - cached.timestamp < this.ttl) {
            return cached.data;
        }

        const data = await fetcher();
        this.cache.set(url, { data, timestamp: Date.now() });
        return data;
    }

    clear(url?: string) {
        if (url) {
            this.cache.delete(url);
        } else {
            this.cache.clear();
        }
    }
}

// Request batching
class RequestBatcher {
    private queue = new Map<string, () => Promise<any>>();
    private timer: NodeJS.Timeout | null = null;

    add(key: string, request: () => Promise<any>) {
        this.queue.set(key, request);

        if (!this.timer) {
            this.timer = setTimeout(() => this.flush(), 50);
        }
    }

    private async flush() {
        const requests = Array.from(this.queue.values());
        this.queue.clear();
        this.timer = null;

        await Promise.all(requests.map(req => req()));
    }
}
```

**6. Web Workers for Heavy Processing:**
```typescript
// worker.ts
self.onmessage = (event: MessageEvent) => {
    const { type, payload } = event.data;

    if (type === 'PROCESS_DATA') {
        const result = heavyComputation(payload);
        self.postMessage({ type: 'RESULT', payload: result });
    }
};

// main-thread.ts
const worker = new Worker('worker.ts');

export function processLargeDataset(data: any[]): Promise<any> {
    return new Promise(resolve => {
        const handler = (event: MessageEvent) => {
            if (event.data.type === 'RESULT') {
                worker.removeEventListener('message', handler);
                resolve(event.data.payload);
            }
        };

        worker.addEventListener('message', handler);
        worker.postMessage({ type: 'PROCESS_DATA', payload: data });
    });
}
```

**Metrics to Monitor:**
- **Core Web Vitals**: LCP (Largest Contentful Paint), FID (First Input Delay), CLS (Cumulative Layout Shift)
- **Time to Interactive (TTI)**: When page is usable
- **First Contentful Paint (FCP)**: When first content appears
- **Total Blocking Time (TBT)**: Sum of blocking time during FCP to TTI

---

## Part 3: State Management & Architecture

### Q4: Design a Type-Safe State Management System

**Question:**
Create a TypeScript-first state management system that scales and prevents common bugs.

**Solution Approach:**

```typescript
// types.ts
export interface BaseAction {
    type: string;
    payload?: any;
}

export type Reducer<S> = (state: S, action: BaseAction) => S;
export type Subscriber<S> = (state: S) => void;
export type Dispatch<A extends BaseAction = BaseAction> = (action: A) => void;

// store.ts
export class Store<S extends Record<string, any>> {
    private state: S;
    private subscribers = new Set<Subscriber<S>>();
    private history: S[] = [];
    private maxHistory = 50;

    constructor(
        private reducer: Reducer<S>,
        initialState: S
    ) {
        this.state = initialState;
    }

    // Dispatch with type safety
    dispatch<A extends BaseAction>(action: A): void {
        const previousState = JSON.parse(JSON.stringify(this.state));
        this.state = this.reducer(this.state, action);

        // Track history
        this.history.push(previousState);
        if (this.history.length > this.maxHistory) {
            this.history.shift();
        }

        // Notify subscribers
        this.subscribers.forEach(subscriber => subscriber(this.state));
    }

    // Get current state
    getState(): Readonly<S> {
        return Object.freeze(JSON.parse(JSON.stringify(this.state)));
    }

    // Subscribe to changes
    subscribe(subscriber: Subscriber<S>): () => void {
        this.subscribers.add(subscriber);
        return () => {
            this.subscribers.delete(subscriber);
        };
    }

    // Undo last action
    undo(): void {
        if (this.history.length > 0) {
            this.state = this.history.pop()!;
            this.subscribers.forEach(subscriber => subscriber(this.state));
        }
    }

    // Debug: Get state history
    getHistory(): ReadonlyArray<S> {
        return [...this.history];
    }
}

// Actions with discriminated union
export type AppAction =
    | { type: 'USER_LOGIN'; payload: { userId: string; email: string } }
    | { type: 'USER_LOGOUT' }
    | { type: 'UPDATE_SETTINGS'; payload: { theme: 'light' | 'dark' } }
    | { type: 'LOAD_DATA'; payload: { items: any[] } };

// State shape
export interface AppState {
    user: {
        id: string | null;
        email: string | null;
    };
    settings: {
        theme: 'light' | 'dark';
    };
    data: {
        items: any[];
        loading: boolean;
    };
}

// Typed reducer
export const appReducer: Reducer<AppState> = (state, action) => {
    const typedAction = action as AppAction;

    switch (typedAction.type) {
        case 'USER_LOGIN':
            return {
                ...state,
                user: {
                    id: typedAction.payload.userId,
                    email: typedAction.payload.email,
                },
            };

        case 'USER_LOGOUT':
            return {
                ...state,
                user: { id: null, email: null },
            };

        case 'UPDATE_SETTINGS':
            return {
                ...state,
                settings: {
                    theme: typedAction.payload.theme,
                },
            };

        case 'LOAD_DATA':
            return {
                ...state,
                data: {
                    items: typedAction.payload.items,
                    loading: false,
                },
            };

        default:
            return state;
    }
};

// Usage
const initialState: AppState = {
    user: { id: null, email: null },
    settings: { theme: 'light' },
    data: { items: [], loading: false },
};

const store = new Store(appReducer, initialState);

// Type-safe dispatch
store.dispatch({
    type: 'USER_LOGIN',
    payload: { userId: '123', email: 'user@example.com' },
});

// Subscribe to changes
store.subscribe(state => {
    console.log('State updated:', state);
});

// React integration
export function useAppStore() {
    const [state, setState] = useState(store.getState());

    useEffect(() => {
        return store.subscribe(setState);
    }, []);

    const dispatch: Dispatch<AppAction> = (action) => {
        store.dispatch(action);
    };

    return [state, dispatch] as const;
}
```

**Advantages:**
- **Type Safety**: Discriminated unions ensure correct payloads
- **Immutability**: Reducer pattern enforces immutability
- **History**: Built-in undo capability
- **Testing**: Pure functions, easy to test
- **Scalability**: Works with large state trees

---

## Part 4: Testing & Quality Assurance

### Q5: Design a Comprehensive Testing Strategy

**Question:**
Outline a testing strategy for a large web application covering unit, integration, and E2E tests.

**Solution Approach:**

```typescript
// Test Pyramid
// Top: E2E (10% of tests)
// Middle: Integration (30% of tests)
// Bottom: Unit (60% of tests)

// 1. Unit Tests (Jest)
describe('Button Component', () => {
    it('should render with children', () => {
        const { getByText } = render(
            <Button>Click me</Button>
        );
        expect(getByText('Click me')).toBeInTheDocument();
    });

    it('should call onClick when clicked', () => {
        const onClick = jest.fn();
        const { getByRole } = render(
            <Button onClick={onClick}>Click me</Button>
        );
        fireEvent.click(getByRole('button'));
        expect(onClick).toHaveBeenCalled();
    });

    it('should be disabled when disabled prop is true', () => {
        const { getByRole } = render(
            <Button disabled>Click me</Button>
        );
        expect(getByRole('button')).toBeDisabled();
    });

    it('should have correct ARIA attributes', () => {
        const { getByRole } = render(
            <Button aria-label="Close modal">×</Button>
        );
        expect(getByRole('button')).toHaveAttribute('aria-label', 'Close modal');
    });
});

// 2. Integration Tests (React Testing Library)
describe('UserForm Integration', () => {
    it('should submit form with valid data', async () => {
        const mockSubmit = jest.fn();
        const { getByRole, getByLabelText } = render(
            <UserForm onSubmit={mockSubmit} />
        );

        // Fill form
        fireEvent.change(getByLabelText(/name/i), { target: { value: 'John' } });
        fireEvent.change(getByLabelText(/email/i), {
            target: { value: 'john@example.com' },
        });

        // Submit
        fireEvent.click(getByRole('button', { name: /submit/i }));

        // Wait for async submission
        await waitFor(() => {
            expect(mockSubmit).toHaveBeenCalledWith({
                name: 'John',
                email: 'john@example.com',
            });
        });
    });

    it('should show validation errors', async () => {
        const { getByRole, getByText } = render(<UserForm />);

        fireEvent.click(getByRole('button', { name: /submit/i }));

        await waitFor(() => {
            expect(getByText(/name is required/i)).toBeInTheDocument();
        });
    });
});

// 3. E2E Tests (Cypress)
describe('User Registration Flow', () => {
    beforeEach(() => {
        cy.visit('http://localhost:3000/register');
    });

    it('should complete registration flow', () => {
        // Fill registration form
        cy.get('input[name="email"]').type('newuser@example.com');
        cy.get('input[name="password"]').type('SecurePassword123!');
        cy.get('input[name="confirmPassword"]').type('SecurePassword123!');

        // Accept terms
        cy.get('input[type="checkbox"]').check();

        // Submit
        cy.get('button[type="submit"]').click();

        // Verify success
        cy.contains('Account created successfully').should('be.visible');
        cy.url().should('include', '/dashboard');
    });

    it('should show error for existing email', () => {
        cy.get('input[name="email"]').type('existing@example.com');
        cy.get('input[name="password"]').type('Password123!');
        cy.get('input[name="confirmPassword"]').type('Password123!');
        cy.get('button[type="submit"]').click();

        cy.contains('Email already exists').should('be.visible');
    });
});

// 4. Visual Regression Tests (Percy)
describe('Button Variants Visual Tests', () => {
    it('should render all button variants correctly', () => {
        cy.visit('http://localhost:6006/?path=/story/button--primary');
        cy.percySnapshot('Button Primary');
    });
});

// 5. Performance Tests (Lighthouse CI)
describe('Performance', () => {
    it('should load dashboard within 3 seconds', () => {
        cy.visit('http://localhost:3000/dashboard', {
            onBeforeLoad: (win) => {
                win.performance.mark('pageStart');
            },
        });

        cy.window().then((win) => {
            win.performance.mark('pageEnd');
            win.performance.measure('pageLoad', 'pageStart', 'pageEnd');
            const measure = win.performance.getEntriesByName('pageLoad')[0];
            expect(measure.duration).toBeLessThan(3000);
        });
    });
});

// 6. Accessibility Tests (jest-axe)
describe('Accessibility', () => {
    it('button should not have accessibility violations', async () => {
        const { container } = render(
            <Button>Click me</Button>
        );
        const results = await axe(container);
        expect(results).toHaveNoViolations();
    });

    it('form should be keyboard navigable', () => {
        const { getByRole } = render(
            <UserForm />
        );
        const nameField = getByRole('textbox', { name: /name/i });
        const emailField = getByRole('textbox', { name: /email/i });
        const submitButton = getByRole('button');

        nameField.focus();
        expect(document.activeElement).toBe(nameField);

        nameField.dispatchEvent(new KeyboardEvent('keydown', { key: 'Tab' }));
        // Should move to next field
    });
});

// 7. Test Coverage
// package.json scripts:
{
    "test": "jest --coverage",
    "test:watch": "jest --watch",
    "test:e2e": "cypress open",
    "test:a11y": "jest --testPathPattern=a11y",
    "test:coverage": "jest --coverage && open coverage/index.html"
}

// Jest coverage configuration
{
    "jest": {
        "collectCoverageFrom": [
            "src/**/*.{ts,tsx}",
            "!src/**/*.d.ts",
            "!src/index.tsx"
        ],
        "coverageThresholds": {
            "global": {
                "branches": 80,
                "functions": 80,
                "lines": 80,
                "statements": 80
            }
        }
    }
}
```

**Testing Strategy Summary:**
- **Unit Tests**: Individual functions, components (80% coverage)
- **Integration Tests**: Component interactions, API mocking (15% coverage)
- **E2E Tests**: Full user flows (5% coverage)
- **Accessibility Tests**: WCAG compliance
- **Visual Regression**: Screenshot comparisons
- **Performance Tests**: Load times, metrics

---

## Part 5: Advanced Patterns & Techniques

### Q6: Design an API Client Architecture

**Question:**
Create a reusable, type-safe API client that handles authentication, errors, and caching.

**Solution:**

```typescript
// types.ts
export interface RequestConfig {
    headers?: Record<string, string>;
    params?: Record<string, any>;
    timeout?: number;
}

export interface ApiResponse<T> {
    data: T;
    status: number;
    headers: Record<string, string>;
}

export interface ApiError {
    message: string;
    status: number;
    code: string;
    details?: any;
}

// error-handler.ts
export class ApiErrorHandler {
    static handle(error: any): ApiError {
        if (error.response) {
            // Server responded with error status
            return {
                message: error.response.data?.message || 'Request failed',
                status: error.response.status,
                code: error.response.data?.code || 'UNKNOWN_ERROR',
                details: error.response.data,
            };
        } else if (error.request) {
            // Request was made but no response
            return {
                message: 'No response from server',
                status: 0,
                code: 'NO_RESPONSE',
            };
        } else {
            // Error in request setup
            return {
                message: error.message,
                status: 0,
                code: 'REQUEST_ERROR',
            };
        }
    }
}

// interceptors.ts
export class Interceptors {
    private requestInterceptors: Array<(config: RequestConfig) => RequestConfig> = [];
    private responseInterceptors: Array<(response: any) => any> = [];
    private errorInterceptors: Array<(error: ApiError) => void> = [];

    addRequestInterceptor(handler: (config: RequestConfig) => RequestConfig) {
        this.requestInterceptors.push(handler);
    }

    addResponseInterceptor(handler: (response: any) => any) {
        this.responseInterceptors.push(handler);
    }

    addErrorInterceptor(handler: (error: ApiError) => void) {
        this.errorInterceptors.push(handler);
    }

    processRequest(config: RequestConfig): RequestConfig {
        return this.requestInterceptors.reduce(
            (config, handler) => handler(config),
            config
        );
    }

    processResponse(response: any) {
        return this.responseInterceptors.reduce(
            (response, handler) => handler(response),
            response
        );
    }

    processError(error: ApiError) {
        this.errorInterceptors.forEach(handler => handler(error));
    }
}

// api-client.ts
export class ApiClient {
    private baseUrl: string;
    private interceptors: Interceptors;
    private cache = new Map<string, { data: any; timestamp: number }>();
    private cacheTTL = 5 * 60 * 1000; // 5 minutes

    constructor(baseUrl: string) {
        this.baseUrl = baseUrl;
        this.interceptors = new Interceptors();

        // Add default interceptors
        this.addAuthInterceptor();
        this.addErrorHandlingInterceptor();
    }

    private addAuthInterceptor() {
        this.interceptors.addRequestInterceptor((config) => {
            const token = localStorage.getItem('auth_token');
            if (token) {
                config.headers = {
                    ...config.headers,
                    'Authorization': `Bearer ${token}`,
                };
            }
            return config;
        });
    }

    private addErrorHandlingInterceptor() {
        this.interceptors.addErrorInterceptor((error) => {
            if (error.status === 401) {
                // Handle unauthorized
                localStorage.removeItem('auth_token');
                window.location.href = '/login';
            }
        });
    }

    private getCacheKey(method: string, url: string, params?: any): string {
        return `${method}:${url}:${JSON.stringify(params)}`;
    }

    async get<T>(url: string, config?: RequestConfig): Promise<T> {
        const cacheKey = this.getCacheKey('GET', url, config?.params);

        // Check cache
        const cached = this.cache.get(cacheKey);
        if (cached && Date.now() - cached.timestamp < this.cacheTTL) {
            return cached.data;
        }

        const config_ = this.interceptors.processRequest({ ...config, params: config?.params });
        const fullUrl = new URL(url, this.baseUrl);

        // Add query parameters
        if (config_.params) {
            Object.entries(config_.params).forEach(([key, value]) => {
                fullUrl.searchParams.set(key, String(value));
            });
        }

        try {
            const response = await fetch(fullUrl.toString(), {
                method: 'GET',
                headers: config_.headers || {},
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const data = await response.json();
            const processedData = this.interceptors.processResponse(data);

            // Cache successful response
            this.cache.set(cacheKey, { data: processedData, timestamp: Date.now() });

            return processedData;
        } catch (error) {
            const apiError = ApiErrorHandler.handle(error);
            this.interceptors.processError(apiError);
            throw apiError;
        }
    }

    async post<T>(url: string, body?: any, config?: RequestConfig): Promise<T> {
        return this.request<T>('POST', url, body, config);
    }

    async put<T>(url: string, body?: any, config?: RequestConfig): Promise<T> {
        return this.request<T>('PUT', url, body, config);
    }

    async delete<T>(url: string, config?: RequestConfig): Promise<T> {
        return this.request<T>('DELETE', url, undefined, config);
    }

    private async request<T>(method: string, url: string, body?: any, config?: RequestConfig): Promise<T> {
        const config_ = this.interceptors.processRequest(config || {});
        const fullUrl = new URL(url, this.baseUrl);

        try {
            const response = await fetch(fullUrl.toString(), {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    ...config_.headers,
                },
                body: body ? JSON.stringify(body) : undefined,
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const data = await response.json();
            return this.interceptors.processResponse(data);
        } catch (error) {
            const apiError = ApiErrorHandler.handle(error);
            this.interceptors.processError(apiError);
            throw apiError;
        }
    }

    clearCache(url?: string) {
        if (url) {
            Array.from(this.cache.keys())
                .filter(key => key.includes(url))
                .forEach(key => this.cache.delete(key));
        } else {
            this.cache.clear();
        }
    }
}

// Usage
export const apiClient = new ApiClient(process.env.REACT_APP_API_URL || 'http://localhost:3000/api');

// Define typed endpoints
export const userApi = {
    getMe: () => apiClient.get<User>('/users/me'),
    getById: (id: string) => apiClient.get<User>(`/users/${id}`),
    update: (id: string, data: Partial<User>) =>
        apiClient.put<User>(`/users/${id}`, data),
    delete: (id: string) => apiClient.delete<void>(`/users/${id}`),
};

// React hook
export function useApi<T>(
    apiCall: () => Promise<T>,
    dependencies: any[] = []
) {
    const [data, setData] = useState<T | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<ApiError | null>(null);

    useEffect(() => {
        let mounted = true;

        (async () => {
            try {
                setLoading(true);
                const result = await apiCall();
                if (mounted) {
                    setData(result);
                    setError(null);
                }
            } catch (err) {
                if (mounted) {
                    setError(err as ApiError);
                }
            } finally {
                if (mounted) {
                    setLoading(false);
                }
            }
        })();

        return () => {
            mounted = false;
        };
    }, dependencies);

    return { data, loading, error };
}

// Usage
function UserProfile({ userId }: { userId: string }) {
    const { data: user, loading, error } = useApi(
        () => userApi.getById(userId),
        [userId]
    );

    if (loading) return <Skeleton />;
    if (error) return <ErrorMessage error={error} />;
    return <UserCard user={user} />;
}
```

---

## Conclusion

These advanced architecture questions cover the design decisions senior engineers make:

1. **Component Systems**: Scaling UI across teams
2. **Micro-Frontends**: Independent feature development
3. **Performance**: Handling large datasets and complex UIs
4. **State Management**: Type-safe, scalable solutions
5. **Testing**: Comprehensive quality assurance
6. **API Design**: Reusable, maintainable client code

The key is balancing simplicity with scalability, and always considering team needs and application requirements.

---

**Last Updated:** October 26, 2024
**Level:** Expert (5+ years)
**Total Patterns:** 25+
**Estimated Study Time:** 40-50 hours
