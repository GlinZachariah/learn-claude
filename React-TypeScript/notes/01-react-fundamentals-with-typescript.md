# React Fundamentals with TypeScript

## Part 1: JSX & Components

```typescript
// 1. JSX Basics
const greeting: React.FC<{ name: string }> = ({ name }) => {
    return <h1>Hello, {name}!</h1>;
};

// 2. Functional Components
interface UserProps {
    id: number;
    name: string;
    email: string;
    role?: 'admin' | 'user';
}

const UserCard: React.FC<UserProps> = ({
    id,
    name,
    email,
    role = 'user'
}) => {
    return (
        <div className="user-card">
            <h2>{name}</h2>
            <p>{email}</p>
            <span className={`badge badge-${role}`}>{role}</span>
        </div>
    );
};

// 3. Children Props
interface ContainerProps {
    children: React.ReactNode;
    title: string;
}

const Container: React.FC<ContainerProps> = ({ children, title }) => (
    <div className="container">
        <h1>{title}</h1>
        {children}
    </div>
);

// Usage
<Container title="Users">
    <UserCard id={1} name="John" email="john@example.com" />
</Container>

// 4. Multiple Children Types
interface PageProps {
    header: React.ReactNode;
    sidebar?: React.ReactNode;
    footer: React.ReactNode;
}

const Page: React.FC<PageProps> = ({ header, sidebar, footer }) => (
    <div className="page">
        <header>{header}</header>
        <main>
            {sidebar && <aside>{sidebar}</aside>}
            <content>{/* main content */}</content>
        </main>
        <footer>{footer}</footer>
    </div>
);

// 5. Component as Prop
interface ButtonProps {
    icon?: React.ComponentType<{ size: number }>;
    label: string;
    onClick: () => void;
}

const Button: React.FC<ButtonProps> = ({ icon: Icon, label, onClick }) => (
    <button onClick={onClick}>
        {Icon && <Icon size={20} />}
        {label}
    </button>
);

// Usage
<Button
    icon={DeleteIcon}
    label="Delete"
    onClick={() => console.log('deleted')}
/>
```

## Part 2: Props & Type Safety

```typescript
// 1. Strict Props Typing
interface ProductProps {
    id: string;
    name: string;
    price: number;
    inStock: boolean;
    categories: string[];
    metadata?: Record<string, any>;
    onSelect?: (id: string) => void;
    onRemove?: (id: string) => Promise<void>;
}

const Product: React.FC<ProductProps> = ({
    id,
    name,
    price,
    inStock,
    categories,
    metadata,
    onSelect,
    onRemove
}) => {
    const handleRemove = async () => {
        if (onRemove) {
            await onRemove(id);
        }
    };

    return (
        <div className={`product ${!inStock ? 'disabled' : ''}`}>
            <h3>{name}</h3>
            <p>${price.toFixed(2)}</p>
            <ul>
                {categories.map(cat => (
                    <li key={cat}>{cat}</li>
                ))}
            </ul>
            {onSelect && <button onClick={() => onSelect(id)}>Select</button>}
            {onRemove && <button onClick={handleRemove}>Remove</button>}
        </div>
    );
};

// 2. Readonly Props
interface ConfigProps {
    readonly apiUrl: string;
    readonly timeout: number;
    readonly retries: number;
}

const Config: React.FC<ConfigProps> = (props) => {
    // props.apiUrl = 'new'; // Error!
    return <div>{JSON.stringify(props)}</div>;
};

// 3. Union Types for Props
interface AlertProps {
    type: 'success' | 'error' | 'warning' | 'info';
    message: string;
}

const Alert: React.FC<AlertProps> = ({ type, message }) => {
    const colors = {
        success: '#27ae60',
        error: '#e74c3c',
        warning: '#f39c12',
        info: '#3498db',
    };

    return (
        <div style={{ color: colors[type] }}>
            {message}
        </div>
    );
};

// 4. Discriminated Union Props
type FormProps =
    | { mode: 'create'; initialValues?: never }
    | { mode: 'edit'; initialValues: Record<string, any> };

const Form: React.FC<FormProps> = (props) => {
    if (props.mode === 'create') {
        return <form>{/* create form */}</form>;
    }

    return (
        <form>
            {/* edit form with props.initialValues */}
        </form>
    );
};

// 5. Optional vs Required
interface ButtonProps {
    label: string;                    // Required
    onClick?: () => void;             // Optional callback
    disabled?: boolean;               // Optional boolean
    className?: string;               // Optional string
}

const Button: React.FC<ButtonProps> = ({
    label,
    onClick,
    disabled = false,
    className = ''
}) => (
    <button
        onClick={onClick}
        disabled={disabled}
        className={className}
    >
        {label}
    </button>
);
```

