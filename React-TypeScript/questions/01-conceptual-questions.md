# React with TypeScript - Conceptual Questions

## Question 1: Component Composition

**Question:** Explain the difference between using composition and inheritance in React components. When would you prefer one over the other?

**Answer:**

React heavily favors composition over inheritance. Here's why:

**Composition:**
- Components are composed together by passing other components as props
- More flexible and reusable
- Easier to test and maintain
- Props drilling can be mitigated with Context API

**Inheritance:**
- Extends a base component class
- Creates tight coupling between parent and child
- Difficult to test
- Breaks the single responsibility principle

**Example of Composition (Preferred):**
```typescript
interface LayoutProps {
    header: React.ReactNode;
    sidebar: React.ReactNode;
    main: React.ReactNode;
    footer: React.ReactNode;
}

const DashboardLayout: React.FC<LayoutProps> = ({ header, sidebar, main, footer }) => (
    <div className="dashboard">
        <header>{header}</header>
        <aside>{sidebar}</aside>
        <main>{main}</main>
        <footer>{footer}</footer>
    </div>
);

// Usage
<DashboardLayout
    header={<Header />}
    sidebar={<Sidebar />}
    main={<MainContent />}
    footer={<Footer />}
/>
```

**When to use Composition:**
- Building flexible, reusable component libraries
- Creating wrapper components (Layout, Modal, Dropdown)
- Combining multiple concerns into a single view

**When to use Inheritance (rare):**
- Some base behavior must be inherited
- Not recommended for modern React; composition typically handles these cases

**Difficulty:** Intermediate
**Tags:** #components #composition #architecture

---

## Question 2: React Hooks and Functional Components

**Question:** Why did React introduce hooks, and what are the main problems they solve compared to class components?

**Answer:**

**Problems with Class Components:**
1. **Complex State Logic** - Stateful logic is hard to reuse and share between components
2. **Wrapper Hell** - HOCs and render props create deeply nested component trees
3. **Large Components** - Lifecycle methods encourage mixing unrelated logic
4. **"this" Binding** - Confusing context binding and method binding requirements
5. **Difficult Testing** - Complex setup required for lifecycle methods

**How Hooks Solve These Problems:**

```typescript
// Before: Class component with lifecycle scattered
class UserProfile extends React.Component {
    componentDidMount() {
        this.fetchUser();
        this.subscribeToUpdates();
    }

    componentDidUpdate(prevProps) {
        if (prevProps.userId !== this.props.userId) {
            this.fetchUser();
        }
    }

    componentWillUnmount() {
        this.unsubscribeFromUpdates();
    }

    // More methods...
}

// After: Hooks isolate related logic
const UserProfile: React.FC<{ userId: string }> = ({ userId }) => {
    // All user fetching logic in one place
    React.useEffect(() => {
        const subscription = subscribeToUpdates(userId);
        return () => subscription.unsubscribe();
    }, [userId]);

    // All state logic together
    const { user, loading, error } = useUser(userId);

    // Cleaner, more testable
};
```

**Main Benefits:**
1. **Logic Reusability** - Extract logic into custom hooks
2. **Simpler Code** - Less boilerplate, clearer intent
3. **Better Testing** - Hooks are just functions
4. **Smaller Bundle** - Function components are smaller
5. **Gradual Adoption** - Can mix hooks and class components

**Difficulty:** Intermediate
**Tags:** #hooks #functional-components #state-management

---

## Question 3: TypeScript Generics in React

**Question:** What are TypeScript generics and how do you use them to make reusable React components? Provide an example.

**Answer:**

**Generics** allow you to write components and functions that work with any type while maintaining type safety.

