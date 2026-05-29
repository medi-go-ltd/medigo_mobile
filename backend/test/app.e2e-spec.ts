import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { AllExceptionsFilter } from '../src/common/filters/all-exceptions.filter';

describe('Health (e2e)', () => {
  let app: INestApplication<App>;
  const apiPrefix = process.env.API_PREFIX ?? 'api/v1';

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

  it(`GET /${apiPrefix}/health`, () => {
    return request(app.getHttpServer())
      .get(`/${apiPrefix}/health`)
      .expect(200)
      .expect(({ body }) => {
        expect((body as { success: boolean }).success).toBe(true);
      });
  });
});
