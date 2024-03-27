import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final pageController = PageController();

  final _itemIndex = 0.obs;
  int get itemIndex => _itemIndex.value;
  set itemIndex(int val) => _itemIndex.value = val;
}
