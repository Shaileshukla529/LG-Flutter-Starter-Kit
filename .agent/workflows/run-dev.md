---
description: How to run a Flutter LG Controller project in development mode.
---

# Flutter Development Workflow

## 1. Check Environment

```bash
flutter doctor
```

Ensure all checkmarks are green for your target platform.

---

## 2. Get Dependencies

```bash
flutter pub get
```

---

## 3. Run on Device/Emulator

```bash
# Run on connected device or emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device_id>
```

---

## 4. Hot Reload

While the app is running:
- Press `r` in the terminal for **hot reload**
- Press `R` for **hot restart**

---

## 5. Analyze Code

```bash
flutter analyze
```

Fix any warnings or errors before committing.

---

## 6. Run Tests

```bash
flutter test
```

---

## 7. Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (on macOS only)
flutter build ios --release
```
