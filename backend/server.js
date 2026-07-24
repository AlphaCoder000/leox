const express = require('express');
const cors = require('cors');
const multer = require('multer');
const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

// Initialize Firebase Admin safely
let firebaseAdminInitialized = false;
try {
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;
  if (privateKey && !privateKey.includes('YOUR_PRIVATE_KEY_HERE') && privateKey.trim().length > 50) {
    const serviceAccount = {
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: privateKey.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    };

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: `${process.env.FIREBASE_PROJECT_ID}.appspot.com`,
    });
    firebaseAdminInitialized = true;
    console.log('✅ Firebase Admin SDK initialized successfully');
  } else {
    console.warn('⚠️ Warning: Firebase credentials are not configured or are placeholder in backend/.env');
    console.warn('⚠️ Firebase Admin dependent APIs will run in simulation/mock mode.');
  }
} catch (e) {
  console.error('❌ Failed to initialize Firebase Admin SDK:', e.message);
  console.warn('⚠️ Backend server will run, but Firebase database access is in mock simulation mode.');
}

const app = express();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain'];
    allowedTypes.includes(file.mimetype) ? cb(null, true) : cb(new Error('Invalid file type'), false);
  },
});

// Middleware
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://localhost:8080',
    'http://localhost:8081',
    'http://localhost:8082',
    'http://localhost:8083',
    'http://127.0.0.1:3000',
    'https://leox-backend-340682426505.asia-south1.run.app',
    'https://studio-7488920972-4ef9c.web.app',
    'https://studio-7488920972-4ef9c.firebaseapp.com'
  ],
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use('/uploads', express.static('uploads'));
app.use('/api/subscription', require('./routes/subscription'));

// Routes
app.post('/api/parse-resume', upload.single('resume'), async (req, res) => {
  try {
    const { file } = req;
    
    if (!file) {
      return res.status(400).json({ success: false, error: 'No file uploaded' });
    }

    // Upload file to Firebase Storage
    const fileName = `resume_${Date.now()}_${file.originalname}`;
    const bucket = admin.storage().bucket();
    const fileUpload = bucket.file(fileName);

    const stream = fileUpload.createWriteStream({
      metadata: {
        contentType: file.mimetype,
        metadata: {
          originalName: file.originalname,
          uploadedAt: new Date().toISOString(),
        },
      },
    });

    stream.end(file.buffer);

    // Get file URL
    const [fileUrl] = await fileUpload.getSignedUrl({
      action: 'read',
      expires: '03-01-2025', // 1 year expiry
    });

    // Parse resume (mock implementation - replace with actual AI parsing)
    const mockParsedData = {
      success: true,
      personalInfo: {
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1-555-123-4567',
        location: 'New York, NY',
      },
      education: [
        {
          degree: 'Bachelor of Science',
          school: 'University of Example',
          year: '2020',
        },
      ],
      experience: [
        {
          title: 'Senior Software Engineer',
          company: 'Tech Corp',
          duration: '3 years',
          description: 'Led development of mobile applications...',
        },
      ],
      skills: ['JavaScript', 'React', 'Node.js', 'Python', 'MongoDB', 'Git'],
      projects: [
        {
          name: 'E-commerce Platform',
          description: 'Built a full-stack e-commerce solution...',
        },
      ],
      certifications: ['AWS Certified Developer', 'Google Cloud Professional'],
      languages: ['English', 'Spanish'],
      summary: 'Experienced software engineer with 5+ years in full-stack development...',
      confidence: 0.92,
    };

    res.json(mockParsedData);

  } catch (error) {
    console.error('Error parsing resume:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to parse resume',
      details: error.message 
    });
  }
});

app.post('/api/match-resume', upload.single('resume'), async (req, res) => {
  try {
    const { file } = req;
    const { jobDescription } = req.body;
    
    if (!file && !jobDescription) {
      return res.status(400).json({ 
        success: false, 
        error: 'Resume file and job description are required' 
      });
    }

    // Mock AI matching (replace with actual OpenAI integration)
    const mockMatchResult = {
      success: true,
      overallScore: 85.5,
      skillsMatch: 90.0,
      experienceMatch: 80.0,
      educationMatch: 75.0,
      analysis: 'Strong candidate with relevant experience in React and Node.js. The candidate\'s technical skills align well with the job requirements. Experience shows progression and leadership potential. Education background is suitable but could benefit from additional certifications.',
      strengths: [
        'Strong technical foundation in modern web technologies',
        'Relevant industry experience',
        'Good communication skills demonstrated through project work',
      ],
      gaps: [
        'Limited experience with cloud architecture at scale',
        'No formal leadership experience in current role',
        'Missing some advanced certifications',
      ],
      recommendations: [
        'Consider pursuing AWS Solutions Architect certification',
        'Highlight team leadership experience in resume',
        'Add cloud deployment projects to portfolio',
        'Obtain Scrum Master certification',
      ],
      matchedSkills: ['JavaScript', 'React', 'Node.js', 'Python', 'MongoDB'],
      missingSkills: ['Docker', 'Kubernetes', 'TypeScript'],
    };

    res.json(mockMatchResult);

  } catch (error) {
    console.error('Error matching resume:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to match resume',
      details: error.message 
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    details: err.message
  });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 LeoRecruit Backend Server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
});
