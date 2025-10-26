# React with TypeScript - Self-Assessment Quiz

## Part 1: React Fundamentals (Questions 1-20)

### Question 1: Basic Component

What will this component render?

```typescript
interface Props {
    name: string;
    age?: number;
}

const User: React.FC<Props> = ({ name, age }) => (
    <div>
        <h2>{name}</h2>
        {age && <p>Age: {age}</p>}
    </div>
);

// Usage
<User name="Alice" age={25} />
```

**A)** A div with "Alice" and "Age: 25"
**B)** A div with "Alice" only
**C)** Error: age is required
**D)** A div with "Alice" and undefined age

**Answer:** A - The age is defined (25), so both elements render

---

### Question 2: useState Hook

What's the initial value of `count` after rendering?

```typescript
const Counter: React.FC = () => {
    const [count, setCount] = React.useState(0);
    return <div>{count}</div>;
};
```

**A)** undefined
**B)** null
**C)** 0
**D)** Error

**Answer:** C - useState initializes count to 0

---

### Question 3: Props Immutability

Which statement is true about React props?

**A)** Props can be modified directly
**B)** Props are immutable and should not be modified
**C)** Props can be modified only inside event handlers
**D)** Props are mutable in functional components but not in class components

**Answer:** B - Props are read-only

---

### Question 4: Conditional Rendering

How many elements will render?

```typescript
const Message: React.FC<{ count: number }> = ({ count }) => (
    <div>
        {count > 0 && <p>Positive</p>}
        {count < 0 && <p>Negative</p>}
        {count === 0 && <p>Zero</p>}
    </div>
);

<Message count={5} />
```

**A)** 0
**B)** 1
**C)** 2
**D)** 3

**Answer:** B - Only "Positive" renders since count is 5

---

### Question 5: Map with Key

What's wrong with this code?

```typescript
const List: React.FC<{ items: string[] }> = ({ items }) => (
    <ul>
        {items.map((item, index) => (
            <li key={index}>{item}</li>
        ))}
    </ul>
);
```

**A)** Nothing, it will work fine
**B)** Using index as key can cause issues with list reordering
**C)** li elements don't support the key prop
**D)** items.map is not a valid method

**Answer:** B - Index as key is an anti-pattern for dynamic lists

---

### Question 6: Event Handler Typing

What's the correct type for this event handler?

```typescript
const handleChange = (event: ???) => {
    console.log(event.target.value);
};

<input onChange={handleChange} />
```

**A)** Event
**B)** React.ChangeEvent<HTMLInputElement>
**C)** SyntheticEvent
**D)** InputEvent

**Answer:** B - React types input events as ChangeEvent<HTMLInputElement>

---

### Question 7: Fragment Usage

What's the purpose of Fragment?

```typescript
const Items: React.FC = () => (
    <>
        <li>Item 1</li>
        <li>Item 2</li>
    </>
);
```

**A)** Render multiple elements without a wrapper div
**B)** Improve performance
**C)** Add styling
**D)** Create a new component

**Answer:** A - Fragment allows rendering multiple elements without adding extra DOM nodes

---

### Question 8: useEffect Dependency

How many times will the effect run?

```typescript
const Component: React.FC = () => {
    React.useEffect(() => {
        console.log('Effect ran');
    }, []);

    return <div>Hello</div>;
};
```

**A)** Never
**B)** Once on mount
**C)** Every render
**D)** Once on mount and once on unmount

**Answer:** B - Empty dependency array means effect runs only on mount

---

### Question 9: useRef vs useState

When should you use useRef instead of useState?

**A)** To update component state
**B)** To access DOM elements or store mutable values that don't trigger re-renders
**C)** To manage form inputs
**D)** To fetch data from APIs

**Answer:** B - useRef stores values that don't cause re-renders

---

### Question 10: Destructuring Props

Which is the correct way to destructure props?

```typescript
interface Props {
    name: string;
    age: number;
}

// Option 1
const Component: React.FC<Props> = (props) => {
    const { name, age } = props;
};

// Option 2
const Component: React.FC<Props> = ({ name, age }) => {};
```

**A)** Option 1 only
**B)** Option 2 only
**C)** Both are correct
**D)** Neither is correct

**Answer:** C - Both patterns work, but Option 2 is more idiomatic

---

### Question 11: JSX Expression

What will render?

```typescript
const Component: React.FC = () => {
    const items = ['a', 'b', 'c'];
    return <div>{items}</div>;
};
```

**A)** ["a", "b", "c"]
**B)** abc
**C)** Error
**D)** A comma-separated list with commas shown

**Answer:** B - React renders array items as a concatenated string

---

### Question 12: Component Naming

Which name is valid for a React component?

**A)** myComponent
**B)** MyComponent
**C)** my-component
**D)** my_component

**Answer:** B - Component names must be PascalCase

---

### Question 13: Children Prop

What's the type of children?

```typescript
interface Props {
    children: ???
}

const Container: React.FC<Props> = ({ children }) => (
    <div>{children}</div>
);
```

**A)** React.ReactNode
**B)** JSX.Element
**C)** React.FC
**D)** any

**Answer:** A - React.ReactNode is the correct type for children

---

### Question 14: forwardRef

Why would you use forwardRef?

```typescript
const Input = React.forwardRef<HTMLInputElement, InputProps>(
    (props, ref) => <input ref={ref} />
);
```

**A)** To forward events to parent
**B)** To expose DOM element to parent component
**C)** To improve performance
**D)** To create a functional component

**Answer:** B - forwardRef allows parent to access child's DOM element

---

### Question 15: useMemo Purpose

What does useMemo do?

**A)** Memoizes component renders
**B)** Caches computation results
**C)** Optimizes all functions
**D)** Prevents state updates

**Answer:** B - useMemo caches expensive calculations

---

### Question 16: useCallback Purpose

What does useCallback do?

**A)** Calls a function immediately
**B)** Delays function execution
**C)** Memoizes a function reference
**D)** Prevents function calls

