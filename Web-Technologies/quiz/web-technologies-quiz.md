# Web Technologies Self-Assessment Quiz

## Overview

This comprehensive quiz contains 150+ questions organized by chapter to help you assess your understanding of HTML, CSS, JavaScript, and TypeScript. Each quiz section includes multiple-choice, true/false, and short-answer questions with detailed answer keys and explanations.

---

## Chapter 1: HTML Fundamentals & Semantic Structure

### Multiple Choice Questions

**Q1: Which of the following is NOT a semantic HTML5 element?**
- A) `<article>`
- B) `<section>`
- C) `<div>`
- D) `<nav>`

**Answer:** C) `<div>`

**Explanation:** `<div>` is a non-semantic container element. While useful for styling and layout, it doesn't convey meaning about its content. Semantic elements like `<article>`, `<section>`, and `<nav>` clearly describe their purpose to both browsers and developers.

---

**Q2: What is the primary purpose of the `<meta charset="UTF-8">` tag?**
- A) Set the page's language
- B) Define character encoding for the document
- C) Specify the page title
- D) Link external stylesheets

**Answer:** B) Define character encoding for the document

**Explanation:** The charset meta tag tells the browser how to interpret the document's bytes. UTF-8 is the recommended encoding as it supports all languages and is the internet standard.

---

**Q3: Which HTML attribute makes form input validation mandatory?**
- A) `validate`
- B) `required`
- C) `mandatory`
- D) `check`

**Answer:** B) `required`

**Explanation:** The `required` attribute prevents form submission if the field is empty. It's a native HTML5 feature that provides basic validation without JavaScript.

---

**Q4: What does ARIA stand for?**
- A) Accessible Rich Internet Applications
- B) Advanced Response Internet Attributes
- C) Async Request Interface Attributes
- D) Application Resource Information Architecture

**Answer:** A) Accessible Rich Internet Applications

**Explanation:** ARIA provides attributes to enhance accessibility for people using assistive technologies like screen readers.

---

**Q5: Which of the following is the correct way to define a responsive viewport?**
- A) `<meta name="viewport" content="width=device-width, initial-scale=1">`
- B) `<meta name="responsive" content="true">`
- C) `<viewport width="device-width">`
- D) `<meta responsive="yes">`

**Answer:** A) `<meta name="viewport" content="width=device-width, initial-scale=1">`

**Explanation:** This meta tag is essential for responsive design, telling the browser to render at the device width and start with a zoom level of 1.

---

**Q6: What is the difference between `<strong>` and `<b>` tags?**
- A) They are identical; use either one
- B) `<strong>` is semantic (importance), `<b>` is presentational (bold)
- C) `<b>` is semantic, `<strong>` is presentational
- D) `<strong>` is only for headings

**Answer:** B) `<strong>` is semantic (importance), `<b>` is presentational (bold)

**Explanation:** `<strong>` indicates strong importance of content and is properly announced by screen readers. `<b>` is purely presentational.

---

**Q7: Which meta tag helps with SEO by describing the page content?**
- A) `<meta name="description">`
- B) `<meta name="content">`
- C) `<meta name="keywords">`
- D) `<meta name="summary">`

**Answer:** A) `<meta name="description">`

**Explanation:** The description meta tag appears in search results and should be 150-160 characters to avoid truncation.

---

**Q8: What is the purpose of the `<picture>` element?**
- A) Insert images into the page
- B) Provide responsive images with art direction
- C) Create image galleries
- D) Add image filters

**Answer:** B) Provide responsive images with art direction

**Explanation:** `<picture>` allows different images to be served based on device size, resolution, or format, enabling better performance and responsive design.

---

**Q9: Which input type provides email validation?**
- A) `type="email"`
- B) `type="mail"`
- C) `type="text-email"`
- D) `type="@"`

**Answer:** A) `type="email"`

**Explanation:** `type="email"` validates that the input matches email format and shows appropriate keyboard on mobile devices.

---

**Q10: What does the `<label>` element do in a form?**
- A) Displays error messages
- B) Associates text with form controls for accessibility
- C) Styles form fields
- D) Validates user input

**Answer:** B) Associates text with form controls for accessibility

**Explanation:** Using `<label for="inputId">` makes forms accessible and improves usability by increasing the clickable area.

---

### True/False Questions

**Q11: Schema.org and JSON-LD can be used interchangeably for structured data.**

**Answer:** False

**Explanation:** While both describe structured data, JSON-LD is a format for embedding structured data in HTML (recommended by Google), while Schema.org is the vocabulary/ontology used with it.

---

**Q12: The `alt` attribute is only necessary for decorative images.**

**Answer:** False

**Explanation:** The `alt` attribute is essential for all images - it provides descriptions for screen readers, improves SEO, and displays if images fail to load.

---

**Q13: Semantic HTML improves both accessibility and SEO.**

**Answer:** True

**Explanation:** Semantic elements help screen readers understand content structure and help search engines index content more effectively.

---

**Q14: Custom elements (Web Components) can be used without JavaScript.**

**Answer:** False

**Explanation:** Custom elements require JavaScript to define (via `customElements.define()`) and to manage their lifecycle.

---

**Q15: The `type` attribute in `<script>` tags is optional in modern HTML5.**

**Answer:** True

**Explanation:** In HTML5, `<script>` defaults to JavaScript, so `type="text/javascript"` is no longer needed.

---

### Short Answer Questions

**Q16: Explain the difference between `<section>` and `<article>` elements with examples.**

**Answer:**
- `<section>`: A generic container for grouped content (chapters, tabs, numbered sections)
- `<article>`: Self-contained content that could be reused independently (blog post, news item)

Example:
```html
<article>
    <h1>Blog Post Title</h1>
    <section>
        <h2>Introduction</h2>
        <p>Content...</p>
    </section>
    <section>
        <h2>Main Content</h2>
        <p>Content...</p>
    </section>
</article>
```

**Difficulty:** Intermediate

---

**Q17: Why is the viewport meta tag critical for responsive design?**

**Answer:** The viewport meta tag tells mobile browsers how to scale the page. Without it, mobile browsers assume a wide desktop viewport and don't render responsively. The standard configuration `width=device-width, initial-scale=1` ensures the page scales to device width at 100% zoom.

**Difficulty:** Intermediate

---

**Q18: What accessibility improvements does semantic HTML provide?**

