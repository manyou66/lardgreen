// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lardgreen/models/bank_model.dart';
import 'package:lardgreen/states/add_account_bank.dart';
import 'package:lardgreen/utility/my_constant.dart';
import 'package:lardgreen/utility/my_dialog.dart';
import 'package:lardgreen/widgets/show_icon_button.dart';
import 'package:lardgreen/widgets/show_progress.dart';
import 'package:lardgreen/widgets/show_text.dart';

class AboutBank extends StatefulWidget {
  final String uid;

  const AboutBank({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<AboutBank> createState() => _AboutBankState();
}

class _AboutBankState extends State<AboutBank> {
  String? docId;
  bool load = true;
  bool? haveData;
  var bankModels = <BankModel>[];
  var docIdBanks = <String>[];

  @override
  void initState() {
    super.initState();
    docId = widget.uid;
    readAccountBank();
  }

  Future<void> readAccountBank() async {
    if (bankModels.isNotEmpty) {
      bankModels.clear();
      docIdBanks.clear();
    }

    await FirebaseFirestore.instance
        .collection('user')
        .doc(docId)
        .collection('bank')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        haveData = false;
      } else {
        haveData = true;
        for (var element in value.docs) {
          BankModel bankModel = BankModel.fromMap(element.data());
          bankModels.add(bankModel);
          docIdBanks.add(element.id);
        }
      }

      load = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAccountBank(
                  docId: docId!,
                ),
              )).then((value) => readAccountBank());
        },
        child: Text('เพิ่ม'),
      ),
      body: load
          ? const ShowProgress()
          : haveData!
              ? ListView.builder(
                  itemCount: bankModels.length,
                  itemBuilder: (context, index) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShowText(
                                lable: bankModels[index].nameBank,
                                textStyle: MyConstant().h2Style(),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ShowText(
                                      lable:
                                          'หมายเลขบัญชี : ${bankModels[index].accountBank}'),
                                ],
                              ),
                              ShowText(
                                  lable:
                                      'ชื่อบัญชี : ${bankModels[index].nameAccountBank}'),
                            ],
                          ),
                          ShowIconButton(
                              iconData: Icons.delete_forever,
                              pressFunc: () {
                                MyDialog(context: context).actionDialog(
                                    title: 'ยืนยันการลบ',
                                    message: 'คุณต้องการลบบัญชีนี้',
                                    label1: 'ลบบัญชี',
                                    label2: 'ยกเลิก',
                                    presFunc1: () async {
                                      print(
                                          'docIdUser = $docId at docIdBank ==> ${docIdBanks[index]}');

                                      await FirebaseFirestore.instance
                                          .collection('user')
                                          .doc(docId)
                                          .collection('bank')
                                          .doc(docIdBanks[index])
                                          .delete()
                                          .then((value) {
                                            readAccountBank();
                                            Navigator.pop(context);
                                          });
                                      
                                    },
                                    presFunc2: () {
                                      Navigator.pop(context);
                                    });
                              }),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: ShowText(
                    lable: 'ยังไม่มีบัญชีธนาคาร',
                    textStyle: MyConstant().h1Style(),
                  ),
                ),
    );
  }
}
