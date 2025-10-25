# HTML Fundamentals & Semantic Structure

## Overview

HTML (HyperText Markup Language) is the foundational language for creating web documents. This chapter covers essential HTML concepts, semantic markup, accessibility, and modern best practices.

---

## Part 1: HTML Basics & Document Structure

### HTML Document Structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Page description for SEO">
    <title>Page Title</title>
    <link rel="canonical" href="https://example.com/page">
</head>
<body>
    <!-- Content goes here -->
</body>
</html>
```

**Critical Components:**
- `<!DOCTYPE html>`: Declares HTML5 document type
- `<html lang="en">`: Root element with language attribute
- `<head>`: Contains metadata and non-visible information
- `<body>`: Contains visible content

### Meta Tags

```html
<!-- Character encoding (MUST be within first 1024 bytes) -->
<meta charset="UTF-8">

<!-- Viewport for responsive design -->
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">

<!-- Search Engine Optimization -->
<meta name="description" content="Concise page description">
<meta name="keywords" content="keyword1, keyword2">
<meta name="robots" content="index, follow">

<!-- Open Graph for social sharing -->
<meta property="og:title" content="Share title">
<meta property="og:description" content="Share description">
<meta property="og:image" content="https://example.com/image.jpg">
<meta property="og:url" content="https://example.com/page">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Tweet title">

<!-- PWA & Theming -->
<meta name="theme-color" content="#2563eb">
<link rel="manifest" href="/manifest.json">
<link rel="icon" href="/favicon.ico">
```

---

## Part 2: Semantic HTML5

### Semantic Elements

Semantic HTML gives meaning to content structure, improving SEO and accessibility.

```html
<!-- Header: Site branding, navigation, search -->
<header>
    <nav>
        <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/about">About</a></li>
        </ul>
    </nav>
</header>

<!-- Main Content Area -->
<main>
    <!-- Article/Blog Post -->
    <article>
        <header>
            <h1>Article Title</h1>
            <p>By <span class="author">John Doe</span> on <time datetime="2024-10-25">October 25, 2024</time></p>
        </header>
        <p>Article content...</p>
        <footer>
            <p>Tags: <span class="tag">html</span>, <span class="tag">web</span></p>
        </footer>
    </article>

    <!-- Sidebar with Related Content -->
    <aside>
        <h2>Related Posts</h2>
        <ul>
            <li><a href="#">Related post 1</a></li>
            <li><a href="#">Related post 2</a></li>
        </ul>
    </aside>
</main>

<!-- Footer: Site info, links, copyright -->
<footer>
    <p>&copy; 2024 Company. All rights reserved.</p>
</footer>
```

**Semantic Elements:**
| Element | Purpose |
|---------|---------|
| `<header>` | Introductory content, logo, navigation |
| `<nav>` | Navigation links |
| `<main>` | Primary content (one per page) |
| `<article>` | Self-contained content (post, article) |
| `<section>` | Thematic grouping of content |
| `<aside>` | Sidebar, related content |
| `<footer>` | Footer content, copyright, links |
| `<figure>` | Self-contained illustration |
| `<figcaption>` | Caption for figure |
| `<time>` | Machine-readable date/time |

### Section Example

```html
<article>
    <section>
        <h2>Introduction</h2>
        <p>Overview of the topic...</p>
    </section>

    <section>
        <h2>Main Content</h2>
        <p>Detailed information...</p>
    </section>

    <section>
        <h2>Conclusion</h2>
        <p>Summary...</p>
    </section>
</article>
```

---

## Part 3: Text Content Elements

### Headings Hierarchy

```html
<!-- Use only one H1 per page -->
<h1>Main Page Title</h1>

<!-- Logical hierarchy -->
<h2>Main Section</h2>
<h3>Subsection</h3>
<h4>Sub-subsection</h4>

<!-- Skip levels: AVOID this -->
<h1>Title</h1>
<h3>Subsection</h3>  <!-- Should be H2 -->
```

**Best Practices:**
- One H1 per page (for SEO and accessibility)
- Use heading hierarchy logically
- Don't skip heading levels
- Avoid using headings for styling

### Text Formatting

```html
<!-- Semantic Emphasis -->
<strong>Important text</strong>  <!-- vs <b> - semantic -->
<em>Emphasized text</em>        <!-- vs <i> - semantic -->

