import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Widgets/DrawerWidget.dart';
import '../widgets/FilterWidget.dart';
import '../models/route_argument.dart';
import '../screens/home.dart';
import '../screens/account.dart';
import '../screens/notifications.dart';
import '../screens/orders.dart';
import '../screens/favorites.dart';
import '../../src/helpers/ui_icons.dart';
import 'package:focus_detector/focus_detector.dart';
import '../../chat/global.dart' as global;
import '../controllers/product_controller.dart';

class PagesWidget extends StatefulWidget {
  dynamic currentTab;
  RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget currentPage = HomeWidget();

  PagesWidget({
    Key key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 2;
    }
  }

  @override
  _PagesWidgetState createState() {
    return _PagesWidgetState();
  }
}

class _PagesWidgetState extends State<PagesWidget> {
  final _resumeDetectorKey = UniqueKey();

  initState() {
    this.initDynamicLinks();
    super.initState();
    _selectTab(widget.currentTab);
  }

  Future initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      print("eraaaaaaaaaaaa");
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        var queryParam = deepLink.queryParameters;
        print(queryParam);
        var proId = queryParam['proId'];
        print(proId);
        print('here in dynamic home link $proId ');
        // global.dynamicLinkId = proId;
        print("global");
        // print(global.dynamicLinkId);
        ProductController()
            .listenForProduct(productId: proId, message: "Wait a minute");
        Navigator.of(context).pushNamed('/Product',
            arguments: new RouteArgument(param: [
              ProductController().product,
              "categorized_products_grid"
            ], id: proId));
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    print('nwo we are here');
    print(deepLink);
    if (deepLink != null) {
      var queryParam = deepLink.queryParameters;
      print(queryParam);
      var proId = queryParam['proId'];
      print(proId);
      print('here in dynamic home link $proId ');
      print("global");
      ProductController()
          .listenForProduct(productId: proId, message: "Wait a minute");
      Navigator.of(context).pushNamed('/Product',
          arguments: new RouteArgument(
              param: [ProductController().product, "categorized_products_grid"],
              id: proId));
    }
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage =
              NotificationsWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage =
              AccountWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 2:
          widget.currentPage =
              HomeWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 3:
          widget.currentPage =
              OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 4:
          widget.currentPage =
              FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      key: _resumeDetectorKey,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: widget.scaffoldKey,
          drawer: DrawerWidget(),
          endDrawer: FilterWidget(onFilter: (filter) {
            Navigator.of(context)
                .pushReplacementNamed('/Pages', arguments: widget.currentTab);
          }),
          body: widget.currentPage,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).accentColor,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            iconSize: 22,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedIconTheme: IconThemeData(size: 25),
            unselectedItemColor: Theme.of(context).hintColor.withOpacity(1),
            currentIndex: widget.currentTab,
            onTap: (int i) {
              this._selectTab(i);
            },
            // this will be set when a new tab is tapped
            items: [
              BottomNavigationBarItem(
                icon: Icon(UiIcons.bell),
                title: new Container(height: 0.0),
              ),
              BottomNavigationBarItem(
                icon: Icon(UiIcons.user_2),
                title: new Container(height: 0.0),
              ),
              BottomNavigationBarItem(
                  title: new Container(height: 5.0),
                  icon: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.4),
                            blurRadius: 40,
                            offset: Offset(0, 15)),
                        BoxShadow(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.4),
                            blurRadius: 13,
                            offset: Offset(0, 3))
                      ],
                    ),
                    child: new Icon(UiIcons.home,
                        color: Theme.of(context).primaryColor),
                  )),
              BottomNavigationBarItem(
                icon: new Icon(UiIcons.inbox),
                title: new Container(height: 0.0),
              ),
              BottomNavigationBarItem(
                icon: new Icon(UiIcons.heart),
                title: new Container(height: 0.0),
              ),
            ],
          ),
        ),
      ),
      onFocusGained: () {
        print('focus gained');
        // print(global.dynamicLinkId);
        // Fluttertoast.showToast(msg: "${global.dynamicLinkId}");
        // print(global.dynamicLinkId);
        // if(global.dynamicLinkId != null){
        //   ProductController().listenForProduct(productId: global.dynamicLinkId, message: "Fetching");
        //   Navigator.of(context).pushNamed('/Product',
        //       arguments: new RouteArgument(param: [ProductController().product, "categorized_products_grid"], id: global.dynamicLinkId));
        //   global.dynamicLinkId = null;
        // }
      },
      onFocusLost: () {
        print('Focus lost, equivalent to onPause or viewDidDisappear');
      },
    );
//    return WillPopScope(
//      onWillPop: () async => false,
//      child: Scaffold(
//        key: widget.scaffoldKey,
//        drawer: DrawerWidget(),
//        endDrawer: FilterWidget(onFilter: (filter) {
//          Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
//        }),
//        body: widget.currentPage,
//        bottomNavigationBar: BottomNavigationBar(
//          type: BottomNavigationBarType.fixed,
//          selectedItemColor: Theme.of(context).accentColor,
//          selectedFontSize: 0,
//          unselectedFontSize: 0,
//          iconSize: 22,
//          elevation: 0,
//          backgroundColor: Colors.transparent,
//          selectedIconTheme: IconThemeData(size: 25),
//          unselectedItemColor: Theme.of(context).hintColor.withOpacity(1),
//          currentIndex: widget.currentTab,
//          onTap: (int i) {
//            this._selectTab(i);
//          },
//          // this will be set when a new tab is tapped
//          items: [
//            BottomNavigationBarItem(
//              icon: Icon(UiIcons.bell),
//              title: new Container(height: 0.0),
//            ),
//            BottomNavigationBarItem(
//              icon: Icon(UiIcons.user_2),
//              title: new Container(height: 0.0),
//            ),
//            BottomNavigationBarItem(
//                title: new Container(height: 5.0),
//                icon: Container(
//                  width: 45,
//                  height: 45,
//                  decoration: BoxDecoration(
//                    color: Theme.of(context).accentColor,
//                    borderRadius: BorderRadius.all(
//                      Radius.circular(50),
//                    ),
//                    boxShadow: [
//                      BoxShadow(
//                          color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
//                      BoxShadow(
//                          color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
//                    ],
//                  ),
//                  child: new Icon(UiIcons.home, color: Theme.of(context).primaryColor),
//                )),
//            BottomNavigationBarItem(
//              icon: new Icon(UiIcons.inbox),
//              title: new Container(height: 0.0),
//            ),
//            BottomNavigationBarItem(
//              icon: new Icon(UiIcons.heart),
//              title: new Container(height: 0.0),
//            ),
//          ],
//        ),
//      ),
//    );
  }
}
