# React with TypeScript - Interview Preparation Guide

## Part 1: Behavioral Questions

### Question 1: Tell us about your React experience

**Why they ask:** Understand your background and expertise level

**How to answer:**
- Mention years of experience
- Describe the types of applications you've built
- Highlight key projects
- Mention technologies and frameworks used
- Show progression in your skills

**Sample Answer:**

```
I have 3 years of professional experience with React, starting with basic component development
and progressing to architecting complex, scalable applications. I've built:

1. E-commerce platform with 50+ components, optimized for performance with 99+ Lighthouse score
2. Real-time analytics dashboard using WebSockets for live data updates
3. Enterprise admin panel with complex state management using Redux

My expertise includes React 18 features (concurrent rendering, suspense), TypeScript type safety,
custom hooks for logic reusability, and modern testing practices with Vitest and Playwright.

Key achievements:
- Reduced bundle size by 40% through code splitting and lazy loading
- Implemented reusable component library used across 3 projects
- Mentored 2 junior developers in React best practices
```

---

### Question 2: Describe a challenging problem you solved with React

**Why they ask:** Assess problem-solving skills and technical depth

**Structure:**
1. **Situation** - What was the challenge?
2. **Task** - What was your responsibility?
3. **Action** - What did you do?
4. **Result** - What was the outcome?

**Sample Answer:**

```
Challenge: An analytics dashboard with thousands of data points was rendering slowly, taking 5+ seconds.

Situation: The dashboard displayed multiple charts with 1000+ data points each. Users complained about
sluggish interactions, especially when filtering or zooming.

Action:
1. Profiled the app using React DevTools Profiler - found unnecessary re-renders in chart components
2. Implemented React.memo on chart components to prevent re-renders
3. Used useMemo to cache filtered data calculations
4. Implemented virtual scrolling for tables with 1000+ rows using react-window
5. Code-split heavy charting library with lazy loading
6. Switched to a faster charting library with better performance

Result:
- Reduced render time from 5+ seconds to under 500ms
- Improved Core Web Vitals (LCP from 4s to 1.2s)
- User satisfaction increased significantly
- Implemented monitoring with web-vitals library to track ongoing performance
```

---

### Question 3: How do you handle disagreements with team members?

**Why they ask:** Assess collaboration and communication skills

**How to answer:**
- Show you value other perspectives
- Explain your conflict resolution approach
- Give a specific example
- Show respect for the team

**Sample Answer:**

```
I believe in collaborative problem-solving. When disagreements arise, I:

1. Listen to understand the other person's perspective completely
2. Share my viewpoint with data/evidence when possible
3. Focus on the problem, not the person
4. Propose compromises or solutions that benefit the project

Example: During code review, a colleague suggested using Redux for state management on a small project.
I initially thought Context API was sufficient. Rather than dismiss the idea, I:
- Asked why they preferred Redux (they had performance concerns)
- Proposed implementing Context API optimally with custom hooks first
- Agreed to reassess if performance became an issue
- Set a metric to measure (re-render counts) to make data-driven decision

We went with Context API, monitored performance, and it worked great. The key was listening,
not assuming, and being willing to change my mind with evidence.
```

---

### Question 4: Describe your approach to learning new technologies

**Why they ask:** Assess growth mindset and learning ability

**How to answer:**
- Show proactive learning
- Give specific examples
- Mention resources you use
- Show results of learning

**Sample Answer:**

```
I'm passionate about continuous learning. My approach:

1. Start with official documentation and understand core concepts
2. Build small side projects to practice
3. Read high-quality blog posts and case studies
4. Contribute to open-source projects
5. Stay updated with community (conferences, podcasts, newsletters)

Example: When React 18 was released with concurrent rendering:
- Read the official React docs on concurrent features
- Built a search application using useTransition and useDeferredValue
- Wrote a blog post explaining the concepts to solidify understanding
- Shared learnings with the team
- Implemented it in a real production app

I believe learning by doing is most effective. I also enjoy mentoring others, as teaching
reinforces my own understanding.
```

