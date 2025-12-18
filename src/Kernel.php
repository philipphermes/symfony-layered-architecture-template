<?php

declare(strict_types=1);

namespace App;

use PhilippHermes\Symfony\LayeredArchitecture\Shared\Twig\TwigPathCompilerPass;
use PhilippHermes\Symfony\LayeredArchitecture\Shared\Twig\TwigPathRegistrator\Plugin\BackendTwigRegistratorPlugin;
use PhilippHermes\Symfony\LayeredArchitecture\Shared\Twig\TwigPathRegistrator\Plugin\FrontendTwigRegistratorPlugin;
use Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\HttpKernel\Kernel as BaseKernel;

class Kernel extends BaseKernel
{
    use MicroKernelTrait;

    /**
     * @inheritDoc
     */
    protected function build(ContainerBuilder $container): void
    {
        $twigPathCompilerPass = new TwigPathCompilerPass([
            new BackendTwigRegistratorPlugin(),
            new FrontendTwigRegistratorPlugin(),
        ]);

        $container->addCompilerPass($twigPathCompilerPass);
    }
}