```typescript
// Generic Component - Works with any data type
interface ListProps<T> {
    items: T[];
    renderItem: (item: T) => React.ReactNode;
    keyExtractor: (item: T) => string | number;
    onItemSelect?: (item: T) => void;
}

const List = <T,>({
    items,
    renderItem,
    keyExtractor,
    onItemSelect,
}: ListProps<T>): React.ReactElement => (
    <ul>
        {items.map((item) => (
            <li
                key={keyExtractor(item)}
                onClick={() => onItemSelect?.(item)}
            >
                {renderItem(item)}
            </li>
        ))}
    </ul>
);

// Usage 1: List of users
interface User {
    id: number;
    name: string;
}

const users: User[] = [
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' },
];

<List<User>
    items={users}
    renderItem={(user) => user.name}
    keyExtractor={(user) => user.id}
    onItemSelect={(user) => console.log(user.name)}
/>

// Usage 2: List of products
interface Product {
    sku: string;
    title: string;
    price: number;
}

const products: Product[] = [
    { sku: 'SKU001', title: 'Laptop', price: 999 },
];

<List<Product>
    items={products}
    renderItem={(product) => `${product.title} - $${product.price}`}
    keyExtractor={(product) => product.sku}
/>

// Generic Hook
interface UseFetchState<T> {
    data: T | null;
    loading: boolean;
    error: Error | null;
}

function useFetch<T>(url: string): UseFetchState<T> {
    const [state, setState] = React.useState<UseFetchState<T>>({
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

// Type inference works automatically
const { data: userData } = useFetch<User>('/api/users');
// userData is typed as User | null
```

**Key Points:**
- Generics enable reusability without sacrificing type safety
- Type parameters are specified with `<T, U, V>`
- React TypeScript automatically infers generic types in most cases
- Constraints can limit what types are acceptable: `<T extends string>`

**Difficulty:** Advanced
**Tags:** #typescript #generics #type-safety #reusability

---

## Question 4: Controlled vs. Uncontrolled Components

**Question:** What's the difference between controlled and uncontrolled components in React? When should you use each?

**Answer:**

**Controlled Components** - React state is the "single source of truth" for the form element's value.

```typescript
const ControlledInput: React.FC = () => {
    const [value, setValue] = React.useState('');

    return (
        <input
            value={value}
            onChange={(e) => setValue(e.target.value)}
            placeholder="Type something..."
        />
    );
};
```

**Uncontrolled Components** - The DOM itself is the "source of truth" using refs.

```typescript
const UncontrolledInput: React.FC = () => {
    const inputRef = React.useRef<HTMLInputElement>(null);

    const handleSubmit = () => {
        console.log(inputRef.current?.value);
    };

    return (
        <>
            <input ref={inputRef} placeholder="Type something..." />
            <button onClick={handleSubmit}>Submit</button>
        </>
    );
};
```

**Comparison Table:**

| Aspect | Controlled | Uncontrolled |
|--------|-----------|--------------|
| **Source of Truth** | React state | DOM |
| **State Management** | Yes, via setState | No, accessed via refs |
| **Re-render Trigger** | State change | Manual |
| **Validation** | Real-time possible | On submit |
| **Reset Value** | Set state to initial | Use ref |
| **Complexity** | Higher | Lower |
| **Performance** | More renders | Fewer renders |

**When to use Controlled:**
- Need real-time validation
- Conditional field enabling/disabling
- Dynamic field values
- Form integration with state management

**When to use Uncontrolled:**
- Simple forms without complex logic
- File inputs (always uncontrolled)
- Integration with non-React code
- Performance-critical scenarios

**Hybrid Approach (Recommended):**
```typescript
interface FormData {
    email: string;
    message: string;
}

const HybridForm: React.FC = () => {
    const [email, setEmail] = React.useState('');
    const fileRef = React.useRef<HTMLInputElement>(null);

    const handleSubmit = () => {
        const file = fileRef.current?.files?.[0];
        // Use both controlled and uncontrolled values
    };

    return (
        <form>
            <input
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Email"
            />
            <input ref={fileRef} type="file" />
        </form>
    );
};
```

**Difficulty:** Intermediate
**Tags:** #forms #controlled-components #state-management

---

## Question 5: Context API vs Props Drilling

**Question:** What is props drilling and how does Context API solve it? What are the trade-offs?

**Answer:**

