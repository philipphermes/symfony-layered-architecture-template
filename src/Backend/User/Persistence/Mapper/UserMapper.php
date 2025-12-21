<?php

declare(strict_types=1);

namespace App\Backend\User\Persistence\Mapper;

use App\Backend\User\Persistence\Entity\UserEntity;
use App\Generated\Transfers\UserTransfer;

class UserMapper
{
    /**
     * @param UserEntity $entity
     *
     * @return UserTransfer
     */
    public function mapEntityToTransfer(UserEntity $entity): UserTransfer
    {
        return new UserTransfer()
            ->setId($entity->getId())
            ->setEmail($entity->getEmail())
            ->setCreatedAt($entity->getCreatedAt())
            ->setUpdatedAt($entity->getUpdatedAt());
    }

    /**
     * @param UserTransfer $userTransfer
     *
     * @return UserEntity
     */
    public function mapTransferToEntity(UserTransfer $userTransfer, ?UserEntity $userEntity): UserEntity
    {
        return ($userEntity ?? new UserEntity())->setEmail(
            $userTransfer->getEmail() ?? $userEntity->getEmail()
        );
    }
}
