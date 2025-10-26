# React with TypeScript - Real-World Coding Challenges

## Challenge 1: Build a Todo Application with Persistence

**Difficulty:** Intermediate
**Estimated Time:** 2 hours

### Requirements

Create a complete todo application with the following features:

1. **Add todos** - Input field with validation (min 3 characters)
2. **Mark complete** - Toggle completion status with visual feedback
3. **Delete todos** - Remove individual todos
4. **Persistence** - Save to localStorage, load on mount
5. **Filtering** - Show all, active, or completed todos
6. **Statistics** - Display count of active and completed todos
7. **Type Safety** - Full TypeScript support

### Starter Code

```typescript
interface Todo {
    id: string;
    text: string;
    completed: boolean;
    createdAt: Date;
}

interface TodoContextType {
    todos: Todo[];
    addTodo: (text: string) => void;
    toggleTodo: (id: string) => void;
    deleteTodo: (id: string) => void;
    filter: 'all' | 'active' | 'completed';
    setFilter: (filter: 'all' | 'active' | 'completed') => void;
}
```

### Expected Solution Structure

```typescript
// 1. Context for state management
const TodoContext = React.createContext<TodoContextType | undefined>(undefined);

// 2. Provider component with localStorage persistence
const TodoProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    // Implementation...
};

// 3. Input component with validation
const TodoInput: React.FC = () => {
    // Implementation...
};

// 4. List component with filtering
const TodoList: React.FC = () => {
    // Implementation...
};

// 5. Filters and statistics
const TodoStats: React.FC = () => {
    // Implementation...
};
```

### Key Concepts to Practice

- useState for state management
- useContext for sharing state
- Custom hooks for reusable logic
- localStorage API
- TypeScript interfaces and types
- Event handling
- Conditional rendering
- Array manipulation (map, filter, find)

### Bonus Features

1. **Edit todos** - Modify existing todo text
2. **Due dates** - Add and filter by due date
3. **Categories** - Organize todos into categories
4. **Undo/Redo** - History management
5. **Export/Import** - Save and load todos from JSON

---

## Challenge 2: Build a User Search Component

**Difficulty:** Intermediate
**Estimated Time:** 2 hours

### Requirements

Create a search component that:

1. **Debounced search** - API calls debounced (300ms)
2. **Display results** - Show user list with name, email, avatar
3. **Error handling** - Show error messages gracefully
4. **Loading state** - Display spinner during fetch
5. **No results** - Handle empty results
6. **Click to select** - Select and show user details
7. **Keyboard navigation** - Arrow keys to navigate results (bonus)

### API Endpoint

```typescript
// Mock API
interface User {
    id: number;
    name: string;
    email: string;
    avatar: string;
}

const mockUsers: User[] = [
    { id: 1, name: 'Alice Johnson', email: 'alice@example.com', avatar: 'https://...' },
    { id: 2, name: 'Bob Smith', email: 'bob@example.com', avatar: 'https://...' },
    // ...
];

const searchUsers = async (query: string): Promise<User[]> => {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));

    if (!query.trim()) return [];

    return mockUsers.filter(user =>
        user.name.toLowerCase().includes(query.toLowerCase()) ||
        user.email.toLowerCase().includes(query.toLowerCase())
    );
};
```

### Solution Structure

```typescript
interface SearchState {
    query: string;
    results: User[];
    loading: boolean;
    error: Error | null;
    selectedUser: User | null;
}

const UserSearch: React.FC = () => {
    const [state, setState] = React.useState<SearchState>({
        query: '',
        results: [],
        loading: false,
        error: null,
        selectedUser: null,
    });

    // 1. Implement debounced search
    const handleSearch = (query: string) => {
        // Debounce logic...
    };

    // 2. Fetch and update results
    const fetchResults = async (query: string) => {
        // Fetch logic...
    };

    // 3. Render results with proper states
    return (
        <div>
            <input
                value={state.query}
                onChange={(e) => handleSearch(e.target.value)}
                placeholder="Search users..."
            />
            {state.loading && <Spinner />}
            {state.error && <Error message={state.error.message} />}
            {state.results.map(user => (
                <UserCard key={user.id} user={user} />
            ))}
        </div>
    );
};
```