**Props Drilling Problem:**

Passing props through multiple levels of components that don't use them, just to pass them to nested children.

```typescript
// Without Context - Props drilling nightmare
const App: React.FC = () => {
    const [theme, setTheme] = React.useState<'light' | 'dark'>('light');

    return <Level1 theme={theme} setTheme={setTheme} />;
};

const Level1: React.FC<{ theme: string; setTheme: (t: string) => void }> = ({ theme, setTheme }) => (
    <Level2 theme={theme} setTheme={setTheme} />
);

const Level2: React.FC<{ theme: string; setTheme: (t: string) => void }> = ({ theme, setTheme }) => (
    <Level3 theme={theme} setTheme={setTheme} />
);

const Level3: React.FC<{ theme: string; setTheme: (t: string) => void }> = ({ theme, setTheme }) => (
    <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
        Current: {theme}
    </button>
);
```

**With Context API - Clean Solution:**

```typescript
interface ThemeContextType {
    theme: 'light' | 'dark';
    setTheme: (theme: 'light' | 'dark') => void;
}

const ThemeContext = React.createContext<ThemeContextType | undefined>(undefined);

const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [theme, setTheme] = React.useState<'light' | 'dark'>('light');

    return (
        <ThemeContext.Provider value={{ theme, setTheme }}>
            {children}
        </ThemeContext.Provider>
    );
};

const useTheme = () => {
    const context = React.useContext(ThemeContext);
    if (!context) throw new Error('useTheme must be used within ThemeProvider');
    return context;
};

// Components are now clean
const Level3: React.FC = () => {
    const { theme, setTheme } = useTheme();
    return (
        <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
            Current: {theme}
        </button>
    );
};

const App: React.FC = () => (
    <ThemeProvider>
        <Level1 />
    </ThemeProvider>
);
```

**Trade-offs:**

| Aspect | Props Drilling | Context API |
|--------|---------------|-------------|
| **Verbosity** | Verbose | Clean |
| **Performance** | Better (memoization) | Can cause unnecessary re-renders |
| **Debugging** | Clear data flow | Harder to trace |
| **Learning Curve** | Easier | Requires understanding Context |
| **Scalability** | Painful with many props | Good for global state |

**Performance Considerations:**

```typescript
// Context changes cause all consumers to re-render
// Solution: Split contexts by concern

const ThemeContext = React.createContext<'light' | 'dark'>('light');
const SetThemeContext = React.createContext<(t: 'light' | 'dark') => void>(() => {});

// Or use memo to prevent unnecessary renders
const MemoizedComponent = React.memo(MyComponent);
```

**When to Use Each:**
- **Props:** Simple passing of props, clear component relationships
- **Context:** Global state, theme, language, authentication

**Difficulty:** Intermediate
**Tags:** #context-api #state-management #props

---

## Question 6: React Performance Optimization

**Question:** Explain the purpose of React.memo, useMemo, and useCallback. When should you use each one?

**Answer:**

**1. React.memo - Prevent Re-renders of Child Components**

Memoizes a component so it only re-renders if its props change.

```typescript
interface ItemProps {
    id: number;
    title: string;
    onDelete: (id: number) => void;
}

// Without memo: re-renders every time parent renders
const Item: React.FC<ItemProps> = ({ id, title, onDelete }) => {
    console.log(`Item ${id} rendered`);
    return (
        <div>
            <span>{title}</span>
            <button onClick={() => onDelete(id)}>Delete</button>
        </div>
    );
};

// With memo: only re-renders if props change
const MemoizedItem = React.memo(Item);

// Custom comparison function for complex props
const SmartItem = React.memo(
    Item,
    (prevProps, nextProps) => {
        // Return true if props are equal (skip re-render)
        return prevProps.id === nextProps.id && prevProps.title === nextProps.title;
    }
);
```

**2. useMemo - Memoize Expensive Calculations**

Caches computation results and only recalculates when dependencies change.

