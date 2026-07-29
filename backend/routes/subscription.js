const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const crypto = require('crypto');
const Razorpay = require('razorpay');

// Initialize Razorpay Client (Credentials must be set in backend/.env)
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || 'rzp_test_dummykeyid',
  key_secret: process.env.RAZORPAY_KEY_SECRET || 'dummyprivatesecretkey',
});

// Get Firestore client only if Firebase app has been initialized
const db = admin.apps.length > 0 ? admin.firestore() : null;

// ================= MIDDLEWARE =================

// Authenticate user with Firebase ID Token
const requireAuth = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: 'Unauthorized: Missing token' });
  }
  const token = authHeader.split('Bearer ')[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('[AuthMiddleware] Invalid token:', error.message);
    return res.status(401).json({ success: false, error: 'Unauthorized: Invalid token' });
  }
};

// Enforce admin custom claims
const requireAdmin = async (req, res, next) => {
  await requireAuth(req, res, () => {
    if (req.user && req.user.admin === true) {
      next();
    } else {
      return res.status(403).json({ success: false, error: 'Forbidden: Admin access required' });
    }
  });
};

// ================= USER ENDPOINTS =================

/**
 * 1. Create Checkout Order
 * Generates a Razorpay Order ID for plans
 */
router.post('/create-order', requireAuth, async (req, res) => {
  try {
    const { planId, billingCycle, couponCode, gstNumber } = req.body;
    const userId = req.user.uid;

    if (!planId || !billingCycle) {
      return res.status(400).json({ success: false, error: 'planId and billingCycle (monthly/yearly) are required' });
    }

    // 1. Fetch Plan Details from Firestore
    if (db) {
      const planDoc = await db.collection('subscription_plans').doc(planId).get();
      if (!planDoc.exists) {
        return res.status(404).json({ success: false, error: 'Subscription plan not found' });
      }

      const planData = planDoc.data();
      if (!planData.isActive) {
        return res.status(400).json({ success: false, error: 'This subscription plan is currently disabled' });
      }

      const role = planData.role || 'employee';

      // Check if user already has an active subscription for this specific role in Firestore
      const subDocId = `${userId}_${role}`;
      const subDoc = await db.collection('subscriptions').doc(subDocId).get();
      if (subDoc.exists) {
        const subData = subDoc.data();
        const now = new Date();
        // Support both Firestore Timestamps and ISO strings
        const endDate = subData.endDate 
          ? (subData.endDate.toDate ? subData.endDate.toDate() : new Date(subData.endDate))
          : null;
        if (subData.status === 'active' && endDate && endDate > now) {
          return res.status(400).json({ 
            success: false, 
            error: 'You already have an active subscription.' 
          });
        }
      }
    }

    if (!db) {
      console.log('[Simulated] Firebase Admin not initialized. Creating mock payment order.');
      const amountInPaise = billingCycle === 'yearly' ? 499900 : 49900;
      return res.json({
        success: true,
        orderId: 'order_simulated_' + Math.random().toString(36).substring(2, 9),
        amount: amountInPaise,
        currency: 'INR',
      });
    }

    // 1. Fetch Plan Details from Firestore
    const planDoc = await db.collection('subscription_plans').doc(planId).get();
    const planData = planDoc.data();

    // Determine base price
    let basePrice = billingCycle === 'yearly' ? planData.yearlyPrice : planData.monthlyPrice;
    let finalPrice = basePrice;

    // 2. Validate & Apply Coupon if present
    let appliedCoupon = null;
    if (couponCode) {
      const couponDoc = await db.collection('coupons').doc(couponCode).get();
      if (couponDoc.exists) {
        const couponData = couponDoc.data();
        const now = admin.firestore.Timestamp.now();

        const role = planData.role || 'employee';
        const applicableRoles = couponData.applicableRoles || [];
        const isRoleValid = applicableRoles.length === 0 || applicableRoles.includes(role);

        // Normalize both sides to lowercase for comparison to handle legacy data like 'Employer'
        const applicablePlansLower = (couponData.applicablePlans || []).map(p => p.toLowerCase());
        const isPlanValid = applicablePlansLower.length === 0 || applicablePlansLower.includes(planId.toLowerCase());

        if (
          couponData.isActive &&
          couponData.expiryDate.toDate() > now.toDate() &&
          couponData.useCount < couponData.maxUses &&
          isPlanValid &&
          isRoleValid
        ) {
          appliedCoupon = couponData;
          if (couponData.discountType === 'percentage') {
            finalPrice = basePrice - (basePrice * (couponData.discountValue / 100));
          } else {
            finalPrice = Math.max(0, basePrice - couponData.discountValue);
          }
        }
      }
    }

    // Razorpay amount is in lowest currency unit (paise for INR)
    const amountInPaise = Math.round(finalPrice * 100);

    if (amountInPaise < 100 && amountInPaise > 0) {
      return res.status(400).json({
        success: false,
        error: 'Razorpay minimum transaction amount is 100 paise (INR 1.00). Please apply a coupon or choose a different billing cycle.',
      });
    }

    if (amountInPaise <= 0) {
      // 100% discount, bypass payment gateway
      return res.json({
        success: true,
        orderId: 'free_plan_bypass',
        amount: 0,
        currency: planData.currency,
      });
    }

    // 3. Generate Razorpay Order
    const options = {
      amount: amountInPaise,
      currency: planData.currency || 'INR',
      receipt: `rcpt_${userId}_${Date.now().toString().slice(-8)}`,
      notes: {
        userId: userId,
        planId: planId,
        billingCycle: billingCycle,
        couponCode: couponCode || '',
        gstNumber: gstNumber || '',
      },
    };

    const hasRealKeys = process.env.RAZORPAY_KEY_ID && 
                        !process.env.RAZORPAY_KEY_ID.includes('dummy') &&
                        process.env.RAZORPAY_KEY_ID.startsWith('rzp_');
    const isLiveMode = hasRealKeys && process.env.RAZORPAY_KEY_ID.startsWith('rzp_live_');

    if (hasRealKeys) {
      try {
        const order = await razorpay.orders.create(options);
        res.json({
          success: true,
          orderId: order.id,
          amount: order.amount,
          currency: order.currency,
          key: process.env.RAZORPAY_KEY_ID,
          isSimulated: false,
        });
      } catch (rzpError) {
        console.error('[CreateOrder] Razorpay API error:', rzpError);
        
        // If it's live keys, do NOT fall back to simulation - return 500 error instead
        if (isLiveMode) {
          return res.status(500).json({
            success: false,
            error: 'Razorpay order creation failed. Please try again.',
            details: rzpError.message,
          });
        }

        // Fallback to simulation only if using test keys and Razorpay call fails
        res.json({
          success: true,
          orderId: 'order_test_' + Math.random().toString(36).substring(2, 9),
          amount: amountInPaise,
          currency: planData.currency || 'INR',
          key: process.env.RAZORPAY_KEY_ID,
          isSimulated: true,
          warning: 'Razorpay API failed, using simulation: ' + (rzpError.error?.description || rzpError.message),
        });
      }
    } else {
      console.warn('⚠️ Warning: Using dummy Razorpay key. Simulating Razorpay order creation.');
      res.json({
        success: true,
        orderId: 'order_test_' + Math.random().toString(36).substring(2, 9),
        amount: amountInPaise,
        currency: planData.currency || 'INR',
        key: process.env.RAZORPAY_KEY_ID || 'rzp_test_dummykeyid',
        isSimulated: true,
      });
    }

  } catch (error) {
    console.error('[CreateOrder] Error creating checkout order:', error);
    res.status(500).json({ success: false, error: 'Failed to initiate checkout transaction', details: error.message });
  }
});

