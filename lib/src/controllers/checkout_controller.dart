import 'dart:async';
import 'dart:convert';

import 'package:ecommerce/src/models/address.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../models/cart.dart';
import '../models/credit_card.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../repository/cart_repository.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'package:http/http.dart' as http;

class CheckoutController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  Payment payment;
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  double subTotal = 0.0;
  double total = 0.0;
  CreditCard creditCard = new CreditCard();
  bool loading = true;
  GlobalKey<ScaffoldState> scaffoldKey;

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  void listenForCarts({String message, bool withAddOrder = false}) async {
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
      calculateSubtotal();
      if (withAddOrder != null && withAddOrder == true) {
        addOrder(carts);
      }
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void addOrder(List<Cart> carts) async {
    carts.forEach( (_cart) {
      Order _order = new Order();
      _order.productOrders = new List<ProductOrder>();
      _order.tax = _cart.product.store.defaultTax;
      _order.deliveryFee = payment.method == 'Pay on Pickup' ? 0 : _cart.product.store.deliveryFee;
      OrderStatus _orderStatus = new OrderStatus();
      _orderStatus.id = '1'; // TODO default order status Id
      _order.orderStatus = _orderStatus;
      _order.deliveryAddress =payment.method == 'Pay on Pickup' ? new Address() : settingRepo.deliveryAddress.value;
      _order.hint = ' ';
      ProductOrder _productOrder = new ProductOrder();
      _productOrder.quantity = _cart.quantity;
      _productOrder.price = _cart.product.price;

      _productOrder.product = _cart.product;
      _productOrder.options = _cart.options;
      _order.productOrders.add(_productOrder);
      orderRepo.addOrder(_order, this.payment).then((value) {
        if (value is Order) {
          setState(() {
            loading = false;
          });
        }
      });

    });


    }

    checkPromo() async {
      final response =
          await http.get('https://bobla.me/api/promo/${userRepo.currentUser.value.id}');
      print(response.body);
      print('we are in checkPromo');
      if (response.statusCode == 200) {
        var r = json.decode(response.body);
        print(r['discount']);
        return r['discount'];
      } else {
        throw Exception('Failed to load album');
      }
    }

  void calculateSubtotal() async {
    subTotal = 0;
    deliveryFee = 0;
    carts.forEach((cart) {
      subTotal += cart.quantity * cart.product.price;
    });
    if (payment?.method != 'Pay on Pickup') {
      deliveryFee = carts[0].product.store.deliveryFee;
    }
    taxAmount = (subTotal + deliveryFee) * carts[0].product.store.defaultTax / 100;
    total = subTotal + taxAmount + deliveryFee;
//    var discount = await checkPromo();
//    print(discount);
//    if(discount.toString().isNotEmpty){
//      total = total - discount ;
//    }

    setState(() {});
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.payment_card_updated_successfully),
      ));
    });
  }
}
