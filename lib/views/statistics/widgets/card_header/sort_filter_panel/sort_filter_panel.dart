import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:obs_blade/shared/general/custom_expansion_tile.dart';
import 'package:obs_blade/views/statistics/widgets/card_header/sort_filter_panel/exclude_unnamed_checkbox.dart';

import 'amount_entries_control.dart';
import 'date_range/date_range.dart';
import 'favorite_control.dart';
import 'filter_name.dart';
import 'order_row.dart';

const double _kControlsPadding = 14.0;

class SortFilterPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1.0),
        CustomExpansionTile(
          headerText: 'Expand to sort and filter your statistics!',
          headerPadding: const EdgeInsets.all(14.0),
          headerTextStyle: Theme.of(context).textTheme.bodyText2,
          expandedBody: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Divider(height: 1.0),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 14.0,
                    right: 14.0,
                    bottom: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: _kControlsPadding + 8.0),
                      OrderRow(),
                      SizedBox(height: _kControlsPadding),
                      FilterName(),
                      SizedBox(height: _kControlsPadding),
                      DateRange(),
                      SizedBox(height: _kControlsPadding + 2.0),
                      FavoriteControl(),
                      SizedBox(height: _kControlsPadding + 2.0),
                      AmountEntriesControl(),
                      SizedBox(height: 4.0),
                      ExcludeUnnamedCheckbox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
