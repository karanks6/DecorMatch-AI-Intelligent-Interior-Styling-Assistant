const express = require('express');
const multer = require('multer');
const { analyzeImageWithAI } = require('../services/aiService');
const { getRecommendations } = require('../services/recommendationEngine');

const router = express.Router();

// Memory storage for multer since we just pass buffer to AI service
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

/**
 * @route POST /api/analyze-room
 * @desc Receives image, queries AI service, generates recommendations
 */
router.post('/analyze-room', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No image file uploaded' });
        }

        // 1. Analyze via AI Microservice
        const fileBuffer = req.file.buffer;
        const aiResult = await analyzeImageWithAI(fileBuffer, req.file.originalname);

        // aiResult contains { style, confidence, dominant_colors }

        // 2. Query Recommendations using ai result and the user's room type
        const roomType = req.body.room_type || 'bedroom';
        const recommendations = await getRecommendations(aiResult, roomType);

        // 3. (Optional) Save to user history using Firebase
        // if (req.body.userId) { ... }

        // 4. Return response to Flutter app
        return res.json({
            analysis: aiResult,
            recommendations: recommendations
        });

    } catch (error) {
        console.error("Analyze Room Error:", error.message);
        res.status(500).json({ error: 'Analysis process failed: ' + error.message });
    }
});

// Mock database fetching endpoints
router.get('/products', (req, res) => {
    res.json([{ id: 1, name: "Sample Decor" }]);
});

router.get('/products/style/:style', (req, res) => {
    res.json([{ id: 1, name: "Sample Style Decor" }]);
});

router.get('/user/history', (req, res) => {
    res.json({ history: [] });
});

module.exports = router;
