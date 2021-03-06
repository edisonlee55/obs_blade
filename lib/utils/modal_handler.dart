import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'styling_helper.dart';

// A translucent color that is painted on top of the blurred backdrop as the
// dialog's background color
// Extracted from https://developer.apple.com/design/resources/.
const Color kDialogColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xCCF2F2F2),
  darkColor: Color(0xBF1E1E1E),
);

const double kDialogBlurAmount = 20.0;

class ModalHandler {
  static Future<T> showBaseDialog<T>({
    @required BuildContext context,
    @required Widget dialogWidget,
    bool barrierDismissible = false,
  }) async =>
      showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => dialogWidget,
      );

  static Future<T> showBaseBottomSheet<T>({
    @required BuildContext context,
    @required Widget modalWidget,
    bool useRootNavigator = true,
    bool barrierDismissible = false,
  }) async =>
      showModalBottomSheet(
        context: context,
        useRootNavigator: useRootNavigator,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 1.5,
              ),
              child: modalWidget,
            ),
          ),
        ),
      );

  static Future<T> showBaseCupertinoBottomSheet<T>({
    @required BuildContext context,
    @required
        Widget Function(BuildContext, ScrollController) modalWidgetBuilder,
    bool useRootNavigator = true,
  }) async =>
      CupertinoScaffold.showCupertinoModalBottomSheet(
        expand: false,
        context: context,
        backgroundColor: Colors.transparent,
        useRootNavigator: useRootNavigator,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: StylingHelper.sigma_blurry,
            sigmaY: StylingHelper.sigma_blurry,
          ),
          child: Scaffold(
            backgroundColor: Theme.of(context)
                .cardColor
                .withOpacity(StylingHelper.opacity_blurry),
            body: SafeArea(
              bottom: false,
              child: modalWidgetBuilder(
                  context, ModalScrollController.of(context)),
            ),
          ),
        ),
      );
}
