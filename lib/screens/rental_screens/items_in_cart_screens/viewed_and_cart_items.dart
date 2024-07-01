import 'package:badges/badges.dart';
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/rental_screens/items_in_cart_screens/cart_items_page.dart';
import 'package:betterhouse/screens/rental_screens/items_in_cart_screens/viewed_items_screen.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartAndViewedItemsScreen extends StatefulWidget {
  const CartAndViewedItemsScreen({Key? key}) : super(key: key);

  @override
  State<CartAndViewedItemsScreen> createState() => _CartAndViewedItemsScreenState();
}

class _CartAndViewedItemsScreenState extends State<CartAndViewedItemsScreen> {


Future<void> getPropertyInCart()async{

}
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPropertyInCart();
  }

  @override
  Widget build(BuildContext context) {    
    AppDataProvider dataProvider =Provider.of<AppDataProvider>(context, listen: false);
    return DefaultTabController(length: 2,
     child: Scaffold(
      appBar: AppBar(title:const Text("Ulizohusika nazo"),
      bottom: TabBar(
        tabs: [
        Badge(child:const Padding(
          padding:EdgeInsets.only(bottom:15),
          child: Text("Kapuni"),
        ),badgeColor: kGreyColor, position:const BadgePosition(end: -20,top: -10), badgeContent: Text(dataProvider.currentUser["cartItems"] !=null?dataProvider.currentUser["cartItems"].length.toString():"0" ,)),
        Badge(child:const Padding(
          padding:EdgeInsets.only(bottom:15),
          child:Text("Ulizotazama"),
        ),badgeColor: kGreyColor,position:const BadgePosition(end: -20,top: -10), badgeContent: Text(dataProvider.currentUser["viewedItems"] !=null?dataProvider.currentUser["viewedItems"].length.toString():"0" ,))]),
      ),
      body:const TabBarView(children: [
        CartItemsPage(),ViewedItemsPage(),
      ])
     )
     );
    }
}