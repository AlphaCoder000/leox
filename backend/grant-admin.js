const admin = require('firebase-admin');
const dotenv = require('dotenv');
const path = require('path');

// Load environment configurations
dotenv.config({ path: path.join(__dirname, '.env') });

const serviceAccount = {
  projectId: process.env.FIREBASE_PROJECT_ID,
  privateKey: process.env.FIREBASE_PRIVATE_KEY ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : undefined,
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
};

if (!serviceAccount.projectId || !serviceAccount.privateKey || !serviceAccount.clientEmail) {
  console.error('❌ Error: Missing Firebase credentials in backend/.env file');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const grantAdminAccess = async (email) => {
  try {
    console.log(`Connecting to Firebase Auth to look up email: ${email}...`);
    const user = await admin.auth().getUserByEmail(email);
    
    // Set custom claim admin: true
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    
    console.log(`\n======================================================`);
    console.log(`✅ Success! Granted Admin privileges to: ${email}`);
    console.log(`👤 User UID: ${user.uid}`);
    console.log(`======================================================`);
    console.log(`Instruct the owner to sign out and log back in to their account to apply the claims.`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Error granting admin access:', error.message);
    process.exit(1);
  }
};

// Check if email was passed in command line arguments
const targetEmail = process.argv[2];

if (!targetEmail) {
  console.log('Usage: node grant-admin.js <email>');
  console.log('Example: node grant-admin.js owner@company.com');
  process.exit(1);
}

grantAdminAccess(targetEmail.trim());
