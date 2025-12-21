<?php

declare(strict_types=1);

namespace App\Backend\User\Business\Model\Writer;

use App\Backend\User\Persistence\UserEntityManagerInterface;
use App\Generated\Transfers\UserTransfer;

class UserWriter implements UserWriterInterface
{
    /**
     * @param UserEntityManagerInterface $userEntityManager
     */
    public function __construct(
        private readonly UserEntityManagerInterface $userEntityManager,
    ) {
    }

    /**
     * @inheritDoc
     */
    public function persistUser(UserTransfer $userTransfer): UserTransfer
    {
        return $this->userEntityManager->persist($userTransfer);
    }
}
