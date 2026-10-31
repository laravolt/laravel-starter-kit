<?php

declare(strict_types=1);

use NunoMaduro\Essentials\Configurables\ForceScheme;

it('forces https in production unless APP_FORCE_HTTPS turns it off', function (): void {
    expect(config('essentials.'.ForceScheme::class))->toBeTrue();

    putenv('APP_FORCE_HTTPS=false');

    try {
        $config = require config_path('essentials.php');
    } finally {
        putenv('APP_FORCE_HTTPS');
    }

    expect($config[ForceScheme::class])->toBeFalse();
});
