import 'dart:convert';

import 'package:ecommerce/src/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/i18n.dart';
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../repository/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../../chat/global.dart' as global;



class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  bool isPromoApplied = false;
  double discountPrice = 0;
  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }


  void listenForCarts({String message}) async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts() async {
    listenForCarts(message: S.current.carts_refreshed_successfuly);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      listenForCarts();
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.the_product_was_removed_from_your_cart(_cart.product.name)),
      ));
    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    total=0;
    taxAmount=0;
    carts.forEach((cart) {
      subTotal += cart.quantity * cart.product.price; //if(cart.product.store.)
      if (Helper.canDelivery(carts: carts)) {
        deliveryFee = cart.product.store.deliveryFee;
      }
      //deliveryFee += cart.product.store.deliveryFee;
      taxAmount = (subTotal + deliveryFee) * cart.product.store.defaultTax / 100;
    });
    //deliveryFee = carts[0].product.store.deliveryFee;
    //taxAmount = (subTotal + deliveryFee) * carts[0].product.store.defaultTax / 100;
    total = subTotal + taxAmount + deliveryFee;
    setState(() {});
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <double.parse(cart.product.itemsAvailable)){
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void promoCode(BuildContext context) {

    print("user id in promo");
    print(currentUser.value.id);
    final _formKey = GlobalKey<FormState>();
    TextEditingController promo = TextEditingController();
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () async {

        if (_formKey.currentState.validate()) {
          if(isPromoApplied) {
            Fluttertoast.showToast(
              msg: 'Code already applied!',
              toastLength: Toast.LENGTH_SHORT,

            );
            return null;
          }
          Fluttertoast.showToast(
            msg: 'Please wait a moment!',
            toastLength: Toast.LENGTH_SHORT,

          );
          print('https://bobla.me/api/promo/${promo.text}/${currentUser.value.id}');
          final response = await http.get('https://bobla.me/api/promo/${promo.text}/${currentUser.value.id}');
          if (response.statusCode == 200) {
            print(response.body);
            var r = json.decode(response.body);

//            total = total - ((total * int.parse(r['discount']))/100);
            discountPrice = ((total * int.parse(r['discount']))/100);
            global.discountedPrice = discountPrice;
            isPromoApplied = true;
            global.isPromoApplied = true;
            setState((){
              total = total - ((total * int.parse(r['discount']))/100);
            });

            Fluttertoast.showToast(
              msg: 'Code Applied!',
              toastLength: Toast.LENGTH_SHORT,
            );
            Navigator.pop(context);
          } else if (response.statusCode == 404) {
            Fluttertoast.showToast(
              msg: 'Code not Valid!',
              toastLength: Toast.LENGTH_SHORT,

            );
          }
        }

      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Enter Promo Code"),
      content:Form(
          key: _formKey,
          child: TextFormField(
            controller: promo,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: InputDecoration(
                hintText: 'Enter Promo Code'
            ),
          )
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }



  void goCheckout(BuildContext context) {
    if (!currentUser.value.profileCompleted()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).completeYourProfileDetailsToContinue),
        action: SnackBarAction(
          label: S.of(context).settings,
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/Settings');
          },
        ),
      ));
    } else {
        Navigator.of(context).pushNamed('/DeliveryPickup');
      }
  }
}
