# JavaScript Fundamentals & Core Concepts

## Part 1: Data Types & Variables

```javascript
// Var (avoid in modern code - function scoped)
var name = "John";

// Let (block scoped - preferred)
let age = 25;

// Const (block scoped, can't reassign - preferred)
const email = "john@example.com";

// Data types
const num = 42;                    // Number
const big = 9007199254740991n;    // BigInt
const str = "Hello";              // String
const bool = true;                // Boolean
const sym = Symbol('id');         // Symbol
const obj = { name: 'John' };    // Object
const arr = [1, 2, 3];           // Array
const fn = function() { };       // Function
const nil = null;                 // Null (intentional absence)
const undef = undefined;          // Undefined (uninitialized)

// Type checking
typeof 42;                        // "number"
typeof "hello";                   // "string"
typeof true;                      // "boolean"
typeof undefined;                 // "undefined"
typeof null;                      // "object" (quirk)
typeof Symbol();                  // "symbol"
typeof {};                        // "object"
typeof (() => {});               // "function"

// Type coercion
"5" + 2;                         // "52" (string concatenation)
"5" - 2;                         // 3 (numeric coercion)
"" == false;                     // true (loose equality)
"" === false;                    // false (strict equality)

// Always use === (strict equality)
```

## Part 2: Objects & Arrays

```javascript
// Object literals
const person = {
    name: "John",
    age: 30,
    email: "john@example.com",
    address: {
        street: "123 Main St",
        city: "NYC"
    },
    greet() {
        return `Hello, ${this.name}!`;
    }
};

// Accessing properties
person.name;              // Dot notation
person["name"];           // Bracket notation
person?.name;            // Optional chaining (null-safe)

// Destructuring
const { name, age, email } = person;
const { street, city } = person.address;
const { name: fullName } = person;  // Rename

// Array operations
const arr = [1, 2, 3, 4, 5];

// Methods
arr.push(6);             // Add to end
arr.pop();               // Remove from end
arr.unshift(0);          // Add to start
arr.shift();             // Remove from start
arr.slice(1, 3);         // Get [2, 3]
arr.splice(1, 2, 9, 10); // Remove 2, add 9,10
arr.indexOf(3);          // Find index
arr.includes(3);         // Check existence
arr.join(",");           // "1,2,3,4,5"
arr.reverse();           // Reverses in place
arr.sort();              // Sorts in place

// Higher-order functions
arr.map(x => x * 2);                    // [2, 4, 6, 8, 10]
arr.filter(x => x > 2);                 // [3, 4, 5]
arr.reduce((sum, x) => sum + x, 0);     // 15
arr.find(x => x > 2);                   // 3
arr.some(x => x > 4);                   // true
arr.every(x => x > 0);                  // true
arr.flatMap(x => [x, x * 2]);           // [1, 2, 2, 4, 3, 6, ...]

// Spread operator
const arr2 = [...arr, 6, 7];
const merged = [...arr, ...arr2];
const copy = [...arr];

// Object methods
Object.keys(person);                 // ["name", "age", "email", "address", "greet"]
Object.values(person);               // ["John", 30, "john@example.com", {...}, ƒ]
Object.entries(person);              // [["name", "John"], ["age", 30], ...]
Object.assign({}, person);           // Shallow copy
```

## Part 3: Functions & Scope

```javascript
// Function declaration
function add(a, b) {
    return a + b;
}

// Function expression
const multiply = function(a, b) {
    return a * b;
};

// Arrow functions (lexical this)
const subtract = (a, b) => a - b;
const square = x => x * x;
const getObj = () => ({ x: 1 });

// Default parameters
function greet(name = "Guest") {
    return `Hello, ${name}!`;
}

// Rest parameters
function sum(...numbers) {
    return numbers.reduce((a, b) => a + b, 0);
}

// Function parameters
function processData(data, callback) {
    callback(data);
}

// Higher-order function
function createMultiplier(multiplier) {
    return (num) => num * multiplier;
}
const double = createMultiplier(2);
double(5);  // 10

// Scope
{
    let blockScoped = 1;     // Only in this block
    const alsoBlock = 2;     // Only in this block
    var functionScoped = 3;  // Available in entire function
}

// Closure
function counter() {
    let count = 0;
    return {
        increment: () => ++count,
        decrement: () => --count,
        get: () => count
    };
}

// Hoisting
console.log(x);  // undefined (var hoisted)
var x = 5;

// console.log(y);  // ReferenceError (let not hoisted)
let y = 10;
```

## Part 4: This & Binding

```javascript
// this binding context
const obj = {
    name: "Object",
    getName() {
        return this.name;  // this = obj
    },
    getNameArrow: () => {
        return this.name;  // this = global (arrow function)
    }
};

// Method call
obj.getName();  // "Object"

// Function call
const getName = obj.getName;
getName();      // undefined (this = undefined in strict mode)

// Explicit binding
getName.call(obj);                  // "Object"
getName.apply(obj);                 // "Object"
const boundGetName = getName.bind(obj);
boundGetName();                      // "Object"

// Constructor binding
function Person(name) {
    this.name = name;
}
new Person("John");  // this = new object

// Arrow functions inherit this
const obj2 = {
    name: "Arrow",
    methods: {
        regularFn() {
            return this.name;  // undefined (this = undefined)
        },
        arrowFn: () => {
            return this.name;  // depends on outer scope
        }
    }
};
```

## Part 5: Asynchronous JavaScript

