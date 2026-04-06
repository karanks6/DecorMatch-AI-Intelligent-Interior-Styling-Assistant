const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Assuming this script sits at the root (d:\Project_Ground\DecorMatch-AI-Intelligent-Interior-Styling-Assistant)
const modelsDir = path.join(__dirname, '3D models');

console.log(`Starting Draco Compression process on ${modelsDir}...`);

let successCount = 0;
let failCount = 0;

function formatBytes(bytes, decimals = 2) {
    if (!+bytes) return '0 Bytes';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(dm))} ${sizes[i]}`;
}

function processDir(dir) {
    if (!fs.existsSync(dir)) {
        console.error(`Directory not found: ${dir}`);
        return;
    }

    const items = fs.readdirSync(dir);
    for (const item of items) {
        const fullPath = path.join(dir, item);
        if (fs.statSync(fullPath).isDirectory()) {
            processDir(fullPath); // Recursive call
        } else if (fullPath.endsWith('.glb') && !fullPath.includes('_draco')) {
            const originalSize = fs.statSync(fullPath).size;
            console.log(`\n===========================================`);
            console.log(`Compressing: ${item}`);
            console.log(`Original Size: ${formatBytes(originalSize)}`);
            
            const tempPath = fullPath.replace('.glb', '_draco.glb');
            try {
                // npx implicitly downloads gltf-pipeline if not present, but using -y auto-confirms it
                // -d applies draco compression
                execSync(`npx -y gltf-pipeline -i "${fullPath}" -o "${tempPath}" -d`, { stdio: 'pipe' });
                
                const newSize = fs.statSync(tempPath).size;
                const reduction = (((originalSize - newSize) / originalSize) * 100).toFixed(1);
                
                console.log(`New Size: ${formatBytes(newSize)} (Reduced by ${reduction}%)`);
                
                // Destructive swap if success
                fs.rmSync(fullPath);
                fs.renameSync(tempPath, fullPath);
                
                console.log(`Successfully overwritten ${item}.`);
                successCount++;
            } catch(e) {
                console.error(`FAILED to compress ${fullPath}`);
                if (fs.existsSync(tempPath)) {
                    try {
                        fs.rmSync(tempPath);
                    } catch (cleanupErr) {
                        console.error(`Could not clean up temp file: ${cleanupErr.message}`);
                    }
                }
                failCount++;
            }
        }
    }
}

try {
    processDir(modelsDir);
    console.log(`\n===========================================`);
    console.log(`Batch Operation Completed!`);
    console.log(`Successfully Compressed: ${successCount} models.`);
    if (failCount > 0) console.log(`Failed: ${failCount} models.`);
} catch (e) {
    console.error("Critical error enclosing script: ", e);
}