---

### Question 5: Tell us about a time you failed and learned from it

**Why they ask:** Assess resilience and self-awareness

**How to answer:**
- Be honest about a real failure
- Show what you learned
- Demonstrate improvement
- Stay humble

**Sample Answer:**

```
Early in my career, I built a form component with deeply nested prop drilling that made it
unmaintainable. When adding a new feature required modifying 5 parent components, I realized
the architecture was wrong.

What I learned:
1. Recognize code smells early (prop drilling is a warning sign)
2. Not all data needs to be in parent components
3. Context API solves many prop drilling issues elegantly
4. Refactoring is an investment, not a cost

I refactored the form using Context API and custom hooks. The result was:
- Cleaner, more maintainable code
- Easier to add new fields
- Better component reusability
- Easier to test

Now I design for maintainability from the start and refactor proactively.
```

---

## Part 2: Technical Questions

### Question 6: What's the difference between controlled and uncontrolled components?

**Answer with Code:**

```typescript
// Controlled: State is in React
interface ControlledInputProps {
    value: string;
    onChange: (value: string) => void;
}

const ControlledInput: React.FC<ControlledInputProps> = ({ value, onChange }) => (
    <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
    />
);

// Usage
const Parent: React.FC = () => {
    const [value, setValue] = React.useState('');
    return <ControlledInput value={value} onChange={setValue} />;
};

// Uncontrolled: State is in DOM
const UncontrolledInput = React.forwardRef<HTMLInputElement, {}>((_, ref) => (
    <input ref={ref} />
));

// Usage
const Parent2: React.FC = () => {
    const inputRef = React.useRef<HTMLInputElement>(null);
    const handleSubmit = () => {
        console.log(inputRef.current?.value);
    };
    return (
        <>
            <UncontrolledInput ref={inputRef} />
            <button onClick={handleSubmit}>Submit</button>
        </>
    );
};
```

**Key Points:**
- **Controlled:** React state is source of truth
- **Uncontrolled:** DOM is source of truth
- **Controlled:** Better for validation and complex logic
- **Uncontrolled:** Simpler, fewer re-renders
- **File inputs:** Always uncontrolled
- **Integration with non-React code:** Use uncontrolled

---

### Question 7: Explain React Hooks and why they were introduced

**Answer:**

Hooks are functions that let you "hook into" React state and lifecycle features without writing class components.

**Why they were introduced:**
1. **Complexity in components** - Class components mix related logic across lifecycle methods
2. **Code reuse** - Difficult to share stateful logic between components
3. **Wrapper hell** - HOCs and render props create deeply nested component trees
4. **"this" binding** - Confusing for newcomers

**Common Hooks:**

```typescript
// useState - State management
const [count, setCount] = React.useState(0);

// useEffect - Side effects
React.useEffect(() => {
    document.title = `Count: ${count}`;
}, [count]);

// useContext - Access context
const theme = React.useContext(ThemeContext);

// useReducer - Complex state
const [state, dispatch] = React.useReducer(reducer, initialState);

// useMemo - Memoize values
const memoizedValue = React.useMemo(() => computeValue(a, b), [a, b]);

// useCallback - Memoize functions
const handleClick = React.useCallback(() => {
    doSomething(a, b);
}, [a, b]);

// useRef - Persistent references
const inputRef = React.useRef<HTMLInputElement>(null);

// useLayoutEffect - Synchronous effects
React.useLayoutEffect(() => {
    // Runs synchronously after DOM mutation
}, []);
```

---

### Question 8: How do you optimize performance in React applications?

**Answer with Examples:**

