#!/bin/bash

# Learning Dashboard Server Startup Script
# This script starts a local web server for the learning dashboard

echo "════════════════════════════════════════════════════════════"
echo "    📚 Learning Hub - Local Server Startup"
echo "════════════════════════════════════════════════════════════"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "📁 Directory: $SCRIPT_DIR"
echo ""

# Change to the script directory
cd "$SCRIPT_DIR"

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    echo "✅ Python 3 found. Starting server..."
    echo ""
    echo "🚀 Server is running at: http://localhost:8000"
    echo ""
    echo "📖 Open your browser and go to:"
    echo "   → http://localhost:8000"
    echo "   → Click on index.html"
    echo ""
    echo "🛑 To stop the server, press Ctrl+C"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo ""
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    echo "✅ Python found. Starting server..."
    echo ""
    echo "🚀 Server is running at: http://localhost:8000"
    echo ""
    echo "📖 Open your browser and go to:"
    echo "   → http://localhost:8000"
    echo "   → Click on index.html"
    echo ""
    echo "🛑 To stop the server, press Ctrl+C"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo ""
    python -m http.server 8000
else
    echo "❌ Python not found!"
    echo ""
    echo "Please install Python or use Node.js:"
    echo ""
    echo "Option 1: Install Python from python.org"
    echo ""
    echo "Option 2: Use Node.js (if installed):"
    echo "   → npx http-server"
    echo ""
    echo "Option 3: Use VS Code Live Server extension"
    echo ""
    exit 1
fi
