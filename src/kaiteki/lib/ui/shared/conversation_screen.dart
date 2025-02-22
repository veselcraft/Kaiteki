import 'package:breakpoint/breakpoint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/fediverse/model/post.dart';
import 'package:kaiteki/ui/shared/breakpoint_container.dart';
import 'package:kaiteki/ui/shared/posts/post_widget.dart';
import 'package:kaiteki/utils/extensions.dart';

import 'package:kaiteki/utils/threader.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final Post post;

  const ConversationScreen(this.post, {super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  Future<Iterable<Post>>? _threadFetchFuture;
  bool showThreaded = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final adapter = ref.watch(accountProvider).adapter;
    try {
      _threadFetchFuture = adapter.getThread(widget.post.getRoot());
    } on UnimplementedError {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fetching threads with ${adapter.client.type.displayName} is not implemented.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.getL10n();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.conversationTitle),
        actions: [
          IconButton(
            icon: Icon(
              showThreaded
                  ? Icons.view_timeline_rounded
                  : Icons.article_rounded,
            ),
            onPressed: () => setState(() => showThreaded = !showThreaded),
          ),
        ],
      ),
      body: BreakpointBuilder(
        builder: (context, breakpoint) {
          return BreakpointContainer(
            breakpoint: breakpoint,
            child: showThreaded ? buildThreaded(context) : buildFlat(context),
          );
        },
      ),
    );
  }

  Widget buildThreaded(BuildContext context) {
    final future = _threadFetchFuture?.then((thread) {
      return compute(toThread, thread.toList(growable: false));
    });

    final l10n = context.getL10n();

    return FutureBuilder<ThreadPost>(
      future: future,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: ThreadPostContainer(snapshot.data!),
          );
        } else if (snapshot.hasError) {
          return Column(
            children: [
              PostWidget(widget.post),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: Text(l10n.threadRetrievalFailed),
                subtitle: Text(snapshot.error.toString()),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildFlat(BuildContext context) {
    final l10n = context.getL10n();

    return FutureBuilder<Iterable<Post>>(
      future: _threadFetchFuture,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data!.elementAt(index);
              return PostWidget(post);
            },
          );
        } else if (snapshot.hasError) {
          return Column(
            children: [
              PostWidget(widget.post),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: Text(l10n.threadRetrievalFailed),
                subtitle: Text(snapshot.error.toString()),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