**Answer:**
1. Screen readers understand document structure and can navigate by headings, sections, etc.
2. Landmarks (`<nav>`, `<main>`, `<aside>`) help users jump to different page regions
3. Semantic elements have implicit roles (e.g., `<nav>` = navigation role)
4. Better keyboard navigation with proper semantic structure
5. Search engines better understand content hierarchy

**Difficulty:** Advanced

---

---

## Chapter 2: Advanced HTML & Web Components

### Multiple Choice Questions

**Q19: What is the Shadow DOM?**
- A) A hidden copy of the entire DOM tree
- B) An encapsulated DOM subtree for Web Components
- C) The DOM tree for desktop browsers only
- D) An outdated browser feature

**Answer:** B) An encapsulated DOM subtree for Web Components

**Explanation:** The Shadow DOM allows encapsulated styles and structure within Web Components, preventing style leakage and providing true component boundaries.

---

**Q20: Which attribute controls the Shadow DOM's visibility to external CSS?**
- A) `open`
- B) `closed`
- C) `hidden`
- D) `shadow`

**Answer:** A) `open` and B) `closed` (both are options when creating Shadow DOM)

**Explanation:** `attachShadow({ mode: 'open' })` allows external access via JavaScript, while `mode: 'closed'` completely encapsulates the Shadow DOM.

---

**Q21: What is a Web Component slot?**
- A) A memory allocation area
- B) A placeholder for external HTML content
- C) An animation timeline
- D) A CSS property

**Answer:** B) A placeholder for external HTML content

**Explanation:** Slots allow you to define where child elements will be rendered within a Web Component, enabling content distribution.

---

**Q22: When are Web Component lifecycle hooks called in order?**
- A) connectedCallback → disconnectedCallback → attributeChangedCallback
- B) constructor → connectedCallback → attributeChangedCallback
- C) attributeChangedCallback → constructor → connectedCallback
- D) connectedCallback → constructor → attributeChangedCallback

**Answer:** B) constructor → connectedCallback → attributeChangedCallback

**Explanation:** Constructor runs first, connectedCallback when added to DOM, attributeChangedCallback when watched attributes change.

---

**Q23: What is the purpose of `customElements.define()`?**
- A) Define CSS styling for custom elements
- B) Register a custom element class with a tag name
- C) Validate custom element attributes
- D) Create instances of custom elements

**Answer:** B) Register a custom element class with a tag name

**Explanation:** `customElements.define('my-element', MyElement)` registers your class to be used as `<my-element>`.

---

**Q24: How do you pass data to a Web Component?**
- A) Only through attributes
- B) Only through JavaScript properties
- C) Through attributes and/or JavaScript properties
- D) Through data attributes only

**Answer:** C) Through attributes and/or JavaScript properties

**Explanation:** Web Components can receive data via HTML attributes (strings) or JavaScript properties (any type).

---

**Q25: What does the `<template>` element do?**
- A) Defines a template literal for JavaScript
- B) Holds HTML that is parsed but not rendered
- C) Creates a template for CSS styling
- D) Defines template strings

**Answer:** B) Holds HTML that is parsed but not rendered

**Explanation:** `<template>` content is parsed but not displayed, allowing you to clone and reuse it dynamically.

---

**Q26: What is Content Security Policy (CSP)?**
- A) A way to store user data securely
- B) A security header that controls resource loading
- C) A form validation method
- D) A database security protocol

**Answer:** B) A security header that controls resource loading

**Explanation:** CSP prevents XSS attacks by restricting which scripts, styles, and other resources can be loaded.

---

**Q27: Which attribute enables lazy loading of images?**
- A) `defer`
- B) `lazy`
- C) `loading="lazy"`
- D) `async`

**Answer:** C) `loading="lazy"`

**Explanation:** `<img loading="lazy">` defers loading until the image is about to be viewed, improving page load performance.

---

**Q28: What is an iframe's main use case?**
- A) To embed responsive images
- B) To embed external content with isolated context
- C) To create animations
- D) To manage form submissions

**Answer:** B) To embed external content with isolated context

**Explanation:** Iframes provide isolation for third-party content, ads, or cross-origin content without affecting the main page.

---

### True/False Questions

**Q29: Web Components require a framework like React or Vue.**

**Answer:** False

**Explanation:** Web Components are native browser APIs; no framework is needed.

---

**Q30: The Shadow DOM completely prevents CSS from the parent page affecting component styles.**

**Answer:** True

**Explanation:** Shadow DOM encapsulation blocks external CSS from affecting the component's shadow tree (with some exceptions like CSS custom properties and inherited properties).

---

**Q31: Templates in HTML are automatically rendered when the page loads.**

**Answer:** False

**Explanation:** `<template>` content is inert—not rendered until cloned and inserted into the DOM via JavaScript.

---

**Q32: Lazy loading images increases initial page load performance.**

**Answer:** True

**Explanation:** Images below the fold aren't loaded until needed, reducing initial network requests and improving perceived performance.

---

**Q33: CSP can completely prevent all XSS attacks.**

**Answer:** False

**Explanation:** While CSP significantly reduces XSS risk, it's a defense mechanism but not a complete solution. Defense-in-depth is needed.

---

### Short Answer Questions

**Q34: Explain the Shadow DOM encapsulation with a code example.**

**Answer:**
```javascript
class MyComponent extends HTMLElement {
    connectedCallback() {
        this.attachShadow({ mode: 'open' });
        this.shadowRoot.innerHTML = `
            <style>
                p { color: red; }  // Only affects this component
            </style>
            <p>Styled text</p>
        `;
    }
}

customElements.define('my-component', MyComponent);
```

The component's styles don't affect the rest of the page, and external styles don't affect the component (with inherited properties as exceptions).

**Difficulty:** Advanced

---

**Q35: How do slots enable content distribution in Web Components?**

**Answer:**
```javascript
class MyCard extends HTMLElement {
    connectedCallback() {
        this.attachShadow({ mode: 'open' }).innerHTML = `
            <slot name="title">Default Title</slot>
            <slot></slot> <!-- unnamed slot for default content -->
        `;
    }
}

// Usage:
// <my-card>
//     <h2 slot="title">Custom Title</h2>
//     <p>Card content</p>
// </my-card>
```

Slots act as placeholders where the parent's HTML is rendered within the component's Shadow DOM.

**Difficulty:** Advanced

---

**Q36: Why is CSP important for security?**

**Answer:** CSP prevents attackers from injecting malicious scripts by only allowing scripts from trusted sources. A strong CSP might look like:
```html
<meta http-equiv="Content-Security-Policy" content="
  default-src 'self';
  script-src 'self' https://trusted-cdn.com;
  style-src 'self' 'unsafe-inline';
">
```

