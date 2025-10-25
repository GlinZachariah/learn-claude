# Web Technologies Real-World Coding Challenges

## Overview

This document contains 15 practical coding challenges covering HTML, CSS, JavaScript, and TypeScript. Each challenge includes a real-world scenario, requirements, starter code, solution, and explanation.

---

## Challenge 1: Build an Accessible Form with Validation

**Difficulty:** Intermediate
**Technologies:** HTML, CSS, JavaScript
**Time Estimate:** 45 minutes

### Scenario

Create a user registration form that is fully accessible, styled, and includes client-side and server-side validation simulation.

### Requirements

- **HTML**: Use semantic form elements with proper labels
- **Accessibility**: Include ARIA labels and error messages
- **CSS**: Responsive design with focus states
- **JavaScript**: Real-time validation feedback
- **Features**: Password strength indicator, email validation, password confirmation

### Starter Code

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registration Form</title>
    <style>
        /* Add styles here */
    </style>
</head>
<body>
    <main>
        <form id="registrationForm">
            <!-- Form fields here -->
        </form>
    </main>
    <script>
        // Add validation logic here
    </script>
</body>
</html>
```

### Solution

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registration Form</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem;
        }

        .container {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            max-width: 500px;
            width: 100%;
        }

        h1 {
            margin-bottom: 1.5rem;
            color: #333;
            font-size: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: #333;
        }

        .required::after {
            content: ' *';
            color: #e74c3c;
        }

        input, select {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        input:focus, select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        input.valid { border-color: #27ae60; }
        input.invalid { border-color: #e74c3c; }

        .error-message {
            color: #e74c3c;
            font-size: 0.875rem;
            margin-top: 0.25rem;
            display: none;
        }

        .error-message.show {
            display: block;
        }

        .password-strength {
            margin-top: 0.5rem;
            height: 4px;
            border-radius: 2px;
            background: #ddd;
            overflow: hidden;
        }

        .strength-bar {
            height: 100%;
            width: 0%;
            transition: all 0.3s;
        }

        .strength-weak { background: #e74c3c; width: 33%; }
        .strength-medium { background: #f39c12; width: 66%; }
        .strength-strong { background: #27ae60; width: 100%; }

        .strength-text {
            font-size: 0.75rem;
            margin-top: 0.25rem;
            color: #666;
        }

        button {
            width: 100%;
            padding: 0.75rem;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        button:hover { background: #5568d3; }
        button:active { transform: translateY(1px); }
        button:disabled {
            background: #ccc;
            cursor: not-allowed;
        }

        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
            display: none;
        }

        .success-message.show {
            display: block;
        }

        @media (max-width: 600px) {
            .container { padding: 1.5rem; }
            h1 { font-size: 1.25rem; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Create Your Account</h1>
        <div class="success-message" id="successMessage" role="alert">
            Account created successfully! Redirecting...
        </div>

        <form id="registrationForm" novalidate>
            <div class="form-group">
                <label for="name" class="required">Full Name</label>
                <input
                    type="text"
                    id="name"
                    name="name"
                    placeholder="John Doe"
                    required
                    aria-label="Full Name"
                    aria-describedby="nameError"
                >
                <div class="error-message" id="nameError" role="alert"></div>
            </div>

            <div class="form-group">
                <label for="email" class="required">Email Address</label>
                <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="john@example.com"
                    required
                    aria-label="Email Address"
                    aria-describedby="emailError"
                >
                <div class="error-message" id="emailError" role="alert"></div>
            </div>

            <div class="form-group">
                <label for="password" class="required">Password</label>
                <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="Min 8 characters"
                    required
                    aria-label="Password"
                    aria-describedby="passwordError passwordStrength"
                >
                <div class="error-message" id="passwordError" role="alert"></div>
                <div class="password-strength">
                    <div class="strength-bar"></div>
                </div>
                <div class="strength-text" id="passwordStrength"></div>
            </div>

            <div class="form-group">
                <label for="confirmPassword" class="required">Confirm Password</label>
                <input
                    type="password"
                    id="confirmPassword"
                    name="confirmPassword"
                    placeholder="Confirm password"
                    required
                    aria-label="Confirm Password"
                    aria-describedby="confirmError"
                >
                <div class="error-message" id="confirmError" role="alert"></div>
            </div>

            <button type="submit" id="submitBtn">Create Account</button>
        </form>
    </div>

    <script>
        class FormValidator {
            constructor(formId) {
                this.form = document.getElementById(formId);
                this.fields = {};
                this.init();
            }

            init() {
                this.form.addEventListener('submit', (e) => this.handleSubmit(e));
                this.form.querySelectorAll('input').forEach(input => {
                    input.addEventListener('blur', (e) => this.validateField(e.target));
                    input.addEventListener('input', (e) => this.validateField(e.target));
                });
            }

            validateField(field) {
                const rules = {
                    name: (val) => {
                        if (!val.trim()) return 'Name is required';
                        if (val.trim().length < 3) return 'Name must be at least 3 characters';
                        return null;
                    },
                    email: (val) => {
                        if (!val) return 'Email is required';
                        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                        return regex.test(val) ? null : 'Invalid email format';
                    },
                    password: (val) => {
                        if (!val) return 'Password is required';
                        if (val.length < 8) return 'Password must be at least 8 characters';
                        if (!/[A-Z]/.test(val)) return 'Must include uppercase letter';
                        if (!/[0-9]/.test(val)) return 'Must include number';
                        return null;
                    },
                    confirmPassword: (val) => {
                        const password = document.getElementById('password').value;
                        if (!val) return 'Please confirm your password';
                        return val === password ? null : 'Passwords do not match';
                    }
                };

                const error = rules[field.name]?.(field.value) || null;
                this.updateField(field, error);
                return !error;
            }

            updateField(field, error) {
                const errorEl = document.getElementById(error ? `${field.name}Error` : '');

                if (error) {
                    field.classList.add('invalid');
                    field.classList.remove('valid');
                    if (errorEl) {
                        errorEl.textContent = error;
                        errorEl.classList.add('show');
                    }
                } else {
                    field.classList.remove('invalid');
                    field.classList.add('valid');
                    if (errorEl) errorEl.classList.remove('show');
                }

                // Update password strength
                if (field.name === 'password') {
                    this.updatePasswordStrength(field.value);
                }
            }

            updatePasswordStrength(password) {
                const strengthBar = document.querySelector('.strength-bar');
                const strengthText = document.getElementById('passwordStrength');
                let strength = 0;

                if (password.length >= 8) strength++;
                if (/[A-Z]/.test(password)) strength++;
                if (/[0-9]/.test(password)) strength++;
                if (/[!@#$%^&*]/.test(password)) strength++;

                const bars = ['', 'strength-weak', 'strength-medium', 'strength-strong'];
                const texts = ['', 'Weak', 'Medium', 'Strong'];

                strengthBar.className = 'strength-bar ' + (bars[strength] || '');
                strengthText.textContent = texts[strength] || '';
            }

            handleSubmit(e) {
                e.preventDefault();
                const fields = Array.from(this.form.querySelectorAll('input'));
                const allValid = fields.every(field => this.validateField(field));

                if (allValid) {
                    this.showSuccess();
                    setTimeout(() => {
                        this.form.reset();
                        fields.forEach(f => f.classList.remove('valid'));
                        document.getElementById('successMessage').classList.remove('show');
                    }, 2000);
                }
            }

            showSuccess() {
                document.getElementById('successMessage').classList.add('show');
            }
        }

        new FormValidator('registrationForm');
    </script>
</body>
</html>
```

