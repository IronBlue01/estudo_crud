<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginUserRequest;
use App\Http\Requests\RegisterUserRequest;
use Illuminate\Http\Request;
use App\Models\User;
use App\Services\UserService;
use Illuminate\Support\Facades\Auth;
use App\Traits\ApiResponser;

class AuthController extends Controller
{
    use ApiResponser;

    public function __construct(
        public readonly UserService $userService,
    ) {
    }

    /**
     * Registra um novo Usuario
     *
     * Efutua o registro de um novo usuario
     * @group Auth
     * @responseFile Response/auth/RegistroCriado.json
    */
    public function register(RegisterUserRequest $request)
    {
        $auth = $this->userService->register($request->validated());

        return $this->success([
            'user'  => $auth['user'],
            'token' => $auth['token']
        ]);
    }

    /**
     * Login Usuario
     *
     * Efetua login de um gerente
     * @group Auth
     * @responseFile Response/auth/LoginUsuario.json
     */
    public function login(LoginUserRequest $request)
    {
        $attr = $request->validated();

        if (!Auth::attempt($attr)) {
            return $this->error('Credentials not match', 401);
        }

        return response()->json([
            'message' => 'success',
            'token' => auth()->user()->createToken('API Token')->plainTextToken
        ],201);
    }

    /**
     * Dados Usuario logado
     *
     * Retorna os dados do Usuario logado 
     * @group Auth
     * @responseFile Response/auth/Detalhar.json
     */
    public function userAuthenticated()
    {
       return auth()->user();
    }

    /**
     * Logout Usuario
     *
     * Efetua o logout do Usuario 
     * @group Auth
     * @responseFile Response/auth/Logout.json
     */
    public function logout()
    {
        auth()->user()->tokens()->delete();

        return response()->json(['message' => 'Token Removido']);
    }
}