This prevents inline scripts and scripts from unknown origins, blocking most XSS attacks.

**Difficulty:** Advanced

---

---

## Chapter 3: CSS Fundamentals & Styling

### Multiple Choice Questions

**Q37: What does CSS specificity determine?**
- A) How quickly CSS loads
- B) Which style rule is applied when conflicting rules exist
- C) The size of the CSS file
- D) Browser compatibility

**Answer:** B) Which style rule is applied when conflicting rules exist

**Explanation:** Specificity is a three-digit score (inline, IDs, classes/attributes/pseudos) that determines rule priority.

---

**Q38: Which selector has the highest specificity?**
- A) `* { }`
- B) `p { }`
- C) `.class { }`
- D) `#id { }`

**Answer:** D) `#id { }`

**Explanation:** ID selectors (specificity 100) beat class selectors (10) which beat element selectors (1).

---

**Q39: What is the CSS box model in correct order?**
- A) Border, Margin, Padding, Content
- B) Margin, Border, Padding, Content
- C) Content, Padding, Border, Margin
- D) Padding, Content, Border, Margin

**Answer:** C) Content, Padding, Border, Margin (from inside out)

**Explanation:** Content is innermost, surrounded by padding, then border, then margin.

---

**Q40: Which display property makes elements flexible containers?**
- A) `display: flex`
- B) `display: flexible`
- C) `display: grid`
- D) `display: flex-box`

**Answer:** A) `display: flex`

**Explanation:** Flexbox is the CSS Flexible Box Layout module for one-dimensional layouts.

---

**Q41: What is the default direction of flex items?**
- A) Vertical (column)
- B) Horizontal (row)
- C) Diagonal
- D) Depends on viewport

**Answer:** B) Horizontal (row)

**Explanation:** By default, `flex-direction` is `row`, placing items in a horizontal line.

---

**Q42: What does `justify-content` control in Flexbox?**
- A) Vertical alignment of items
- B) Horizontal alignment of items on the main axis
- C) Item width
- D) Item order

**Answer:** B) Horizontal alignment of items on the main axis

**Explanation:** `justify-content` distributes items along the main axis (row direction by default).

---

**Q43: What is CSS Grid's primary advantage over Flexbox?**
- A) It's faster
- B) It supports two-dimensional layouts
- C) It's simpler to learn
- D) It has better browser support

**Answer:** B) It supports two-dimensional layouts

**Explanation:** Grid handles both rows and columns, while Flexbox is primarily one-dimensional.

---

**Q44: Which CSS property defines the number of grid columns?**
- A) `grid-columns`
- B) `grid-template-columns`
- C) `columns`
- D) `grid-cols`

**Answer:** B) `grid-template-columns`

**Explanation:** `grid-template-columns: 1fr 2fr 1fr` creates three columns with relative widths.

---

**Q45: What does the `fr` unit represent in CSS Grid?**
- A) Frames per second
- B) Free space
- C) Fractional unit (fraction of available space)
- D) Forward rendering

**Answer:** C) Fractional unit (fraction of available space)

**Explanation:** `1fr` means "one fraction of available space", allowing proportional sizing.

---

**Q46: Which property enables CSS animations?**
- A) `animation`
- B) `transition`
- C) Both A and B
- D) `animate`

**Answer:** C) Both A and B

**Explanation:** Transitions animate property changes; animations use keyframes for complex sequences.

---

### True/False Questions

**Q47: Margin and padding are the same thing.**

**Answer:** False

**Explanation:** Margin is outside the border; padding is inside. Margin creates space between elements; padding creates space inside.

---

**Q48: `z-index` works on statically positioned elements.**

**Answer:** False

**Explanation:** `z-index` only works on positioned elements (`position: relative/absolute/fixed`).

---

**Q49: CSS custom properties (variables) can be used in all CSS properties.**

**Answer:** True

**Explanation:** CSS custom properties (e.g., `--color: red`) can be used anywhere with `var(--color)`.

---

**Q50: Media queries are only for responsive design.**

**Answer:** False

**Explanation:** Media queries target different devices/conditions (print, dark mode, orientation, resolution, etc.).

---

**Q51: Grid items must be direct children of the grid container.**

**Answer:** True

**Explanation:** Only direct children participate in the grid layout; nested items don't.

---

### Short Answer Questions

**Q52: Explain CSS specificity with an example.**

**Answer:** Specificity is calculated as (inline styles, IDs, classes/attributes, elements):

```css
p { color: blue; }                    /* Specificity: 0,0,0,1 */
.highlight { color: red; }            /* Specificity: 0,0,1,0 */
#main { color: green; }               /* Specificity: 0,1,0,0 */
<p style="color: yellow;">text</p>   /* Specificity: 1,0,0,0 (wins) */
```

Inline styles win, then IDs, then classes, then elements.

**Difficulty:** Intermediate

---

**Q53: Create a responsive Flexbox layout for a navigation bar.**

**Answer:**
```css
nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 1rem;
}

nav a {
    flex: 1;
    min-width: 100px;
    text-align: center;
    padding: 0.5rem;
}

@media (max-width: 768px) {
    nav {
        flex-direction: column;
    }
    nav a {
        flex: 1 0 100%;
    }
}
```

**Difficulty:** Intermediate

---

**Q54: Explain the difference between transitions and animations.**

**Answer:**
- **Transitions:** Animate from one state to another when a property changes
  ```css
  button { transition: background 0.3s ease; }
  button:hover { background: blue; }
  ```
- **Animations:** Use keyframes for complex multi-step sequences
  ```css
  @keyframes slide {
      from { transform: translateX(0); }
      to { transform: translateX(100px); }
  }
  .box { animation: slide 1s ease infinite; }
  ```

**Difficulty:** Intermediate

---

---

## Chapter 4: Advanced CSS & Modern Techniques

### Multiple Choice Questions

**Q55: What does `grid-auto-flow` control?**
- A) How automatically created tracks are sized
- B) The direction grid items flow when not explicitly placed
- C) The animation speed of grid items
- D) Browser rendering performance

**Answer:** B) The direction grid items flow when not explicitly placed

**Explanation:** `grid-auto-flow: row` places items left-to-right; `column` places them top-to-bottom.

---

**Q56: What are CSS custom properties (variables)?**
- A) Properties that only work on custom elements
- B) CSS variables that start with `--` and are used with `var()`
- C) Deprecated CSS features
- D) Properties that change based on user input

**Answer:** B) CSS variables that start with `--` and are used with `var()`

