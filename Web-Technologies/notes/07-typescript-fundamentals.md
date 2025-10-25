# TypeScript Fundamentals & Advanced Types

## Part 1: Basic Types

```typescript
// Primitive types
const num: number = 42;
const str: string = "Hello";
const bool: boolean = true;
const sym: symbol = Symbol('id');
const big: bigint = 100n;

// Arrays
const numbers: number[] = [1, 2, 3];
const strings: Array<string> = ["a", "b"];
const mixed: (number | string)[] = [1, "two", 3];
const tuple: [string, number] = ["age", 30];
const readonly_arr: readonly number[] = [1, 2];

// Any & Unknown
let anything: any = "can be anything";  // Avoid!
let something: unknown = "could be anything";
if (typeof something === 'string') {
    let str: string = something;  // Type narrowing
}

// Never & Void
function throwError(): never {
    throw new Error("Error!");
}

function log(): void {
    console.log("Logged");
}

// Union types
let id: string | number = "123";
id = 456;  // Valid

// Literal types
let direction: "up" | "down" | "left" | "right" = "up";
let statusCode: 200 | 404 | 500 = 200;

// Type aliases
type User = {
    name: string;
    age: number;
    email?: string;  // Optional
};

const user: User = {
    name: "John",
    age: 30
};
```

## Part 2: Interfaces & Classes

```typescript
// Interfaces
interface Animal {
    name: string;
    age: number;
    speak(): string;
}

interface Flyable {
    fly(): void;
}

// Implementing interfaces
class Dog implements Animal, Flyable {
    name: string;
    age: number;

    constructor(name: string, age: number) {
        this.name = name;
        this.age = age;
    }

    speak(): string {
        return `${this.name} barks`;
    }

    fly(): void {
        // Not realistic but shows implementation
    }
}

// Class members
class Person {
    // Public (default)
    public firstName: string;

    // Private
    private email: string;

    // Protected
    protected phoneNumber: string;

    // Readonly
    readonly id: number;

    constructor(firstName: string, email: string) {
        this.firstName = firstName;
        this.email = email;
        this.phoneNumber = "";
        this.id = Math.random();
    }

    // Getter
    get fullEmail(): string {
        return this.email;
    }

    // Setter
    set fullEmail(email: string) {
        this.email = email;
    }

    // Static
    static species = "Homo sapiens";
    static isAdult(age: number): boolean {
        return age >= 18;
    }
}

// Abstract classes
abstract class Shape {
    abstract getArea(): number;

    displayArea(): void {
        console.log(`Area: ${this.getArea()}`);
    }
}

class Circle extends Shape {
    constructor(public radius: number) {
        super();
    }

    getArea(): number {
        return Math.PI * this.radius ** 2;
    }
}
```

## Part 3: Advanced Types

```typescript
// Generics
function identity<T>(arg: T): T {
    return arg;
}

identity<string>("hello");
identity(42);  // Type inference

// Generic constraints
function maxLength<T extends { length: number }>(obj: T): T {
    if (obj.length > 10) {
        console.log(`Long: ${obj.length}`);
    }
    return obj;
}

// Generic classes
class Container<T> {
    value: T;

    constructor(value: T) {
        this.value = value;
    }

    getValue(): T {
        return this.value;
    }
}

const stringContainer = new Container<string>("hello");

// Generic interfaces
interface Repository<T> {
    getAll(): T[];
    getById(id: number): T | undefined;
    save(item: T): void;
}

class UserRepository implements Repository<User> {
    private users: User[] = [];

    getAll(): User[] {
        return this.users;
    }

    getById(id: number): User | undefined {
        return this.users.find((u, i) => i === id);
    }

    save(item: User): void {
        this.users.push(item);
    }
}

// Conditional types
type IsString<T> = T extends string ? true : false;
type A = IsString<"hello">;  // true
type B = IsString<number>;   // false

// Mapped types
type Readonly<T> = {
    readonly [K in keyof T]: T[K];
};

type Optional<T> = {
    [K in keyof T]?: T[K];
};

type Getters<T> = {
    [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

// Pick & Omit
type UserPreview = Pick<User, "name" | "age">;
type UserWithoutEmail = Omit<User, "email">;

// Record
type Color = "red" | "green" | "blue";
type ColorCode = Record<Color, string>;
const colorMap: ColorCode = {
    red: "#ff0000",
    green: "#00ff00",
    blue: "#0000ff"
};

// Type predicates
function isString(value: unknown): value is string {
    return typeof value === 'string';
}

function process(value: string | number) {
    if (isString(value)) {
        value.toUpperCase();  // Narrowed to string
    }
}

// Discriminated unions
type Success = {
    status: "success";
    data: User;
};

type Error = {
    status: "error";
    error: string;
};

type Result = Success | Error;

function handleResult(result: Result) {
    if (result.status === "success") {
        console.log(result.data.name);
    } else {
        console.log(result.error);
    }
}
```

