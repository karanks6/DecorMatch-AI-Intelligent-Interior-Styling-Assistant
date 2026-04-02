const axios = require('axios');
const FormData = require('form-data');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

const analyzeImageWithAI = async (fileBuffer, originalName) => {
    try {
        const form = new FormData();
        form.append('file', fileBuffer, { filename: originalName || 'image.jpg', contentType: 'image/jpeg' });

        const response = await axios.post(`${AI_SERVICE_URL}/analyze-room`, form, {
            headers: {
                ...form.getHeaders()
            }
        });

        return response.data; // { style, confidence, dominant_colors }
    } catch (error) {
        let detail = error.message;
        if (error.response && error.response.data && error.response.data.detail) {
            detail = JSON.stringify(error.response.data.detail);
        }
        console.error("Error communicating with AI service:", detail);
        throw new Error("AI Python Microservice Error: " + detail);
    }
};

module.exports = { analyzeImageWithAI };
