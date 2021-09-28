<?php
declare(strict_types=1);

use App\Http\Controllers\Api\ObjectController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::get("/object/get_all_records", [ObjectController::class, "list"]);
Route::get('/object/{id}', [ObjectController::class, "view", "id"]);
Route::post("/object", [ObjectController::class, "create"]);

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});