**Answer:** C - useCallback returns a memoized function

---

### Question 17: Controlled Input

What makes an input controlled?

```typescript
const [value, setValue] = React.useState('');

<input value={value} onChange={(e) => setValue(e.target.value)} />
```

**A)** The value prop is set from state
**B)** The onChange handler updates state
**C)** Both A and B
**D)** It's an input element

**Answer:** C - Both value from state and onChange handler make it controlled

---

### Question 18: preventDefault

When would you use preventDefault?

```typescript
const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // ...
};

<form onSubmit={handleSubmit}>
```

**A)** To stop form submission and handle it with JavaScript
**B)** To disable the form
**C)** To validate inputs
**D)** To prevent re-renders

**Answer:** A - preventDefault stops default form submission behavior

---

### Question 19: Rendering Optimization

What's the purpose of React.memo?

**A)** Improve rendering speed
**B)** Prevent re-renders if props don't change
**C)** Cache component state
**D)** Memoize component computation

**Answer:** B - React.memo skips re-render if props haven't changed

---

### Question 20: Component Composition

Which demonstrates better composition?

```typescript
// Option A: Inheritance
class Button extends BaseButton {}

// Option B: Composition
const Button: React.FC<ButtonProps> = (props) => <BaseButton {...props} />;
```

**A)** Option A is better
**B)** Option B is better
**C)** Both are equal
**D)** Neither works in React

**Answer:** B - Composition (Option B) is preferred in React

---

## Part 2: Advanced React (Questions 21-40)

### Question 21: Context API

How many times does Context value change cause re-renders?

```typescript
const Context = React.createContext({ value: 0 });

const Provider: React.FC<{ children: React.ReactNode }> = ({ children }) => (
    <Context.Provider value={{ value: Math.random() }}>
        {children}
    </Context.Provider>
);
```

**A)** Never
**B)** Once per render
**C)** Only when value actually changes
**D)** Never, objects are compared by reference

**Answer:** B - New object is created each render, causing re-renders

---

### Question 22: useContext Hook

What happens if you call useContext outside a Provider?

```typescript
const value = React.useContext(MyContext);
```

**A)** Returns undefined
**B)** Returns default value
**C)** Throws error
**D)** Returns null

**Answer:** B or C depending on how the context is defined - usually error if no default

---

### Question 23: Custom Hook Naming

What must all custom hooks start with?

**A)** "use"
**B)** "get"
**C)** "Custom"
**D)** "_"

**Answer:** A - Custom hooks must start with "use"

---

### Question 24: Error Boundaries

Which error types do Error Boundaries catch?

**A)** All JavaScript errors
**B)** Errors during rendering and lifecycle methods
**C)** Event handler errors
**D)** Async errors

**Answer:** B - Error Boundaries only catch errors during render and lifecycle

---

### Question 25: Suspense Boundaries

What does Suspense do?

```typescript
<Suspense fallback={<Spinner />}>
    <LazyComponent />
</Suspense>
```

**A)** Catches errors
**B)** Handles code splitting and async rendering
**C)** Prevents component updates
**D)** Optimizes performance

**Answer:** B - Suspense handles code splitting and shows fallback during loading

---

### Question 26: React.lazy

What does React.lazy return?

```typescript
const Component = React.lazy(() => import('./Heavy'));
```

**A)** The imported component
**B)** A promise
**C)** A lazy component that must be wrapped in Suspense
**D)** An error

**Answer:** C - lazy returns a component that suspends during loading

---

### Question 27: HOC Pattern

What's the purpose of Higher-Order Components?

**A)** Render child components
**B)** Add functionality to components
**C)** Manage component state
**D)** Handle errors

**Answer:** B - HOCs are functions that enhance components with additional functionality

---

### Question 28: Render Props Pattern

What's the render prop pattern?

```typescript
<DataFetcher render={(data) => <Component data={data} />} />
```

**A)** Passing JSX as a prop
**B)** Rendering child components
**C)** Creating components in props
**D)** All of above

**Answer:** D - Render props pattern uses functions passed as props to render content

---

### Question 29: useReducer Hook

When should you use useReducer instead of useState?

**A)** Always instead of useState
**B)** For complex state with multiple sub-values
**C)** For simple boolean state
**D)** Never, useState is better

**Answer:** B - useReducer is better for complex state logic

---

### Question 30: Action Typing in useReducer

How should actions be typed?

```typescript
type AppAction = ??? ;

const reducer = (state: AppState, action: AppAction): AppState => {
    switch (action.type) {
        case 'INCREMENT': return { ...state, count: state.count + 1 };
        case 'DECREMENT': return { ...state, count: state.count - 1 };
    }
};
```

**A)** Union of action objects with type property
**B)** Any type
**C)** String
**D)** Function

**Answer:** A - Use discriminated union types for type safety

---

### Question 31: Compound Components

What's a compound component?

**A)** A component with multiple children
**B)** A component that manages related sub-components together
**C)** A component that inherits from another
**D)** A component with props

**Answer:** B - Compound components manage related sub-components as a unit

---

### Question 32: React.memo Comparison

How does React.memo compare props?

**A)** Using === (shallow comparison)
**B)** Using deep equality
**C)** Using object.equals
**D)** Always re-renders

**Answer:** A - React.memo uses shallow comparison by default

---

### Question 33: Custom Comparison in React.memo

How do you provide custom prop comparison?

```typescript
React.memo(Component, (prevProps, nextProps) => {
    return ??? // return true to skip re-render
});
```

**A)** Return true if props are equal
**B)** Return false if props are equal
**C)** Return props equality
**D)** Return object comparison

**Answer:** A - Return true if props are EQUAL to SKIP re-render (inverse of standard comparison)

---

### Question 34: useLayoutEffect vs useEffect

What's the difference?

**A)** useLayoutEffect runs synchronously after DOM mutations
**B)** useEffect runs asynchronously after paint
**C)** useLayoutEffect is better for animations
**D)** All of above

