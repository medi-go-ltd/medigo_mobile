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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const auth_service_1 = require("./auth.service");
const register_doctor_dto_1 = require("./dto/register-doctor.dto");
const register_patient_dto_1 = require("./dto/register-patient.dto");
const login_dto_1 = require("./dto/login.dto");
const refresh_token_dto_1 = require("./dto/refresh-token.dto");
const auth_response_dto_1 = require("../common/dto/auth-response.dto");
let AuthController = class AuthController {
    authService;
    constructor(authService) {
        this.authService = authService;
    }
    registerDoctor(body) {
        return this.authService.registerDoctor(body);
    }
    registerPatient(body) {
        return this.authService.registerPatient(body);
    }
    login(body) {
        return this.authService.login(body);
    }
    refresh(body) {
        return this.authService.refresh(body);
    }
    logout(body) {
        return this.authService.logout(body);
    }
};
exports.AuthController = AuthController;
__decorate([
    (0, common_1.Post)('doctors/register'),
    (0, swagger_1.ApiOkResponse)({ type: auth_response_dto_1.AuthResponseDto }),
    (0, swagger_1.ApiConflictResponse)({ description: 'Email already registered' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_doctor_dto_1.RegisterDoctorDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "registerDoctor", null);
__decorate([
    (0, common_1.Post)('patients/register'),
    (0, swagger_1.ApiOkResponse)({ type: auth_response_dto_1.AuthResponseDto }),
    (0, swagger_1.ApiConflictResponse)({ description: 'Email already registered' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_patient_dto_1.RegisterPatientDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "registerPatient", null);
__decorate([
    (0, common_1.Post)('login'),
    (0, swagger_1.ApiOkResponse)({ type: auth_response_dto_1.AuthResponseDto }),
    (0, swagger_1.ApiUnauthorizedResponse)({ description: 'Invalid credentials' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [login_dto_1.LoginDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "login", null);
__decorate([
    (0, common_1.Post)('auth/refresh'),
    (0, swagger_1.ApiOkResponse)({ type: auth_response_dto_1.AuthResponseDto }),
    (0, swagger_1.ApiUnauthorizedResponse)({ description: 'Invalid or expired refresh token' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [refresh_token_dto_1.RefreshTokenDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "refresh", null);
__decorate([
    (0, common_1.Post)('auth/logout'),
    (0, swagger_1.ApiOkResponse)({ type: auth_response_dto_1.MessageResponseDto }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [refresh_token_dto_1.RefreshTokenDto]),
    __metadata("design:returntype", void 0)
], AuthController.prototype, "logout", null);
exports.AuthController = AuthController = __decorate([
    (0, swagger_1.ApiTags)('auth'),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [auth_service_1.AuthService])
], AuthController);
//# sourceMappingURL=auth.controller.js.map