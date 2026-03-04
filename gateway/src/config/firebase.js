const admin = require('firebase-admin');

// In a real production scenario, use a proper ServiceAccountKey.json
// For this demo structure, we initialize with default credentials or dummy
try {
    // If you have a real service account key, uncomment and use it:
    // const serviceAccount = require('./ServiceAccountKey.json');
    // admin.initializeApp({
    //     credential: admin.credential.cert(serviceAccount)
    // });

    // For now we will use a mock initialization or default app to prevent crash
    admin.initializeApp();
    console.log("Firebase Admin Initialized");
} catch (error) {
    console.warn("Firebase Init Warning (Expected if no credentials):", error.message);
}

const db = admin.firestore();
const storage = admin.storage();

module.exports = { admin, db, storage };
