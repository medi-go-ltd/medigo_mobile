"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const core_1 = require("@nestjs/core");
const throttler_1 = require("@nestjs/throttler");
const validate_env_1 = require("./config/validate-env");
const prisma_module_1 = require("./prisma/prisma.module");
const auth_module_1 = require("./auth/auth.module");
const health_module_1 = require("./health/health.module");
const patients_module_1 = require("./patients/patients.module");
const doctors_module_1 = require("./doctors/doctors.module");
const appointments_module_1 = require("./appointments/appointments.module");
const admin_module_1 = require("./admin/admin.module");
const files_module_1 = require("./files/files.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                validate: validate_env_1.validate,
            }),
            throttler_1.ThrottlerModule.forRootAsync({
                useFactory: () => [
                    {
                        ttl: Number(process.env.THROTTLE_TTL ?? 60),
                        limit: Number(process.env.THROTTLE_LIMIT ?? 100),
                    },
                ],
            }),
            prisma_module_1.PrismaModule,
            health_module_1.HealthModule,
            auth_module_1.AuthModule,
            patients_module_1.PatientsModule,
            doctors_module_1.DoctorsModule,
            appointments_module_1.AppointmentsModule,
            admin_module_1.AdminModule,
            files_module_1.FilesModule,
        ],
        controllers: [],
        providers: [
            {
                provide: core_1.APP_GUARD,
                useClass: throttler_1.ThrottlerGuard,
            },
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map