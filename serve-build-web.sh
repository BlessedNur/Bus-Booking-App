#!/bin/bash

# Serve Built Flutter Web App on LAN
# This builds the web app first and then serves it
# Use this if the live development server doesn't work

echo "🔨 Building Flutter web app..."
flutter build web

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check for errors above."
    exit 1
fi

echo ""
echo "✅ Build completed!"
echo ""

# Find local IP address
LOCAL_IP=$(ip addr show | grep -E "inet.*192\.168\.|inet.*10\.|inet.*172\." | grep -v "127.0.0.1" | head -1 | awk '{print $2}' | cut -d/ -f1)

if [ -z "$LOCAL_IP" ]; then
    echo "❌ Could not detect local IP address. Make sure you're connected to Wi-Fi."
    exit 1
fi

PORT=${1:-8000}

echo "📱 Starting HTTP server..."
echo ""
echo "Your app will be available at:"
echo "   http://$LOCAL_IP:$PORT"
echo ""
echo "📋 Steps:"
echo "   1. Make sure your phone is on the same Wi-Fi network"
echo "   2. Open your phone browser and go to: http://$LOCAL_IP:$PORT"
echo "   3. If it doesn't work, check your firewall settings"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Python is available
if command -v python3 &> /dev/null; then
    cd build/web
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    cd build/web
    python -m http.server $PORT
else
    echo "❌ Python not found. Please install Python 3 to use this script."
    echo "   Alternatively, use the run-web-on-lan.sh script for live development."
    exit 1
fi