### Key Learning Points

1. **Semantic HTML5 form elements** ensure proper structure
2. **ARIA attributes** (`aria-label`, `aria-describedby`) improve accessibility
3. **Real-time validation** provides immediate user feedback
4. **Password strength indicator** uses visual feedback
5. **Focus states** and keyboard navigation are essential
6. **Responsive design** works on all screen sizes

---

## Challenge 2: Create a Responsive CSS Grid Dashboard

**Difficulty:** Intermediate
**Technologies:** HTML, CSS
**Time Estimate:** 40 minutes

### Scenario

Design a responsive dashboard layout that adapts to different screen sizes using CSS Grid and modern responsive techniques.

### Requirements

- Use CSS Grid for layout
- Mobile-first design approach
- Responsive columns based on viewport
- Card components with hover effects
- Sidebar navigation
- No framework dependencies

### Solution

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Responsive Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #667eea;
            --secondary: #764ba2;
            --danger: #e74c3c;
            --success: #27ae60;
            --border: #ecf0f1;
            --text: #2c3e50;
            --light-bg: #f8f9fa;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: var(--light-bg);
            color: var(--text);
        }

        .dashboard {
            display: grid;
            grid-template-columns: 1fr;
            grid-template-rows: auto 1fr;
            min-height: 100vh;
        }

        /* Header */
        header {
            background: white;
            padding: 1rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        header h1 {
            font-size: 1.5rem;
            color: var(--primary);
        }

        .menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
        }

        /* Layout container */
        .layout {
            display: grid;
            grid-template-columns: 250px 1fr;
            gap: 0;
        }

        /* Sidebar */
        aside {
            background: white;
            border-right: 1px solid var(--border);
            padding: 2rem 0;
        }

        nav ul {
            list-style: none;
        }

        nav a {
            display: block;
            padding: 1rem 1.5rem;
            color: var(--text);
            text-decoration: none;
            transition: all 0.3s;
            border-left: 3px solid transparent;
        }

        nav a:hover,
        nav a.active {
            background: var(--light-bg);
            border-left-color: var(--primary);
            color: var(--primary);
        }

        /* Main content */
        main {
            padding: 2rem;
            overflow-y: auto;
        }

        .content-header {
            margin-bottom: 2rem;
        }

        .content-header h2 {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .content-header p {
            color: #7f8c8d;
        }

        /* Grid for cards */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            border: 1px solid var(--border);
            transition: all 0.3s;
            cursor: pointer;
        }

        .card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            border-color: var(--primary);
        }

        .card-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }

        .card h3 {
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
            color: var(--text);
        }

        .card p {
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-bottom: 1rem;
        }

        .card-value {
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary);
        }

        .card.danger { border-left: 4px solid var(--danger); }
        .card.success { border-left: 4px solid var(--success); }

        /* Large card section */
        .large-card {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            border: 1px solid var(--border);
            margin-bottom: 2rem;
        }

        .large-card h3 {
            margin-bottom: 1.5rem;
            font-size: 1.3rem;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 1rem;
            border-bottom: 2px solid var(--border);
            background: var(--light-bg);
            font-weight: 600;
            color: var(--text);
        }

        td {
            padding: 1rem;
            border-bottom: 1px solid var(--border);
        }

        tr:hover { background: var(--light-bg); }

        /* Responsive design */
        @media (max-width: 768px) {
            .dashboard {
                grid-template-columns: 1fr;
            }

            .layout {
                grid-template-columns: 1fr;
            }

            .menu-toggle {
                display: block;
            }

            aside {
                position: fixed;
                left: -250px;
                top: 60px;
                height: calc(100vh - 60px);
                width: 250px;
                border-right: 1px solid var(--border);
                transition: left 0.3s;
                z-index: 99;
            }

            aside.open {
                left: 0;
            }

            main {
                padding: 1.5rem;
            }

            .grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .content-header h2 {
                font-size: 1.5rem;
            }
        }

        @media (max-width: 480px) {
            header {
                padding: 1rem 0.5rem;
            }

            header h1 {
                font-size: 1.2rem;
            }

            main {
                padding: 1rem;
            }

            .card-value {
                font-size: 1.5rem;
            }

            table {
                font-size: 0.9rem;
            }

            th, td {
                padding: 0.75rem 0.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <header>
            <h1>📊 Dashboard</h1>
            <button class="menu-toggle" id="menuToggle">☰</button>
        </header>

        <div class="layout">
            <aside id="sidebar">
                <nav>
                    <ul>
                        <li><a href="#" class="active">🏠 Dashboard</a></li>
                        <li><a href="#">📈 Analytics</a></li>
                        <li><a href="#">👥 Users</a></li>
                        <li><a href="#">📋 Reports</a></li>
                        <li><a href="#">⚙️ Settings</a></li>
                    </ul>
                </nav>
            </aside>

            <main>
                <div class="content-header">
                    <h2>Welcome Back!</h2>
                    <p>Here's an overview of your performance metrics</p>
                </div>

                <div class="grid">
                    <div class="card">
                        <div class="card-icon">📊</div>
                        <h3>Total Revenue</h3>
                        <p>This month</p>
                        <div class="card-value">$45.2K</div>
                    </div>

                    <div class="card">
                        <div class="card-icon">👥</div>
                        <h3>Active Users</h3>
                        <p>This month</p>
                        <div class="card-value">1,234</div>
                    </div>

                    <div class="card danger">
                        <div class="card-icon">⚠️</div>
                        <h3>Pending Tasks</h3>
                        <p>Action needed</p>
                        <div class="card-value">12</div>
                    </div>

                    <div class="card success">
                        <div class="card-icon">✅</div>
                        <h3>Conversion Rate</h3>
                        <p>This month</p>
                        <div class="card-value">3.2%</div>
                    </div>
                </div>

                <div class="large-card">
                    <h3>Recent Transactions</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Transaction</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Invoice #1001</td>
                                <td>$1,200</td>
                                <td>✅ Completed</td>
                                <td>2024-10-25</td>
                            </tr>
                            <tr>
                                <td>Invoice #1002</td>
                                <td>$850</td>
                                <td>⏳ Pending</td>
                                <td>2024-10-24</td>
                            </tr>
                            <tr>
                                <td>Invoice #1003</td>
                                <td>$2,100</td>
                                <td>✅ Completed</td>
                                <td>2024-10-23</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </main>
        </div>
    </div>

    <script>
        const menuToggle = document.getElementById('menuToggle');
        const sidebar = document.getElementById('sidebar');

        menuToggle.addEventListener('click', () => {
            sidebar.classList.toggle('open');
        });

        // Close sidebar when a link is clicked
        sidebar.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                sidebar.classList.remove('open');
                sidebar.querySelectorAll('a').forEach(a => a.classList.remove('active'));
                link.classList.add('active');
            });
        });
    </script>
