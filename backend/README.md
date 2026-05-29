# Medigo Backend

NestJS + Prisma backend for Medigo mobile.

## Local Setup

1. Install dependencies:
```bash
npm install
```
2. Start PostgreSQL:
```bash
docker compose up -d
```
3. Copy env values if needed:
```bash
cp .env.example .env
```
4. Run migrations and generate client:
```bash
npm run prisma:migrate
npm run prisma:generate
```
5. Seed admin account:
```bash
npm run seed
```
6. Start server:
```bash
npm run start:dev
```

## API

- Base URL prefix: `api/v1`
- Swagger docs: `http://localhost:3001/docs` (port from `PORT` in `.env`)
- Health endpoint: `GET /api/v1/health`
- Postman collection: `postman/medigo-api.postman_collection.json`

### Auth endpoints

- `POST /api/v1/login`
- `POST /api/v1/patients/register`
- `POST /api/v1/doctors/register`
- `POST /api/v1/auth/refresh` (rotates refresh token)
- `POST /api/v1/auth/logout`

Login/register responses include:

- `user.token` (JWT access token for mobile app)
- `refreshToken` (opaque token stored server-side with rotation)

## Scripts

- `npm run lint`
- `npm run test`
- `npm run test:e2e`
- `npm run build`
