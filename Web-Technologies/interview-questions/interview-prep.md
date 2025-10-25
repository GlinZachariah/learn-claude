# Web Technologies Interview Preparation

## Overview

This comprehensive guide contains 60+ interview questions organized by seniority level, technology, and question type. Each question includes expected answer points, common mistakes, and follow-up questions.

---

## Level 1: Junior Developer (Entry-Level)

### HTML & Accessibility (5 questions)

**Q1: What is semantic HTML and why is it important?**

**Expected Answer:**
Semantic HTML uses meaningful tags that describe the content's purpose. Examples: `<header>`, `<nav>`, `<main>`, `<article>`, `<footer>` instead of generic `<div>` tags.

**Importance:**
- Improves accessibility for screen readers
- Better SEO for search engines
- Makes code more maintainable
- Provides better document structure
- Helps with keyboard navigation

**Sample Answer:**
"Semantic HTML uses tags that describe what the content means, not just how it looks. For example, using `<nav>` instead of `<div class="navigation">`. This helps screen readers understand the page structure and helps search engines index content properly. It also makes the code easier for other developers to understand."

**Common Mistakes:**
- Thinking semantic HTML is only for SEO
- Using semantic tags incorrectly (e.g., `<nav>` for all navigation)
- Not understanding the accessibility impact
- Overusing `<div>` when semantic alternatives exist

**Follow-up Questions:**
- What's the difference between `<section>` and `<div>`?
- Why is the order of headings (h1-h6) important?
- What role does ARIA play alongside semantic HTML?

---

**Q2: Explain the viewport meta tag and its purpose.**

**Expected Answer:**
The viewport meta tag controls how a web page is displayed on mobile devices.

```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

**What it does:**
- `width=device-width`: Sets width to device width
- `initial-scale=1`: Sets initial zoom level to 100%
- Enables responsive design on mobile
- Prevents unwanted zooming/panning

**Sample Answer:**
"The viewport meta tag tells mobile browsers how to scale the page. Without it, mobile browsers assume a wide desktop viewport and the page appears zoomed out. `width=device-width` makes the page width match the device width, and `initial-scale=1` sets the zoom to 100%. This is essential for responsive design."

**Common Mistakes:**
- Forgetting to include it in new projects
- Using hardcoded pixel widths instead of `device-width`
- Setting `user-scalable=no` (accessibility issue)

**Follow-up Questions:**
- What other viewport properties can you set?
- Why shouldn't you disable user scaling?
- How does viewport relate to media queries?

---

**Q3: What's the difference between `<strong>` and `<b>` tags?**

**Expected Answer:**
- `<strong>`: Semantic tag indicating strong importance
- `<b>`: Presentational tag indicating bold text

**Key Differences:**
| Aspect | `<strong>` | `<b>` |
|--------|-----------|-------|
| Semantic | Yes | No |
| Screen Reader | "strong" emphasis | No announcement |
| Use Case | Important emphasis | Stylistic bolding |
| Best Practice | Prefer this | Use rarely |

**Sample Answer:**
"`<strong>` is semantic and indicates the text has strong importance, which screen readers announce. `<b>` is purely presentational and just makes text bold without conveying meaning. Use `<strong>` when something is truly important (like warnings), and `<b>` only for styling without semantic meaning, like product names in reviews."

**Common Mistakes:**
- Using `<b>` when you mean `<strong>`
- Not understanding the accessibility difference
- Using either instead of `<em>` for emphasis

**Follow-up Questions:**
- What's the difference between `<em>` and `<i>`?
- When would you use `<b>` instead of CSS bold?
- How do screen readers treat these differently?

---

**Q4: What is the purpose of the alt attribute for images?**

**Expected Answer:**
The `alt` attribute provides alternative text describing an image. It serves multiple purposes:

1. **Accessibility**: Screen readers read alt text for blind/low-vision users
2. **SEO**: Search engines use alt text to understand images
3. **Broken Images**: Displays if image fails to load
4. **Slow Connections**: Helps users understand missing images

**Best Practices:**
- Be descriptive but concise
- Don't repeat the same alt text
- Decorative images: use empty `alt=""`
- Include relevant keywords naturally

**Sample Answer:**
"The alt attribute describes what's in an image. It's critical for accessibility because screen readers use it to explain images to blind users. It also helps SEO since search engines can't 'see' images. For decorative images, use `alt=\"\"` to tell screen readers to skip them. For meaningful images, write a clear description of what the image shows."

**Common Mistakes:**
- Omitting alt text
- Using vague descriptions ("image", "photo")
- Using alt text for decorative images
- Writing too long descriptions

**Follow-up Questions:**
- How do you handle alt text for complex images?
- Should you include "image of" in alt text?
- How does alt text affect SEO?

---

**Q5: What are HTML5 semantic elements?**

**Expected Answer:**
HTML5 introduced semantic elements that describe their content's purpose:

**Common Semantic Elements:**
- `<header>`: Introductory content
- `<nav>`: Navigation links
- `<main>`: Main content of page
- `<article>`: Self-contained content
- `<section>`: Thematic grouping
- `<aside>`: Sidebar/tangential content
- `<footer>`: Footer content
- `<figure>`: Illustration/diagram
- `<figcaption>`: Caption for figure

