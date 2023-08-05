<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LoginUserRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'email' => 'required|string|email|',
            'password' => 'required|string|min:6'
        ];
    }

    public function bodyParameters()
    {
        return [
            'email' => [
                'description' => 'E-mail do gerente.',
                'example' => 'fabio@gmail.com',
            ],
            'password' => [
                'description' => 'Senha do gerente.',
                'example' => '123456',
            ],
        ];
    }

}