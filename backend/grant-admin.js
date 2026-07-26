const { admin, initializeFirebase } = require('./config/firebase');

initializeFirebase();

if (!admin.apps.length) {
  console.error('❌ Error: Missing Firebase credentials in backend/.env file');
  process.exit(1);
}

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
