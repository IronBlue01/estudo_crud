<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ContatoController extends Controller
{
    /**
     * Display a listing of the resource.
    */
    public function index()
    {
        return response()->json('ContatosController@Index');    
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        return response()->json('ContatosController@Store');    
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        return response()->json('ContatosController@Show');    
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        return response()->json('ContatosController@Update');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        return response()->json('ContatosController@Destroy');    
    }
}
