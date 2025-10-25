# TypeScript Advanced & Patterns

## Part 1: Complex Type Operations

```typescript
// typeof operator for types
const user = { name: "John", age: 30 };
type User = typeof user;  // { name: string; age: number; }

// keyof operator
type UserKeys = keyof User;  // "name" | "age"

function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
}

const name = getProperty(user, "name");  // Type safe!

// Indexed access types
type Name = User["name"];  // string
type AllValues = User[keyof User];  // string | number

// Template literal types
type EventType = `on${Capitalize<"click">}`;  // "onClick"

type Getters<T> = {
    [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

type UserGetters = Getters<User>;
// {
//     getName: () => string;
//     getAge: () => number;
// }

// Recursive types
type Json =
    | null
    | boolean
    | number
    | string
    | Json[]
    | { [key: string]: Json };

const data: Json = {
    name: "John",
    nested: {
        value: 123
    },
    array: [1, "two", { three: 3 }]
};

// Distributive conditional types
type Flatten<T> = T extends Array<infer U> ? U : T;

type A = Flatten<string[]>;  // string
type B = Flatten<string>;     // string

// Infer keyword
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

type MyFunc = (a: string) => number;
type MyReturn = ReturnType<MyFunc>;  // number

// Promise unwrapping
type Unwrap<T> = T extends Promise<infer U> ? U : T;

type PromiseString = Promise<string>;
type UnwrappedString = Unwrap<PromiseString>;  // string
```

## Part 2: Advanced Patterns

```typescript
// Builder pattern with types
class UserBuilder {
    private data: Partial<User> = {};

    setName(name: string): this {
        this.data.name = name;
        return this;
    }

    setAge(age: number): this {
        this.data.age = age;
        return this;
    }

    build(): User {
        if (!this.data.name || !this.data.age) {
            throw new Error("Name and age are required");
        }
        return this.data as User;
    }
}

const user = new UserBuilder()
    .setName("John")
    .setAge(30)
    .build();

// Proxy pattern
function createProxy<T extends object>(target: T): T {
    return new Proxy(target, {
        get(target, prop) {
            console.log(`Accessing ${String(prop)}`);
            return target[prop as keyof T];
        },
        set(target, prop, value) {
            console.log(`Setting ${String(prop)} = ${value}`);
            target[prop as keyof T] = value;
            return true;
        }
    });
}

// Observer pattern
interface Observer<T> {
    update(data: T): void;
}

class Subject<T> {
    private observers: Set<Observer<T>> = new Set();

    subscribe(observer: Observer<T>): () => void {
        this.observers.add(observer);
        return () => this.observers.delete(observer);
    }

    notify(data: T): void {
        this.observers.forEach(obs => obs.update(data));
    }
}

// Dependency injection
class Container {
    private services: Map<string, any> = new Map();

    register<T>(key: string, factory: () => T): void {
        this.services.set(key, factory);
    }

    resolve<T>(key: string): T {
        const factory = this.services.get(key);
        if (!factory) throw new Error(`Service ${key} not found`);
        return factory();
    }
}

const container = new Container();
container.register("userService", () => new UserRepository());
const userRepo = container.resolve<UserRepository>("userService");
```

## Part 3: Async & Promise Types

```typescript
// Promise wrapping
async function fetchUser(id: number): Promise<User> {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) throw new Error("Failed to fetch");
    return response.json();
}

// Multiple async operations
async function getMultipleUsers(ids: number[]): Promise<User[]> {
    const promises = ids.map(id => fetchUser(id));
    return Promise.all(promises);
}

// Async iterables
async function* asyncGenerator() {
    yield 1;
    yield 2;
    yield 3;
}

for await (const value of asyncGenerator()) {
    console.log(value);
}

// Retry logic with types
async function retry<T>(
    fn: () => Promise<T>,
    maxAttempts: number = 3
): Promise<T> {
    for (let i = 0; i < maxAttempts; i++) {
        try {
            return await fn();
        } catch (error) {
            if (i === maxAttempts - 1) throw error;
            console.log(`Retry attempt ${i + 1}`);
        }
    }
    throw new Error("Max retries exceeded");
}

// Usage
const user = await retry(() => fetchUser(1), 3);

// Result type (either success or error)
type Result<T, E> = { success: true; value: T } | { success: false; error: E };

async function fetchUserSafe(id: number): Promise<Result<User, Error>> {
    try {
        const user = await fetchUser(id);
        return { success: true, value: user };
    } catch (error) {
        return { success: false, error: error as Error };
    }
}

const result = await fetchUserSafe(1);
if (result.success) {
    console.log(result.value.name);
} else {
    console.log(result.error.message);
}
```

## Part 4: Functional Programming Patterns

