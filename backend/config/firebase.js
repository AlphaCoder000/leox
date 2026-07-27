const admin = require('firebase-admin');

let initialized = false;
let initError = null;
let initMethod = null;

function isCloudRun() {
  return Boolean(process.env.K_SERVICE || process.env.CLOUD_RUN_JOB);
}

function normalizePrivateKey(rawKey) {
  if (!rawKey || typeof rawKey !== 'string') {
    return undefined;
  }

  let key = rawKey.trim();

  if (
    (key.startsWith('"') && key.endsWith('"')) ||
    (key.startsWith("'") && key.endsWith("'"))
  ) {
    key = key.slice(1, -1);
  }

  // Cloud Run secrets often double-escape or preserve literal backslash-n sequences.
  key = key
    .replace(/\\\\n/g, '\n')
    .replace(/\\n/g, '\n')
    .split(String.raw`\n`)
    .join('\n');

  if (
    !key.includes('BEGIN PRIVATE KEY') &&
    !key.includes('BEGIN RSA PRIVATE KEY')
  ) {
    return undefined;
  }

  return key;
}

function parseServiceAccountJson(rawJson) {
  if (!rawJson) {
    return null;
  }

  if (typeof rawJson === 'object' && rawJson !== null) {
    const normalized = { ...rawJson };
    if (normalized.private_key) {
      normalized.private_key = normalizePrivateKey(normalized.private_key);
    }
    return normalized;
  }

  if (typeof rawJson !== 'string') {
    return null;
  }

  const attempts = [];
  const trimmed = rawJson.trim();

  if (trimmed) {
    attempts.push(trimmed);

    if (
      (trimmed.startsWith('"') && trimmed.endsWith('"')) ||
      (trimmed.startsWith("'") && trimmed.endsWith("'"))
    ) {
      attempts.push(trimmed.slice(1, -1));
    }
  }

  const tryParse = (value) => {
    if (!value || typeof value !== 'string') {
      return null;
    }

    const candidates = [value];

    if (value.includes('\n')) {
      candidates.push(value.replace(/\\n/g, '\n'));
    }

    candidates.push(value.replace(/\r?\n/g, '\\n'));

    for (const candidate of candidates) {
      try {
        const parsed = JSON.parse(candidate);
        if (parsed && typeof parsed === 'object') {
          return parsed;
        }
      } catch (error) {
        // Try the next candidate.
      }
    }

    return null;
  };

  for (const candidate of attempts) {
    const parsed = tryParse(candidate);
    if (parsed) {
      if (parsed.private_key) {
        parsed.private_key = normalizePrivateKey(parsed.private_key);
      }
      return parsed;
    }
  }

  try {
    const decoded = Buffer.from(trimmed, 'base64').toString('utf8');
    const parsed = tryParse(decoded);
    if (parsed) {
      if (parsed.private_key) {
        parsed.private_key = normalizePrivateKey(parsed.private_key);
      }
      return parsed;
    }
  } catch (error) {
    // Ignore and fall through to the generic error below.
  }

  initError = `Failed to parse FIREBASE_SERVICE_ACCOUNT_KEY JSON: ${typeof rawJson === 'string' ? rawJson.slice(0, 80) : String(rawJson)}`;
  return null;
}

function buildServiceAccountFromEnv() {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = normalizePrivateKey(process.env.FIREBASE_PRIVATE_KEY);

  if (!projectId || !clientEmail || !privateKey) {
    return null;
  }

  return {
    projectId,
    clientEmail,
    privateKey,
  };
}

function getProjectId(fallbackProjectId) {
  return (
    process.env.FIREBASE_PROJECT_ID ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    fallbackProjectId
  );
}

function buildAppOptions(projectId, credential) {
  const options = { credential };

  if (projectId) {
    options.projectId = projectId;
    options.storageBucket = `${projectId}.appspot.com`;
  }

  return options;
}

