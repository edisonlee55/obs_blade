import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:obs_blade/shared/basic/base_progress_indicator.dart';
import 'package:obs_blade/utils/styling_helper.dart';
import 'package:obs_blade/views/settings/widgets/action_block.dart/light_divider.dart';

/// This is a collection of licenses and the packages to which they apply.
/// [packageLicenseBindings] records the m+:n+ relationship between the license
/// and packages as a map of package names to license indexes.
///
/// Took from: about.dart (26.07.2020)
class _LicenseData {
  final List<LicenseEntry> licenses = <LicenseEntry>[];
  final Map<String, List<int>> packageLicenseBindings = <String, List<int>>{};
  final List<String> packages = <String>[];

  void addLicense(LicenseEntry entry) {
    // Before the license can be added, we must first record the packages to
    // which it belongs.
    for (final String package in entry.packages) {
      _addPackage(package);
      // Bind this license to the package using the next index value. This
      // creates a contract that this license must be inserted at this same
      // index value.
      packageLicenseBindings[package].add(licenses.length);
    }
    licenses.add(entry); // Completion of the contract above.
  }

  /// Add a package and initialise package license binding. This is a no-op if
  /// the package has been seen before.
  void _addPackage(String package) {
    if (!packageLicenseBindings.containsKey(package)) {
      packageLicenseBindings[package] = <int>[];
      packages.add(package);
    }
  }

  /// Sort the packages using some comparison method, or by the default manner,
  /// which is to put the application package first, followed by every other
  /// package in case-insensitive alphabetical order.
  void sortPackages([int compare(String a, String b)]) {
    packages.sort(compare ??
        (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }
}

class LicenseModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return LicensePage();
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Material(
        color: Colors.transparent,
        child: Scaffold(
          backgroundColor:
              StylingHelper.MAIN_BLUE.withOpacity(StylingHelper.OPACITY_BLURRY),
          extendBodyBehindAppBar: true,
          body: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(CupertinoIcons.clear_circled_solid),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Align(
                child: Container(
                  padding: EdgeInsets.only(bottom: 12.0),
                  width: 300.0,
                  child: Image.asset('assets/images/base-logo.png'),
                ),
              ),
              LightDivider(),
              Padding(
                padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 8.0),
                      height: 32.0,
                      child:
                          Image.asset('assets/images/flutter_logo_render.png'),
                    ),
                    Text('Powered by Flutter'),
                  ],
                ),
              ),
              LightDivider(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          FutureBuilder<_LicenseData>(
                            future: LicenseRegistry.licenses
                                .fold<_LicenseData>(
                                  _LicenseData(),
                                  (_LicenseData prev, LicenseEntry license) =>
                                      prev..addLicense(license),
                                )
                                .then((_LicenseData licenseData) =>
                                    licenseData..sortPackages()),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: snapshot.data.packages
                                      .map((packageName) => ListTile(
                                            dense: true,
                                            title: Text(packageName),
                                            subtitle: Text(
                                                '${snapshot.data.packageLicenseBindings[packageName].length} licenses'),
                                          ))
                                      .toList(),
                                );
                              }
                              return Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 24.0),
                                child:
                                    BaseProgressIndicator(text: 'Fetching...'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
