<?php

use Illuminate\Http\Request;
use App\Task;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register php routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "php" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/tasks', function (Request $request) {
//    $validator =
    return view('tasks');
})->middleware('auth:node');

Route::get('/tasks/{task}', function (Request $request) {
    return view('task');
})->middleware('auth:node');

Route::post('/tasks/{task}', function (Request $request) {
    //
})->middleware('auth:node');

Route::delete('/tasks/{task}', function (Request $request) {
    //
})->middleware('auth:node');