```typescript
// 1. Memoization
const MemoChild = React.memo(({ count }: { count: number }) => {
    console.log('Rendered');
    return <div>{count}</div>;
});

// 2. useMemo for expensive calculations
const expensiveValue = React.useMemo(() => {
    return items.filter(item => computeCondition(item));
}, [items]);

// 3. useCallback to prevent unnecessary re-renders of memoized children
const handleClick = React.useCallback(() => {
    dispatch({ type: 'INCREMENT' });
}, [dispatch]);

// 4. Code splitting
const HeavyComponent = React.lazy(() => import('./Heavy'));
<Suspense fallback={<Spinner />}>
    <HeavyComponent />
</Suspense>

// 5. Virtual scrolling for large lists
import { FixedSizeList } from 'react-window';
<FixedSizeList height={600} itemCount={1000} itemSize={35} />

// 6. Using keys correctly
{items.map(item => (
    <Item key={item.id} item={item} />  // ✅ Use unique ID
))}

// 7. Image optimization
<img
    srcSet="small.jpg 480w, large.jpg 1200w"
    sizes="(max-width: 480px) 100vw, 1200px"
    src="large.jpg"
    loading="lazy"
/>
```

**Key Principles:**
- Measure with React Profiler before optimizing
- Don't optimize prematurely
- Use React DevTools to identify bottlenecks
- Profile in production builds
- Monitor Core Web Vitals

---

### Question 9: Explain the difference between useEffect and useLayoutEffect

**Answer:**

```typescript
// useEffect (Recommended)
React.useEffect(() => {
    // Runs AFTER paint
    // Non-blocking, asynchronous
    // Best for data fetching, subscriptions
    console.log('useEffect');
}, []);

// useLayoutEffect (Rare)
React.useLayoutEffect(() => {
    // Runs BEFORE paint
    // Synchronous, blocks paint
    // Use for DOM mutations that affect layout
    const height = measureElement();
    adjustLayout(height);
}, []);

// Timing Example
const Demo: React.FC = () => {
    React.useLayoutEffect(() => {
        console.log('2. Layout effect');
    }, []);

    React.useEffect(() => {
        console.log('3. Effect');
    }, []);

    console.log('1. Render');

    // Output order: 1, 2, 3
};
```

**When to use each:**
- **useEffect:** Default choice for 99% of cases
- **useLayoutEffect:** DOM measurements, animations that affect layout

---

### Question 10: How do you handle errors in React applications?

**Answer with Code:**

```typescript
// Error Boundaries (class components)
class ErrorBoundary extends React.Component<
    { children: React.ReactNode },
    { hasError: boolean; error: Error | null }
> {
    constructor(props: { children: React.ReactNode }) {
        super(props);
        this.state = { hasError: false, error: null };
    }

    static getDerivedStateFromError(error: Error) {
        return { hasError: true, error };
    }

    componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
        // Log to error reporting service
        console.error('Error:', error, errorInfo);
    }

    render() {
        if (this.state.hasError) {
            return <div>Something went wrong: {this.state.error?.message}</div>;
        }
        return this.props.children;
    }
}

// Usage
<ErrorBoundary>
    <MyComponent />
</ErrorBoundary>

// Try-catch for event handlers
const handleClick = async () => {
    try {
        await riskyOperation();
    } catch (error) {
        setError(error instanceof Error ? error.message : 'Unknown error');
    }
};

// Custom error handling hook
function useAsync<T>(asyncFn: () => Promise<T>) {
    const [state, setState] = React.useState<{
        data: T | null;
        error: Error | null;
        loading: boolean;
    }>({
        data: null,
        error: null,
        loading: true,
    });

    React.useEffect(() => {
        asyncFn()
            .then(data => setState({ data, error: null, loading: false }))
            .catch(error => setState({ data: null, error, loading: false }));
    }, [asyncFn]);

    return state;
}
```

---

## Part 3: Architecture and Design Questions

### Question 11: How would you structure a large-scale React application?

**Answer:**

