const axios = require('axios');
const FormData = require('form-data');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

const analyzeImageWithAI = async (fileBuffer, originalName) => {
    try {
        const form = new FormData();
        form.append('file', fileBuffer, originalName);

        const response = await axios.post(`${AI_SERVICE_URL}/analyze-room`, form, {
            headers: {
                ...form.getHeaders()
            }
        });

        return response.data; // { style, confidence, dominant_colors }
    } catch (error) {
        console.error("Error communicating with AI service:", error.message);
        throw new Error("Failed to analyze image with AI service.");
    }
};

module.exports = { analyzeImageWithAI };
