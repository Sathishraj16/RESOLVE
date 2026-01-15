# Google Sign-In Error Fix (API Exception: 10)

## Problem
Google Sign-In is failing with `ApiException: 10` (DEVELOPER_ERROR). This happens because the SHA-1 certificate fingerprint is not registered in your Firebase project.

## Solution

### Step 1: Get Your SHA-1 Fingerprint

Run this command in PowerShell from the project root:

```powershell
cd android
.\gradlew signingReport
```

Look for the SHA1 fingerprint under `Variant: debug` and `Config: debug`:
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **resolve-bcdcb**
3. Click the gear icon ⚙️ → **Project settings**
4. Scroll down to **Your apps** section
5. Find your Android app: `com.civicflow.resolve`
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

### Step 3: Download Updated google-services.json

1. In the same Firebase Project Settings page
2. Under your Android app (`com.civicflow.resolve`)
3. Click **google-services.json** download button
4. Replace the file in: `android/app/google-services.json`

### Step 4: Rebuild and Run

```bash
flutter clean
flutter pub get
flutter run -d 000553439001689
```

## Alternative: Quick Test Without Google Sign-In

For now, you can test the app by using email/password authentication for Officials/Admins, or skip the Google Sign-In and implement it later.

The app should still work for:
- Officials logging in with email/password
- Admins logging in with email/password
- Everything except citizen Google OAuth

## Note
Your current google-services.json has an empty `oauth_client` array, which confirms the SHA-1 is not configured:
```json
"oauth_client": []
```

After adding the SHA-1, this array will be populated with OAuth client configuration.
