const testEnv: Record<string, string> = {
  NODE_ENV: 'test',
  PORT: '3001',
  API_PREFIX: 'api/v1',
  DATABASE_URL: 'postgresql://postgres:postgres@localhost:5432/medigo_test',
  JWT_SECRET: 'test-secret',
  JWT_EXPIRES_IN: '1h',
  JWT_REFRESH_SECRET: 'test-refresh-secret',
  JWT_REFRESH_EXPIRES_IN: '7d',
  THROTTLE_TTL: '60',
  THROTTLE_LIMIT: '100',
};

for (const [key, value] of Object.entries(testEnv)) {
  process.env[key] ??= value;
}
