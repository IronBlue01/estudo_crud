<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterUserRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|unique:users,email',
            'password' => 'required|confirmed|min:6',
            'password_confirmation' => 'required'
        ];
    }

    public function messages()
    {
        return [
            '*.required' => 'O campo :attribute é obrigatório',
        ];
    }

    public function bodyParameters()
    {
        return [
            'name' => [
                'description' => 'O nome do gerente.',
                'example' => 'José Silva',
            ],
            'email' => [
                'description' => 'E-mail do gerente.',
                'example' => 'jose@gmail.com',
            ],
            'password' => [
                'description' => 'Senha do gerente.',
                'example' => '1234abc',
            ],
            'password_confirmation' => [
                'description' => 'Senha do gerente deve ser enviada duas vezes para confirmação.',
                'example' => '1234abc',
            ],
        ];
    }

}