**Answer:** D - useLayoutEffect is synchronous and useful for layout-dependent effects

---

### Question 35: Dependency Array

What's wrong with this?

```typescript
React.useEffect(() => {
    console.log(data);
}, [data.id]);
```

**A)** data.id is not a primitive
**B)** Should use data instead
**C)** Dependency array should be empty
**D)** Nothing is wrong

**Answer:** B - Should include full objects, not properties, to avoid bugs

---

### Question 36: Cleanup Function

What does a cleanup function in useEffect do?

```typescript
React.useEffect(() => {
    const unsubscribe = subscribe();
    return () => unsubscribe(); // cleanup
}, []);
```

**A)** Runs before component mounts
**B)** Runs on every render
**C)** Runs before unmount or before effect re-runs
**D)** Never runs

**Answer:** C - Cleanup function prevents memory leaks

---

### Question 37: Prop Spreading

Is this type-safe?

```typescript
const Component: React.FC<Props> = (props) => {
    return <button {...props} onClick={handleClick} />;
};
```

**A)** Yes, always safe
**B)** No, could override onClick
**C)** Only if Props extends ButtonProps
**D)** Depends on implementation

**Answer:** B - Spreading props could override or conflict with other props

---

### Question 38: Type-Safe Event Handlers

What's the correct type?

```typescript
const handleClick: ??? = (event) => {
    console.log(event.currentTarget.value);
};

<input onClick={handleClick} />
```

**A)** React.MouseEventHandler
**B)** React.MouseEventHandler<HTMLInputElement>
**C)** React.ClickHandler
**D)** Function

**Answer:** B - Specify the element type for type safety

---

### Question 39: Strict Mode

What does React.StrictMode do?

```typescript
<React.StrictMode>
    <App />
</React.StrictMode>
```

**A)** Prevents re-renders
**B)** Highlights potential problems in development
**C)** Improves performance
**D)** Disables features

**Answer:** B - StrictMode helps identify bugs and deprecated features

---

### Question 40: Fragment vs div

Why use Fragment instead of div?

**A)** Fragment is faster
**B)** Fragment doesn't create DOM nodes
**C)** Fragment prevents styling
**D)** Fragment improves accessibility

**Answer:** B - Fragment avoids unnecessary DOM nodes

---

## Part 3: TypeScript & React (Questions 41-60)

### Question 41: Generic Component Props

What's the correct syntax?

```typescript
const List = <T,>({ items }: { items: T[] }) => (
    <ul>
        {items.map((item) => (
            <li key={???}>{item}</li>
        ))}
    </ul>
);
```

**A)** items as string
**B)** T as key
**C)** string(item)
**D)** Cannot use generics with lists

**Answer:** A - Use unique string keys (generics don't help with keys)

---

### Question 42: Conditional Types

What will be the type of value?

```typescript
type IsString<T> = T extends string ? string : number;
type Value = IsString<'hello'>; // ???
```

**A)** string
**B)** number
**C)** 'hello'
**D)** unknown

**Answer:** A - Since 'hello' extends string, type is string

---

### Question 43: Utility Types

What does Partial do?

```typescript
interface User {
    id: number;
    name: string;
    email: string;
}

type PartialUser = Partial<User>;
```

**A)** Makes all properties required
**B)** Makes all properties optional
**C)** Selects specific properties
**D)** Makes properties read-only

**Answer:** B - Partial makes all properties optional

---

### Question 44: Pick Utility Type

What does Pick do?

```typescript
type UserPreview = Pick<User, 'id' | 'name'>;
```

**A)** Removes those properties
**B)** Selects only those properties
**C)** Makes those optional
**D)** Renames properties

**Answer:** B - Pick selects specific properties from a type

---

### Question 45: Omit Utility Type

What does Omit do?

```typescript
type UserWithoutEmail = Omit<User, 'email'>;
```

**A)** Selects those properties
**B)** Removes those properties
**C)** Makes those optional
**D)** Requires those properties

**Answer:** B - Omit removes specified properties

---

### Question 46: Record Utility Type

What type is created?

```typescript
type Role = 'admin' | 'user' | 'guest';
type RolePermissions = Record<Role, string[]>;
```

**A)** A union type
**B)** An object with keys from Role and values of string[]
**C)** A function type
**D)** An array type

**Answer:** B - Record creates an object type with specified keys

---

### Question 47: Readonly Properties

What's the effect of readonly?

```typescript
interface User {
    readonly id: number;
    name: string;
}

const user: User = { id: 1, name: 'Alice' };
user.id = 2; // ???
```

**A)** Updates successfully
**B)** Throws error
**C)** TypeScript error
**D)** Creates a new object

**Answer:** C - TypeScript prevents assignment to readonly properties

---

### Question 48: Discriminated Unions

Which is a valid discriminated union?

```typescript
type Result =
    | { status: 'success'; data: unknown }
    | { status: 'error'; error: Error };
```

**A)** Yes, status discriminates the types
**B)** No, must use different names
**C)** Only with numbers
**D)** Not valid for React

**Answer:** A - Discriminated unions use a common property to narrow types

---

### Question 49: Type Guards

What's the purpose of a type guard?

```typescript
function isString(value: unknown): value is string {
    return typeof value === 'string';
}
```

**A)** Check if value is string
**B)** Narrow type in conditional blocks
**C)** Prevent type errors
**D)** All of above

**Answer:** D - Type guards check and narrow types

---

### Question 50: keyof Operator

What's the type of key?

```typescript
interface User {
    id: number;
    name: string;
}

const key: keyof User = ???
```

**A)** 'id' | 'name'
**B)** string
**C)** any
**D)** User

**Answer:** A - keyof creates a union of property names

---

### Question 51: typeof Operator

What's the type?

```typescript
const user = { id: 1, name: 'Alice' };
type UserType = typeof user;
```