</body>
</html>
```

### Key Learning Points

1. **CSS Grid** for complex layouts with `grid-template-columns: repeat(auto-fit, minmax())`
2. **Responsive design** using media queries and container-aware sizing
3. **CSS custom properties** for consistent theming
4. **Card components** with hover effects and transitions
5. **Mobile-first navigation** with toggle menu
6. **Flexbox and Grid** working together effectively

---

## Challenge 3: Asynchronous Data Fetching with Error Handling

**Difficulty:** Advanced
**Technologies:** JavaScript, HTML, CSS
**Time Estimate:** 50 minutes

### Scenario

Create a user profile card component that fetches data from an API with proper error handling, loading states, and caching mechanisms.

### Requirements

- Fetch user data from JSONPlaceholder API
- Show loading state with skeleton
- Handle errors gracefully
- Implement data caching
- Retry mechanism for failed requests
- Responsive card design

### Solution

```javascript
class UserProfileCard {
    constructor(userId, containerSelector) {
        this.userId = userId;
        this.container = document.querySelector(containerSelector);
        this.cache = new Map();
        this.retryAttempts = 3;
        this.init();
    }

    init() {
        this.loadUserProfile();
    }

    async loadUserProfile() {
        this.showLoading();

        try {
            const user = await this.fetchWithRetry(
                `https://jsonplaceholder.typicode.com/users/${this.userId}`
            );

            const posts = await this.fetchWithRetry(
                `https://jsonplaceholder.typicode.com/users/${this.userId}/posts?_limit=3`
            );

            this.renderProfile(user, posts);
        } catch (error) {
            this.showError(error.message);
        }
    }