/**
 * 2. Verify Payment & Activate
 * Checks checkout signature, records invoice, and updates subscription state.
 */
router.post('/verify-payment', requireAuth, async (req, res) => {
  try {
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature, planId, billingCycle, couponCode, gstNumber } = req.body;
    const userId = req.user.uid;

    if (!db) {
      console.log('[Simulated] Firebase Admin not initialized. Verifying mock payment.');
      return res.json({
        success: true,
        message: 'Payment verified and subscription activated (simulation mode).',
        subscription: {
          userId: userId,
          planId: planId,
          role: 'employer',
          status: 'active',
          trialUsed: true,
          startDate: new Date().toISOString(),
          endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        }
      });
    }

    const isLiveMode = process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_ID.startsWith('rzp_live_');

    // Direct activation if free bypass or simulated test bypass
    if (razorpayOrderId === 'free_plan_bypass' || razorpayOrderId.startsWith('order_test_')) {
      const isSim = razorpayOrderId.startsWith('order_test_');
      
      // If we are in live/production mode, block simulated test bypasses
      if (isSim && isLiveMode) {
        console.warn(`[VerifyPayment] Blocked simulated payment attempt in Live mode for user ${userId}`);
        return res.status(400).json({
          success: false,
          error: 'Simulated payments are not allowed in Live production mode.',
        });
      }

      await activateUserSubscription(
        userId, 
        planId, 
        billingCycle, 
        isSim ? 'simulated_bypass' : 'free_bypass', 
        razorpayPaymentId || 'pay_simulated', 
        couponCode
      );
      return res.json({ 
        success: true, 
        message: isSim 
          ? 'Subscription activated (simulated test bypass)' 
          : 'Subscription activated (free discount bypass)' 
      });
    }

    if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature || !planId || !billingCycle) {
      return res.status(400).json({ success: false, error: 'Missing payment signature verification properties' });
    }

    // 1. Verify Signature
    const keySecret = process.env.RAZORPAY_KEY_SECRET || 'dummyprivatesecretkey';
    const generated_signature = crypto
      .createHmac('sha256', keySecret)
      .update(razorpayOrderId + '|' + razorpayPaymentId)
      .digest('hex');

    if (generated_signature !== razorpaySignature) {
      console.warn('[VerifyPayment] Invalid Razorpay signature detected');
      return res.status(400).json({ success: false, error: 'Signature verification failed. Potential tampering.' });
    }

    // 2. Fetch Plan & Coupon to record price details
    const planDoc = await db.collection('subscription_plans').doc(planId).get();
    if (!planDoc.exists) {
      return res.status(404).json({ success: false, error: 'Plan details not found' });
    }
    const planData = planDoc.data();
    let price = billingCycle === 'yearly' ? planData.yearlyPrice : planData.monthlyPrice;
    
    // 3. Record Payment transaction
    await db.collection('payments').doc(razorpayPaymentId).set({
      id: razorpayPaymentId,
      userId: userId,
      amount: price,
      currency: planData.currency || 'INR',
      status: 'captured',
      planId: planId,
      razorpayOrderId: razorpayOrderId,
      razorpaySignature: razorpaySignature,
      couponUsed: couponCode || null,
      gstNumber: gstNumber || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 4. Update coupon count if applicable
    if (couponCode) {
      await db.collection('coupons').doc(couponCode).update({
        useCount: admin.firestore.FieldValue.increment(1),
      }).catch(() => {});
    }

    // 5. Activate User Subscription
    const subscription = await activateUserSubscription(userId, planId, billingCycle, 'razorpay', razorpayPaymentId, couponCode);

    res.json({
      success: true,
      message: 'Payment successfully captured and subscription active.',
      subscription: subscription,
    });

  } catch (error) {
    console.error('[VerifyPayment] Error verifying checkout payment:', error);
    res.status(500).json({ success: false, error: 'Failed to verify transaction signature', details: error.message });
  }
});

