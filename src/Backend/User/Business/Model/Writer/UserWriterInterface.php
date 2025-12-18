<?php

namespace App\Backend\User\Business\Model\Writer;

use App\Generated\Transfers\UserTransfer;

interface UserWriterInterface
{
    /**
     * @param UserTransfer $userTransfer
     *
     * @return UserTransfer
     */
    public function persistUser(UserTransfer $userTransfer): UserTransfer;
}