### Key Concepts to Practice

- Custom useDebounce hook
- useEffect for side effects
- useState for managing fetch state
- Error handling and display
- Loading states and spinners
- Proper TypeScript typing
- Async/await patterns

### Bonus Features

1. **Recent searches** - Show last 5 searches
2. **Keyboard navigation** - Arrow keys and Enter
3. **User profiles** - Click to see full profile
4. **Quick add** - Add user to favorites
5. **Search history** - Persist searches to localStorage

---

## Challenge 3: Build a Data Table with Sorting and Filtering

**Difficulty:** Advanced
**Estimated Time:** 3 hours

### Requirements

Create a data table component with:

1. **Column headers** - Click to sort (ascending/descending)
2. **Sorting** - Support multiple column types (string, number, date)
3. **Filtering** - Filter by multiple columns
4. **Pagination** - Display 10 items per page
5. **Search** - Global search across all columns
6. **Selection** - Select multiple rows with checkboxes
7. **Actions** - Edit, delete, export for selected rows

### Data Structure

```typescript
interface Product {
    id: number;
    name: string;
    category: string;
    price: number;
    stock: number;
    createdAt: Date;
    status: 'active' | 'inactive';
}

// Sample data with 100 products
const mockProducts: Product[] = [
    { id: 1, name: 'Product 1', category: 'Electronics', price: 99.99, stock: 50, createdAt: new Date('2024-01-01'), status: 'active' },
    // ... more products
];
```

### Solution Structure

```typescript
interface TableState {
    sortColumn: keyof Product | null;
    sortDirection: 'asc' | 'desc';
    filters: Partial<Record<keyof Product, any>>;
    currentPage: number;
    selectedRows: Set<number>;
    searchQuery: string;
}

interface TableColumn<T> {
    key: keyof T;
    label: string;
    sortable: boolean;
    filterable: boolean;
    render?: (value: any) => React.ReactNode;
}

const DataTable: React.FC<{ data: Product[]; columns: TableColumn<Product>[] }> = ({
    data,
    columns,
}) => {
    // 1. Implement sorting logic
    const handleSort = (column: keyof Product) => {
        // Toggle sort...
    };

    // 2. Implement filtering
    const handleFilter = (column: keyof Product, value: any) => {
        // Apply filter...
    };

    // 3. Implement pagination
    const paginatedData = getPaginatedData();

    // 4. Render table
    return (
        <div>
            <TableHeader columns={columns} onSort={handleSort} />
            <TableBody
                data={paginatedData}
                columns={columns}
                selected={selectedRows}
                onSelectRow={toggleRow}
            />
            <Pagination
                totalPages={totalPages}
                currentPage={currentPage}
                onPageChange={setCurrentPage}
            />
        </div>
    );
};
```

### Key Concepts to Practice

- useState for managing complex table state
- useMemo for filtering and sorting optimization
- useCallback for event handlers
- Custom comparators for different types
- Pagination logic
- Selection management (checkboxes)
- TypeScript generics for type-safe tables
- Responsive table design

### Bonus Features

1. **Column resizing** - Adjust column widths
2. **Column hiding** - Show/hide columns
3. **Bulk actions** - Edit multiple rows
4. **Export to CSV** - Download as CSV
5. **Advanced filters** - Date ranges, numeric ranges
6. **Drag to reorder** - Reorder columns

---

## Challenge 4: Build a Form Wizard (Multi-Step Form)

**Difficulty:** Advanced
**Estimated Time:** 3 hours

### Requirements

Create a multi-step form with:

1. **Step navigation** - Next, Previous, Submit buttons
2. **Validation** - Validate before proceeding to next step
3. **Progress indicator** - Show current step and progress
4. **State persistence** - Maintain data between steps
5. **Error handling** - Display validation errors
6. **Type safety** - Full TypeScript support

### Form Structure