**Benefits:**
- Improves accessibility
- Better document structure
- Easier for screen readers and browsers
- Improves SEO
- Makes code more readable

**Sample Answer:**
"HTML5 semantic elements replace generic `<div>` tags with meaningful names. For example, `<header>` instead of `<div class="header">`, `<nav>` for navigation, `<main>` for main content. This helps screen readers understand page structure, improves SEO, and makes code more maintainable. Each element has implicit roles that browsers and assistive technology understand."

**Common Mistakes:**
- Using semantic elements incorrectly
- Not understanding the difference between elements
- Assuming all divs should be replaced
- Not using them at all

**Follow-up Questions:**
- What's the difference between `<article>` and `<section>`?
- Can you nest semantic elements?
- How do they relate to ARIA roles?

---

### CSS Fundamentals (5 questions)

**Q6: Explain CSS specificity with examples.**

**Expected Answer:**
Specificity determines which CSS rule is applied when conflicts exist. It's calculated as a three-digit score:

**Calculation:**
1. **Inline styles** (1,0,0): `style="color: red"`
2. **ID selectors** (0,1,0): `#myId`
3. **Classes/Attributes/Pseudos** (0,0,1): `.class`, `[attr]`, `:hover`
4. **Element selectors** (0,0,0): `p`, `div`, etc.

**Examples:**
```css
p { color: blue; }                    /* 0,0,1 */
.highlight { color: red; }            /* 0,0,10 */
#main { color: green; }               /* 0,1,0 */
<p style="color: yellow;">text</p>   /* 1,0,0 (wins) */
```

**Sample Answer:**
"Specificity is a scoring system that determines which CSS rule wins when there are conflicts. Inline styles have the highest specificity (100), then IDs (10), then classes and attributes (1), then elements (0). When multiple rules target the same element, the one with the highest specificity wins. It's important to avoid highly specific selectors because they're hard to override."

**Common Mistakes:**
- Using too many ID selectors
- Using `!important` excessively
- Misunderstanding pseudo-elements
- Not understanding the cascade

**Follow-up Questions:**
- How does the cascade work with specificity?
- What's the problem with using `!important`?
- How does inheritance affect specificity?

---

**Q7: What is the CSS box model?**

**Expected Answer:**
The box model describes the layout of elements as concentric rectangles: content, padding, border, margin.

**From Inside Out:**
1. **Content**: The actual content (text, images)
2. **Padding**: Space inside the border (transparent)
3. **Border**: Edge around padding
4. **Margin**: Space outside the border (transparent)

**Example:**
```css
.box {
    width: 200px;           /* Content width */
    padding: 20px;          /* Inside space */
    border: 5px solid;      /* Edge */
    margin: 10px;           /* Outside space */
    box-sizing: border-box; /* Width includes padding/border */
}
```

**With box-sizing: border-box:**
- Total width = 200px (includes padding and border)
- More intuitive for layout

**Sample Answer:**
"The box model has four layers: content, padding, border, and margin. Padding is inside the border and affects how the content is spaced within the box. Margin is outside and controls spacing between elements. By default, `box-sizing: content-box` means the width only includes the content, not padding or border. Using `box-sizing: border-box` makes width include everything, which is usually more intuitive."

**Common Mistakes:**
- Confusing margin and padding
- Not using `box-sizing: border-box`
- Thinking margin collapses in all directions
- Not accounting for box model in layouts

**Follow-up Questions:**
- What is margin collapsing?
- Why does padding not work on inline elements?
- How does the box model affect Flexbox?

---

**Q8: How do you create a responsive layout with CSS?**

**Expected Answer:**
Use media queries, flexible units, and flexible layouts (Flexbox, Grid).

**Approaches:**
1. **Mobile-First Design**: Start with mobile, add features for larger screens
2. **Media Queries**: Apply different styles at different viewport widths
3. **Flexible Units**: Use `%`, `em`, `rem`, `vw` instead of `px`
4. **Flexible Layouts**: Flexbox and Grid adapt to available space

**Example:**
```css
/* Mobile first */
.container {
    display: flex;
    flex-direction: column;
    font-size: 1rem;
}

/* Tablet */
@media (min-width: 768px) {
    .container {
        flex-direction: row;
        gap: 2rem;
    }
}

/* Desktop */
@media (min-width: 1200px) {
    .container {
        max-width: 1200px;
        margin: 0 auto;
    }
}
```

**Sample Answer:**
"Responsive design uses media queries to apply different styles at different viewport sizes. Start with mobile-first: write CSS for mobile devices first, then add breakpoints for larger screens using `@media (min-width: ...)`. Use flexible units like percentages and flexbox/grid for layouts that adapt. The key is thinking about how your content adapts to different screen sizes, not trying to make one design work everywhere."

**Common Mistakes:**
- Using desktop-first approach
- Too many breakpoints
- Using hardcoded pixel widths
- Not testing on real devices

**Follow-up Questions:**
- What breakpoints should you use?
- What's the difference between mobile-first and desktop-first?
- How do you test responsive design?

---

**Q9: Explain Flexbox layout with a practical example.**

**Expected Answer:**
Flexbox is a one-dimensional layout system that distributes items in rows or columns.