**A)** { id: number; name: string }
**B)** User
**C)** object
**D)** typeof

**Answer:** A - typeof infers the type from a value

---

### Question 52: as const Assertion

What's the difference?

```typescript
// Without as const
const arr = [1, 2, 3]; // number[]

// With as const
const arr = [1, 2, 3] as const; // readonly [1, 2, 3]
```

**A)** No difference
**B)** as const makes it immutable and more specific
**C)** as const makes it faster
**D)** as const creates constant

**Answer:** B - as const narrows types and makes values readonly

---

### Question 53: Extending Interfaces

What's the result?

```typescript
interface Base {
    id: number;
}

interface Extended extends Base {
    name: string;
}

type Result = Extended; // ???
```

**A)** { name: string }
**B)** { id: number; name: string }
**C)** Base
**D)** Error

**Answer:** B - Extended inherits properties from Base

---

### Question 54: Interface Merging

Can interfaces with the same name merge?

```typescript
interface User {
    id: number;
}

interface User {
    name: string;
}

const user: User = ???
```

**A)** No, error
**B)** Yes, merges into { id: number; name: string }
**C)** Only in some cases
**D)** Cannot use merged interface

**Answer:** B - Interfaces with same name merge their properties

---

### Question 55: Type vs Interface

What's a key difference?

**A)** Types can't extend other types
**B)** Interfaces can't use unions
**C)** Types are more flexible with unions and tuples
**D)** Interfaces are better for everything

**Answer:** C - Types are more flexible for advanced type operations

---

### Question 56: Non-null Assertion

What does ! do?

```typescript
const element = document.getElementById('root')!;
```

**A)** Returns null if not found
**B)** Asserts to TypeScript that value is not null/undefined
**C)** Makes element required
**D)** Throws error

**Answer:** B - ! tells TypeScript to trust that value is not null

---

### Question 57: Optional Chaining

What will this return if user is null?

```typescript
const name = user?.name;
```

**A)** Error
**B)** undefined
**C)** null
**D)** Empty string

**Answer:** B - Optional chaining returns undefined if user is null

---

### Question 58: Nullish Coalescing

What's the difference from ||?

```typescript
const value = null ?? 'default'; // 'default'
const value2 = 0 || 'default'; // 'default'
```

**A)** No difference
**B)** ?? checks for null/undefined, || checks for falsy
**C)** ?? is deprecated
**D)** || is better

**Answer:** B - ?? only checks for null/undefined, while || checks any falsy value

---

### Question 59: Generic Constraints

What does this constraint do?

```typescript
function getValue<T extends { id: number }>(obj: T) {
    return obj.id;
}

getValue({ id: 1, name: 'Alice' }); // OK
getValue({ name: 'Bob' }); // Error
```

**A)** No constraint
**B)** T must have id: number property
**C)** T must be object
**D)** T must be comparable

**Answer:** B - Constraint ensures T has id property

---

### Question 60: infer Keyword

What does infer do?

```typescript
type GetReturnType<T> = T extends (...args: any[]) => infer R ? R : never;
type FnReturn = GetReturnType<() => string>; // string
```

**A)** Declares a variable
**B)** Infers a type from another type
**C)** Makes type optional
**D)** Extracts type parameter

**Answer:** B - infer captures and extracts a type from a pattern

---

## Part 4: State Management & Forms (Questions 61-80)

### Question 61: React Hook Form

What's the purpose of `register`?

```typescript
const { register } = useForm();
<input {...register('email')} />
```

**A)** Registers component for rendering
**B)** Connects input to form state without controlling it
**C)** Requires the input
**D)** Validates input

**Answer:** B - register connects uncontrolled inputs to form state

---

### Question 62: Form Validation

Which validation approach is better?

```typescript
// Option A: Client-side only
<input onChange={(e) => validate(e.target.value)} />

// Option B: Schema validation with Zod
const schema = z.object({ email: z.string().email() });
```

**A)** Option A
**B)** Option B
**C)** Both equally
**D)** Neither

**Answer:** B - Schema validation is more robust and reusable

---

### Question 63: Zod Schema

What does this schema do?

```typescript
const schema = z.object({
    email: z.string().email(),
    age: z.number().min(18),
});
```

**A)** Validates strings and numbers
**B)** Ensures email format and age >= 18
**C)** Creates a database schema
**D)** Validates at runtime

**Answer:** B - Zod schema validates email format and age constraint

---

### Question 64: Form Submission

Should you prevent default?

```typescript
const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle submission
};

<form onSubmit={handleSubmit}>
```

**A)** No, let form submit naturally
**B)** Yes, prevent page refresh
**C)** Only for validation
**D)** Depends on form type

**Answer:** B - preventDefault stops page refresh and lets you handle submission

---

### Question 65: Form Error Handling

How should errors be displayed?

```typescript
const { formState: { errors } } = useForm();

{errors.email && <span>{errors.email.message}</span>}
```

**A)** Show errors always
**B)** Show errors only if field was touched
**C)** Show after submission
**D)** All approaches work equally

**Answer:** B - Show errors only if field was touched to avoid spam

---

### Question 66: File Upload

How do you handle file input?

```typescript
const fileInput = React.useRef<HTMLInputElement>(null);

const handleFileSelect = () => {
    const file = fileInput.current?.files?.[0];
};

<input ref={fileInput} type="file" />
```

**A)** Use controlled input
**B)** Use ref since file inputs are always uncontrolled
**C)** Use onChange
**D)** File inputs can't be handled

**Answer:** B - File inputs cannot be controlled, must use refs

---

### Question 67: Dynamic Form Fields

Which approach is better?

```typescript
// Option A: Conditional rendering
{showEmail && <input />}

// Option B: Array of fields
fields.map(field => <input key={field.id} />)
```

**A)** Option A
**B)** Option B
**C)** Both equally
**D)** Neither works

**Answer:** B - Option B is better for truly dynamic fields

---