```typescript
interface DataListProps {
    items: { id: number; value: number }[];
}

const DataList: React.FC<DataListProps> = ({ items }) => {
    const [filter, setFilter] = React.useState('');

    // Expensive calculation is cached
    const filteredItems = React.useMemo(() => {
        console.log('Filtering...');
        return items.filter(item => String(item.id).includes(filter));
    }, [items, filter]);

    // Also cache derived values
    const total = React.useMemo(() => {
        console.log('Calculating total...');
        return filteredItems.reduce((sum, item) => sum + item.value, 0);
    }, [filteredItems]);

    return (
        <div>
            <input value={filter} onChange={e => setFilter(e.target.value)} />
            <p>Total: {total}</p>
            <ul>
                {filteredItems.map(item => (
                    <li key={item.id}>{item.id}: {item.value}</li>
                ))}
            </ul>
        </div>
    );
};
```

**3. useCallback - Memoize Function References**

Prevents child components from re-rendering due to new function references.

```typescript
interface ListProps {
    items: { id: number; title: string }[];
}

const List: React.FC<ListProps> = ({ items }) => {
    const [selectedId, setSelectedId] = React.useState<number | null>(null);

    // Without useCallback: new function every render
    // const handleSelect = (id: number) => setSelectedId(id);

    // With useCallback: same function reference unless dependencies change
    const handleSelect = React.useCallback((id: number) => {
        setSelectedId(id);
    }, []);

    return (
        <ul>
            {items.map(item => (
                <MemoizedItem
                    key={item.id}
                    item={item}
                    isSelected={selectedId === item.id}
                    onSelect={handleSelect}
                />
            ))}
        </ul>
    );
};

const MemoizedItem = React.memo(({ item, isSelected, onSelect }: any) => (
    <li onClick={() => onSelect(item.id)} className={isSelected ? 'selected' : ''}>
        {item.title}
    </li>
));
```

**Comparison Table:**

| Hook | Purpose | Use When |
|------|---------|----------|
| **React.memo** | Prevent re-renders | Props often don't change |
| **useMemo** | Cache calculations | Calculation is expensive |
| **useCallback** | Cache functions | Function prop affects children |

**Performance Rules:**

```typescript
// ❌ Don't optimize prematurely - measure first!
// ✅ Use React DevTools Profiler to identify bottlenecks

// ❌ Don't over-memoize - adds complexity and overhead
// ✅ Only memoize when measurement shows it helps

// ❌ Don't create new dependency arrays constantly
// ✅ Keep dependency arrays stable
```

**Difficulty:** Advanced
**Tags:** #performance #optimization #react-memo #usememo #usecallback

---

## Question 7: Custom Hooks

**Question:** What is a custom hook and how do you create one? Provide a practical example.

**Answer:**

**Custom Hooks** are JavaScript functions that use React hooks and encapsulate stateful logic for reuse.

**Rules for Custom Hooks:**
1. Must start with "use"
2. Must call other hooks
3. Must be called at top level

**Practical Example: useLocalStorage Hook**

```typescript
function useLocalStorage<T>(key: string, initialValue: T) {
    // State to store our value
    const [storedValue, setStoredValue] = React.useState<T>(() => {
        try {
            // Get from local storage
            const item = window.localStorage.getItem(key);
            return item ? JSON.parse(item) : initialValue;
        } catch (error) {
            console.error(error);
            return initialValue;
        }
    });

    // Return a wrapped version of useState's setter function that
    // persists the new value to localStorage
    const setValue = (value: T | ((val: T) => T)) => {
        try {
            // Allow value to be a function for same API as useState
            const valueToStore = value instanceof Function ? value(storedValue) : value;
            // Save state
            setStoredValue(valueToStore);
            // Save to local storage
            window.localStorage.setItem(key, JSON.stringify(valueToStore));
        } catch (error) {
            console.error(error);
        }
    };

    return [storedValue, setValue] as const;
}

// Usage
const MyComponent: React.FC = () => {
    const [theme, setTheme] = useLocalStorage<'light' | 'dark'>('theme', 'light');

    return (
        <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
            Current theme: {theme}
        </button>
    );
};
```