<!-- Explicit Emphasis (styling only) -->
<b>Bold text</b>                <!-- Styling only, not emphasis -->
<i>Italic text</i>              <!-- Styling only, not emphasis -->

<!-- Inline Elements -->
<code>const x = 10;</code>       <!-- Code snippet -->
<kbd>Ctrl + S</kbd>             <!-- Keyboard input -->
<samp>Output result</samp>      <!-- Computer output -->
<var>x</var>                    <!-- Mathematical variable -->
<mark>Highlighted text</mark>   <!-- Marked/highlighted -->
<del>Deleted text</del>         <!-- Deleted content -->
<ins>Inserted text</ins>        <!-- Inserted content -->
<sub>H<sub>2</sub>O</sub>       <!-- Subscript -->
<sup>x<sup>2</sup></sup>        <!-- Superscript -->

<!-- Quotations -->
<blockquote cite="https://source.com">
    <p>Long quote from a source.</p>
</blockquote>

<q cite="https://source.com">Short inline quote.</q>

<cite>Author or source citation</cite>
```

### Lists

```html
<!-- Unordered List -->
<ul>
    <li>Item 1</li>
    <li>Item 2</li>
    <li>Item 3</li>
</ul>

<!-- Ordered List -->
<ol>
    <li>First step</li>
    <li>Second step</li>
    <li>Third step</li>
</ol>

<!-- Definition List -->
<dl>
    <dt>Term 1</dt>
    <dd>Definition of term 1</dd>
    <dt>Term 2</dt>
    <dd>Definition of term 2</dd>
</dl>

<!-- Nested Lists -->
<ul>
    <li>Parent item
        <ul>
            <li>Child item 1</li>
            <li>Child item 2</li>
        </ul>
    </li>
</ul>
```

---

## Part 4: Forms & Input Elements

### Form Structure

```html
<form action="/submit" method="POST" novalidate>
    <!-- Text Input -->
    <label for="username">Username:</label>
    <input
        type="text"
        id="username"
        name="username"
        required
        minlength="3"
        maxlength="20"
        placeholder="Enter username"
        autocomplete="username"
    >

    <!-- Email Input (Built-in validation) -->
    <label for="email">Email:</label>
    <input
        type="email"
        id="email"
        name="email"
        required
        autocomplete="email"
    >

    <!-- Password Input -->
    <label for="password">Password:</label>
    <input
        type="password"
        id="password"
        name="password"
        required
        minlength="8"
        autocomplete="current-password"
    >

    <!-- Number Input -->
    <label for="age">Age:</label>
    <input
        type="number"
        id="age"
        name="age"
        min="18"
        max="120"
    >

    <!-- Date Input -->
    <label for="dob">Date of Birth:</label>
    <input type="date" id="dob" name="dob">

    <!-- Textarea -->
    <label for="message">Message:</label>
    <textarea
        id="message"
        name="message"
        rows="5"
        cols="40"
        maxlength="500"
        placeholder="Enter your message"
    ></textarea>

    <!-- Select Dropdown -->
    <label for="country">Country:</label>
    <select id="country" name="country" required>
        <option value="">-- Select Country --</option>
        <option value="us">United States</option>
        <option value="uk">United Kingdom</option>
        <option value="ca">Canada</option>
    </select>

    <!-- Checkboxes -->
    <fieldset>
        <legend>Interests:</legend>
        <label>
            <input type="checkbox" name="interests" value="sports"> Sports
        </label>
        <label>
            <input type="checkbox" name="interests" value="reading"> Reading
        </label>
    </fieldset>

    <!-- Radio Buttons -->
    <fieldset>
        <legend>Gender:</legend>
        <label>
            <input type="radio" name="gender" value="male"> Male
        </label>
        <label>
            <input type="radio" name="gender" value="female"> Female
        </label>
    </fieldset>

    <!-- Buttons -->
    <button type="submit">Submit</button>
    <button type="reset">Reset</button>
    <button type="button">Button</button>