## Part 3: State Management with Hooks

```typescript
// 1. useState with Types
interface User {
    id: number;
    name: string;
    email: string;
}

const UserProfile: React.FC<{ userId: number }> = ({ userId }) => {
    const [user, setUser] = React.useState<User | null>(null);
    const [loading, setLoading] = React.useState(true);
    const [error, setError] = React.useState<string | null>(null);

    React.useEffect(() => {
        (async () => {
            try {
                setLoading(true);
                const response = await fetch(`/api/users/${userId}`);
                const data = await response.json();
                setUser(data);
                setError(null);
            } catch (err) {
                setError(err instanceof Error ? err.message : 'Unknown error');
                setUser(null);
            } finally {
                setLoading(false);
            }
        })();
    }, [userId]);

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error}</div>;
    if (!user) return <div>No user found</div>;

    return (
        <div>
            <h2>{user.name}</h2>
            <p>{user.email}</p>
        </div>
    );
};

// 2. useState with Functions
const Counter: React.FC = () => {
    const [count, setCount] = React.useState(() => {
        const saved = localStorage.getItem('count');
        return saved ? parseInt(saved) : 0;
    });

    const increment = () => setCount(prev => prev + 1);
    const decrement = () => setCount(prev => Math.max(0, prev - 1));

    React.useEffect(() => {
        localStorage.setItem('count', String(count));
    }, [count]);

    return (
        <div>
            <p>Count: {count}</p>
            <button onClick={increment}>+</button>
            <button onClick={decrement}>-</button>
        </div>
    );
};

// 3. useRef with Types
interface TextInputHandle {
    focus: () => void;
    clear: () => void;
}

const TextInput = React.forwardRef<TextInputHandle, { placeholder: string }>(
    ({ placeholder }, ref) => {
        const inputRef = React.useRef<HTMLInputElement>(null);

        React.useImperativeHandle(ref, () => ({
            focus: () => inputRef.current?.focus(),
            clear: () => {
                if (inputRef.current) {
                    inputRef.current.value = '';
                }
            },
        }));

        return <input ref={inputRef} placeholder={placeholder} />;
    }
);

// Usage
const Form: React.FC = () => {
    const inputRef = React.useRef<TextInputHandle>(null);

    return (
        <div>
            <TextInput ref={inputRef} placeholder="Type here" />
            <button onClick={() => inputRef.current?.focus()}>Focus</button>
            <button onClick={() => inputRef.current?.clear()}>Clear</button>
        </div>
    );
};

// 4. useCallback for Memoization
interface ListProps {
    items: string[];
    onItemClick: (item: string) => void;
}

const List: React.FC<ListProps> = React.memo(({ items, onItemClick }) => {
    return (
        <ul>
            {items.map(item => (
                <li key={item} onClick={() => onItemClick(item)}>
                    {item}
                </li>
            ))}
        </ul>
    );
});

const ListContainer: React.FC = () => {
    const [items, setItems] = React.useState(['A', 'B', 'C']);

    const handleItemClick = React.useCallback((item: string) => {
        console.log(`Clicked: ${item}`);
    }, []);

    return <List items={items} onItemClick={handleItemClick} />;
};

// 5. useMemo for Expensive Calculations
interface DataTableProps {
    data: Array<{ id: number; value: number }>;
    filter: string;
}

const DataTable: React.FC<DataTableProps> = ({ data, filter }) => {
    const filteredData = React.useMemo(() => {
        console.log('Filtering data...');
        return data.filter(item =>
            item.id.toString().includes(filter)
        );
    }, [data, filter]);

    const sum = React.useMemo(() => {
        return filteredData.reduce((acc, item) => acc + item.value, 0);
    }, [filteredData]);

    return (
        <div>
            <table>
                <tbody>
                    {filteredData.map(item => (
                        <tr key={item.id}>
                            <td>{item.id}</td>
                            <td>{item.value}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
            <p>Total: {sum}</p>
        </div>
    );
};
```

## Part 4: Event Handling

