# Advanced HTML & Web Components

## Advanced Form Features & Validation

### Form Features

```html
<!-- Input Groups -->
<fieldset>
    <legend>Personal Information</legend>
    <div class="form-group">
        <label for="firstName">First Name:</label>
        <input type="text" id="firstName" name="firstName" required>
    </div>
    <div class="form-group">
        <label for="lastName">Last Name:</label>
        <input type="text" id="lastName" name="lastName" required>
    </div>
</fieldset>

<!-- Datalist (Autocomplete) -->
<label for="browser">Choose your browser:</label>
<input
    list="browsers"
    id="browser"
    name="browser"
>
<datalist id="browsers">
    <option value="Chrome">
    <option value="Firefox">
    <option value="Safari">
    <option value="Edge">
</datalist>

<!-- Color Input -->
<label for="favoriteColor">Favorite Color:</label>
<input type="color" id="favoriteColor" name="favoriteColor" value="#0066ff">

<!-- Range Slider -->
<label for="volume">Volume:</label>
<input type="range" id="volume" name="volume" min="0" max="100" value="50">

<!-- File Input -->
<label for="photo">Upload Photo:</label>
<input
    type="file"
    id="photo"
    name="photo"
    accept="image/*"
    multiple
>

<!-- File Input with Specific Types -->
<input type="file" accept=".pdf,.doc,.docx">
<input type="file" accept="image/png,image/jpeg">

<!-- Datetime Local -->
<label for="meetingTime">Meeting Time:</label>
<input type="datetime-local" id="meetingTime" name="meetingTime">
```

### Advanced Validation

```html
<!-- Constraint Validation API -->
<form id="myForm">
    <input type="text" id="username" name="username" required pattern="[a-zA-Z0-9]{3,20}">
    <span id="error"></span>
    <button type="submit">Submit</button>
</form>

<script>
    const form = document.getElementById('myForm');
    const input = document.getElementById('username');
    const error = document.getElementById('error');

    input.addEventListener('invalid', (e) => {
        e.preventDefault();
        if (input.validity.valueMissing) {
            error.textContent = 'Username is required';
        } else if (input.validity.patternMismatch) {
            error.textContent = 'Username must be 3-20 alphanumeric characters';
        }
    });

    form.addEventListener('submit', (e) => {
        e.preventDefault();
        if (form.reportValidity()) {
            // Form is valid
            form.submit();
        }
    });
</script>
```

---

## Web Components Deep Dive

### Creating Custom Elements

```html
<!-- Using Custom Element -->
<user-profile
    name="John Doe"
    email="john@example.com"
    avatar="avatar.jpg"
></user-profile>

<script>
    class UserProfile extends HTMLElement {
        constructor() {
            super();
            this.attachShadow({ mode: 'open' });
        }

        connectedCallback() {
            this.render();
            this.setupEventListeners();
        }

        disconnectedCallback() {
            // Cleanup
        }

        attributeChangedCallback(name, oldValue, newValue) {
            if (oldValue !== newValue) {
                this.render();
            }
        }

        static get observedAttributes() {
            return ['name', 'email', 'avatar'];
        }

        render() {
            const name = this.getAttribute('name') || 'Unknown';
            const email = this.getAttribute('email') || '';
            const avatar = this.getAttribute('avatar') || '';

            this.shadowRoot.innerHTML = `
                <style>
                    :host {
                        display: block;
                        padding: 20px;
                        border: 1px solid #ccc;
                        border-radius: 8px;
                    }
                    .profile {
                        display: flex;
                        gap: 15px;
                    }
                    img {
                        width: 80px;
                        height: 80px;
                        border-radius: 50%;
                        object-fit: cover;
                    }
                    h2 {
                        margin: 0;
                        font-size: 1.3rem;
                    }
                    p {
                        margin: 5px 0;
                        color: #666;
                    }
                </style>
                <div class="profile">
                    ${avatar ? `<img src="${avatar}" alt="${name}">` : ''}
                    <div>
                        <h2>${name}</h2>
                        <p>${email}</p>
                    </div>
                </div>
            `;
        }

        setupEventListeners() {
            this.shadowRoot.addEventListener('click', this.handleClick.bind(this));
        }

        handleClick() {
            this.dispatchEvent(new CustomEvent('profile-clicked', {
                detail: {
                    name: this.getAttribute('name'),
                    email: this.getAttribute('email')
                },
                bubbles: true,
                composed: true
            }));
        }
    }

    customElements.define('user-profile', UserProfile);

    // Using the component
    document.addEventListener('profile-clicked', (e) => {
        console.log('Profile clicked:', e.detail);
    });
</script>
```

