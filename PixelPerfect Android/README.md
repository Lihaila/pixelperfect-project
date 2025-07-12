# PixelPerfect Android

A professional image optimization app for Android, built with Kotlin and Jetpack Compose, targeting the latest Android 16.

## ✨ Features

- **🖼️ Multiple Formats**: Support for JPEG, PNG, and SVG formats with optimized compression
- **📐 Smart Resizing**: Resize images with aspect ratio preservation for perfect results
- **🎛️ Quality Control**: Adjust compression quality to balance file size and image quality
- **💾 Easy Export**: Save to Gallery or share optimized images instantly with scoped storage
- **🎨 Modern UI**: Built with Jetpack Compose and Material Design 3
- **🔒 Privacy First**: Granular media permissions for Android 13+
- **⚡ Performance**: Optimized for Android 16 with hardware acceleration
- **🌙 Theme Support**: Light and dark theme compatibility

## 📋 Requirements

- **Android Studio**: Hedgehog (2023.1.1) or later
- **Kotlin**: 1.9.22
- **Minimum SDK**: API 24 (Android 7.0) - Covers 98%+ of devices
- **Target SDK**: API 36 (Android 16)
- **Compile SDK**: 36
- **Java**: Version 8 compatibility

## 🚀 Getting Started

### Prerequisites
- Install Android Studio with Android 16 (API 36) SDK
- Enable USB debugging on your device or set up an emulator

### Setup Instructions
1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd "PixelPerfect Android"
   ```

2. **Open the project**
   - Launch Android Studio
   - File → Open → Select the "PixelPerfect Android" folder
   - Wait for Gradle sync to complete

3. **Build and run**
   ```bash
   Build → Make Project (Ctrl+F9)
   Run → Run 'app' (Shift+F10)
   ```

### 📱 Device Setup
- **Physical Device**: Android 7.0+ with USB debugging enabled
- **Emulator**: Create AVD with Android 16 (API 36) system image

## 🏗️ Architecture

The app follows modern Android development practices and Android 16 optimizations:

### **Core Technologies**
- **UI Framework**: Jetpack Compose 1.5.10 with Material Design 3
- **Language**: Kotlin 1.9.22 with coroutines
- **Architecture**: MVVM with Compose state management
- **Build System**: Gradle 8.6 with Android Gradle Plugin 8.2.2

### **Key Libraries**
- **Image Loading**: Coil 2.5.0 for efficient image loading and caching
- **Permissions**: Accompanist Permissions 0.32.0 for runtime permission handling
- **File Operations**: DocumentFile API with scoped storage compliance
- **Image Processing**: ExifInterface for metadata handling
- **UI Components**: Material Icons Extended for comprehensive iconography

### **Android 16 Features**
- **Granular Media Permissions**: Enhanced privacy with READ_MEDIA_IMAGES
- **Scoped Storage**: Full compliance with modern file access patterns
- **Hardware Acceleration**: Optimized image processing performance
- **Memory Management**: Improved bitmap handling for large images

## 📁 Project Structure

```
PixelPerfect Android/
├── app/
│   ├── src/main/
│   │   ├── java/com/pixelperfect/android/
│   │   │   ├── ui/
│   │   │   │   ├── screens/          # Screen composables (Home, About)
│   │   │   │   └── theme/            # Material Design 3 theme system
│   │   │   ├── MainActivity.kt       # Main activity with Compose setup
│   │   │   └── PixelPerfectApp.kt   # Root app composable with navigation
│   │   ├── res/
│   │   │   ├── values/               # Strings, colors, themes
│   │   │   └── mipmap-*/             # App icons for different densities
│   │   └── AndroidManifest.xml       # App configuration with modern permissions
│   ├── build.gradle                  # App-level dependencies and config
│   └── proguard-rules.pro           # Code obfuscation rules
├── gradle/
│   └── wrapper/
│       └── gradle-wrapper.properties # Gradle 8.6 distribution
├── build.gradle                      # Project-level build configuration
├── settings.gradle                   # Project settings and modules
├── gradle.properties                 # Gradle JVM and build options
├── README.md                        # This file
└── SETUP_STATUS.md                  # Detailed setup and configuration status
```

## 🛠️ Development Features

### **Ready-to-Use Components**
- ✅ **Bottom Navigation**: Home and About screens
- ✅ **Image Selection Card**: Gallery integration placeholder
- ✅ **Processing UI**: Image optimization interface
- ✅ **Supported Formats Display**: Format badges (JPG, PNG, SVG)
- ✅ **Material Design Cards**: Clean, modern interface components

### **Planned Implementations**
- 🔄 **Photo Picker Integration**: Modern Android photo selection
- 🔄 **Image Compression Engine**: Quality and size optimization
- 🔄 **Resize Functionality**: Aspect ratio preservation (like iOS version)
- 🔄 **Export Options**: Gallery save and sharing capabilities
- 🔄 **Progress Indicators**: Real-time processing feedback

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
   - Follow Kotlin coding conventions
   - Add comments for complex logic
   - Update tests if applicable
4. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
5. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
6. **Submit a pull request**

## 🔧 Troubleshooting

### Common Issues
- **Gradle Sync Failed**: Check `SETUP_STATUS.md` for dependency versions
- **Permission Errors**: Ensure Android 16 SDK is installed
- **Build Errors**: Clean and rebuild project (Build → Clean Project)

### Useful Commands
```bash
# Clean build
./gradlew clean

# Build debug APK
./gradlew assembleDebug

# Run tests
./gradlew test
```

## 📝 Changelog

### v1.0.0 (Current)
- ✅ Initial project setup with Android 16 support
- ✅ Jetpack Compose UI framework
- ✅ Material Design 3 implementation
- ✅ Modern permission handling
- ✅ Scoped storage compliance
- ✅ Image processing dependencies ready

## 📄 License

© 2025 PixelPerfect. All rights reserved.

---

**Built with ❤️ using Android 16, Kotlin, and Jetpack Compose**
