const { db } = require('../config/firebase');
const fs = require('fs');
const path = require('path');

// Dynamically load the dataset
let productDatabase = [];
const modelsDir = path.join(__dirname, '../../../3D models');

try {
    if (fs.existsSync(modelsDir)) {
        const styles = fs.readdirSync(modelsDir);
        styles.forEach(style => {
            const stylePath = path.join(modelsDir, style);
            if (fs.statSync(stylePath).isDirectory()) {
                const roomTypes = fs.readdirSync(stylePath);
                roomTypes.forEach(roomType => {
                    const roomPath = path.join(stylePath, roomType);
                    if (fs.statSync(roomPath).isDirectory()) {
                        const files = fs.readdirSync(roomPath);
                        files.filter(f => f.endsWith('.glb')).forEach(glbFile => {
                            const baseName = path.parse(glbFile).name;
                            const pngFile = baseName + '.png';
                            
                            // Format name cleanly
                            const nameParts = baseName.replace(/_/g, ' ').replace(/-/g, ' ').split(' ');
                            const cleanName = nameParts.map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
                            
                            productDatabase.push({
                                product_id: `${style}_${roomType}_${baseName}`,
                                name: cleanName,
                                style_category: style,
                                room_type: roomType,
                                item_category: "decor",
                                dominant_color: "#ffffff", // Default mock
                                image_url: `/models/v2/${encodeURIComponent(style)}/${encodeURIComponent(roomType)}/${encodeURIComponent(pngFile)}`,
                                ar_model_url: `/models/v2/${encodeURIComponent(style)}/${encodeURIComponent(roomType)}/${encodeURIComponent(glbFile)}`,
                                price: Math.floor(Math.random() * 200) + 20,
                                popularity_score: Math.floor(Math.random() * 40) + 60
                            });
                        });
                    }
                });
            }
        });
        console.log(`Loaded ${productDatabase.length} 3D models into product database dynamically!`);
    } else {
        console.error("3D models directory not found at:", modelsDir);
    }
} catch (e) {
    console.error("Failed to load 3D models directory:", e.message);
}

// Fallback if no models are found
if (productDatabase.length === 0) {
    productDatabase = [
        {
            product_id: "p1",
            name: "Placeholder Decor",
            style_category: "Modern",
            item_category: "decor",
            dominant_color: "#1F2933",
            image_url: "https://via.placeholder.com/200",
            ar_model_url: "",
            price: 59.99,
            popularity_score: 95
        }
    ];
}

const hexToRgb = (hex) => {
    // Default fallback if hex is malformed
    if(!hex || hex.length < 7) return [255, 255, 255];
    const r = parseInt(hex.substring(1, 3), 16);
    const g = parseInt(hex.substring(3, 5), 16);
    const b = parseInt(hex.substring(5, 7), 16);
    return [r, g, b];
};

const colorDistance = (c1, c2) => {
    const rgb1 = hexToRgb(c1);
    const rgb2 = hexToRgb(c2);
    return Math.sqrt(
        Math.pow(rgb1[0] - rgb2[0], 2) +
        Math.pow(rgb1[1] - rgb2[1], 2) +
        Math.pow(rgb1[2] - rgb2[2], 2)
    );
};

const getRecommendations = async (aiResult, requestedRoomType = 'bedroom') => {
    const { style, dominant_colors = [], detected_items = [] } = aiResult;

    // Filter by requested room type
    let validProducts = productDatabase.filter(p => !p.room_type || p.room_type === requestedRoomType);

    // Exclude items that are already in the room
    validProducts = validProducts.filter(p => !detected_items.includes(p.item_category));

    // Filter by matching style first
    let matchingProducts = validProducts.filter(p => p.style_category === style);

    // If we have none matching perfectly, fall back
    if (matchingProducts.length === 0) {
        matchingProducts = [...productDatabase];
    }

    // Sort by best color match with any of the dominant colors and popularity
    matchingProducts.sort((a, b) => {
        // Only do color distance if dominant_colors has loaded properly from AI
        if (dominant_colors.length > 0) {
            let bestDistA = Math.min(...dominant_colors.map(c => colorDistance(c, a.dominant_color)));
            let bestDistB = Math.min(...dominant_colors.map(c => colorDistance(c, b.dominant_color)));

            // Lower distance is better
            if (bestDistA !== bestDistB) return bestDistA - bestDistB;
        }

        // Higher popularity is better
        return b.popularity_score - a.popularity_score;
    });

    return matchingProducts;
};

module.exports = { getRecommendations };
