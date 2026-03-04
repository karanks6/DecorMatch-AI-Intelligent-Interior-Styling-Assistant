const { db } = require('../config/firebase');

// Utility to calculate simple color distance (Euclidean distance between hex colors)
const hexToRgb = (hex) => {
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

const getRecommendations = async (aiResult) => {
    const { style, dominant_colors } = aiResult;

    // In a real database, we would query Products collection
    // For now we will return some mock recommended products that match
    const mockProducts = [
        {
            product_id: "p1",
            name: "Modern Leather Sofa",
            style_category: "Modern",
            dominant_color: "#1F2933",
            image_url: "https://example.com/sofa.png",
            ar_model_url: "sofa.glb",
            price: 599.99,
            popularity_score: 95
        },
        {
            product_id: "p2",
            name: "Bohemian Woven Rug",
            style_category: "Bohemian",
            dominant_color: "#D4A373",
            image_url: "https://example.com/rug.png",
            ar_model_url: "rug.glb",
            price: 129.99,
            popularity_score: 88
        },
        {
            product_id: "p3",
            name: "Minimalist Wood Frame Bed",
            style_category: "Minimalist",
            dominant_color: "#F7F3EF",
            image_url: "https://example.com/bed.png",
            ar_model_url: "bed.glb",
            price: 450.00,
            popularity_score: 92
        },
        // We ensure there's a dynamic result based on input
    ];

    // Filter by matching style first
    let matchingProducts = mockProducts.filter(p => p.style_category === style);

    // If we have none matching perfectly, just return all sorted by popularity
    if (matchingProducts.length === 0) {
        matchingProducts = [...mockProducts];
    }

    // Sort by best color match with any of the dominant colors and popularity
    matchingProducts.sort((a, b) => {
        let bestDistA = Math.min(...dominant_colors.map(c => colorDistance(c, a.dominant_color)));
        let bestDistB = Math.min(...dominant_colors.map(c => colorDistance(c, b.dominant_color)));

        // Lower distance is better
        if (bestDistA !== bestDistB) return bestDistA - bestDistB;

        // Higher popularity is better
        return b.popularity_score - a.popularity_score;
    });

    return matchingProducts;
};

module.exports = { getRecommendations };
