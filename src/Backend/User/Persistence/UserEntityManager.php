<?php

declare(strict_types=1);

namespace App\Backend\User\Persistence;

use App\Backend\User\Persistence\Mapper\UserMapper;
use App\Generated\Transfers\UserTransfer;
use Doctrine\ORM\EntityManagerInterface;

class UserEntityManager implements UserEntityManagerInterface
{
    public function __construct(
        private readonly EntityManagerInterface $entityManager,
        private readonly UserRepositoryInterface $userRepository,
        private readonly UserMapper $userMapper,
    ) {}

    /**
     * @inheritDoc
     */
    public function persist(UserTransfer $userTransfer): UserTransfer
    {
        if (!$userTransfer->getEmail() && !$userTransfer->getId()) {
            throw new \Exception('Email or Id required');
        }

        $userEntity = null;
        if ($userTransfer->getId()) {
            $userEntity = $this->userRepository->findOneById($userTransfer->getId());
        }

        $userEntity = $this->userMapper->mapTransferToEntity($userTransfer, $userEntity);

        if (!$userEntity->getId()) {
            $this->entityManager->persist($userEntity);
        }

        $this->entityManager->flush();

        return $this->userMapper->mapEntityToTransfer($userEntity);
    }
}
