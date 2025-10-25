# Advanced CSS & Modern Techniques

## Part 1: CSS Grid Advanced

```css
/* Named grid lines */
.grid {
    display: grid;
    grid-template-columns: [sidebar-start] 200px [sidebar-end main-start] 1fr [main-end];
    grid-template-rows: [header] 60px [nav] 40px [content] 1fr [footer] 80px;
    gap: 20px;
}

.sidebar {
    grid-column: sidebar-start / sidebar-end;
    grid-row: nav / content;
}

.main {
    grid-column: main-start / main-end;
    grid-row: content;
}

/* Template areas */
.grid-layout {
    display: grid;
    grid-template-columns: 200px 1fr 200px;
    grid-template-rows: 60px 1fr 80px;
    grid-template-areas:
        "header header header"
        "sidebar main aside"
        "footer footer footer";
}

.header { grid-area: header; }
.sidebar { grid-area: sidebar; }
.main { grid-area: main; }
.aside { grid-area: aside; }
.footer { grid-area: footer; }

/* Auto-fit vs Auto-fill */
.responsive-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
}

/* Subgrid */
.item {
    display: grid;
    grid-column: span 2;
    grid-template-columns: subgrid;
}

/* Grid alignment */
.grid-container {
    display: grid;
    justify-items: center;        /* Horizontal alignment */
    align-items: center;           /* Vertical alignment */
    justify-content: space-between; /* Space between items */
    align-content: space-around;   /* Space around items */
    gap: 20px;
}

.item {
    justify-self: start;           /* Override horizontal */
    align-self: end;               /* Override vertical */
}
```

## Part 2: Flexbox Mastery

```css
/* Flex container */
.flex {
    display: flex;
    flex-direction: row;           /* row | column | row-reverse | column-reverse */
    justify-content: center;       /* Main axis: flex-start, flex-end, center, space-between, space-around, space-evenly */
    align-items: center;           /* Cross axis: stretch, flex-start, flex-end, center, baseline */
    align-content: space-between;  /* Multiple rows: same as justify-content */
    gap: 20px;
    flex-wrap: wrap;
}

/* Flex items */
.item {
    flex: 1;                       /* shorthand: grow shrink basis */
    flex-grow: 1;                  /* Growth factor */
    flex-shrink: 1;                /* Shrink factor */
    flex-basis: 200px;             /* Base size */
    align-self: flex-end;          /* Override cross axis */
    order: 1;                      /* Visual order (default: 0) */
    min-width: 0;                  /* Allow shrinking below content size */
}

/* Flex gaps */
.flex {
    gap: 20px;                     /* All gaps */
    row-gap: 20px;                 /* Between rows */
    column-gap: 20px;              /* Between columns */
}

/* Absolute flex */
.flex-item {
    position: absolute;
    margin: auto;                  /* Center with flexbox */
}
```

## Part 3: CSS Variables & Theming