```typescript
// 1. Event Types
const Form: React.FC = () => {
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        console.log(e.currentTarget.value);
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        // Handle submission
    };

    const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
        console.log('Button clicked');
    };

    const handleFocus = (e: React.FocusEvent<HTMLInputElement>) => {
        e.currentTarget.style.borderColor = 'blue';
    };

    const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
        if (e.key === 'Enter') {
            console.log('Enter pressed');
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <input
                onChange={handleChange}
                onFocus={handleFocus}
                onKeyDown={handleKeyDown}
            />
            <button onClick={handleClick}>Submit</button>
        </form>
    );
};

// 2. Generic Event Handlers
interface InputProps {
    value: string;
    onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
    onBlur?: (e: React.FocusEvent<HTMLInputElement>) => void;
}

const Input: React.FC<InputProps> = ({ value, onChange, onBlur }) => (
    <input value={value} onChange={onChange} onBlur={onBlur} />
);

// 3. Event Handler Wrapper
const Button: React.FC<{ onClick: (e: React.MouseEvent) => void }> = ({
    onClick
}) => {
    const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
        console.log('Button clicked');
        onClick(e);
    };

    return <button onClick={handleClick}>Click</button>;
};

// 4. Preventing Default
const Link: React.FC<{ href: string }> = ({ href }) => {
    const handleClick = (e: React.MouseEvent<HTMLAnchorElement>) => {
        e.preventDefault();
        window.location.href = href;
    };

    return <a href={href} onClick={handleClick}>Link</a>;
};

// 5. Event Delegation
const List: React.FC<{ items: string[] }> = ({ items }) => {
    const handleClick = (e: React.MouseEvent<HTMLUListElement>) => {
        const target = e.target as HTMLElement;
        if (target.tagName === 'LI') {
            console.log(`Clicked: ${target.textContent}`);
        }
    };

    return (
        <ul onClick={handleClick}>
            {items.map((item, i) => (
                <li key={i}>{item}</li>
            ))}
        </ul>
    );
};
```

## Part 5: Forms & Validation

```typescript
// 1. Controlled Form
interface FormData {
    email: string;
    password: string;
    rememberMe: boolean;
}

const LoginForm: React.FC<{ onSubmit: (data: FormData) => void }> = ({
    onSubmit
}) => {
    const [formData, setFormData] = React.useState<FormData>({
        email: '',
        password: '',
        rememberMe: false,
    });

    const [errors, setErrors] = React.useState<Partial<FormData>>({});

    const validate = (): boolean => {
        const newErrors: Partial<FormData> = {};

        if (!formData.email.includes('@')) {
            newErrors.email = 'Invalid email';
        }
        if (formData.password.length < 8) {
            newErrors.password = 'Password too short';
        }

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value, type, checked } = e.currentTarget;
        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value,
        }));
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        if (validate()) {
            onSubmit(formData);
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
            />
            {errors.email && <span className="error">{errors.email}</span>}

            <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
            />
            {errors.password && <span className="error">{errors.password}</span>}

            <label>
                <input
                    type="checkbox"
                    name="rememberMe"
                    checked={formData.rememberMe}
                    onChange={handleChange}
                />
                Remember me
            </label>

            <button type="submit">Login</button>
        </form>
    );
};

// 2. Uncontrolled Form with useRef
const UncontrolledForm: React.FC = () => {
    const nameRef = React.useRef<HTMLInputElement>(null);
    const emailRef = React.useRef<HTMLInputElement>(null);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        console.log({
            name: nameRef.current?.value,
            email: emailRef.current?.value,
        });
    };

    return (
        <form onSubmit={handleSubmit}>
            <input ref={nameRef} type="text" placeholder="Name" />
            <input ref={emailRef} type="email" placeholder="Email" />
            <button type="submit">Submit</button>
        </form>
    );
};

// 3. Custom Form Hook
interface UseFormOptions<T> {
    initialValues: T;
    onSubmit: (values: T) => void | Promise<void>;
    validate?: (values: T) => Partial<T>;
}

function useForm<T extends Record<string, any>>({
    initialValues,
    onSubmit,
    validate,
}: UseFormOptions<T>) {
    const [values, setValues] = React.useState(initialValues);
    const [errors, setErrors] = React.useState<Partial<T>>({});
    const [touched, setTouched] = React.useState<Partial<Record<keyof T, boolean>>>({});

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value, type, checked } = e.currentTarget;
        setValues(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value,
        }));
    };

    const handleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
        const { name } = e.currentTarget;
        setTouched(prev => ({ ...prev, [name]: true }));

        if (validate) {
            const fieldErrors = validate(values);
            setErrors(fieldErrors);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (validate) {
            const fieldErrors = validate(values);
            setErrors(fieldErrors);
            if (Object.keys(fieldErrors).length > 0) return;
        }

        await onSubmit(values);
    };

    return {
        values,
        errors,
        touched,
        handleChange,
        handleBlur,
        handleSubmit,
    };
}

// Usage
interface SignupData {
    email: string;
    password: string;
    confirmPassword: string;
}

const SignupForm: React.FC = () => {
    const form = useForm<SignupData>({
        initialValues: { email: '', password: '', confirmPassword: '' },
        validate: (values) => {
            const errors: Partial<SignupData> = {};
            if (!values.email) errors.email = 'Required';
            if (values.password !== values.confirmPassword) {
                errors.confirmPassword = 'Passwords do not match';
            }
            return errors;
        },
        onSubmit: async (values) => {
            // Submit form
        },
    });

    return (
        <form onSubmit={form.handleSubmit}>
            <input
                name="email"
                value={form.values.email}
                onChange={form.handleChange}
                onBlur={form.handleBlur}
            />
            {form.touched.email && form.errors.email && (
                <span>{form.errors.email}</span>
            )}
            {/* More fields */}
            <button type="submit">Sign up</button>
        </form>
    );
};
```