**Explanation:**
```css
:root { --primary-color: blue; }
p { color: var(--primary-color); }
```

---

**Q57: What does CSS containment do?**
- A) Contains CSS to a specific scope
- B) Limits browser rendering to a component, improving performance
- C) Restricts CSS selectors
- D) Prevents CSS inheritance

**Answer:** B) Limits browser rendering to a component, improving performance

**Explanation:** `contain: layout paint` tells the browser this element is independent, skipping recalculation of parent/sibling styles.

---

**Q58: Which at-rule defines a font?**
- A) `@import`
- B) `@font-face`
- C) `@font`
- D) `@define-font`

**Answer:** B) `@font-face`

**Explanation:**
```css
@font-face {
    font-family: "CustomFont";
    src: url("font.woff2") format("woff2");
}
```

---

**Q59: What is a pseudo-element?**
- A) A fake element in JavaScript
- B) A CSS keyword that selects part of an element (e.g., `::before`, `::after`)
- C) A deprecated CSS feature
- D) An element created by CSS Grid

**Answer:** B) A CSS keyword that selects part of an element (e.g., `::before`, `::after`)

**Explanation:** `::before` and `::after` create pseudo-elements; `::first-letter` selects first letter, etc.

---

**Q60: What does `scroll-snap-type` do?**
- A) Prevents scrolling
- B) Enables scroll snapping to defined snap points
- C) Animates scrolling
- D) Detects scroll position

**Answer:** B) Enables scroll snapping to defined snap points

**Explanation:**
```css
.container { scroll-snap-type: x mandatory; }
.item { scroll-snap-align: center; }
```

---

**Q61: Which CSS feature enables responsive design without media queries?**
- A) Container queries
- B) Grid responsive design
- C) Flexbox wrapping
- D) Viewport units

**Answer:** A) Container queries

**Explanation:** Container queries let components adapt based on their container size, not viewport size:
```css
@container (min-width: 400px) {
    .item { /* styles */ }
}
```

---

**Q62: What does `backdrop-filter` do?**
- A) Filters the HTML backdrop element
- B) Applies effects to the area behind an element
- C) Filters DOM elements
- D) Prevents backdrop color changes

**Answer:** B) Applies effects to the area behind an element

**Explanation:**
```css
.modal { backdrop-filter: blur(5px); }
```

---

**Q63: What is CSS subgrid?**
- A) A small grid
- B) A grid item that inherits parent grid columns/rows
- C) A deprecated feature
- D) An animation feature

**Answer:** B) A grid item that inherits parent grid columns/rows

**Explanation:**
```css
.parent { display: grid; grid-template-columns: 1fr 1fr; }
.child { display: grid; grid-template-columns: subgrid; }
```

---

**Q64: What does the `@supports` rule do?**
- A) Provides browser support information
- B) Conditionally applies CSS if a feature is supported
- C) Imports CSS support files
- D) Validates CSS syntax

**Answer:** B) Conditionally applies CSS if a feature is supported

**Explanation:**
```css
@supports (display: grid) {
    .container { display: grid; }
}
```

---

### True/False Questions

**Q65: CSS custom properties can be scoped to specific elements.**

**Answer:** True

**Explanation:**
```css
.section { --primary: blue; }
.other { --primary: red; } /* Different scope */
```

---

**Q66: The `!important` flag overrides specificity completely.**

**Answer:** False

**Explanation:** `!important` increases specificity, but cascade order still applies. Specificity with `!important` can still be overridden by higher specificity with `!important`.

---

**Q67: CSS filters can only be applied to images.**

**Answer:** False

**Explanation:** Filters can be applied to any HTML element: `filter: blur(5px) brightness(1.2);`

---

**Q68: Masking allows you to hide parts of an element.**

**Answer:** True

**Explanation:**
```css
.image { mask-image: url(mask.svg); }
```

---

**Q69: Container queries have full browser support as of 2024.**

**Answer:** True (mostly)

**Explanation:** Most modern browsers support container queries, though older browsers don't. Check caniuse.com for exact support.

---

### Short Answer Questions

**Q70: Create a responsive navigation using CSS Grid.**

**Answer:**
```css
nav {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
    gap: 1rem;
    align-items: center;
}

@supports (container-type: inline-size) {
    nav { container-type: inline-size; }
    nav a {
        @container (max-width: 600px) {
            font-size: 0.9rem;
        }
    }
}
```

**Difficulty:** Advanced

---

**Q71: Explain CSS containment and its performance benefits.**

**Answer:** CSS containment (`contain: layout paint style`) tells the browser:
- **layout**: This element's layout is independent; don't recalculate parent layout
- **paint**: This element paints independently
- **style**: Styles don't leak to ancestors

Performance benefit: Browser skips expensive recalculations for siblings and ancestors when this element changes.

**Difficulty:** Advanced

---

**Q72: Create a CSS solution for a glass-morphism effect.**

**Answer:**
```css
.glass {
    background: rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 10px;
    padding: 2rem;
}
```

The `backdrop-filter` blurs the background; transparency and border create the glass effect.

**Difficulty:** Intermediate

---

---

## Chapter 5: JavaScript Fundamentals & Core Concepts

### Multiple Choice Questions

**Q73: What is the difference between `var`, `let`, and `const`?**
- A) No difference; use any
- B) `var` is function-scoped; `let`/`const` are block-scoped; `const` can't be reassigned
- C) `let` and `const` are deprecated
- D) `var` is modern; others are outdated

**Answer:** B) `var` is function-scoped; `let`/`const` are block-scoped; `const` can't be reassigned

**Explanation:**
```javascript
if (true) {
    var x = 1;      // Function-scoped
    let y = 2;      // Block-scoped
    const z = 3;    // Block-scoped, can't reassign
}
console.log(x);     // 1 (accessible)
console.log(y);     // Error (not accessible)
```

---

**Q74: What does type coercion mean?**
- A) Converting types explicitly
- B) Automatic type conversion by JavaScript
- C) Preventing type changes
- D) Type checking

**Answer:** B) Automatic type conversion by JavaScript

**Explanation:**
```javascript
"5" + 3;        // "53" (string concatenation)
"5" - 3;        // 2 (numeric coercion)
true + 1;       // 2 (true converts to 1)
```

---

**Q75: What is the result of `console.log(0.1 + 0.2 === 0.3)`?**
- A) true
- B) false
- C) undefined
- D) Error

**Answer:** B) false