```css
/* Define custom properties (CSS variables) */
:root {
    /* Colors */
    --color-primary: #2563eb;
    --color-secondary: #1e40af;
    --color-success: #10b981;
    --color-danger: #ef4444;
    --color-warning: #f59e0b;

    /* Spacing */
    --spacing-xs: 0.25rem;
    --spacing-sm: 0.5rem;
    --spacing-md: 1rem;
    --spacing-lg: 2rem;
    --spacing-xl: 4rem;

    /* Typography */
    --font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    --font-size-sm: 0.875rem;
    --font-size-base: 1rem;
    --font-size-lg: 1.25rem;
    --font-size-xl: 1.5rem;
    --line-height-base: 1.5;

    /* Borders */
    --border-radius-sm: 0.25rem;
    --border-radius-base: 0.375rem;
    --border-radius-lg: 0.5rem;

    /* Shadows */
    --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
    --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    --shadow-lg: 0 20px 25px -5px rgba(0, 0, 0, 0.1);

    /* Transitions */
    --transition-fast: 150ms;
    --transition-base: 250ms;
    --transition-slow: 350ms;
}

/* Light theme */
html {
    --bg-primary: #ffffff;
    --bg-secondary: #f9fafb;
    --text-primary: #1f2937;
    --text-secondary: #6b7280;
    --border-color: #e5e7eb;
}

/* Dark theme */
html.dark {
    --bg-primary: #1f2937;
    --bg-secondary: #111827;
    --text-primary: #f9fafb;
    --text-secondary: #d1d5db;
    --border-color: #374151;
}

/* Use variables */
.button {
    background-color: var(--color-primary);
    color: white;
    padding: var(--spacing-md);
    border-radius: var(--border-radius-base);
    font-family: var(--font-family);
    transition: background-color var(--transition-base) ease;
    box-shadow: var(--shadow-md);
}

.button:hover {
    background-color: var(--color-secondary);
}

/* Fallback values */
.text {
    color: var(--text-primary, #1f2937);
}

/* Computed values */
.container {
    max-width: calc(var(--spacing-xl) * 10);
    padding: var(--spacing-lg);
    margin: calc(var(--spacing-md) * 2) auto;
}

/* Theme switching */
html.dark-mode {
    color-scheme: dark;
}

@media (prefers-color-scheme: dark) {
    :root {
        /* Dark theme defaults */
    }
}
```

## Part 4: CSS Containment & Performance

```css
/* Containment */
.component {
    /* Layout containment */
    contain: layout;               /* Element doesn't affect outside layout */

    /* Paint containment */
    contain: paint;                /* Doesn't paint outside boundaries */

    /* Size containment */
    contain: size;                 /* Size not affected by children */

    /* Style containment */
    contain: style;                /* Style isolated */

    /* Content containment */
    contain: content;              /* Layout, paint, style */

    /* Strict */
    contain: strict;               /* Layout, paint, size, style */
}

/* Content visibility */
.off-screen {
    content-visibility: auto;      /* Skip rendering until visible */
}

.hidden-initially {
    content-visibility: hidden;
}

/* Will-change hint */
.animated {
    will-change: transform;
    transform: translate(0);
}

/* Avoid expensive properties */
.good {
    transform: translateX(10px);   /* GPU accelerated */
}

.bad {
    left: 10px;                    /* Not GPU accelerated */
    position: relative;
}
```

## Part 5: CSS At-Rules

```css
/* Media queries */
@media (max-width: 768px) {
    .responsive { width: 100%; }
}

/* Keyframes for animations */
@keyframes slide {
    from { transform: translateX(-100%); }
    to { transform: translateX(0); }
}

/* Font face for custom fonts */
@font-face {
    font-family: 'CustomFont';
    src: url('font.woff2') format('woff2');
    font-display: swap;
}

/* Import external stylesheets */
@import url('https://fonts.googleapis.com/css2?family=Roboto');

/* Supports (feature detection) */
@supports (display: grid) {
    .grid-layout {
        display: grid;
    }
}

@supports not (display: grid) {
    .grid-layout {
        display: flex;
    }
}

/* Container queries (CSS 4) */
@container (min-width: 400px) {
    .card { display: grid; }
}

/* Layer for cascade control */
@layer reset, theme, utilities {
    @layer reset {
        * { margin: 0; }
    }
    @layer theme {
        body { font-family: sans-serif; }
    }
    @layer utilities {
        .text-center { text-align: center; }
    }
}
```

## Part 6: Pseudo-Elements & Classes

```css
/* Pseudo-elements */
::before {
    content: "";                   /* Must have for visibility */
    display: block;
}

::after { }

::first-line { font-weight: bold; }
::first-letter { font-size: 2em; }
::selection { background: blue; }
::marker { color: red; }

/* Pseudo-classes */
:hover { }
:active { }
:focus { }
:visited { }
:link { }
:target { }
:not(p) { }
:is(h1, h2, h3) { }
:where(h1, h2, h3) { }
:has(> img) { }                  /* Parent selector */
:focus-visible { }
:focus-within { }
:valid { }
:invalid { }
:checked { }
:disabled { }
:enabled { }
:empty { }
:blank { }
:nth-child(2n) { }
:nth-of-type(3) { }
:first-child { }
:last-child { }
:only-child { }
```

