const http = require('http');

function testEndpoint(path, expectedStatus = 200) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path,
      method: 'GET',
    };

    const req = http.request(options, (res) => {
      if (res.statusCode === expectedStatus) {
        console.log(`✅ ${path} - Status: ${res.statusCode}`);
        resolve(true);
      } else {
        console.log(
          `❌ ${path} - Expected: ${expectedStatus}, Got: ${res.statusCode}`
        );
        reject(new Error(`Expected ${expectedStatus}, got ${res.statusCode}`));
      }
    });

    req.on('error', (err) => {
      console.log(`❌ ${path} - Error: ${err.message}`);
      reject(err);
    });

    req.setTimeout(5000, () => {
      console.log(`❌ ${path} - Timeout`);
      req.destroy();
      reject(new Error('Timeout'));
    });

    req.end();
  });
}

async function runTests() {
  console.log('🧪 Iniciando testes básicos...');

  try {
    require('../src/index.js');

    await new Promise((resolve) => setTimeout(resolve, 1000));

    await testEndpoint('/');
    await testEndpoint('/status');
    await testEndpoint('/health');
    await testEndpoint('/nonexistent', 404);

    console.log('✅ Todos os testes passaram!');
    process.exit(0);
  } catch (error) {
    console.log('❌ Testes falharam:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  runTests();
}
