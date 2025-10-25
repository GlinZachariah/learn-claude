# Advanced JavaScript & Modern Patterns

## Part 1: OOP & Classes

```javascript
// ES6 Classes
class Animal {
    constructor(name) {
        this.name = name;
    }

    speak() {
        return `${this.name} makes a sound`;
    }

    static info() {
        return "This is an animal class";
    }
}

class Dog extends Animal {
    constructor(name, breed) {
        super(name);
        this.breed = breed;
    }

    speak() {
        return `${this.name} barks`;
    }

    getBreed() {
        return this.breed;
    }
}

const dog = new Dog("Buddy", "Golden Retriever");
dog.speak();           // "Buddy barks"
Dog.info();            // "This is an animal class"

// Getters & Setters
class Person {
    constructor(firstName, lastName) {
        this.firstName = firstName;
        this.lastName = lastName;
    }

    get fullName() {
        return `${this.firstName} ${this.lastName}`;
    }

    set fullName(name) {
        [this.firstName, this.lastName] = name.split(' ');
    }

    static fromString(str) {
        const [first, last] = str.split(' ');
        return new Person(first, last);
    }
}

const person = new Person("John", "Doe");
console.log(person.fullName);  // "John Doe"
person.fullName = "Jane Smith";
console.log(person.firstName); // "Jane"

// Private fields
class BankAccount {
    #balance = 0;  // Private field

    constructor(initialBalance) {
        this.#balance = initialBalance;
    }

    deposit(amount) {
        this.#balance += amount;
    }

    #calculateInterest() {  // Private method
        return this.#balance * 0.02;
    }

    getBalance() {
        return this.#balance + this.#calculateInterest();
    }
}

const account = new BankAccount(1000);
account.deposit(500);
// account.#balance;  // SyntaxError - cannot access private field
account.getBalance();  // 1530

// Static properties
class Counter {
    static count = 0;

    constructor() {
        Counter.count++;
    }

    static getCount() {
        return Counter.count;
    }
}
```

## Part 2: Prototypes & Inheritance

```javascript
// Prototype chain
const parent = {
    greet() {
        return `Hello, I'm ${this.name}`;
    }
};

const child = Object.create(parent);
child.name = "Child";
child.greet();  // "Hello, I'm Child"

// Constructor functions (pre-ES6)
function Vehicle(brand) {
    this.brand = brand;
}

Vehicle.prototype.drive = function() {
    return `${this.brand} is driving`;
};

function Car(brand, model) {
    Vehicle.call(this, brand);  // Call parent constructor
    this.model = model;
}

Car.prototype = Object.create(Vehicle.prototype);
Car.prototype.constructor = Car;
Car.prototype.honk = function() {
    return `${this.model} honks`;
};

const myCar = new Car("Toyota", "Camry");
myCar.drive();  // "Toyota is driving"
myCar.honk();   // "Camry honks"

// Object.create with property descriptors
const obj = Object.create(null, {
    prop: {
        value: 'value',
        writable: true,
        enumerable: true,
        configurable: true
    }
});

// Property descriptors
Object.defineProperty(obj, 'name', {
    value: 'John',
    writable: false,
    enumerable: true,
    configurable: false
});

obj.name = 'Jane';  // No effect (read-only)
```

## Part 3: Functional Programming

```javascript
// Pure functions (no side effects)
const add = (a, b) => a + b;
const multiply = (a, b) => a * b;

// Function composition
const compose = (...fns) => x => fns.reduceRight((v, f) => f(v), x);
const pipe = (...fns) => x => fns.reduce((v, f) => f(v), x);

const square = x => x * x;
const double = x => x * 2;
const addOne = x => x + 1;

const composed = compose(double, square, addOne);
composed(5);  // double(square(addOne(5))) = double(36) = 72

const piped = pipe(addOne, square, double);
piped(5);     // double(square(addOne(5))) = double(36) = 72

// Currying (partial application)
const curry = (fn) => {
    const arity = fn.length;
    return function curried(...args) {
        if (args.length >= arity) {
            return fn(...args);
        }
        return (...moreArgs) => curried(...args, ...moreArgs);
    };
};

