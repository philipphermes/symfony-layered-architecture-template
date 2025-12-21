<?php

declare(strict_types=1);

namespace App\Backend\User\Persistence;

use App\Backend\User\Persistence\Entity\UserEntity;
use App\Backend\User\Persistence\Mapper\UserMapper;
use App\Generated\Transfers\UserTransfer;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<UserEntity>
 */
class UserRepository extends ServiceEntityRepository implements UserRepositoryInterface
{
    /**
     * @param ManagerRegistry $registry
     * @param UserMapper $userMapper
     */
    public function __construct(
        ManagerRegistry $registry,
        private readonly UserMapper $userMapper,
    ) {
        parent::__construct($registry, UserEntity::class);
    }

    /**
     * @inheritDoc
     */
    public function findOneByEmail(string $email): ?UserTransfer
    {
        $userEntity = $this->findOneBy(['email' => $email]);
        if (!$userEntity) {
            return null;
        }

        return $this->userMapper->mapEntityToTransfer($userEntity);
    }

    /**
     * @inheritDoc
     */
    public function findOneById(int $id): ?UserEntity
    {
        return $this->find($id);
    }
}