**Key Concepts:**
- **Container**: Parent element with `display: flex`
- **Items**: Child elements that flex
- **Main axis**: Primary direction (default: horizontal)
- **Cross axis**: Perpendicular direction

**Common Properties:**
```css
.container {
    display: flex;           /* Enable flexbox */
    flex-direction: row;     /* Direction: row or column */
    justify-content: center; /* Align on main axis */
    align-items: center;     /* Align on cross axis */
    gap: 1rem;              /* Space between items */
    flex-wrap: wrap;        /* Wrap items to next line */
}

.item {
    flex: 1;                /* Grow equally */
    flex-basis: 200px;      /* Base size */
    flex-grow: 1;           /* Growth factor */
    flex-shrink: 1;         /* Shrink factor */
}
```

**Sample Answer:**
"Flexbox is a layout system for one-dimensional layouts. You put `display: flex` on a container, and the children automatically become flex items. Use `justify-content` to space items on the main axis (default is left-to-right), `align-items` for the cross axis, and `gap` for space between items. `flex: 1` makes items grow equally. It's great for navigation bars, centering, and responsive layouts."

**Common Mistakes:**
- Using `flex` on containers instead of items
- Not understanding main vs. cross axis
- Forgetting `align-items` for vertical centering
- Using fixed widths with flex items

**Follow-up Questions:**
- How does `flex: 1` work?
- What's the difference between `justify-content` and `align-items`?
- When should you use Flexbox vs. Grid?

---

**Q10: What is CSS Grid and when should you use it?**

**Expected Answer:**
CSS Grid is a two-dimensional layout system for complex layouts with rows and columns.

**Key Concepts:**
```css
.container {
    display: grid;
    grid-template-columns: 1fr 2fr 1fr;  /* Three columns */
    grid-template-rows: auto 1fr auto;   /* Three rows */
    gap: 1rem;                            /* Gap between items */
    grid-auto-flow: row;                  /* How to place items */
}

.item {
    grid-column: 1 / 3;  /* Span columns 1-2 */
    grid-row: 2 / 4;     /* Span rows 2-3 */
}
```

**When to Use:**
- **Grid**: 2D layouts (entire pages, dashboards)
- **Flexbox**: 1D layouts (navigation, sidebars)

**Sample Answer:**
"CSS Grid is for two-dimensional layouts with rows and columns. You define the grid on the container with `grid-template-columns` and `grid-template-rows`, then place items explicitly or let the browser auto-place them. Use Grid for page layouts and dashboards. Use Flexbox for one-dimensional layouts like navigation bars. The `fr` unit is helpful—`1fr 2fr` means the second column is twice as wide as the first."

**Common Mistakes:**
- Using Grid for one-dimensional layouts
- Not understanding the `fr` unit
- Forgetting to define grid tracks
- Overcomplicating simple layouts

**Follow-up Questions:**
- What's the difference between `grid-auto-flow` and explicit placement?
- When should you use `auto-fit` vs. `auto-fill`?
- How do you make Grid responsive without media queries?

---

### JavaScript Fundamentals (5 questions)

**Q11: What are the differences between var, let, and const?**

**Expected Answer:**
Three keywords for declaring variables with different scoping and reassignment rules.

| Keyword | Scope | Reassign | Redeclare | Hoisting | Best For |
|---------|-------|----------|-----------|----------|----------|
| `var` | Function | Yes | Yes | Yes (undefined) | Avoid |
| `let` | Block | Yes | No | No (TDZ) | Variables |
| `const` | Block | No | No | No (TDZ) | Constants |

**Key Differences:**
```javascript
// Scope
if (true) {
    var x = 1;      // Function-scoped
    let y = 2;      // Block-scoped
    const z = 3;    // Block-scoped
}
console.log(x);     // 1 (accessible)
console.log(y);     // ReferenceError

// Reassignment
const obj = {};
obj.prop = 1;       // OK (mutation allowed)
obj = {};           // Error (reassignment not allowed)
```

**Sample Answer:**
"Use `const` by default, `let` when you need to reassign, and avoid `var`. `const` and `let` are block-scoped (inside if/for), while `var` is function-scoped. `const` prevents reassignment but not mutation (you can modify object properties). The Temporal Dead Zone prevents accessing `let`/`const` before declaration. Modern JavaScript rarely needs `var`."

**Common Mistakes:**
- Using `var` in modern code
- Not understanding block scope
- Thinking `const` prevents all changes
- Confusion about hoisting

**Follow-up Questions:**
- What is the Temporal Dead Zone?
- How does hoisting work differently for each?
- When would you actually use `var`?

---

**Q12: Explain closures and give a practical example.**

**Expected Answer:**
A closure is a function with access to another function's variables through the scope chain.

**Example:**
```javascript
function makeCounter() {
    let count = 0;  // Variable that will be "closed over"

    return {
        increment() { return ++count; },
        decrement() { return --count; },
        getCount() { return count; }
    };
}

const counter = makeCounter();
counter.increment();  // 1
counter.increment();  // 2
counter.decrement();  // 1
counter.getCount();   // 1
// count is private and can only be accessed through these methods
```

