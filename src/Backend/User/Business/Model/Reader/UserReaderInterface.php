<?php

namespace App\Backend\User\Business\Model\Reader;

use App\Generated\Transfers\UserTransfer;

interface UserReaderInterface
{
    /**
     * @param string $email
     *
     * @return UserTransfer|null
     */
    public function findOneByEmail(string $email): ?UserTransfer;
}
