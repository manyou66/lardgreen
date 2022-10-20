import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lardgreen/models/user_model.dart';
import 'package:lardgreen/states/about.dart';
import 'package:lardgreen/states/authen.dart';
import 'package:lardgreen/states/helper.dart';
import 'package:lardgreen/states/home.dart';
import 'package:lardgreen/states/product_cancel_buyer.dart';
import 'package:lardgreen/states/product_confirm_buyer.dart';
import 'package:lardgreen/states/product_finish_buyer.dart';
import 'package:lardgreen/states/product_order_buyer.dart';
import 'package:lardgreen/states/product_payment_buyer.dart';
import 'package:lardgreen/states/product_paymented_buyer.dart';
import 'package:lardgreen/states/search.dart';
import 'package:lardgreen/states/show_chart.dart';
import 'package:lardgreen/states/user_manual.dart';
import 'package:lardgreen/utility/my_constant.dart';
import 'package:lardgreen/utility/my_dialog.dart';
import 'package:lardgreen/widgets/show_icon_button.dart';
import 'package:lardgreen/widgets/show_image.dart';
import 'package:lardgreen/widgets/show_progress.dart';
import 'package:lardgreen/widgets/show_signout.dart';
import 'package:lardgreen/widgets/show_text.dart';

import '../widgets/show_menu.dart';

class MainHome extends StatefulWidget {
  const MainHome({
    Key? key,
  }) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  bool load = true;
  bool? logined;

  var widgetGuests = <Widget>[];
  var widgetBuyer = <Widget>[];
  var widgets = <Widget>[];
  int indexWidget = 0;
  var user = FirebaseAuth.instance.currentUser;
  UserModle? userModle;
  String? titleMessage, bodyMessage, token;

  @override
  void initState() {
    super.initState();

    widgetGuests.add(const Home());
    widgetGuests.add(const Helper());
    widgetGuests.add(const About());

    widgetBuyer.add(const Home());
    widgetBuyer.add(const ProductOrderBuyer());
    widgetBuyer.add(const ProductConfirmBuyer());
    widgetBuyer.add(const ProductPaymentedBuyer());
    widgetBuyer.add(const ProductPaymentBuyer());
    widgetBuyer.add(const ProductFinishBuyer());
    widgetBuyer.add(const ProductCancelBuyer());

    readDataUser();
  }

