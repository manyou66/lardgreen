import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lardgreen/models/user_model.dart';
import 'package:lardgreen/statewebsites/manage_promotion.dart';
import 'package:lardgreen/utility/my_constant.dart';
import 'package:lardgreen/widgets/show_button.dart';
import 'package:lardgreen/widgets/show_text.dart';
import 'package:lardgreen/widgets/show_text_button.dart';

import '../widgets/show_progress.dart';

class CheckApproveUser extends StatefulWidget {
  const CheckApproveUser({Key? key}) : super(key: key);

  @override
  State<CheckApproveUser> createState() => _CheckApproveUserState();
}

class _CheckApproveUserState extends State<CheckApproveUser> {
  bool load = true;
  var userModels = <UserModle>[];
  var docIdUsers = <String>[];

  @override
  void initState() {
    super.initState();
    readData();
  }

  Future<void> readData() async {
    if (userModels.isNotEmpty) {
      userModels.clear();
      docIdUsers.clear();
    }

    await FirebaseFirestore.instance
        .collection('user')
        .where('typeUser', isEqualTo: 'seller')
        .get()
        .then((value) {
      for (var item in value.docs) {
        UserModle userModle = UserModle.fromMap(item.data());
        userModels.add(userModle);
        docIdUsers.add(item.id);
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
          ShowButton(
              label: 'Manage Promotion',
              pressFunc: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManagePromotion(),
                    ));
              }),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: MyConstant.dark,
      ),
      body: load
          ? const ShowProgress()
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              children: [
                ShowText(
                  lable: 'Approve Seller User',
                  textStyle: MyConstant().h1Style(),
                ),
                Divider(
                  color: MyConstant.primary,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ShowText(
                        lable: 'ชื่อ',
                        textStyle: MyConstant().h2Style(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ShowText(
                        lable: 'อีเมล์',
                        textStyle: MyConstant().h2Style(),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ShowText(
                        lable: 'ที่อยู่',
                        textStyle: MyConstant().h2Style(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ShowText(
                        lable: 'โทรศัพท์',
                        textStyle: MyConstant().h2Style(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ShowText(
                        lable: 'สถานะ',
                        textStyle: MyConstant().h2Style(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: userModels.length,
                  itemBuilder: (context, index) => Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ShowText(
                          lable: userModels[index].name,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ShowText(
                          lable: userModels[index].email,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ShowText(
                          lable: userModels[index].address,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ShowText(
                          lable: userModels[index].phone,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ShowText(
                          lable: userModels[index].status,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ShowTextButton(
                            label: userModels[index].status == 'approve'
                                ? 'Wait'
                                : 'Approve',
                            pressFunc: () {
                              print('index ==> $index');
                              processEditStatus(index: index);
                            }),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: MyConstant.primary,
                ),
              ],
            ),
    );
  }

  Future<void> processEditStatus({required int index}) async {
    Map<String, dynamic> data = {};

    if (userModels[index].status == 'wait') {
      data['status'] = 'approve';
    } else {
      data['status'] = 'wait';
    }

    await FirebaseFirestore.instance
        .collection('user')
        .doc(docIdUsers[index])
        .update(data)
        .then((value) {
      readData();
    });
  }
}
