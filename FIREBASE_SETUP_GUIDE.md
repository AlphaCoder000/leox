# Firebase & Next.js Backend Setup Guide

## 📋 Current Status
- ✅ Flutter app configured for Firebase
- ✅ Firebase Auth integrated in providers
- ✅ API service ready for Next.js backend
- ⚠️ Need correct Firebase config files
- ⚠️ Need to verify Next.js backend connection

## 🔧 Step 1: Get Correct Firebase Configuration

### What You Need:
1. **Firebase Console Access** ✅ (You have this)
2. **Project ID**: `studio-7488920972-4ef9c` ✅ (From your service account)
3. **Correct config files** ❌ (Currently have service account file)

### Actions Required:

#### A. Download Correct Android Config:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `studio-7488920972-4ef9c`
3. **Project Settings** ⚙️ → **Your apps**
4. Select your **Android app**
5. Click **Download config** → Get `google-services.json`
6. **Replace** current file: `android/app/google-services.json`

#### B. Generate Firebase Options:
```bash
# Run this command in your project root
flutterfire configure
```

This will update `lib/firebase_options.dart` with correct values.

## 🌐 Step 2: Next.js Backend Connection

### Current Configuration:
- **API Base URL**: `http://localhost:3000/api`
- **Authentication**: Firebase Auth tokens
- **Data Storage**: Firebase Firestore/Firebase Storage

### Verify Backend Endpoints:
Make sure your Next.js backend has these endpoints:

#### Authentication Endpoints:
```
POST /api/auth/employee/register-email
POST /api/auth/employee/login-email  
POST /api/auth/employee/register-phone
POST /api/auth/employee/send-otp
POST /api/auth/employee/verify-otp
```

#### Employee Data Endpoints:
```
GET  /api/employee/dashboard
GET  /api/employee/profile
PUT  /api/employee/profile
GET  /api/employee/jobs
POST /api/employee/jobs/:id/apply
```

#### Employer Data Endpoints:
```
GET  /api/employer/dashboard
GET  /api/employer/profile
PUT  /api/employer/profile
GET  /api/employer/jobs
POST /api/employer/jobs
```

## 🧪 Step 3: Test Connection

### 1. Test Firebase Auth:
```dart
// In your Flutter app, test Firebase Auth
await Provider.of<EmployeeAuthProvider>(context, listen: false)
    .signInWithFirebase(email: "test@example.com", password: "password");
```

### 2. Test Backend API:
```bash
# Test if Next.js backend is running
curl http://localhost:3000/api/health

# Test authentication endpoint
curl -X POST http://localhost:3000/api/auth/employee/login-email \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

## 🔍 Step 4: Debug Firebase Issues

### Common Firebase Issues & Solutions:

#### Issue 1: "Failed to load FirebaseOptions from resource"
**Cause**: Wrong `google-services.json` file
**Solution**: Download correct Android config from Firebase Console

#### Issue 2: "auth/invalid-api-key"
**Cause**: Wrong API key in Firebase options
**Solution**: Run `flutterfire configure` to update options

#### Issue 3: "auth/project-not-found"
**Cause**: Wrong project ID or Firebase project not initialized
**Solution**: Verify project ID in Firebase Console

## 📱 Step 5: Test Complete Flow

### Authentication Flow:
1. **User opens app** → Splash screen
2. **Firebase Auth state checked** → Auto-login if authenticated
3. **Manual login** → Firebase Auth + Next.js API call
4. **Token stored** → SharedPreferences for session
5. **Navigate to dashboard** → User data loaded from API

### Data Flow:
1. **Firebase Auth** → Handles authentication
2. **Next.js API** → Handles business logic & data
3. **Firebase Firestore** → Stores user data
4. **Flutter App** → Displays UI

## 🚀 Next Steps

### Immediate Actions:
1. **Download correct `google-services.json`** from Firebase Console
2. **Run `flutterfire configure`** to update Firebase options
3. **Start Next.js backend** on `http://localhost:3000`
4. **Test authentication flow**

### Verification:
- ✅ Firebase initializes without errors
- ✅ Firebase Auth works (login/register)
- ✅ API calls to Next.js succeed
- ✅ User data loads correctly

## 🆘 Troubleshooting

### If Firebase Still Fails:
```bash
# Clean Flutter project
flutter clean
flutter pub get

# Rebuild
flutter build apk --debug
```

### If Backend Connection Fails:
1. **Check Next.js server is running**: `npm run dev`
2. **Verify API endpoints exist**: Use Postman/curl
3. **Check CORS settings**: Allow mobile app requests
4. **Verify Firebase Admin SDK** in Next.js backend

### If Auth Tokens Don't Work:
1. **Verify Firebase Admin SDK** configuration in Next.js
2. **Check token exchange** between Flutter and backend
3. **Test with Firebase Emulator** if needed

---

## 📞 Support Resources

- [Flutter Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
- [Firebase Console](https://console.firebase.google.com/)
- [Next.js Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

**Remember**: Your existing web app's Firebase project should work seamlessly with the Flutter mobile app once properly configured!
