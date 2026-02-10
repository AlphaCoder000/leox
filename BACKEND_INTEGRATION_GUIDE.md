# Backend Integration Guide
## Flutter App with Web App Backend Structure

### 📋 **Overview**

Your Flutter app has been restructured to match the web app's backend architecture while preserving all existing Firebase configurations and functionality.

---

## 🏗️ **New Backend Structure**

### **1. Core Backend Logic (`lib/backend/`)**

#### **Server Actions** (`server_actions.dart`)
- **Equivalent to**: Web app's `src/lib/actions.ts`
- **Purpose**: Main backend logic for job applications, interviews, database operations
- **Key Features**:
  - Job application management
  - Interview scheduling
  - User profile updates
  - Statistics and analytics
  - Notification system

#### **AI Workflows** (`ai_workflows.dart`)
- **Equivalent to**: Web app's `src/ai/flows/` directory
- **Purpose**: AI-powered features and workflows
- **Key Features**:
  - Resume parsing (`parse-resume.ts`)
  - Job-resume matching (`ai-match-resume-to-job.ts`)
  - Interview question generation (`generate-interview-questions.ts`)
  - Profile optimization
  - Career recommendations
  - Skill assessment

### **2. Service Layer (`lib/services/`)**

#### **Firebase Service** (`firebase_service.dart`)
- **Equivalent to**: Web app's `src/lib/firebaseAdmin.server.ts`
- **Purpose**: Secure Firebase operations
- **Key Features**:
  - Authentication management
  - Firestore operations with security
  - File storage operations
  - Batch operations and transactions
  - User permissions and access control

#### **Profile Service** (`profile_service.dart`)
- **Equivalent to**: Web app's `src/lib/services/profileService.ts`
- **Purpose**: Specialized business logic for user profiles
- **Key Features**:
  - Employee profile management
  - Employer profile management
  - Profile completeness analysis
  - AI-powered profile optimization
  - Profile verification

---

## 🔧 **Integration Points**

### **Firebase Configuration (Preserved)**
✅ **Project ID**: `studio-7488920972-4ef9c`  
✅ **API Key**: `AIzaSyBNVp_4-eg-QNAlAWY612osmTcOLVrcGXU`  
✅ **App ID**: `1:340682426505:android:922212c20eff9fb0135e58`  
✅ **Storage Bucket**: `studio-7488920972-4ef9c.firebasestorage.app`

### **Next.js Backend Integration**
✅ **Base URL**: `http://localhost:3000/api`  
✅ **API Service**: Configured for backend communication  
✅ **Authentication**: Firebase Auth tokens for API calls  

---

## 📱 **App Architecture**

### **Provider Structure**
```dart
MultiProvider(
  providers: [
    // Core Services
    Provider<FirebaseService>(create: (_) => FirebaseService()),
    Provider<ProfileService>(create: (_) => ProfileService()),
    Provider<ServerActions>(create: (_) => ServerActions()),
    Provider<AIWorkflows>(create: (_) => AIWorkflows()),
    
    // Existing Providers (Preserved)
    ChangeNotifierProvider(create: (_) => EmployeeAuthProvider()),
    ChangeNotifierProvider(create: (_) => EmployerAuthProvider()),
    // ... other providers
  ],
)
```

### **Data Flow**
1. **UI Layer** → **Providers** → **Services** → **Backend**
2. **Firebase Auth** → **Firebase Service** → **Firestore**
3. **AI Features** → **AI Workflows** → **Next.js API** → **AI Services**

---

## 🚀 **New Features Added**

### **1. Enhanced Job Management**
- **Job Application Tracking**: Complete application lifecycle
- **Interview Scheduling**: Automated interview management
- **AI Job Matching**: Resume-to-job compatibility scoring
- **Application Analytics**: Comprehensive statistics

### **2. AI-Powered Features**
- **Resume Parsing**: Automatic extraction of resume data
- **Profile Optimization**: AI suggestions for better profiles
- **Interview Questions**: Dynamic question generation
- **Career Recommendations**: Personalized career paths
- **Skill Assessment**: Automated skill evaluation

### **3. Enhanced User Profiles**
- **Profile Completeness**: Automatic scoring and suggestions
- **AI Insights**: Profile strength analysis
- **Verification System**: Profile verification workflow
- **Activity Logging**: User activity tracking

### **4. Advanced Backend Operations**
- **Batch Operations**: Efficient bulk operations
- **Transactions**: Atomic database operations
- **Security Rules**: Document-level access control
- **Activity Monitoring**: User activity analytics

---

## 🔄 **API Endpoints Structure**

### **Authentication Endpoints**
```
POST /api/auth/employee/login-email
POST /api/auth/employee/register-email
POST /api/auth/employer/login-email
POST /api/auth/employer/register-email
```

### **AI Endpoints**
```
POST /api/ai/parse-resume
POST /api/ai/match-resume
POST /api/ai/generate-questions
POST /api/ai/optimize-profile
POST /api/ai/analyze-job
POST /api/ai/assess-skills
POST /api/ai/career-recommendations
```

