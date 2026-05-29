import { PrismaClient, UserRole, VerificationStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const adminEmail = 'admin@medigo.local';
  const existingAdmin = await prisma.user.findUnique({ where: { email: adminEmail } });
  if (!existingAdmin) {
    await prisma.user.create({
      data: {
        email: adminEmail,
        passwordHash: await bcrypt.hash('Admin123!', 10),
        firstName: 'Medigo',
        lastName: 'Admin',
        role: UserRole.ADMIN,
        verificationStatus: VerificationStatus.APPROVED,
      },
    });
  }
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