**Another Example: useAsync Hook**

```typescript
interface UseAsyncState<T> {
    status: 'idle' | 'pending' | 'success' | 'error';
    data: T | null;
    error: Error | null;
}

function useAsync<T>(
    asyncFunction: () => Promise<T>,
    immediate: boolean = true
): UseAsyncState<T> & { execute: () => Promise<void> } {
    const [state, setState] = React.useState<UseAsyncState<T>>({
        status: 'idle',
        data: null,
        error: null,
    });

    const execute = React.useCallback(async () => {
        setState({ status: 'pending', data: null, error: null });
        try {
            const response = await asyncFunction();
            setState({ status: 'success', data: response, error: null });
        } catch (error) {
            setState({
                status: 'error',
                data: null,
                error: error instanceof Error ? error : new Error(String(error)),
            });
        }
    }, [asyncFunction]);

    React.useEffect(() => {
        if (immediate) {
            execute();
        }
    }, [execute, immediate]);

    return { ...state, execute };
}

// Usage
const UserProfile: React.FC<{ userId: string }> = ({ userId }) => {
    const { status, data: user, error, execute } = useAsync(
        () => fetch(`/api/users/${userId}`).then(r => r.json()),
        true
    );

    if (status === 'pending') return <div>Loading...</div>;
    if (status === 'error') return <div>Error: {error?.message}</div>;
    if (status === 'success') return <div>{user?.name}</div>;
    return null;
};
```

**Benefits of Custom Hooks:**
- **Reusability** - Share logic across components
- **Cleaner Components** - Extract complex logic
- **Testability** - Easier to test than class components
- **Composability** - Hooks can use other hooks

**Difficulty:** Intermediate
**Tags:** #custom-hooks #reusability #state-management

---

## Question 8: Error Boundaries

**Question:** What are Error Boundaries and why are they important? Show an example.

**Answer:**

**Error Boundaries** are React components that catch errors in child components, log those errors, and display a fallback UI instead of crashing the entire app.

**Key Points:**
- Only work in class components (as of React 18)
- Catch errors during rendering, in lifecycle methods, and in constructors
- Do NOT catch errors in event handlers, async code, or server-side rendering

```typescript
interface ErrorBoundaryState {
    hasError: boolean;
    error: Error | null;
}

class ErrorBoundary extends React.Component<
    { children: React.ReactNode },
    ErrorBoundaryState
> {
    constructor(props: { children: React.ReactNode }) {
        super(props);
        this.state = { hasError: false, error: null };
    }

    static getDerivedStateFromError(error: Error): ErrorBoundaryState {
        return { hasError: true, error };
    }

    componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
        // Log to error reporting service
        console.error('Error caught:', error, errorInfo);
    }

    render() {
        if (this.state.hasError) {
            return (
                <div className="error-boundary">
                    <h1>Something went wrong</h1>
                    <p>{this.state.error?.message}</p>
                    <button onClick={() => this.setState({ hasError: false, error: null })}>
                        Try again
                    </button>
                </div>
            );
        }

        return this.props.children;
    }
}

// Usage
const App: React.FC = () => (
    <ErrorBoundary>
        <Dashboard />
    </ErrorBoundary>
);
```

**Why They Matter:**
- Prevent complete app crashes from component errors
- Provide graceful fallback UI
- Help identify problematic components
- Enable error logging and monitoring

**Difficulty:** Intermediate
**Tags:** #error-handling #error-boundaries #robustness

---

## Question 9: Key Prop in Lists

**Question:** Why is the "key" prop important when rendering lists in React? What happens if you don't use it correctly?

**Answer:**

**The key prop helps React identify which items have changed**, allowing React to maintain component state and DOM elements correctly.

**Problems Without Keys:**

