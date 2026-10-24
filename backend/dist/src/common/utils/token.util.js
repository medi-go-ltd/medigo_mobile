"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateRefreshToken = generateRefreshToken;
exports.hashRefreshToken = hashRefreshToken;
exports.generatePasswordResetToken = generatePasswordResetToken;
exports.hashPasswordResetToken = hashPasswordResetToken;
exports.generateEmailVerificationCode = generateEmailVerificationCode;
exports.hashEmailVerificationCode = hashEmailVerificationCode;
exports.parseDurationToMs = parseDurationToMs;
exports.expiresAtFromDuration = expiresAtFromDuration;
const crypto_1 = require("crypto");
function generateRefreshToken() {
    return (0, crypto_1.randomBytes)(48).toString('hex');
}
function hashRefreshToken(token) {
    return (0, crypto_1.createHash)('sha256').update(token).digest('hex');
}
function generatePasswordResetToken() {
    return (0, crypto_1.randomBytes)(32).toString('hex');
}
function hashPasswordResetToken(token) {
    return (0, crypto_1.createHash)('sha256').update(token).digest('hex');
}
function generateEmailVerificationCode() {
    const n = (0, crypto_1.randomBytes)(3).readUIntBE(0, 3) % 1_000_000;
    return n.toString().padStart(6, '0');
}
function hashEmailVerificationCode(code) {
    return (0, crypto_1.createHash)('sha256').update(code.trim()).digest('hex');
}
function parseDurationToMs(duration) {
    const match = /^(\d+)([smhd])$/i.exec(duration.trim());
    if (!match) {
        return 3_600_000;
    }
    const value = Number(match[1]);
    const unit = match[2].toLowerCase();
    const multipliers = {
        s: 1000,
        m: 60_000,
        h: 3_600_000,
        d: 86_400_000,
    };
    return value * (multipliers[unit] ?? 3_600_000);
}
function expiresAtFromDuration(duration) {
    return new Date(Date.now() + parseDurationToMs(duration));
}
//# sourceMappingURL=token.util.js.map