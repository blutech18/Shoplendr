const admin = require('firebase-admin');
const serviceAccount = require('./shop-lendr3-yy2xvd-firebase-adminsdk-fbsvc-ffce5d2e75.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

// Additional student configurations with realistic Filipino names
const students = [
  {
    email: 'maria.santos@antiquespride.edu.ph',
    password: 'Maria123!',
    displayName: 'Maria Santos',
    username: 'maria_santos',
    role: 'student',
    permissions: [],
    phoneNumber: '+63 912 345 6789',
    address: 'Quezon City, Metro Manila',
    studentId: '2024-001234'
  },
  {
    email: 'jose.garcia@antiquespride.edu.ph',
    password: 'Jose123!',
    displayName: 'Jose Garcia',
    username: 'jose_garcia',
    role: 'student',
    permissions: [],
    phoneNumber: '+63 917 890 1234',
    address: 'Makati City, Metro Manila',
    studentId: '2024-005678'
  }
];

async function createStudent(studentConfig) {
  try {
    console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
    console.log(`Creating STUDENT account: ${studentConfig.displayName}`);
    console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);

    // Step 1: Create user in Firebase Authentication
    let userRecord;
    try {
      userRecord = await auth.createUser({
        email: studentConfig.email,
        password: studentConfig.password,
        displayName: studentConfig.displayName,
        emailVerified: true
      });
      console.log(`✓ Created in Firebase Auth`);
      console.log(`  UID: ${userRecord.uid}`);
    } catch (error) {
      if (error.code === 'auth/email-already-exists') {
        console.log(`⚠ User already exists in Firebase Auth, fetching existing user...`);
        userRecord = await auth.getUserByEmail(studentConfig.email);
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
      display_name: studentConfig.displayName,
      email: studentConfig.email,
      username: studentConfig.username,
      created_time: admin.firestore.FieldValue.serverTimestamp(),
      phone_number: studentConfig.phoneNumber,
      photo_url: '',
      profile_picture: '',
      IDverification: studentConfig.studentId,
      Address: studentConfig.address,
      emailVerified: true,
      studentIdVerified: true,
      verificationStatus: 'verified',
      is_suspended: false,
      student_id: studentConfig.studentId,
      last_login: admin.firestore.FieldValue.serverTimestamp()
    };

    await userRef.set(userData, { merge: true });
    console.log(`✓ Created/Updated in Users collection`);
    console.log(`✓ Student ID: ${studentConfig.studentId}`);
    console.log(`✓ Phone: ${studentConfig.phoneNumber}`);
    console.log(`✓ Address: ${studentConfig.address}`);

    console.log(`\n✅ STUDENT account ready!`);
    console.log(`   Name: ${studentConfig.displayName}`);
    console.log(`   Email: ${studentConfig.email}`);
    console.log(`   Password: ${studentConfig.password}`);
    console.log(`   Student ID: ${studentConfig.studentId}`);
    console.log(`   UID: ${userRecord.uid}`);

    return {
      name: studentConfig.displayName,
      email: studentConfig.email,
      password: studentConfig.password,
      studentId: studentConfig.studentId,
      uid: userRecord.uid,
      phoneNumber: studentConfig.phoneNumber,
      address: studentConfig.address
    };

  } catch (error) {
    console.error(`\n❌ Error creating student account for ${studentConfig.displayName}:`, error.message);
    throw error;
  }
}

async function main() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   SHOPLENDR ADDITIONAL STUDENT ACCOUNTS        ║');
  console.log('╚════════════════════════════════════════════════╝');

  const createdStudents = [];

  for (const studentConfig of students) {
    try {
      const result = await createStudent(studentConfig);
      createdStudents.push(result);
    } catch (error) {
      console.error(`Failed to create ${studentConfig.displayName}`);
    }
  }

  // Print summary
  console.log('\n\n╔════════════════════════════════════════════════╗');
  console.log('║              CREATION SUMMARY                  ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  createdStudents.forEach((student, index) => {
    console.log(`${index + 1}. ${student.name}`);
    console.log(`   Email:      ${student.email}`);
    console.log(`   Password:   ${student.password}`);
    console.log(`   Student ID: ${student.studentId}`);
    console.log(`   Phone:      ${student.phoneNumber}`);
    console.log(`   Address:    ${student.address}`);
    console.log(`   UID:        ${student.uid}`);
    console.log('');
  });

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('✓ All student accounts are email verified');
  console.log('✓ All student accounts created in Firebase Authentication');
  console.log('✓ Student documents created in Firestore Users collection');
  console.log('✓ Student ID verification status set to verified');
  console.log('✓ Ready for messaging and transaction testing');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  console.log('📝 TESTING SCENARIOS:');
  console.log('   • Maria Santos can message Jose Garcia');
  console.log('   • Jose Garcia can message Maria Santos');
  console.log('   • Both can buy/rent items from each other');
  console.log('   • Both can use the messaging system');
  console.log('   • Both accounts are fully verified\n');

  console.log('⚠️  IMPORTANT: These passwords are for TESTING ONLY');
  console.log('    Change passwords in production environment!\n');

  process.exit(0);
}

main().catch(error => {
  console.error('\n❌ Fatal error:', error);
  process.exit(1);
});
