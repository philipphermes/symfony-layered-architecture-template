<?php

declare(strict_types=1);

namespace App\Backend\User\Business;

use App\Generated\Transfers\UserTransfer;

interface UserFacadeInterface
{
    /**
     * @param string $email
     *
     * @return UserTransfer|null
     */
    public function findOneByEmail(string $email): ?UserTransfer;

    /**
     * @param UserTransfer $userTransfer
     *
     * @return UserTransfer
     */
    public function persistUser(UserTransfer $userTransfer): UserTransfer;
}
