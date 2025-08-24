const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/status', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'Aplicacao em execucao',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || '1.0.0',
    environment: process.env.ENVIRONMENT || 'development',
    release: {
      version: process.env.RELEASE_VERSION || 'unknown',
      commit: process.env.GIT_COMMIT || 'unknown',
    },
    infrastructure: {
      platform: 'AWS ECS Fargate',
      cluster: process.env.ECS_CLUSTER || 'unknown',
      service: process.env.ECS_SERVICE || 'unknown',
      region: process.env.AWS_REGION || 'unknown',
    },
  });
});

app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Bem-vindo à aplicação de template CI/CD!',
    endpoints: {
      status: '/status',
      health: '/health',
    },
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Rota não encontrada',
    message: 'Esta rota não existe na aplicação',
  });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
    console.log(`Status endpoint: http://localhost:${PORT}/status`);
    console.log(`Home endpoint: http://localhost:${PORT}/`);
  });
}

module.exports = app;