**Real-World Uses:**
- Data privacy (private variables)
- Function factories
- Event handlers storing state
- Callbacks with context

**Sample Answer:**
"A closure is when a function remembers variables from the scope in which it was created. In the example, the returned object has access to `count` even after `makeCounter` finishes executing. This creates a private variable that can only be accessed through the returned methods. Closures are useful for creating private state, callbacks, and event handlers."

**Common Mistakes:**
- Thinking closures "close over" after execution
- Not understanding they capture by reference
- Loops with closures (common bug)
- Confusion with `this` binding

**Follow-up Questions:**
- What's the loop problem with closures?
- How do closures affect memory?
- How are closures different from private fields?

---

**Q13: What is the event loop and why is it important?**

**Expected Answer:**
The event loop manages JavaScript execution: running code, handling asynchronous operations, and processing callbacks.

**How It Works:**
1. **Call Stack**: Execute synchronous code
2. **Web APIs**: Browser handles async (fetch, timers, events)
3. **Callback Queue**: Callbacks wait here after async operation completes
4. **Event Loop**: Moves callbacks to stack when stack is empty

**Execution Order:**
```javascript
console.log('1');                          // Synchronous
setTimeout(() => console.log('2'), 0);     // Macrotask
Promise.resolve().then(() => console.log('3'));  // Microtask
console.log('4');                          // Synchronous

// Output: 1, 4, 3, 2
// Reason: Sync → Microtasks → Macrotasks
```

**Two Queue Types:**
- **Microtask Queue**: Promises, MutationObserver (runs before macrotasks)
- **Macrotask Queue**: setTimeout, setInterval, I/O (runs after microtasks)

**Sample Answer:**
"The event loop constantly checks if the call stack is empty. If it is, it moves the next callback from the queue to the stack for execution. JavaScript code runs synchronously on the call stack. When async operations like fetch or setTimeout occur, they're handled by Web APIs. When they complete, their callbacks go to a queue. The event loop moves them to the stack when it's empty. Microtasks (Promises) run before macrotasks (timers)."

**Common Mistakes:**
- Thinking `setTimeout(..., 0)` runs immediately
- Not understanding microtask vs. macrotask
- Confusion about when callbacks execute
- Thinking event loop is about events

**Follow-up Questions:**
- What's the difference between microtasks and macrotasks?
- Why do Promises run before setTimeout?
- How do you avoid blocking the event loop?

---

**Q14: What is async/await and how does it differ from Promises?**

**Expected Answer:**
`async/await` is syntactic sugar over Promises that makes asynchronous code look synchronous.

**Comparison:**
```javascript
// Promise-based
function fetchUser(id) {
    return fetch(`/api/users/${id}`)
        .then(res => res.json())
        .then(user => user);
}

// async/await
async function fetchUser(id) {
    const res = await fetch(`/api/users/${id}`);
    const user = await res.json();
    return user;
}

// Error handling
// Promise: .catch()
// async/await: try/catch
```

**Key Differences:**
| Aspect | Promises | async/await |
|--------|----------|-----------|
| Syntax | Chain `.then()` | `await` keyword |
| Readability | Callback chain | Looks synchronous |
| Error Handling | `.catch()` | `try/catch` |
| Return Value | Promise | Promise |
| Debugging | Harder (stack traces) | Easier (clearer stack) |

**Sample Answer:**
"`async/await` makes Promise-based code easier to read by making it look synchronous. You `await` a Promise and get its value, without `.then()` chaining. It uses `try/catch` for error handling instead of `.catch()`. The function automatically returns a Promise. Async/await is not actually different from Promises—it's just a cleaner way to write Promise code."

**Common Mistakes:**
- Forgetting `await` on Promises
- Not catching errors
- Using nested awaits when could be parallel
- Thinking `async` makes code synchronous

**Follow-up Questions:**
- How do you handle multiple Promises in parallel?
- What happens if you forget `await`?
- How do you abort an async operation?

---

**Q15: Explain the this keyword and its binding rules.**

**Expected Answer:**
`this` refers to the object that a method is called on, determined at runtime by how the function is called.

**Binding Rules (in order):**
1. **Explicit Binding** (`call`, `apply`, `bind`): Explicitly set by you
2. **Constructor Binding** (`new`): New object created
3. **Method Binding**: Object calling the method
4. **Global Binding**: Global object (or undefined in strict mode)
5. **Arrow Functions**: Inherit from enclosing scope

**Examples:**
```javascript
const obj = {
    name: "John",
    greet() { return `Hello, ${this.name}`; }
};

// Method binding
obj.greet();                    // "Hello, John" (this = obj)

// Function binding
const fn = obj.greet;
fn();                          // Error or undefined (this = window)

// Explicit binding
obj.greet.call({ name: "Jane" }); // "Hello, Jane" (this = new object)

// Constructor binding
function User(name) { this.name = name; }
new User("Bob");               // this = new instance

// Arrow function
const person = {
    name: "Alice",
    arrow: () => this.name    // this = outer scope, not person
};
```

**Sample Answer:**
"`this` is determined by how a function is called. When called as a method (`obj.method()`), `this` is the object. When called as a function (`func()`), `this` is the global object (or undefined in strict mode). You can explicitly set `this` with `call()`, `apply()`, or `bind()`. Arrow functions don't have their own `this`—they use the enclosing scope's `this`. This is one of JavaScript's trickiest features."

