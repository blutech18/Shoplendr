const admin = require('firebase-admin');
const serviceAccount = require('./shop-lendr3-yy2xvd-firebase-adminsdk-fbsvc-ffce5d2e75.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

/**
 * Script to sync all user emails from Firebase Auth to Firestore Users collection
 * This fixes missing emails for Google-authenticated users
 */
async function syncUserEmails() {
  try {
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Starting Email Sync Process...');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Get all users from Firestore Users collection
    const usersSnapshot = await db.collection('Users').get();
    
    if (usersSnapshot.empty) {
      console.log('⚠ No users found in Firestore Users collection.');
      return;
    }

    console.log(`📊 Found ${usersSnapshot.size} users in Firestore\n`);

    let syncedCount = 0;
    let skippedCount = 0;
    let errorCount = 0;
    const errors = [];

    // Process each user
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const userData = userDoc.data();
      const currentEmail = userData.email || '';

      try {
        // Get user from Firebase Auth
        let authUser;
        try {
          authUser = await auth.getUser(userId);
        } catch (authError) {
          if (authError.code === 'auth/user-not-found') {
            console.log(`⚠ User ${userId} not found in Firebase Auth - skipping`);
            skippedCount++;
            continue;
          }
          throw authError;
        }

        const authEmail = authUser.email || '';

        // Skip if no email in Firebase Auth
        if (!authEmail || authEmail.trim() === '') {
          console.log(`⏭ Skipping ${userId}: No email in Firebase Auth`);
          skippedCount++;
          continue;
        }

        // Check if email needs to be synced
        if (currentEmail === authEmail) {
          console.log(`✓ ${userData.display_name || userId}: Email already synced (${authEmail})`);
          skippedCount++;
          continue;
        }

        // Update email in Firestore
        await db.collection('Users').doc(userId).update({
          email: authEmail
        });

        console.log(`✅ ${userData.display_name || userId}: Email synced`);
        console.log(`   Previous: ${currentEmail || '(empty)'} → New: ${authEmail}`);
        syncedCount++;

      } catch (error) {
        console.error(`❌ Error syncing user ${userId}:`, error.message);
        errors.push({ userId, error: error.message });
        errorCount++;
      }
    }

    // Summary
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Email Sync Summary:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`✅ Synced: ${syncedCount} users`);
    console.log(`⏭ Skipped: ${skippedCount} users`);
    console.log(`❌ Errors: ${errorCount} users`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    if (errors.length > 0) {
      console.log('Errors encountered:');
      errors.forEach(({ userId, error }) => {
        console.log(`  - ${userId}: ${error}`);
      });
      console.log('');
    }

    console.log('✅ Email sync process completed!');

  } catch (error) {
    console.error('\n❌ Fatal error during email sync:', error);
    process.exit(1);
  }
}

// Run the sync
syncUserEmails()
  .then(() => {
    console.log('\n✨ Script finished successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Script failed:', error);
    process.exit(1);
  });

