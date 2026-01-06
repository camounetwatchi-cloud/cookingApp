const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
const fetch = require('node-fetch');

async function testFoodDetection() {
    const imagePath = path.join(__dirname, '..', 'istockphoto-842160124-612x612.jpg');

    console.log('='.repeat(60));
    console.log('🧪 Testing Food Detection with Gemini 2.5 Flash');
    console.log('='.repeat(60));
    console.log(`\n📸 Image: ${imagePath}`);

    if (!fs.existsSync(imagePath)) {
        console.error('❌ Test image not found!');
        process.exit(1);
    }

    const form = new FormData();
    form.append('photo', fs.createReadStream(imagePath));

    try {
        console.log('\n🚀 Sending request to http://localhost:8080/api/fridge...\n');

        const response = await fetch('http://localhost:8080/api/fridge', {
            method: 'POST',
            body: form,
            headers: form.getHeaders(),
        });

        const data = await response.json();

        if (response.ok) {
            console.log('✅ SUCCESS!\n');
            console.log(`📊 Detected ${data.items.length} food items:\n`);
            data.items.forEach((item, index) => {
                console.log(`   ${index + 1}. ${item}`);
            });
            console.log('\n' + '='.repeat(60));
            console.log('✨ Food detection working perfectly!');
            console.log('='.repeat(60));
        } else {
            console.error('❌ ERROR!');
            console.error('Status:', response.status);
            console.error('Response:', JSON.stringify(data, null, 2));
        }
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        console.error('\n💡 Make sure the server is running on port 8080');
        console.error('   Run: node index.js');
    }
}

testFoodDetection();