```typescript
interface UserFormData {
    // Step 1: Personal Info
    firstName: string;
    lastName: string;
    email: string;

    // Step 2: Address
    street: string;
    city: string;
    state: string;
    zip: string;

    // Step 3: Preferences
    newsletter: boolean;
    notifications: 'email' | 'sms' | 'both' | 'none';
    frequency: 'daily' | 'weekly' | 'monthly';
}

interface Step {
    id: number;
    title: string;
    description: string;
    fields: (keyof UserFormData)[];
}

const steps: Step[] = [
    { id: 1, title: 'Personal Info', description: 'Enter your details', fields: ['firstName', 'lastName', 'email'] },
    { id: 2, title: 'Address', description: 'Where do you live?', fields: ['street', 'city', 'state', 'zip'] },
    { id: 3, title: 'Preferences', description: 'Customize your experience', fields: ['newsletter', 'notifications', 'frequency'] },
];
```

### Solution Structure

```typescript
interface FormWizardState {
    currentStep: number;
    data: Partial<UserFormData>;
    errors: Partial<Record<keyof UserFormData, string>>;
    isSubmitting: boolean;
}

const FormWizard: React.FC = () => {
    const [state, setState] = React.useState<FormWizardState>({
        currentStep: 1,
        data: {},
        errors: {},
        isSubmitting: false,
    });

    // 1. Handle field changes
    const handleFieldChange = (field: keyof UserFormData, value: any) => {
        setState(prev => ({
            ...prev,
            data: { ...prev.data, [field]: value },
        }));
    };

    // 2. Validate current step
    const validateStep = (): boolean => {
        const currentStepFields = steps.find(s => s.id === state.currentStep)?.fields || [];
        // Validate logic...
        return true;
    };

    // 3. Handle next step
    const handleNext = () => {
        if (validateStep()) {
            setState(prev => ({
                ...prev,
                currentStep: prev.currentStep + 1,
            }));
        }
    };

    // 4. Handle submit
    const handleSubmit = async () => {
        if (validateStep()) {
            // Submit logic...
        }
    };

    return (
        <div>
            <ProgressBar current={state.currentStep} total={steps.length} />
            <StepContent step={steps[state.currentStep - 1]} data={state.data} onChange={handleFieldChange} errors={state.errors} />
            <StepNavigation
                currentStep={state.currentStep}
                totalSteps={steps.length}
                onPrevious={() => setState(prev => ({ ...prev, currentStep: prev.currentStep - 1 }))}
                onNext={handleNext}
                onSubmit={handleSubmit}
            />
        </div>
    );
};
```

### Key Concepts to Practice

- useState for managing multi-step state
- Form validation across steps
- Error handling and display
- Conditional rendering based on step
- Type-safe form data
- Progress tracking
- Navigation logic

### Bonus Features

1. **Save progress** - Resume from where user left off
2. **Edit previous step** - Allow going back and editing
3. **Review step** - Show all data before submitting
4. **Conditional steps** - Skip steps based on answers
5. **Auto-save** - Save progress on field change

---

## Challenge 5: Build a Real-time Chat Component

**Difficulty:** Advanced
**Estimated Time:** 3 hours

### Requirements

Create a chat component with:

1. **Message display** - Show sent/received messages
2. **Real-time updates** - WebSocket or polling
3. **User status** - Show online/offline status
4. **Typing indicator** - Show when user is typing
5. **Message timestamps** - Display time relative to now
6. **Auto-scroll** - Scroll to latest message
7. **Input validation** - Don't send empty messages

### Data Structure

```typescript
interface Message {
    id: string;
    senderId: string;
    text: string;
    timestamp: Date;
    read: boolean;
}

interface ChatUser {
    id: string;
    name: string;
    avatar: string;
    status: 'online' | 'offline';
    lastSeen: Date;
}

interface ChatState {
    messages: Message[];
    currentUser: ChatUser;
    otherUser: ChatUser;
    typingUsers: string[];
    isConnected: boolean;
}
```

### Solution Structure

