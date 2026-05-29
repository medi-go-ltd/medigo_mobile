import { Test, TestingModule } from '@nestjs/testing';
import { AppModule } from './app.module';

describe('AppModule', () => {
  it('compiles testing module', async () => {
    const moduleRef: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    expect(moduleRef).toBeDefined();
  });

  beforeEach(async () => {
    const moduleRef: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    expect(moduleRef).toBeDefined();
  });
});
