<?php

declare(strict_types=1);

namespace App\Backend\User\Persistence;

use App\Backend\User\Persistence\Entity\UserEntity;
use App\Generated\Transfers\UserTransfer;

interface UserRepositoryInterface
{
    /**
     * @param string $email
     *
     * @return UserTransfer|null
     */
    public function findOneByEmail(string $email): ?UserTransfer;

    /**
     * @param int $id
     *
     * @return UserTransfer|null
     */
    public function findOneById(int $id): ?UserEntity;
}