```typescript
const ChatComponent: React.FC<{ userId: string; recipientId: string }> = ({ userId, recipientId }) => {
    const [state, setState] = React.useState<ChatState>({
        messages: [],
        currentUser: null,
        otherUser: null,
        typingUsers: [],
        isConnected: false,
    });

    const messagesEndRef = React.useRef<HTMLDivElement>(null);

    // 1. Connect to WebSocket or polling
    React.useEffect(() => {
        const connect = () => {
            // Connect and listen for messages...
        };
        connect();
        return () => {
            // Cleanup connection
        };
    }, []);

    // 2. Auto-scroll to bottom
    React.useEffect(() => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, [state.messages]);

    // 3. Send message
    const handleSendMessage = (text: string) => {
        if (!text.trim()) return;
        // Send message...
    };

    // 4. Handle typing
    const handleTyping = () => {
        // Notify other user of typing...
    };

    return (
        <div className="chat-container">
            <ChatHeader user={state.otherUser} />
            <MessageList
                messages={state.messages}
                currentUserId={userId}
                typingUsers={state.typingUsers}
            />
            <div ref={messagesEndRef} />
            <ChatInput onSend={handleSendMessage} onTyping={handleTyping} />
        </div>
    );
};
```

### Key Concepts to Practice

- WebSocket/polling for real-time data
- useRef for DOM scrolling
- useEffect for connection management
- Message state management
- Typing indicator logic
- Relative timestamps (e.g., "5 minutes ago")
- Auto-scroll behavior
- Unread message handling

### Bonus Features

1. **Message reactions** - Emoji reactions
2. **File sharing** - Send images/files
3. **Message search** - Search through messages
4. **Group chat** - Support multiple users
5. **Message editing** - Edit sent messages
6. **Unread badges** - Show unread count

---

## Challenge 6: Build a Dynamic Form Generator

**Difficulty:** Advanced
**Estimated Time:** 3 hours

### Requirements

Create a form generator that:

1. **Schema-driven** - Generate forms from JSON schema
2. **Field types** - Support text, email, number, select, checkbox, textarea
3. **Validation** - Validate based on schema rules
4. **Conditional fields** - Show/hide fields based on other field values
5. **Dynamic arrays** - Add/remove field arrays
6. **Error display** - Show field-level errors
7. **Type safety** - Full TypeScript support

### Schema Structure

```typescript
interface FieldSchema {
    name: string;
    label: string;
    type: 'text' | 'email' | 'number' | 'select' | 'checkbox' | 'textarea';
    required?: boolean;
    validation?: {
        min?: number;
        max?: number;
        pattern?: RegExp;
        custom?: (value: any) => boolean;
    };
    options?: Array<{ value: string; label: string }>;
    condition?: (formData: any) => boolean; // Show if true
}

interface FormSchema {
    title: string;
    fields: FieldSchema[];
    submitLabel?: string;
}

const exampleSchema: FormSchema = {
    title: 'User Registration',
    fields: [
        { name: 'email', label: 'Email', type: 'email', required: true },
        { name: 'password', label: 'Password', type: 'text', required: true },
        {
            name: 'accountType',
            label: 'Account Type',
            type: 'select',
            options: [
                { value: 'personal', label: 'Personal' },
                { value: 'business', label: 'Business' },
            ],
        },
        {
            name: 'businessName',
            label: 'Business Name',
            type: 'text',
            condition: (data) => data.accountType === 'business',
        },
    ],
};
```

### Solution Structure

```typescript
interface FormGeneratorProps {
    schema: FormSchema;
    onSubmit: (data: any) => void;
}

const FormGenerator: React.FC<FormGeneratorProps> = ({ schema, onSubmit }) => {
    const [formData, setFormData] = React.useState<any>({});
    const [errors, setErrors] = React.useState<Record<string, string>>({});

    // 1. Handle field changes
    const handleChange = (fieldName: string, value: any) => {
        setFormData(prev => ({ ...prev, [fieldName]: value }));
        // Clear error if exists
    };

    // 2. Validate field
    const validateField = (field: FieldSchema, value: any): string | null => {
        if (field.required && !value) return `${field.label} is required`;
        // More validation logic...
        return null;
    };

    // 3. Validate entire form
    const validateForm = (): boolean => {
        // Validate all fields...
        return true;
    };

    // 4. Handle submit
    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (validateForm()) {
            onSubmit(formData);
        }
    };

    // 5. Render fields conditionally
    const visibleFields = schema.fields.filter(f => !f.condition || f.condition(formData));

    return (
        <form onSubmit={handleSubmit}>
            <h2>{schema.title}</h2>
            {visibleFields.map(field => (
                <FormField
                    key={field.name}
                    field={field}
                    value={formData[field.name] || ''}
                    error={errors[field.name]}
                    onChange={(value) => handleChange(field.name, value)}
                />
            ))}
            <button type="submit">{schema.submitLabel || 'Submit'}</button>
        </form>
    );
};
```

