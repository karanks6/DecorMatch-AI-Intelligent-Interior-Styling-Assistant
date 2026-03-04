require('dotenv').config();
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Load API Routes
const apiRoutes = require('./src/routes/api');
app.use('/api', apiRoutes);

// General/Health Route
app.get('/health', (req, res) => {
    res.json({ status: 'Gateway is healthy', ts: new Date() });
});

// Start Server
app.listen(PORT, () => {
    console.log(`Gateway server running on port ${PORT}`);
});
