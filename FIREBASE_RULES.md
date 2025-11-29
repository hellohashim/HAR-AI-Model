# Firebase Realtime Database Rules

Your Firebase Realtime Database needs proper rules to allow read/write access.

## Current Issue
The app may not be able to write data because the database rules are too restrictive or not properly configured.

## How to Fix

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: **work-out-app-6fcba**
3. Navigate to: **Realtime Database** → **Rules** tab
4. Replace the rules with one of the following options:

### Option 1: Allow All (Development Only - UNSAFE FOR PRODUCTION)
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

### Option 2: Secure (Recommended for Production)
```json
{
  "rules": {
    "text_entries": {
      ".read": true,
      ".write": true,
      "$entry": {
        ".validate": "newData.hasChildren(['text', 'createdAt', 'updatedAt'])",
        "text": {
          ".validate": "newData.isString() && newData.val().length > 0"
        },
        "createdAt": {
          ".validate": "newData.isString()"
        },
        "updatedAt": {
          ".validate": "newData.isString()"
        }
      }
    }
  }
}
```

5. Click **Publish** button
6. Wait for the confirmation
7. Run your Flutter app again

## Testing
After updating rules:
1. Run: `flutter run`
2. Try adding a text entry
3. Check the console logs for the DEBUG messages
4. Check Firebase Console → Realtime Database → Data tab to see if entries appear

## Why This Issue Happens
Firebase Realtime Database is secure by default. If you haven't set up rules, the database likely has default deny rules that prevent all read/write operations.
