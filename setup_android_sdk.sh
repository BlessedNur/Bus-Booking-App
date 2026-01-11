#!/bin/bash
echo "🚀 Setting up Android SDK for APK building..."
echo ""

# Step 1: Install Java
echo "📦 Step 1: Installing Java (JDK 17)..."
sudo apt update
sudo apt install openjdk-17-jdk -y

# Step 2: Create Android SDK directory
echo ""
echo "📁 Step 2: Creating Android SDK directory..."
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk

# Step 3: Download command-line tools
echo ""
echo "⬇️  Step 3: Downloading Android command-line tools (~200MB)..."
wget -q --show-progress https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip

# Step 4: Extract tools
echo ""
echo "📦 Step 4: Extracting command-line tools..."
unzip -q cmdline-tools.zip
mkdir -p cmdline-tools/latest
# Move contents to latest directory
if [ -d "cmdline-tools" ]; then
    # If cmdline-tools directory exists, move its contents
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
    # If there are files directly in cmdline-tools, move them
    find cmdline-tools -maxdepth 1 -type f -exec mv {} cmdline-tools/latest/ \; 2>/dev/null || true
else
    # If extracted to current directory, create structure
    mkdir -p cmdline-tools/latest
    # Move any extracted files to latest
    find . -maxdepth 1 -type f -name "*.jar" -o -name "*.txt" -o -name "NOTICE*" | xargs -I {} mv {} cmdline-tools/latest/ 2>/dev/null || true
    find . -maxdepth 1 -type d ! -name "." ! -name "cmdline-tools" | xargs -I {} mv {}/* cmdline-tools/latest/ 2>/dev/null || true
fi
rm -f cmdline-tools.zip

# Step 5: Set environment variables
echo ""
echo "⚙️  Step 5: Setting up environment variables..."
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Add to bashrc if not already there
if ! grep -q "ANDROID_HOME" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Android SDK" >> ~/.bashrc
    echo "export ANDROID_HOME=\$HOME/Android/Sdk" >> ~/.bashrc
    echo "export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools" >> ~/.bashrc
fi

# Step 6: Accept licenses and install SDK components
echo ""
echo "✅ Step 6: Accepting licenses and installing SDK components..."
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null 2>&1
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Step 7: Configure Flutter
echo ""
echo "🔧 Step 7: Configuring Flutter..."
flutter config --android-sdk $ANDROID_HOME
yes | flutter doctor --android-licenses

echo ""
echo "✅ Setup complete! Now you can build APK with:"
echo "   cd /home/blessed-nur/Desktop/projects/bus_booking_app"
echo "   flutter build apk --release"
