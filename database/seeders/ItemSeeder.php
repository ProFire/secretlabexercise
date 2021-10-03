<?php
declare(strict_types=1);
namespace Database\Seeders;

use Cake\Chronos\Chronos;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ItemSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        DB::table('items')->insert([
            "name" => "mykey",
            "value" => "value1",
            "created_at" => Chronos::parse("2021-01-01 00:00:00"),
            "updated_at" => Chronos::parse("2021-01-01 00:00:00"),
        ]);
        DB::table('items')->insert([
            "name" => "mykey",
            "value" => "value2",
            "created_at" => Chronos::parse("2021-01-01 01:00:00"),
            "updated_at" => Chronos::parse("2021-01-01 01:00:00"),
        ]);
    }
}