## Part 4: Utility Types

```typescript
// Partial<T> - make all properties optional
type PartialUser = Partial<User>;

// Required<T> - make all properties required
type RequiredUser = Required<User>;

// Readonly<T> - make all properties readonly
type ReadonlyUser = Readonly<User>;

// Record<K, T> - object with specific keys
type Scores = Record<"math" | "english" | "science", number>;

// Pick<T, K> - select subset of properties
type UserPreview = Pick<User, "name" | "age">;

// Omit<T, K> - exclude properties
type UserWithoutEmail = Omit<User, "email">;

// Exclude<T, U> - remove types from union
type NonStringTypes = Exclude<string | number | boolean, string>;

// Extract<T, U> - select types from union
type StringOrNumber = Extract<string | number | boolean, string | number>;

// NonNullable<T> - remove null and undefined
type ValidUser = NonNullable<User | null | undefined>;

// ReturnType<T> - get function return type
type UserResult = ReturnType<() => User>;

// Parameters<T> - get function parameters as tuple
type MyFnParams = Parameters<(a: string, b: number) => void>;

// InstanceType<T> - get instance type of constructor
type UserInstance = InstanceType<typeof User>;
```

## Part 5: Decorators & Advanced Patterns

```typescript
// Enable decorators in tsconfig.json:
// "experimentalDecorators": true

// Class decorator
function WithLogging(constructor: Function) {
    return class extends constructor {
        constructor(...args: any[]) {
            super(...args);
            console.log(`Creating instance of ${constructor.name}`);
        }
    };
}

@WithLogging
class User {
    name: string;
    constructor(name: string) {
        this.name = name;
    }
}

// Method decorator
function Log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = function(...args: any[]) {
        console.log(`Calling ${propertyKey} with`, args);
        return originalMethod.apply(this, args);
    };

    return descriptor;
}

class Service {
    @Log
    getData(id: number) {
        return { id, data: "data" };
    }
}

// Property decorator
function MinLength(length: number) {
    return function(target: any, propertyKey: string) {
        let value: string;

        const getter = () => value;
        const setter = (newValue: string) => {
            if (newValue.length < length) {
                throw new Error(`${propertyKey} must be at least ${length} chars`);
            }
            value = newValue;
        };

        Object.defineProperty(target, propertyKey, {
            get: getter,
            set: setter,
            enumerable: true
        });
    };
}

class ValidatedUser {
    @MinLength(3)
    name: string = "";
}

// Mixin pattern
function Activatable<TBase extends { new(...args: any[]): {} }>(
    Base: TBase
) {
    return class extends Base {
        isActive = false;

        activate() {
            this.isActive = true;
        }

        deactivate() {
            this.isActive = false;
        }
    };
}

class User {}
class ActivatableUser extends Activatable(User) {}
```

## Part 6: Type Safety Patterns

```typescript
// Strict null checks - prevents null/undefined errors
// Enable in tsconfig: "strictNullChecks": true

let value: string | null = null;
// value.toUpperCase();  // Error!

if (value !== null) {
    value.toUpperCase();  // OK
}

// Optional chaining
const user: User | null = null;
user?.name;           // undefined instead of error
user?.speak?.();      // Safe function call

// Nullish coalescing
const name = user?.name ?? "Unknown";

// Type assertion (use sparingly)
const str = value as string;  // Force type
const str2 = <string>value;   // Alternative syntax

// const assertion
const config = { readonly: true } as const;  // Literal type
type Config = typeof config;  // { readonly: true }

// Exhaustiveness checking
type Status = "pending" | "completed" | "failed";

function handleStatus(status: Status): string {
    switch (status) {
        case "pending":
            return "Waiting...";
        case "completed":
            return "Done!";
        case "failed":
            return "Error!";
        default:
            const _exhaustive: never = status;
            return _exhaustive;
    }
}

// String literal types for safety
type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";

function apiCall(method: HttpMethod, url: string) {
    // Only accepts valid HTTP methods
}

// Branded types
type UserId = string & { readonly __brand: unique symbol };

function createUserId(id: string): UserId {
    return id as UserId;
}

// Only accepts UserId, not regular string
function getUser(id: UserId) {
    // Implementation
}
```

---

## Key Takeaways

1. **Types catch errors** at compile time
2. **Generics enable reusable** type-safe code
3. **Interfaces define contracts** for objects
4. **Utility types reduce** boilerplate
5. **Type guards enable type narrowing**
6. **Discriminated unions** are safer than regular unions
7. **Strict mode catches more errors**
8. **TypeScript improves code documentation**

---

**Last Updated:** October 25, 2024
**Level:** Expert
**Topics Covered:** 50+ TypeScript concepts, 80+ code examples