  Future<void> processMessageing() async {
    await FirebaseMessaging.instance.getToken().then((value) async {
      token = value.toString();
      print('token สำหรับ ผู้ซื้อ ==> $token');

      Map<String, dynamic> map = {};

      map['token'] = token;

      await FirebaseFirestore.instance
          .collection('user')
          .doc(user!.uid)
          .update(map)
          .then((value) {
        print('Update Token Success');
      });
    });
    // for Open App
    FirebaseMessaging.onMessage.listen((event) {
      titleMessage = event.notification!.title;
      bodyMessage = event.notification!.body;
      MyDialog(context: context)
          .normalDialog(title: titleMessage!, message: bodyMessage!);
    });

    // for Colse App
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      titleMessage = event.notification!.title;
      bodyMessage = event.notification!.body;
      print('message ==> $titleMessage, $bodyMessage');
    });
  }

  Future<void> readDataUser() async {
    await FirebaseAuth.instance.authStateChanges().listen((event) async {
      if (event == null) {
        logined = false;
        widgets = widgetGuests;
      } else {
        logined = true;
        widgets = widgetBuyer;

        processMessageing();

        await FirebaseFirestore.instance
            .collection('user')
            .doc(user!.uid)
            .get()
            .then((value) {
          userModle = UserModle.fromMap(value.data()!);
        });
      }
      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          ShowIconButton(
            iconData: Icons.search_outlined,
            pressFunc: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Search(),
                  ));
            },
          ),
          ShowIconButton(
              iconData: Icons.shopping_cart_outlined,
              pressFunc: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShowChart(),
                    ));
              }),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: MyConstant.dark,
      ),
      drawer: load
          ? null
          : logined!
              ? drawerBuyer(context)
              : drawerGuest(context),
      body: load ? const ShowProgress() : widgets[indexWidget],
    );
  }

  Drawer drawerGuest(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const ShowImage(),
            decoration: BoxDecoration(
              color: MyConstant.dark.withOpacity(0.5),
            ),
            accountName: ShowText(
              lable: 'ยังไม่ได้ลงชื่อใช้งาน',
              textStyle: MyConstant().h5Style(),
            ),
            accountEmail: ShowText(
              lable: 'กรุณาลงชื่อใช้งาน โดยคลิกที่สมาชิก',
              textStyle: MyConstant().h5Style(),
            ),
          ),
          ShowMenu(
              title: 'Home',
              iconData: Icons.home_outlined,
              tapFunc: () {
                Navigator.pop(context);
                setState(() {
                  indexWidget = 0;
                });
              }),
          ShowMenu(
              title: 'คู่มือการใช้งาน',
              iconData: Icons.manage_search_outlined,
              tapFunc: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserManual(),
                  ),
                );
                setState(() {
                  indexWidget = 1;
                });
              }),
          ShowMenu(
              title: 'เกี่ยวกับ',
              iconData: Icons.album_outlined,
              tapFunc: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => About(),
                  ),
                );
                setState(() {
                  indexWidget = 2;
                });
              }),
          const Spacer(),
          ShowMenu(
            subTitle: 'ลงชื่อใช้งาน หรือสมัครสมาชิก',
            title: 'สมาชิก Login',
            iconData: Icons.card_membership,
            tapFunc: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Authen(),
                  ),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Drawer drawerBuyer(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: MyConstant.light.withOpacity(0.5),
              ),
              currentAccountPicture: ShowImage(),
              accountName: ShowText(
                lable: userModle!.name,
                textStyle: MyConstant().h2Style(),
              ),
              accountEmail: ShowText(
                lable: userModle!.email,
                textStyle: MyConstant().h3Style(),
              ),
            ),
            ShowMenu(
              title: 'เลือกซื้อสินค้า',
              iconData: Icons.filter_1,
              tapFunc: () {
                Navigator.pop(context);
                setState(() {
                  indexWidget = 0;
                });
              },
            ),
            ShowMenu(
              title: 'รายการสั่งสินค้า',
              subTitle: 'Status Order',
              iconData: Icons.filter_2,
              tapFunc: () {
                Navigator.pop(context);
                setState(() {
                  indexWidget = 1;
                });
              },
            ),
            ShowMenu(
              title: 'รายการรอชำระสินค้า',
              subTitle: 'Status Payment',
              iconData: Icons.filter_3,
              tapFunc: () {
                Navigator.pop(context);
                setState(() {
                  indexWidget = 2;
                });
              },
            ),
            ShowMenu(
              title: 'รายการจ่ายเงินแล้ว',
              subTitle: 'Status Paymented',
              iconData: Icons.filter_4,
              tapFunc: () {
                Navigator.pop(context);
                setState(() {
                  indexWidget = 3;
                });
              },
            ),
            ShowMenu(
              title: 'สินค้าที่รอรับ',
              subTitle: 'Status Delivery',
              iconData: Icons.filter_5,
              tapFunc: () {
                Navigator.pop(context);
                setState(() {
                  indexWidget = 4;
                });
              },
            ),
            ShowMenu(
              title: 'รายการส่งของสำเร็จ',
              subTitle: 'Status Finish',
              iconData: Icons.filter_6,
              tapFunc: () {
                Navigator.pop(context);
                setState(() {
                  indexWidget = 5;
                });
              },
            ),
            ShowMenu(
              title: 'รายการสินค้ายกเลิก',
              subTitle: 'Status Cancel',
              iconData: Icons.filter_7,
              tapFunc: () {
                Navigator.pop(context);
                setState(() {
                  indexWidget = 6;
                });
              },
            ),
            const ShowSignOut(),
          ],
        ),
      ),
    );
  }
}
