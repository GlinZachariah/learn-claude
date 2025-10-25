# CSS Fundamentals & Styling

## Part 1: CSS Basics

### Selectors & Specificity

```css
/* Element Selector */
p { color: blue; }

/* Class Selector */
.container { width: 1200px; }

/* ID Selector (use sparingly) */
#header { position: fixed; }

/* Attribute Selector */
input[type="text"] { border: 1px solid #ccc; }
a[href^="https"] { color: green; }
a[href$=".pdf"] { color: red; }

/* Pseudo-class */
a:hover { color: red; }
a:visited { color: purple; }
input:focus { outline: 2px solid blue; }
p:first-child { margin-top: 0; }
li:nth-child(2n) { background: #f0f0f0; }
li:last-child { margin-bottom: 0; }

/* Pseudo-element */
p::before { content: "→ "; }
p::first-letter { font-size: 2em; }
p::first-line { font-weight: bold; }
input::placeholder { color: #999; }

/* Combinators */
.parent > .child { }              /* Direct child */
.ancestor .descendant { }         /* Any descendant */
.sibling + .next-sibling { }      /* Adjacent sibling */
.sibling ~ .sibling { }           /* General sibling */

/* Multiple selectors */
h1, h2, h3 { font-family: Arial; }

/* Compound selector */
button.primary { background: blue; }
```

### Specificity

```
Specificity = (ID selectors) (Class selectors, attribute selectors, pseudo-classes) (Element selectors, pseudo-elements)

Examples:
p                           0-0-1
.class                      0-1-0
#id                         1-0-0
p.class#id                  1-1-1
div > p.class               0-1-1
:not(p)                     0-1-0
!important                  Overrides all (use sparingly)
```

---

## Part 2: Box Model & Layout

### Box Model

```css
.box {
    /* Content width/height */
    width: 200px;
    height: 200px;

    /* Padding (inside border) */
    padding: 20px;
    padding-top: 10px;
    padding-right: 15px;
    padding-bottom: 10px;
    padding-left: 15px;
    padding: 10px 15px;           /* vertical horizontal */
    padding: 10px 15px 12px 20px; /* top right bottom left */

    /* Border */
    border: 2px solid #333;
    border-width: 2px;
    border-style: solid;
    border-color: #333;
    border-radius: 8px;
    border-top-left-radius: 4px;

    /* Margin (outside border) */
    margin: 20px;
    margin: 20px auto;             /* Center horizontally */
    margin-collapse: true;         /* Adjacent margins collapse */

    /* Box sizing */
    box-sizing: content-box;       /* Default: width/height = content only */
    box-sizing: border-box;        /* width/height = content + padding + border */
}

/* Reset margins for better consistency */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}
```

### Display & Positioning

```css
/* Display Values */
.inline { display: inline; }       /* Flow with text */
.block { display: block; }         /* Full width, new line */
.inline-block { display: inline-block; } /* Inline but respects dimensions */
.none { display: none; }           /* Removed from layout */

/* Flex Layout */
.flex-container {
    display: flex;
    flex-direction: row;           /* row | column | row-reverse | column-reverse */
    justify-content: center;       /* main axis */
    align-items: center;           /* cross axis */
    gap: 20px;
    flex-wrap: wrap;
}

.flex-item {
    flex: 1;                       /* Grow equal */
    flex-basis: 200px;
    flex-grow: 1;
    flex-shrink: 1;
    align-self: flex-start;
}

/* Grid Layout */
.grid-container {
    display: grid;
    grid-template-columns: repeat(3, 1fr);      /* 3 equal columns */
    grid-template-columns: 200px 1fr 200px;     /* 2 sidebars, flexible center */
    grid-template-rows: auto 1fr auto;          /* Header, content, footer */
    gap: 20px;
    grid-auto-flow: dense;
}

.grid-item {
    grid-column: span 2;           /* Span 2 columns */
    grid-row: 1 / 3;               /* Row 1 to 3 */
    grid-column: 1 / -1;           /* Full width */
}

/* Position Values */
.static { position: static; }      /* Default */
.relative { position: relative; top: 10px; left: 20px; }  /* Relative to normal position */
.absolute { position: absolute; top: 0; right: 0; }       /* Relative to positioned parent */
.fixed { position: fixed; top: 0; right: 0; }             /* Relative to viewport */
.sticky { position: sticky; top: 0; }                     /* Sticky until scroll */

/* Stacking context */
.z-index { z-index: 10; position: relative; }
```