```
project/
├── src/
│   ├── components/
│   │   ├── common/           # Reusable components (Button, Card, etc.)
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   └── Modal.tsx
│   │   ├── features/         # Feature-specific components
│   │   │   ├── auth/
│   │   │   │   ├── Login.tsx
│   │   │   │   └── Register.tsx
│   │   │   ├── dashboard/
│   │   │   │   ├── Dashboard.tsx
│   │   │   │   └── DashboardChart.tsx
│   │   │   └── products/
│   │   │       ├── ProductList.tsx
│   │   │       └── ProductDetail.tsx
│   │   └── layout/           # Layout components
│   │       ├── Header.tsx
│   │       ├── Sidebar.tsx
│   │       └── Footer.tsx
│   ├── pages/                # Page components (route-level)
│   │   ├── HomePage.tsx
│   │   ├── DashboardPage.tsx
│   │   └── NotFoundPage.tsx
│   ├── hooks/                # Custom hooks
│   │   ├── useAuth.ts
│   │   ├── useFetch.ts
│   │   └── useDebounce.ts
│   ├── services/             # Business logic, API calls
│   │   ├── api.ts
│   │   ├── auth.service.ts
│   │   └── product.service.ts
│   ├── context/              # Context providers
│   │   ├── AuthContext.tsx
│   │   └── ThemeContext.tsx
│   ├── store/                # State management
│   │   ├── store.ts
│   │   ├── slices/
│   │   │   ├── authSlice.ts
│   │   │   └── productSlice.ts
│   ├── types/                # TypeScript types
│   │   ├── index.ts
│   │   └── api.ts
│   ├── utils/                # Utility functions
│   │   ├── format.ts
│   │   └── validation.ts
│   ├── styles/               # Global styles
│   │   ├── globals.css
│   │   └── variables.css
│   ├── Router.tsx            # Route configuration
│   └── App.tsx               # App entry point
├── tests/                    # Test files
│   ├── components/
│   ├── hooks/
│   └── services/
└── package.json
```

**Key Principles:**
1. **Separation of Concerns** - Each file has one responsibility
2. **Feature-based Structure** - Group by features, not file types
3. **Scalability** - Easy to add new features
4. **Testability** - Easy to write tests
5. **Maintainability** - Clear organization, easy to find code

---

### Question 12: Design a component library for your company

**Answer:**

```typescript
// Structure
components/
├── core/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx
│   │   ├── Button.styles.tsx
│   │   └── index.ts
│   ├── Input/
│   ├── Card/
│   └── ...
├── theme/
│   ├── colors.ts
│   ├── spacing.ts
│   ├── typography.ts
│   └── ThemeProvider.tsx
└── index.ts (exports all components)

// Example: Button Component
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'danger';
    size?: 'sm' | 'md' | 'lg';
    isLoading?: boolean;
    children: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
    ({ variant = 'primary', size = 'md', isLoading, children, ...props }, ref) => (
        <button
            ref={ref}
            className={cn('btn', `btn-${variant}`, `btn-${size}`)}
            disabled={isLoading || props.disabled}
            {...props}
        >
            {isLoading && <Spinner size={size} />}
            {children}
        </button>
    )
);

// Theme system
export const theme = {
    colors: {
        primary: '#667eea',
        secondary: '#764ba2',
        danger: '#ef4444',
    },
    spacing: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
    },
    typography: {
        h1: { fontSize: '32px', fontWeight: 'bold' },
        h2: { fontSize: '24px', fontWeight: 'bold' },
        body: { fontSize: '16px', lineHeight: '1.5' },
    },
};

// Usage
<Button variant="primary" size="lg">
    Click me
</Button>
```

---

### Question 13: How would you implement authentication in React?

**Answer:**