</form>
```

### Input Validation Attributes

```html
<!-- HTML5 Validation -->
<input required>                        <!-- Field is required -->
<input type="email">                    <!-- Must be valid email -->
<input type="url">                      <!-- Must be valid URL -->
<input minlength="5">                   <!-- Minimum length -->
<input maxlength="20">                  <!-- Maximum length -->
<input min="0" max="100">               <!-- Range -->
<input pattern="[A-Z]{3}">              <!-- Regex pattern -->

<!-- Custom Validation JavaScript -->
<form id="myForm">
    <input type="text" id="username">
    <button type="submit">Submit</button>
</form>

<script>
    const form = document.getElementById('myForm');
    form.addEventListener('submit', (e) => {
        e.preventDefault();
        if (form.checkValidity() === false) {
            e.stopPropagation();
        }
        form.classList.add('was-validated');
    });
</script>
```

---

## Part 5: Media & Embedded Content

### Images

```html
<!-- Basic Image -->
<img
    src="image.jpg"
    alt="Descriptive alt text"
    width="800"
    height="600"
    loading="lazy"
>

<!-- Responsive Images with srcset -->
<img
    src="image.jpg"
    srcset="
        image-small.jpg 480w,
        image-medium.jpg 800w,
        image-large.jpg 1200w
    "
    sizes="
        (max-width: 480px) 100vw,
        (max-width: 800px) 80vw,
        (max-width: 1200px) 60vw,
        800px
    "
    alt="Descriptive text"
>

<!-- Picture Element for Art Direction -->
<picture>
    <source media="(min-width: 1200px)" srcset="image-desktop.jpg">
    <source media="(min-width: 768px)" srcset="image-tablet.jpg">
    <source media="(max-width: 767px)" srcset="image-mobile.jpg">
    <img src="image-fallback.jpg" alt="Descriptive text">
</picture>

<!-- Figure with Caption -->
<figure>
    <img src="chart.png" alt="Sales chart">
    <figcaption>Figure 1: Monthly sales data 2024</figcaption>
</figure>
```

### Video & Audio

```html
<!-- Video with Multiple Formats & Fallback -->
<video
    width="640"
    height="360"
    controls
    preload="metadata"
    poster="video-poster.jpg"
>
    <source src="video.mp4" type="video/mp4">
    <source src="video.webm" type="video/webm">
    <p>Your browser doesn't support HTML5 video.</p>
</video>

<!-- Audio -->
<audio controls preload="metadata">
    <source src="audio.mp3" type="audio/mpeg">
    <source src="audio.ogg" type="audio/ogg">
    Your browser doesn't support HTML5 audio.
</audio>

<!-- Video with Tracks (Captions, Subtitles) -->
<video controls>
    <source src="video.mp4" type="video/mp4">
    <track kind="captions" src="captions-en.vtt" srclang="en" label="English">
    <track kind="subtitles" src="subtitles-es.vtt" srclang="es" label="Spanish">
</video>
```

---

## Part 6: Accessibility (A11y)

### ARIA Attributes

```html
<!-- Landmark Roles -->
<div role="navigation" aria-label="Main navigation">
    <ul>
        <li><a href="/">Home</a></li>
    </ul>
</div>

<!-- Live Regions -->
<div role="status" aria-live="polite" aria-atomic="true">
    <!-- Updates announced to screen readers -->
</div>

<!-- Buttons with Icons -->
<button aria-label="Close menu">×</button>

<!-- Expandable Content -->
<button
    aria-expanded="false"
    aria-controls="menu-content"
>
    Menu
</button>
<div id="menu-content" hidden>
    <!-- Menu items -->
</div>

<!-- Modal Dialog -->
<div role="dialog" aria-labelledby="dialog-title" aria-modal="true">
    <h2 id="dialog-title">Confirm Action</h2>
    <p>Are you sure?</p>
    <button>Yes</button>
    <button>No</button>
</div>

<!-- Skip Links -->
<body>
    <a href="#main" class="skip-link">Skip to main content</a>
    <nav>Navigation...</nav>
    <main id="main">Content...</main>
</body>
```

### Accessibility Best Practices

```html
<!-- 1. Alt Text for Images -->
<img src="dog.jpg" alt="Golden retriever playing fetch in park">

<!-- 2. Form Labels -->
<label for="email">Email Address:</label>
<input type="email" id="email" name="email">

