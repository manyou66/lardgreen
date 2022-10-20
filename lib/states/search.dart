import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lardgreen/models/product_model.dart';
import 'package:lardgreen/utility/my_constant.dart';
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
              itemBuilder: (context, index) => ShowText(
                lable: searchProductModels[index].name,
                textStyle: MyConstant().h2Style(),
              ),
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
        changeFunc: (p0) {},
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
