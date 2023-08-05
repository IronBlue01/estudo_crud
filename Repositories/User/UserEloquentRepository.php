<?php

namespace Repositories\User;

use App\Models\User;

class UserEloquentRepository implements UserRepository
{
    public function __construct(
        public readonly User $model
    ) {
    }

    public function store(array $data)
    {
        $user =  $this->model->create($data);

        return [
            'user' => $user,
            'token' => $user->createToken('API Token')->plainTextToken
        ];
    }
}