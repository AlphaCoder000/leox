const fs = require('fs');
const path = require('path');

const envPath = path.join(__dirname, '..', '.env');
if (!fs.existsSync(envPath)) {
  console.error(`Missing file: ${envPath}`);
  process.exit(1);
}

const text = fs.readFileSync(envPath, 'utf8');
const env = {};
text.split(/\r?\n/).forEach((line) => {
  const trimmed = line.trim();
  if (!trimmed || trimmed.startsWith('#')) return;
  const idx = trimmed.indexOf('=');
  if (idx < 0) return;
  const key = trimmed.slice(0, idx).trim();
  let value = trimmed.slice(idx + 1).trim();
  if (value.startsWith('"') && value.endsWith('"')) {
    value = value.slice(1, -1);
  }
  env[key] = value.replace(/\\n/g, '\n');
});

const account = {
  type: 'service_account',
  project_id: env.FIREBASE_PROJECT_ID,
  private_key_id: env.FIREBASE_PRIVATE_KEY_ID,
  private_key: env.FIREBASE_PRIVATE_KEY,
  client_email: env.FIREBASE_CLIENT_EMAIL,
};

const json = JSON.stringify(account, null, 2);
const base64 = Buffer.from(json, 'utf8').toString('base64');

console.log('=== FIREBASE SERVICE ACCOUNT JSON ===');
console.log(json);
console.log('\n=== FIREBASE_SERVICE_ACCOUNT_KEY_BASE64 ===');
console.log(base64);
console.log('\n=== RENDER ENV VARS TO SET ===');
console.log('FIREBASE_SERVICE_ACCOUNT_KEY_BASE64=' + base64);
if (env.OPENAI_API_KEY) console.log('OPENAI_API_KEY=' + env.OPENAI_API_KEY);
if (env.RAZORPAY_KEY_ID) console.log('RAZORPAY_KEY_ID=' + env.RAZORPAY_KEY_ID);
if (env.RAZORPAY_KEY_SECRET) console.log('RAZORPAY_KEY_SECRET=' + env.RAZORPAY_KEY_SECRET);
console.log('OPENAI_MODEL=gpt-4-turbo');
