<?php
declare(strict_types=1);
namespace Tests\Feature;

use Cake\Chronos\Chronos;
use Tests\TestCase;

class ObjectTest extends TestCase
{
    /**
     * Get the latest mykey
     *
     * @return void
     */
    public function test_getLatest()
    {
        $response = $this->get('/api/object/mykey');

        $response->assertOk();
        $response->assertHeader("Content-Type", "application/json"); // Must be JSON
        $response->assertSee("value2"); // Latest value
        $response->assertDontSee("value1"); // Earlier value shouldn't show up
    }

    /**
     * Get the earlier mykey
     *
     * @return void
     */
    public function test_getEarlierTimestamp()
    {
        $response = $this->get('/api/object/mykey?timestamp=' . Chronos::parse("2021-01-01 00:30:00")->timestamp);

        $response->assertOk();
        $response->assertHeader("Content-Type", "application/json"); // Must be JSON
        $response->assertSee("value1"); // Earlier value
        $response->assertDontSee("value2"); // Latest value shouldn't show up
    }

    /**
     * Get the earlier mykey
     *
     * @return void
     */
    public function test_getEarlierDatetime()
    {
        $response = $this->get('/api/object/mykey?timestamp=' . Chronos::parse("2021-01-01 00:30:00")->toDateTimeString());

        $response->assertOk();
        $response->assertHeader("Content-Type", "application/json"); // Must be JSON
        $response->assertSee("value1"); // Earlier value
        $response->assertDontSee("value2"); // Latest value shouldn't show up
    }

    /**
     * Get a nonexistent object
     *
     * @return void
     */
    public function test_getNonexistentObject()
    {
        $response = $this->get('/api/object/doesnotexist');

        $response->assertNotFound();
        $response->assertHeader("Content-Type", "application/json"); // Must be JSON
        $response->assertSee('{"status":404,"errors":["Object not found"]}', false); // Error
        $response->assertDontSee("value2"); // Latest value shouldn't show up
    }

    

    /**
     * Add a new object
     *
     * @return void
     */
    public function test_postObject()
    {
        // Initial database count
        $this->assertDatabaseCount('items', 2);

        $response = $this->postJson('/api/object/', [
            "mykey" => "value3",
            "anotherKey" => "{a:1,b:2}",
        ]);

        $response->assertOk();
        $response->assertHeader("Content-Type", "application/json"); // Must be JSON
        $response->assertSee('Object[s] created', false); // Generic Message
        
        // New database count
        $this->assertDatabaseCount('items', 4);
    }

    

    /**
     * Get list of objects
     *
     * @return void
     */
    public function test_getAllRecords()
    {
        $response = $this->get('/api/object/get_all_records');

        $response->assertOk();
        $response->assertHeader("Content-Type", "application/json"); // Must be JSON
        $response->assertJson([
            [
                "name" => "mykey",
                "value" => "value1",
            ],
            [
                "name" => "mykey",
                "value" => "value2",
            ],
        ]); // All the records
    }
}
