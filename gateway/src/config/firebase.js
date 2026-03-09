const admin = require('firebase-admin');

// Load your Firebase Service Account Key directly
const serviceAccount = require('D:/Project_Ground/DecorMatch-AI-Intelligent-Interior-Styling-Assistant/gateway/decormatch-ai-firebase-adminsdk-fbsvc-3e9043c5cd.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: serviceAccount.project_id + '.appspot.com'
});

console.log("✅ Firebase Admin Initialized with Service Account");

const db = admin.firestore();
const storage = admin.storage();
const auth = admin.auth();

module.exports = { admin, db, storage, auth };