function initializeFirebase() {
  if (initialized || admin.apps.length > 0) {
    initialized = true;
    return true;
  }

  initError = null;
  initMethod = null;

  const preferAdc =
    process.env.FIREBASE_USE_ADC === 'true' ||
    (isCloudRun() && process.env.FIREBASE_USE_SERVICE_ACCOUNT_KEY !== 'true');

  if (preferAdc) {
    try {
      const projectId = getProjectId();
      admin.initializeApp(
        buildAppOptions(projectId, admin.credential.applicationDefault())
      );
      initialized = true;
      initMethod = 'applicationDefault';
      console.log('✅ Firebase Admin SDK initialized with Application Default Credentials');
      return true;
    } catch (error) {
      initError = `ADC initialization failed: ${error.message}`;
      console.warn(`⚠️ ${initError}`);
      if (process.env.FIREBASE_USE_ADC === 'true') {
        return false;
      }
    }
  }

  const jsonCandidates = [
    process.env.FIREBASE_SERVICE_ACCOUNT_KEY,
    process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON,
  ];

  if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY_BASE64) {
    try {
      jsonCandidates.unshift(
        Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_KEY_BASE64, 'base64').toString('utf8')
      );
    } catch (error) {
      initError = `Failed to decode FIREBASE_SERVICE_ACCOUNT_KEY_BASE64: ${error.message}`;
      console.warn(`⚠️ ${initError}`);
    }
  }

  for (const rawJson of jsonCandidates) {
    const serviceAccount = parseServiceAccountJson(rawJson);
    if (!serviceAccount) {
      continue;
    }

    try {
      admin.initializeApp(
        buildAppOptions(getProjectId(serviceAccount.project_id), admin.credential.cert(serviceAccount))
      );
      initialized = true;
      initMethod = 'serviceAccountJson';
      console.log('✅ Firebase Admin SDK initialized from service account JSON');
      return true;
    } catch (error) {
      initError = `Service account JSON initialization failed: ${error.message}`;
      console.warn(`⚠️ ${initError}`);
    }
  }

  const serviceAccount = buildServiceAccountFromEnv();
  if (serviceAccount) {
    try {
      admin.initializeApp(
        buildAppOptions(serviceAccount.projectId, admin.credential.cert(serviceAccount))
      );
      initialized = true;
      initMethod = 'serviceAccountEnv';
      console.log('✅ Firebase Admin SDK initialized from environment variables');
      return true;
    } catch (error) {
      initError = `Service account env initialization failed: ${error.message}`;
      console.error(`❌ ${initError}`);
    }
  } else if (!initError) {
    initError = 'Firebase credentials are missing or the private key PEM is invalid';
    console.warn(`⚠️ ${initError}`);
  }

  console.warn('⚠️ Firebase Admin dependent APIs will run in simulation/mock mode.');
  return false;
}

function isFirebaseInitialized() {
  return initialized || admin.apps.length > 0;
}

function getFirebaseInitStatus() {
  return {
    initialized: isFirebaseInitialized(),
    method: initMethod,
    runtime: isCloudRun() ? 'cloud-run' : 'local',
    projectId: getProjectId(),
    error: initError,
  };
}

async function probeFirebaseConnectivity() {
  if (!isFirebaseInitialized()) {
    return {
      ok: false,
      auth: false,
      firestore: false,
      error: initError || 'Firebase Admin is not initialized',
    };
  }

  const result = {
    ok: false,
    auth: false,
    firestore: false,
    error: null,
  };

  try {
    await admin.auth().listUsers(1);
    result.auth = true;
  } catch (error) {
    result.error = `Auth probe failed: ${error.message}`;
    return result;
  }

  try {
    await admin.firestore().collection('subscription_plans').limit(1).get();
    result.firestore = true;
  } catch (error) {
    result.error = `Firestore probe failed: ${error.message}`;
    return result;
  }

  result.ok = true;
  return result;
}

module.exports = {
  admin,
  initializeFirebase,
  isFirebaseInitialized,
  getFirebaseInitStatus,
  probeFirebaseConnectivity,
};