```typescript
// Higher-order functions
function compose<T1, T2, T3>(
    f1: (x: T1) => T2,
    f2: (x: T2) => T3
): (x: T1) => T3 {
    return (x) => f2(f1(x));
}

const square = (x: number) => x * x;
const double = (x: number) => x * 2;
const composed = compose(square, double);
composed(5);  // 50

// Currying with types
function curry<A, B, R>(
    fn: (a: A, b: B) => R
): (a: A) => (b: B) => R {
    return (a) => (b) => fn(a, b);
}

const add = (a: number, b: number) => a + b;
const curriedAdd = curry(add);
curriedAdd(1)(2);  // 3

// Pipe function
type FunctionChain<T extends readonly any[]> = T extends readonly [
    infer F extends (...args: any[]) => any,
    ...infer R
]
    ? (
        x: Parameters<F>[0]
    ) => R extends readonly [infer N extends (...args: any[]) => any, ...any[]]
        ? ReturnType<F> extends Parameters<N>[0]
            ? FunctionChain<R>
            : never
        : ReturnType<F>
    : never;

// Memoization with generics
function memoize<T extends (...args: any[]) => any>(fn: T): T {
    const cache = new Map();

    return ((...args: any[]) => {
        const key = JSON.stringify(args);
        if (cache.has(key)) return cache.get(key);
        const result = fn(...args);
        cache.set(key, result);
        return result;
    }) as T;
}
```

## Part 5: Module System

```typescript
// Named exports
export interface User {
    name: string;
    age: number;
}

export class UserService {
    getUser(id: number): User {
        return { name: "John", age: 30 };
    }
}

export const DEFAULT_AGE = 18;

// Default export
export default class UserRepository {
    // ...
}

// Re-exports
export { User, UserService } from "./models";
export * from "./utils";

// Namespace (older module style - avoid)
namespace Utils {
    export function log(msg: string) {
        console.log(msg);
    }
}

Utils.log("message");

// Declaration files (.d.ts)
// Describe types for JavaScript libraries
declare module "external-library" {
    export interface Options {
        timeout: number;
    }

    export function process(data: any, options?: Options): Promise<void>;
}

// Triple-slash directives (in .d.ts files)
/// <reference path="./types.d.ts" />
/// <reference types="node" />
```

## Part 6: Performance & Compilation

```typescript
// @ts-ignore - ignore next line
const anyValue: string = 123;

// @ts-expect-error - expect error (fails if no error)
const wrongType: string = 123;

// Type-only imports (tree-shakeable)
import type { User } from "./types";
import type { FC } from "react";

// Const type parameters (TS 5.0+)
function createArray<const T>(item: T) {
    return [item] as const;
}

// Selective property types
type Getters<T> = {
    [P in keyof T as `get${Capitalize<string & P>}`]: () => T[P];
};

type Person = { name: string; age: number };
type PersonGetters = Getters<Person>;
// {
//     getName: () => string;
//     getAge: () => number;
// }

// Filtering properties by type
type OnlyStrings<T> = {
    [K in keyof T as T[K] extends string ? K : never]: T[K];
};

type PersonStrings = OnlyStrings<Person>;  // { name: string; }

// Performance: avoid circular types
// type A = { b: B };
// type B = { a: A };  // Infinite

// Instead, use:
interface A {
    b: B;
}

interface B {
    a: A;
}
```

## Part 7: Testing with Types

```typescript
// Type-safe assertions
function expectType<T>(value: T): void {}
function expectAssignable<T>(_: T): void {}
function expectNotAssignable<T>(_: T): void {}

expectType<string>("hello");
// expectType<number>("hello");  // Error!

// Test helpers
function describe(name: string, fn: () => void) {
    fn();
}

function it(name: string, fn: () => void) {
    fn();
}

function expect<T>(value: T) {
    return {
        toBe(expected: T) {
            if (value !== expected) throw new Error("Assertion failed");
        },
        toEqual(expected: unknown) {
            if (JSON.stringify(value) !== JSON.stringify(expected)) {
                throw new Error("Assertion failed");
            }
        }
    };
}

// Usage
describe("UserService", () => {
    it("should create user", () => {
        const service = new UserService();
        const user = service.getUser(1);
        expect(user.name).toBe("John");
    });
});
```

## Part 8: Best Practices

```typescript
// ✓ DO
class GoodExample {
    // Use explicit types
    private value: number = 0;

    // Use private/protected for encapsulation
    private calculateSecret(): number {
        return this.value * 2;
    }

    // Return specific types
    public getValue(): number {
        return this.value;
    }

    // Use readonly for immutability
    public readonly id: string = "123";
}

// ✗ AVOID
class BadExample {
    // Implicit types (any-ish)
    value = 0;

    // Using any
    method(param: any): any {
        return param;
    }

    // Loose typing
    processData(data: object) {
        // data.anything  // Unsafe!
    }

    // Mutable globals
    static globalState: User[] = [];
}

// Configuration example
interface Config {
    apiUrl: string;
    timeout: number;
    retries: number;
}

const config: Readonly<Config> = {
    apiUrl: "https://api.example.com",
    timeout: 5000,
    retries: 3
};

// Type-safe environment variables
function getEnvVar(name: string, defaultValue: string): string {
    return process.env[name] ?? defaultValue;
}

const apiUrl = getEnvVar("API_URL", "http://localhost");
```

---

## Key Takeaways

1. **Advanced types** reduce boilerplate and improve safety
2. **Generic constraints** make functions reusable and safe
3. **Discriminated unions** are safer than optional properties
4. **Type inference** reduces annotation overhead
5. **Utility types** cover common type transformations
6. **Decorators** enable powerful metadata patterns
7. **Performance optimization** through tree-shaking
8. **Type testing** ensures type safety

---

**Last Updated:** October 25, 2024
**Level:** Expert
**Topics Covered:** 45+ advanced patterns, 70+ code examples
