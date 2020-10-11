
import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';

import '../../src/widgets/BrandsIconsCarouselLoadingWidget.dart';

import '../../src/widgets/ProductsGridLoadingWidget.dart';
import '../../src/widgets/CategoriesIconsCarouselLoadingWidget.dart';
import '../widgets/BrandedProductsWidget.dart';
import '../widgets/DeliveryAddressBottomSheetWidget.dart';
import '../../generated/i18n.dart';
import '../../src/widgets/ShoppingCartButtonWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../../src/controllers/home_controller.dart';
import '../../src/helpers/ui_icons.dart';
import '../../src/widgets/BrandsIconsCarouselWidget.dart';
import '../../src/widgets/CategoriesIconsCarouselWidget.dart';
import '../../src/widgets/CategorizedProductsWidget.dart';
import '../../src/widgets/FlashSalesCarouselWidget.dart';
import '../../src/widgets/FlashSalesWidget.dart';
import '../../src/widgets/HomeSliderWidget.dart';
import '../../src/widgets/SearchBarWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';
import 'package:http/http.dart' as http;
import 'post.dart';
import '../models/post.dart';

class BlogWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  const BlogWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _BlogWidgetState createState() => _BlogWidgetState();
}

class _BlogWidgetState extends StateMVC<BlogWidget> with SingleTickerProviderStateMixin{
  Animation animationOpacity;
  AnimationController animationController;

  Future futurePosts;

  fetchPosts() async {
    print("request sent");
    var response =  await http.get(GlobalConfiguration().getString('base_url')+"/api/posts");
    print("request received");
    var j = jsonDecode(response.body);
    return j;

  }




  @override
  void initState() {
    futurePosts = fetchPosts();
    animationController = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    CurvedAnimation curve = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animationOpacity = Tween(begin: 0.0, end: 1.0).animate(curve)..addListener(() {setState(() {});});
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  row(p){
    return  InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostScreen(postData: Post.fromJson(p))),
        );
        },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffeeeeee), width: 1, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  p['featured_image'],
                  height: 75.0,
                  width: 75.0,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(width: 10,),
              Container(width:250,child: Text(p['title'], textAlign: TextAlign.justify,)),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              "Blog Posts",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
//
        ],
      ),
      body: FutureBuilder(
        future: futurePosts,
        builder: (context, snapshot){
          if(snapshot.hasData){

              return Column(
                children: <Widget>[

              for (var p in snapshot.data) row(p)

          ],
          );
          } else if (snapshot.hasError){
            return Text('${snapshot.error}');
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
