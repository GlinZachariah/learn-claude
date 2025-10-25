# Server Setup & Troubleshooting Guide

The HTML viewer requires a local web server to properly load files. This guide explains why and how to set it up.

## Why Do I Need a Server?

### The Problem: file:// Protocol Restrictions

When you open `index.html` directly in your browser (as a file), the browser applies strict security restrictions:

- ❌ Cannot fetch local files via JavaScript
- ❌ Cannot access files outside the HTML directory
- ❌ Cannot load from relative paths properly
- ❌ Results in "Could not load file" errors

This is a browser security feature to prevent malicious websites from accessing your files.

### The Solution: Local Web Server

A local web server allows the browser to:
- ✅ Fetch markdown files via HTTP
- ✅ Properly resolve relative paths
- ✅ Access files in subdirectories
- ✅ Work exactly as intended

**Good news:** Setting up a local server takes 30 seconds!

---

## Quick Setup (Choose One)

### Option 1: Python (Easiest - No Installation)

**Python 3:**
```bash
cd /Users/iamgroot/Documents/learn-claude
python -m http.server 8000
```

**Python 2:**
```bash
cd /Users/iamgroot/Documents/learn-claude
python -m SimpleHTTPServer 8000
```

Then open: **http://localhost:8000**

### Option 2: Node.js

**Prerequisites:** Node.js installed

```bash
cd /Users/iamgroot/Documents/learn-claude
npx http-server
```

Then open: **http://localhost:8080**

### Option 3: Node.js with http-server Package

```bash
# Install once
npm install -g http-server

# Run
cd /Users/iamgroot/Documents/learn-claude
http-server
```

Then open: **http://localhost:8080**

### Option 4: VS Code Live Server (IDE Built-in)

1. Open `index.html` in VS Code
2. Right-click the file
3. Select "Open with Live Server"
4. Browser opens automatically
5. Server runs in background

### Option 5: Use Browser Built-in

Some modern browsers have minimal server capabilities, but Python/Node is more reliable.

---

## Step-by-Step Instructions

### Step 1: Open Terminal/Command Prompt

**macOS/Linux:**
- Open Terminal app
- Or: Cmd+Space, type "Terminal", press Enter

**Windows:**
- Open Command Prompt (Win+R, type "cmd")
- Or open PowerShell

### Step 2: Navigate to Directory

```bash
cd /Users/iamgroot/Documents/learn-claude
```

**Windows alternative:**
```bash
cd C:\Users\YourUsername\Documents\learn-claude
```

### Step 3: Start Server

```bash
python -m http.server 8000
```

You should see:
```
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

### Step 4: Open Browser

1. Open your browser (Chrome, Firefox, Safari, Edge)
2. Navigate to: **http://localhost:8000**
3. Dashboard loads automatically
4. Click on "index.html" if needed
5. Explore your learning materials!

### Step 5: When Done

In terminal, press: **Ctrl+C** (Cmd+C on Mac)

Server stops, you can close terminal.

---

## Verify Server is Working

### Signs Server is Running

✅ Terminal shows "Serving HTTP on..."
✅ Browser shows files listed (directory view)
✅ Can click on index.html link
✅ Dashboard loads with all content

### Signs Something is Wrong

❌ "Connection refused" message
❌ Port 8000 already in use
❌ Files won't load
❌ "Could not load file" error still appears

---

## Troubleshooting

### Problem: "Address already in use"

**Cause:** Port 8000 is being used by another application

**Solutions:**

1. Use a different port:
   ```bash
   python -m http.server 9000
   # Then open: http://localhost:9000
   ```

2. Find and stop the process using port 8000:
   ```bash
   # macOS/Linux
   lsof -i :8000
   kill -9 [PID]

   # Windows
   netstat -ano | findstr :8000
   taskkill /PID [PID] /F
   ```

### Problem: "Command not found: python"

**Cause:** Python not installed or not in PATH

**Solutions:**

1. Check if Python is installed:
   ```bash
   python --version
   # or
   python3 --version
   ```

2. Use Node.js instead:
   ```bash
   npx http-server
   ```

3. Try explicit Python path:
   ```bash
   /usr/bin/python3 -m http.server 8000
   ```

4. Install Python from python.org

### Problem: Still Getting "Could not load file" Error

**Checklist:**

1. ✅ Server is running (see "Serving HTTP..." message)
2. ✅ Browser shows directory listing at http://localhost:8000
3. ✅ Click on index.html loads the dashboard
4. ✅ Files exist in correct folders:
   ```
   /Users/iamgroot/Documents/learn-claude/
   ├── Java8-Plus/
   │   ├── notes/
   │   │   ├── 01-java8-fundamentals.md
   │   │   ├── 02-streams-api-deep-dive.md
   │   │   └── 03-java9-to-java21-features.md
   │   ├── questions/
   │   │   └── java8-questions.md
   │   ├── quiz/
   │   │   └── java8-quiz.md
   │   ├── real-problems/
   │   │   └── coding-problems.md
   │   └── interview-questions/
   │       └── java8-interviews.md
   └── index.html
   ```

5. ✅ File permissions are readable:
   ```bash
   ls -la /Users/iamgroot/Documents/learn-claude/Java8-Plus/notes/
   ```

6. If all above checks pass, **refresh the browser** (Cmd+R / Ctrl+R)

### Problem: Browser Shows Directory Listing Instead of Dashboard

**Cause:** You're at the directory level, not viewing index.html

**Solution:**

1. Click on "index.html" link to open it
2. Or directly visit: http://localhost:8000/index.html

### Problem: Port 8000 Won't Work on My System

**Try Different Ports:**

```bash
# Port 8001
python -m http.server 8001

