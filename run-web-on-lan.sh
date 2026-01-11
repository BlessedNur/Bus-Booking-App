#!/bin/bash

# Flutter Web Server for LAN Access
# This script runs your Flutter web app on your local network
# so you can access it from your phone browser

echo "🚀 Starting Flutter Web Server for LAN access..."
echo ""

# Find local IP address
LOCAL_IP=$(ip addr show | grep -E "inet.*192\.168\.|inet.*10\.|inet.*172\." | grep -v "127.0.0.1" | head -1 | awk '{print $2}' | cut -d/ -f1)

if [ -z "$LOCAL_IP" ]; then
    echo "❌ Could not detect local IP address. Make sure you're connected to Wi-Fi."
    exit 1
fi

PORT=${1:-8080}

echo "📱 Your app will be available at:"
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

# Run Flutter web server with LAN access
flutter run -d web-server --web-port $PORT --web-hostname 0.0.0.0