---

## Part 3: Typography

### Font Properties

```css
.text {
    /* Font family (fallback list) */
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;

    /* Font size */
    font-size: 16px;               /* Absolute */
    font-size: 1em;                /* Relative to parent */
    font-size: 1.5rem;             /* Relative to root */
    font-size: clamp(16px, 5vw, 32px);  /* Responsive, min, preferred, max */

    /* Font weight */
    font-weight: normal;           /* 400 */
    font-weight: bold;             /* 700 */
    font-weight: 600;              /* 0-900 */

    /* Font style */
    font-style: normal;
    font-style: italic;

    /* Letter spacing */
    letter-spacing: 0.05em;
    letter-spacing: 2px;

    /* Line height */
    line-height: 1.5;              /* Unitless (multiplier) - preferred */
    line-height: 1.5em;            /* Relative to font-size */
    line-height: 24px;             /* Absolute */

    /* Text alignment */
    text-align: left;
    text-align: center;
    text-align: justify;

    /* Text transform */
    text-transform: uppercase;
    text-transform: lowercase;
    text-transform: capitalize;

    /* Text decoration */
    text-decoration: underline;
    text-decoration: underline wavy red 3px;
    text-decoration-line: underline;
    text-decoration-style: wavy;
    text-decoration-color: red;
    text-decoration-thickness: 3px;
    text-decoration-skip-ink: auto;

    /* Text shadow */
    text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    text-shadow: 1px 1px 0 #999, 2px 2px 0 #888;

    /* Word spacing */
    word-spacing: 0.2em;
    word-break: break-word;

    /* Whitespace */
    white-space: nowrap;           /* No wrapping */
    white-space: pre;              /* Preserve spaces */
    white-space: pre-wrap;         /* Preserve + wrap */
    white-space: pre-line;         /* Preserve line breaks */

    /* Text overflow */
    text-overflow: ellipsis;
    overflow: hidden;
    display: -webkit-box;
    -webkit-line-clamp: 2;         /* Limit to 2 lines */
    -webkit-box-orient: vertical;
}

/* Web Fonts */
@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap');

@font-face {
    font-family: 'CustomFont';
    src: url('font.woff2') format('woff2'),
         url('font.woff') format('woff');
    font-weight: 400;
    font-style: normal;
    font-display: swap;            /* Show fallback immediately */
}
```

---

## Part 4: Colors & Backgrounds

### Color Systems

```css
.color-example {
    /* Named colors */
    color: red;

    /* Hex colors */
    color: #ff0000;
    color: #f00;                  /* Shorthand */

    /* RGB */
    color: rgb(255, 0, 0);

    /* RGBA (with alpha/transparency) */
    color: rgba(255, 0, 0, 0.5);

    /* HSL (Hue, Saturation, Lightness) */
    color: hsl(0, 100%, 50%);

    /* HSLA */
    color: hsla(0, 100%, 50%, 0.5);

    /* CSS Custom Properties (Variables) */
    --primary-color: #2563eb;
    --secondary-color: #1e40af;
    color: var(--primary-color);
    color: var(--primary-color, blue);  /* With fallback */
}

/* Contrast and readability */
.high-contrast {
    color: #000000;
    background: #ffffff;           /* 21:1 contrast ratio */
}
```

### Backgrounds

