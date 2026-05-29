import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import type { RequestHandler } from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(helmet() as RequestHandler);
  app.enableCors();

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );
  app.useGlobalFilters(new AllExceptionsFilter());

  const apiPrefix = process.env.API_PREFIX ?? 'api/v1';
  app.setGlobalPrefix(apiPrefix);

  const config = new DocumentBuilder()
    .setTitle('Medigo Backend API')
    .setDescription('Medigo MVP backend APIs')
    .setVersion('1.0.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  const port = Number(process.env.PORT ?? 3001);
  await app.listen(port);
  console.log(`Medigo API listening on http://localhost:${port}/${apiPrefix}`);
}
void bootstrap();
