import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import '../../shared/dialogs/confirmation.dart';
import '../../shared/general/custom_sliver_list.dart';
import '../../shared/general/responsive_widget_wrapper.dart';
import '../../stores/shared/network.dart';
import '../../stores/views/dashboard.dart';
import '../../types/enums/hive_keys.dart';
import '../../types/enums/settings_keys.dart';
import '../../utils/modal_handler.dart';
import '../../utils/routing_helper.dart';
import 'widgets/save_edit_connection_dialog.dart';
import 'widgets/reconnect_toast.dart';
import 'widgets/scenes/scenes.dart';
import 'widgets/status_app_bar/status_app_bar.dart';
import 'widgets/stream_widgets/stream_widgets.dart';
import 'widgets/stream_widgets/stream_widgets_mobile.dart';

/// InheritedWidget [DashBoardScroll] is used to expose the ScrollController
/// which is being used for the main ListView in Dashboard to the descendant
/// Widgets - could be put inside the DashboardStore but I want to avoid
/// putting Flutter specific classes inside my stores
@Deprecated(
    'Don\'t necessary anymore since we expose a [ScrollController] from the Navigators used for the tabs since we want to scroll or route back if a user taps on the tab - therefore we can access the [ScrollController] from the [ModalRoute] settings argument')
class DashboardScroll extends InheritedWidget {
  final ScrollController scrollController = ScrollController();

  DashboardScroll({@required Widget child}) : super(child: child);

  static DashboardScroll of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DashboardScroll>();

  @override
  bool updateShouldNotify(DashboardScroll oldWidget) =>
      oldWidget.scrollController != this.scrollController;
}

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<DashboardStore>(create: (_) {
      DashboardStore dashboardStore = DashboardStore();

      // Setting the active session and make initial requests
      // to display data on connect
      dashboardStore.setupNetworkStoreHandling(context.read<NetworkStore>());
      return dashboardStore;
    }, builder: (context, _) {
      return _DashboardView();
    });
  }
}

class _DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    if (Hive.box(HiveKeys.Settings.name)
        .get(SettingsKeys.WakeLock.name, defaultValue: true)) {
      Wakelock.enable();
    }

    when(
        (_) =>
            context.read<NetworkStore>().activeSession.connection.name == null,
        () => SchedulerBinding.instance
            .addPostFrameCallback((_) => _saveConnectionDialog(context)));

    when(
        (_) => context.read<NetworkStore>().obsTerminated,
        () => Navigator.of(context).pushReplacementNamed(
              HomeTabRoutingKeys.Landing.route,
              arguments: ModalRoute.of(context).settings.arguments,
            ));
    super.initState();
  }

  @override
  void dispose() {
    /// Disable [Wakelock] - does not need to check whether this is active
    /// since calling disable is idempotent
    Wakelock.disable();
    super.dispose();
  }

  _saveConnectionDialog(BuildContext context) {
    ModalHandler.showBaseDialog(
      context: context,
      dialogWidget: ConfirmationDialog(
        title: 'Save Connection',
        body:
            'Do you want to save this connection? You can do it later as well!\n\n(Click on the icon on the top right of the screen and select "Save / Edit Connection"',
        onOk: (_) {
          ModalHandler.showBaseDialog(
            context: context,
            dialogWidget: SaveEditConnectionDialog(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(builder: (_) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            CustomScrollView(
              physics: context.read<DashboardStore>().isPointerOnChat
                  ? NeverScrollableScrollPhysics()
                  : ClampingScrollPhysics(),
              controller: ModalRoute.of(context).settings.arguments,
              slivers: [
                StatusAppBar(),
                CustomSliverList(
                  children: [
                    Align(
                      child: SizedBox(
                        // width: MediaQuery.of(context).size.width / 100 * 85,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Scenes(),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 8.0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Widgets',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Divider(height: 0.0),
                            ),
                            ResponsiveWidgetWrapper(
                              mobileWidget: StreamWidgetsMobile(),
                              tabletWidget: StreamWidgets(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: kBottomNavigationBarHeight,
                    // ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              child: Align(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ReconnectToast(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
