<?php

declare(strict_types=1);

namespace App\Backend\User\Persistence;

use App\Generated\Transfers\UserTransfer;

interface UserRepositoryInterface
{
    /**
     * @param string $email
     *
     * @return UserTransfer|null
     */
    public function findOneByEmail(string $email): ?UserTransfer;
}