**Common Mistakes:**
- Assuming `this` is determined where function is defined
- Using arrow functions when regular functions are needed
- Forgetting to bind methods in callbacks
- Not understanding constructor binding

**Follow-up Questions:**
- What's the difference between `call` and `apply`?
- How do you bind a method to use in callbacks?
- Why don't arrow functions have `this`?

---

## Level 2: Mid-Level Developer (2-5 Years)

### Advanced JavaScript (6 questions)

**Q16: Explain prototypal inheritance and the prototype chain.**

**Expected Answer:**
JavaScript uses prototypal inheritance where objects inherit from other objects through the prototype chain.

**Concepts:**
- Every object has a `[[Prototype]]` (accessed via `__proto__` or `Object.getPrototypeOf()`)
- Properties/methods are looked up the chain
- `prototype` property exists on functions for constructor inheritance

**Example:**
```javascript
// Constructor function
function Animal(name) { this.name = name; }
Animal.prototype.speak = function() {
    return `${this.name} speaks`;
};

// Inheritance
function Dog(name) { Animal.call(this, name); }
Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.bark = function() {
    return `${this.name} barks`;
};

const dog = new Dog("Rex");
dog.speak();  // "Rex speaks" (inherited)
dog.bark();   // "Rex barks"

// Lookup chain:
// dog -> Dog.prototype -> Animal.prototype -> Object.prototype
```

**ES6 Classes** (syntactic sugar for the above):
```javascript
class Animal {
    constructor(name) { this.name = name; }
    speak() { return `${this.name} speaks`; }
}

class Dog extends Animal {
    bark() { return `${this.name} barks`; }
}
```

**Sample Answer:**
"JavaScript uses prototypal inheritance where objects inherit from other objects through the prototype chain. When you access a property, JavaScript looks in the object, then its prototype, then the prototype's prototype, etc. ES6 classes are syntactic sugar over this system. Understanding the prototype chain is important for debugging and understanding how inheritance works."

**Common Mistakes:**
- Confusing `prototype` with `[[Prototype]]`
- Not understanding the lookup chain
- Incorrect inheritance setup
- Mixing class and prototype patterns

**Follow-up Questions:**
- What's the difference between `prototype` and `__proto__`?
- How does `Object.create()` work?
- Why do some recommend composition over inheritance?

---

**Q17: What are higher-order functions and functional programming patterns?**

**Expected Answer:**
Higher-order functions take or return functions, enabling functional programming patterns.

**Common Patterns:**
```javascript
// Map: Transform array
[1, 2, 3].map(x => x * 2);  // [2, 4, 6]

// Filter: Select items
[1, 2, 3, 4].filter(x => x > 2);  // [3, 4]

// Reduce: Combine values
[1, 2, 3].reduce((sum, x) => sum + x, 0);  // 6

// Compose: Combine functions
const compose = (f, g) => (x) => f(g(x));
const double = x => x * 2;
const addOne = x => x + 1;
compose(double, addOne)(5);  // 12 (double(addOne(5)))

// Curry: Partial application
const curry = (fn) => (a) => (b) => fn(a, b);
const add = (a, b) => a + b;
const curriedAdd = curry(add);
curriedAdd(1)(2);  // 3

// Memoization: Cache results
const memoize = (fn) => {
    const cache = {};
    return (...args) => {
        const key = JSON.stringify(args);
        return cache[key] ?? (cache[key] = fn(...args));
    };
};
```

**Benefits of Functional Programming:**
- Predictable (pure functions)
- Easier to test
- Better for parallel processing
- Less side effects

**Sample Answer:**
"Higher-order functions take or return functions. Examples include map, filter, and reduce. Functional programming uses these patterns to write code with pure functions (same input = same output) and minimal side effects. Common patterns are composition (combining functions), currying (partial application), and memoization (caching results). It makes code more predictable and testable."

**Common Mistakes:**
- Not understanding pure functions
- Overusing functional patterns
- Performance issues with immutability
- Confusion between composition and currying

**Follow-up Questions:**
- What's a pure function?
- How does immutability relate to functional programming?
- When should you use functional patterns?

---

**Q18: How do you implement debouncing and throttling?**

**Expected Answer:**
Debouncing and throttling are techniques to limit function execution frequency, useful for performance-intensive operations.

**Debouncing:**
```javascript
// Execute after activity stops
function debounce(fn, delay) {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn(...args), delay);
    };
}

// Usage: search input (execute when user finishes typing)
input.addEventListener('input', debounce((e) => {
    search(e.target.value);
}, 300));
```

**Throttling:**
```javascript
// Execute at most once per interval
function throttle(fn, limit) {
    let inThrottle;
    return (...args) => {
        if (!inThrottle) {
            fn(...args);
            inThrottle = true;
            setTimeout(() => { inThrottle = false; }, limit);
        }
    };
}

// Usage: scroll event (execute at most every 300ms)
window.addEventListener('scroll', throttle(() => {
    updatePosition();
}, 300));
```