### Question 68: Form State Persistence

How should you persist form data?

```typescript
const [formData, setFormData] = React.useState(() => {
    return localStorage.getItem('form')
        ? JSON.parse(localStorage.getItem('form')!)
        : initialValues;
});
```

**A)** Always from localStorage
**B)** Load from localStorage on mount, save on change
**C)** Only save when submitting
**D)** Never persist

**Answer:** B - Load on mount, save on change for good UX

---

### Question 69: Multi-step Forms

How should you handle state?

**A)** Reset state on each step
**B)** Keep state across steps in parent or context
**C)** Use multiple useState hooks
**D)** Use URL params only

**Answer:** B - Keep state in parent/context to preserve data across steps

---

### Question 70: Auto-save Pattern

How should auto-save be implemented?

```typescript
React.useEffect(() => {
    const timer = setTimeout(() => {
        saveForm(formData);
    }, 500); // Debounce

    return () => clearTimeout(timer);
}, [formData]);
```

**A)** Save on every change
**B)** Save only on submit
**C)** Debounce to avoid excessive saves
**D)** Never auto-save

**Answer:** C - Debounce to balance responsiveness and performance

---

## Part 5: Performance & Optimization (Questions 71-90)

### Question 71: Bundle Size

What's a good target for initial bundle?

**A)** As small as possible
**B)** Under 50KB (gzipped)
**C)** Under 100KB (gzipped)
**D)** No limit

**Answer:** C - Under 100KB gzipped is a reasonable target

---

### Question 72: Code Splitting

How should routes be split?

```typescript
const Home = React.lazy(() => import('./pages/Home'));
const Dashboard = React.lazy(() => import('./pages/Dashboard'));
```

**A)** Split at route level for faster initial load
**B)** Don't split
**C)** Split all components
**D)** Split only if over 100KB

**Answer:** A - Route-level splitting provides best UX

---

### Question 73: Image Optimization

What's srcSet for?

```typescript
<img
    srcSet="small.jpg 480w, large.jpg 1200w"
    sizes="(max-width: 480px) 100vw, 1200px"
    src="large.jpg"
/>
```

**A)** Multiple image sources
**B)** Load appropriate image size for device
**C)** Improve accessibility
**D)** Cache images

**Answer:** B - srcSet loads appropriate image size based on viewport

---

### Question 74: Virtual Scrolling

When should you use virtual scrolling?

**A)** Always for lists
**B)** For lists with 1000+ items
**C)** Only for performance-critical apps
**D)** Never, it's too complex

**Answer:** B - Virtual scrolling helps with large lists (1000+ items)

---

### Question 75: React Profiler

What does the Profiler measure?

**A)** Memory usage
**B)** Render duration
**C)** Component mount time
**D)** Network requests

**Answer:** B - Profiler measures how long renders take

---

### Question 76: Web Vitals

What are Core Web Vitals?

**A)** Performance metrics
**B)** LCP, FID, CLS
**C)** Important for SEO
**D)** All of above

**Answer:** D - Core Web Vitals are metrics important for SEO and UX

---

### Question 77: Lazy Loading

What lazy loads?

```typescript
<img src="image.jpg" loading="lazy" />
```

**A)** Images load on scroll into view
**B)** Images load immediately
**C)** Images never load
**D)** Images load in background

**Answer:** A - lazy loading defers loading until needed

---

### Question 78: Tree Shaking

What should you do for tree shaking?

```typescript
// ❌ Bad
import * as utils from './utils';

// ✅ Good
import { getValue } from './utils';
```

**A)** No difference
**B)** Named imports allow tree shaking
**C)** Wildcard imports are better
**D)** Tree shaking doesn't matter

**Answer:** B - Named imports allow unused code to be removed

---

### Question 79: Memoization Cost

Is memoization always beneficial?

**A)** Always use it
**B)** Memoization has overhead, use when needed
**C)** Never use it
**D)** Only for large components

**Answer:** B - Memoization adds overhead, only use when necessary

---

### Question 80: Performance Monitoring

How should you monitor performance?

```typescript
import { getCLS, getFID, getLCP } from 'web-vitals';

getCLS(console.log);
getFID(console.log);
getLCP(console.log);
```

**A)** Manually with performance.mark
**B)** Using web-vitals library
**C)** Using browser DevTools only
**D)** No monitoring needed

**Answer:** B - web-vitals library provides standard metrics

---

## Part 6: Testing (Questions 81-100)

### Question 81: Unit Testing

What should unit tests cover?

**A)** Every line of code
**B)** Critical business logic
**C)** All edge cases
**D)** Implementation details

**Answer:** B - Focus on critical logic, not implementation details

---

### Question 82: Testing Library Query

Which query is best for accessibility?

```typescript
// Option A
screen.getByRole('button', { name: /submit/i })

// Option B
screen.getByTestId('submit-btn')
```

**A)** Option A is more accessible
**B)** Option B is more accessible
**C)** Both equally accessible
**D)** Neither

**Answer:** A - Querying by role encourages accessible components

---

### Question 83: Mocking

What should you mock?

**A)** Everything
**B)** Only external dependencies (API, libraries)
**C)** Nothing
**D)** Always mock components

**Answer:** B - Mock external dependencies, test actual components

---

### Question 84: Async Testing

How do you test async code?

```typescript
it('should load data', async () => {
    render(<UserProfile />);
    const name = await screen.findByText('John');
    expect(name).toBeInTheDocument();
});
```

**A)** Use await with findBy
**B)** Use getBy immediately
**C)** Use setTimeout
**D)** Cannot test async

**Answer:** A - Use findBy or waitFor for async operations

---

### Question 85: Snapshot Testing

When should you use snapshots?

**A)** For every component
**B)** For complex output that rarely changes
**C)** Never, they're unreliable
**D)** Only for styles

**Answer:** B - Snapshots are useful for complex, stable output

---

### Question 86: E2E Testing

What should E2E tests cover?

