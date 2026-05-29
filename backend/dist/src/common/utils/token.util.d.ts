export declare function generateRefreshToken(): string;
export declare function hashRefreshToken(token: string): string;
export declare function parseDurationToMs(duration: string): number;
export declare function expiresAtFromDuration(duration: string): Date;
