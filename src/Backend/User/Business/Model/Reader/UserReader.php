<?php

declare(strict_types=1);

namespace App\Backend\User\Business\Model\Reader;

use App\Backend\User\Persistence\UserRepositoryInterface;
use App\Generated\Transfers\UserTransfer;

class UserReader implements UserReaderInterface
{
    /**
     * @param UserRepositoryInterface $userRepository
     */
    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
    ) {
    }

    /**
     * @inheritDoc
     */
    public function findOneByEmail(string $email): ?UserTransfer
    {
        return $this->userRepository->findOneByEmail($email);
    }
}
