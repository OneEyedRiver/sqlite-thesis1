<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth; 
class UserController extends Controller
{
         public function showMenu()
    {
        return view('user.menu');
    }

             public function userOnly()
    {
        return view('user.only');
    }


  public function sellView(Request $request)
    {

        $cats = $request->get('cat_name');
        

        if(!$cats){
        $userID=Auth::id();
    
        
        $products = Product::where('seller_id', $userID)->get();
        $categories = Product::select('product_category')->distinct()->get();

return view('user.sellView', [
    'products' => $products,
    'categories'=> $categories
]);
}

else{
        $userID=Auth::id();
     
        
        $products = Product::where('seller_id', $userID)->
        where('product_category', $cats)->get();
        $categories = Product::select('product_category')->distinct()->get();

return view('user.sellView', [
    'products' => $products,
    'categories'=> $categories
]);
    
}


    }
}