// Helper function to activate/extend subscription
async function activateUserSubscription(userId, planId, billingCycle, gateway, paymentId, couponCode) {
  const planDoc = await db.collection('subscription_plans').doc(planId).get();
  const planData = planDoc.data();

  const now = new Date();
  const endDate = new Date();
  if (billingCycle === 'yearly') {
    endDate.setFullYear(now.getFullYear() + 1);
  } else {
    endDate.setMonth(now.getMonth() + 1);
  }

  // Check coupon for trial extension
  let trialDaysToAdd = 0;
  if (couponCode) {
    const couponDoc = await db.collection('coupons').doc(couponCode).get();
    if (couponDoc.exists) {
      trialDaysToAdd = couponDoc.data().trialExtensionDays || 0;
    }
  }
  if (trialDaysToAdd > 0) {
    endDate.setDate(endDate.getDate() + trialDaysToAdd);
  }

  const subPayload = {
    userId: userId,
    planId: planId,
    role: planData.role,
    status: 'active',
    trialUsed: true,
    startDate: admin.firestore.Timestamp.fromDate(now),
    endDate: admin.firestore.Timestamp.fromDate(endDate),
    paymentGateway: gateway,
    paymentId: paymentId,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const docId = `${userId}_${planData.role || 'employee'}`;
  await db.collection('subscriptions').doc(docId).set(subPayload, { merge: true });
  return subPayload;
}

// ================= RAZORPAY WEBHOOK =================

/**
 * 3. Webhook Receiver
 * Handles notifications for failed charges, subscription renewals, refunds
 */
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || 'dummywebhooksecret';
  const signature = req.headers['x-razorpay-signature'];

  try {
    const expectedSignature = crypto
      .createHmac('sha256', webhookSecret)
      .update(typeof req.body === 'string' ? req.body : JSON.stringify(req.body))
      .digest('hex');

    if (expectedSignature !== signature) {
      console.warn('[Webhook] Warning: Invalid webhook signature detected');
      return res.status(400).send('Invalid signature');
    }

    const event = req.body.event;
    const payload = req.body.payload;

    console.log(`[Webhook] Received Razorpay event: ${event}`);

    // Parse event details and execute updates
    if (event === 'payment.failed') {
      const payment = payload.payment.entity;
      const orderNotes = payment.notes || {};
      const userId = orderNotes.userId;

      if (userId) {
        // Record failed transaction log
        await db.collection('payments').doc(payment.id).set({
          id: payment.id,
          userId: userId,
          amount: payment.amount / 100,
          currency: payment.currency,
          status: 'failed',
          errorDescription: payment.error_description || 'Unknown check error',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    } else if (event === 'refund.processed') {
      const refund = payload.refund.entity;
      const paymentId = refund.payment_id;

      // Update payment record in Firestore
      const paymentSnap = await db.collection('payments').where('id', '==', paymentId).limit(1).get();
      if (!paymentSnap.empty) {
        const payDoc = paymentSnap.docs[0];
        await payDoc.ref.update({
          status: 'refunded',
          refundDetails: {
            refundId: refund.id,
            amount: refund.amount / 100,
            refundedAt: admin.firestore.Timestamp.fromDate(new Date()),
          }
        });
      }
    }

    res.send('OK');

  } catch (error) {
    console.error('[Webhook] Failed to process incoming Razorpay event:', error);
    res.status(500).send('Webhook Processing Error');
  }
});

// ================= ADMIN ACTIONS =================

// --- PBKDF2 HASHING HELPERS ---
function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, storedValue) {
  if (!storedValue || !storedValue.includes(':')) return false;
  const [salt, originalHash] = storedValue.split(':');
  const hash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
  return hash === originalHash;
}

/**
 * 3.5. Grant Admin Role Endpoint
 * Allows existing administrators to securely add/remove other administrators
 */
router.post('/admin/grant-role', requireAdmin, async (req, res) => {
  try {
    const { email, isAdmin } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, error: 'email is required' });
    }

    if (!db) {
      console.log(`[Simulated] Firebase Admin not initialized. Simulating admin role change for ${email}`);
      return res.json({
        success: true,
        message: `Successfully set admin claim for ${email} to ${isAdmin} (Simulation mode)`
      });
    }

    const docId = 'admin_' + email.trim().toLowerCase().replace(/[^a-zA-Z0-9]/g, '_');

    if (isAdmin) {
      return res.status(400).json({
        success: false,
        error: 'Creating an admin requires assigning a password. Please use the "Create Admin" panel.'
      });
    } else {
      // Revoking admin is simply deleting their credentials document
      await db.collection('admins').doc(docId).delete();
    }

    res.json({
      success: true,
      message: `Successfully set admin status for ${email} to ${isAdmin}`
    });
  } catch (error) {
    console.error('[GrantRole] Error:', error);
    res.status(500).json({ success: false, error: 'Failed to update user admin status', details: error.message });
  }
});