# Port 8080
python -m http.server 8080

# Port 3000
python -m http.server 3000

# Port 5000
python -m http.server 5000
```

Then visit: `http://localhost:[port]`

### Problem: Files Load but Content is Empty

**Possible Causes:**

1. Markdown syntax error in file
2. File encoding issue (save as UTF-8)
3. File path issue

**Debug Steps:**

1. Open browser Developer Tools (F12)
2. Go to Console tab
3. Look for error messages
4. Check Network tab for failed requests
5. Try to view the .md file directly in browser

---

## Advanced Setup

### Keep Server Running in Background

**macOS/Linux:**
```bash
# Run in background
cd /Users/iamgroot/Documents/learn-claude
nohup python -m http.server 8000 &

# Or use screen/tmux
screen python -m http.server 8000
```

**Windows:**
```bash
# Run in background (PowerShell)
Start-Process python -ArgumentList "-m http.server 8000"
```

### Set Up Permanent Development Server

**Using Node.js (Recommended):**

```bash
# Install globally
npm install -g http-server

# Create alias in ~/.bashrc or ~/.zshrc
alias learn-server='cd ~/Documents/learn-claude && http-server'

# Use it anytime
learn-server
```

### IDE Integration

**VS Code:**
1. Install "Live Server" extension
2. Right-click index.html
3. Select "Open with Live Server"
4. Server auto-restarts on file changes

**WebStorm/IntelliJ:**
1. Built-in server included
2. Right-click index.html
3. Select "Run 'index.html'"

**Other IDEs:**
- Most modern IDEs have built-in servers
- Check IDE documentation for your specific editor

---

## Security Note

**Is it safe to run a local server?**

Yes! A local server on `localhost`:
- ✅ Only accessible from your computer
- ✅ No port exposed to internet
- ✅ Used only for development/learning
- ✅ Can be stopped anytime (Ctrl+C)

The server doesn't:
- ❌ Send data anywhere
- ❌ Connect to internet
- ❌ Expose sensitive information
- ❌ Run any dangerous code

---

## Complete Workflow

### First Time Setup (5 minutes)

```bash
# 1. Open Terminal
# Command: Cmd+Space → Terminal (macOS)

# 2. Navigate to directory
cd /Users/iamgroot/Documents/learn-claude

# 3. Start server
python -m http.server 8000

# 4. Open browser
# Visit: http://localhost:8000

# 5. Click index.html link
# Dashboard opens!
```

### Every Time You Study

```bash
# 1. Open Terminal
# 2. Navigate to directory
cd /Users/iamgroot/Documents/learn-claude

# 3. Start server
python -m http.server 8000

# 4. Open browser to http://localhost:8000

# 5. Study!

# 6. When done, press Ctrl+C to stop server
```

---

## Verify Installation

### Check Python Version
```bash
python --version
# or
python3 --version
```

Should output: `Python 3.x.x` or `Python 2.7.x`

### Check Node.js Version
```bash
node --version
npm --version
```

Should output version numbers if installed.

### Test Server

1. Start server as described above
2. Visit: http://localhost:8000
3. You should see a directory listing
4. Click on "index.html"
5. Dashboard loads
6. Click on Java8-Plus subject
7. Click on a file
8. Content displays without errors

---

## Quick Reference

| Task | Command |
|------|---------|
| Start Server (Python 3) | `python -m http.server 8000` |
| Start Server (Python 2) | `python -m SimpleHTTPServer 8000` |
| Start Server (Node) | `npx http-server` |
| Stop Server | Ctrl+C |
| Visit Dashboard | http://localhost:8000 |
| Use Different Port | `python -m http.server 9000` |
| Check Python | `python --version` |
| Check Node | `node --version` |

---

## Still Having Issues?

### Browser Console Debugging

1. Open browser (Chrome, Firefox, Safari, Edge)
2. Press F12 or Cmd+Option+I (Mac)
3. Click "Console" tab
4. Look for red error messages
5. Note the error and file path
6. Verify file exists in that location

### File Verification

Verify files exist:
```bash
ls -la /Users/iamgroot/Documents/learn-claude/Java8-Plus/notes/

# Should show:
# 01-java8-fundamentals.md
# 02-streams-api-deep-dive.md
# 03-java9-to-java21-features.md
```

### Terminal Output

When server starts, you should see:
```
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
127.0.0.1 - - [25/Oct/2024 20:00:00] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [25/Oct/2024 20:00:01] "GET /index.html HTTP/1.1" 200 -
```

Each request is logged. Errors show status codes like 404 (not found).

---

## Summary

**The Simple Solution:**

1. Open Terminal
2. Run: `python -m http.server 8000`
3. Open browser: http://localhost:8000
4. Click index.html
5. Start learning!

**That's it!** Your dashboard will work perfectly with a local server.

---

## Next Steps

Once server is running and dashboard loads:

1. ✅ Explore the sidebar
2. ✅ Click on Java8-Plus subject
3. ✅ Browse available files
4. ✅ Open a markdown file
5. ✅ Read the content
6. ✅ Try dark mode
7. ✅ Print a section
8. ✅ Start learning!

**Happy learning!** 🚀

