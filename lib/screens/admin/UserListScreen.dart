import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:quizeapp/models/UserModel.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/screens/admin/components/UserItemWidget.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../../main.dart';

class UserListScreen extends StatelessWidget {
  static String tag = '/UserListScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('Users', showBack: false, elevation: 0.0),
      body: PaginateFirestore(
        itemBuilderType: PaginateBuilderType.listView,
        itemBuilder: (index, context, documentSnapshot) {
          UserModel data = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

          return UserItemWidget(data);
        },
        shrinkWrap: true,
        padding: EdgeInsets.all(8),
        // orderBy is compulsory to enable pagination
        query: userService.getUserList()!,
        itemsPerPage: DocLimit,
        bottomLoader: Loader(),
        initialLoader: Loader(),
        emptyDisplay: noDataWidget(),
        onError: (e) => Text(e.toString(), style: primaryTextStyle()).center(),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
