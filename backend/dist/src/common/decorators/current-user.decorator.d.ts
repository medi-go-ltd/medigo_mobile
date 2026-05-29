export interface JwtUser {
    sub: string;
    role: 'PATIENT' | 'DOCTOR' | 'ADMIN';
    email: string;
}
export declare const CurrentUser: (...dataOrPipes: unknown[]) => ParameterDecorator;