const add3 = (a, b, c) => a + b + c;
const curriedAdd = curry(add3);
curriedAdd(1)(2)(3);  // 6
curriedAdd(1, 2)(3);  // 6

// Partial application
const partial = (fn, ...args) => (...moreArgs) => fn(...args, ...moreArgs);
const multiply3 = (a, b, c) => a * b * c;
const multiplyBy2 = partial(multiply3, 2);
multiplyBy2(3, 4);  // 24

// Memoization (caching)
const memoize = (fn) => {
    const cache = new Map();
    return (...args) => {
        const key = JSON.stringify(args);
        if (cache.has(key)) {
            return cache.get(key);
        }
        const result = fn(...args);
        cache.set(key, result);
        return result;
    };
};

const expensiveOperation = (n) => {
    console.log("Computing...");
    return n * 2;
};

const memoizedOp = memoize(expensiveOperation);
memoizedOp(5);  // "Computing..." -> 10
memoizedOp(5);  // 10 (from cache)
```

## Part 4: Destructuring & Spread

```javascript
// Array destructuring
const [a, b, c] = [1, 2, 3];
const [x, , z] = [1, 2, 3];           // Skip middle
const [first, ...rest] = [1, 2, 3, 4]; // Rest: [2, 3, 4]

// Object destructuring
const { name, age } = { name: 'John', age: 30 };
const { name: fullName } = { name: 'John' }; // Rename
const { name = 'Unknown' } = { };      // Default value
const { a, b, ...rest } = { a: 1, b: 2, c: 3, d: 4 };

// Nested destructuring
const { user: { name, address: { city } } } = {
    user: {
        name: 'John',
        address: { city: 'NYC' }
    }
};

// Function parameters
const greet = ({ name, age = 18 }) => {
    return `${name} is ${age}`;
};

greet({ name: 'John', age: 30 });

// Spread operator
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];
const merged = [...arr1, ...arr2];     // [1, 2, 3, 4, 5, 6]
const withExtra = [0, ...arr1, 3.5];   // [0, 1, 2, 3, 3.5]

const obj1 = { a: 1, b: 2 };
const obj2 = { c: 3, d: 4 };
const merged_obj = { ...obj1, ...obj2 }; // { a: 1, b: 2, c: 3, d: 4 }
const override = { ...obj1, b: 99 };     // Override property

// Rest parameters
const sum = (...numbers) => numbers.reduce((a, b) => a + b, 0);
sum(1, 2, 3, 4, 5);  // 15
```

## Part 5: Advanced Array Methods

```javascript
// Array creation
Array(3).fill(0);           // [0, 0, 0]
Array.from('hello');        // ['h', 'e', 'l', 'l', 'o']
Array.from({ length: 5 }, (_, i) => i); // [0, 1, 2, 3, 4]
Array.of(1, 2, 3);          // [1, 2, 3]

// Searching
arr.indexOf(3);             // First index or -1
arr.lastIndexOf(3);         // Last index
arr.find(x => x > 2);       // First matching element
arr.findIndex(x => x > 2);  // First matching index
arr.findLast(x => x > 2);   // Last matching (ES2023)
arr.includes(3);            // Boolean

// Transforming
arr.map(x => x * 2);        // New array
arr.flatMap(x => [x, x*2]); // Map and flatten
arr.flat(2);                // Flatten depth 2
arr.reverse();              // Reverse in place
arr.sort((a, b) => a - b);  // Sort in place

// Reducing
arr.reduce((acc, val) => acc + val, 0);           // Single value
arr.reduceRight((acc, val) => acc + val, 0);      // Right to left
arr.reduce((groups, item) => {
    const key = item.category;
    groups[key] = groups[key] || [];
    groups[key].push(item);
    return groups;
}, {});  // Grouping

// Testing
arr.some(x => x > 4);       // At least one true
arr.every(x => x > 0);      // All true

// Concatenating
arr.concat([7, 8]);
[...arr, 7, 8];

// Slicing (no mutation)
arr.slice(2);               // From index 2
arr.slice(1, 3);            // Indices 1-2
```

## Part 6: Modules & Bundling

```javascript
// ES6 Modules - Export
export const multiply = (a, b) => a * b;
export function divide(a, b) { return a / b; }
export default class Calculator { }

