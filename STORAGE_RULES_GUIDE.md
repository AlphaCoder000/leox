# Firebase Storage Rules Setup

To ensure file uploads work correctly (Profile Pictures and Resumes), you must configure your Firebase Storage Rules.

1. Go to **Firebase Console** > **Storage** > **Rules**.
2. Replace the default rules with the following rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

This allows any authenticated user to upload and view files.

## For Production (Optional refinement)

To restrict uploads to specific folders:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Only allow users to manage their own profile pictures and resumes
    match /employees/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /employers/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

For now, sticking to `request.auth != null` is safest for development.
