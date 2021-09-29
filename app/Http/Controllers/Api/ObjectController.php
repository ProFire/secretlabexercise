<?php
declare(strict_types=1);
namespace App\Http\Controllers\Api;

use App\Models\Item;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Routing\Controller;

/**
 * Object controller that interacts with the Item model
 */
class ObjectController extends Controller
{
    /**
     * Get the latest value from the name
     * Optionally allows latest value from timestamp in the query string
     * timestamp can be in epoch seconds or valid datetime string
     * 
     * @param Request $request The request object
     * @param string $name The name of the key to get the value from
     * @return JsonResponse with the latest value from the name
     */
    public function view(Request $request, string $name): JsonResponse
    {
        if ($request->query("timestamp") != "") {
            $item = Item::getLatestBefore($name, $request->query("timestamp"));
        } else {
            $item = Item::getLatest($name);
        }
        // /*DEBUG*/ print_r($item);exit;

        // If no item is found, return 404
        if (empty($item)) {
            return response()
                ->json([
                    'status' => 404,
                    'errors' => [
                        "Object not found",
                    ],
                ])
            ;
        }

        $value = json_decode($item->value, true);
        // /*DEBUG*/ var_dump($value);exit;

        if ($value === null) {
            // JSON decode failed. Value is just plain string, so respond as string
            return response()
                ->json($item->value)
            ;
        }
        // Return the decoded JSON as an array
        return response()
                ->json($value)
            ;
    }

    /**
     * Creates a new name and value store
     * Allows for multiple name/value pairs to be stored
     * The json string from the request body can contain multiple name/value pairs
     * 
     * @param Request $request The request object
     * @return Response Empty string
     */
    public function create(Request $request): JsonResponse
    {
        // Get the input data
        // /*DEBUG*/ echo "<pre>"; print_r($request->getContent()); echo "</pre>";exit;
        $requestBody = json_decode($request->getContent(), true);
        // /*DEBUG*/ print_r($requestBody);exit;
        
        foreach ($requestBody as $name => $value) {
            $item = new Item();

            // Prepare for storage
            $item->name = $name;
            $item->value = $value;

            // Save
            $item->save();
        }


        return response()
            ->json("")
        ;
    }

    /**
     * Returns the list of the name/value records
     * 
     * @return Response with the list of name/value records in JSON
     */
    public function list(): JsonResponse
    {
        $item = Item::select(['name', 'value'])
            ->get()
        ;
        return response()
            ->json($item)
        ;
    }
}