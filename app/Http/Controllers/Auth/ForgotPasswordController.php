<?php

declare(strict_types=1);

namespace App\Http\Controllers\Auth;

use App\Models\User;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;

final class ForgotPasswordController extends Controller
{
    /**
     * Display the form to request a password reset link.
     */
    public function show(): View
    {
        return view('auth.forgot');
    }

    /**
     * Send a reset link to the given user.
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate(['email' => ['required', 'email', 'exists:users']]);

        $response = Password::INVALID_USER;

        $user = User::whereEmail($request->email)->first();

        if ($user) {
            $response = resolve('laravolt.password')->sendResetLink($user);
        }

        $email = (string) $request->input('email');

        /** @var array<string, string> $translationParams */
        $translationParams = ['email' => $email, 'emailMasked' => Str::maskEmail($email)];

        return to_route('auth::forgot.show')
            ->with('success', trans(Password::RESET_LINK_SENT, $translationParams));
    }
}