**Explanation:** JavaScript uses floating-point arithmetic: `0.1 + 0.2` equals `0.30000000000000004`, not `0.3`. Use `Math.abs(a - b) < epsilon` for comparisons.

---

**Q76: What is a closure?**
- A) A function that closes
- B) A function with access to another function's scope
- C) A completed execution context
- D) A deprecated feature

**Answer:** B) A function with access to another function's scope

**Explanation:**
```javascript
function outer(x) {
    return function inner() {
        return x;  // Closure over outer's x
    };
}
const fn = outer(5);
fn();  // 5
```

---

**Q77: What is the `this` keyword bound to in a regular function?**
- A) The object it's defined on
- B) The object it's called on
- C) The global object (if not strict mode)
- D) Always undefined

**Answer:** C) The global object (if not strict mode)

**Explanation:**
```javascript
function greet() { return this; }
greet();           // window (global object)
obj.greet();       // obj
```

---

**Q78: What does `async/await` allow you to do?**
- A) Make code run synchronously
- B) Write asynchronous code that looks synchronous
- C) Avoid using promises
- D) Speed up code execution

**Answer:** B) Write asynchronous code that looks synchronous

**Explanation:**
```javascript
async function getData() {
    const response = await fetch(url);
    return response.json();
}
```

---

**Q79: What is the event loop?**
- A) An infinite loop in your code
- B) The mechanism that handles asynchronous code execution
- C) A browser feature for loops
- D) A deprecated concept

**Answer:** B) The mechanism that handles asynchronous code execution

**Explanation:** The event loop continuously checks the call stack and callback queue, moving callbacks to the stack when it's empty.

---

**Q80: What is DOM manipulation?**
- A) Modifying CSS styles
- B) Changing HTML elements, attributes, content
- C) Validating forms
- D) Loading scripts

**Answer:** B) Changing HTML elements, attributes, content

**Explanation:**
```javascript
document.getElementById('id').innerHTML = 'new content';
element.setAttribute('class', 'highlight');
```

---

**Q81: What is event delegation?**
- A) Delegating event handling to a parent element
- B) Creating multiple event listeners
- C) Using event.preventDefault()
- D) Removing event listeners

**Answer:** A) Delegating event handling to a parent element

**Explanation:** Instead of adding listeners to each child, add one listener to the parent and check `event.target`.

---

**Q82: What does the spread operator do?**
- A) Spreads CSS across elements
- B) Expands iterables into individual elements
- C) Duplicates arrays
- D) Creates new objects

**Answer:** B) Expands iterables into individual elements

**Explanation:**
```javascript
const arr = [1, 2, 3];
const copy = [...arr];  // [1, 2, 3]
const obj = { ...{ a: 1 } };  // { a: 1 }
```

---

### True/False Questions

**Q83: JavaScript is a strictly-typed language.**

**Answer:** False

**Explanation:** JavaScript is dynamically typed; types can change at runtime.

---

**Q84: Promises always resolve or reject eventually.**

**Answer:** False

**Explanation:** Promises can hang indefinitely if never settled.

---

**Q85: Arrow functions have their own `this` binding.**

**Answer:** False

**Explanation:** Arrow functions inherit `this` from enclosing scope; they don't have their own binding.

---

**Q86: Objects are passed by reference in JavaScript.**

**Answer:** True

**Explanation:**
```javascript
const obj1 = { a: 1 };
const obj2 = obj1;
obj2.a = 2;
console.log(obj1.a);  // 2 (same object)
```

---

**Q87: Array methods like `map` and `filter` modify the original array.**

**Answer:** False

**Explanation:** They return new arrays; the original remains unchanged.

---

### Short Answer Questions

**Q88: Explain closures with a practical example.**

**Answer:**
```javascript
function makeCounter() {
    let count = 0;
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
```

The returned object forms closures over `count`, creating private state.

**Difficulty:** Intermediate

---

**Q89: How does the event loop work in JavaScript?**

**Answer:**
1. Synchronous code executes on the call stack
2. Asynchronous operations (timers, promises, fetch) go to Web APIs
3. Callbacks move to the callback queue when ready
4. When call stack is empty, event loop moves callbacks to the stack
5. Process repeats

Example:
```javascript
console.log(1);
setTimeout(() => console.log(2), 0);
Promise.resolve().then(() => console.log(3));
console.log(4);
// Output: 1, 4, 3, 2 (microtasks before macrotasks)
```

**Difficulty:** Advanced

---

**Q90: Create a function that converts callback-based async to promise-based.**

**Answer:**
```javascript
// Callback-based
function fetchDataCallback(url, callback) {
    setTimeout(() => callback(null, { data: 'test' }), 100);
}

// Convert to promise
function fetchDataPromise(url) {
    return new Promise((resolve, reject) => {
        fetchDataCallback(url, (err, data) => {
            if (err) reject(err);
            else resolve(data);
        });
    });
}

// Use with async/await
const data = await fetchDataPromise(url);
```

**Difficulty:** Advanced

---

---

## Chapter 6: Advanced JavaScript & Modern Patterns

### Multiple Choice Questions

**Q91: What is prototypal inheritance?**
- A) Inheritance using the `extends` keyword
- B) Objects inherit from prototypes, forming a chain
- C) Classes in JavaScript
- D) A deprecated feature

**Answer:** B) Objects inherit from prototypes, forming a chain

**Explanation:**
```javascript
const parent = { greet() { return "Hello"; } };
const child = Object.create(parent);
child.greet();  // "Hello" (inherited through prototype chain)
```

---

**Q92: What does destructuring do?**
- A) Destroys arrays/objects
- B) Extracts values into separate variables
- C) Deletes properties
- D) Compresses code

**Answer:** B) Extracts values into separate variables

**Explanation:**
```javascript
const { name, age } = { name: "John", age: 30 };
const [first, ...rest] = [1, 2, 3, 4];
```

---

**Q93: What is functional composition?**
- A) Organizing functions in files
- B) Combining functions to create new functions
- C) Writing pure functions
- D) Object-oriented design

**Answer:** B) Combining functions to create new functions

**Explanation:**
```javascript
const compose = (f, g) => (x) => f(g(x));
const addOne = (x) => x + 1;
const double = (x) => x * 2;
const addOneThenDouble = compose(double, addOne);
addOneThenDouble(5);  // 12
```

---

**Q94: What is currying?**
- A) Cooking with functions
- B) Converting a function to accept arguments one at a time
- C) Caching function results
- D) Async functions

**Answer:** B) Converting a function to accept arguments one at a time

