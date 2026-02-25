# FINAL SETUP - EDITOR ROLE ACTIVE

Congrats! With the **Editor** role, you can now fix everything yourself.

## 1. Create the OAuth Client ID
1.  Go to **Google Cloud Console > Credentials**:
    [https://console.cloud.google.com/apis/credentials?project=studio-7488920972-4ef9c](https://console.cloud.google.com/apis/credentials?project=studio-7488920972-4ef9c)

2.  Click **"+ Create credentials"**.

3.  Select **"OAuth client ID"**.

4.  **Application Type**: Select **"Web application"**.
    *(Do NOT select Android. Firebase uses the Web Client ID for authentication).*

5.  **Name**: Enter "Web Client".

6.  **Authorized JavaScript origins**: `http://localhost` (optional, good for testing).

7.  **Authorized redirect URIs**: Leave empty.

8.  Click **"CREATE"**.

9.  Copy the **Client ID** from the popup (ends with `.apps.googleusercontent.com`).

## 2. Add Client ID to Code
Paste the Client ID into these two files:

*   **File:** `lib/providers/employer_auth_provider.dart` (Line ~13)
    *   Find: `clientId: '1068765307272...`
    *   Replace with your new ID.

*   **File:** `lib/providers/employee_providers/employee_auth_provider.dart` (Line ~14)
    *   Find: `clientId: '1068765307272...`
    *   Replace with your new ID.

## 3. Enable Google Sign-In (If not already enabled)
1.  Go to **Firebase Console > Authentication > Sign-in method**:
    [https://console.firebase.google.com/project/studio-7488920972-4ef9c/authentication/providers](https://console.firebase.google.com/project/studio-7488920972-4ef9c/authentication/providers)

2.  Make sure **Google** is enabled.
3.  Also ensure **Email/Password** is enabled.

## 4. Run the App
```bash
flutter run
```

 EVERYTHING will now work:
 *   Google Sign-In
 *   Email Registration
 *   Job Posting
 *   Database Rules
