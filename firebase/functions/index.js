const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("messages/" + user.uid);
});

// Import messaging functions
const messagingFunctions = require('./messaging_functions');

// Export messaging functions
exports.updateMessageThreads = messagingFunctions.updateMessageThreads;
exports.createBidirectionalThreads = messagingFunctions.createBidirectionalThreads;
