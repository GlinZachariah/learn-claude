# Web Technologies - Conceptual Questions

## Questions Directory

**Total Questions:** 40+
**Coverage:** HTML, CSS, JavaScript, TypeScript
**Difficulty Levels:** Beginner to Advanced

---

## HTML Questions (8 Questions)

### Q1: What is the difference between semantic and non-semantic HTML elements?

**Answer:**
- **Semantic HTML:** Elements with inherent meaning (e.g., `<header>`, `<nav>`, `<article>`, `<footer>`)
  - Improves SEO and accessibility
  - Provides context to browsers and screen readers
  - Makes code more maintainable

- **Non-semantic HTML:** Generic elements like `<div>` and `<span>`
  - No inherent meaning
  - Require additional context (CSS classes, ARIA attributes)
  - Less accessible without proper ARIA roles

**Example:**
```html
<!-- Semantic - Better -->
<article>
    <header>
        <h1>Article Title</h1>
    </header>
    <main>Content...</main>
    <footer>Posted by Author</footer>
</article>

<!-- Non-semantic - Avoid -->
<div class="article">
    <div class="header">
        <h1>Article Title</h1>
    </div>
    <div class="content">Content...</div>
    <div class="footer">Posted by Author</div>
</div>
```

**Importance:**
- Accessibility compliance (WCAG)
- SEO optimization
- Code readability and maintenance
- Assistive technology compatibility

**Difficulty:** Beginner | **Tags:** #HTML #Accessibility #Semantics

---

### Q2: Explain the purpose of the viewport meta tag in responsive web design.

**Answer:**
The viewport meta tag controls how a page is displayed on mobile devices.

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

**Components:**
- `width=device-width`: Set viewport width to device width
- `initial-scale=1.0`: Initial zoom level
- `maximum-scale=5.0`: Maximum zoom allowed
- `minimum-scale=0.5`: Minimum zoom allowed
- `user-scalable=yes`: Allow user zooming

**Why it matters:**
- Without it, mobile browsers assume fixed width (980px)
- Users see tiny, unreadable content
- Breaks responsive layouts
- Critical for mobile UX

**Example Issues:**
```html
<!-- Without viewport meta tag -->
<!-- Page appears tiny on mobile, requires zooming to read -->

<!-- With viewport meta tag -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- Page scales to device width, readable without zooming -->
```

**Difficulty:** Beginner | **Tags:** #HTML #Responsive #Mobile

---

### Q3: What is the difference between block, inline, and inline-block elements?

**Answer:**
- **Block Elements:** Take full width, start new line
  - Examples: `<div>`, `<p>`, `<header>`, `<section>`
  - Respect margin, padding, width, height

- **Inline Elements:** Flow with text, no line break
  - Examples: `<span>`, `<a>`, `<strong>`, `<em>`
  - Ignore top/bottom margin, don't respect width/height
  - Padding works but may overlap

- **Inline-Block:** Hybrid behavior
  - Flow inline but respect dimensions
  - Examples: `<img>`, `<button>`, `<input>`
  - Respect all margin, padding, width, height

**Example:**
```html
<!-- Block -->
<div>Block 1</div>  <!-- Takes full width, new line -->
<div>Block 2</div>

<!-- Inline -->
<span>Inline 1</span><span>Inline 2</span>  <!-- Flow together -->

<!-- Inline-block -->
<img src="image.jpg">  <!-- Flows inline but respects dimensions -->
```

**Difficulty:** Beginner | **Tags:** #CSS #Display #Layout

---

### Q4: Explain Web Components and their benefits.

**Answer:**
Web Components are a set of web platform APIs for creating encapsulated, reusable components.

**Three Core Technologies:**

1. **Custom Elements**
   - Define custom HTML elements
   - Lifecycle hooks (connectedCallback, disconnectedCallback)
   - Attributes and properties

2. **Shadow DOM**
   - Encapsulated DOM and CSS
   - Scoped styles don't leak out
   - Private internal structure

3. **Templates & Slots**
   - `<template>`: Inert HTML to clone
   - `<slot>`: Placeholder for external content

