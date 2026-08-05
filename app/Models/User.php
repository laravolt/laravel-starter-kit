<?php

declare(strict_types=1);

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Notifications\Notifiable;
use Laravolt\Platform\Models\User as BaseUser;
use Laravolt\Suitable\AutoFilter;
use Laravolt\Suitable\AutoSearch;
use Laravolt\Suitable\AutoSort;
use Override;

#[Fillable(['name', 'email', 'username', 'password', 'status', 'timezone'])]
#[Hidden(['password', 'remember_token'])]
final class User extends BaseUser
{
    use AutoFilter, AutoSearch, AutoSort;

    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    #[Override]
    protected $casts = [
        'email_verified_at' => 'datetime',
    ];
}
