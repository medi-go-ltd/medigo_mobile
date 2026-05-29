import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { AllExceptionsFilter } from '../src/common/filters/all-exceptions.filter';

const hasDatabase = process.env.DATABASE_URL?.includes('postgresql');

(hasDatabase ? describe : describe.skip)('Auth (e2e)', () => {
  let app: INestApplication<App>;
  const apiPrefix = process.env.API_PREFIX ?? 'api/v1';
  const uniqueEmail = `patient-${Date.now()}@medigo.test`;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
      }),
    );
    app.useGlobalFilters(new AllExceptionsFilter());
    app.setGlobalPrefix(apiPrefix);
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('registers patient, refreshes token, and logs out', async () => {
    const registerResponse = await request(app.getHttpServer())
      .post(`/${apiPrefix}/patients/register`)
      .send({
        firstName: 'Test',
        lastName: 'Patient',
        dateOfBirth: '1990-01-01',
        gender: 'female',
        genderAtBirth: 'female',
        email: uniqueEmail,
        phoneNumber: '+447700900000',
        address: {
          houseNumber: '1',
          street: 'Test Street',
          postcode: 'SW1A 1AA',
        },
        password: 'SecurePass123!',
      })
      .expect(201);

    const registerBody = registerResponse.body as {
      refreshToken: string;
      user: { token: string };
    };
    expect(registerBody.refreshToken).toBeDefined();
    expect(registerBody.user.token).toBeDefined();

    const refreshResponse = await request(app.getHttpServer())
      .post(`/${apiPrefix}/auth/refresh`)
      .send({ refreshToken: registerBody.refreshToken })
      .expect(201);

    const refreshBody = refreshResponse.body as { refreshToken: string };
    expect(refreshBody.refreshToken).not.toBe(registerBody.refreshToken);

    await request(app.getHttpServer())
      .post(`/${apiPrefix}/auth/logout`)
      .send({ refreshToken: refreshBody.refreshToken })
      .expect(201);

    await request(app.getHttpServer())
      .post(`/${apiPrefix}/auth/refresh`)
      .send({ refreshToken: refreshBody.refreshToken })
      .expect(401);
  });
});
