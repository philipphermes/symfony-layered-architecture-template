<?php

namespace App\Backend\User\Persistence;

use App\Generated\Transfers\UserTransfer;

interface UserEntityManagerInterface
{
    /**
     * @param UserTransfer $userTransfer
     *
     * @return UserTransfer
     *
     * @throws \Exception
     */
    public function persist(UserTransfer $userTransfer): UserTransfer;
}