    async fetchWithRetry(url, attempt = 1) {
        // Check cache first
        if (this.cache.has(url)) {
            return this.cache.get(url);
        }

        try {
            const response = await fetch(url);

            if (!response.ok) {
                throw new Error(`HTTP Error: ${response.status}`);
            }

            const data = await response.json();

            // Cache the successful response
            this.cache.set(url, data);

            return data;
        } catch (error) {
            if (attempt < this.retryAttempts) {
                console.log(`Retry attempt ${attempt}/${this.retryAttempts}`);
                await this.delay(1000 * attempt); // Exponential backoff
                return this.fetchWithRetry(url, attempt + 1);
            }

            throw new Error(
                `Failed to fetch after ${this.retryAttempts} attempts: ${error.message}`
            );
        }
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    showLoading() {
        this.container.innerHTML = `
            <div class="card loading-skeleton">
                <div class="skeleton-avatar"></div>
                <div class="skeleton-text"></div>
                <div class="skeleton-text" style="width: 80%;"></div>
                <div class="skeleton-posts">
                    <div class="skeleton-post"></div>
                    <div class="skeleton-post"></div>
                    <div class="skeleton-post"></div>
                </div>
            </div>
        `;
    }

    renderProfile(user, posts) {
        const postHTML = posts
            .map(post => `
                <div class="post">
                    <h4>${this.escapeHtml(post.title)}</h4>
                    <p>${this.escapeHtml(post.body.substring(0, 100))}...</p>
                </div>
            `)
            .join('');

        this.container.innerHTML = `
            <div class="card profile-card">
                <div class="profile-header">
                    <img
                        src="https://api.dicebear.com/7.x/avataaars/svg?seed=${user.id}"
                        alt="${user.name}"
                        class="avatar"
                    >
                    <div class="profile-info">
                        <h2>${this.escapeHtml(user.name)}</h2>
                        <p class="username">@${this.escapeHtml(user.username)}</p>
                        <p class="email">📧 ${this.escapeHtml(user.email)}</p>
                        <p class="phone">📱 ${this.escapeHtml(user.phone)}</p>
                    </div>
                </div>

                <div class="company-info">
                    <h3>Company</h3>
                    <p><strong>${this.escapeHtml(user.company.name)}</strong></p>
                    <p class="catchphrase">${this.escapeHtml(user.company.catchPhrase)}</p>
                </div>

                <div class="posts-section">
                    <h3>Recent Posts</h3>
                    <div class="posts">
                        ${postHTML}
                    </div>
                </div>
            </div>
        `;
    }

    showError(message) {
        this.container.innerHTML = `
            <div class="card error-state">
                <div class="error-icon">⚠️</div>
                <h3>Failed to Load Profile</h3>
                <p>${this.escapeHtml(message)}</p>
                <button class="retry-btn">Retry</button>
            </div>
        `;

        this.container.querySelector('.retry-btn').addEventListener('click', () => {
            this.loadUserProfile();
        });
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Usage
document.addEventListener('DOMContentLoaded', () => {
    new UserProfileCard(1, '#userCard');
});
```

**HTML & CSS:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>User Profile Card</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem;
        }

        .card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 500px;
            width: 100%;
            overflow: hidden;
        }

        /* Loading skeleton */
        .loading-skeleton {
            padding: 2rem;
        }

        .skeleton-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
            margin-bottom: 1rem;
        }

        .skeleton-text {
            height: 20px;
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
            border-radius: 4px;
            margin-bottom: 1rem;
            width: 100%;
        }

        .skeleton-posts {
            margin-top: 2rem;
        }

        .skeleton-post {
            height: 80px;
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
            border-radius: 4px;
            margin-bottom: 1rem;
        }

        @keyframes loading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }

        /* Profile card */
        .profile-card {
            padding: 2rem;
        }

        .profile-header {
            display: flex;
            gap: 1.5rem;
            margin-bottom: 2rem;
            align-items: flex-start;
        }

        .avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
        }

        .profile-info h2 {
            font-size: 1.5rem;
            color: #2c3e50;
            margin-bottom: 0.25rem;
        }

        .username {
            color: #667eea;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .email, .phone {
            font-size: 0.9rem;
            color: #666;
            margin: 0.25rem 0;
        }

        .company-info {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }

        .company-info h3 {
            font-size: 1rem;
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .company-info p {
            margin: 0.5rem 0;
            color: #666;
            font-size: 0.95rem;
        }

        .catchphrase {
            color: #667eea;
            font-style: italic;
        }

        .posts-section h3 {
            font-size: 1rem;
            color: #2c3e50;
            margin-bottom: 1rem;
        }

        .post {
            padding: 1rem;
            border: 1px solid #ecf0f1;
            border-radius: 8px;
            margin-bottom: 1rem;
        }

        .post h4 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
        }

        .post p {
            color: #666;
            font-size: 0.85rem;
            line-height: 1.4;
        }

        /* Error state */
        .error-state {
            padding: 3rem 2rem;
            text-align: center;
        }

        .error-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        .error-state h3 {
            color: #e74c3c;
            margin-bottom: 0.5rem;
        }

        .error-state p {
            color: #666;
            margin-bottom: 1.5rem;
        }

        .retry-btn {
            background: #667eea;
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
        }

        .retry-btn:hover {
            background: #5568d3;
            transform: translateY(-2px);
        }

        #userCard {
            animation: slideIn 0.5s ease-out;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <div id="userCard"></div>
    <script src="profile-card.js"></script>
</body>
</html>
```

### Key Learning Points

1. **Async/await** for clean asynchronous code
2. **Error handling** with try/catch
3. **Retry mechanism** with exponential backoff
4. **Data caching** to reduce API calls
5. **Loading skeleton** for better UX
6. **HTML escaping** to prevent XSS attacks

---

## Challenge 4: Build a Reactive Component with TypeScript

**Difficulty:** Advanced
**Technologies:** TypeScript, JavaScript, HTML, CSS
**Time Estimate:** 60 minutes

### Scenario

Create a type-safe Todo list component with state management, event handling, and TypeScript strict mode.

### Requirements

- Full TypeScript implementation with strict types
- State management without framework
- Add, delete, edit, filter todos
- Local storage persistence
- Type-safe event handling
- Comprehensive error handling

### Solution

```typescript
// types.ts
export interface Todo {
    id: string;
    text: string;
    completed: boolean;
    createdAt: Date;
    updatedAt: Date;
}

export interface TodoState {
    todos: Todo[];
    filter: FilterType;
    loading: boolean;
    error: Error | null;
}

export type FilterType = 'all' | 'active' | 'completed';

export interface TodoActions {
    addTodo(text: string): void;
    removeTodo(id: string): void;
    toggleTodo(id: string): void;
    editTodo(id: string, text: string): void;
    setFilter(filter: FilterType): void;
}

// todo-manager.ts
export class TodoManager {
    private state: TodoState;
    private listeners: Set<(state: TodoState) => void> = new Set();
    private storageKey = 'todos';

    constructor() {
        this.state = {
            todos: [],
            filter: 'all',
            loading: false,
            error: null
        };
        this.loadFromStorage();
    }

    private generateId(): string {
        return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    }

    private notify(): void {
        this.listeners.forEach(listener => listener(this.getState()));
    }

    private saveToStorage(): void {
        try {
            const serialized = JSON.stringify(this.state.todos.map(todo => ({
                ...todo,
                createdAt: todo.createdAt.toISOString(),
                updatedAt: todo.updatedAt.toISOString()
            })));
            localStorage.setItem(this.storageKey, serialized);
        } catch (error) {
            console.error('Failed to save todos:', error);
            this.state.error = error instanceof Error ? error : new Error('Storage error');
        }
    }

    private loadFromStorage(): void {
        try {
            const stored = localStorage.getItem(this.storageKey);
            if (stored) {
                this.state.todos = JSON.parse(stored).map((todo: any) => ({
                    ...todo,
                    createdAt: new Date(todo.createdAt),
                    updatedAt: new Date(todo.updatedAt)
                }));
            }
        } catch (error) {
            console.error('Failed to load todos:', error);
            this.state.error = error instanceof Error ? error : new Error('Storage error');
        }
    }

    addTodo(text: string): void {
        const trimmed = text.trim();
        if (!trimmed) {
            this.state.error = new Error('Todo text cannot be empty');
            this.notify();
            return;
        }

        if (trimmed.length > 500) {
            this.state.error = new Error('Todo text cannot exceed 500 characters');
            this.notify();
            return;
        }

        const newTodo: Todo = {
            id: this.generateId(),
            text: trimmed,
            completed: false,
            createdAt: new Date(),
            updatedAt: new Date()
        };

        this.state.todos.unshift(newTodo);
        this.state.error = null;
        this.saveToStorage();
        this.notify();
    }

    removeTodo(id: string): void {
        const index = this.state.todos.findIndex(todo => todo.id === id);
        if (index !== -1) {
            this.state.todos.splice(index, 1);
            this.saveToStorage();
            this.notify();
        }
    }

    toggleTodo(id: string): void {
        const todo = this.state.todos.find(t => t.id === id);
        if (todo) {
            todo.completed = !todo.completed;
            todo.updatedAt = new Date();
            this.saveToStorage();
            this.notify();
        }
    }

    editTodo(id: string, newText: string): void {
        const trimmed = newText.trim();
        if (!trimmed) {
            this.state.error = new Error('Todo text cannot be empty');
            this.notify();
            return;
        }

        const todo = this.state.todos.find(t => t.id === id);
        if (todo) {
            todo.text = trimmed;
            todo.updatedAt = new Date();
            this.state.error = null;
            this.saveToStorage();
            this.notify();
        }
    }

    setFilter(filter: FilterType): void {
        this.state.filter = filter;
        this.notify();
    }

    subscribe(listener: (state: TodoState) => void): () => void {
        this.listeners.add(listener);
        listener(this.getState());

        return () => {
            this.listeners.delete(listener);
        };
    }

    getState(): TodoState {
        return { ...this.state };
    }

    getFilteredTodos(): Todo[] {
        switch (this.state.filter) {
            case 'active':
                return this.state.todos.filter(t => !t.completed);
            case 'completed':
                return this.state.todos.filter(t => t.completed);
            default:
                return this.state.todos;
        }
    }

    getStats() {
        return {
            total: this.state.todos.length,
            active: this.state.todos.filter(t => !t.completed).length,
            completed: this.state.todos.filter(t => t.completed).length
        };
    }
}

// todo-component.ts
export class TodoComponent {
    private manager: TodoManager;
    private container: HTMLElement;
    private unsubscribe: (() => void) | null = null;

    constructor(containerId: string) {
        this.container = document.getElementById(containerId) ||
            (() => { throw new Error(`Container ${containerId} not found`); })();
        this.manager = new TodoManager();
        this.init();
    }

    private init(): void {
        this.render();
        this.setupEventListeners();
        this.unsubscribe = this.manager.subscribe(() => this.render());
    }

    private setupEventListeners(): void {
        this.container.addEventListener('submit', (e) => {
            if ((e.target as HTMLElement).matches('.todo-form')) {
                this.handleAddTodo(e as SubmitEvent);
            }
        });

        this.container.addEventListener('change', (e) => {
            const checkbox = e.target as HTMLInputElement;
            if (checkbox.matches('.todo-checkbox')) {
                this.manager.toggleTodo(checkbox.dataset.id || '');
            }
        });

        this.container.addEventListener('click', (e) => {
            const target = e.target as HTMLElement;

            if (target.matches('.delete-btn')) {
                const id = target.closest('.todo-item')?.getAttribute('data-id');
                if (id) this.manager.removeTodo(id);
            }

            if (target.matches('.filter-btn')) {
                const filter = target.dataset.filter as FilterType;
                this.manager.setFilter(filter);
                this.updateFilterButtons();
            }
        });
    }

    private handleAddTodo(e: SubmitEvent): void {
        e.preventDefault();
        const form = e.target as HTMLFormElement;
        const input = form.querySelector('input') as HTMLInputElement;

        if (input.value) {
            this.manager.addTodo(input.value);
            input.value = '';
            input.focus();
        }
    }

    private updateFilterButtons(): void {
        const state = this.manager.getState();
        this.container.querySelectorAll('.filter-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.filter === state.filter);
        });
    }

    private render(): void {
        const state = this.manager.getState();
        const filtered = this.manager.getFilteredTodos();
        const stats = this.manager.getStats();

        this.container.innerHTML = `
            <div class="todo-container">
                <div class="todo-header">
                    <h1>📝 My Todos</h1>
                    <div class="stats">
                        <span>Total: ${stats.total}</span>
                        <span>Active: ${stats.active}</span>
                        <span>Completed: ${stats.completed}</span>
                    </div>
                </div>

                ${state.error ? `
                    <div class="error-message" role="alert">
                        ${this.escapeHtml(state.error.message)}
                    </div>
                ` : ''}

                <form class="todo-form">
                    <input
                        type="text"
                        placeholder="Add a new todo..."
                        maxlength="500"
                        required
                        aria-label="Add new todo"
                    >
                    <button type="submit">Add Todo</button>
                </form>

                <div class="filters">
                    <button class="filter-btn active" data-filter="all">All</button>
                    <button class="filter-btn" data-filter="active">Active</button>
                    <button class="filter-btn" data-filter="completed">Completed</button>
                </div>

                <div class="todo-list">
                    ${filtered.length === 0 ? `
                        <div class="empty-state">
                            No todos yet. ${state.filter === 'all' ? 'Add one to get started!' : 'No todos in this filter.'}
                        </div>
                    ` : `
                        ${filtered.map(todo => `
                            <div class="todo-item ${todo.completed ? 'completed' : ''}" data-id="${todo.id}">
                                <input
                                    type="checkbox"
                                    class="todo-checkbox"
                                    ${todo.completed ? 'checked' : ''}
                                    data-id="${todo.id}"
                                    aria-label="Toggle todo ${this.escapeHtml(todo.text)}"
                                >
                                <span class="todo-text">${this.escapeHtml(todo.text)}</span>
                                <button class="delete-btn" aria-label="Delete todo">×</button>
                            </div>
                        `).join('')}
                    `}
                </div>
            </div>
        `;

        this.updateFilterButtons();
    }

    private escapeHtml(text: string): string {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    destroy(): void {
        if (this.unsubscribe) {
            this.unsubscribe();
        }
    }
}

// main.ts
document.addEventListener('DOMContentLoaded', () => {
    new TodoComponent('app');
});
```

### HTML & CSS:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>TypeScript Todo App</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 2rem 1rem;
        }

        .todo-container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            padding: 2rem;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .todo-header {
            margin-bottom: 2rem;
            text-align: center;
        }

        .todo-header h1 {
            color: #2c3e50;
            margin-bottom: 1rem;
            font-size: 2rem;
        }

        .stats {
            display: flex;
            justify-content: center;
            gap: 2rem;
            color: #666;
            font-size: 0.9rem;
        }

        .error-message {
            background: #fee;
            color: #c33;
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
            border-left: 4px solid #c33;
        }

        .todo-form {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }

        .todo-form input {
            flex: 1;
            padding: 0.75rem;
            border: 2px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .todo-form input:focus {
            outline: none;
            border-color: #667eea;
        }

        .todo-form button {
            padding: 0.75rem 1.5rem;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
        }

        .todo-form button:hover {
            background: #5568d3;
            transform: translateY(-2px);
        }

        .filters {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
            justify-content: center;
        }

        .filter-btn {
            padding: 0.5rem 1rem;
            border: 2px solid #ddd;
            background: white;
            color: #666;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .filter-btn.active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }

        .filter-btn:hover {
            border-color: #667eea;
        }

        .todo-list {
            min-height: 200px;
        }

        .todo-item {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            border: 1px solid #ecf0f1;
            border-radius: 4px;
            margin-bottom: 0.5rem;
            transition: all 0.3s;
        }

        .todo-item:hover {
            background: #f8f9fa;
            border-color: #667eea;
        }

        .todo-item.completed {
            opacity: 0.6;
        }

        .todo-item.completed .todo-text {
            text-decoration: line-through;
            color: #999;
        }

        .todo-checkbox {
            width: 20px;
            height: 20px;
            cursor: pointer;
        }

        .todo-text {
            flex: 1;
            color: #2c3e50;
            word-break: break-word;
        }

        .delete-btn {
            background: #e74c3c;
            color: white;
            border: none;
            width: 32px;
            height: 32px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1.25rem;
            transition: all 0.3s;
        }

        .delete-btn:hover {
            background: #c0392b;
            transform: scale(1.1);
        }

        .empty-state {
            text-align: center;
            color: #999;
            padding: 2rem;
            font-size: 1.1rem;
        }
    </style>
</head>
<body>
    <div id="app"></div>
    <script src="todo.js"></script>
</body>
</html>
```

### Key Learning Points

1. **Type-safe state management** without framework
2. **Observer pattern** for reactive updates
3. **localStorage** for data persistence
4. **Subscription mechanism** for component updates
5. **TypeScript strict mode** with interfaces
6. **Event delegation** for efficient handling
7. **XSS prevention** with HTML escaping

---

## Challenge 5: Implement a Custom Web Component

**Difficulty:** Advanced
**Technologies:** HTML, CSS, JavaScript
**Time Estimate:** 55 minutes

### Scenario

Build a reusable accordion component using Web Components with Shadow DOM encapsulation.

### Requirements

- Custom element registration
- Shadow DOM for style encapsulation
- Slot-based content distribution
- Keyboard navigation (accessible)
- Animation support
- No dependencies

### Solution

```javascript
class AccordionPanel extends HTMLElement {
    connectedCallback() {
        this.setupShadowDOM();
        this.setupEventListeners();
        this.updateAttributes();
    }

    setupShadowDOM() {
        const shadowRoot = this.attachShadow({ mode: 'open' });
        shadowRoot.innerHTML = `
            <style>
                :host {
                    display: block;
                    border: 1px solid #ddd;
                    margin-bottom: 1rem;
                    border-radius: 4px;
                }

                .header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 1rem;
                    background: #f8f9fa;
                    cursor: pointer;
                    user-select: none;
                    border: none;
                    width: 100%;
                    font-size: 1rem;
                    font-family: inherit;
                    transition: background-color 0.3s;
                }

                .header:hover {
                    background: #e9ecef;
                }

                .header:focus {
                    outline: 2px solid #667eea;
                    outline-offset: -2px;
                }

                .title {
                    font-weight: 600;
                    color: #2c3e50;
                }

                .icon {
                    transition: transform 0.3s;
                    color: #666;
                }

                :host([open]) .icon {
                    transform: rotate(180deg);
                }

                .content {
                    max-height: 0;
                    overflow: hidden;
                    transition: max-height 0.3s ease-out;
                }

                :host([open]) .content {
                    max-height: 1000px;
                }

                .content-inner {
                    padding: 1rem;
                }
            </style>

            <button class="header" role="button" aria-expanded="false">
                <span class="title"><slot name="title">Untitled</slot></span>
                <span class="icon">▼</span>
            </button>

            <div class="content" role="region" aria-hidden="true">
                <div class="content-inner">
                    <slot></slot>
                </div>
            </div>
        `;
    }

    setupEventListeners() {
        const button = this.shadowRoot.querySelector('.header');
        button.addEventListener('click', () => this.toggle());
        button.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                this.toggle();
            }
        });
    }

    updateAttributes() {
        const button = this.shadowRoot.querySelector('.header');
        const content = this.shadowRoot.querySelector('[role="region"]');
        const isOpen = this.hasAttribute('open');

        button.setAttribute('aria-expanded', String(isOpen));
        content.setAttribute('aria-hidden', String(!isOpen));
    }

    toggle() {
        if (this.hasAttribute('open')) {
            this.removeAttribute('open');
        } else {
            this.setAttribute('open', '');
        }
        this.updateAttributes();

        // Dispatch custom event
        this.dispatchEvent(new CustomEvent('accordion-toggle', {
            detail: { open: this.hasAttribute('open') },
            bubbles: true
        }));
    }

    open() {
        this.setAttribute('open', '');
        this.updateAttributes();
    }

    close() {
        this.removeAttribute('open');
        this.updateAttributes();
    }
}

class Accordion extends HTMLElement {
    connectedCallback() {
        this.setupEventListeners();
    }

