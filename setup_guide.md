# Leox App - Firebase Integration Guide

## 1. Firebase Rules

I have generated a `firestore.rules` file that supports both your existing Web App and the new Mobile App.

**To deploy these rules, run:**

```bash
firebase deploy --only firestore:rules
```

**If you get a permission error (HTTP 403):**
1. Go to Google Cloud Console: [IAM Admin](https://console.developers.google.com/iam-admin/iam/project?project=studio-7488920972-4ef9c)
2. Locate your email: `akashmoreasm6000@gmail.com`
3. Click "Edit" (pencil icon) or "Grant Access".
4. Add the Role: **"Service Usage Consumer"** (`roles/serviceusage.serviceUsageConsumer`).
5. Save and wait 2 minutes.
6. Run the deploy command again.

## 2. Google Sign-In Setup

For Google Sign In to work on Android and Web (Firebase Auth), you need to configure the **OAuth Client ID**.

1. Go to **Google Cloud Console > APIs & Services > Credentials**.
2. Look for the **Web application** client ID (auto-created by Firebase).
3. Copy the **Client ID** (ends with `.apps.googleusercontent.com`).
4. Update `lib/providers/employer_auth_provider.dart` and `lib/providers/employee_providers/employee_auth_provider.dart`:
   - Replace the placeholder `1068765307272-33003202...` with your actual Client ID.

## 3. Usage

- **Register**: Creates users in `users` collection (Web compatible) AND `employers`/`employees` collection (Mobile compatible).
- **Jobs**:
  - Posting a job now requires **Company Name** and **Location** (added to UI).
  - Jobs are saved with `status: 'Open'` and `postedBy: <UID>` to match your database structure.
- **Navigation**:
  - After posting a job, you will be redirected to the Jobs List.