**Explanation:**
```javascript
const add = (a) => (b) => (c) => a + b + c;
add(1)(2)(3);  // 6
```

---

**Q95: What is a higher-order function?**
- A) A function with a high priority
- B) A function that takes or returns functions
- C) An async function
- D) A recursive function

**Answer:** B) A function that takes or returns functions

**Explanation:**
```javascript
const map = (fn, arr) => arr.map(fn);
const filter = (predicate, arr) => arr.filter(predicate);
```

---

**Q96: What is memoization?**
- A) Writing notes in code
- B) Caching function results based on arguments
- C) Memory management
- D) A data structure

**Answer:** B) Caching function results based on arguments

**Explanation:**
```javascript
const memoize = (fn) => {
    const cache = {};
    return (...args) => {
        const key = JSON.stringify(args);
        return cache[key] ?? (cache[key] = fn(...args));
    };
};
```

---

**Q97: What is debouncing?**
- A) Removing bugs
- B) Delaying function execution until activity stops
- C) Validating input
- D) Caching results

**Answer:** B) Delaying function execution until activity stops

**Explanation:**
```javascript
const debounce = (fn, delay) => {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => fn(...args), delay);
    };
};
```

---

**Q98: What is Web Workers used for?**
- A) Loading web pages
- B) Running JavaScript in background threads
- C) CSS effects
- D) DOM manipulation

**Answer:** B) Running JavaScript in background threads

**Explanation:** Offload heavy computations to avoid blocking the main thread.

---

**Q99: What is the difference between shallow and deep copy?**
- A) Shallow copies are better
- B) Shallow copies copy references; deep copies copy nested values
- C) Deep copies are always slower
- D) They're the same

**Answer:** B) Shallow copies copy references; deep copies copy nested values

**Explanation:**
```javascript
const obj = { a: { b: 1 } };
const shallow = { ...obj };  // shallow.a references obj.a
const deep = JSON.parse(JSON.stringify(obj));  // independent copy
```

---

**Q100: What are modules in JavaScript?**
- A) CSS frameworks
- B) Separate files with reusable code
- C) Browser extensions
- D) Outdated concept

**Answer:** B) Separate files with reusable code

**Explanation:**
```javascript
// math.js
export const add = (a, b) => a + b;

// main.js
import { add } from './math.js';
add(2, 3);  // 5
```

---

### True/False Questions

**Q101: Pure functions always return the same output for the same input.**

**Answer:** True

**Explanation:** Pure functions have no side effects and consistent output.

---

**Q102: Throttling prevents function execution completely.**

**Answer:** False

**Explanation:** Throttling limits execution frequency (e.g., once per 1 second), not prevents it.

---

**Q103: Web Workers can access the DOM.**

**Answer:** False

**Explanation:** Web Workers run in isolated context without DOM access.

---

**Q104: CommonJS and ES6 modules are compatible without conversion.**

**Answer:** False

**Explanation:** They use different syntax; transpilation is needed for compatibility.

---

**Q105: Object.freeze() makes an object completely immutable.**

**Answer:** False (partially true)

**Explanation:** It prevents adding/removing/modifying properties but not nested objects.

---

### Short Answer Questions

**Q106: Explain prototypal inheritance with a code example.**

**Answer:**
```javascript
function Animal(name) { this.name = name; }
Animal.prototype.speak = function() { return `${this.name} speaks`; };

function Dog(name) { Animal.call(this, name); }
Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.bark = function() { return `${this.name} barks`; };

const dog = new Dog("Rex");
dog.speak();  // "Rex speaks"
dog.bark();   // "Rex barks"
```

**Difficulty:** Advanced

---

**Q107: Create a functional pipeline that processes data through multiple functions.**

**Answer:**
```javascript
const pipe = (...fns) => (x) => fns.reduce((acc, fn) => fn(acc), x);

const addTax = (price) => price * 1.1;
const applyDiscount = (price) => price * 0.9;
const round = (price) => Math.round(price * 100) / 100;

const calculatePrice = pipe(addTax, applyDiscount, round);
calculatePrice(100);  // 99 (100 * 1.1 * 0.9 rounded)
```

**Difficulty:** Advanced

---

**Q108: Explain the difference between `call`, `apply`, and `bind`.**

**Answer:**
```javascript
function greet(greeting, punctuation) {
    return `${greeting}, ${this.name}${punctuation}`;
}

const obj = { name: "John" };

greet.call(obj, "Hi", "!");        // "Hi, John!" (execute immediately)
greet.apply(obj, ["Hi", "!"]);     // "Hi, John!" (args as array)
const boundGreet = greet.bind(obj, "Hi", "!");
boundGreet();                       // "Hi, John!" (returns function)
```

**Difficulty:** Advanced

---

---

## Chapter 7: TypeScript Fundamentals & Advanced Types

### Multiple Choice Questions

**Q109: What is TypeScript?**
- A) A JavaScript framework
- B) A superset of JavaScript with static typing
- C) A CSS preprocessor
- D) A testing library

**Answer:** B) A superset of JavaScript with static typing

**Explanation:** TypeScript adds static types to JavaScript and compiles to JavaScript.

---

**Q110: What is type inference?**
- A) Guessing types
- B) TypeScript automatically determining types
- C) Manual type assignment
- D) Runtime type checking

**Answer:** B) TypeScript automatically determining types

**Explanation:**
```typescript
const num = 42;  // TypeScript infers: number
const str = "hello";  // TypeScript infers: string
```

---

**Q111: What is the difference between `any` and `unknown`?**
- A) They're the same
- B) `any` bypasses type checking; `unknown` requires type narrowing
- C) `unknown` is deprecated
- D) `any` is safer

**Answer:** B) `any` bypasses type checking; `unknown` requires type narrowing

**Explanation:**
```typescript
let a: any = "hello";
a.toUpperCase();  // OK (unsafe)

let u: unknown = "hello";
if (typeof u === 'string') {
    u.toUpperCase();  // OK (type-safe)
}
```

---

**Q112: What is a union type?**
- A) Combining types with `&`
- B) Combining types with `|`, meaning "one of these"
- C) A deprecated feature
- D) A CSS feature

**Answer:** B) Combining types with `|`, meaning "one of these"

**Explanation:**
```typescript
let id: string | number;
id = "123";  // OK
id = 456;    // OK
```

---

**Q113: What is an interface in TypeScript?**
- A) A GUI component
- B) A contract defining object shape
- C) A function signature
- D) A CSS class

**Answer:** B) A contract defining object shape

