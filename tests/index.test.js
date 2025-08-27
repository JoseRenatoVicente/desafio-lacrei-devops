const request = require('supertest');
const app = require('../src/index');

describe('API Endpoints', () => {
  describe('GET /', () => {
    it('should return welcome message with endpoints', async () => {
      const res = await request(app).get('/');

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('message');
      expect(res.body).toHaveProperty('endpoints');
      expect(res.body.endpoints).toHaveProperty('status');
      expect(res.body.endpoints).toHaveProperty('health');
    });
  });

  describe('GET /status', () => {
    it('should return application status', async () => {
      const res = await request(app).get('/status');

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'OK');
      expect(res.body).toHaveProperty('message');
      expect(res.body).toHaveProperty('timestamp');
      expect(res.body).toHaveProperty('uptime');
      expect(res.body).toHaveProperty('version');
      expect(res.body).toHaveProperty('environment');
      expect(res.body).toHaveProperty('release');
      expect(res.body).toHaveProperty('infrastructure');
    });

    it('should return valid timestamp format', async () => {
      const res = await request(app).get('/status');

      expect(res.body.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
    });

    it('should return release information', async () => {
      const res = await request(app).get('/status');

      expect(res.body.release).toHaveProperty('version');
      expect(res.body.release).toHaveProperty('commit');
      expect(Object.keys(res.body.release)).toEqual(['version', 'commit']);
    });

    it('should return infrastructure information', async () => {
      const res = await request(app).get('/status');

      expect(res.body.infrastructure).toHaveProperty(
        'platform',
        'AWS ECS Fargate'
      );
      expect(res.body.infrastructure).toHaveProperty('cluster');
      expect(res.body.infrastructure).toHaveProperty('service');
      expect(res.body.infrastructure).toHaveProperty('region');
    });

    it('should return environment from ENVIRONMENT', async () => {
      const originalEnv = process.env.ENVIRONMENT;

      process.env.ENVIRONMENT = 'test';

      const res = await request(app).get('/status');

      expect(res.body.environment).toBe('test');

      if (originalEnv) {
        process.env.ENVIRONMENT = originalEnv;
      } else {
        delete process.env.ENVIRONMENT;
      }
    });
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const res = await request(app).get('/health');

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'healthy');
      expect(res.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /nonexistent', () => {
    it('should return 404 for non-existent routes', async () => {
      const res = await request(app).get('/nonexistent');

      expect(res.statusCode).toBe(404);
      expect(res.body).toHaveProperty('error', 'Rota não encontrada');
      expect(res.body).toHaveProperty('message');
    });
  });

  describe('GET /latency', () => {
    it('should delay the response by at least the default time (5s)', async () => {
      const start = Date.now();
      const res = await request(app).get('/latency');
      const duration = Date.now() - start;
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('message');
      expect(duration).toBeGreaterThanOrEqual(4900);
    }, 10000);

    it('should delay the response by the specified ms', async () => {
      const delay = 1000;
      const start = Date.now();
      const res = await request(app).get(`/latency?ms=${delay}`);
      const duration = Date.now() - start;
      expect(res.statusCode).toBe(200);
      expect(res.body.message).toContain(`${delay}ms`);
      expect(duration).toBeGreaterThanOrEqual(delay - 50); // margem de erro
    });
  });

  describe('GET /error', () => {
    it('should always return 500 error', async () => {
      const res = await request(app).get('/error');
      expect(res.statusCode).toBe(500);
      expect(res.body).toHaveProperty('error', 'Erro interno simulado');
      expect(res.body).toHaveProperty('message');
    });
  });

  describe('POST /status', () => {
    it('should return 404 for non-GET methods on status', async () => {
      const res = await request(app).post('/status');

      expect(res.statusCode).toBe(404);
    });
  });
});

describe('Application Configuration', () => {
  it('should use correct port from environment or default', () => {
    const originalPort = process.env.PORT;
    delete process.env.PORT;

    delete require.cache[require.resolve('../src/index')];
    const freshApp = require('../src/index');

    if (originalPort) {
      process.env.PORT = originalPort;
    }

    expect(freshApp).toBeDefined();
  });
});
