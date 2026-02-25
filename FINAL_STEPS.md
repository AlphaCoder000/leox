# 🛑 PERMISSION BLOCKED

**I saw your screenshot.** The problem is that **you are not the Project Owner**, so Google Cloud is blocking you from changing your own permissions.

In the screenshot, I see that **Anand** (`ramashankarsingh841@gmail.com`) is the **Owner**.

## 🚀 THE ONLY FIX

You must ask **Anand** to do this for you:

1.  Ask Anand to log in to the Google Cloud Console.
2.  Go to the **IAM** page for project `studio-7488920972-4ef9c`.
3.  Find your email (`akashmoreasm6000@gmail.com`).
4.  Add the role: **"Service Usage Consumer"**.
5.  Click **Save**.

---

## ⏳ WHILE YOU WAIT
While you wait for Anand to grant the permission, you **cannot** deploy the Firebase Rules.

However, you can still **complete Step 3** (Adding the Google Client ID) so that part is ready.

1.  **Add Google Client ID**:
    *   Open `lib/providers/employer_auth_provider.dart`.
    *   Find `clientId: '1068765307272...`.
    *   Replace it with your actual Client ID if you have it. (If you can't access the Credentials page either, you will have to wait for Anand for this too).

## 🔄 ONCE ANAND GRANTS PERMISSION
Run the deploy command again:
```bash
firebase deploy --only firestore:rules
```