## Part 6: Conditional Rendering

```typescript
// 1. If/Else Pattern
interface LoadingProps {
    isLoading: boolean;
    hasError: boolean;
    errorMessage?: string;
    data?: string;
}

const Display: React.FC<LoadingProps> = ({
    isLoading,
    hasError,
    errorMessage,
    data,
}) => {
    if (isLoading) {
        return <div>Loading...</div>;
    }

    if (hasError) {
        return <div className="error">{errorMessage}</div>;
    }

    return <div>{data}</div>;
};

// 2. Ternary Operator
const Badge: React.FC<{ count: number }> = ({ count }) => (
    <span>
        {count > 0 ? `${count} items` : 'No items'}
    </span>
);

// 3. Logical AND Operator
const Notification: React.FC<{ message?: string; visible: boolean }> = ({
    message,
    visible,
}) => visible && <div className="notification">{message}</div>;

// 4. Switch Statement
type Status = 'pending' | 'success' | 'error';

const StatusBadge: React.FC<{ status: Status }> = ({ status }) => {
    switch (status) {
        case 'pending':
            return <span className="badge-warning">Pending</span>;
        case 'success':
            return <span className="badge-success">Success</span>;
        case 'error':
            return <span className="badge-error">Error</span>;
        default:
            const _exhaustive: never = status;
            return _exhaustive;
    }
};

// 5. Conditional Components
interface MenuProps {
    isAdmin: boolean;
    isLoggedIn: boolean;
}

const Menu: React.FC<MenuProps> = ({ isAdmin, isLoggedIn }) => (
    <nav>
        <a href="/">Home</a>
        {isLoggedIn && <a href="/profile">Profile</a>}
        {isAdmin && (
            <>
                <a href="/users">Users</a>
                <a href="/settings">Settings</a>
            </>
        )}
        {!isLoggedIn && <a href="/login">Login</a>}
    </nav>
);
```

## Part 7: Rendering Lists

