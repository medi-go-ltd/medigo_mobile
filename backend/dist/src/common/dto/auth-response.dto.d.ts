export declare class AuthUserDto {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    phoneNumber: string | null;
    role: string;
    verificationStatus: string;
    token: string;
}
export declare class AuthResponseDto {
    success: boolean;
    message: string;
    user: AuthUserDto;
    refreshToken: string;
}
export declare class RefreshTokenRequestDto {
    refreshToken: string;
}
export declare class MessageResponseDto {
    success: boolean;
    message: string;
}