**A)** Implementation details
**B)** User workflows and scenarios
**C)** All code paths
**D)** Internal state

**Answer:** B - E2E tests should cover real user workflows

---

### Question 87: Test Coverage

What's good test coverage?

**A)** 100% always
**B)** 80%+ for critical code
**C)** 50% is sufficient
**D)** Coverage doesn't matter

**Answer:** B - Aim for 80%+ coverage of critical business logic

---

### Question 88: Integration Testing

What do integration tests verify?

**A)** Single function behavior
**B)** Components working together
**C)** External APIs
**D)** User interactions

**Answer:** B - Integration tests verify components work together

---

### Question 89: Test Utilities

Should you create custom render?

```typescript
const customRender = (ui, { theme = 'light' } = {}) =>
    render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);
```

**A)** No, use standard render
**B)** Yes, for providers and wrappers
**C)** Only for complex apps
**D)** Never needed

**Answer:** B - Custom render helps reduce boilerplate with providers

---

### Question 90: Mocking Fetch

How should you mock fetch?

```typescript
vi.mock('fetch', () => ({
    default: vi.fn(),
}));
```

**A)** Mock global fetch
**B)** Mock HTTP client library
**C)** Use msw (Mock Service Worker)
**D)** All approaches work

**Answer:** C - msw is better for mocking APIs in tests

---

## Part 7: Advanced Topics (Questions 91-143)

### Question 91: Render Optimization

How many times does child render?

```typescript
const Parent: React.FC = () => {
    const [count, setCount] = React.useState(0);
    const handleClick = () => setCount(count + 1);

    return (
        <>
            <Child onClick={handleClick} />
            <button onClick={() => setCount(count + 1)}>Inc</button>
        </>
    );
};

const Child = React.memo(({ onClick }: any) => {
    console.log('Child rendered');
    return <button onClick={onClick}>Click child</button>;
});
```

**A)** Never, it's memoized
**B)** Every time parent renders
**C)** Only when onClick prop changes
**D)** Question is incomplete

**Answer:** B - handleClick is new function each render, breaking memo

---

### Question 92: useCallback Dependency

What's wrong?

```typescript
const handleClick = React.useCallback(() => {
    setCount(count + 1);
}, []); // Empty dependency
```

**A)** Nothing wrong
**B)** count is missing from dependencies
**C)** Should use useEffect instead
**D)** Empty array is required

**Answer:** B - count should be in dependencies, or use previous state pattern

---

### Question 93: StrictMode Double Render

Why does StrictMode render twice?

**A)** Bug in React
**B)** To catch side effects that shouldn't exist
**C)** To test performance
**D)** Always happens in production

**Answer:** B - Double renders help identify side effects in development

---

### Question 94: Batching Updates

When are updates batched?

```typescript
const handleClick = () => {
    setCount(count + 1);
    setName('Alice');
    // Batched: one re-render for both
};
```

**A)** Never
**B)** In event handlers and effects
**C)** Only setTimeout
**D)** Only promises

**Answer:** B - React 18 batches updates in event handlers and effects

---

### Question 95: Transitions

What do transitions do?

```typescript
const [isPending, startTransition] = React.useTransition();
startTransition(() => setResults(filtered));
```

**A)** Animate component changes
**B)** Defer updates to unblock urgent ones
**C)** Create animation effects
**D)** Transition between routes

**Answer:** B - Transitions defer non-urgent updates

---

### Question 96: Suspense for Data

How should Suspense be used?

```typescript
<Suspense fallback={<Spinner />}>
    <UserProfile userId={id} />
</Suspense>
```

**A)** For async component rendering
**B)** For showing spinners
**C)** Component throws promise during loading
**D)** For data fetching with proper integration

**Answer:** C - Component suspends (throws promise) during async operations

---

### Question 97: Error Boundary with Suspense

How do they work together?

```typescript
<ErrorBoundary>
    <Suspense fallback={<Spinner />}>
        <Component />
    </Suspense>
</ErrorBoundary>
```

**A)** No interaction
**B)** Suspense shows fallback, ErrorBoundary catches errors
**C)** ErrorBoundary shows spinner
**D)** They conflict

**Answer:** B - Suspense for loading, ErrorBoundary for errors

---

### Question 98: Portal

When should you use Portal?

```typescript
ReactDOM.createPortal(<Modal />, document.body);
```

**A)** For all dialogs
**B)** To render outside DOM hierarchy
**C)** For modals and dropdowns to escape parent styling
**D)** Only for performance

**Answer:** C - Portals escape parent styling and stacking context

---

### Question 99: useId Hook

What does useId generate?

```typescript
const id = React.useId();
<input id={id} />
<label htmlFor={id}>Label</label>
```

**A)** Random ID each render
**B)** Unique stable ID for accessibility
**C)** Sequential ID
**D)** UUID

**Answer:** B - useId generates unique, stable IDs for accessibility

---

### Question 100: useSyncExternalStore

When would you use it?

**A)** For state management libraries
**B)** Never, use Context API
**C)** For subscribing to external stores
**D)** For local storage

**Answer:** C - For libraries that need to subscribe to external state

---

### Question 101: Forwarding Refs

What does ref forwarding enable?

```typescript
const Input = React.forwardRef<HTMLInputElement, Props>((props, ref) => (
    <input ref={ref} />
));

const inputRef = React.useRef<HTMLInputElement>(null);
<Input ref={inputRef} />
// Now can do: inputRef.current?.focus()
```

**A)** Pass refs through components
**B)** Expose DOM elements to parents
**C)** Create uncontrolled components
**D)** All of above

**Answer:** D - Forwarding refs allows parent to access child DOM

---

### Question 102: Controlled Components Best Practice

Should all forms be controlled?

**A)** Yes, always
**B)** No, uncontrolled is better
**C)** Controlled for validation, uncontrolled for simple forms
**D)** Doesn't matter

**Answer:** C - Choose based on complexity

---

