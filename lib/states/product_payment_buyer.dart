import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lardgreen/main.dart';
import 'package:lardgreen/models/order_product_model.dart';
import 'package:lardgreen/models/user_model.dart';
import 'package:lardgreen/utility/my_constant.dart';
import 'package:lardgreen/utility/my_dialog.dart';
import 'package:lardgreen/utility/my_firebase.dart';
import 'package:lardgreen/widgets/show_button.dart';
import 'package:lardgreen/widgets/show_progress.dart';
import 'package:lardgreen/widgets/show_text.dart';

class ProductPaymentBuyer extends StatefulWidget {
  const ProductPaymentBuyer({Key? key}) : super(key: key);

  @override
  State<ProductPaymentBuyer> createState() => _ProductPaymentBuyerState();
}

class _ProductPaymentBuyerState extends State<ProductPaymentBuyer> {
  var user = FirebaseAuth.instance.currentUser;
  var orderProductModels = <OrderProductModel>[];
  var sellerUserModels = <UserModle>[];
  var dateOrders = <String>[];
  var docIdOrders = <String>[];
  bool load = true;
  bool? haveData;

  @override
  void initState() {
    super.initState();
    readOrderProduct();
  }

  Future<void> readOrderProduct() async {
    if (orderProductModels.isNotEmpty) {
      orderProductModels.clear();
      sellerUserModels.clear();
      dateOrders.clear();
      docIdOrders.clear();
    }

    await FirebaseFirestore.instance
        .collection('order')
        .where('uidBuyer', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'delivery')
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        haveData = false;
      } else {
        haveData = true;
        for (var element in value.docs) {
          OrderProductModel orderProductModel =
              OrderProductModel.fromMap(element.data());
          orderProductModels.add(orderProductModel);
          UserModle userModle = await MyFirebase()
              .processFindUserModel(uid: orderProductModel.uidSeller);
          sellerUserModels.add(userModle);
          dateOrders.add(MyFirebase().changeTimeStampToDateTime(
              timestamp: orderProductModel.timeOrder));
          docIdOrders.add(element.id);
        }
      }

      load = false;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return load
        ? const ShowProgress()
        : haveData!
            ? newContent()
            : Center(
                child: ShowText(
                lable: 'ไม่มีรายการจ่ายเงิน',
                textStyle: MyConstant().h1Style(),
              ));
  }

  Widget newContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ShowText(
            lable: 'สินค้าที่รอรับ',
            textStyle: MyConstant().h1Style(),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: orderProductModels.length,
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShowText(
                  lable: 'ร้าน : ${sellerUserModels[index].name}',
                  textStyle: MyConstant().h2Style(),
                ),
                ShowText(
                  lable: 'โทร: ${sellerUserModels[index].phone}',
                  textStyle: MyConstant().h2Style(),
                ),
                ShowText(lable: dateOrders[index]),
                Divider(
                  color: MyConstant.dark,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: orderProductModels[index].nameProducts.length,
                  itemBuilder: (context, index2) => Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ShowText(
                            lable:
                                orderProductModels[index].nameProducts[index2]),
                      ),
                      Expanded(
                        flex: 1,
                        child: ShowText(
                            lable: orderProductModels[index]
                                .priceProducts[index2]),
                      ),
                      Expanded(
                        flex: 1,
                        child: ShowText(
                            lable: orderProductModels[index]
                                .amountProducts[index2]),
                      ),
                      Expanded(
                        flex: 1,
                        child: ShowText(
                            lable:
                                orderProductModels[index].sumProducts[index2]),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: MyConstant.dark,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ShowText(
                            lable: 'ผลรวม : ',
                            textStyle: MyConstant().h2Style(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ShowText(
                        lable: orderProductModels[index].total,
                        textStyle: MyConstant().h2Style(),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShowButton(
                        label: 'ยืนยันรับสินค้า',
                        pressFunc: () {
                          MyDialog(context: context).actionDialog(
                              title: 'ยืนยันรับสินค้า',
                              message: 'ได้รับสินค้า สมบูรณ์',
                              label1: 'ยืนยัน',
                              label2: 'ไม่ยืนยัน',
                              presFunc1: () {
                                Navigator.pop(context);
                                processConfirmReceiveProduct(
                                  docIdOrder: docIdOrders[index],
                                  orderProductModel: orderProductModels[index],
                                );
                              },
                              presFunc2: () {
                                Navigator.pop(context);
                              });
                        }),
                  ],
                ),
                Divider(
                  color: MyConstant.dark,
                  thickness: 3,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> processConfirmReceiveProduct(
      {required OrderProductModel orderProductModel,
      required String docIdOrder}) async {
    Map<String, dynamic> map = {};
    map['status'] = 'finish';

    UserModle userModle = await MyFirebase()
        .processFindUserModel(uid: orderProductModel.uidSeller);

    await FirebaseFirestore.instance
        .collection('order')
        .doc(docIdOrder)
        .update(map)
        .then((value) async {
      await MyFirebase()
          .processSentNotification(
              title: 'ได้รับสินค้าแล้ว',
              body: 'ของคุณมากครับ',
              token: userModle.token)
          .then((value) {
        readOrderProduct();
      });
    });
  }
}
