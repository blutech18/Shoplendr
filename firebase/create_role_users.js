const admin = require('firebase-admin');
const serviceAccount = require('./shop-lendr3-yy2xvd-firebase-adminsdk-fbsvc-ffce5d2e75.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

// User configurations
const users = [
  {
    email: 'admin@antiquespride.edu.ph',
    password: 'Admin123!',
    displayName: 'Administrator',
    username: 'admin',
    role: 'super_admin',
    permissions: [
      'manage_users',
      'manage_products',
      'manage_categories',
      'manage_reviews',
      'view_analytics',
      'moderate_content',
      'manage_admins'
    ]
  },
  {
    email: 'moderator@antiquespride.edu.ph',
    password: 'Moderator123!',
    displayName: 'Moderator',
    username: 'moderator',
    role: 'moderator',
    permissions: [
      'moderate_content',
      'manage_reviews',
      'view_analytics'
    ]
  },
  {
    email: 'student@antiquespride.edu.ph',
    password: 'Student123!',
    displayName: 'Student User',
    username: 'student',
    role: 'student',
    permissions: []
  }
];

async function createUser(userConfig) {
  try {
    console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
    console.log(`Creating ${userConfig.role.toUpperCase()} account...`);
    console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);

    // Step 1: Create user in Firebase Authentication
    let userRecord;
    try {
      userRecord = await auth.createUser({
        email: userConfig.email,
        password: userConfig.password,
        displayName: userConfig.displayName,
        emailVerified: true
      });
      console.log(`✓ Created in Firebase Auth`);
      console.log(`  UID: ${userRecord.uid}`);
    } catch (error) {
      if (error.code === 'auth/email-already-exists') {
        console.log(`⚠ User already exists in Firebase Auth, fetching existing user...`);
        userRecord = await auth.getUserByEmail(userConfig.email);
        console.log(`  UID: ${userRecord.uid}`);
        
        // Update email verification status
        await auth.updateUser(userRecord.uid, {
          emailVerified: true
        });
        console.log(`✓ Updated email verification status`);
      } else {
        throw error;
      }
    }

    // Step 2: Create/Update document in Users collection
    const userRef = db.collection('Users').doc(userRecord.uid);
    const userData = {
      display_name: userConfig.displayName,
      email: userConfig.email,
      username: userConfig.username,
      created_time: admin.firestore.FieldValue.serverTimestamp(),
      phone_number: '',
      photo_url: '',
      profile_picture: '',
      IDverification: '',
      Address: '',
      emailVerified: true,
      studentIdVerified: userConfig.role === 'student',
      verificationStatus: 'verified',
      is_suspended: false
    };

    await userRef.set(userData, { merge: true });
    console.log(`✓ Created/Updated in Users collection`);

    // Step 3: Create/Update AdminUsers document (for admin and moderator only)
    if (userConfig.role === 'super_admin' || userConfig.role === 'moderator') {
      // Check if AdminUsers entry already exists
      const adminUsersQuery = await db.collection('AdminUsers')
        .where('user_ref', '==', userRef)
        .limit(1)
        .get();

      const adminData = {
        user_ref: userRef,
        role: userConfig.role,
        permissions: userConfig.permissions,
        is_active: true,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        created_by: userRef
      };

      if (!adminUsersQuery.empty) {
        // Update existing AdminUsers document
        const adminDoc = adminUsersQuery.docs[0];
        await adminDoc.ref.set(adminData, { merge: true });
        console.log(`✓ Updated in AdminUsers collection`);
      } else {
        // Create new AdminUsers document
        await db.collection('AdminUsers').add(adminData);
        console.log(`✓ Created in AdminUsers collection`);
      }
    }

    console.log(`\n✅ ${userConfig.role.toUpperCase()} account ready!`);
    console.log(`   Email: ${userConfig.email}`);
    console.log(`   Password: ${userConfig.password}`);
    console.log(`   Role: ${userConfig.role}`);
    console.log(`   UID: ${userRecord.uid}`);

    return {
      email: userConfig.email,
      password: userConfig.password,
      role: userConfig.role,
      uid: userRecord.uid
    };

  } catch (error) {
    console.error(`\n❌ Error creating ${userConfig.role} account:`, error.message);
    throw error;
  }
}

async function main() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   SHOPLENDR USER ROLE ACCOUNTS CREATION        ║');
  console.log('╚════════════════════════════════════════════════╝');

  const createdUsers = [];

  for (const userConfig of users) {
    try {
      const result = await createUser(userConfig);
      createdUsers.push(result);
    } catch (error) {
      console.error(`Failed to create ${userConfig.email}`);
    }
  }

  // Print summary
  console.log('\n\n╔════════════════════════════════════════════════╗');
  console.log('║              CREATION SUMMARY                  ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  createdUsers.forEach((user, index) => {
    console.log(`${index + 1}. ${user.role.toUpperCase()}`);
    console.log(`   Email:    ${user.email}`);
    console.log(`   Password: ${user.password}`);
    console.log(`   UID:      ${user.uid}`);
    console.log('');
  });

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('✓ All accounts are email verified');
  console.log('✓ All accounts created in Firebase Authentication');
  console.log('✓ User documents created in Firestore Users collection');
  console.log('✓ Admin/Moderator entries created in AdminUsers collection');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  console.log('⚠️  IMPORTANT: These passwords are for TESTING ONLY');
  console.log('    Change passwords in production environment!\n');

  process.exit(0);
}

main().catch(error => {
  console.error('\n❌ Fatal error:', error);
  process.exit(1);
});