**Example:**
```html
<my-card title="Card">
    Content here
</my-card>

<script>
    class MyCard extends HTMLElement {
        connectedCallback() {
            const title = this.getAttribute('title');
            this.attachShadow({ mode: 'open' }).innerHTML = `
                <style>
                    .card { border: 1px solid #ccc; }
                </style>
                <div class="card">
                    <h2>${title}</h2>
                    <slot></slot>
                </div>
            `;
        }
    }
    customElements.define('my-card', MyCard);
</script>
```

**Benefits:**
- Encapsulation (scoped styles and DOM)
- Reusability across projects
- Framework-agnostic
- Native browser support
- No build tools required

**Difficulty:** Intermediate | **Tags:** #WebComponents #HTML #Encapsulation

---

### Q5: What is ARIA and why is it important for accessibility?

**Answer:**
ARIA (Accessible Rich Internet Applications) provides semantic meaning to interactive elements.

**Key ARIA Concepts:**

1. **Roles:** Define element purpose
   ```html
   <div role="button">Click me</div>
   <div role="navigation">Nav items</div>
   ```

2. **Properties:** Describe element characteristics
   ```html
   <button aria-label="Close menu">×</button>
   <div aria-expanded="false">Content</div>
   ```

3. **States:** Describe current condition
   ```html
   <input aria-invalid="true">
   <button aria-pressed="true">Toggle</button>
   ```

**Why it matters:**
- Screen readers understand dynamic content
- Improves keyboard navigation
- Makes interactive components accessible
- WCAG compliance

**Example - Accessible Modal:**
```html
<div role="dialog" aria-labelledby="title" aria-modal="true">
    <h2 id="title">Confirm Action</h2>
    <p>Are you sure?</p>
    <button>Yes</button>
    <button>No</button>
</div>
```

**Difficulty:** Intermediate | **Tags:** #Accessibility #ARIA #a11y

---

### Q6: Explain form validation and its importance.

**Answer:**
Form validation ensures data quality before submission.

**Types:**

1. **HTML5 Validation** (built-in)
   ```html
   <input type="email" required>
   <input type="number" min="0" max="100">
   <input pattern="[A-Z]{3}">
   ```

2. **CSS Validation Styling**
   ```css
   input:invalid { border-color: red; }
   input:valid { border-color: green; }
   ```

3. **JavaScript Validation**
   ```javascript
   if (form.checkValidity()) {
       form.submit();
   }
   ```

**Benefits:**
- Prevent invalid data in database
- Improve user experience with immediate feedback
- Reduce server load
- Security (prevent malicious input)

**Difficulty:** Beginner | **Tags:** #Forms #Validation #HTML

---

### Q7: What is the difference between attributes and properties in HTML?

**Answer:**
- **Attributes:** Defined in HTML, read-only text
  ```html
  <input type="text" value="default" data-id="123">
  ```

- **Properties:** JavaScript object members, can be changed
  ```javascript
  input.value = "new value";
  input.disabled = true;
  input.dataset.id = "456";
  ```

**Key Differences:**
| Attribute | Property |
|-----------|----------|
| String values | Any type |
| HTML source | JavaScript object |
| Static initially | Dynamic |
| Visible in inspector | Not visible |

**Example:**
```javascript
// Attributes
input.getAttribute('value');      // "default"

// Properties
input.value = "changed";          // Updates DOM
input.getAttribute('value');      // Still "default"
input.value;                      // "changed"
```

**Difficulty:** Intermediate | **Tags:** #HTML #DOM #Properties

---

### Q8: Explain meta tags and their role in SEO.

**Answer:**
Meta tags provide metadata about the HTML document.

**Important Meta Tags:**

```html
<!-- Character encoding -->
<meta charset="UTF-8">

<!-- Viewport for responsive -->
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Description for search results -->
<meta name="description" content="Page summary">

<!-- Keywords (less important now) -->
<meta name="keywords" content="keyword1, keyword2">

<!-- Open Graph for social sharing -->
<meta property="og:title" content="Title">
<meta property="og:description" content="Description">
<meta property="og:image" content="image.jpg">
<meta property="og:url" content="https://example.com">

<!-- Canonical URL (prevent duplicates) -->
<link rel="canonical" href="https://example.com/page">

<!-- Theme color -->
<meta name="theme-color" content="#2563eb">
```

**SEO Impact:**
- Description appears in search results
- Open Graph improves social sharing
- Canonical prevents duplicate content penalties
- Character encoding prevents display issues

**Difficulty:** Beginner | **Tags:** #SEO #Meta #HTML

---

## CSS Questions (8 Questions)

### Q9: Explain CSS specificity and how it affects rule application.

**Answer:**
Specificity determines which CSS rule is applied when multiple rules target the same element.

**Specificity Calculation:**
```
(ID selectors, Class selectors, Element selectors)

Examples:
p                           0-0-1  (1 element)
.class                      0-1-0  (1 class)
#id                         1-0-0  (1 ID)
div.class#id                1-1-1  (1 ID, 1 class, 1 element)
```

**Hierarchy (highest to lowest):**
1. Inline styles (`style="color: red"`) - 1-0-0-0
2. ID selectors (#id) - 1-0-0
3. Class selectors (.class) - 0-1-0
4. Element selectors (p) - 0-0-1
5. Universal selector (*) - 0-0-0

**Example:**
```css
p { color: blue; }              /* 0-0-1 */
.text { color: green; }         /* 0-1-0 - Wins */
#special { color: red; }        /* 1-0-0 - Wins over both */

/* Even multiple low specificity loses to higher */
p.text.box { color: purple; }   /* 0-2-1 - Still loses to #special */
```

**Best Practice:**
- Avoid ID selectors in CSS (too specific)
- Use classes for flexibility
- Avoid `!important` (breaks cascade)

**Difficulty:** Beginner | **Tags:** #CSS #Specificity #Cascade

---

### Q10: Explain Flexbox and when to use it vs Grid.

**Answer:**

**Flexbox:** One-dimensional layout (row or column)
```css
.flex-container {
    display: flex;
    justify-content: space-between;  /* Main axis */
    align-items: center;              /* Cross axis */
    gap: 20px;
}
```

**Use Flexbox for:**
- Navigation bars
- Component layouts
- Aligning items in one direction
- Equal-width columns

**Grid:** Two-dimensional layout (rows and columns)
```css
.grid-container {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    grid-template-rows: auto 1fr auto;
    gap: 20px;
}
```

**Use Grid for:**
- Page layouts
- Complex positioning
- Control over both axes
- Overlapping elements

**Comparison:**
| Feature | Flexbox | Grid |
|---------|---------|------|
| Dimensions | 1D | 2D |
| Child alignment | Along axis | Rows and columns |
| Content-based | Better | Structure-based |
| Browser support | All modern | All modern |

**Example:**
```html
<!-- Flexbox: Header with nav -->
<header style="display: flex; justify-content: space-between;">
    <logo>Logo</logo>
    <nav>Nav items</nav>
</header>

<!-- Grid: Page layout -->
<div style="display: grid; grid-template-areas: 'header' 'sidebar main' 'footer';">
    <header style="grid-area: header">Header</header>
    <aside style="grid-area: sidebar">Sidebar</aside>
    <main style="grid-area: main">Main</main>
    <footer style="grid-area: footer">Footer</footer>
</div>
```

**Difficulty:** Intermediate | **Tags:** #CSS #Flexbox #Grid #Layout

---

### Q11: What are CSS custom properties (variables) and how do they enable theming?

**Answer:**
CSS variables allow storing reusable values, enabling dynamic theming.

**Defining Variables:**
```css
:root {
    --primary-color: #2563eb;
    --secondary-color: #1e40af;
    --spacing-base: 1rem;
    --border-radius: 0.375rem;
}

/* Light theme */
html.light {
    --bg-primary: #ffffff;
    --text-primary: #000000;
}

/* Dark theme */
html.dark {
    --bg-primary: #1f2937;
    --text-primary: #f9fafb;
}
```

**Using Variables:**
```css
.button {
    background: var(--primary-color);
    padding: var(--spacing-base);
    border-radius: var(--border-radius);
}

.button:hover {
    background: var(--secondary-color);
}
```

**Benefits:**
- Centralized color/spacing management
- Easy theme switching
- Reduced code duplication
- Dynamic changes with JavaScript

**JavaScript Integration:**
```javascript
// Switch theme
document.documentElement.classList.toggle('dark');

// Or set directly
document.documentElement.style.setProperty('--primary-color', '#ff0000');
```

**Difficulty:** Intermediate | **Tags:** #CSS #Variables #Theming

---

### Q12: Explain the difference between margin, padding, and border in the box model.

**Answer:**
The CSS box model defines how element dimensions are calculated.

**Components (outside to inside):**

1. **Margin:** Space outside border
   - Transparent, no background
   - Collapses with adjacent margins
   - Doesn't affect element size (usually)

2. **Border:** Visible line around padding
   - Part of element size
   - Can have color, width, style

3. **Padding:** Space inside border, around content
   - Respects background color
   - Doesn't collapse
   - Part of element size

4. **Content:** Actual content (text, images)

**Visual:**
```
┌─────────────────────────────┐
│      Margin (outside)        │
│  ┌──────────────────────┐    │
│  │  Border              │    │
│  │  ┌────────────────┐  │    │
│  │  │ Padding        │  │    │
│  │  │ ┌────────────┐ │  │    │
│  │  │ │  Content   │ │  │    │
│  │  │ └────────────┘ │  │    │
│  │  └────────────────┘  │    │
│  └──────────────────────┘    │
└─────────────────────────────┘
```

**box-sizing Property:**
```css
/* Default: size = content only */
.default {
    box-sizing: content-box;
    width: 100px;              /* Content width */
}

/* Modern: size includes padding and border */
.modern {
    box-sizing: border-box;
    width: 100px;              /* Total width including padding/border */
}
```

**Difficulty:** Beginner | **Tags:** #CSS #BoxModel #Layout

---

### Q13: Explain responsive design and mobile-first approach.

**Answer:**
Responsive design adapts layout to different screen sizes.

**Mobile-first Approach:**
Start with mobile styles, enhance for larger screens.

```css
/* Mobile first (base styles) */
.container {
    width: 100%;
    padding: 10px;
}

/* Tablet */
@media (min-width: 768px) {
    .container {
        width: 750px;
        padding: 20px;
    }
}

/* Desktop */
@media (min-width: 1024px) {
    .container {
        width: 960px;
    }
}

/* Large screen */
@media (min-width: 1440px) {
    .container {
        width: 1320px;
    }
}
```

**Benefits of Mobile-first:**
- Better performance (don't load unnecessary features)
- Focuses on essential content
- Progressive enhancement
- Better mobile UX

**Viewport Meta Tag (Required):**
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

**Flexible Units:**
```css
.responsive {
    width: 100%;                /* Relative to parent */
    max-width: 1200px;          /* Prevents too wide */
    padding: 5%;                /* Percentage */
    font-size: 2vw;             /* Viewport width */
    margin-bottom: clamp(1rem, 5%, 3rem); /* Responsive with limits */
}
```

**Difficulty:** Beginner | **Tags:** #CSS #Responsive #Mobile

---

### Q14: What are CSS animations and transitions, and how do they differ?

**Answer:**

**Transitions:** Smooth change between two states
```css
.button {
    background: blue;
    transition: background 0.3s ease-in-out;
}

.button:hover {
    background: red;  /* Smoothly transitions */
}
```

**Animations:** Keyframe-based, can loop, repeat
```css
@keyframes slide-in {
    from { transform: translateX(-100%); }
    to { transform: translateX(0); }
}

.modal {
    animation: slide-in 0.5s ease-in-out forwards;
}
```

**Key Differences:**
| Feature | Transition | Animation |
|---------|-----------|-----------|
| Trigger | State change | Automatic |
| Keyframes | Two states | Multiple |
| Loop | No | Yes |
| Control | Limited | Full |
| Delay | Yes | Yes |

**Timing Functions:**
```css
transition-timing-function: linear;      /* Constant speed */
transition-timing-function: ease;        /* Default, smooth */
transition-timing-function: ease-in;     /* Slow start */
transition-timing-function: ease-out;    /* Slow end */
transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); /* Custom */
```

**Performance Tip:**
Use `transform` and `opacity` for smooth animations (GPU accelerated).

```css
/* Good - GPU accelerated */
.box {
    transition: transform 0.3s;
}
.box:hover {
    transform: scale(1.1);
}

/* Bad - CPU intensive */
.box:hover {
    width: 110px;      /* Triggers layout recalculation */
    height: 110px;
}
```

**Difficulty:** Intermediate | **Tags:** #CSS #Animations #Performance

---

### Q15: Explain CSS preprocessors (SASS/SCSS) and their benefits.

**Answer:**
Preprocessors extend CSS with programming features, compiled to standard CSS.

**Key Features of SCSS:**

1. **Variables**
   ```scss
   $primary-color: #2563eb;
   $spacing: 1rem;

   .button {
       background: $primary-color;
       padding: $spacing;
   }
   ```

2. **Nesting**
   ```scss
   .card {
       border: 1px solid #ccc;

       .title {
           font-size: 1.5rem;
       }

       &:hover {
           box-shadow: 0 4px 8px rgba(0,0,0,0.1);
       }
   }
   ```

3. **Mixins (reusable styles)**
   ```scss
   @mixin flex-center {
       display: flex;
       justify-content: center;
       align-items: center;
   }

   .container {
       @include flex-center;
   }
   ```

4. **Functions & Operations**
   ```scss
   $base-size: 16px;
   $double-size: $base-size * 2;
   ```

**Benefits:**
- Write less code
- Better organization
- Reusable components
- Easier maintenance
- Variables for consistency

**Important Note:**
Browsers don't understand SCSS. Must compile to CSS during build.

**Difficulty:** Intermediate | **Tags:** #CSS #SCSS #Preprocessors

---

## JavaScript Questions (12 Questions)

### Q16: Explain the difference between var, let, and const.

**Answer:**

| Feature | var | let | const |
|---------|-----|-----|-------|
| Scope | Function | Block | Block |
| Redeclaration | Yes | No | No |
| Reassignment | Yes | Yes | No |
| Hoisting | Hoisted (undefined) | TDZ | TDZ |
| Use | Avoid | Prefer | Prefer |

**Scoping Example:**
```javascript
function test() {
    if (true) {
        var x = 1;      // Function scoped
        let y = 2;      // Block scoped
        const z = 3;    // Block scoped
    }
    console.log(x);     // 1 (accessible)
    console.log(y);     // ReferenceError
    console.log(z);     // ReferenceError
}
```

**Best Practice:**
```javascript
// 1. Use const by default
const user = { name: 'John' };

// 2. Use let when you need to reassign
let count = 0;
count++;

// 3. Avoid var
var oldStyle = 'avoid';  // ❌
```

**Difficulty:** Beginner | **Tags:** #JavaScript #Variables #Scope

---

### Q17: Explain closures and their practical use.

**Answer:**
A closure is a function that has access to variables from its outer scope, even after the outer function returns.

**Simple Example:**
```javascript
function outer(x) {
    function inner(y) {
        return x + y;  // Access to x from outer scope
    }
    return inner;
}

const add5 = outer(5);
console.log(add5(3));  // 8 - closure remembers x=5
```

**Practical Uses:**

1. **Data Privacy**
   ```javascript
   function createCounter() {
       let count = 0;  // Private variable

       return {
           increment: () => ++count,
           decrement: () => --count,
           get: () => count
       };
   }

   const counter = createCounter();
   counter.increment();      // count not accessible directly
   ```

2. **Function Factories**
   ```javascript
   function createMultiplier(n) {
       return (x) => x * n;
   }

   const double = createMultiplier(2);
   const triple = createMultiplier(3);
   ```

3. **Event Handlers with Data**
   ```javascript
   for (let i = 1; i <= 3; i++) {
       button.addEventListener('click', () => {
           console.log(i);  // Closure captures current i
       });
   }
   ```

**Important:** `let` and `const` create new bindings per iteration (for closure benefits).

**Difficulty:** Intermediate | **Tags:** #JavaScript #Closures #Functions

---

### Q18: Explain asynchronous JavaScript (callbacks, promises, async/await).

**Answer:**

**Callbacks (Old Way - Callback Hell)**
```javascript
fetchData(userId, (user) => {
    fetchPosts(user.id, (posts) => {
        fetchComments(posts[0].id, (comments) => {
            console.log(comments);  // Deeply nested
        });
    });
});
```

**Promises (Better)**
```javascript
fetchData(userId)
    .then(user => fetchPosts(user.id))
    .then(posts => fetchComments(posts[0].id))
    .then(comments => console.log(comments))
    .catch(error => console.error(error));
```

**Async/Await (Best)**
```javascript
async function getComments(userId) {
    try {
        const user = await fetchData(userId);
        const posts = await fetchPosts(user.id);
        const comments = await fetchComments(posts[0].id);
        return comments;
    } catch (error) {
        console.error(error);
    }
}
```

**Parallel Operations:**
```javascript
// Sequential (slower)
const user = await fetchUser(1);
const posts = await fetchPosts(user.id);  // Wait for user first

// Parallel (faster)
const [user, posts] = await Promise.all([
    fetchUser(1),
    fetchPosts(1)
]);
```

**Promise States:**
- **Pending:** Initial state
- **Fulfilled:** Operation succeeded
- **Rejected:** Operation failed

**Difficulty:** Intermediate | **Tags:** #JavaScript #Async #Promises

---

### Q19: Explain the event loop and how JavaScript executes code.

**Answer:**
JavaScript is single-threaded but handles async operations through the event loop.

**Three Components:**

1. **Call Stack:** Executes synchronous code
2. **Web APIs:** Handle async operations (setTimeout, fetch, etc.)
3. **Task Queue/Microtask Queue:** Hold callbacks ready to execute

**Execution Order:**
```javascript
console.log('1');  // Synchronous - executes immediately

setTimeout(() => {
    console.log('2');  // Macrotask - executes after stack is empty
}, 0);

Promise.resolve()
    .then(() => console.log('3'));  // Microtask - executes before macrotask

console.log('4');  // Synchronous - executes immediately

// Output: 1, 4, 3, 2
```

**Why?**
1. Synchronous code (1, 4) executes first
2. Microtasks (Promise - 3) execute after sync, before macrotasks
3. Macrotasks (setTimeout - 2) execute last

**Diagram:**
```
Call Stack: [console.log('1')]
           → Prints '1'
           → [setTimeout...]
           → Prints '4'

Event Loop checks:
1. Call Stack empty? Yes
2. Microtask Queue has items? Yes → Execute Promise callback → Prints '3'
3. Macrotask Queue has items? Yes → Execute setTimeout → Prints '2'
```

**Difficulty:** Advanced | **Tags:** #JavaScript #EventLoop #Async

---

### Q20: Explain prototypal inheritance and the prototype chain.

**Answer:**
JavaScript uses prototypes for inheritance, not classical classes (until ES6).

**Prototype Chain:**
```javascript
const animal = {
    speak() { return 'sound'; }
};

const dog = Object.create(animal);
dog.name = 'Buddy';

dog.speak();  // Finds speak() in prototype chain
```

**How it works:**
1. Look for property on object itself
2. Look in object's `__proto__`
3. Look in `__proto__.__proto__`
4. Continue until found or end of chain

**Constructor Functions (Old Pattern):**
```javascript
function Animal(name) {
    this.name = name;
}

Animal.prototype.speak = function() {
    return `${this.name} speaks`;
};

const dog = new Animal('Buddy');
dog.speak();  // Finds speak in Animal.prototype
```

**ES6 Classes (Modern):**
```javascript
class Animal {
    constructor(name) {
        this.name = name;
    }

    speak() {
        return `${this.name} speaks`;
    }
}

class Dog extends Animal {
    speak() {
        return `${this.name} barks`;
    }
}
```

**Prototype Chain Diagram:**
```
dog instance
    ↓ [[Prototype]]
Dog.prototype { constructor, speak() }
    ↓ [[Prototype]]
Animal.prototype { constructor, speak() }
    ↓ [[Prototype]]
Object.prototype { ... }
    ↓ [[Prototype]]
null
```

**Difficulty:** Intermediate | **Tags:** #JavaScript #Prototypes #Inheritance

---

### Q21: Explain the this keyword and its binding rules.

**Answer:**
`this` refers to the object that calls the function.

**Binding Rules (Priority Order):**

1. **new binding** (Constructor)
   ```javascript
   function Person(name) {
       this.name = name;  // this = new object
   }
   new Person('John');
   ```

2. **Explicit binding** (call, apply, bind)
   ```javascript
   function greet() { return this.name; }

   const person = { name: 'John' };
   greet.call(person);        // 'John'
   greet.apply(person);       // 'John'
   greet.bind(person)();      // 'John'
   ```

3. **Implicit binding** (Method call)
   ```javascript
   const obj = {
       name: 'John',
       greet() { return this.name; }  // this = obj
   };
   obj.greet();  // 'John'
   ```

4. **Default binding** (Global)
   ```javascript
   function greet() { return this; }
   greet();  // window (browser) or global (Node)
   ```

**Arrow Functions:** Lexical this
```javascript
const obj = {
    name: 'John',
    greet: () => this.name  // this = outer scope, not obj
};
```

**Common Mistake:**
```javascript
const obj = {
    value: 10,
    getValue() {
        setTimeout(function() {
            console.log(this.value);  // undefined - this is window
        }, 100);
    }
};

// Solution: Use arrow function
setTimeout(() => {
    console.log(this.value);  // Lexical this
}, 100);
```

**Difficulty:** Intermediate | **Tags:** #JavaScript #this #Binding

---

### Q22: Explain the Document Object Model (DOM) and common manipulation techniques.

**Answer:**
The DOM is a tree representation of HTML elements, accessible via JavaScript.

**Selecting Elements:**
```javascript
document.querySelector('.class');        // First match
document.querySelectorAll('.class');     // All matches
document.getElementById('id');           // By ID
document.getElementsByClassName('cls');  // By class (live collection)
```

**Modifying Content:**
```javascript
element.textContent = "Text only";      // Set text
element.innerHTML = "<b>HTML</b>";      // Set HTML (XSS risk)
element.innerText = "Rendered text";    // Visible text
```

**Modifying Attributes:**
```javascript
element.setAttribute('data-id', '123');
element.getAttribute('data-id');         // '123'
element.removeAttribute('data-id');
element.classList.add('active');
element.classList.remove('inactive');
element.classList.toggle('hidden');
```

**DOM Traversal:**
```javascript
element.parentElement;
element.children;           // Direct children only
element.childNodes;         // Include text nodes
element.firstChild;
element.lastChild;
element.nextSibling;
element.previousSibling;
element.closest('.parent'); // Find ancestor
```

**Creating/Removing Elements:**
```javascript
const div = document.createElement('div');
div.textContent = 'Hello';
parent.appendChild(div);

element.remove();
parent.removeChild(element);
parent.replaceChild(newElement, oldElement);
```

**Difficulty:** Beginner | **Tags:** #JavaScript #DOM #Manipulation

---

### Q23: Explain event handling, delegation, and the event object.

**Answer:**

**Basic Event Listening:**
```javascript
button.addEventListener('click', (event) => {
    console.log(event.type);          // 'click'
    console.log(event.target);         // Element clicked
    console.log(event.currentTarget);  // Element listener attached to
    event.preventDefault();             // Prevent default behavior
    event.stopPropagation();            // Stop bubbling
});
```

**Event Delegation (Efficient for Many Elements):**
```javascript
// Instead of adding listener to each item
ul.addEventListener('click', (event) => {
    if (event.target.matches('li')) {
        console.log('Clicked:', event.target.textContent);
    }
});
```

**Common Events:**
```
Mouse: click, dblclick, mouseenter, mouseleave, mousemove
Keyboard: keydown, keyup, keypress
Form: submit, change, input, focus, blur
Window: load, DOMContentLoaded, scroll, resize
```

**Event Object Properties:**
```javascript
event.type;           // 'click', 'submit', etc.
event.target;         // Element that triggered event
event.currentTarget;  // Element with listener
event.key;            // Key name (keyboard events)
event.code;           // Physical key
event.x, event.y;     // Mouse position
event.shiftKey;       // Modifier keys
event.altKey;
event.ctrlKey;
event.metaKey;
```

**Custom Events:**
```javascript
const event = new CustomEvent('myEvent', {
    detail: { message: 'Hello' },
    bubbles: true,
    cancelable: true
});

element.dispatchEvent(event);

element.addEventListener('myEvent', (e) => {
    console.log(e.detail.message);
});
```

**Difficulty:** Intermediate | **Tags:** #JavaScript #Events #Delegation

---

### Q24: Explain higher-order functions and functional programming in JavaScript.

**Answer:**
Higher-order functions take or return functions, enabling functional programming.

**Functions as Arguments:**
```javascript
function applyTwice(fn, value) {
    return fn(fn(value));
}

const double = x => x * 2;
applyTwice(double, 5);  // 20
```

**Functions as Return Values:**
```javascript
function createMultiplier(multiplier) {
    return (number) => number * multiplier;
}

const double = createMultiplier(2);
const triple = createMultiplier(3);

double(5);   // 10
triple(5);   // 15
```

**Function Composition:**
```javascript
const compose = (...fns) => x =>
    fns.reduceRight((v, f) => f(v), x);

const add1 = x => x + 1;
const double = x => x * 2;

const add1ThenDouble = compose(double, add1);
add1ThenDouble(5);  // (5+1)*2 = 12
```

**Array Higher-Order Methods:**
```javascript
arr.map(x => x * 2);              // Transform
arr.filter(x => x > 5);           // Filter
arr.reduce((acc, x) => acc + x, 0); // Aggregate
arr.find(x => x > 5);             // First match
arr.some(x => x > 5);             // Any match
arr.every(x => x > 0);            // All match
```

**Partial Application & Currying:**
```javascript
const add = (a, b, c) => a + b + c;

// Partial application
const addWith5 = (b, c) => add(5, b, c);
addWith5(2, 3);  // 10

// Currying (automatic)
const curry = f => a => b => c => f(a, b, c);
const curriedAdd = curry(add);
curriedAdd(1)(2)(3);  // 6
```

**Difficulty:** Advanced | **Tags:** #JavaScript #FunctionalProgramming #HigherOrder

---

### Q25: Explain module systems (CommonJS, ES6 modules) and their differences.

**Answer:**

**CommonJS (Node.js)**
```javascript
// Export
module.exports = {
    add: (a, b) => a + b,
    multiply: (a, b) => a * b
};

// Import
const math = require('./math.js');
math.add(2, 3);
```

**ES6 Modules (Modern Standard)**
```javascript
// Named exports
export const add = (a, b) => a + b;
export const multiply = (a, b) => a * b;

// Default export
export default class Calculator { }

// Imports
import Calculator from './calc.js';
import { add, multiply } from './math.js';
import { add as addition } from './math.js';  // Rename
import * as math from './math.js';
```

**Key Differences:**
| Feature | CommonJS | ES6 |
|---------|----------|-----|
| Syntax | require/module.exports | import/export |
| Loading | Synchronous | Asynchronous |
| Environment | Node.js | Browsers (with bundler) |
| Tree-shaking | No | Yes |
| Default | All modules | Default export |

**Dynamic Imports (Both):**
```javascript
// ES6 Dynamic
import('./module.js').then(module => {
    module.doSomething();
});

// Or with async/await
const module = await import('./module.js');

// Node.js Dynamic (since v12.20)
import('chalk').then(({ default: chalk }) => {
    console.log(chalk.red('Error!'));
});
```

**Benefits of ES6 Modules:**
- Tree-shaking (remove unused code)
- Static analysis possible
- Better tooling support
- Standard for web and Node.js

**Difficulty:** Intermediate | **Tags:** #JavaScript #Modules #ES6

---

## TypeScript Questions (6 Questions)

### Q26: Explain TypeScript's type system and why it matters.

**Answer:**
TypeScript adds static typing to JavaScript, catching errors at compile-time.

**Basic Types:**
```typescript
const name: string = "John";
const age: number = 30;
const isActive: boolean = true;
const items: number[] = [1, 2, 3];
const tuple: [string, number] = ["John", 30];
const unknown: any = "could be anything";  // Avoid!
const value: unknown = "type-safe any";
```

**Benefits:**
- Catch errors before runtime
- Better IDE autocomplete
- Self-documenting code
- Easier refactoring
- Reduced bugs in production

**Type Inference:**
```typescript
const x = 10;  // TypeScript infers: number
// x = "string";  // Error - can't assign string to number

const name = "John";
// name = 30;  // Error - can't assign number to string
```

**Union Types:**
```typescript
let id: string | number = "123";
id = 456;  // Valid

function printId(id: string | number) {
    if (typeof id === 'string') {
        console.log(id.toUpperCase());
    } else {
        console.log(id.toFixed(2));
    }
}
```

**Difficulty:** Beginner | **Tags:** #TypeScript #Types #Static

---

### Q27: Explain interfaces and types in TypeScript.

**Answer:**

**Types:**
```typescript
type User = {
    name: string;
    age: number;
    email?: string;  // Optional
    readonly id: number;  // Read-only
};

const user: User = {
    id: 1,
    name: "John",
    age: 30
};
```

**Interfaces:**
```typescript
interface Animal {
    name: string;
    speak(): string;
}

interface Flyable {
    fly(): void;
}

class Bird implements Animal, Flyable {
    name: string;

    constructor(name: string) {
        this.name = name;
    }

    speak() { return "chirp"; }
    fly() { }
}
```

**Differences:**
| Feature | Type | Interface |
|---------|------|-----------|
| Syntax | Type alias | Interface definition |
| Extends | & (intersection) | extends |
| Merging | No | Yes |
| Primitives | Yes | No |
| Tuples | Yes | No |
| Functions | Yes | Yes |

**When to Use:**
- **Type:** Unions, primitives, functions, complex types
- **Interface:** Objects, class contracts, extendable

**Merging Interfaces:**
```typescript
interface User {
    name: string;
}

interface User {
    age: number;
}

// Combined: User has name and age
const user: User = { name: "John", age: 30 };
```

**Difficulty:** Intermediate | **Tags:** #TypeScript #Interfaces #Types

---

### Q28: Explain generics and type constraints.

**Answer:**
Generics enable reusable, type-safe code that works with any type.

**Generic Functions:**
```typescript
function identity<T>(arg: T): T {
    return arg;
}

identity<string>("hello");
identity(42);  // Type inference
```

**Generic Constraints:**
```typescript
function getLength<T extends { length: number }>(obj: T): number {
    return obj.length;
}

getLength("hello");      // 5
getLength([1, 2, 3]);   // 3
getLength({ length: 5 }); // 5
// getLength(123);      // Error - no length property
```

**Generic Classes:**
```typescript
class Container<T> {
    constructor(private value: T) {}

    getValue(): T {
        return this.value;
    }
}

const stringContainer = new Container<string>("hello");
const numberContainer = new Container<number>(123);
```

**Keyof Constraint:**
```typescript
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
}

const user = { name: "John", age: 30 };
getProperty(user, "name");    // "John"
// getProperty(user, "email");  // Error - email not in User
```

**Conditional Types:**
```typescript
type IsString<T> = T extends string ? true : false;

type A = IsString<"hello">;  // true
type B = IsString<number>;   // false
```

**Difficulty:** Advanced | **Tags:** #TypeScript #Generics #Constraints

---

### Q29: Explain utility types and how they reduce boilerplate.

**Answer:**
Utility types provide type transformations for common patterns.

**Partial<T> - Make all properties optional:**
```typescript
type User = { name: string; age: number; };
type PartialUser = Partial<User>;
// Same as: { name?: string; age?: number; }

const user: PartialUser = { name: "John" };  // Valid
```

**Required<T> - Make all properties required:**
```typescript
type RequiredUser = Required<User>;
// Same as: { name: string; age: number; } (no optionals)
```

**Pick<T, K> - Select subset of properties:**
```typescript
type UserPreview = Pick<User, "name" | "age">;
// Same as: { name: string; age: number; }
```

**Omit<T, K> - Exclude properties:**
```typescript
type UserWithoutEmail = Omit<User, "email">;
// Removes email from User type
```

**Record<K, T> - Key-value pairs:**
```typescript
type Color = "red" | "green" | "blue";
type ColorCode = Record<Color, string>;
// Same as: { red: string; green: string; blue: string; }

const colors: ColorCode = {
    red: "#ff0000",
    green: "#00ff00",
    blue: "#0000ff"
};
```

**ReturnType<T> - Get function return type:**
```typescript
type MyFunc = (x: number) => string;
type MyReturn = ReturnType<MyFunc>;  // string
```

**Parameters<T> - Get function parameters:**
```typescript
type MyFunc = (x: number, y: string) => void;
type MyParams = Parameters<MyFunc>;  // [number, string]
```

**Difficulty:** Intermediate | **Tags:** #TypeScript #UtilityTypes #Types

---

### Q30: Explain decorators in TypeScript and their practical uses.

**Answer:**
Decorators are functions that modify classes, methods, or properties.

**Enable in tsconfig.json:**
```json
{
    "compilerOptions": {
        "experimentalDecorators": true
    }
}
```

**Class Decorator:**
```typescript
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
    constructor(public name: string) {}
}
```

**Method Decorator:**
```typescript
function Log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = function(...args: any[]) {
        console.log(`Calling ${propertyKey} with:`, args);
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
```

**Property Decorator:**
```typescript
function MinLength(length: number) {
    return function(target: any, propertyKey: string) {
        let value: string;

        const getter = () => value;
        const setter = (newValue: string) => {
            if (newValue.length < length) {
                throw new Error(`Must be at least ${length} chars`);
            }
            value = newValue;
        };

        Object.defineProperty(target, propertyKey, { get: getter, set: setter });
    };
}

class User {
    @MinLength(3)
    name: string = "";
}
```

**Practical Uses:**
- Validation
- Logging and debugging
- Dependency injection
- Authorization checks
- Caching

**Difficulty:** Advanced | **Tags:** #TypeScript #Decorators #Patterns

---

## Summary

**Total Questions:** 30
**Difficulty Distribution:**
- Beginner: 10 questions
- Intermediate: 15 questions
- Advanced: 5 questions

**Topics Covered:**
- HTML: 8 questions
- CSS: 7 questions
- JavaScript: 10 questions
- TypeScript: 5 questions

---

**Last Updated:** October 26, 2024
**Level:** Expert
**All questions include:** Detailed answers, code examples, practical applications
