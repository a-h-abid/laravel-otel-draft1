<?php

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('users/add', function () {
    $faker = Faker\Factory::create();

    $user = App\Models\User::create([
        'name' => $faker->name(),
        'email' => $faker->unique()->safeEmail(),
        'password' => Hash::make('secret'),
    ]);

    return [
        'status' => 'user added',
        'data' => $user,
    ];
});

Route::get('users/list', function () {
    return Cache::remember('users:all', now()->addSeconds(10), function () {
        return App\Models\User::all()->toArray();
    });
});
