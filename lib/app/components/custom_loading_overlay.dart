import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../config/translations/strings_enum.dart';
import '../../utils/constants.dart';

showLoadingOverLay({
  required Future<dynamic> Function() asyncFunction,
  String? msg,
}) async {
  await Get.showOverlay(asyncFunction: () async {
    try{
      await asyncFunction();
    } catch(error) {
      rethrow;
    }
  }, loadingWidget: Center(
    child: _getLoadingIndicator(msg: msg),
  ), opacity: 0.7,
    opacityColor: Colors.black,
  );
}

Widget _getLoadingIndicator({String? msg}){
  final theme = Get.theme;
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: 20.w,
      vertical: 10.h,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      color: theme.cardColor,
      border: Border.all(color: theme.dividerColor),
    ),
    child: Column(mainAxisSize: MainAxisSize.min,children: [
      Image.asset(Constants.logo,height: 45.h,),
      SizedBox(width: 8.h,),
      Text(msg ?? Strings.loading.tr,style: Get.theme.textTheme.bodyLarge),
    ],),
  );
}