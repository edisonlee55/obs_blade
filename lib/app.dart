import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:obs_blade/utils/built_in_themes.dart';
import 'package:provider/provider.dart';

import 'models/custom_theme.dart';
import 'stores/shared/network.dart';
import 'stores/shared/tabs.dart';
import 'types/enums/hive_keys.dart';
import 'types/enums/settings_keys.dart';
import 'utils/routing_helper.dart';
import 'utils/styling_helper.dart';
import 'types/extensions/string.dart';

class App extends StatelessWidget {
  ThemeData _getCurrentTheme(Box settingsBox) {
    Brightness brightness;
    Color scaffoldBackgroundColor;
    Color accentColor;
    Color backgroundColor;
    Color canvasColor;
    Color cardColor;
    Color indicatorColor;
    Color toggleableActiveColor;
    Color sliderColor;
    Color appBarColor;
    Color buttonColor;
    Color extraButtonColor;
    Color tabBarColor;
    Color cursorColor;
    Color cupertinoPrimaryColor;

    if (settingsBox.get(SettingsKeys.CustomTheme.name, defaultValue: false)) {
      CustomTheme activeCustomTheme = [
        ...BuiltInThemes.themes,
        ...Hive.box<CustomTheme>(HiveKeys.CustomTheme.name).values
      ].firstWhere(
          (customTheme) =>
              customTheme.uuid ==
              settingsBox.get(SettingsKeys.ActiveCustomThemeUUID.name,
                  defaultValue: ''),
          orElse: () => null);
      if (activeCustomTheme != null) {
        brightness = activeCustomTheme.useLightBrightness != null &&
                activeCustomTheme.useLightBrightness
            ? Brightness.light
            : Brightness.dark;
        scaffoldBackgroundColor =
            activeCustomTheme.backgroundColorHex?.hexToColor();
        accentColor = activeCustomTheme.accentColorHex?.hexToColor();
        backgroundColor = activeCustomTheme.cardColorHex?.hexToColor();
        canvasColor = activeCustomTheme.cardColorHex?.hexToColor();
        cardColor = activeCustomTheme.cardColorHex?.hexToColor();
        indicatorColor = activeCustomTheme.accentColorHex?.hexToColor();
        toggleableActiveColor = activeCustomTheme.accentColorHex?.hexToColor();
        sliderColor = activeCustomTheme.accentColorHex?.hexToColor();
        appBarColor = activeCustomTheme.appBarColorHex?.hexToColor();
        buttonColor = activeCustomTheme.accentColorHex?.hexToColor();
        extraButtonColor = activeCustomTheme.highlightColorHex?.hexToColor();
        tabBarColor = activeCustomTheme.tabBarColorHex?.hexToColor();
        cursorColor = activeCustomTheme.accentColorHex?.hexToColor();
        cupertinoPrimaryColor =
            activeCustomTheme.highlightColorHex?.hexToColor();
      }
    }

    return (brightness != null && brightness == Brightness.light
            ? ThemeData.light()
            : ThemeData.dark())
        .copyWith(
      scaffoldBackgroundColor: scaffoldBackgroundColor ??
          (settingsBox.get(SettingsKeys.TrueDark.name, defaultValue: false)
              ? settingsBox.get(SettingsKeys.ReduceSmearing.name,
                      defaultValue: false)
                  ? StylingHelper.background_reduced_smearing_color
                  : StylingHelper.background_color
              : '212123'.hexToColor()), //Colors.grey[900]),
      accentColor: accentColor ?? StylingHelper.highlight_color,
      backgroundColor: backgroundColor ?? StylingHelper.primary_color,
      canvasColor: canvasColor ?? StylingHelper.primary_color,
      cardColor: cardColor ?? StylingHelper.primary_color,
      // cursorColor: cursorColor ?? StylingHelper.highlight_color,
      indicatorColor: indicatorColor ?? StylingHelper.highlight_color,
      buttonColor: extraButtonColor,
      dividerColor: Colors.grey[500],
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textSelectionColor: accentColor ?? StylingHelper.highlight_color,
      toggleableActiveColor:
          toggleableActiveColor ?? StylingHelper.accent_color,

      /// Inner Widget themes
      primaryIconTheme: IconThemeData(
        color: brightness != null && brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      ),

      sliderTheme: SliderThemeData(
        activeTickMarkColor: sliderColor ?? StylingHelper.highlight_color,
        activeTrackColor: sliderColor ?? StylingHelper.highlight_color,
        valueIndicatorColor: sliderColor ?? StylingHelper.highlight_color,
        thumbColor: sliderColor ?? StylingHelper.highlight_color,
        overlayColor:
            (sliderColor ?? StylingHelper.highlight_color).withOpacity(0.3),
        inactiveTrackColor:
            (sliderColor ?? StylingHelper.highlight_color).withOpacity(0.3),
        inactiveTickMarkColor:
            (sliderColor ?? StylingHelper.highlight_color).withOpacity(0.3),
      ),

      // useTextSelectionTheme: true,

      // textSelectionTheme: TextSelectionThemeData(
      //   cursorColor: cursorColor ?? StylingHelper.highlight_color,
      //   selectionColor: cursorColor ?? StylingHelper.highlight_color,
      //   selectionHandleColor: cursorColor ?? StylingHelper.highlight_color,
      // ),

      // textSelectionHandleColor: cursorColor ?? StylingHelper.highlight_color,

      tabBarTheme: TabBarTheme(
        labelColor: brightness != null && brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      ),

      appBarTheme: AppBarTheme(
        color: (appBarColor ?? StylingHelper.primary_color)
            .withOpacity(StylingHelper.opacity_blurry),
      ),

      buttonTheme: ButtonThemeData(
        buttonColor: buttonColor ?? StylingHelper.accent_color,
        splashColor: Colors.transparent,
      ),
      // tooltipTheme: TooltipThemeData(
      //   decoration: BoxDecoration(
      //     color: Colors.grey[800],
      //     borderRadius: BorderRadius.circular(12.0),
      //   ),
      //   textStyle: TextStyle(color: Colors.white),
      // ),
      cupertinoOverrideTheme: CupertinoThemeData(
        scaffoldBackgroundColor: scaffoldBackgroundColor ??
            (settingsBox.get(SettingsKeys.TrueDark.name, defaultValue: false)
                ? settingsBox.get(SettingsKeys.ReduceSmearing.name,
                        defaultValue: false)
                    ? StylingHelper.background_reduced_smearing_color
                    : StylingHelper.background_color
                : Colors.grey[900]),
        textTheme: CupertinoTextThemeData(
          primaryColor: accentColor ?? StylingHelper.highlight_color,
        ),
        barBackgroundColor: (tabBarColor ?? StylingHelper.primary_color)
            .withOpacity(StylingHelper.opacity_blurry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NetworkStore>(create: (_) => NetworkStore()),
        Provider<TabsStore>(create: (_) => TabsStore()),
      ],
      child: ValueListenableBuilder(
        valueListenable: Hive.box(HiveKeys.Settings.name).listenable(keys: [
          SettingsKeys.TrueDark.name,
          SettingsKeys.ReduceSmearing.name,
          SettingsKeys.CustomTheme.name,
          SettingsKeys.ActiveCustomThemeUUID.name,
        ]),
        builder: (context, Box settingsBox, child) => ValueListenableBuilder(
          valueListenable:
              Hive.box<CustomTheme>(HiveKeys.CustomTheme.name).listenable(),
          builder: (context, Box<CustomTheme> customThemeBox, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: _getCurrentTheme(settingsBox),
              initialRoute: settingsBox.get(SettingsKeys.HasUserSeenIntro.name,
                      defaultValue: false)
                  ? AppRoutingKeys.Tabs.route
                  : AppRoutingKeys.Intro.route,
              onGenerateInitialRoutes: (initialRoute) => [
                MaterialPageRoute(
                  builder: RoutingHelper.appRoutes[initialRoute],
                  settings: RouteSettings(name: initialRoute),
                ),
              ],
              routes: RoutingHelper.appRoutes,
            );
          },
        ),
      ),
    );
  }
}
