const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const modelsDir = path.join(__dirname, '3D models');

console.log(`Starting Uncompression process on ${modelsDir}...`);

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
    if (!fs.existsSync(dir)) return;

    const items = fs.readdirSync(dir);
    for (const item of items) {
        const fullPath = path.join(dir, item);
        if (fs.statSync(fullPath).isDirectory()) {
            processDir(fullPath);
        } else if (fullPath.endsWith('.glb') && !fullPath.includes('_raw')) {
            const originalSize = fs.statSync(fullPath).size;
            console.log(`\n===========================================`);
            console.log(`Uncompressing (removing Draco): ${item}`);
            
            const tempPath = fullPath.replace('.glb', '_raw.glb');
            try {
                // By completely omitting the '-d' flag, gltf-pipeline will intrinsically decode Draco into raw geometry
                execSync(`npx -y gltf-pipeline -i "${fullPath}" -o "${tempPath}"`, { stdio: 'pipe' });
                
                const newSize = fs.statSync(tempPath).size;
                console.log(`Decompressed. New Size: ${formatBytes(newSize)}`);
                
                fs.rmSync(fullPath);
                fs.renameSync(tempPath, fullPath);
                
                successCount++;
            } catch(e) {
                console.error(`FAILED to uncompress ${fullPath}`);
                if (fs.existsSync(tempPath)) {
                    try { fs.rmSync(tempPath); } catch {}
                }
                failCount++;
            }
        }
    }
}

try {
    processDir(modelsDir);
    console.log(`\n===========================================`);
    console.log(`Batch Decompression Completed!`);
    console.log(`Successfully Fixed: ${successCount} models.`);
    if (failCount > 0) console.log(`Failed: ${failCount} models.`);
} catch (e) {
    console.error("Critical error: ", e);
}
