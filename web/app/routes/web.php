<?php

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
