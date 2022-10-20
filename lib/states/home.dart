import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:lardgreen/models/product_model.dart';
import 'package:lardgreen/models/promotion_model.dart';
import 'package:lardgreen/models/user_model.dart';
import 'package:lardgreen/states/list_product_of_seller.dart';
import 'package:lardgreen/states/show_detail_product.dart';
import 'package:lardgreen/utility/my_constant.dart';
import 'package:lardgreen/widgets/show_image.dart';
import 'package:lardgreen/widgets/show_progress.dart';
import 'package:lardgreen/widgets/show_text.dart';
import 'package:lardgreen/widgets/show_title.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var userModels = <UserModle>[];
  var productModels = <ProductModel>[];
  var docIdUsers = <String>[];
  var docIdProducts = <String>[];
  String? docIdUser;
  bool load = true;
  var widgetPromotions = <Widget>[];

  var promotionModels = <PromotionModel>[];

  @override
  void initState() {
    super.initState();
    readAllSeller();
    readAllBanner();
  }

  Future<void> readAllSeller() async {
    //for GridView Seller
    await FirebaseFirestore.instance
        .collection('user')
        .where('typeUser', isEqualTo: 'seller')
        .get()
        .then((value) async {
      load = false;

      int i = 1;
      for (var item in value.docs) {
        UserModle userModle = UserModle.fromMap(item.data());
        if (i <= 6) {
          userModels.add(userModle);
        }
        i++;

        docIdUser = item.id;
        docIdUsers.add(docIdUser!);
        await FirebaseFirestore.instance
            .collection('user')
            .doc(docIdUser)
            .collection('product')
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            for (var item in value.docs) {
              ProductModel productModel = ProductModel.fromMap(item.data());
              productModels.add(productModel);
              docIdProducts.add(item.id);
            }
          }
        });
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, Constraints) {
      return load
          ? const ShowProgress()
          : ListView(
              children: [
                const ShowTitle(title: 'โปรโมชั่น'),
                newBanner(Constraints),
                const ShowTitle(title: 'ร้านค้า :'),
                newSellerGroup(),
                const ShowTitle(title: 'สินค้าใหม่:'),
                newProductGroup(),
              ],
            );
    });
  }

  GridView newProductGroup() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 8,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) => InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowDetailProduct(
                  docIdUser: docIdUser!,
                  docIdProduct: docIdProducts[index],
                  productModel: productModels[index]),
            ),
          );
        },
        child: Card(
          color: const Color.fromARGB(255, 241, 90, 141).withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(productModels[index].urlProduct)),
              ShowText(lable: productModels[index].name),
            ],
          ),
        ),
      ),
      itemCount: productModels.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
    );
  }

  GridView newSellerGroup() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ), //column to show

      itemBuilder: (BuildContext context, int index) => InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListProductOfSeller(
                  docIdUser: docIdUsers[index], userModle: userModels[index]),
            ),
          );
        },
        child: Card(
          color: Colors.lime,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: userModels[index].urlAvatar!.isEmpty
                    ? const ShowImage(
                        path: 'images/logo.png',
                      )
                    : Image.network(
                        userModels[index].urlAvatar!,
                        fit: BoxFit.cover,
                      ),
              ),
              ShowText(lable: userModels[index].name),
            ],
          ),
        ),
      ),
      itemCount: userModels.length,
      physics: ScrollPhysics(),
      shrinkWrap: true,
    );
  }

  Widget newBanner(BoxConstraints constraints) {
    return promotionModels.isEmpty
        ? const ShowProgress()
        : ImageSlideshow(
            autoPlayInterval: 3000,
            isLoop: true,
            height: 150,
            children: widgetPromotions,
          );
  }

  Future<void> readAllBanner() async {
    await FirebaseFirestore.instance
        .collection('promotion')
        .orderBy('timeAdd', descending: true)
        .get()
        .then((value) {
      int amount = 0;
      for (var item in value.docs) {
        PromotionModel promotionModel = PromotionModel.fromMap(item.data());
        promotionModels.add(promotionModel);

        if (amount <= 4) {
          widgetPromotions.add(
            Image.network(
              promotionModel.url,
              fit: BoxFit.cover,
            ),
          );
          amount++;
        }
      }
      setState(() {});
    });
  }
}