### Question 103: Composition vs HOCs

Why prefer composition?

```typescript
// Composition (preferred)
<Wrapper><Component /></Wrapper>

// HOC
const Enhanced = withFeature(Component);
```

**A)** Easier to understand
**B)** Avoids wrapper hell
**C)** Better for TypeScript
**D)** All of above

**Answer:** D - Composition is more flexible and type-safe

---

### Question 104: Context Performance

How should you optimize context?

**A)** Never use context
**B)** Split contexts by frequency of change
**C)** Memoize consumers
**D)** Use selectors

**Answer:** B - Split contexts to prevent unnecessary re-renders

---

### Question 105: Render Props

When is render props better than HOC?

```typescript
<DataFetcher render={(data) => <Component data={data} />} />
```

**A)** Always
**B)** Never
**C)** For more flexibility and fewer naming issues
**D)** Only for simple cases

**Answer:** C - Render props provide flexibility without wrapper names

---

### Question 106: Custom Hook Data Fetching

Should hooks do data fetching?

```typescript
const useUser = (id: string) => {
    const [user, setUser] = React.useState(null);
    React.useEffect(() => {
        fetch(`/api/users/${id}`).then(r => r.json()).then(setUser);
    }, [id]);
    return user;
};
```

**A)** Yes, this is recommended
**B)** No, use effects instead
**C)** Only for simple fetching
**D)** Avoid side effects in hooks

**Answer:** A - Custom hooks are good for encapsulating fetch logic

---

### Question 107: Infinite Loop Prevention

What causes infinite loops?

```typescript
React.useEffect(() => {
    setState(data.map(item => item)); // Creates new array each time
}, [data]); // data changed, triggers effect, creates new array
```

**A)** setState in effect
**B)** Data changing triggers effect
**C)** New object in dependency
**D)** Effect without cleanup

**Answer:** C - New objects in dependencies cause infinite loops

---

### Question 108: Memory Leaks

How do you prevent memory leaks?

```typescript
React.useEffect(() => {
    const subscription = subscribe();
    return () => subscription.unsubscribe(); // Cleanup
}, []);
```

**A)** Just unsubscribe
**B)** Use cleanup function in useEffect
**C)** Always return null
**D)** Use useCallback

**Answer:** B - Cleanup functions prevent memory leaks

---

### Question 109: Event Handler Memory

What's the issue here?

```typescript
const items.map(item => (
    <button onClick={() => handleClick(item.id)} />
))
```

**A)** No issue
**B)** Creates new function each render
**C)** Not a memory leak
**D)** Both A and C

**Answer:** B - Each render creates new function, breaking memo

---

### Question 110: Component Lazy Loading

How should you lazy load components?

```typescript
const Component = React.lazy(() => import('./Component'));
```

**A)** Always lazy load
**B)** Lazy load routes and heavy components
**C)** Never lazy load
**D)** Only lazy load async components

**Answer:** B - Lazy load route components and heavy features

---

### Question 111: Bundle Analysis

How should you analyze bundle?

**A)** Guess what's large
**B)** Use source-map-explorer or webpack-bundle-analyzer
**C)** Don't analyze
**D)** Analyze after every build

**Answer:** B - Use tools to identify what's taking space

---

### Question 112: Internationalization

How should you handle i18n?

```typescript
<I18nProvider language={language}>
    <App />
</I18nProvider>
```

**A)** Build strings directly
**B)** Use i18n library with context
**C)** Use URL params
**D)** Not necessary

**Answer:** B - i18n libraries with context are standard

---

### Question 113: Accessibility Keys

Should you always use tab index?

**A)** Yes, always
**B)** Only when necessary
**C)** Never use tabindex
**D)** Only for divs

**Answer:** B - Use semantic HTML first, tabindex only when needed

---

### Question 114: Dark Mode Implementation

How should dark mode work?

```typescript
<ThemeProvider theme={theme}>
    <App />
</ThemeProvider>
```

**A)** Hard-code in CSS
**B)** Use Context Provider
**C)** Save to localStorage
**D)** B and C

**Answer:** D - Use context and persist to localStorage

---

### Question 115: Theme Switching

How should switching work instantly?

```typescript
const setTheme = (newTheme: string) => {
    setThemeState(newTheme);
    localStorage.setItem('theme', newTheme);
    document.documentElement.dataset.theme = newTheme;
};
```

**A)** Update state only
**B)** Update state and localStorage
**C)** Update state, localStorage, and DOM
**D)** Update DOM only

**Answer:** C - Instant switch with DOM update, persist with localStorage

---

### Question 116: Responsive Components

How should responsiveness work?

**A)** Media queries in CSS
**B)** Custom hook for window size
**C)** React window plugin
**D)** All approaches valid

**Answer:** D - Choose based on needs

---

### Question 117: Animations in React

What should you use?

**A)** JavaScript animations only
**B)** CSS animations with React state
**C)** Framer Motion or similar
**D)** All valid

**Answer:** D - Choose based on complexity

---

### Question 118: Form Library Integration

Should you use React Hook Form?

**A)** Yes, always
**B)** For complex forms
**C)** Only with validation
**D)** Never

**Answer:** B - For complex forms with validation

---

### Question 119: State Persistence

Where should you persist state?

**A)** localStorage
**B)** sessionStorage
**C)** URL params
**D)** Based on requirements

**Answer:** D - Choose based on use case

---

### Question 120: Optimistic Updates

How should you handle optimistic updates?

```typescript
setLocalState(newValue); // Update immediately
updateServer(newValue); // Update server
```

**A)** Update server first
**B)** Update local state then server
**C)** Show loading then update
**D)** Don't use optimistic

**Answer:** B - Show update immediately, sync with server

---

### Question 121: Debouncing vs Throttling

What's the difference?

**A)** No difference
**B)** Debouncing waits for pause, throttling limits frequency
**C)** Throttling is better
**D)** Debouncing is better

**Answer:** B - Different use cases