```typescript
// 1. Create authentication context
interface User {
    id: string;
    email: string;
    name: string;
}

interface AuthContextType {
    user: User | null;
    loading: boolean;
    error: string | null;
    login: (email: string, password: string) => Promise<void>;
    logout: () => void;
    register: (email: string, password: string, name: string) => Promise<void>;
}

const AuthContext = React.createContext<AuthContextType | undefined>(undefined);

// 2. Auth provider
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [state, setState] = React.useState<{
        user: User | null;
        loading: boolean;
        error: string | null;
    }>({
        user: null,
        loading: true,
        error: null,
    });

    // Check if user is already logged in
    React.useEffect(() => {
        const checkAuth = async () => {
            try {
                const response = await fetch('/api/auth/me');
                if (response.ok) {
                    const user = await response.json();
                    setState({ user, loading: false, error: null });
                } else {
                    setState({ user: null, loading: false, error: null });
                }
            } catch (error) {
                setState({ user: null, loading: false, error: error instanceof Error ? error.message : 'Unknown error' });
            }
        };

        checkAuth();
    }, []);

    const login = async (email: string, password: string) => {
        try {
            const response = await fetch('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password }),
            });

            if (!response.ok) throw new Error('Login failed');

            const user = await response.json();
            setState({ user, loading: false, error: null });
        } catch (error) {
            setState({
                user: null,
                loading: false,
                error: error instanceof Error ? error.message : 'Login error',
            });
            throw error;
        }
    };

    const logout = () => {
        setState({ user: null, loading: false, error: null });
        // Call logout endpoint
    };

    const register = async (email: string, password: string, name: string) => {
        try {
            const response = await fetch('/api/auth/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password, name }),
            });

            if (!response.ok) throw new Error('Registration failed');

            const user = await response.json();
            setState({ user, loading: false, error: null });
        } catch (error) {
            setState({
                user: null,
                loading: false,
                error: error instanceof Error ? error.message : 'Registration error',
            });
            throw error;
        }
    };

    return (
        <AuthContext.Provider value={{ ...state, login, logout, register }}>
            {children}
        </AuthContext.Provider>
    );
};

// 3. Protected route
interface ProtectedRouteProps {
    element: React.ReactElement;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ element }) => {
    const { user, loading } = useAuth();

    if (loading) return <Spinner />;

    return user ? element : <Navigate to="/login" />;
};

// 4. Usage
<AuthProvider>
    <Router>
        <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/dashboard" element={<ProtectedRoute element={<Dashboard />} />} />
        </Routes>
    </Router>
</AuthProvider>
```

---

## Part 4: Problem-Solving Questions

### Question 14: How would you implement a debounced search?

**Answer:**

```typescript
// 1. Custom useDebounce hook
function useDebounce<T>(value: T, delay: number): T {
    const [debouncedValue, setDebouncedValue] = React.useState(value);

    React.useEffect(() => {
        const handler = setTimeout(() => {
            setDebouncedValue(value);
        }, delay);

        return () => clearTimeout(handler);
    }, [value, delay]);

    return debouncedValue;
}

// 2. Usage in search component
interface SearchResult {
    id: number;
    name: string;
}

const SearchComponent: React.FC = () => {
    const [query, setQuery] = React.useState('');
    const debouncedQuery = useDebounce(query, 300);

    const [results, setResults] = React.useState<SearchResult[]>([]);
    const [loading, setLoading] = React.useState(false);
    const [error, setError] = React.useState<string | null>(null);

    // Fetch results when debounced query changes
    React.useEffect(() => {
        if (!debouncedQuery.trim()) {
            setResults([]);
            return;
        }

        const fetchResults = async () => {
            setLoading(true);
            setError(null);

            try {
                const response = await fetch(`/api/search?q=${encodeURIComponent(debouncedQuery)}`);
                if (!response.ok) throw new Error('Search failed');
                const data = await response.json();
                setResults(data);
            } catch (err) {
                setError(err instanceof Error ? err.message : 'Search error');
            } finally {
                setLoading(false);
            }
        };

        fetchResults();
    }, [debouncedQuery]);

    return (
        <div>
            <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Search..."
            />
            {loading && <Spinner />}
            {error && <Error message={error} />}
            <ul>
                {results.map(result => (
                    <li key={result.id}>{result.name}</li>
                ))}
            </ul>
        </div>
    );
};
```

