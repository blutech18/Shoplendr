const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin (if not already initialized)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Cloud Function to handle bidirectional message updates
 * This function is triggered when a new message is added to a chat thread
 */
exports.updateMessageThreads = functions.firestore
  .document('messages/{threadId}/chats/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const messageData = snap.data();
      const threadId = context.params.threadId;
      const messageText = messageData.text;
      const senderRef = messageData.senderRef;
      const sentAt = messageData.sentAt;

      console.log(`New message in thread ${threadId}: ${messageText}`);

      // Get the thread document
      const threadDoc = await db.collection('messages').doc(threadId).get();
      if (!threadDoc.exists) {
        console.error(`Thread ${threadId} not found`);
        return;
      }

      const threadData = threadDoc.data();
      const threadUid = threadData.uid;
      const participants = threadData.participants;

      // Update the current thread
      await db.collection('messages').doc(threadId).update({
        lastMessage: messageText,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // Find and update the corresponding thread for the other participant
      if (participants) {
        const otherThreadsQuery = await db.collection('messages')
          .where('uid', '==', participants.id)
          .where('participants', '==', db.collection('Users').doc(threadUid))
          .limit(1)
          .get();

        if (!otherThreadsQuery.empty) {
          const otherThread = otherThreadsQuery.docs[0];
          await otherThread.ref.update({
            lastMessage: messageText,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          console.log(`Updated corresponding thread ${otherThread.id}`);
        }
      }

      console.log(`Successfully updated both threads for message in ${threadId}`);
    } catch (error) {
      console.error('Error updating message threads:', error);
    }
  });

/**
 * Cloud Function to create bidirectional threads when a new conversation starts
 * DISABLED: This was causing duplicate chat heads in the message list
 * Instead, we'll use a single thread per conversation and update the message list logic
 */
exports.createBidirectionalThreads = functions.firestore
  .document('messages/{threadId}')
  .onCreate(async (snap, context) => {
    try {
      const threadData = snap.data();
      const threadId = context.params.threadId;
      const uid = threadData.uid;
      const participants = threadData.participants;

      console.log(`New thread created: ${threadId}`);

      // DISABLED: No longer creating bidirectional threads to prevent duplicates
      // The message list will be updated to show conversations properly
      console.log(`Thread creation completed for ${threadId} - bidirectional creation disabled`);
      
    } catch (error) {
      console.error('Error in thread creation:', error);
    }
  });
