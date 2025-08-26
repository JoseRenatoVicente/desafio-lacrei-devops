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
      latency: '/latency',
      error: '/error',
    },
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

app.get('/latency', async (req, res) => {
  const delayMs = parseInt(req.query.ms, 10) || 5000;
  await new Promise((resolve) => setTimeout(resolve, delayMs));
  res.status(200).json({
    message: `Resposta enviada após ${delayMs}ms de latência simulada.`,
  });
});

app.get('/error', (req, res) => {
  res.status(500).json({
    error: 'Erro interno simulado',
    message: 'Este endpoint sempre retorna erro 500.',
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
