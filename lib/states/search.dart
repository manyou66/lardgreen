// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:lardgreen/models/product_model.dart';
import 'package:lardgreen/models/user_model.dart';
import 'package:lardgreen/states/show_detail_product.dart';
import 'package:lardgreen/utility/my_constant.dart';
import 'package:lardgreen/utility/my_firebase.dart';
import 'package:lardgreen/widgets/show_form.dart';
import 'package:lardgreen/widgets/show_progress.dart';
import 'package:lardgreen/widgets/show_text.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var productModels = <ProductModel>[];
  var searchProductModels = <ProductModel>[];

  bool load = true;

  final debouncer = Debouncer(milliSecound: 500);

  Map<int, String> mapDocIdUsers = {};
  Map<int, String> mapDocIdPosition = {};
  Map<int, String> mapNameShop = {};

  @override
  void initState() {
    super.initState();
    readAllProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: newAppBar(),
      body: load
          ? const ShowProgress()
          : ListView.builder(
              itemCount: searchProductModels.length,
              itemBuilder: (context, index) => LayoutBuilder(
                  builder: (context, BoxConstraints boxConstraints) {
                return InkWell(
                  onTap: () {
                    int key = searchProductModels[index].timeAdd.seconds;
                    print(
                        'You tab $key, docIdUser ==> ${mapDocIdUsers[key]}, docIdPosition = ${mapDocIdPosition}');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowDetailProduct(
                              docIdUser: mapDocIdUsers[key].toString(),
                              docIdProduct: mapDocIdPosition[key].toString(),
                              productModel: searchProductModels[index]),
                        ));
                  },
                  child: Card(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          width: boxConstraints.maxWidth * 0.5 - 4,
                          height: boxConstraints.maxWidth * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShowText(
                                lable: searchProductModels[index].name,
                                textStyle: MyConstant().h2Style(),
                              ),
                              ShowText(
                                  lable: searchProductModels[index].detail),
                              ShowText(
                                lable: mapNameShop[searchProductModels[index].timeAdd.seconds].toString(),
                                textStyle: MyConstant().h3ActionStyle(),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: boxConstraints.maxWidth * 0.5 - 4,
                          height: boxConstraints.maxWidth * 0.4,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Image.network(
                            searchProductModels[index].urlProduct,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
    );
  }

  AppBar newAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: MyConstant.dark,
      elevation: 0,
      title: ShowForm(
        label: 'Search',
        iconData: Icons.search,
        changeFunc: (p0) {
          debouncer.run(() {
            if (searchProductModels.isNotEmpty) {
              searchProductModels.clear();
              searchProductModels.addAll(productModels);
            }
            searchProductModels = searchProductModels
                .where((element) =>
                    element.name.toLowerCase().contains(p0.toLowerCase()))
                .toList();
            setState(() {});
          });
        },
      ),
    );
  }

  Future<void> readAllProduct() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('typeUser', isEqualTo: 'seller')
        .get()
        .then((value) async {
      for (var element in value.docs) {
        String docIdUser = element.id;
        print('docIdUser ==> $docIdUser');

        UserModle userModle =
            await MyFirebase().processFindUserModel(uid: docIdUser);

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

              String docIdProduct = item.id;
              mapDocIdUsers[productModel.timeAdd.seconds] = docIdUser;
              mapDocIdPosition[productModel.timeAdd.seconds] = docIdProduct;
              mapNameShop[productModel.timeAdd.seconds]= userModle.name;
            }
          }
        });
      }

      searchProductModels.addAll(productModels);
      load = false;
      setState(() {});
    });
  }
}

class Debouncer {
  final int milliSecound;
  Timer? timer;
  VoidCallback? voidCallback;

  Debouncer({
    required this.milliSecound,
    this.timer,
    this.voidCallback,
  });

  run(VoidCallback voidCallback) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(microseconds: milliSecound), voidCallback);
  }
}
