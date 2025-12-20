<?php

declare(strict_types=1);

namespace App\Frontend\Health\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class IndexController extends AbstractController
{
    #[Route('/health', name: 'health')]
    public function __invoke(): Response
    {
        return new Response('OK');
    }
}
