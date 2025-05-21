import 'package:flutter/widgets.dart';
import 'package:tic_tac_toe/utilities/generic_alert_box.dart';

Future<void> showErrorDialogBox(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: "Error Loading content",
    content: "Error showing the content ",
    optionsBuilder: () {
      return {"ok" : null};
    },
  );
}