```typescript
// ❌ BAD: Using array index as key
const TodoList: React.FC<{ todos: Todo[] }> = ({ todos }) => (
    <ul>
        {todos.map((todo, index) => (
            <li key={index}>{todo.text}</li>
        ))}
    </ul>
);

// Problems:
// 1. If list is reordered, keys don't match items
// 2. If items are added/removed, keys shift
// 3. Component state gets misaligned
// 4. Performance issues with filtered/sorted lists
```

**Problems Illustrated:**

```typescript
const TodoApp: React.FC = () => {
    const [todos, setTodos] = React.useState([
        { id: 1, text: 'Learn React', completed: false },
        { id: 2, text: 'Learn TypeScript', completed: false },
    ]);

    const reorder = () => {
        // Reverse the list
        setTodos([...todos].reverse());
    };

    return (
        <div>
            {todos.map((todo, index) => (
                // ❌ With index key, component state gets confused
                // When reversed, the checkbox states don't follow the correct todo
                <TodoItem key={index} todo={todo} />
            ))}
            <button onClick={reorder}>Reorder</button>
        </div>
    );
};

interface TodoItemProps {
    todo: Todo;
}

const TodoItem: React.FC<TodoItemProps> = ({ todo }) => {
    const [completed, setCompleted] = React.useState(false);

    return (
        <li>
            <input
                type="checkbox"
                checked={completed}
                onChange={(e) => setCompleted(e.target.checked)}
            />
            {todo.text}
        </li>
    );
};
```

**Correct Solution - Use Unique Identifiers:**

```typescript
// ✅ GOOD: Use unique, stable identifiers
const TodoList: React.FC<{ todos: Todo[] }> = ({ todos }) => (
    <ul>
        {todos.map((todo) => (
            <li key={todo.id}>{todo.text}</li>
        ))}
    </ul>
);

// Now:
// 1. Items maintain their identity through reorders
// 2. Component state stays with correct item
// 3. DOM elements reuse correctly
// 4. Performance optimizations work properly
```

**Best Practices:**

```typescript
// ✅ Use unique, stable identifiers from data
<Item key={item.id} item={item} />

// ✅ Use combination for uniqueness
<Item key={`${item.id}-${item.version}`} item={item} />

// ❌ Don't use array index as key
<Item key={index} item={item} />

// ❌ Don't generate keys on render
<Item key={Math.random()} item={item} />

// ❌ Don't use unstable identifiers
<Item key={item.name} item={item} /> {/* If name can change */}
```

**Difficulty:** Beginner
**Tags:** #lists #keys #rendering #performance

---

## Question 10: React 18 Concurrent Features

**Question:** What are React 18's concurrent features and how do they improve user experience?

**Answer:**

**Concurrent rendering** allows React to interrupt long renders to handle higher-priority updates (like user input) immediately.

**Key Concurrent Features:**

1. **Startups Transitions**
   - Mark updates that don't need urgent feedback
   - Allow React to deprioritize them

2. **useDeferredValue**
   - Defer a value update
   - Keep urgent updates responsive

3. **useTransition**
   - Track pending state of non-urgent updates

**Example: useTransition for Search**

```typescript
const SearchUsers: React.FC = () => {
    const [input, setInput] = React.useState('');
    const [results, setResults] = React.useState<User[]>([]);
    const [isPending, startTransition] = React.useTransition();

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const value = e.target.value;
        setInput(value); // Urgent: update input immediately

        // Non-urgent: filter results
        startTransition(() => {
            const filtered = users.filter(u =>
                u.name.toLowerCase().includes(value.toLowerCase())
            );
            setResults(filtered);
        });
    };

    return (
        <div>
            <input
                value={input}
                onChange={handleInputChange}
                placeholder="Search users..."
            />
            {isPending && <span>Loading...</span>}
            <ul>
                {results.map(user => (
                    <li key={user.id}>{user.name}</li>
                ))}
            </ul>
        </div>
    );
};
```

**Example: useDeferredValue**

