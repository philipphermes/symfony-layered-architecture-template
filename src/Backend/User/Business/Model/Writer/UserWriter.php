<?php

declare(strict_types=1);

namespace App\Backend\User\Business\Model\Writer;

use App\Backend\User\Persistence\UserEntityManagerInterface;
use App\Backend\User\Persistence\UserRepositoryInterface;
use App\Generated\Transfers\UserTransfer;

class UserWriter implements UserWriterInterface
{
    /**
     * @param UserRepositoryInterface $userRepository
     * @param UserEntityManagerInterface $userEntityManager
     */
    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
        private readonly UserEntityManagerInterface $userEntityManager,
    ) {
    }

    /**
     * @inheritDoc
     */
    public function persistUser(UserTransfer $userTransfer): UserTransfer
    {
        $existingUserTransfer = $this->userRepository->findOneByEmail($userTransfer->getEmail());
        if ($existingUserTransfer) {
            $userTransfer->setId($existingUserTransfer->getId());
        }

        return $this->userEntityManager->persist($userTransfer);
    }
}
