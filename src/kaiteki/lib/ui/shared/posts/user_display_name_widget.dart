import 'package:flutter/material.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/fediverse/model/user.dart';
import 'package:kaiteki/utils/extensions.dart';

class UserDisplayNameWidget extends ConsumerWidget {
  final User user;
  final Axis orientation;

  const UserDisplayNameWidget(
    this.user, {
    super.key,
    this.orientation = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textSpacing =
        orientation == Axis.vertical || _equalUserName(user) ? 0.0 : 6.0;

    final secondaryText = _getSecondaryUserText(user);
    final secondaryColor = Theme.of(context).disabledColor;
    final secondaryTextTheme = TextStyle(color: secondaryColor);

    return Wrap(
      direction: orientation,
      spacing: textSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          user.renderDisplayName(context, ref),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (secondaryText != null)
          Text(
            secondaryText,
            style: secondaryTextTheme,
            overflow: TextOverflow.fade,
          ),
      ],
    );
  }

  String? _getSecondaryUserText(User user) {
    if (orientation != Axis.vertical) {
      String? result;

      if (!_equalUserName(user)) {
        result = user.username;
      }

      final host = user.host;
      if (host != null) {
        result = '${result ?? ''}@$host';
      }

      return result;
    }

    return user.handle;
  }

  bool _equalUserName(User user) {
    return user.username.toLowerCase() == user.displayName.toLowerCase();
  }
}