**Explanation:**
```typescript
interface User {
    name: string;
    age: number;
}
const user: User = { name: "John", age: 30 };
```

---

**Q114: What is a type alias?**
- A) An alternative name for a type
- B) A variable holding a type
- C) The same as interface
- D) A deprecated feature

**Answer:** A) An alternative name for a type

**Explanation:**
```typescript
type User = { name: string; age: number };
type ID = string | number;
```

---

**Q115: What is a generic type?**
- A) A basic type
- B) A type that accepts type parameters like functions accept parameters
- C) A union type
- D) A non-specific type

**Answer:** B) A type that accepts type parameters like functions accept parameters

**Explanation:**
```typescript
function identity<T>(arg: T): T { return arg; }
identity<string>("hello");
```

---

**Q116: What does `readonly` do?**
- A) Makes properties visible only in read mode
- B) Prevents property modification after initialization
- C) Makes properties private
- D) A CSS property

**Answer:** B) Prevents property modification after initialization

**Explanation:**
```typescript
const user: { readonly id: number; name: string } = { id: 1, name: "John" };
user.name = "Jane";  // OK
user.id = 2;         // Error
```

---

**Q117: What is a type guard?**
- A) Guards against type errors
- B) A function that narrows types within a code block
- C) A TypeScript compiler feature
- D) A runtime protection

**Answer:** B) A function that narrows types within a code block

**Explanation:**
```typescript
function isString(value: unknown): value is string {
    return typeof value === 'string';
}
if (isString(value)) {
    value.toUpperCase();  // value is narrowed to string
}
```

---

**Q118: What are utility types?**
- A) Tools for writing TypeScript
- B) Built-in types that transform other types
- C) User-defined types
- D) Deprecated features

**Answer:** B) Built-in types that transform other types

**Explanation:**
```typescript
type Partial<T> = { [P in keyof T]?: T[P]; };
type Readonly<T> = { readonly [P in keyof T]: T[P]; };
```

---

### True/False Questions

**Q119: TypeScript prevents all runtime errors.**

**Answer:** False

**Explanation:** TypeScript catches compile-time type errors but not all runtime errors (e.g., null reference outside type system).

---

**Q120: Interfaces can be merged (declaration merging).**

**Answer:** True

**Explanation:**
```typescript
interface User { name: string; }
interface User { age: number; }
// Merged to: { name: string; age: number; }
```

---

**Q121: TypeScript compiles to JavaScript and can run in browsers.**

**Answer:** True

**Explanation:** TypeScript is compiled to JavaScript which runs in all browsers.

---

**Q122: The `strictNullChecks` flag is enabled by default.**

**Answer:** True (in `strict: true`)

**Explanation:** Recommended for catching null/undefined errors.

---

**Q123: Classes in TypeScript are the same as JavaScript classes.**

**Answer:** True (mostly)

**Explanation:** TypeScript adds access modifiers and type annotations but compiles to JavaScript classes.

---

### Short Answer Questions

**Q124: Create a generic function with constraints.**

**Answer:**
```typescript
interface HasLength { length: number; }

function getLength<T extends HasLength>(arg: T): number {
    return arg.length;
}

getLength("hello");        // 5
getLength([1, 2, 3]);      // 3
getLength(123);            // Error: number doesn't have length
```

**Difficulty:** Intermediate

---

**Q125: Explain interfaces vs types with examples.**

**Answer:**
```typescript
// Interface (structural contract)
interface User {
    name: string;
    age: number;
}

// Type (can be union, primitive, etc.)
type ID = string | number;
type User = { name: string; age: number };  // Also works, but union requires type

// Key difference:
interface X {}
interface X {}  // Can merge

type Y = { a: 1 };
type Y = { b: 2 };  // Error: duplicate
```

**Difficulty:** Intermediate

---

**Q126: Create a discriminated union type.**

**Answer:**
```typescript
type Result =
    | { status: 'success'; data: string }
    | { status: 'error'; error: string }
    | { status: 'loading' };

function handleResult(result: Result) {
    switch (result.status) {
        case 'success':
            console.log(result.data);  // Narrowed
            break;
        case 'error':
            console.log(result.error);  // Narrowed
            break;
        case 'loading':
            console.log('Loading...');
    }
}
```

**Difficulty:** Advanced

---

---

## Chapter 8: TypeScript Advanced & Patterns

### Multiple Choice Questions

**Q127: What does `keyof` do?**
- A) Creates new keys in objects
- B) Extracts object keys as a union type
- C) Deletes object keys
- D) Validates key names

**Answer:** B) Extracts object keys as a union type

**Explanation:**
```typescript
interface User { name: string; age: number; }
type Keys = keyof User;  // "name" | "age"
```

---

**Q128: What are template literal types?**
- A) CSS template literals
- B) JavaScript template strings
- C) String literal types created with templates
- D) A deprecated feature

**Answer:** C) String literal types created with templates

**Explanation:**
```typescript
type Event = `on${Capitalize<'click'>}`;  // "onClick"
type Getter<T extends string> = `get${Capitalize<T>}`;
```

---

**Q129: What does `infer` do in TypeScript?**
- A) Guesses types
- B) Extracts and infers types from conditional types
- C) Imports types
- D) Validates types

**Answer:** B) Extracts and infers types from conditional types

**Explanation:**
```typescript
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;
type MyReturn = ReturnType<() => string>;  // string
```

---

**Q130: What is a mapped type?**
- A) A type that maps arrays
- B) A type created by transforming properties of another type
- C) A type used in maps/dictionaries
- D) A deprecated feature

**Answer:** B) A type created by transforming properties of another type

**Explanation:**
```typescript
type Getters<T> = {
    [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};
```

---

**Q131: What are conditional types?**
- A) Types with conditions in CSS
- B) Types that change based on type relationships
- C) Runtime conditionals
- D) Optional types

**Answer:** B) Types that change based on type relationships

**Explanation:**
```typescript
type IsString<T> = T extends string ? true : false;
type A = IsString<"hello">;  // true
type B = IsString<number>;   // false
```

---

**Q132: What is the Decorator pattern in TypeScript?**
- A) CSS decorations
- B) Functions that modify class/method behavior
- C) Design patterns documentation
- D) Animation effects

**Answer:** B) Functions that modify class/method behavior

**Explanation:**
```typescript
function Log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const original = descriptor.value;
    descriptor.value = function(...args: any[]) {
        console.log(`Calling ${propertyKey}`);
        return original.apply(this, args);
    };
}

class Service {
    @Log
    getData() { /* ... */ }
}
```

---