```typescript
// 1. Basic List Rendering
interface ItemProps {
    id: string;
    title: string;
}

const ItemList: React.FC<{ items: ItemProps[] }> = ({ items }) => (
    <ul>
        {items.map(item => (
            <li key={item.id}>{item.title}</li>
        ))}
    </ul>
);

// 2. List with Filtering & Sorting
interface Product {
    id: number;
    name: string;
    price: number;
    category: string;
}

const ProductList: React.FC<{ products: Product[] }> = ({ products }) => {
    const [filterCategory, setFilterCategory] = React.useState('all');
    const [sortBy, setSortBy] = React.useState<'price' | 'name'>('name');

    const filtered = React.useMemo(() => {
        let result = products;

        if (filterCategory !== 'all') {
            result = result.filter(p => p.category === filterCategory);
        }

        if (sortBy === 'price') {
            result.sort((a, b) => a.price - b.price);
        } else {
            result.sort((a, b) => a.name.localeCompare(b.name));
        }

        return result;
    }, [products, filterCategory, sortBy]);

    return (
        <div>
            <select onChange={(e) => setFilterCategory(e.target.value)}>
                <option value="all">All</option>
                <option value="electronics">Electronics</option>
                <option value="books">Books</option>
            </select>

            <button onClick={() => setSortBy('name')}>Sort by Name</button>
            <button onClick={() => setSortBy('price')}>Sort by Price</button>

            <ul>
                {filtered.map(product => (
                    <li key={product.id}>
                        {product.name} - ${product.price}
                    </li>
                ))}
            </ul>
        </div>
    );
};

// 3. Indexed Lists
const IndexedList: React.FC<{ items: string[] }> = ({ items }) => (
    <ol>
        {items.map((item, index) => (
            <li key={index}>{item}</li>
        ))}
    </ol>
);

// 4. Grouped Lists
interface GroupedItem {
    group: string;
    items: string[];
}

const GroupedList: React.FC<{ groups: GroupedItem[] }> = ({ groups }) => (
    <div>
        {groups.map(group => (
            <div key={group.group}>
                <h3>{group.group}</h3>
                <ul>
                    {group.items.map((item, i) => (
                        <li key={i}>{item}</li>
                    ))}
                </ul>
            </div>
        ))}
    </div>
);

// 5. Empty State Handling
interface ListProps<T> {
    items: T[];
    renderItem: (item: T, index: number) => React.ReactNode;
    emptyMessage?: string;
}

const List = <T,>({
    items,
    renderItem,
    emptyMessage = 'No items found'
}: ListProps<T>) => (
    <>
        {items.length === 0 ? (
            <p className="empty">{emptyMessage}</p>
        ) : (
            <ul>
                {items.map((item, index) => (
                    <li key={index}>{renderItem(item, index)}</li>
                ))}
            </ul>
        )}
    </>
);

// Usage
<List
    items={users}
    renderItem={(user) => `${user.name} (${user.email})`}
    emptyMessage="No users available"
/>
```

## Part 8: Performance Optimization

```typescript
// 1. React.memo
interface UserCardProps {
    user: { id: number; name: string };
    onSelect: (id: number) => void;
}

const UserCard = React.memo<UserCardProps>(
    ({ user, onSelect }) => {
        console.log('UserCard rendered');
        return (
            <div onClick={() => onSelect(user.id)}>
                {user.name}
            </div>
        );
    },
    (prevProps, nextProps) => {
        return prevProps.user.id === nextProps.user.id;
    }
);

// 2. useMemo Hook
const ExpensiveComponent: React.FC<{ data: any[] }> = ({ data }) => {
    const expensiveValue = React.useMemo(() => {
        console.log('Computing expensive value...');
        return data.reduce((acc, item) => acc + item.value, 0);
    }, [data]);

    return <div>{expensiveValue}</div>;
};

// 3. useCallback Hook
interface ListProps {
    items: string[];
}

const List: React.FC<ListProps> = ({ items }) => {
    const [selected, setSelected] = React.useState<string | null>(null);

    const handleSelect = React.useCallback(
        (item: string) => {
            setSelected(item);
        },
        []
    );

    return (
        <div>
            {items.map(item => (
                <Item
                    key={item}
                    value={item}
                    onSelect={handleSelect}
                    isSelected={item === selected}
                />
            ))}
        </div>
    );
};

const Item = React.memo(
    ({ value, onSelect, isSelected }: any) => (
        <div
            onClick={() => onSelect(value)}
            className={isSelected ? 'selected' : ''}
        >
            {value}
        </div>
    )
);

// 4. Code Splitting with Suspense
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));

const App: React.FC = () => (
    <React.Suspense fallback={<div>Loading component...</div>}>
        <HeavyComponent />
    </React.Suspense>
);

// 5. Lazy Route Loading
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Contact = lazy(() => import('./pages/Contact'));

const Router: React.FC = () => (
    <BrowserRouter>
        <Suspense fallback={<div>Loading...</div>}>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/about" element={<About />} />
                <Route path="/contact" element={<Contact />} />
            </Routes>
        </Suspense>
    </BrowserRouter>
);
```

---

## Key Takeaways

1. **Type Safety**: Always type your props, state, and events
2. **Component Design**: Keep components small and focused
3. **Hooks**: Use hooks for state management and side effects
4. **Performance**: Memoize expensive computations and components
5. **Forms**: Use controlled components for better control
6. **Lists**: Always use stable keys when rendering lists
7. **Event Handling**: Type your event handlers correctly
8. **Rendering**: Optimize conditional rendering and list rendering

---

**Last Updated:** October 26, 2024
**Level:** Expert
**Topics Covered:** 50+ fundamental concepts, 80+ code examples