```javascript
// Callbacks
function fetchData(callback) {
    setTimeout(() => {
        callback({ id: 1, name: "John" });
    }, 1000);
}

fetchData((data) => {
    console.log(data);
});

// Promises
const promise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve("Success!");
    }, 1000);
});

promise
    .then(result => console.log(result))
    .catch(error => console.error(error))
    .finally(() => console.log("Done"));

// Promise.all (wait for all)
Promise.all([
    fetch('/api/users'),
    fetch('/api/posts'),
    fetch('/api/comments')
])
.then(responses => responses.map(r => r.json()))
.then(data => console.log(data));

// Promise.race (first to complete)
Promise.race([
    new Promise(r => setTimeout(() => r("first"), 100)),
    new Promise(r => setTimeout(() => r("second"), 200))
])
.then(result => console.log(result));  // "first"

// Async/Await (preferred)
async function getUserData(userId) {
    try {
        const response = await fetch(`/api/users/${userId}`);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error("Error:", error);
    } finally {
        console.log("Request completed");
    }
}

// Using async function
getUserData(1).then(data => console.log(data));

// Parallel async operations
async function getMultipleUsers(ids) {
    // Sequential (slower)
    for (const id of ids) {
        const user = await getUserData(id);
    }

    // Parallel (faster)
    const users = await Promise.all(
        ids.map(id => getUserData(id))
    );
}
```

## Part 6: Error Handling

```javascript
// Try-catch
try {
    riskyOperation();
} catch (error) {
    console.error("Error caught:", error.message);
} finally {
    cleanup();
}

// Custom errors
class ValidationError extends Error {
    constructor(message) {
        super(message);
        this.name = "ValidationError";
    }
}

throw new ValidationError("Invalid input");

// Error types
// Error, SyntaxError, TypeError, ReferenceError, RangeError,
// URIError, EvalError, AggregateError

// Error properties
try {
    throw new Error("Something went wrong");
} catch (e) {
    console.log(e.message);     // "Something went wrong"
    console.log(e.stack);        // Stack trace
    console.log(e.name);         // "Error"
}

// Chaining with .catch()
fetch('/api/data')
    .then(res => res.json())
    .then(data => processData(data))
    .catch(error => handleError(error));

// Async error handling
async function safeOperation() {
    try {
        const result = await riskyOperation();
        return result;
    } catch (error) {
        console.error("Operation failed:", error);
        throw error;  // Re-throw if needed
    }
}
```

## Part 7: DOM Manipulation

```javascript
// Selecting elements
const el = document.querySelector('.my-class');
const els = document.querySelectorAll('p');
const byId = document.getElementById('my-id');
const byClass = document.getElementsByClassName('class-name');

// Creating elements
const div = document.createElement('div');
div.textContent = "Hello";
div.className = 'container';
div.id = 'main';
div.setAttribute('data-value', '123');

// DOM traversal
el.parentElement;
el.parentNode;
el.children;
el.childNodes;
el.firstChild;
el.lastChild;
el.nextSibling;
el.previousSibling;
el.closest('.parent');

// Modifying DOM
el.textContent = "New text";      // Plain text
el.innerHTML = "<p>HTML</p>";     // HTML (XSS risk!)
el.innerText = "Text";            // Rendered text
el.replaceWith(newEl);
el.remove();
el.appendChild(child);
el.insertBefore(child, reference);
el.insertAdjacentHTML('beforeend', '<p>Text</p>');

// Classes
el.classList.add('active');
el.classList.remove('inactive');
el.classList.toggle('hidden');
el.classList.contains('visible');

// Styles
el.style.color = 'red';
el.style.backgroundColor = 'blue';
getComputedStyle(el).color;
```

## Part 8: Events

```javascript
// Event listeners
el.addEventListener('click', (event) => {
    console.log(event.type);       // "click"
    console.log(event.target);     // Element clicked
    console.log(event.currentTarget); // Element listener attached to
    event.preventDefault();         // Prevent default behavior
    event.stopPropagation();        // Stop bubbling
});

// Common events
// Mouse: click, dblclick, mousedown, mouseup, mousemove, mouseenter, mouseleave
// Keyboard: keydown, keyup, keypress, keydown (for modifiers)
// Form: submit, change, input, focus, blur
// Document: load, DOMContentLoaded, unload
// UI: scroll, resize, orientationchange

// Event delegation
document.addEventListener('click', (event) => {
    if (event.target.matches('button.action')) {
        handleClick(event);
    }
});

// Event object properties
event.type;              // Event type
event.target;            // Element that triggered
event.currentTarget;     // Element with listener
event.key;              // Key name (for keyboard)
event.code;             // Physical key code
event.x, event.y;       // Mouse position
event.shiftKey;         // Modifier keys
event.altKey;
event.ctrlKey;
event.metaKey;

// Custom events
const event = new CustomEvent('myEvent', {
    detail: { message: "Hello" },
    bubbles: true,
    cancelable: true
});

el.dispatchEvent(event);

el.addEventListener('myEvent', (e) => {
    console.log(e.detail.message);
});
```

---

## Key Takeaways

1. **Use const/let**, avoid var
2. **Use === for equality** comparisons
3. **Understand closures** for advanced patterns
4. **Prefer async/await** over callbacks and promises
5. **Always use try-catch** for error handling
6. **Event delegation** improves performance
7. **Understand this binding** for OOP patterns
8. **Use spread operator** for object/array manipulation

---

**Last Updated:** October 25, 2024
**Level:** Expert
**Topics Covered:** 60+ JavaScript concepts, 120+ code examples
