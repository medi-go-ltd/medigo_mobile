import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { MessageResponseDto } from '../common/dto/auth-response.dto';

@ApiTags('health')
@Controller('health')
export class HealthController {
  @Get()
  @ApiOkResponse({ type: MessageResponseDto })
  check() {
    return { success: true, message: 'ok' };
  }
}
