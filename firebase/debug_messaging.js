// Debug script to test messaging functionality
// Run this in the Firebase console or as a Cloud Function

const admin = require('firebase-admin');

// Test function to check if messaging works
async function testMessaging() {
  try {
    console.log('Testing messaging functionality...');
    
    // Test user UIDs from TEST_CREDENTIALS.txt
    const mariaUid = 'cHUncKWfQpWpoW0LFx46b5twfbn2';
    const joseUid = 'qWglVzwdJ9RIbdfxUcFrHr5gHj13';
    
    console.log('Maria UID:', mariaUid);
    console.log('Jose UID:', joseUid);
    
    // Check if both users exist
    const mariaRef = admin.firestore().collection('Users').doc(mariaUid);
    const joseRef = admin.firestore().collection('Users').doc(joseUid);
    
    const mariaDoc = await mariaRef.get();
    const joseDoc = await joseRef.get();
    
    console.log('Maria exists:', mariaDoc.exists);
    console.log('Jose exists:', joseDoc.exists);
    
    if (mariaDoc.exists && joseDoc.exists) {
      // Check existing threads
      const mariaThreads = await admin.firestore().collection('messages')
        .where('uid', '==', mariaUid)
        .where('participants', '==', joseRef)
        .get();
        
      const joseThreads = await admin.firestore().collection('messages')
        .where('uid', '==', joseUid)
        .where('participants', '==', mariaRef)
        .get();
        
      console.log('Maria threads with Jose:', mariaThreads.size);
      console.log('Jose threads with Maria:', joseThreads.size);
      
      // Create test threads if they don't exist
      if (mariaThreads.empty) {
        console.log('Creating Maria thread...');
        await admin.firestore().collection('messages').add({
          uid: mariaUid,
          participants: joseRef,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastMessage: '',
          displayName: 'Jose Garcia',
          email: 'jose.garcia@antiquespride.edu.ph',
          photoUrl: '',
          phoneNumber: '+63 917 890 1234',
          address: 'Makati City, Metro Manila',
          createdTime: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log('Maria thread created');
      }
      
      if (joseThreads.empty) {
        console.log('Creating Jose thread...');
        await admin.firestore().collection('messages').add({
          uid: joseUid,
          participants: mariaRef,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastMessage: '',
          displayName: 'Maria Santos',
          email: 'maria.santos@antiquespride.edu.ph',
          photoUrl: '',
          phoneNumber: '+63 912 345 6789',
          address: 'Quezon City, Metro Manila',
          createdTime: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log('Jose thread created');
      }
      
      console.log('✅ Test completed successfully');
    } else {
      console.log('❌ Users not found');
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

// Export for use
module.exports = { testMessaging };