### Shadow DOM Advanced

```html
<style-demo></style-demo>

<script>
    class StyleDemo extends HTMLElement {
        constructor() {
            super();
            this.attachShadow({ mode: 'open' });
        }

        connectedCallback() {
            this.shadowRoot.innerHTML = `
                <style>
                    /* Scoped styles */
                    :host {
                        display: block;
                        --primary-color: blue;
                    }

                    /* Host pseudo-class */
                    :host(:hover) {
                        background: lightblue;
                    }

                    :host(.dark) {
                        --primary-color: darkblue;
                    }

                    /* Part pseudo-element (exposed styles) */
                    ::part(button) {
                        background: var(--primary-color);
                        color: white;
                        padding: 10px 20px;
                        border: none;
                        border-radius: 4px;
                        cursor: pointer;
                    }

                    /* Slotted content */
                    ::slotted(h1) {
                        margin-top: 0;
                        color: var(--primary-color);
                    }
                </style>

                <slot name="header">
                    <h1>Default Header</h1>
                </slot>

                <button part="button">Click me</button>

                <slot>Default content</slot>
            `;
        }
    }

    customElements.define('style-demo', StyleDemo);
</script>

<!-- Using the component with exposed parts -->
<style>
    style-demo::part(button) {
        background: red;
    }
</style>

<style-demo class="dark">
    <h1 slot="header">Custom Header</h1>
    <p>Custom content here</p>
</style-demo>
```

### Template and Slots

```html
<template id="card-template">
    <style>
        .card {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .card-header {
            margin-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 10px;
        }
        .card-body {
            margin-bottom: 15px;
        }
        .card-footer {
            padding-top: 10px;
            border-top: 1px solid #f0f0f0;
            text-align: right;
        }
    </style>
    <div class="card">
        <div class="card-header">
            <slot name="header"></slot>
        </div>
        <div class="card-body">
            <slot></slot>
        </div>
        <div class="card-footer">
            <slot name="footer"></slot>
        </div>
    </div>
</template>

<script>
    class Card extends HTMLElement {
        connectedCallback() {
            const template = document.getElementById('card-template');
            const clone = template.content.cloneNode(true);
            this.appendChild(clone);
        }
    }
    customElements.define('custom-card', Card);
</script>

<custom-card>
    <h2 slot="header">Card Title</h2>
    <p>This is the main content of the card.</p>
    <button slot="footer">Action</button>
</custom-card>
```

---

## Advanced Media Handling

### Progressive Enhancement with Picture

```html
<!-- Art direction with picture element -->
<picture>
    <!-- Ultra-wide screens -->
    <source
        media="(min-width: 1920px)"
        srcset="image-4k.jpg"
    >
    <!-- Desktop -->
    <source
        media="(min-width: 1024px)"
        srcset="image-desktop.jpg 1x, image-desktop@2x.jpg 2x"
    >
    <!-- Tablet -->
    <source
        media="(min-width: 768px)"
        srcset="image-tablet.jpg"
    >
    <!-- Mobile -->
    <source
        media="(max-width: 767px)"
        srcset="image-mobile.jpg"
    >
    <!-- Fallback -->
    <img src="image-default.jpg" alt="Responsive image">
</picture>

<!-- Format selection -->
<picture>
    <source srcset="image.webp" type="image/webp">
    <source srcset="image.jpg" type="image/jpeg">
    <img src="image.jpg" alt="Image">
</picture>
```

### Lazy Loading Optimization

```html
<!-- Native lazy loading -->
<img
    src="image.jpg"
    loading="lazy"
    alt="Image"
    width="400"
    height="300"
>

<!-- Intersection Observer for custom lazy loading -->
<img class="lazy-image" data-src="image.jpg" src="placeholder.jpg">

<script>
    const lazyImages = document.querySelectorAll('.lazy-image');

    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.add('loaded');
                observer.unobserve(img);
            }
        });
    });

    lazyImages.forEach(img => imageObserver.observe(img));
</script>
```

---

## Microdata & Semantic Enrichment

### Microdata Format

