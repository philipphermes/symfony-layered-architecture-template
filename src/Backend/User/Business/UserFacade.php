<?php

declare(strict_types=1);

namespace App\Backend\User\Business;

use App\Backend\User\Business\Model\Reader\UserReaderInterface;
use App\Backend\User\Business\Model\Writer\UserWriterInterface;
use App\Generated\Transfers\UserTransfer;

class UserFacade implements UserFacadeInterface
{
    /**
     * @param UserReaderInterface $userReader
     * @param UserWriterInterface $userWriter
     */
    public function __construct(
        private readonly UserReaderInterface $userReader,
        private readonly UserWriterInterface $userWriter,
    ) {
    }

    /**
     * @inheritDoc
     */
    public function findOneByEmail(string $email): ?UserTransfer
    {
        return $this->userReader->findOneByEmail($email);
    }

    /**
     * @inheritDoc
     */
    public function persistUser(UserTransfer $userTransfer): UserTransfer
    {
        return $this->userWriter->persistUser($userTransfer);
    }
}
