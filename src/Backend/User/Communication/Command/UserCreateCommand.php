<?php

declare(strict_types=1);

namespace App\Backend\User\Communication\Command;

use App\Backend\User\Business\UserFacadeInterface;
use App\Generated\Transfers\UserTransfer;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\QuestionHelper;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Question\Question;

#[AsCommand(name: 'user:create', description: 'Created or updates a user')]
class UserCreateCommand extends Command
{
    public function __construct(private readonly UserFacadeInterface $userFacade) {
        parent::__construct();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $helper = new QuestionHelper();
        $emailQuestion = new Question('Email: ', null);

        $result = $helper->ask($input, $output, $emailQuestion);

        $output->writeln($result);

        $userTransfer = $this->userFacade->persistUser(new UserTransfer()->setEmail($result));
        $output->writeln('User created successfully');

        return Command::SUCCESS;
    }
}
