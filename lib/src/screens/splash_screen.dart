import 'package:ecommerce/src/controllers/product_controller.dart';
import 'package:ecommerce/src/models/route_argument.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/splash_screen_controller.dart';
import '../../chat/global.dart' as global;

import '../controllers/product_controller.dart' as proCon;

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    // initDynamicLinks();
    loadData();
  }

  // Future initDynamicLinks() async {

  //   FirebaseDynamicLinks.instance.onLink(

  //       onSuccess: (PendingDynamicLinkData dynamicLink) async {

  //         final Uri deepLink = dynamicLink?.link;
  //         if (deepLink != null) {
  //           var queryParam = deepLink.queryParameters;
  //           print(queryParam);
  //           var proId = queryParam['proId'];
  //           print(proId);
  //           print('here in dynamic link $proId ');

  //           ProductController().listenForProduct(productId: global.dynamicLinkId, message: "Wait a minute");
  //           Navigator.of(context).pushNamed('/Product',
  //           arguments: new RouteArgument(param: [ProductController().product, "categorized_products_grid"], id: global.dynamicLinkId));

  //         }
  //       },
  //       onError: (OnLinkErrorException e) async {
  //         print('onLinkError');
  //         print(e.message);
  //       }
  //   );

  //  final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
  //  final Uri deepLink = data?.link;
  //  print('nwo we are here');
  //  print(deepLink);
  //  if (deepLink != null) {
  //     var queryParam = deepLink.queryParameters;
  //     print(queryParam);
  //     var proId = queryParam['proId'];
  //     print(proId);
  //     print('here in dynamic link $proId ');

  //     ProductController().listenForProduct(productId: global.dynamicLinkId, message: "Wait a minute");
  //     Navigator.of(context).pushNamed('/Product',
  //     arguments: new RouteArgument(param: [ProductController().product, "categorized_products_grid"], id: global.dynamicLinkId));

  //  }
  // }

  void loadData() async {
    print('here in load data');
    _con.progress.addListener(() async {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      // if(global.dynamicLinkId == "" || global.dynamicLinkId == null ){

      // }
      if (progress == 100) {
        try {
          //  print("in try block");
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);

          // } else {
          //  Fluttertoast.showToast(msg: " we are in the else block ${widget.proId}");
          // ProductController().listenForProduct(productId: global.dynamicLinkId, message: "Wait a minute");
          // Navigator.of(context).pushNamed('/Product',
          // arguments: new RouteArgument(param: [ProductController().product, "categorized_products_grid"], id: global.dynamicLinkId));
          // global.dynamicLinkId = null;
          // }
        } catch (e) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/icon/icon.png',
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
