export declare class SocialSignInDto {
    provider: 'google' | 'apple';
    idToken: string;
    role: 'patient';
    email?: string;
    firstName?: string;
    lastName?: string;
    nonce?: string;
}
