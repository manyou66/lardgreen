import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:lardgreen/models/bank_model.dart';
import 'package:lardgreen/models/user_model.dart';

class MyFirebase {
  Future<void> processSentNotification(
      {required String title,
      required String body,
      required String token}) async {
    String path =
        'https://www.androidthai.in.th/bigc/noti/apiNotilardgreen.php?isAdd=true&token=$token&title=$title&body=$body';
    await Dio().get(path).then((value) {
      print('Success Sent Notification');
    });
  }

  Future<List<BankModel>> processFindBookModel({required String uid}) async {
    var bankModels = <BankModel>[];
    var result = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('bank')
        .get();
    for (var element in result.docs) {
      BankModel bankModel = BankModel.fromMap(element.data());
      bankModels.add(bankModel);
    }
    return bankModels;
  }

  Future<UserModle> processFindUserModel({required String uid}) async {
    var result =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    UserModle userModle = UserModle.fromMap(result.data()!);
    return userModle;
  }

  String changeTimeStampToDateTime({required Timestamp timestamp}) {
    DateFormat dateFormat = DateFormat('dd MMM yyyy HH:mm');
    DateTime dateTime = timestamp.toDate();
    String result = dateFormat.format(dateTime);
    return result;
  }
}
