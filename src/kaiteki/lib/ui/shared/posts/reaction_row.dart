import 'package:flutter/material.dart';
import 'package:kaiteki/fediverse/model/post.dart';
import 'package:kaiteki/fediverse/model/reaction.dart';
import 'package:kaiteki/ui/shared/posts/reaction_widget.dart';

class ReactionRow extends StatelessWidget {
  final Iterable<Reaction> _reactions;
  final Post _parentPost;

  const ReactionRow(
    this._parentPost,
    this._reactions, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (var reaction in _reactions)
          ReactionWidget(parentPost: _parentPost, reaction: reaction),
      ],
    );
  }
}
