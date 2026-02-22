# CREATE OAUTH CLIENT ID

I see from your screenshot that **no OAuth 2.0 Client IDs exist yet**. You need to create one.

## STEPS TO CREATE

1.  On that same screen (Google Cloud Console > Credentials), click the **"+ Create credentials"** button at the top.

2.  Select **"OAuth client ID"**.

3.  *If it asks you to "Configure Consent Screen" first:*
    *   Click "Configure Consent Screen".
    *   Select "External".
    *   Fill in the App Name ("Leox"), User Support Email (your email), and Developer Contact Info (your email).
    *   Click "Save and Continue" through the other steps (you don't need to add scopes or test users right now).
    *   Go back to "Credentials" and click "+ Create credentials" > "OAuth client ID" again.

4.  **Application Type**: Select **"Web application"**.
    *(Do NOT select Android. Firebase uses the Web Client ID for authentication).*

5.  **Name**: Enter "Web Client".

6.  **Authorized JavaScript origins**: Leave empty for now (or add `http://localhost` if testing web).

7.  **Authorized redirect URIs**: Leave empty for now.

8.  Click **"CREATE"**.

9.  A popup will show your **Client ID** (it ends with `.apps.googleusercontent.com`).

10. **COPY THAT CLIENT ID**.

## NEXT STEP
Once you have copied the Client ID, paste it into your code in:
*   `lib/providers/employer_auth_provider.dart`
*   `lib/providers/employee_providers/employee_auth_provider.dart`
