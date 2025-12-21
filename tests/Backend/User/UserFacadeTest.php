<?php

declare(strict_types=1);

namespace App\Tests\Backend\User;

use App\Backend\User\Business\UserFacadeInterface;
use App\Generated\Transfers\UserTransfer;
use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

class UserFacadeTest extends KernelTestCase
{
    private Connection $connection;

    /**
     * @return void
     */
    protected function setUp(): void
    {
        self::bootKernel();

        $this->connection = self::getContainer()->get(Connection::class);
        $this->connection->beginTransaction();
    }

    /**
     * @return void
     */
    protected function tearDown(): void
    {
        if ($this->connection->isTransactionActive()) {
            $this->connection->rollBack();
        }

        parent::tearDown();
    }

    /**
     * @return void
     */
    public function testPersistUser(): void
    {
        $userTransfer = self::getContainer()->get(UserFacadeInterface::class)->persistUser(
            new UserTransfer()->setEmail('test@email.com')->setId(null));

        self::assertNotNull($userTransfer->getId());
        self::assertSame($userTransfer->getEmail(), $userTransfer->getEmail());

        $userTransferUpdated = self::getContainer()->get(UserFacadeInterface::class)->persistUser(
            (clone $userTransfer)->setEmail('test2@email.com'));

        self::assertSame($userTransfer->getId(), $userTransferUpdated->getId());
        self::assertNotSame($userTransfer->getEmail(), $userTransferUpdated->getEmail());
        self::assertNotEquals($userTransfer->getUpdatedAt(), $userTransferUpdated->getUpdatedAt());
    }

    /**
     * @return void
     */
    public function testPersistUserAndIdAndEmailWasNotProvided(): void
    {
        $this->expectExceptionMessage('Email or Id required');

        self::getContainer()->get(UserFacadeInterface::class)->persistUser(new UserTransfer());
    }

    /**
     * @return void
     */
    public function testFindOneByEmail(): void
    {
        $persistedUserTransfer = self::getContainer()->get(UserFacadeInterface::class)->persistUser(
            new UserTransfer()->setEmail('test@email.com'));

        $userTransfer = self::getContainer()->get(UserFacadeInterface::class)->findOneByEmail(
            $persistedUserTransfer->getEmail()
        );

        self::assertNotNull($userTransfer->getId());
    }

    /**
     * @return void
     */
    public function testFindOneByEmailAndWasNotFound(): void
    {
        $userTransfer = self::getContainer()->get(UserFacadeInterface::class)->findOneByEmail(
            'test@email.com'
        );

        self::assertNull($userTransfer);
    }
}