/**
 * 3.6. Check Admin Setup Status Endpoint
 * Returns whether the system has zero admins (allowing initial bootstrap registration)
 */
router.get('/admin/setup-status', async (req, res) => {
  try {
    if (!db) {
      return res.json({ success: true, bootstrapMode: true });
    }
    const adminsSnap = await db.collection('admins').limit(1).get();
    res.json({ success: true, bootstrapMode: adminsSnap.empty });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * 3.6.1. Admin Login Endpoint
 * Verifies custom credentials and returns a Firebase Custom Token
 */
router.post('/admin/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'Email and password are required' });
    }

    if (!db) {
      console.log(`[Simulated] Firebase Admin not initialized. Simulating admin login for ${email}`);
      return res.json({
        success: true,
        customToken: 'mock_custom_token_for_simulation'
      });
    }

    const docId = 'admin_' + email.trim().toLowerCase().replace(/[^a-zA-Z0-9]/g, '_');
    const doc = await db.collection('admins').doc(docId).get();

    if (!doc.exists) {
      return res.status(401).json({ success: false, error: 'Invalid email or password' });
    }

    const adminData = doc.data();
    const isMatch = verifyPassword(password, adminData.passwordHash);

    if (!isMatch) {
      return res.status(401).json({ success: false, error: 'Invalid email or password' });
    }

    // Generate Firebase Custom Token mapped to unique admin docId with claim admin = true
    const customToken = await admin.auth().createCustomToken(docId, { admin: true });

    res.json({
      success: true,
      customToken: customToken
    });
  } catch (error) {
    console.error('[AdminLogin] Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * 3.7. Register Admin Endpoint
 * Allows initial owner registration (if no admins exist) or secure admin-to-admin creation.
 */
router.post('/admin/register', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'email and password are required' });
    }

    if (!db) {
      console.log(`[Simulated] Firebase Admin not initialized. Simulating admin registration for ${email}`);
      return res.json({
        success: true,
        message: `[Simulated] Registered admin ${email}`
      });
    }

    // Check if there are any admins in the system
    const adminsSnap = await db.collection('admins').limit(1).get();
    const noAdminsExist = adminsSnap.empty;

    let isAuthorized = false;

    if (noAdminsExist) {
      // Bootstrap mode: allow anyone to create the first admin
      isAuthorized = true;
      console.log(`[Register] System has no administrators. Bootstrapping first admin: ${email}`);
    } else {
      // Invite mode: require the requester to be an existing administrator
      const authHeader = req.headers.authorization;
      if (authHeader && authHeader.startsWith('Bearer ')) {
        const idToken = authHeader.split('Bearer ')[1];
        try {
          const decodedToken = await admin.auth().verifyIdToken(idToken);
          if (decodedToken.admin === true) {
            isAuthorized = true;
          }
        } catch (err) {
          console.error('[Register] Token verification failed:', err);
        }
      }
    }

    if (!isAuthorized) {
      return res.status(403).json({
        success: false,
        error: 'Forbidden: You must be an administrator to create new admin accounts.'
      });
    }

    // Register securely in Firestore admins collection with hashed password
    const docId = 'admin_' + email.trim().toLowerCase().replace(/[^a-zA-Z0-9]/g, '_');
    
    await db.collection('admins').doc(docId).set({
      email: email.trim().toLowerCase(),
      passwordHash: hashPassword(password),
      grantedAt: admin.firestore.FieldValue.serverTimestamp(),
      grantedBy: noAdminsExist ? 'system_bootstrap' : 'admin_invitation',
    });

    res.json({
      success: true,
      message: `Admin account ${email} created successfully.`
    });
  } catch (error) {
    console.error('[AdminRegister] Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * 4. Admin Override Endpoint
 * Allows administrators to manually grant, cancel, extend, or reset subscriptions
 */
router.post('/admin/modify', requireAdmin, async (req, res) => {
  try {
    const { userId, action, extensionDays, planId, reason } = req.body;
    const adminId = req.user.uid;

    if (!userId || !action) {
      return res.status(400).json({ success: false, error: 'userId and action are required' });
    }

    if (!db) {
      console.log('[Simulated] Firebase Admin not initialized. Simulating admin action.');
      return res.json({
        success: true,
        message: `Admin action '${action}' simulated successfully.`
      });
    }

    // Parse userId and role if format is userId_role
    let docId = userId;
    let rawUserId = userId;
    let docRole = null;
    if (userId.includes('_')) {
      const parts = userId.split('_');
      rawUserId = parts[0];
      docRole = parts[1];
    }

    const subRef = db.collection('subscriptions').doc(docId);
    const subDoc = await subRef.get();

    if (action === 'grant_complimentary') {
      if (!planId) {
        return res.status(400).json({ success: false, error: 'planId is required to grant subscription' });
      }
      
      const planDoc = await db.collection('subscription_plans').doc(planId).get();
      if (!planDoc.exists) return res.status(404).json({ success: false, error: 'Plan not found' });
      const planData = planDoc.data();

      const startDate = new Date();
      const endDate = new Date();
      endDate.setDate(startDate.getDate() + (extensionDays || 365)); // Default 1 year

      const subPayload = {
        userId: rawUserId,
        planId: planId,
        role: docRole || planData.role,
        status: 'active',
        isComplimentary: true,
        trialUsed: true,
        startDate: admin.firestore.Timestamp.fromDate(startDate),
        endDate: admin.firestore.Timestamp.fromDate(endDate),
        reason: reason || 'Granted by Admin',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await subRef.set(subPayload, { merge: true });
      return res.json({ success: true, message: 'Complimentary subscription successfully granted', subscription: subPayload });
    }

    if (!subDoc.exists) {
      return res.status(404).json({ success: false, error: 'User does not have an existing subscription record' });
    }

    const subData = subDoc.data();

    if (action === 'extend') {
      if (!extensionDays) return res.status(400).json({ success: false, error: 'extensionDays is required' });
      
      const currentEndDate = subData.endDate.toDate();
      currentEndDate.setDate(currentEndDate.getDate() + extensionDays);

      const updateData = {
        endDate: admin.firestore.Timestamp.fromDate(currentEndDate),
        manualExtensions: admin.firestore.FieldValue.arrayUnion({
          days: extensionDays,
          grantedBy: adminId,
          reason: reason || 'Extended manually',
          date: admin.firestore.Timestamp.fromDate(new Date()),
        }),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await subRef.update(updateData);
      return res.json({ success: true, message: `Subscription extended by ${extensionDays} days` });

    } else if (action === 'cancel') {
      await subRef.update({
        status: 'cancelled',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return res.json({ success: true, message: 'Subscription successfully cancelled' });

    } else if (action === 'suspend') {
      await subRef.update({
        status: 'suspended',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return res.json({ success: true, message: 'Subscription suspended' });

    } else if (action === 'reset_trial') {
      await subRef.update({
        status: 'trial',
        trialUsed: false,
        startDate: admin.firestore.FieldValue.serverTimestamp(),
        endDate: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)), // 30 Days trial
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return res.json({ success: true, message: 'Free trial successfully reset to 30 days' });
    }

    res.status(400).json({ success: false, error: `Invalid action specified: ${action}` });

  } catch (error) {
    console.error('[AdminModify] Error modifying subscription:', error);
    res.status(500).json({ success: false, error: 'Failed to process admin subscription changes', details: error.message });
  }
});

const seedPlans = async () => {
  try {
    if (!db) {
      console.warn('[Seeding] Skipping database plans seeding - Firebase Admin not initialized.');
      return;
    }
    console.log('[Seeding] Ensuring default and free trial subscription plans exist in Firestore...');
    const defaultPlans = [
      {
        id: 'employer_monthly',
        name: 'Employer Premium Plan',
        role: 'employer',
        description: 'Recruitment access & AI candidate matching with job posting tools.',
        monthlyPrice: 199.00,
        yearlyPrice: 1999.00,
        currency: 'INR',
        trialDurationDays: 30,
        features: { post_jobs: true, resume_matching: true, view_candidates: true },
        isRecommended: true,
        isActive: true,
      },
      {
        id: 'employer_free_trial',
        name: 'Employer 1-Month Free Trial',
        role: 'employer',
        description: 'First month free trial for all new employer accounts.',
        monthlyPrice: 0.00,
        yearlyPrice: 0.00,
        currency: 'INR',
        trialDurationDays: 30,
        features: { post_jobs: true, resume_matching: true, view_candidates: true },
        isRecommended: false,
        isActive: true,
      },
      {
        id: 'employee_monthly',
        name: 'Employee Pro Plan',
        role: 'employee',
        description: 'Access to premium job listings and AI resume matching.',
        monthlyPrice: 199.00,
        yearlyPrice: 1999.00,
        currency: 'INR',
        trialDurationDays: 30,
        features: { view_jobs: true, apply_jobs: true, resume_matching: true },
        isRecommended: true,
        isActive: true,
      },
      {
        id: 'employee_free_trial',
        name: 'Employee 1-Month Free Trial',
        role: 'employee',
        description: 'First month free trial for all new employee accounts.',
        monthlyPrice: 0.00,
        yearlyPrice: 0.00,
        currency: 'INR',
        trialDurationDays: 30,
        features: { view_jobs: true, apply_jobs: true, resume_matching: true },
        isRecommended: false,
        isActive: true,
      },
      {
        id: 'provider_monthly',
        name: 'Provider Pro Plan',
        role: 'provider',
        description: 'Publish services and manage client appointment bookings.',
        monthlyPrice: 199.00,
        yearlyPrice: 1999.00,
        currency: 'INR',
        trialDurationDays: 30,
        features: { add_services: true, manage_bookings: true },
        isRecommended: true,
        isActive: true,
      },
      {
        id: 'provider_free_trial',
        name: 'Provider 1-Month Free Trial',
        role: 'provider',
        description: 'First month free trial for all new provider accounts.',
        monthlyPrice: 0.00,
        yearlyPrice: 0.00,
        currency: 'INR',
        trialDurationDays: 30,
        features: { add_services: true, manage_bookings: true },
        isRecommended: false,
        isActive: true,
      },
      {
        id: 'seeker_monthly',
        name: 'Seeker Pro Plan',
        role: 'seeker',
        description: 'Browse listed services and book appointments with priority scheduling.',
        monthlyPrice: 199.00,
        yearlyPrice: 1999.00,
        currency: 'INR',
        trialDurationDays: 30,
        features: { book_services: true, view_bookings: true },
        isRecommended: true,
        isActive: true,
      },
      {
        id: 'seeker_free_trial',
        name: 'Seeker 1-Month Free Trial',
        role: 'seeker',
        description: 'First month free trial for all new seeker accounts.',
        monthlyPrice: 0.00,
        yearlyPrice: 0.00,
        currency: 'INR',
        trialDurationDays: 30,
        features: { book_services: true, view_bookings: true },
        isRecommended: false,
        isActive: true,
      }
    ];

    for (const plan of defaultPlans) {
      await db.collection('subscription_plans').doc(plan.id).set({
        ...plan,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
    }
    console.log('[Seeding] Seeded/updated default and trial plans successfully.');
  } catch (error) {
    console.error('[Seeding] Error seeding default subscription plans:', error);
  }
};
seedPlans();

// --- GEMINI AI INTEGRATION AND QUEUEING ---
const https = require('https');

function callGeminiAPI(prompt) {
  return new Promise((resolve, reject) => {
    const apiKey = process.env.GEMINI_API_KEY || process.env.OPENAI_API_KEY || '';
    if (!apiKey) {
      return reject(new Error('API key not configured on backend'));
    }

    const payload = JSON.stringify({
      contents: [{
        parts: [{
          text: prompt
        }]
      }],
      generationConfig: {
        responseMimeType: 'application/json'
      }
    });

    const options = {
      hostname: 'generativelanguage.googleapis.com',
      port: 443,
      path: `/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 429) {
          const error = new Error('Rate limit exceeded');
          error.statusCode = 429;
          return reject(error);
        }
        if (res.statusCode >= 400) {
          return reject(new Error(`API Error: Status ${res.statusCode} | Data: ${data}`));
        }

        try {
          const parsed = JSON.parse(data);
          const responseText = parsed.candidates[0].content.parts[0].text;
          resolve(responseText);
        } catch (err) {
          reject(new Error(`Failed to parse Gemini response: ${err.message} | Raw response: ${data}`));
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(payload);
    req.end();
  });
}

/**
 * 5. AI Resume Matcher Endpoint
 * Compares candidate resume text to job description with dynamic queueing on rate limits.
 */
router.post('/ai/match-resume', requireAuth, async (req, res) => {
  try {
    const { resumeText, jobDescription } = req.body;
    const userId = req.user.uid;

    if (!resumeText || !jobDescription) {
      return res.status(400).json({ success: false, error: 'resumeText and jobDescription are required' });
    }

    if (!db) {
      console.log('[Simulated] Gemini matching simulation.');
      return res.json({
        success: true,
        data: {
          overallScore: 85.0,
          skillsMatch: 90.0,
          experienceMatch: 80.0,
          educationMatch: 85.0,
          analysis: '[Simulated] Candidate has strong compatibility with this position.',
          strengths: ['Relevant domain experience', 'Solid core technical skills'],
          gaps: ['Minor tools experience differences'],
          recommendations: ['Update resume profile headers'],
          matchedSkills: ['JavaScript', 'Flutter', 'Firebase'],
          missingSkills: ['Cloud Services Architecture']
        }
      });
    }

    const prompt = `
      Act as an AI Recruiter. Compare the provided resume against the job description.
      Return a detailed analysis in JSON format with the following keys:
      - overallScore: A matching percentage (0.0 to 100.0)
      - skillsMatch: Percentage for skills only (0.0 to 100.0)
      - experienceMatch: Percentage for experience only (0.0 to 100.0)
      - educationMatch: Percentage for education only (0.0 to 100.0)
      - analysis: A high-level summary of the match (2-3 sentences)
      - strengths: Array of 3-5 specific strengths the candidate has for this role
      - gaps: Array of 3-5 specific areas where the candidate is lacking or could improve
      - recommendations: Array of 3-5 actionable steps the candidate should take to improve their chances
      - matchedSkills: Array of skills found in both resume and job description
      - missingSkills: Array of high-priority skills in the job description missing from the resume

      Return pure JSON object only, no markdown formatting.

      Resume Text:
      ${resumeText}

      Job Description:
      ${jobDescription}
    `;

    const responseText = await callGeminiAPI(prompt);
    
    let matchedData;
    try {
      matchedData = JSON.parse(responseText);
    } catch (_) {
      let cleanText = responseText.trim();
      if (cleanText.includes('```json')) {
        cleanText = cleanText.split('```json').last().split('```').first();
      } else if (cleanText.includes('```')) {
        cleanText = cleanText.split('```').last().split('```').first();
      }
      matchedData = JSON.parse(cleanText.trim());
    }

    res.json({
      success: true,
      data: matchedData
    });

  } catch (error) {
    console.error('[AiMatch] Error:', error);

    if (error.statusCode === 429) {
      try {
        const queueId = `match_${userId}_${Date.now()}`;
        await db.collection('pending_matches').doc(queueId).set({
          userId: userId,
          resumeText: resumeText,
          jobDescription: jobDescription,
          status: 'pending',
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        return res.status(202).json({
          success: false,
          rateLimited: true,
          message: 'AI matching is currently busy. We have queued your resume for processing and will notify you as soon as the results are ready!'
        });
      } catch (dbError) {
        console.error('[AiMatch] Failed to queue pending match:', dbError);
      }
    }

    res.status(500).json({
      success: false,
      error: 'Error generating AI Match: ' + error.message
    });
  }
});

module.exports = router;
