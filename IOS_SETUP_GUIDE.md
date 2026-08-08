# iOS Setup & Build Guide for macOS

This guide provides step-by-step instructions to set up Flutter on a MacBook, configure Xcode and CocoaPods, run the project, and generate the iOS build.

---

## Prerequisites

Before starting, ensure your MacBook is connected to the internet and has enough disk space (at least 20-30 GB for Xcode and build tools).

---

## Step 1: Install Xcode & Command Line Tools

Xcode is Apple's IDE required to build iOS apps.

1. Open the **App Store** on the Mac and search for **Xcode**.
2. Download and install Xcode (this may take some time as it is large).
3. Once installed, open **Terminal** (press `Cmd + Space`, type `Terminal`, and hit Enter) and run the following command to configure Xcode command-line tools:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
4. Accept the Xcode license agreement:
   ```bash
   sudo xcodebuild -license accept
   ```

---

## Step 2: Install Homebrew & CocoaPods

CocoaPods is the dependency manager for iOS native libraries used by Flutter plugins.

1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Follow the on-screen instructions in the Terminal to add Homebrew to your PATH.
3. **Install CocoaPods** using Homebrew:
   ```bash
   brew install cocoapods
   ```

---

## Step 3: Install Flutter SDK

1. Download the Flutter SDK for macOS from the [official Flutter website](https://docs.flutter.dev/get-started/install/macos).
   * **Note:** Choose the correct version matching the MacBook's processor (Apple Silicon `Apple M1/M2/M3` or `Intel`).
2. Extract the downloaded zip file and move the `flutter` directory to your desired location (e.g., `~/development/flutter`).
3. Add `flutter` to your system PATH. Open `~/.zshrc` (or `~/.bash_profile`) in a text editor:
   ```bash
   nano ~/.zshrc
   ```
4. Add the following line at the end of the file (replace with your actual path):
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```
5. Save the file (in nano, press `Ctrl + O`, `Enter`, and then `Ctrl + X`) and reload it:
   ```bash
   source ~/.zshrc
   ```
6. Run `flutter doctor` to verify the installation:
   ```bash
   flutter doctor
   ```
   * Resolve any issues flagged by `flutter doctor` (e.g., agreeing to android-licenses if needed, or configuring Xcode settings).

---

## Step 4: Prepare the Project

1. Copy the codebase folder (`leox`) onto the MacBook.
2. In the Terminal, navigate (`cd`) into the project directory:
   ```bash
   cd /path/to/your/project/leox
   ```
3. Fetch the Flutter dependencies:
   ```bash
   flutter pub get
   ```
4. Set up CocoaPods for the iOS platform:
   ```bash
   cd ios
   pod install
   cd ..
   ```

---

## Step 5: Run the App on Simulator

1. To open the iOS Simulator:
   ```bash
   open -a Simulator
   ```
2. Verify that the Simulator is active and detected by running:
   ```bash
   flutter devices
   ```
3. Run the application in debug mode on the Simulator:
   ```bash
   flutter run
   ```

---

## Step 6: Generate the iOS App / Archive (.ipa)

There are two primary ways to compile the iOS app:

### Option A: Generate an Unsigned Release Build
This is useful if you want to generate a build without configuring Apple Developer profiles immediately.
1. Run the build command:
   ```bash
   flutter build ios --no-codesign --release
   ```
2. Navigate to the compiled build directory:
   ```bash
   cd build/ios/iphoneos
   ```
3. Package the `.app` bundle into a deployable `.ipa` format:
   ```bash
   mkdir -p Payload
   cp -r Runner.app Payload/
   zip -r Runner.ipa Payload
   ```
4. Your unsigned `.ipa` file is now located at `build/ios/iphoneos/Runner.ipa`. You can install it on jailbroken devices or distribute it via services that accept unsigned apps.

### Option B: Build a Signed App via Xcode (For App Store or TestFlight)
To install the app on standard physical iPhones, you must sign it.
1. Open the project's iOS workspace in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In Xcode, select the **Runner** project in the left navigation sidebar.
3. Select the **Runner** target, then go to the **Signing & Capabilities** tab.
4. Check **Automatically manage signing**.
5. Select your Apple Development Team (you can log in with a free or paid Apple ID).
   * Note: A paid Apple Developer Program account is required to generate an App Store IPA or distribute through TestFlight.
6. Select **Any iOS Device (arm64)** as the build target at the top header bar.
7. Go to **Product** (in the top menu bar) -> **Archive**.
8. Once archiving is complete, the Organizer window will open. Click **Distribute App** and follow the prompt options to export it as an **Ad-Hoc**, **Development**, or **App Store Connect** `.ipa` file.
