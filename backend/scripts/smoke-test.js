/**
 * Smoke test for deployed Cloud Run backend.
 * Usage: node scripts/smoke-test.js [baseUrl]
 */
const admin = require('firebase-admin');

const BASE_URL =
  process.argv[2] ||
  process.env.API_BASE_URL ||
  'https://leox-backend-340682426505.asia-south1.run.app/api';

const FIREBASE_API_KEY = process.env.FIREBASE_WEB_API_KEY || 'AIzaSyBNVp_4-eg-QNAlAWY612osmTcOLVrcGXU';

async function request(method, path, { body, token, rawBody } = {}) {
  const headers = { Accept: 'application/json' };
  let payload;

  if (rawBody !== undefined) {
    payload = rawBody;
    headers['Content-Type'] = 'application/json';
  } else if (body !== undefined) {
    payload = JSON.stringify(body);
    headers['Content-Type'] = 'application/json';
  }

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    body: payload,
  });

  const text = await response.text();
  let json = null;
  try {
    json = text ? JSON.parse(text) : null;
  } catch {
    json = { raw: text };
  }

  return { status: response.status, json };
}

async function getIdTokenForTestUser() {
  admin.initializeApp({ credential: admin.credential.applicationDefault() });

  const uid = `smoke_test_${Date.now()}`;
  try {
    await admin.auth().createUser({ uid, displayName: 'Smoke Test User' });
  } catch (error) {
    if (error.code !== 'auth/uid-already-exists') {
      throw error;
    }
  }

  const customToken = await admin.auth().createCustomToken(uid);
  const signInResponse = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${FIREBASE_API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: customToken, returnSecureToken: true }),
    }
  );

  const signInJson = await signInResponse.json();
  if (!signInResponse.ok) {
    throw new Error(`Failed to exchange custom token: ${JSON.stringify(signInJson)}`);
  }

  return { uid, idToken: signInJson.idToken };
}

async function findActivePlanId() {
  const snapshot = await admin
    .firestore()
    .collection('subscription_plans')
    .where('isActive', '==', true)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return null;
  }

  const doc = snapshot.docs[0];
  return { planId: doc.id, plan: doc.data() };
}

function pass(label, detail = '') {
  console.log(`PASS  ${label}${detail ? ` — ${detail}` : ''}`);
}

function fail(label, detail = '') {
  console.error(`FAIL  ${label}${detail ? ` — ${detail}` : ''}`);
}

async function main() {
  console.log(`Smoke testing ${BASE_URL}\n`);

  let failed = 0;

  const health = await request('GET', '/health?deep=true');
  if (health.status === 200 && health.json?.connectivity?.ok) {
    pass('Health + Firebase connectivity', health.json.firebase.method);
  } else {
    fail('Health + Firebase connectivity', JSON.stringify(health.json));
    failed += 1;
  }

  const setup = await request('GET', '/subscription/admin/setup-status');
  if (setup.status === 200 && setup.json?.success === true) {
    pass('Admin setup-status', `bootstrapMode=${setup.json.bootstrapMode}`);
  } else {
    fail('Admin setup-status', JSON.stringify(setup.json));
    failed += 1;
  }

  const badLogin = await request('POST', '/subscription/admin/login', {
    body: { email: 'nonexistent@example.com', password: 'wrong-password' },
  });
  if (badLogin.status === 401) {
    pass('Admin login rejects invalid credentials');
  } else {
    fail('Admin login rejects invalid credentials', `status=${badLogin.status}`);
    failed += 1;
  }

  const webhookBad = await request('POST', '/subscription/webhook', {
    rawBody: JSON.stringify({ event: 'payment.failed', payload: {} }),
  });
  if (webhookBad.status === 400) {
    pass('Webhook rejects invalid signature');
  } else {
    fail('Webhook rejects invalid signature', `status=${webhookBad.status}`);
    failed += 1;
  }

  console.log('\nAuth-required subscription flow...');

  try {
    const { uid, idToken } = await getIdTokenForTestUser();
    pass('Generated Firebase ID token for smoke user', uid);

    const noAuth = await request('POST', '/subscription/create-order', {
      body: { planId: 'test', billingCycle: 'monthly' },
    });
    if (noAuth.status === 401) {
      pass('Create-order requires auth');
    } else {
      fail('Create-order requires auth', `status=${noAuth.status}`);
      failed += 1;
    }

    const planInfo = await findActivePlanId();
    if (!planInfo) {
      fail('Find active subscription plan in Firestore', 'none found');
      failed += 1;
    } else {
      pass('Found active plan', `${planInfo.planId} (${planInfo.plan.role || 'unknown role'})`);

      const createOrder = await request('POST', '/subscription/create-order', {
        token: idToken,
        body: {
          planId: planInfo.planId,
          billingCycle: 'monthly',
        },
      });

      if (createOrder.status === 200 && createOrder.json?.success === true && createOrder.json?.orderId) {
        pass('Create-order', createOrder.json.orderId);
      } else if (createOrder.status === 400 && createOrder.json?.error?.includes('active subscription')) {
        pass('Create-order blocked for existing active subscription (expected for repeat runs)');
      } else {
        fail('Create-order', JSON.stringify(createOrder.json));
        failed += 1;
      }

      const verifyPayment = await request('POST', '/subscription/verify-payment', {
        token: idToken,
        body: {
          razorpayOrderId: 'order_test_smoke_bypass',
          razorpayPaymentId: 'pay_test_smoke_bypass',
          razorpaySignature: 'simulated',
          planId: planInfo.planId,
          billingCycle: 'monthly',
        },
      });

      if (verifyPayment.status === 200 && verifyPayment.json?.success === true) {
        pass('Verify-payment simulated bypass', verifyPayment.json.message || 'activated');
      } else {
        fail('Verify-payment simulated bypass', JSON.stringify(verifyPayment.json));
        failed += 1;
      }
    }
  } catch (error) {
    fail('Auth-required subscription flow', error.message);
    failed += 1;
  }

  console.log(`\n${failed === 0 ? 'All smoke tests passed.' : `${failed} test(s) failed.`}`);
  process.exit(failed === 0 ? 0 : 1);
}

main().catch((error) => {
  console.error('Smoke test crashed:', error);
  process.exit(1);
});
