const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

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
  origin: ['http://localhost:3000', 'http://localhost:8080', 'http://127.0.0.1:3000'],
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use('/uploads', express.static('uploads'));

// Create uploads directory if it doesn't exist
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

// Routes
app.post('/api/parse-resume', upload.single('resume'), async (req, res) => {
  try {
    const { file } = req;
    
    if (!file) {
      return res.status(400).json({ success: false, error: 'No file uploaded' });
    }

    console.log(`📄 Resume uploaded: ${file.originalname} (${file.size} bytes)`);

    // Save file locally
    const fileName = `resume_${Date.now()}_${file.originalname}`;
    const filePath = path.join('uploads', fileName);
    fs.writeFileSync(filePath, file.buffer);

    // Mock AI parsing - replace with actual AI service
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
          degree: 'Bachelor of Science in Computer Science',
          school: 'University of Technology',
          year: '2020',
          gpa: '3.8/4.0',
        },
      ],
      experience: [
        {
          title: 'Senior Software Engineer',
          company: 'Tech Corp',
          duration: '3 years',
          description: 'Led development of mobile applications using React Native and Node.js. Managed team of 5 developers and improved app performance by 40%.',
        },
        {
          title: 'Software Developer',
          company: 'StartUp Inc',
          duration: '2 years',
          description: 'Developed full-stack web applications using React, Node.js, and MongoDB. Implemented RESTful APIs and optimized database queries.',
        },
      ],
      skills: ['JavaScript', 'React', 'Node.js', 'Python', 'MongoDB', 'Git', 'Docker', 'AWS', 'TypeScript'],
      projects: [
        {
          name: 'E-commerce Platform',
          description: 'Built a full-stack e-commerce solution with payment integration, user authentication, and admin dashboard.',
          technologies: ['React', 'Node.js', 'MongoDB', 'Stripe'],
        },
        {
          name: 'Mobile Banking App',
          description: 'Developed secure mobile banking application with biometric authentication and real-time transaction updates.',
          technologies: ['React Native', 'Node.js', 'PostgreSQL'],
        },
      ],
      certifications: ['AWS Certified Developer', 'Google Cloud Professional', 'Certified Kubernetes Administrator'],
      languages: ['English', 'Spanish', 'Mandarin'],
      summary: 'Experienced software engineer with 5+ years in full-stack development, specializing in React, Node.js, and cloud technologies. Strong background in building scalable applications and leading development teams.',
      confidence: 0.92,
    };

    console.log(`✅ Resume parsed successfully for ${mockParsedData.personalInfo.name}`);
    res.json(mockParsedData);

  } catch (error) {
    console.error('❌ Error parsing resume:', error);
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

    console.log(`🎯 Matching resume against job description...`);
    console.log(`📝 Job description length: ${jobDescription?.length || 0} characters`);

    // Mock AI matching - replace with actual AI service
    const mockMatchResult = {
      success: true,
      overallScore: 85.5,
      skillsMatch: 90.0,
      experienceMatch: 80.0,
      educationMatch: 75.0,
      analysis: 'Strong candidate with relevant experience in React and Node.js. The candidate demonstrates excellent technical skills and a solid educational background. Experience shows clear progression and leadership potential. The candidate\'s skills align well with 90% of the job requirements, particularly in frontend and backend development. Missing some advanced cloud architecture experience but has foundational knowledge that can be quickly developed.',
      strengths: [
        'Strong technical foundation in modern web technologies',
        'Relevant industry experience with progressive responsibility',
        'Excellent communication skills demonstrated through project work',
        'Leadership experience in managing development teams',
        'Continuous learning through certifications',
      ],
      gaps: [
        'Limited experience with large-scale cloud architecture',
        'No formal experience with microservices architecture',
        'Missing some advanced certifications in cloud platforms',
        'Limited experience with DevOps practices',
      ],
      recommendations: [
        'Consider pursuing AWS Solutions Architect certification to strengthen cloud credentials',
        'Highlight team leadership and project management experience in resume',
        'Add cloud deployment and DevOps projects to portfolio',
        'Obtain Scrum Master certification to demonstrate agile methodology expertise',
        'Gain experience with containerization and orchestration tools',
      ],
      matchedSkills: ['JavaScript', 'React', 'Node.js', 'Python', 'MongoDB', 'Git', 'TypeScript'],
      missingSkills: ['Kubernetes', 'Terraform', 'Jenkins', 'GraphQL', 'Redis'],
    };

    console.log(`✅ Resume matching completed with score: ${mockMatchResult.overallScore}%`);
    res.json(mockMatchResult);

  } catch (error) {
    console.error('❌ Error matching resume:', error);
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
    version: '1.0.0',
    message: 'LeoRecruit AI Resume Matcher Backend is running'
  });
});

// Test endpoint
app.get('/api/test', (req, res) => {
  res.json({ 
    message: 'Backend is working!',
    timestamp: new Date().toISOString(),
    endpoints: [
      'POST /api/parse-resume - Parse resume files',
      'POST /api/match-resume - Match resume to job description',
      'GET /api/health - Health check'
    ]
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('❌ Unhandled error:', err);
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
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🧪 Test endpoint: http://localhost:${PORT}/api/test`);
  console.log(`📄 Ready to receive resume uploads and AI matching requests!`);
});
