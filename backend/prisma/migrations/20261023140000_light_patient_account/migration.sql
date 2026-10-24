-- Light patient accounts: optional profile fields + social auth columns

ALTER TABLE "User" ALTER COLUMN "passwordHash" DROP NOT NULL;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "authProvider" TEXT;
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "providerSubject" TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS "User_authProvider_providerSubject_key"
  ON "User"("authProvider", "providerSubject");

ALTER TABLE "Patient" ALTER COLUMN "dateOfBirth" DROP NOT NULL;
ALTER TABLE "Patient" ALTER COLUMN "gender" DROP NOT NULL;
ALTER TABLE "Patient" ALTER COLUMN "genderAtBirth" DROP NOT NULL;
ALTER TABLE "Patient" ALTER COLUMN "houseNumber" DROP NOT NULL;
ALTER TABLE "Patient" ALTER COLUMN "street" DROP NOT NULL;
ALTER TABLE "Patient" ALTER COLUMN "postcode" DROP NOT NULL;
