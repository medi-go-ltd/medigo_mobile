"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var PasswordResetMailerService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PasswordResetMailerService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
let PasswordResetMailerService = PasswordResetMailerService_1 = class PasswordResetMailerService {
    configService;
    logger = new common_1.Logger(PasswordResetMailerService_1.name);
    constructor(configService) {
        this.configService = configService;
    }
    sendPasswordResetEmail(email, token) {
        const resetUrl = this.buildResetUrl(email, token);
        const nodeEnv = this.configService.get('NODE_ENV') ?? 'development';
        if (nodeEnv !== 'production') {
            this.logger.log(`Password reset link for ${email}: ${resetUrl} (token: ${token})`);
            return;
        }
        this.logger.warn(`Password reset email not sent in production (no mail provider configured) for ${email}`);
    }
    buildResetUrl(email, token) {
        const baseUrl = this.configService.get('PASSWORD_RESET_URL') ??
            'medigo://reset-password';
        const params = new URLSearchParams({ email, token });
        return `${baseUrl}?${params.toString()}`;
    }
};
exports.PasswordResetMailerService = PasswordResetMailerService;
exports.PasswordResetMailerService = PasswordResetMailerService = PasswordResetMailerService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], PasswordResetMailerService);
//# sourceMappingURL=password-reset-mailer.service.js.map