```css
.background {
    /* Solid background */
    background-color: #f0f0f0;

    /* Background image */
    background-image: url('image.jpg');
    background-size: cover;        /* Cover entire element */
    background-size: contain;      /* Fit entire image */
    background-size: 100% 100%;
    background-size: 200px 200px;
    background-position: center;
    background-position: right bottom;
    background-position: 50% 50%;

    /* Background repeat */
    background-repeat: no-repeat;
    background-repeat: repeat-x;
    background-repeat: repeat-y;

    /* Background attachment */
    background-attachment: fixed;  /* Parallax effect */
    background-attachment: scroll;

    /* Multiple backgrounds */
    background:
        url('overlay.png') center/cover,
        url('base.jpg') center/cover,
        #f0f0f0;

    /* Linear gradient */
    background: linear-gradient(to right, red, blue);
    background: linear-gradient(45deg, red, yellow, green);
    background: linear-gradient(to right, red 0%, blue 50%, green 100%);

    /* Radial gradient */
    background: radial-gradient(circle, red, blue);
    background: radial-gradient(ellipse at center, yellow, red);

    /* Conic gradient */
    background: conic-gradient(red, yellow, lime, aqua, blue, magenta, red);

    /* Clip path (mask) */
    background-clip: padding-box;  /* Default */
    background-clip: content-box;
    background-clip: text;

    /* Blend modes */
    mix-blend-mode: multiply;
    mix-blend-mode: screen;
    mix-blend-mode: overlay;
    mix-blend-mode: darken;
    mix-blend-mode: lighten;
}
```

---

## Part 5: Transforms & Animations

### Transforms

```css
.transformed {
    /* 2D Transforms */
    transform: translate(10px, 20px);      /* Move */
    transform: scale(1.5);                  /* Scale uniformly */
    transform: scale(1.5, 0.8);            /* Scale x and y */
    transform: rotate(45deg);              /* Rotate */
    transform: skew(10deg, 20deg);         /* Skew */

    /* 3D Transforms */
    transform: translateZ(100px);
    transform: translate3d(10px, 20px, 100px);
    transform: rotateX(45deg);
    transform: rotateY(45deg);
    transform: rotateZ(45deg);
    transform: rotate3d(1, 1, 1, 45deg);
    transform: perspective(600px);
    transform: scaleZ(2);

    /* Multiple transforms */
    transform: translate(10px, 20px) rotate(45deg) scale(1.5);

    /* Transform origin (default: center) */
    transform-origin: top left;
    transform-origin: 50% 50%;

    /* Perspective (for 3D effect) */
    perspective: 600px;
    transform-style: preserve-3d;

    /* Backface visibility */
    backface-visibility: hidden;
}
```

### Transitions

```css
.transition-example {
    /* All properties */
    transition: all 0.3s ease-in-out;

    /* Specific property */
    transition: background-color 0.3s ease-in-out;

    /* Multiple properties */
    transition:
        background-color 0.3s ease-in,
        transform 0.3s ease-out,
        opacity 0.2s linear;

    /* Timing functions */
    /* linear, ease (default), ease-in, ease-out, ease-in-out */
    /* cubic-bezier(0.4, 0.0, 0.2, 1) for custom */

    /* Transition delay */
    transition-delay: 0.1s;

    /* On hover */
}

.transition-example:hover {
    background-color: blue;
    transform: scale(1.1);
    opacity: 0.8;
}
```

### Keyframe Animations

```css
/* Define animation */
@keyframes slide-in {
    from {
        opacity: 0;
        transform: translateX(-100%);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes bounce {
    0% { transform: translateY(0); }
    50% { transform: translateY(-20px); }
    100% { transform: translateY(0); }
}

/* Apply animation */
.animated {
    animation: slide-in 0.5s ease-in-out;

    /* Full syntax */
    animation-name: slide-in;
    animation-duration: 0.5s;
    animation-timing-function: ease-in-out;
    animation-delay: 0.2s;
    animation-iteration-count: 1;     /* or infinite */
    animation-direction: normal;       /* forward | backward | alternate */
    animation-fill-mode: forwards;     /* Keep final state */
    animation-play-state: running;     /* paused */
}

/* Multiple animations */
.multi-animated {
    animation:
        slide-in 0.5s ease-in-out,
        bounce 1s infinite 0.5s;
}
```