### **Job Management Endpoints**
```
GET  /api/jobs
POST /api/jobs
PUT  /api/jobs/:id
DELETE /api/jobs/:id
POST /api/jobs/:id/apply
```

### **Profile Management Endpoints**
```
GET  /api/profile/employee/:id
PUT  /api/profile/employee/:id
GET  /api/profile/employer/:id
PUT  /api/profile/employer/:id
POST /api/profile/verify
```

---

## 🛠️ **Usage Examples**

### **1. Applying for a Job**
```dart
final serverActions = Provider.of<ServerActions>(context, listen: false);

bool success = await serverActions.applyForJob(
  jobId: 'job123',
  employeeId: 'emp456',
  applicationData: {
    'resumeUrl': 'https://storage.googleapis.com/resume.pdf',
    'coverLetter': 'I am excited about this opportunity...',
    'additionalInfo': {'expectedSalary': '50000'},
  },
);
```

### **2. AI Resume Parsing**
```dart
final aiWorkflows = Provider.of<AIWorkflows>(context, listen: false);

Map<String, dynamic> result = await aiWorkflows.parseResume(
  resumeFileUrl: 'https://storage.googleapis.com/resume.pdf',
);

if (result['success']) {
  final skills = result['skills'] as List<String>;
  final experience = result['experience'] as List<Map<String, dynamic>>;
}
```

### **3. Job Matching**
```dart
final aiWorkflows = Provider.of<AIWorkflows>(context, listen: false);

Map<String, dynamic> match = await aiWorkflows.matchResumeToJob(
  resumeText: 'Experienced software developer...',
  jobDescription: 'Looking for senior developer...',
);

if (match['success']) {
  final score = match['overallScore'] as double;
  final strengths = match['strengths'] as List<String>;
}
```

### **4. Profile Management**
```dart
final profileService = Provider.of<ProfileService>(context, listen: false);

Map<String, dynamic> profile = await profileService.getEmployeeProfile(userId);
final completeness = await profileService.calculateProfileCompleteness(
  userId: userId,
  role: 'employee',
);
```

---

## 🔒 **Security & Permissions**

### **Firebase Security Rules**
- **Document Ownership**: Users can only access their own documents
- **Role-Based Access**: Different permissions for employees vs employers
- **Public Data**: Job postings are publicly readable
- **Private Data**: Applications and profiles are restricted

### **API Security**
- **Firebase Auth Tokens**: All API calls require valid tokens
- **Role Verification**: Backend verifies user roles
- **Rate Limiting**: Prevent API abuse
- **Input Validation**: Sanitize all inputs

---

## 📊 **Database Schema**

### **Collections**
```
employees/
  {userId}/
    - profile data
    - resume data
    - applications

employers/
  {userId}/
    - company data
    - job postings
    - candidates

jobs/
  {jobId}/
    - job details
    - requirements
    - application count

job_applications/
  {applicationId}/
    - applicant info
    - status
    - resume

interviews/
  {interviewId}/
    - scheduling info
    - questions
    - feedback

ai_results/
  {resultId}/
    - parsed resumes
    - match scores
    - generated questions
```

---

## 🚦 **Migration Status**

### ✅ **Completed**
- Backend structure created
- Firebase integration preserved
- AI workflows implemented
- Profile services added
- Server actions implemented
- Provider setup updated

### ⚠️ **Next Steps**
- Start Next.js backend server
- Test API endpoints
- Verify Firebase rules
- Test AI workflows
- Complete integration testing

---

## 🎯 **Benefits of New Structure**

### **1. Scalability**
- Modular architecture
- Separation of concerns
- Easy to extend features
- Efficient data operations

### **2. Maintainability**
- Clear code organization
- Consistent with web app
- Easy debugging
- Comprehensive logging

### **3. Features**
- AI-powered capabilities
- Advanced analytics
- Better user experience
- Enhanced security

### **4. Performance**
- Optimized database operations
- Efficient caching
- Batch operations
- Transaction support

---

## 🔧 **Development Guidelines**

### **Adding New Features**
1. **Backend Logic**: Add to `ServerActions` class
2. **AI Features**: Add to `AIWorkflows` class
3. **Profile Features**: Add to `ProfileService` class
4. **Firebase Operations**: Use `FirebaseService` class

### **Error Handling**
- All methods return proper error messages
- Comprehensive logging with `debugPrint`
- Graceful degradation for failed operations
- User-friendly error messages

### **Testing**
- Test each service independently
- Mock Firebase operations for unit tests
- Test API endpoints with integration tests
- Verify security rules

---

## 📞 **Support & Troubleshooting**

### **Common Issues**
1. **Firebase Connection**: Check configuration in `firebase_options.dart`
2. **API Connection**: Ensure Next.js server is running on `localhost:3000`
3. **AI Features**: Verify AI endpoints are available
4. **Permissions**: Check Firebase security rules

### **Debug Logging**
All services include comprehensive debug logging:
```dart
debugPrint('[ServiceName] Operation description');
```

### **Performance Monitoring**
- Use Firebase Performance Monitoring
- Monitor API response times
- Track AI workflow performance
- Analyze database query efficiency

---

**Your Flutter app now has a complete backend structure matching the web app while preserving all existing functionality!** 🎉