**Q133: What does `Pick<T, K>` do?**
- A) Picks random properties
- B) Extracts specific properties from a type
- C) Selects types
- D) A sorting function

**Answer:** B) Extracts specific properties from a type

**Explanation:**
```typescript
type User = { name: string; age: number; email: string };
type UserPreview = Pick<User, "name" | "age">;  // { name: string; age: number; }
```

---

**Q134: What is `Omit<T, K>`?**
- A) Same as Pick
- B) Excludes specific properties from a type
- C) Deletes properties
- D) Creates optional properties

**Answer:** B) Excludes specific properties from a type

**Explanation:**
```typescript
type UserWithoutEmail = Omit<User, "email">;  // { name: string; age: number; }
```

---

**Q135: What is `Record<K, T>`?**
- A) Records data
- B) Creates a type with specific keys and value type
- C) Stores historical data
- D) A deprecated feature

**Answer:** B) Creates a type with specific keys and value type

**Explanation:**
```typescript
type Scores = Record<"math" | "english" | "science", number>;
const myScores: Scores = { math: 95, english: 87, science: 92 };
```

---

### True/False Questions

**Q136: Decorators require `experimentalDecorators` to be enabled.**

**Answer:** True

**Explanation:** Set `"experimentalDecorators": true` in `tsconfig.json`.

---

**Q137: Recursive types can be infinitely deep.**

**Answer:** False

**Explanation:** Recursion must have a base case; infinite recursion causes errors.

---

**Q138: Generic constraints make functions less flexible.**

**Answer:** False

**Explanation:** Constraints increase type safety while maintaining flexibility.

---

**Q139: TypeScript's type system is completely runtime-safe.**

**Answer:** False

**Explanation:** Type erasure means types don't exist at runtime; type assertions can be unsafe.

---

**Q140: Distributive conditional types apply to each type in a union separately.**

**Answer:** True

**Explanation:**
```typescript
type Flatten<T> = T extends Array<infer U> ? U : T;
type T = Flatten<(string | number)[]>;  // string | number (applies to each)
```

---

### Short Answer Questions

**Q141: Create a type that extracts function parameter types.**

**Answer:**
```typescript
type Parameters<T> = T extends (...args: infer P) => any ? P : never;

function myFunc(a: string, b: number) { }
type MyParams = Parameters<typeof myFunc>;  // [a: string, b: number]
```

**Difficulty:** Advanced

---

**Q142: Explain recursive types with a JSON example.**

**Answer:**
```typescript
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
        value: 123,
        array: [1, "two", { three: 3 }]
    }
};
```

This recursively allows any JSON structure.

**Difficulty:** Advanced

---

**Q143: Create a type-safe dependency injection container.**

**Answer:**
```typescript
type ServiceFactory<T> = () => T;

class DIContainer {
    private services = new Map<string, ServiceFactory<any>>();

    register<T>(key: string, factory: ServiceFactory<T>): void {
        this.services.set(key, factory);
    }

    resolve<T>(key: string): T {
        const factory = this.services.get(key);
        if (!factory) throw new Error(`Service ${key} not found`);
        return factory() as T;
    }
}

const container = new DIContainer();
container.register('logger', () => new Logger());
const logger = container.resolve<Logger>('logger');
```

**Difficulty:** Advanced

---

---

## Scoring Guide

### Scoring Breakdown

- **Multiple Choice:** 1 point each
- **True/False:** 1 point each
- **Short Answer:** 2 points each

### Chapter Scores

| Chapter | Total Points | Questions |
|---------|-------------|-----------|
| HTML Fundamentals | 32 | 18 |
| HTML Advanced | 27 | 15 |
| CSS Fundamentals | 28 | 16 |
| CSS Advanced | 27 | 15 |
| JavaScript Fundamentals | 28 | 16 |
| JavaScript Advanced | 27 | 15 |
| TypeScript Fundamentals | 28 | 16 |
| TypeScript Advanced | 27 | 15 |
| **TOTAL** | **224 points** | **143 questions** |

### Performance Levels

| Score | Level | Interpretation |
|-------|-------|-----------------|
| 200-224 (89-100%) | Expert | Mastery of all concepts; ready for advanced work |
| 176-199 (79-88%) | Advanced | Strong understanding; some gaps to address |
| 156-175 (70-78%) | Intermediate | Solid foundation; review advanced topics |
| 134-155 (60-69%) | Beginner | Basic understanding; study fundamentals |
| < 134 (< 60%) | Needs Review | Focus on core concepts; retry after review |

### Study Recommendations by Score

**90%+ (Expert)**
- Focus on advanced patterns and edge cases
- Implement real-world projects
- Mentor others in these technologies

**75-89% (Advanced)**
- Review chapters with lowest scores
- Practice coding challenges
- Deep dive into advanced patterns

**60-74% (Intermediate)**
- Revisit fundamental chapters
- Work through all code examples
- Complete practical exercises

**< 60% (Needs Work)**
- Start with Chapter 1 and review sequentially
- Run all code examples in a local environment
- Complete conceptual questions before moving forward

---

## Quiz Completion Tracking

### Instructions

1. **Take the quiz section by section** - Don't rush through all questions at once
2. **Track your scores** - Record points as you complete each chapter quiz
3. **Review incorrect answers** - Use explanations to understand mistakes
4. **Revisit weak areas** - Focus study time on chapters with lower scores
5. **Progress gradually** - Take quizzes again after studying to track improvement

### Progress Tracking Table

| Chapter | Date | Score | % | Notes |
|---------|------|-------|---|-------|
| Ch. 1: HTML Fundamentals | | / 32 | % | |
| Ch. 2: HTML Advanced | | / 27 | % | |
| Ch. 3: CSS Fundamentals | | / 28 | % | |
| Ch. 4: CSS Advanced | | / 27 | % | |
| Ch. 5: JS Fundamentals | | / 28 | % | |
| Ch. 6: JS Advanced | | / 27 | % | |
| Ch. 7: TS Fundamentals | | / 28 | % | |
| Ch. 8: TS Advanced | | / 27 | % | |

---

## Key Takeaways

1. **HTML** - Semantic markup and Web Components are essential for modern web development
2. **CSS** - Layout, responsive design, and modern features (Grid, Flexbox, Custom Properties)
3. **JavaScript** - Asynchronous patterns, closures, prototypes, and functional programming
4. **TypeScript** - Type safety, generics, and advanced type manipulation

---

**Last Updated:** October 26, 2024
**Level:** Expert
**Total Questions:** 143
**Total Points:** 224