**Comparison:**
| Use Case | Debounce | Throttle |
|----------|----------|----------|
| Search input | Yes | No |
| Scroll events | No | Yes |
| Window resize | Yes | Maybe |
| Button clicks | Yes | No |

**Sample Answer:**
"Debouncing delays execution until activity stops—useful for search inputs where you wait for the user to finish typing. Throttling limits execution frequency—useful for scroll/resize where you want updates at regular intervals. Debounce executes after a delay with no executions, while throttle executes at most once per time interval."

**Common Mistakes:**
- Using the wrong pattern
- Not cleaning up timeouts
- Incorrect parameter passing
- Ignoring this binding

**Follow-up Questions:**
- How do you handle `this` binding?
- Can you combine debounce and throttle?
- What's the difference from using a flag?

---

**Q19: Explain the differences between shallow copy and deep copy.**

**Expected Answer:**
Shallow copy copies only the first level; deep copy recursively copies all nested values.

**Shallow Copy:**
```javascript
const original = { a: 1, b: { c: 2 } };

// Shallow copy (reference to b is shared)
const shallow = { ...original };
shallow.b.c = 99;
console.log(original.b.c);  // 99 (shared)
```

**Deep Copy:**
```javascript
// JSON method (works for most cases)
const deep = JSON.parse(JSON.stringify(original));
deep.b.c = 99;
console.log(original.b.c);  // 2 (independent)

// Recursive function (more flexible)
function deepClone(obj) {
    if (obj === null || typeof obj !== 'object') return obj;
    if (obj instanceof Array) return obj.map(deepClone);
    if (obj instanceof Date) return new Date(obj);
    if (obj instanceof Set) return new Set([...obj].map(deepClone));

    const cloned = {};
    for (const key in obj) {
        cloned[key] = deepClone(obj[key]);
    }
    return cloned;
}
```

**Methods:**
| Method | Shallow/Deep | Pros | Cons |
|--------|--------------|------|------|
| Spread `{...}` | Shallow | Simple, fast | Only first level |
| `Object.assign()` | Shallow | Standard | Only first level |
| `JSON.parse()` | Deep | Simple | Loses functions, dates, etc. |
| Recursive | Deep | Full control | Slower |
| `structuredClone()` | Deep | Native, handles many types | Not widely supported yet |

**Sample Answer:**
"Shallow copy copies only the top level—nested objects are still referenced. Deep copy recursively copies everything, creating independent copies. Use shallow copy for simple objects. Use deep copy when you need complete independence from the original. `JSON.parse(JSON.stringify())` works for most cases but doesn't handle functions or dates. A recursive function gives you full control."

**Common Mistakes:**
- Using shallow copy when deep copy is needed
- Forgetting `Date`, `Map`, `Set` handling
- Performance issues with unnecessary deep copies
- Not understanding reference vs. value

**Follow-up Questions:**
- Why does JSON method lose functions?
- How do you handle circular references?
- When do you actually need deep copy?

---

**Q20: What are Web APIs and how do you use Fetch?**

**Expected Answer:**
Web APIs are browser APIs for common tasks. Fetch API is for making HTTP requests.

**Fetch Basics:**
```javascript
// Simple GET
fetch('/api/data')
    .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
    })
    .then(data => console.log(data))
    .catch(error => console.error('Error:', error));

// With async/await
async function getData() {
    try {
        const response = await fetch('/api/data');
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error:', error);
    }
}

// POST request
async function createUser(user) {
    const response = await fetch('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    });
    return response.json();
}
```

**Common Web APIs:**
- **Fetch**: HTTP requests
- **LocalStorage**: Client-side storage
- **IntersectionObserver**: Detect visibility
- **MutationObserver**: Detect DOM changes
- **RequestAnimationFrame**: Smooth animations

**Sample Answer:**
"Fetch API is a modern way to make HTTP requests. It returns a Promise that resolves to a Response object. Always check `response.ok` before reading the body. Fetch only rejects on network errors, not HTTP errors like 404. Other useful Web APIs include LocalStorage for storing data, IntersectionObserver for detecting when elements become visible (lazy loading), and MutationObserver for tracking DOM changes."

**Common Mistakes:**
- Not checking `response.ok`
- Assuming status is in the Promise rejection
- Not setting headers for POST
- Not handling network errors

**Follow-up Questions:**
- How do you add headers to a Fetch request?
- What's the difference between `response.json()` and `response.text()`?
- How do you handle CORS?

---

## Level 3: Senior Developer (5+ Years)

### Architecture & Performance (5 questions)

**Q21: Describe the rendering process and how to optimize it.**

**Expected Answer:**
The browser rendering process has several stages; optimization focuses on minimizing reflows and repaints.

**Rendering Pipeline:**
1. **Parse**: HTML → DOM, CSS → CSSOM
2. **Compute**: Merge DOM + CSSOM → Render Tree
3. **Layout**: Calculate positions (reflow)
4. **Paint**: Rasterize pixels (repaint)
5. **Composite**: Combine layers

**Critical Rendering Path (CRP):**
- Minimize: DOM size, CSS complexity, JavaScript parsing
- Optimize: Above-the-fold content, compress assets
- Defer: Non-critical JavaScript, non-critical CSS

