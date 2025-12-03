import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sk_chos_tool/components/log_panel.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/controller/log_controller.dart';
import 'package:sk_chos_tool/controller/main_controller.dart';
import 'package:sk_chos_tool/page/about_view.dart';
import 'package:sk_chos_tool/page/advance_view.dart';
import 'package:sk_chos_tool/page/app_view.dart';
import 'package:sk_chos_tool/page/decky_view.dart';
import 'package:sk_chos_tool/page/ota_view.dart';
import 'package:sk_chos_tool/page/general_view.dart';
import 'package:sk_chos_tool/page/tool_view.dart';

import '../const.dart';
import '../components/menu_item.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.title});

  final String title;

  MainController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    // Initialize LogController
    Get.put(LogController());

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: AppSizes.menuWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Center(
                      child: Text('Sk Tool', style: AppTextStyles.menuTitle),
                    ),
                  ),
                  Expanded(
                    child: SkSingleChildScrollView(
                      child: Obx(() {
                        return MenuView(
                          key: ValueKey(controller.itemIndex),
                          titles: const [
                            '常用',
                            '工具',
                            'Decky 插件',
                            '软件&游戏',
                            '高级',
                            '自动更新',
                            '关于'
                          ],
                          pageController: controller.pageController,
                          icons: const [
                            Icon(
                              FontAwesomeIcons.toggleOn,
                            ),
                            Icon(
                              FontAwesomeIcons.wrench,
                            ),
                            Icon(
                              FontAwesomeIcons.plug,
                              size: 24,
                            ),
                            Icon(
                              FontAwesomeIcons.appStoreIos,
                            ),
                            Icon(
                              FontAwesomeIcons.gear,
                            ),
                            Icon(
                              FontAwesomeIcons.rotate,
                            ),
                            Icon(
                              FontAwesomeIcons.circleInfo,
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      GeneralView(),
                      ToolView(),
                      DeckyView(),
                      AppView(),
                      AdvanceView(),
                      OtaView(),
                      AboutView(),
                    ],
                  ),
                ),
                const LogPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
