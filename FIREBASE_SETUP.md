# Firebase Setup Guide for RESOLVE

## Overview
RESOLVE now uses Firebase for:
- **Citizens**: Google OAuth authentication (no password needed)
- **Officials/Admins**: Email/password stored in Firestore (added by admins)
- **Database**: Cloud Firestore for storing user data and complaints

## Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name: `RESOLVE` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Add Android App
1. Click Android icon in project overview
2. **Android package name**: `com.resolve.app` (from `android/app/build.gradle`)
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

### 3. Add iOS App (if needed)
1. Click iOS icon in project overview
2. **iOS bundle ID**: `com.resolve.app`
3. Download `GoogleService-Info.plist`
4. Place in: `ios/Runner/GoogleService-Info.plist`

### 4. Add Web App
1. Click Web icon (</>)
2. App nickname: `RESOLVE Web`
3. Copy the Firebase configuration object
4. Update `lib/core/config/firebase_config.dart`:

```dart
static const String webApiKey = 'YOUR_WEB_API_KEY_HERE';
static const String projectId = 'your-project-id';
static const String messagingSenderId = '123456789';
static const String appId = '1:123456789:web:abcdef';
static const String storageBucket = 'your-project.appspot.com';
```

### 5. Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Google** sign-in provider:
   - Click on "Google"
   - Toggle "Enable"
   - Set project support email
   - Click "Save"

### 6. Create Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Start in **test mode** (change to production rules later)
4. Choose location closest to your users
5. Click "Enable"

### 7. Set Up Firestore Collections

Create these collections manually or they'll be created automatically:

#### `citizens` Collection
- Stores citizen profiles (auto-created on Google Sign-In)
- Document ID: Firebase Auth UID
- Fields:
  ```
  - id: string
  - name: string
  - email: string
  - phone: string (optional)
  - photoUrl: string (optional)
  - role: "citizen"
  - createdAt: timestamp
  - complaintsFiled: number
  ```

#### `officials` Collection
- Stores field officer profiles (manually added by admin)
- Document ID: auto-generated
- Fields:
  ```
  - id: string
  - name: string
  - email: string
  - password: string (plain text for now - hash in production!)
  - phone: string
  - role: "official"
  - department: string
  - designation: string
  - createdAt: timestamp
  - complaintsResolved: number
  ```

#### `admins` Collection
- Stores administrator profiles
- Document ID: auto-generated
- Fields:
  ```
  - id: string
  - name: string
  - email: string
  - password: string
  - phone: string
  - role: "admin"
  - department: string
  - designation: string
  - createdAt: timestamp
  ```

### 8. Add Sample Official Account
Go to Firestore Database and manually add a document to `officials`:

```json
{
  "id": "official_001",
  "name": "Officer Smith",
  "email": "officer@example.com",
  "password": "password123",
  "phone": "+91 9876543210",
  "role": "official",
  "department": "Public Works",
  "designation": "Field Engineer",
  "createdAt": "2026-01-14T10:00:00Z",
  "complaintsResolved": 0
}
```

### 9. Add Sample Admin Account
Add a document to `admins`:

```json
{
  "id": "admin_001",
  "name": "Admin Kumar",
  "email": "admin@example.com",
  "password": "admin123",
  "phone": "+91 9876543210",
  "role": "admin",
  "department": "Public Works",
  "designation": "Department Head",
  "createdAt": "2026-01-14T10:00:00Z"
}
```

### 10. Configure Android App
Edit `android/app/build.gradle`:

```gradle
// Add at the top
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'dev.flutter.flutter-gradle-plugin'
    id 'com.google.gms.google-services'  // Add this line
}
```

Edit `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:8.7.3'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.2'  // Add this line
    }
}
```

### 11. Initialize Firebase in App

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Auto-generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ResolveApp());
}
```

### 12. Generate Firebase Options
Run this command to auto-generate Firebase configuration:

```bash
flutterfire configure
```

This creates `lib/firebase_options.dart` with all your Firebase configuration.

## Security Rules (Production)

### Firestore Rules
Replace test mode rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Citizens collection
    match /citizens/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Officials collection (read-only)
    match /officials/{docId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins via admin SDK
    }
    
    // Admins collection (read-only)
    match /admins/{docId} {
      allow read: if request.auth != null;
      allow write: if false; // Only via admin SDK
    }
    
    // Complaints collection
    match /complaints/{complaintId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```

## Testing

### Test Citizen Login
1. Run the app
2. Select "Citizen"
3. Click "Sign in with Google"
4. Choose Google account
5. Should redirect to Citizen Home

### Test Official Login
1. Select "Official"
2. Email: `officer@example.com`
3. Password: `password123`
4. Should redirect to Official Home

### Test Admin Login
1. Select "Administrator"
2. Email: `admin@example.com`
3. Password: `admin123`
4. Should redirect to Admin Dashboard

## Important Notes

⚠️ **Security Warnings**:
1. Passwords are stored in plain text - use Firebase Admin SDK with hashing in production
2. Test mode Firestore rules are open - update before going live
3. Add rate limiting and abuse prevention

🔐 **Google Sign-In**:
- Only citizens use Google OAuth
- Officials and admins use email/password
- No self-registration for officials/admins

📱 **Platform Support**:
- Android: Full support with google-services.json
- iOS: Full support with GoogleService-Info.plist
- Web: Full support with web config

## Troubleshooting

### Google Sign-In Fails
- Check SHA-1 certificate in Firebase Console
- Verify google-services.json is in android/app/
- Run `flutter clean` and rebuild

### Firestore Permission Denied
- Check security rules
- Verify authentication is working
- Check collection names match exactly

### Build Errors
- Update Android build.gradle files
- Run `flutter pub get`
- Clean and rebuild: `flutter clean && flutter build apk`

## Next Steps
1. Complete Firebase setup
2. Test authentication flow
3. Implement complaint storage in Firestore
4. Add image upload to Firebase Storage
5. Set up Cloud Functions for notifications