**Optimization Techniques:**
```javascript
// Bad: Forces reflow/repaint in loop
for (let i = 0; i < 100; i++) {
    element.style.left = i + 'px';  // Reflow each time
}

// Good: Batch DOM changes
element.style.left = '100px';  // One reflow

// Better: Use CSS animation
element.style.animation = 'moveRight 1s';  // GPU accelerated

// Debounce scroll events
window.addEventListener('scroll', debounce(() => {
    updatePositions();
}, 100));

// Use requestAnimationFrame
function animate() {
    element.style.transform = 'translateX(100px)';
    requestAnimationFrame(animate);
}
```

**Tools & Metrics:**
- **Core Web Vitals**: LCP, FID, CLS
- **Lighthouse**: Performance audits
- **DevTools**: Performance recording
- **WebPageTest**: Detailed analysis

**Sample Answer:**
"The browser parses HTML into a DOM tree, CSS into a CSSOM tree, then combines them into a Render Tree. It then calculates positions (layout/reflow) and rasterizes pixels (paint/repaint). Optimization focuses on minimizing these steps. Avoid forced reflows by batching DOM changes. Use CSS animations for smoothness (GPU accelerated). Defer non-critical JavaScript and CSS. Measure with Core Web Vitals (LCP, FID, CLS)."

**Common Mistakes:**
- Querying DOM in loops
- Unexpected reflows/repaints
- Large bundle sizes
- Not measuring actual performance

**Follow-up Questions:**
- What causes reflow vs. repaint?
- How do CSS transforms avoid reflow?
- What are Core Web Vitals?

---

**Q22: How do you handle state management in a large application?**

**Expected Answer:**
State management becomes critical in large applications to avoid prop drilling and scattered state.

**Patterns:**
1. **Redux/Flux Pattern**: Centralized store, actions, reducers
2. **Context API**: React-specific, good for moderate apps
3. **Event Bus**: Decoupled communication
4. **State Machines**: Predictable state transitions
5. **Reactive Programming**: Observables (RxJS)

**Simple Pattern (Vanilla JavaScript):**
```javascript
// Observer pattern
class StateManager {
    constructor(initialState) {
        this.state = initialState;
        this.listeners = new Set();
    }

    subscribe(listener) {
        this.listeners.add(listener);
        return () => this.listeners.delete(listener);
    }

    dispatch(action) {
        this.state = this.reduce(this.state, action);
        this.listeners.forEach(listener => listener(this.state));
    }

    reduce(state, action) {
        switch (action.type) {
            case 'INCREMENT':
                return { ...state, count: state.count + 1 };
            case 'DECREMENT':
                return { ...state, count: state.count - 1 };
            default:
                return state;
        }
    }
}

// Usage
const store = new StateManager({ count: 0 });
store.subscribe(state => console.log(state));
store.dispatch({ type: 'INCREMENT' });
```

**Key Principles:**
- **Predictability**: Same action → same result
- **Centralization**: Single source of truth
- **Traceability**: History of all changes
- **Scalability**: Grows with app

**Sample Answer:**
"State management is critical for large apps to avoid chaos. Patterns like Redux provide a centralized store, actions for changes, and reducers for logic. The key principles are predictability (same action gives same result) and centralization (single source of truth). You can also use React Context for smaller apps or implement a simple observer pattern with event emitters. The goal is making state changes predictable and trackable."

**Common Mistakes:**
- Overcomplicating for simple apps
- Mutating state directly
- Putting too much in state
- Not normalizing state shape

**Follow-up Questions:**
- How do you handle async actions?
- What's the difference between action and reducer?
- When should you use Context vs. Redux?

---

**Q23: Explain TypeScript's advanced type system features.**

**Expected Answer:**
TypeScript provides advanced typing mechanisms for type-safe applications.

**Advanced Features:**
```typescript
// 1. Generics with constraints
function process<T extends { length: number }>(item: T): T {
    console.log(item.length);
    return item;
}

// 2. Conditional types
type IsString<T> = T extends string ? true : false;

// 3. Mapped types
type Readonly<T> = { readonly [K in keyof T]: T[K]; };
type Getters<T> = {
    [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

// 4. Utility types
type Partial<T> = { [K in keyof T]?: T[K]; };
type Pick<T, K extends keyof T> = { [P in K]: T[P]; };
type Omit<T, K extends PropertyKey> = Pick<T, Exclude<keyof T, K>>;
type Record<K extends PropertyKey, T> = { [P in K]: T; };

// 5. Discriminated unions
type Result<T, E> =
    | { success: true; value: T }
    | { success: false; error: E };

// 6. Type guards
function isString(value: unknown): value is string {
    return typeof value === 'string';
}

// 7. Recursive types
type Json =
    | null | boolean | number | string
    | Json[] | { [key: string]: Json };

// 8. Template literal types
type Event = `on${Capitalize<'click'>}`;
```

**Performance Considerations:**
- Avoid recursive type complexity
- Use `type` for better inference
- Be careful with circular references
- Monitor compilation time

**Sample Answer:**
"TypeScript's advanced type system includes generics for reusable types, conditional types for type-level logic, mapped types for transforming existing types, and utility types for common patterns. Discriminated unions provide type safety for variant types. Type guards narrow types within code blocks. Template literal types create complex string literal types. These features enable writing very type-safe code but can be complex—use them judiciously."