---

### Question 15: Design a system to handle infinite scrolling

**Answer:**

```typescript
// 1. Custom hook for infinite scroll
interface UseInfiniteScrollOptions {
    onLoadMore: () => Promise<void>;
    threshold?: number;
}

function useInfiniteScroll({ onLoadMore, threshold = 0.5 }: UseInfiniteScrollOptions) {
    const observerTarget = React.useRef<HTMLDivElement>(null);
    const [isLoading, setIsLoading] = React.useState(false);

    React.useEffect(() => {
        if (!observerTarget.current) return;

        const observer = new IntersectionObserver(
            async (entries) => {
                if (entries[0].isIntersecting && !isLoading) {
                    setIsLoading(true);
                    try {
                        await onLoadMore();
                    } finally {
                        setIsLoading(false);
                    }
                }
            },
            { threshold }
        );

        observer.observe(observerTarget.current);

        return () => observer.disconnect();
    }, [onLoadMore, isLoading, threshold]);

    return { observerTarget, isLoading };
}

// 2. Component using infinite scroll
interface Post {
    id: number;
    title: string;
    content: string;
}

const InfinitePostList: React.FC = () => {
    const [posts, setPosts] = React.useState<Post[]>([]);
    const [page, setPage] = React.useState(1);
    const [hasMore, setHasMore] = React.useState(true);

    const loadMore = React.useCallback(async () => {
        if (!hasMore) return;

        try {
            const response = await fetch(`/api/posts?page=${page}`);
            const newPosts = await response.json();

            if (newPosts.length === 0) {
                setHasMore(false);
            } else {
                setPosts(prev => [...prev, ...newPosts]);
                setPage(prev => prev + 1);
            }
        } catch (error) {
            console.error('Failed to load posts:', error);
        }
    }, [page, hasMore]);

    const { observerTarget, isLoading } = useInfiniteScroll({ onLoadMore: loadMore });

    return (
        <div>
            <div className="posts">
                {posts.map(post => (
                    <article key={post.id}>
                        <h2>{post.title}</h2>
                        <p>{post.content}</p>
                    </article>
                ))}
            </div>
            <div ref={observerTarget} className="observer-target">
                {isLoading && <Spinner />}
                {!hasMore && <p>No more posts</p>}
            </div>
        </div>
    );
};
```

---

## Part 5: Advanced Questions

### Question 16: Explain TypeScript generics in React

**Answer:**

```typescript
// 1. Generic component for reusability
interface ListProps<T> {
    items: T[];
    renderItem: (item: T) => React.ReactNode;
    keyExtractor: (item: T) => string | number;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
    return (
        <ul>
            {items.map(item => (
                <li key={keyExtractor(item)}>{renderItem(item)}</li>
            ))}
        </ul>
    );
}

// 2. Usage with different types
interface User {
    id: number;
    name: string;
}

<List<User>
    items={users}
    renderItem={(user) => user.name}
    keyExtractor={(user) => user.id}
/>

// 3. Generic fetch hook
interface FetchState<T> {
    data: T | null;
    loading: boolean;
    error: Error | null;
}

function useFetch<T>(url: string): FetchState<T> {
    const [state, setState] = React.useState<FetchState<T>>({
        data: null,
        loading: true,
        error: null,
    });

    React.useEffect(() => {
        fetch(url)
            .then(r => r.json() as Promise<T>)
            .then(data => setState({ data, loading: false, error: null }))
            .catch(error => setState({ data: null, loading: false, error }));
    }, [url]);

    return state;
}

// 4. Type-safe form reducer with generics
type FormAction<T> =
    | { type: 'SET_FIELD'; field: keyof T; value: T[keyof T] }
    | { type: 'RESET' };

function useFormReducer<T extends Record<string, any>>(initialValues: T) {
    const [state, dispatch] = React.useReducer(
        (state: T, action: FormAction<T>): T => {
            switch (action.type) {
                case 'SET_FIELD':
                    return { ...state, [action.field]: action.value };
                case 'RESET':
                    return initialValues;
                default:
                    return state;
            }
        },
        initialValues
    );

    return { state, dispatch };
}
```