// Named exports
export { multiply, divide };
export { multiply as mul, divide as div };

// Re-export
export { multiply, divide } from './math.js';
export * from './utils.js';

// ES6 Modules - Import
import Calculator from './calculator.js';
import { multiply, divide } from './math.js';
import { multiply as mul, divide as div } from './math.js';
import * as math from './math.js';

// Dynamic imports
const module = await import('./module.js');
module.someFunction();

// CommonJS (Node.js)
module.exports = { multiply, divide };
const { multiply } = require('./math.js');
```

## Part 7: Web APIs

```javascript
// Fetch API
fetch('/api/users')
    .then(res => {
        if (!res.ok) throw new Error('Network response');
        return res.json();
    })
    .then(data => console.log(data))
    .catch(error => console.error(error));

// With request options
fetch('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: 'John' })
})
.then(res => res.json());

// AbortController for cancellation
const controller = new AbortController();
fetch('/api/data', { signal: controller.signal });
controller.abort();  // Cancel request

// Storage API
localStorage.setItem('key', 'value');
const value = localStorage.getItem('key');
localStorage.removeItem('key');
localStorage.clear();

sessionStorage.setItem('temp', 'data');  // Session only

// JSON
JSON.stringify({ name: 'John', age: 30 });      // Serialize
JSON.parse('{"name":"John","age":30}');         // Deserialize
JSON.stringify(obj, null, 2);                   // Formatted

// setTimeout & setInterval
const timerId = setTimeout(() => {
    console.log("After 1 second");
}, 1000);
clearTimeout(timerId);

const intervalId = setInterval(() => {
    console.log("Every 1 second");
}, 1000);
clearInterval(intervalId);

// RequestAnimationFrame
requestAnimationFrame((timestamp) => {
    // Sync with browser repaint
});

// IntersectionObserver
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            console.log("Element visible");
        }
    });
});
observer.observe(element);

// MutationObserver
const observer = new MutationObserver((mutations) => {
    mutations.forEach(mutation => {
        console.log("DOM changed");
    });
});
observer.observe(element, {
    childList: true,
    attributes: true,
    subtree: true
});
```

## Part 8: Performance & Optimization

```javascript
// Debouncing (wait for pause)
const debounce = (fn, delay) => {
    let timeoutId;
    return (...args) => {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => fn(...args), delay);
    };
};

const searchHandler = debounce((query) => {
    fetch(`/api/search?q=${query}`);
}, 500);

// Throttling (limit frequency)
const throttle = (fn, limit) => {
    let inThrottle;
    return (...args) => {
        if (!inThrottle) {
            fn(...args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
};

const scrollHandler = throttle(() => {
    checkLoadMore();
}, 1000);

// Lazy evaluation
const lazyMap = (transform) => (collection) =>
    collection.map(transform);

// Request Idle Callback
requestIdleCallback((deadline) => {
    if (deadline.timeRemaining() > 1) {
        doBackgroundWork();
    }
});

// Web Workers (off-main-thread)
const worker = new Worker('worker.js');
worker.postMessage({ data: largeDataset });
worker.onmessage = (event) => {
    console.log('Result:', event.data);
};

// Profiling
console.time('operation');
// ... code to measure ...
console.timeEnd('operation');

// Performance API
performance.mark('start');
// ... code ...
performance.mark('end');
performance.measure('duration', 'start', 'end');

const measures = performance.getEntriesByType('measure');
measures.forEach(m => console.log(`${m.name}: ${m.duration}ms`));
```

---

## Key Takeaways

1. **Classes** provide cleaner OOP syntax than prototypes
2. **Functional programming** enables composable code
3. **Destructuring** simplifies working with complex data
4. **Spread operator** reduces array/object manipulation code
5. **Modules** organize code into reusable pieces
6. **Async patterns** handle operations that take time
7. **Performance optimization** is critical for UX
8. **Web APIs** provide powerful browser capabilities

---

**Last Updated:** October 25, 2024
**Level:** Expert
**Topics Covered:** 50+ advanced concepts, 100+ code examples