```html
<!-- Product with microdata -->
<div itemscope itemtype="https://schema.org/Product">
    <h1 itemprop="name">Laptop Computer</h1>
    <img itemprop="image" src="laptop.jpg">

    <div itemprop="offers" itemscope itemtype="https://schema.org/Offer">
        <span itemprop="price">$999.99</span>
        <span itemprop="priceCurrency">USD</span>
    </div>

    <span itemprop="description">High-performance laptop</span>

    <div itemprop="aggregateRating" itemscope itemtype="https://schema.org/AggregateRating">
        <span itemprop="ratingValue">4.5</span> / 5
        (<span itemprop="reviewCount">100</span> reviews)
    </div>
</div>

<!-- Person with microdata -->
<div itemscope itemtype="https://schema.org/Person">
    <span itemprop="name">John Doe</span>
    <span itemprop="email">john@example.com</span>
    <img itemprop="image" src="john.jpg">
</div>
```

### JSON-LD (Recommended)

```html
<script type="application/ld+json">
{
    "@context": "https://schema.org",
    "@type": "BlogPosting",
    "headline": "Article Title",
    "image": "https://example.com/image.jpg",
    "author": {
        "@type": "Person",
        "name": "John Doe",
        "url": "https://example.com/authors/john"
    },
    "datePublished": "2024-10-25T10:00:00Z",
    "dateModified": "2024-10-26T12:00:00Z",
    "articleBody": "Article content...",
    "wordCount": 1200
}
</script>
```

---

## Iframes & Embedding

### Secure Iframe Usage

```html
<!-- Basic iframe -->
<iframe
    src="https://example.com/embed"
    title="Embedded content"
    width="560"
    height="315"
    allow="fullscreen"
    loading="lazy"
></iframe>

<!-- Restricted iframe (sandbox) -->
<iframe
    src="untrusted.html"
    sandbox="allow-scripts allow-same-origin"
    title="Restricted content"
></iframe>

<!-- Sandbox permissions -->
<iframe
    src="content.html"
    sandbox="
        allow-same-origin
        allow-scripts
        allow-forms
        allow-popups
        allow-presentation
    "
></iframe>

<!-- YouTube embed with privacy-enhanced mode -->
<iframe
    width="560"
    height="315"
    src="https://www.youtube-nocookie.com/embed/VIDEO_ID"
    title="YouTube video"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
    allowfullscreen
></iframe>
```

---

## Performance & Resource Hints

### Resource Hints

```html
<head>
    <!-- DNS Prefetch (fast for external domains) -->
    <link rel="dns-prefetch" href="https://cdn.example.com">

    <!-- Preconnect (slower but more complete) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <!-- Prefetch (for next navigation) -->
    <link rel="prefetch" href="next-page.html">

    <!-- Preload (critical resources) -->
    <link rel="preload" href="fonts/main.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="preload" href="critical-styles.css" as="style">

    <!-- Preload with media queries -->
    <link
        rel="preload"
        as="image"
        href="large.jpg"
        media="(min-width: 1024px)"
    >
</head>
```

### Critical Rendering Path

```html
<head>
    <!-- Critical CSS inline -->
    <style>
        /* Above-the-fold styles only */
        body { font-family: sans-serif; }
        .header { background: #f0f0f0; }
    </style>

    <!-- Deferred stylesheets -->
    <link rel="stylesheet" href="styles.css" media="print" onload="this.media='all'">

    <!-- Preload fonts -->
    <link
        rel="preload"
        href="fonts/roboto-regular.woff2"
        as="font"
        type="font/woff2"
        crossorigin
    >
</head>

<body>
    <!-- Deferred scripts -->
    <script src="app.js" defer></script>

    <!-- Async scripts (independent) -->
    <script src="analytics.js" async></script>
</body>
```

---

## Content Security Policy

```html
<meta
    http-equiv="Content-Security-Policy"
    content="
        default-src 'self';
        script-src 'self' 'unsafe-inline' https://trusted.com;
        style-src 'self' 'unsafe-inline';
        img-src 'self' data: https:;
        font-src 'self' data:;
        connect-src 'self' https://api.example.com;
        frame-src 'self' https://trusted.com;
        object-src 'none';
        base-uri 'self';
        form-action 'self';
        upgrade-insecure-requests;
    "
>
```

---

## Key Takeaways

1. **Web Components** enable reusable, encapsulated components
2. **Shadow DOM** provides style and scope isolation
3. **Custom Elements** create semantic, meaningful HTML
4. **Validation API** provides fine-grained form control
5. **Microdata and JSON-LD** improve discoverability
6. **Resource hints** optimize loading performance
7. **CSP** improves security
8. **Sandbox attributes** restrict iframe capabilities

---

**Last Updated:** October 25, 2024
**Level:** Expert
**Topics Covered:** 40+ advanced concepts, 80+ code examples
