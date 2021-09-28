<?php
declare(strict_types=1);
namespace App\Models;

use Cake\Chronos\Chronos;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Item extends Model
{
    use HasFactory;

    /**
     * Get the latest record of "name"
     * 
     * @param string $name The hashkey of the record
     * @return Item The latest record
     */
    public static function getLatest(string $name): ?Item
    {
        return self::where(["name" => $name])
            ->orderBy("created_at", "desc")
            ->first()
        ;
    }

    /**
     * Get the latest record of "name" before the timestamp "datetime"
     * 
     * @param string $name The hashkey of the record
     * @param string $datetime The timestamp in epoch numbers or a valid datetime string
     * @return Item The latest record before the timestamp
     */
    public static function getLatestBefore(string $name, string $datetime): ?Item
    {
        if (is_numeric($datetime)) {
            $datetime = Chronos::create()
                ->timestamp((int)$datetime)
            ;
        } else {
            $datetime = Chronos::parse($datetime);
        }
        return self::where(["name" => $name, ["created_at", "<", $datetime]])
            ->orderBy("created_at", "desc")
            ->first()
        ;
    }
}