<!-- 3. Semantic HTML -->
<button>Click me</button>      <!-- Instead of <div onclick> -->

<!-- 4. Color Not Alone -->
<p>
    <span style="color: red;">●</span>
    <span>Error: Please check your input</span>
</p>

<!-- 5. Sufficient Contrast -->
<!-- Text should have at least 4.5:1 contrast ratio -->

<!-- 6. Keyboard Navigation -->
<button tabindex="0">Focusable button</button>
<div tabindex="-1">Not in tab order</div>

<!-- 7. Heading Structure -->
<h1>Page Title</h1>
<h2>Section 1</h2>
<h3>Subsection 1.1</h3>
```

---

## Part 7: Modern HTML Features

### Data Attributes

```html
<div data-user-id="12345" data-role="admin" data-status="active">
    User Profile
</div>

<script>
    const div = document.querySelector('div');
    console.log(div.dataset.userId);    // "12345"
    console.log(div.dataset.role);      // "admin"
    console.log(div.dataset.status);    // "active"
</script>
```

### Custom Elements

```html
<!-- Define custom element -->
<custom-card
    title="Card Title"
    image="image.jpg"
    description="Card description"
>
</custom-card>

<script>
    class CustomCard extends HTMLElement {
        connectedCallback() {
            const title = this.getAttribute('title');
            const image = this.getAttribute('image');
            this.innerHTML = `
                <div class="card">
                    <img src="${image}" alt="">
                    <h2>${title}</h2>
                </div>
            `;
        }
    }
    customElements.define('custom-card', CustomCard);
</script>
```

### Template & Slot (Web Components)

```html
<template id="card-template">
    <style>
        .card { border: 1px solid #ccc; padding: 20px; }
    </style>
    <div class="card">
        <h2><slot name="title">Default Title</slot></h2>
        <p><slot>Default content</slot></p>
    </div>
</template>

<card-element>
    <span slot="title">Custom Title</span>
    Custom content here
</card-element>
```

---

## Part 8: SEO Best Practices

### Structured Data (Schema.org)

```html
<script type="application/ld+json">
{
    "@context": "https://schema.org/",
    "@type": "Article",
    "headline": "Article Title",
    "image": "https://example.com/image.jpg",
    "author": {
        "@type": "Person",
        "name": "John Doe"
    },
    "datePublished": "2024-10-25",
    "dateModified": "2024-10-26"
}
</script>
```

### Robots Meta Tags

```html
<!-- Tell search engines how to crawl -->
<meta name="robots" content="index, follow">
<meta name="robots" content="noindex, nofollow">  <!-- Private pages -->

<!-- Canonical URL (prevent duplicate content) -->
<link rel="canonical" href="https://example.com/page">

<!-- Preload critical resources -->
<link rel="preload" href="font.woff2" as="font" type="font/woff2" crossorigin>

<!-- DNS Prefetch for external domains -->
<link rel="dns-prefetch" href="https://cdn.example.com">

<!-- Preconnect for critical third-party origins -->
<link rel="preconnect" href="https://api.example.com">
```

---

## Part 9: Performance Optimization

### Resource Loading

```html
<!-- Defer JavaScript (non-critical scripts) -->
<script src="script.js" defer></script>

<!-- Async JavaScript (independent scripts) -->
<script src="analytics.js" async></script>

<!-- Preload critical resources -->
<link rel="preload" href="critical-style.css" as="style">

<!-- Lazy load images -->
<img src="image.jpg" loading="lazy" alt="Description">

<!-- Lazy load iframes -->
<iframe src="video.html" loading="lazy"></iframe>
```

---

## Key Takeaways

1. **Semantic HTML** provides structure and meaning
2. **Proper heading hierarchy** improves accessibility and SEO
3. **Forms require labels** for accessibility
4. **Alt text for images** is critical for accessibility and SEO
5. **Meta tags** control how pages appear in search and social media
6. **Accessibility is not optional** - it's a requirement
7. **Performance matters** - optimize resource loading
8. **Validation** improves data quality and user experience

---

**Last Updated:** October 25, 2024
**Level:** Expert
**Topics Covered:** 50+ concepts, 100+ code examples
