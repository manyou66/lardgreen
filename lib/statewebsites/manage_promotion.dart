import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lardgreen/models/promotion_model.dart';
import 'package:lardgreen/utility/my_constant.dart';
import 'package:lardgreen/utility/my_dialog.dart';
import 'package:lardgreen/widgets/show_button.dart';
import 'package:lardgreen/widgets/show_form.dart';
import 'package:lardgreen/widgets/show_image.dart';
import 'package:lardgreen/widgets/show_text.dart';

class ManagePromotion extends StatefulWidget {
  const ManagePromotion({Key? key}) : super(key: key);

  @override
  State<ManagePromotion> createState() => _ManagePromotionState();
}

class _ManagePromotionState extends State<ManagePromotion> {
  String? urlImageUpload, namePromotion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: newAppBar(),
      body: Center(
        child: Column(
          children: [
            ShowForm(
              label: 'Name Promotion',
              iconData: Icons.book,
              changeFunc: (p0) {
                namePromotion = p0.trim();
              },
            ),
            urlImageUpload == null
                ? const ShowImage(
                    path: 'images/product.png',
                  )
                : Container(
                    margin: const EdgeInsets.all(8),
                    width: 250,
                    child: Image.network(urlImageUpload!),
                  ),
            ShowButton(
              label: 'GetPhoto',
              pressFunc: () {
                processGetPhoto();
              },
            ),
            ShowButton(
                label: 'Add Promotion',
                pressFunc: () {
                  if (namePromotion?.isEmpty ?? true) {
                    MyDialog(context: context).normalDialog(
                        title: 'Name Promotion',
                        message: 'Please Fill Name Promotion');
                  } else if (urlImageUpload?.isEmpty ?? true) {
                    MyDialog(context: context).normalDialog(
                        title: 'No Photo ?', message: 'Please Get Photo');
                  } else {
                    processInsertPromotion();
                  }
                }),
          ],
        ),
      ),
    );
  }

  AppBar newAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: MyConstant.dark,
      title: ShowText(
        lable: 'Manage Promotion',
        textStyle: MyConstant().h2Style(),
      ),
    );
  }

  Future<void> processGetPhoto() async {
    var result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      var imageByte = await result.readAsBytes();
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference reference = storage.ref().child('promotion/promote${Random().nextInt(1000000)}.jpg');
      UploadTask uploadTask = reference.putData(
          imageByte, SettableMetadata(contentType: 'image/jpg'));
      await uploadTask.whenComplete(() async {
        await reference.getDownloadURL().then((value) {
          var urlImage = value;
          //print('urlImage ==>$urlImage');
          urlImageUpload = value;
          setState(() {});
        });
      });
    }
  }

  Future<void> processInsertPromotion() async {
    DateTime dateTime = DateTime.now();

    PromotionModel promotionModel = PromotionModel(
        name: namePromotion!,
        url: urlImageUpload!,
        timeAdd: Timestamp.fromDate(dateTime));

    await FirebaseFirestore.instance
        .collection('promotion')
        .doc()
        .set(promotionModel.toMap())
        .then((value) => Navigator.pop(context));
  }
}
