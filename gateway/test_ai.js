const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

async function test() {
    try {
        const form = new FormData();
        // create a dummy valid smaller image or just a 1x1 JPG
        const buffer = Buffer.from('ffd8ffe000104a46494600010101004800480000ffdb004300080606070605080707070909080a0c140d0c0b0b0c1912130f141d1a1f1e1d1a1c1c20242e2720222c231c1c2837292c30313434341f27393d38323c2e333432ffdb0043010909090c0b0c180d0d1832211c213232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232c00011080001000103012200021101031101ffc4001500010100000000000000000000000000000007ffc40014100100000000000000000000000000000000ffc400150101010000000000000000000000000000000000ffc40014110100000000000000000000000000000000ffda000c03010002110311003f00f07fa28a00fffd', 'hex');
        form.append('file', buffer, 'test.jpg');

        const response = await axios.post(`http://localhost:8000/analyze-room`, form, {
            headers: {
                ...form.getHeaders()
            }
        });
        fs.writeFileSync('error_log.txt', JSON.stringify(response.data));
    } catch (e) {
        fs.writeFileSync('error_log.txt', e.response ? JSON.stringify(e.response.data) : e.message);
    }
}
test();
