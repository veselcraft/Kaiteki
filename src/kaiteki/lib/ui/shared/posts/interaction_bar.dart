import 'package:flutter/material.dart';
import 'package:kaiteki/fediverse/model/post.dart';
import 'package:kaiteki/theming/kaiteki/colors.dart';
import 'package:kaiteki/ui/shared/posts/count_button.dart';

class InteractionBar extends StatelessWidget {
  const InteractionBar({
    super.key,
    required Post post,
    this.onReply,
    this.onFavorite,
    this.onRepeat,
    this.onReact,
    this.favorited,
    this.repeated,
    this.reacted,
    required this.buildActions,
    this.onShowFavoritees,
    this.onShowRepeatees,
  }) : _post = post;

  final Post _post;

  final VoidCallback? onReply;
  final VoidCallback? onFavorite;
  final VoidCallback? onShowFavoritees;
  final bool? favorited;

  final VoidCallback? onRepeat;
  final VoidCallback? onShowRepeatees;

  final bool? repeated;

  final VoidCallback? onReact;
  final bool? reacted;
  final List<PopupMenuEntry> Function(BuildContext) buildActions;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      CountButton(
        count: _post.replyCount,
        focusNode: FocusNode(skipTraversal: true),
        icon: const Icon(Icons.reply_rounded),
        onTap: onReply,
      ),
      if (repeated != null)
        CountButton(
          active: _post.repeated,
          activeColor: Theme.of(context).ktkColors?.repeatColor,
          count: _post.repeatCount,
          focusNode: FocusNode(skipTraversal: true),
          icon: const Icon(Icons.repeat_rounded),
          onTap: onRepeat,
          onLongPress: onShowRepeatees,
        ),
      if (favorited != null)
        CountButton(
          active: _post.liked,
          activeColor: Theme.of(context).ktkColors?.favoriteColor,
          activeIcon: const Icon(Icons.star_rounded),
          count: _post.likeCount,
          focusNode: FocusNode(skipTraversal: true),
          icon: const Icon(Icons.star_border_rounded),
          onTap: onFavorite,
          onLongPress: onShowFavoritees,
        ),
      if (reacted != null)
        CountButton(
          focusNode: FocusNode(skipTraversal: true),
          icon: const Icon(Icons.mood_rounded),
          onTap: onReact,
        ),
      PopupMenuButton(
        icon: const Icon(Icons.more_horiz),
        itemBuilder: buildActions,
        onSelected: (callback) => (callback as VoidCallback).call(),
        splashRadius: 18,
      ),
    ];

    // Added Material for fixing bork with Hero *shrug*
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        direction: Axis.horizontal,
        children: [
          for (var button in buttons)
            Flexible(
              fit: FlexFit.tight,
              child: Row(children: [button]),
            ),
        ],
      ),
    );
  }
}
