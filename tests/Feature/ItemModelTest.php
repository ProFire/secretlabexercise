<?php
declare(strict_types=1);
namespace Tests\Unit;

use App\Models\Item;
use Tests\TestCase;

class ItemModelTest extends TestCase
{

    /**
     * Item::getLatest test
     *
     * @return void
     */
    public function test_getLatest()
    {
        $this->assertEquals(Item::find(2), Item::getLatest("mykey"));
    }

    /**
     * Item::getLatestBefore test
     *
     * @return void
     */
    public function test_getLatestBefore()
    {
        $this->assertEquals(Item::find(1), Item::getLatestBefore("mykey", "1609461000"));
        $this->assertEquals(Item::find(1), Item::getLatestBefore("mykey", "2021-01-01 00:30:00"));
    }
}