## Part 7: CSS Scroll Behavior

```css
/* Smooth scroll */
html {
    scroll-behavior: smooth;
}

/* Scroll padding (for fixed headers) */
html {
    scroll-padding-top: 80px;
}

/* Scroll snap */
.scroll-container {
    scroll-snap-type: y mandatory;
    overflow-y: scroll;
    height: 100vh;
}

.scroll-item {
    scroll-snap-align: start;
    scroll-snap-stop: always;
    height: 100vh;
}

/* Scrollbar styling */
::-webkit-scrollbar {
    width: 10px;
}

::-webkit-scrollbar-track {
    background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
    background: #888;
    border-radius: 5px;
}

::-webkit-scrollbar-thumb:hover {
    background: #555;
}

/* Overflow control */
.scrollable {
    overflow: auto;
    overflow-x: hidden;
    overflow-y: auto;
    overflow: hidden auto;
    overscroll-behavior: contain;
}
```

## Part 8: Masking & Clipping

```css
/* Clip path */
.clipped {
    clip-path: circle(50%);
    clip-path: ellipse(30% 40%);
    clip-path: polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%);
    clip-path: inset(10px 20px 30px 40px);
    clip-path: polygon(0 0, 100% 0, 100% 85%, 0 100%);
    clip-path: path('M 0,0 L 100,0 L 100,100 L 0,100 Z');
}

/* Mask */
.masked {
    mask-image: url('#mask');
    mask-image: linear-gradient(to right, transparent, black);
    mask-size: cover;
    mask-position: center;
    mask-repeat: no-repeat;
    mask-clip: padding-box;
    mask-composite: intersect;
}

/* Shape outside (for text wrapping) */
.shape {
    shape-outside: circle(50%);
    shape-margin: 10px;
    float: left;
    width: 100px;
    height: 100px;
}
```

## Performance Best Practices

```css
/* ✓ DO */
.good {
    /* Specific selectors (fast) */
    .header .nav-link { }

    /* Direct child combinator (faster) */
    .header > .nav { }

    /* Classes (fast) */
    .button { }

    /* ID when necessary (fastest) */
    #main { }

    /* Use transform/opacity (GPU accelerated) */
    transform: translateX(10px);
    opacity: 0.5;
}

/* ✗ AVOID */
.bad {
    /* Universal selector (slow) */
    * { }

    /* Attribute selectors (slow) */
    [data-role="button"] { }

    /* Complex pseudo-selectors */
    :not(.p):not(.div) { }

    /* Expensive properties (CPU bound) */
    position: relative; left: 10px;
    width: calc(100% / 7 * 2);

    /* Box shadows on many elements */
    box-shadow: 0 0 20px rgba(0,0,0,0.5);
}

/* Critical CSS */
/* Inline above-the-fold critical CSS */
<style>
    /* Essential rendering styles */
    body { font-family: sans-serif; }
    .header { background: #f0f0f0; }
</style>

/* Defer non-critical CSS */
<link rel="stylesheet" href="non-critical.css" media="print" onload="this.media='all'">
```

---

## Key Takeaways

1. **Grid** for complex layouts, **Flexbox** for components
2. **CSS Variables** enable dynamic theming
3. **Containment** improves performance
4. **Feature detection** ensures progressive enhancement
5. **Scroll snap** improves user experience
6. **GPU acceleration** with transform and opacity
7. **Masking and clipping** create complex shapes
8. **Specificity management** keeps CSS maintainable

---

**Last Updated:** October 25, 2024
**Level:** Expert
**Topics Covered:** 50+ advanced CSS concepts