---

## Part 6: Filters & Effects

```css
.effects {
    /* Blur */
    filter: blur(5px);

    /* Brightness */
    filter: brightness(1.2);

    /* Contrast */
    filter: contrast(1.5);

    /* Grayscale */
    filter: grayscale(100%);

    /* Hue rotate */
    filter: hue-rotate(90deg);

    /* Invert */
    filter: invert(100%);

    /* Opacity */
    filter: opacity(50%);

    /* Saturate */
    filter: saturate(2);

    /* Sepia */
    filter: sepia(100%);

    /* Drop shadow */
    filter: drop-shadow(2px 2px 5px rgba(0,0,0,0.3));

    /* Multiple filters */
    filter: blur(2px) brightness(1.1) contrast(1.2);

    /* Backdrop filter (CSS 4) */
    backdrop-filter: blur(10px);
}

/* Box shadow */
.shadows {
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    box-shadow:
        0 1px 3px rgba(0,0,0,0.12),
        0 1px 2px rgba(0,0,0,0.24);    /* Elevation shadow */
    box-shadow: inset 0 0 5px rgba(0,0,0,0.2);
}
```

---

## Part 7: Responsive Design

### Media Queries

```css
/* Mobile-first approach (recommended) */
.container {
    width: 100%;
    padding: 10px;
}

@media (min-width: 768px) {
    .container {
        width: 750px;
        padding: 20px;
    }
}

@media (min-width: 1024px) {
    .container {
        width: 960px;
    }
}

@media (min-width: 1440px) {
    .container {
        width: 1320px;
    }
}

/* Other media features */
@media (max-width: 600px) { }       /* Max width */
@media (orientation: landscape) { } /* Landscape */
@media (orientation: portrait) { }  /* Portrait */
@media (prefers-dark-mode) { }      /* Dark mode preference */
@media (prefers-reduced-motion) { } /* Reduce animations */
@media (hover: hover) { }           /* Can hover (not touch) */
@media (pointer: fine) { }          /* Precise pointer */
@media print { }                    /* Print styles */
```

### Viewport & Flexible Units

```html
<!-- Viewport meta tag (required for responsive) -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

```css
/* Flexible units */
.responsive {
    width: 100%;                /* Percentage - relative to parent */
    max-width: 1200px;
    padding: 5%;                /* Percentage of parent width */

    font-size: 2vw;             /* Viewport width - 1vw = 1% of viewport width */
    font-size: 3vh;             /* Viewport height */
    font-size: 2vmin;           /* Min of vw and vh */

    /* REM (relative to root font-size) */
    margin: 1rem;               /* Usually 16px */
    padding: 2rem;

    /* EM (relative to font-size) */
    padding: 1em;               /* Relative to element font-size */

    /* Calc for combinations */
    width: calc(100% - 20px);
    width: calc(100vw - 2rem);
    margin-top: max(1rem, 5%);
    margin-top: min(2rem, 5vw);
    margin-top: clamp(1rem, 5%, 3rem);
}
```

---

## Key Takeaways

1. **CSS Specificity** determines which rules apply
2. **Box Model** is fundamental to layout
3. **Flexbox** simplifies alignment and distribution
4. **Grid** enables complex layouts efficiently
5. **Mobile-first approach** ensures responsive design
6. **Custom Properties** reduce repetition and enable dynamic theming
7. **Transforms** create smooth, GPU-accelerated effects
8. **Media Queries** adapt design to different devices

---

**Last Updated:** October 25, 2024
**Level:** Expert
**Topics Covered:** 60+ CSS concepts, 100+ code examples