### Key Concepts to Practice

- Schema-driven form generation
- Dynamic field rendering
- Conditional field visibility
- Validation logic
- TypeScript generics
- Error state management
- Dynamic field arrays
- Flexible component architecture

### Bonus Features

1. **Nested fields** - Support nested object schemas
2. **Custom validators** - Custom validation functions
3. **Field dependencies** - Fields depending on other fields
4. **Dynamic options** - Options from API
5. **Multi-language support** - i18n for labels

---

## Challenge 7: Build a Shopping Cart with State Management

**Difficulty:** Advanced
**Estimated Time:** 3 hours

### Requirements

Create an e-commerce cart with:

1. **Add to cart** - Add/update item quantities
2. **Remove items** - Delete items from cart
3. **Update quantities** - Change item quantities
4. **Persist state** - Save to localStorage
5. **Calculate totals** - Subtotal, tax, shipping, total
6. **Apply coupons** - Discount codes
7. **Checkout flow** - Simple checkout process

### Data Structure

```typescript
interface Product {
    id: string;
    name: string;
    price: number;
    image: string;
    stock: number;
}

interface CartItem {
    product: Product;
    quantity: number;
}

interface CartState {
    items: CartItem[];
    discountCode: string | null;
    discountPercent: number;
    shippingCost: number;
}

interface CartContextType {
    state: CartState;
    addItem: (product: Product, quantity: number) => void;
    removeItem: (productId: string) => void;
    updateQuantity: (productId: string, quantity: number) => void;
    applyDiscount: (code: string) => boolean;
    checkout: () => Promise<void>;
}
```

### Solution Structure

```typescript
// Valid discount codes
const discountCodes: Record<string, number> = {
    'SAVE10': 10,
    'SAVE20': 20,
    'SAVE50': 50,
};

const CartProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [state, setState] = React.useState<CartState>(() => {
        const saved = localStorage.getItem('cart');
        return saved ? JSON.parse(saved) : { items: [], discountCode: null, discountPercent: 0, shippingCost: 10 };
    });

    // 1. Save to localStorage
    React.useEffect(() => {
        localStorage.setItem('cart', JSON.stringify(state));
    }, [state]);

    // 2. Add item
    const addItem = (product: Product, quantity: number) => {
        setState(prev => {
            const existing = prev.items.find(i => i.product.id === product.id);
            if (existing) {
                return {
                    ...prev,
                    items: prev.items.map(i =>
                        i.product.id === product.id
                            ? { ...i, quantity: i.quantity + quantity }
                            : i
                    ),
                };
            }
            return { ...prev, items: [...prev.items, { product, quantity }] };
        });
    };

    // 3. Calculate totals
    const subtotal = state.items.reduce((sum, item) => sum + item.product.price * item.quantity, 0);
    const discountAmount = subtotal * (state.discountPercent / 100);
    const total = subtotal - discountAmount + state.shippingCost;

    return (
        <CartContext.Provider value={{ state, addItem, /* ... */ }}>
            {children}
        </CartContext.Provider>
    );
};
```

### Key Concepts to Practice

- useContext for global state
- localStorage persistence
- Calculations (subtotal, tax, discounts)
- Cart item management
- Complex state updates
- TypeScript interfaces
- Provider pattern
- Side effects (saving state)

### Bonus Features

1. **Stock validation** - Check inventory
2. **Wishlist** - Save for later
3. **Product recommendations** - Related products
4. **Order history** - View past orders
5. **Multiple payment methods** - Support various payments

---

## Challenge 8: Build a Dashboard with Charts and Analytics