```typescript
const UserList: React.FC<{ users: User[] }> = ({ users }) => {
    const [filter, setFilter] = React.useState('');
    const deferredFilter = React.useDeferredValue(filter);

    // useMemo prevents unnecessary filtering
    const filteredUsers = React.useMemo(() => {
        return users.filter(u =>
            u.name.toLowerCase().includes(deferredFilter.toLowerCase())
        );
    }, [users, deferredFilter]);

    return (
        <div>
            <input
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
                placeholder="Filter users..."
            />
            <ul>
                {filteredUsers.map(user => (
                    <li key={user.id}>{user.name}</li>
                ))}
            </ul>
        </div>
    );
};
```

**Benefits:**
- **Better UX** - Input feels responsive even during heavy rendering
- **No Blocking** - Concurrent features prevent UI freezing
- **Auto Batching** - Multiple setState calls in event handlers batch automatically
- **Suspense** - Better support for data fetching boundaries

**Difficulty:** Advanced
**Tags:** #react18 #concurrent #performance #ux

---

## Question 11: Type Safety with React Props

**Question:** How do you ensure complete type safety for React component props using TypeScript? Show different patterns.

**Answer:**

**Pattern 1: Interface for Props**

```typescript
interface ButtonProps {
    label: string;
    onClick: () => void;
    disabled?: boolean;
    variant?: 'primary' | 'secondary' | 'danger';
}

const Button: React.FC<ButtonProps> = ({ label, onClick, disabled, variant = 'primary' }) => (
    <button
        onClick={onClick}
        disabled={disabled}
        className={`btn btn-${variant}`}
    >
        {label}
    </button>
);
```

**Pattern 2: Using React.ComponentProps for HTML Elements**

```typescript
import { ComponentProps } from 'react';

// Get all native button props
type CustomButtonProps = ComponentProps<'button'> & {
    variant?: 'primary' | 'secondary';
};

const CustomButton: React.FC<CustomButtonProps> = ({ variant, ...props }) => (
    <button {...props} className={`btn btn-${variant || 'primary'}`} />
);

// Usage: Accepts all standard button attributes
<CustomButton onClick={handleClick} disabled variant="primary" />
```

**Pattern 3: Union Types for Exclusive Props**

```typescript
// Button can be either a submit or regular button
type ButtonProps =
    | {
        type: 'submit';
        formId: string;
    }
    | {
        type: 'button';
        onClick: () => void;
    };

const ExclusiveButton: React.FC<ButtonProps & { label: string }> = (props) => {
    if (props.type === 'submit') {
        return <button type="submit" form={props.formId}>{props.label}</button>;
    }
    return <button onClick={props.onClick}>{props.label}</button>;
};

// ✅ Valid: submit with formId
<ExclusiveButton type="submit" formId="myForm" label="Submit" />

// ❌ Error: submit type requires formId
<ExclusiveButton type="submit" onClick={() => {}} label="Submit" />
```

**Pattern 4: Strict Prop Validation**

```typescript
interface User {
    id: string;
    name: string;
    email: string;
}

interface StrictUserCardProps {
    readonly user: User;
    readonly onEdit: (user: User) => void;
    readonly onDelete: (id: string) => void;
}

const UserCard: React.FC<StrictUserCardProps> = ({ user, onEdit, onDelete }) => (
    <div>
        <h3>{user.name}</h3>
        <p>{user.email}</p>
        <button onClick={() => onEdit(user)}>Edit</button>
        <button onClick={() => onDelete(user.id)}>Delete</button>
    </div>
);
```

**Pattern 5: Generic Component Props**

```typescript
interface TableProps<T extends Record<string, any>> {
    data: T[];
    columns: {
        key: keyof T;
        header: string;
        render?: (value: T[keyof T]) => React.ReactNode;
    }[];
}

const Table = <T extends Record<string, any>>({
    data,
    columns,
}: TableProps<T>): React.ReactElement => (
    <table>
        <thead>
            <tr>
                {columns.map(col => (
                    <th key={String(col.key)}>{col.header}</th>
                ))}
            </tr>
        </thead>
        <tbody>
            {data.map((row, idx) => (
                <tr key={idx}>
                    {columns.map(col => (
                        <td key={String(col.key)}>
                            {col.render ? col.render(row[col.key]) : row[col.key]}
                        </td>
                    ))}
                </tr>
            ))}
        </tbody>
    </table>
);
```