---

### Question 17: How would you implement a state management solution?

**Answer:**

```typescript
// Simple state management library (like Zustand)
type StateUpdater<T> = (state: T) => T | Partial<T>;

interface Store<T> {
    getState: () => T;
    setState: (update: StateUpdater<T>) => void;
    subscribe: (listener: (state: T) => void) => () => void;
}

function createStore<T extends Record<string, any>>(initialState: T): Store<T> {
    let state = initialState;
    const listeners = new Set<(state: T) => void>();

    return {
        getState: () => state,
        setState: (update) => {
            const newState = typeof update === 'function' ? update(state) : update;
            state = { ...state, ...newState };
            listeners.forEach(listener => listener(state));
        },
        subscribe: (listener) => {
            listeners.add(listener);
            return () => listeners.delete(listener);
        },
    };
}

// React hook for store
function useStore<T extends Record<string, any>>(store: Store<T>): T {
    const [state, setState] = React.useState(store.getState());

    React.useEffect(() => {
        return store.subscribe(setState);
    }, [store]);

    return state;
}

// Usage
interface AppState {
    count: number;
    user: { name: string } | null;
}

const appStore = createStore<AppState>({
    count: 0,
    user: null,
});

const App: React.FC = () => {
    const state = useStore(appStore);

    return (
        <div>
            <p>{state.count}</p>
            <button onClick={() => appStore.setState(s => ({ count: s.count + 1 }))}>
                Increment
            </button>
        </div>
    );
};
```

---

## Interview Preparation Checklist

### Before the Interview
- [ ] Review your past projects and accomplishments
- [ ] Prepare examples using STAR method (Situation, Task, Action, Result)
- [ ] Practice explaining technical concepts simply
- [ ] Prepare questions to ask the interviewer
- [ ] Research the company and their tech stack
- [ ] Set up coding environment for live coding
- [ ] Review common algorithms and data structures (if required)

### Technical Topics to Review
- [ ] React hooks and their uses
- [ ] State management patterns
- [ ] TypeScript basics and generics
- [ ] Performance optimization
- [ ] Testing React applications
- [ ] Error handling
- [ ] Component composition
- [ ] Async operations
- [ ] Form handling

### Questions to Ask Interviewer
1. "What does a typical day look like for this role?"
2. "What's the team structure and size?"
3. "What technical challenges is the team facing?"
4. "How do you approach code reviews?"
5. "What's the testing strategy?"
6. "What's the deployment process like?"
7. "How do you handle technical debt?"
8. "What opportunities are there for growth?"

### Live Coding Tips
- Think out loud - explain your approach
- Ask clarifying questions
- Start with a simple solution, then optimize
- Write clean, readable code
- Test edge cases
- Discuss trade-offs
- Don't rush - it's better to be thorough

### Common Mistakes to Avoid
- [ ] Don't oversell your skills
- [ ] Don't badmouth previous employers
- [ ] Don't interrupt the interviewer
- [ ] Don't give vague answers
- [ ] Don't forget to follow up after interview
- [ ] Don't memorize answers - be genuine
- [ ] Don't ask about salary too early

---

**Last Updated:** October 26, 2024
**Level:** All Levels (Beginner to Senior)
**Topics Covered:** 17 questions across behavioral, technical, and architectural topics
**Estimated Preparation Time:** 8-12 hours