**Difficulty:** Advanced
**Estimated Time:** 4 hours

### Requirements

Create a dashboard with:

1. **Charts** - Line, bar, pie charts for data visualization
2. **Time period selector** - Filter data by date range
3. **Statistics cards** - Show key metrics
4. **Responsive layout** - Works on mobile/tablet/desktop
5. **Real-time updates** - Live data updates
6. **Export data** - Download as CSV or PDF
7. **Dark mode** - Support light and dark themes

### Solution Structure

```typescript
interface DashboardMetrics {
    totalRevenue: number;
    totalOrders: number;
    averageOrderValue: number;
    newCustomers: number;
}

interface ChartData {
    labels: string[];
    datasets: Array<{
        label: string;
        data: number[];
    }>;
}

const Dashboard: React.FC = () => {
    const [metrics, setMetrics] = React.useState<DashboardMetrics | null>(null);
    const [chartData, setChartData] = React.useState<ChartData | null>(null);
    const [dateRange, setDateRange] = React.useState<[Date, Date]>([
        new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
        new Date(),
    ]);
    const [theme, setTheme] = React.useState<'light' | 'dark'>('light');

    // 1. Fetch dashboard data
    React.useEffect(() => {
        fetchDashboardData(dateRange);
    }, [dateRange]);

    // 2. Export functionality
    const handleExport = (format: 'csv' | 'pdf') => {
        // Export logic...
    };

    return (
        <div className={`dashboard ${theme}`}>
            <Header onThemeToggle={() => setTheme(t => t === 'light' ? 'dark' : 'light')} />
            <DateRangePicker onChange={setDateRange} />
            <MetricsGrid metrics={metrics} />
            <ChartsSection data={chartData} />
            <ExportButtons onExport={handleExport} />
        </div>
    );
};
```

### Key Concepts to Practice

- Chart library integration (Recharts, Chart.js)
- Data visualization patterns
- Date range selection
- Responsive grid layouts
- Real-time data updates
- Export functionality
- Theme switching
- TypeScript for complex data structures

### Bonus Features

1. **Filters** - Filter by category, region
2. **Drill-down** - Click chart for details
3. **Custom date ranges** - Predefined ranges
4. **Alerts** - Notify on anomalies
5. **Scheduled exports** - Email reports

---

## Summary

### Difficulty Progression

1. **Challenge 1 - Todo App** - Master fundamentals
2. **Challenge 2 - User Search** - Learn async patterns
3. **Challenge 3 - Data Table** - Complex state management
4. **Challenge 4 - Form Wizard** - Multi-step workflows
5. **Challenge 5 - Chat** - Real-time updates
6. **Challenge 6 - Form Generator** - Advanced patterns
7. **Challenge 7 - Shopping Cart** - Full feature implementation
8. **Challenge 8 - Dashboard** - Professional applications

### Skills Covered Across Challenges

- ✅ State management (useState, useContext, useReducer)
- ✅ Side effects (useEffect, custom hooks)
- ✅ Performance optimization (useMemo, useCallback)
- ✅ Form handling and validation
- ✅ Async operations (fetch, API calls)
- ✅ Error handling
- ✅ TypeScript integration
- ✅ localStorage persistence
- ✅ Real-time communication
- ✅ Complex UI components
- ✅ Responsive design
- ✅ Testing patterns

### Recommended Approach

1. Start with Challenge 1 and 2 to build confidence
2. Complete Challenge 3 before 4
3. Attempt challenges 5-8 in any order
4. Review solutions and compare approaches
5. Add bonus features to extend learning

### Time Commitment

- **All 8 challenges:** 20-24 hours
- **First 4 challenges:** 10-12 hours
- **Individual challenge:** 2-4 hours

### How to Use These Challenges

1. Read requirements carefully
2. Start coding without looking at solutions
3. Implement basic functionality first
4. Add features iteratively
5. Test edge cases
6. Review the provided starter code for patterns
7. Refactor for code quality
8. Add bonus features

---

**Last Updated:** October 26, 2024
**Level:** Intermediate to Advanced
**Total Challenges:** 8
**Estimated Total Time:** 20-24 hours