**Best Practices:**
- Use interfaces over types for object shapes
- Make props readonly for immutability
- Use discriminated unions for exclusive props
- Leverage TypeScript inference
- Avoid `any` type

**Difficulty:** Intermediate
**Tags:** #typescript #props #type-safety

---

## Question 12: State Management Patterns

**Question:** Compare different state management approaches in React. When would you use Context API vs. a library like Redux?

**Answer:**

**Simple State - useState**
- Local component state
- Single value changes
- No sharing needed

**Shared State - Context API**
- Multiple components need same data
- Not frequently changing
- Moderate complexity

**Complex State - Redux/Zustand**
- Highly interconnected state
- Frequent updates
- Complex state logic
- Time-travel debugging needed

**Comparison:**

```typescript
// Pattern 1: useState (Simple)
const Counter: React.FC = () => {
    const [count, setCount] = React.useState(0);
    return (
        <div>
            <p>{count}</p>
            <button onClick={() => setCount(count + 1)}>+</button>
        </div>
    );
};

// Pattern 2: Context API (Moderate)
interface AppContextType {
    user: User | null;
    theme: 'light' | 'dark';
    setTheme: (theme: 'light' | 'dark') => void;
}

const AppContext = React.createContext<AppContextType | undefined>(undefined);

const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [user, setUser] = React.useState<User | null>(null);
    const [theme, setTheme] = React.useState<'light' | 'dark'>('light');

    return (
        <AppContext.Provider value={{ user, theme, setTheme }}>
            {children}
        </AppContext.Provider>
    );
};

// Pattern 3: Redux-like (Complex)
type AppAction =
    | { type: 'SET_USER'; payload: User }
    | { type: 'LOGOUT' }
    | { type: 'SET_THEME'; payload: 'light' | 'dark' };

interface AppState {
    user: User | null;
    theme: 'light' | 'dark';
}

const appReducer = (state: AppState, action: AppAction): AppState => {
    switch (action.type) {
        case 'SET_USER':
            return { ...state, user: action.payload };
        case 'LOGOUT':
            return { ...state, user: null };
        case 'SET_THEME':
            return { ...state, theme: action.payload };
        default:
            return state;
    }
};

const AppContainer: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [state, dispatch] = React.useReducer(appReducer, {
        user: null,
        theme: 'light',
    });

    return (
        <AppContext.Provider
            value={{
                state,
                dispatch,
            }}
        >
            {children}
        </AppContext.Provider>
    );
};
```

**Decision Matrix:**

| Criterion | useState | Context | Redux |
|-----------|----------|---------|-------|
| **Simplicity** | High | Medium | Low |
| **Learning Curve** | Low | Medium | High |
| **Scalability** | Low | Medium | High |
| **DevTools** | No | No | Yes |
| **Boilerplate** | None | Medium | High |
| **Performance** | Good | Okay | Good |

**Difficulty:** Intermediate
**Tags:** #state-management #context-api #redux

---

## Summary

These 12 conceptual questions cover key React and TypeScript topics from fundamentals to advanced patterns. They provide deep understanding of why certain patterns exist and how to apply them effectively in real-world applications.

**Topics Covered:**
- Component design and composition
- Hooks and functional components
- TypeScript type safety
- Form handling (controlled vs. uncontrolled)
- State management solutions
- Performance optimization
- Custom hooks creation
- Error handling
- List rendering best practices
- React 18 concurrent features
- Type-safe props
- State management patterns

**Suggested Study Approach:**
1. Read question and try to answer from memory
2. Review answer and explanations
3. Look at code examples
4. Apply concepts to your own projects
5. Return to review challenging topics

**Last Updated:** October 26, 2024
**Level:** Intermediate to Advanced
**Total Questions:** 12
**Estimated Study Time:** 4-6 hours