**Common Mistakes:**
- Overcomplicating types
- Not using utility types
- Unclear constraints on generics
- Ignoring TypeScript errors

**Follow-up Questions:**
- What's the difference between `infer` and constraints?
- When should you use conditional types?
- How do decorators work in TypeScript?

---

**Q24: How do you structure and scale a web application?**

**Expected Answer:**
Scaling requires thoughtful architecture, separation of concerns, and team coordination.

**Architecture Patterns:**
```
src/
├── components/           # Reusable UI components
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.css
│   │   └── Button.test.tsx
│   └── Form/
├── pages/               # Page-level components
│   ├── Home/
│   └── Dashboard/
├── services/            # API calls, business logic
│   ├── api.ts
│   ├── auth.ts
│   └── data.ts
├── state/              # State management
│   ├── store.ts
│   └── slices/
├── hooks/              # Custom React hooks
│   ├── useAuth.ts
│   └── useFetch.ts
├── types/              # TypeScript types
│   └── index.ts
├── utils/              # Utility functions
│   └── helpers.ts
└── App.tsx
```

**Key Principles:**
1. **Separation of Concerns**: Each module has one responsibility
2. **Modularity**: Small, focused, reusable modules
3. **Layering**: Clear dependencies (components → services → API)
4. **Scalability**: Easy to add features without big refactors
5. **Testing**: Each layer independently testable

**Component Scaling:**
```typescript
// Presentational (dumb) components
// Props-based, no logic, easy to test
const Button: React.FC<ButtonProps> = ({ onClick, children }) => (
    <button onClick={onClick}>{children}</button>
);

// Container (smart) components
// Handle logic, fetch data, manage state
const UserList: React.FC = () => {
    const [users, setUsers] = useState([]);

    useEffect(() => {
        fetchUsers().then(setUsers);
    }, []);

    return <UserListView users={users} />;
};
```

**Sample Answer:**
"Scale by maintaining clear separation of concerns. Organize by feature or layer. Keep components small and single-responsibility. Separate presentational components (just UI) from container components (logic and data). Use services for API calls and business logic. Implement state management to avoid prop drilling. Write tests at each layer. Use TypeScript for type safety. Document APIs and component props. This makes the codebase maintainable as it grows."

**Common Mistakes:**
- No clear structure (spaghetti code)
- God components with too much logic
- Prop drilling instead of state management
- No clear API boundaries
- Insufficient testing

**Follow-up Questions:**
- How do you handle code splitting?
- What's the difference between feature-based and layer-based organization?
- How do you manage shared state?

---

**Q25: What are security best practices for web applications?**

**Expected Answer:**
Security requires defense-in-depth approach across multiple layers.

**XSS (Cross-Site Scripting) Prevention:**
```javascript
// Bad: Direct HTML insertion
element.innerHTML = userInput;

// Good: Text content (sanitized automatically)
element.textContent = userInput;

// Good: Use a library to sanitize
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(userInput);
```

**CSRF (Cross-Site Request Forgery) Prevention:**
```javascript
// Include token in requests
const response = await fetch('/api/action', {
    method: 'POST',
    headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
});
```

**Content Security Policy:**
```html
<!-- Restrict resource loading -->
<meta http-equiv="Content-Security-Policy" content="
    default-src 'self';
    script-src 'self' https://trusted-cdn.com;
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https:;
">
```

**HTTPS/TLS:**
- Always use HTTPS
- Use secure cookies: `Secure; HttpOnly; SameSite=Strict`

**Authentication/Authorization:**
- Use standard protocols (OAuth 2.0, JWT)
- Hash passwords (bcrypt, argon2)
- Implement rate limiting
- Use secure session management

**Dependencies:**
```bash
# Regularly update dependencies
npm audit
npm update

# Check for vulnerabilities
npm audit fix
```

**Data Security:**
- Never log sensitive data
- Encrypt sensitive data in transit and at rest
- Implement principle of least privilege
- Regular security audits

**Sample Answer:**
"Security requires a multi-layered approach. Prevent XSS by using `textContent` instead of `innerHTML`, sanitizing user input, and using CSP headers. Prevent CSRF with token validation. Always use HTTPS. Implement proper authentication with standard protocols. Hash passwords server-side. Set security headers (CSP, X-Frame-Options, etc.). Keep dependencies updated and audit regularly. Never trust user input. Use security libraries and tools rather than implementing custom solutions."

**Common Mistakes:**
- Direct HTML insertion of user input
- Trusting client-side validation
- Weak password hashing
- Storing sensitive data in localStorage
- Outdated dependencies
- Not using HTTPS

**Follow-up Questions:**
- What's the difference between XSS and CSRF?
- How do you safely store tokens?
- What are common security headers?

---

## Conclusion

These 25 questions cover the spectrum of web development interview topics from junior to senior levels. Study the answers, understand the concepts deeply, and practice explaining them clearly. Interviews aren't just about correct answers—they're about demonstrating problem-solving skills, communication, and depth of knowledge.

---

**Last Updated:** October 26, 2024
**Level:** Junior to Senior
**Total Questions:** 25
**Estimated Study Time:** 30-40 hours
