# LeoRecruit Backend Server

Backend API server for LeoRecruit AI Resume Matcher application.

## 🚀 Quick Start

### Prerequisites
- Node.js (v14 or higher)
- npm or yarn
- Firebase project with Admin SDK configured

### Installation

1. **Install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Configure environment variables:**
   Copy `.env.example` to `.env` and update with your Firebase and OpenAI credentials:
   ```env
   FIREBASE_PROJECT_ID=your-firebase-project-id
   FIREBASE_PRIVATE_KEY_ID=your-private-key-id
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@xxxxx.iam.gserviceaccount.com
   OPENAI_API_KEY=your-openai-api-key-here
   OPENAI_MODEL=gpt-4-turbo
   PORT=3000
   NODE_ENV=development
   ```

3. **Start the server:**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

## 📡 API Endpoints

### POST /api/parse-resume
Parses uploaded resume file and extracts structured data.

**Request:** `multipart/form-data`
- `resume`: Resume file (PDF, DOC, TXT)

**Response:**
```json
{
  "success": true,
  "personalInfo": {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1-555-123-4567",
    "location": "New York, NY"
  },
  "education": [...],
  "experience": [...],
  "skills": [...],
  "projects": [...],
  "certifications": [...],
  "languages": [...],
  "summary": "Experienced software engineer...",
  "confidence": 0.92
}
```

### POST /api/match-resume
Matches resume against job description using AI.

**Request:** `multipart/form-data`
- `resume`: Resume file
- `jobDescription`: Job description text

**Response:**
```json
{
  "success": true,
  "overallScore": 85.5,
  "skillsMatch": 90.0,
  "experienceMatch": 80.0,
  "educationMatch": 75.0,
  "analysis": "Detailed AI analysis...",
  "strengths": [...],
  "gaps": [...],
  "recommendations": [...],
  "matchedSkills": [...],
  "missingSkills": [...]
}
```

### GET /api/health
Health check endpoint.

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2024-02-20T12:00:00.000Z",
  "version": "1.0.0"
}
```

## 🔧 Configuration

### Firebase Setup
1. Go to Firebase Console → Project Settings → Service Accounts
2. Generate a new private key
3. Download the JSON file and copy credentials to `.env`
4. Enable Cloud Storage API

### OpenAI Setup
1. Create OpenAI account
2. Generate API key
3. Add API key to `.env`
4. Choose appropriate model (gpt-4-turbo recommended)

## 🗂️ File Structure

```
backend/
├── package.json
├── server.js
├── .env
├── .env.example
├── uploads/
├── README.md
└── node_modules/
```

## 🧪 Features

- ✅ Resume file upload (PDF, DOC, TXT)
- ✅ Firebase Storage integration
- ✅ AI-powered resume parsing (mock)
- ✅ AI-powered job matching (mock)
- ✅ CORS support for Flutter app
- ✅ Error handling and logging
- ✅ Health check endpoint

## 🔒 Security

- File size limits (5MB max)
- File type validation
- CORS configuration
- Environment variable protection
- Firebase security rules integration

## 📝 Development Notes

- Current implementation uses mock AI responses
- Replace mock implementations with actual OpenAI API calls
- Add proper error logging
- Implement rate limiting for production
- Add input validation and sanitization

## 🚀 Deployment

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

### Environment Variables
- `NODE_ENV=development` - Development mode
- `NODE_ENV=production` - Production mode
- `PORT=3000` - Server port
- Firebase credentials required
- OpenAI API key required