---

### Question 122: Search Debouncing

How should search be debounced?

```typescript
const [query, setQuery] = React.useState('');
const debouncedSearch = useDebounce(query, 300);
```

**A)** Search on every keystroke
**B)** Debounce before making request
**C)** Throttle requests
**D)** No debouncing

**Answer:** B - Debounce to avoid excessive API calls

---

### Question 123: List Virtualization Libraries

What's a good choice?

**A)** react-window
**B)** @tanstack/react-virtual
**C)** Your own implementation
**D)** A or B

**Answer:** D - Both are solid choices

---

### Question 124: Drag and Drop

What library should you use?

**A)** React DnD
**B)** react-beautiful-dnd
**C)** HTML5 Drag and Drop
**D)** Based on requirements

**Answer:** D - Choose based on complexity

---

### Question 125: Animation Libraries

What's recommended?

**A)** Framer Motion
**B)** React Spring
**C)** CSS Animations
**D)** Based on needs

**Answer:** D - Choose based on animation complexity

---

### Question 126: Tooltip Implementation

How should tooltips be implemented?

**A)** Simple CSS visibility
**B)** Popper.js with React
**C)** Portal with positioning
**D)** Libraries like headlessui

**Answer:** D - Use well-tested libraries

---

### Question 127: Menu Implementation

How should dropdowns work?

**A)** Simple conditional render
**B)** useRef to track clicks
**C)** Popover library
**D)** All valid

**Answer:** C - Use tested popover/dropdown library

---

### Question 128: Date Handling

What library should you use?

**A)** moment.js
**B)** date-fns
**C)** dayjs
**D)** All are valid

**Answer:** D - All are good choices

---

### Question 129: Currency Formatting

How should currency format?

```typescript
new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(100);
```

**A)** String concatenation
**B)** Intl API
**C)** Custom function
**D)** Library

**Answer:** B - Use Intl API or library

---

### Question 130: Internationalization

Should text be hardcoded?

**A)** Yes
**B)** No, use i18n
**C)** Only for English
**D)** Not necessary

**Answer:** B - Always use i18n for maintainability

---

### Question 131: Testing Async Components

How should you test async?

```typescript
it('loads user', async () => {
    render(<User />);
    await screen.findByText('John');
});
```

**A)** Use async/await
**B)** Use waitFor
**C)** Use findBy
**D)** All valid

**Answer:** D - All valid approaches

---

### Question 132: Mocking Libraries

What should you mock?

**A)** API calls
**B)** External libraries
**C)** Third-party services
**D)** All of above

**Answer:** D - Mock external dependencies

---

### Question 133: API Integration

How should API be integrated?

**A)** Direct fetch in components
**B)** Custom hooks
**C)** API client library
**D)** B or C

**Answer:** D - Use hooks or client library

---

### Question 134: Error Recovery

How should errors be handled?

```typescript
catch (error) {
    // Retry or show error
    showError(error.message);
}
```

**A)** Show error message
**B)** Retry automatically
**C)** Show error and allow retry
**D)** Silently fail

**Answer:** C - Show error and allow user to retry

---

### Question 135: Loading States

How should loading be handled?

**A)** Show spinner
**B)** Skeleton screens
**C)** Disable buttons
**D)** All valid

**Answer:** D - Different UX for different contexts

---

### Question 136: Pagination

How should pagination work?

**A)** Load all data
**B)** Cursor-based pagination
**C)** Offset pagination
**D)** Virtual scrolling

**Answer:** D or B - Based on data size and UX

---

### Question 137: Filtering

How should filters work?

**A)** Client-side filter
**B)** Server-side filter
**C)** Based on requirements
**D)** Always server-side

**Answer:** C - Choose based on data size

---

### Question 138: Sorting

How should sorting work?

**A)** Alphabetical only
**B)** Multiple sort columns
**C)** Server-side when possible
**D)** Always client-side

**Answer:** C - Server-side for large datasets

---

### Question 139: Search Implementation

How should search work?

**A)** Client-side filtering
**B)** Server search endpoint
**C)** Full-text search
**D)** Based on data size

**Answer:** D - Choose based on requirements

---

### Question 140: Real-time Updates

How should real-time work?

**A)** WebSocket
**B)** Server-sent events
**C)** Polling
**D)** Based on requirements

**Answer:** D - Choose technology based on needs

---

### Question 141: Offline Support

How should offline work?

**A)** Prevent usage offline
**B)** Service workers for caching
**C)** Queue updates for sync
**D)** B and C

**Answer:** D - Cache and queue for offline support

---

### Question 142: Authentication

How should auth flow work?

```typescript
<ProtectedRoute>
    <Dashboard />
</ProtectedRoute>
```

**A)** Hardcode checks
**B)** Auth provider with context
**C)** Protected route wrapper
**D)** B and C

**Answer:** D - Use provider and route protection

---

### Question 143: Authorization

How should permissions work?

```typescript
{hasPermission('admin') && <AdminPanel />}
```

**A)** Check on frontend only
**B)** Check on backend
**C)** Check on both
**D)** Never check permissions

**Answer:** C - Always verify on backend, hide UI on frontend

---

## Quiz Summary

**Total Questions:** 143
**Difficulty Levels:** Beginner, Intermediate, Advanced
**Topics Covered:**
- React Fundamentals (20 questions)
- Advanced React (20 questions)
- TypeScript & React (20 questions)
- State Management & Forms (20 questions)
- Performance & Optimization (20 questions)
- Testing (20 questions)
- Advanced Topics (43 questions)

**Recommended Study Approach:**
1. Take quiz without looking at answers
2. Review answers and explanations
3. Focus on areas where you scored poorly
4. Retake quiz after reviewing weak areas
5. Aim for 80%+ score

**Suggested Study Time:** 8-10 hours
**Refresh Interval:** Review every 2 weeks

**Last Updated:** October 26, 2024
**Level:** Intermediate to Advanced