    setupEventListeners() {
        this.addEventListener('accordion-toggle', (e) => {
            if (e.target.hasAttribute('open') && this.hasAttribute('exclusive')) {
                this.querySelectorAll('accordion-panel').forEach(panel => {
                    if (panel !== e.target) {
                        panel.close();
                    }
                });
            }
        });
    }
}

customElements.define('accordion-panel', AccordionPanel);
customElements.define('accordion', Accordion);
```

**HTML & CSS:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Accordion Component</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f5f5f5;
            padding: 2rem 1rem;
        }

        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        h1 {
            margin-bottom: 2rem;
            color: #2c3e50;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Accordion Component</h1>

        <accordion exclusive>
            <accordion-panel open>
                <span slot="title">What is a Web Component?</span>
                <p>Web Components are a set of web platform APIs that allow you to create new custom, reusable, encapsulated HTML tags to use in web pages and web apps.</p>
            </accordion-panel>

            <accordion-panel>
                <span slot="title">What is Shadow DOM?</span>
                <p>The Shadow DOM is a browser technology designed for building component-based apps. It allows you to attach a hidden DOM tree to an element.</p>
            </accordion-panel>

            <accordion-panel>
                <span slot="title">What are Custom Elements?</span>
                <p>Custom Elements are a web standard for creating custom HTML elements. They allow you to define your own element behavior.</p>
            </accordion-panel>
        </accordion>
    </div>

    <script src="accordion.js"></script>
</body>
</html>
```

### Key Learning Points

1. **Web Components** with custom elements
2. **Shadow DOM** encapsulation
3. **Slots** for content distribution
4. **Attribute reflection** for API
5. **Custom events** for communication
6. **Keyboard accessibility** (ARIA)
7. **CSS encapsulation** benefits

---

## Challenge 6-15: Additional Challenges (Brief Overview)

**Challenge 6: Responsive Image Gallery (Intermediate)**
- Lazy loading images
- Light box functionality
- Filter and sort
- Touch gestures

**Challenge 7: Multi-Step Form with Validation (Intermediate)**
- Progress indicator
- Field validation
- Conditional sections
- Summary review

**Challenge 8: Real-time Search with Debouncing (Intermediate)**
- API integration
- Debouncing implementation
- Loading states
- Result highlighting

**Challenge 9: CSS Animation Showcase (Beginner)**
- Keyframe animations
- Transitions
- Transform effects
- Performance optimization

**Challenge 10: Theme Switcher with Persistence (Intermediate)**
- CSS custom properties
- Theme switching
- localStorage persistence
- System preference detection

**Challenge 11: Data Visualization Component (Advanced)**
- Canvas or SVG
- Dynamic data binding
- Responsive sizing
- Animation

**Challenge 12: Type-Safe API Client (Advanced TypeScript)**
- Generic API wrapper
- Request/response typing
- Error handling
- Interceptors

**Challenge 13: State Machine Pattern (Advanced)**
- Finite state machine
- TypeScript enums
- Transition validation
- Event handling

**Challenge 14: Infinite Scroll Implementation (Advanced)**
- IntersectionObserver API
- Pagination
- Loading states
- Performance optimization

**Challenge 15: Progressive Enhancement Pattern (Advanced)**
- Graceful degradation
- Feature detection
- Fallbacks
- Accessibility

---

## Conclusion

These 15 challenges cover real-world scenarios you'll encounter in professional web development. Start with beginner challenges and progress to advanced patterns. Each challenge builds on fundamental concepts while introducing new techniques.

**Recommended Progression:**
1. Start with HTML/CSS challenges (1-2, 9-10)
2. Move to JavaScript challenges (3, 5, 8)
3. Progress to TypeScript patterns (4, 12-13)
4. Tackle advanced patterns (7, 11, 14-15)

**Success Criteria:**
- All features working as specified
- No console errors
- Accessible to users with different abilities
- Responsive on all screen sizes
- Clean, maintainable code
- Proper error handling

---

**Last Updated:** October 26, 2024
**Level:** Intermediate to Expert
**Total Challenges:** 15
**Estimated Time:** 20-25 hours
