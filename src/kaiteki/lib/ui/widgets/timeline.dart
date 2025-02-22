import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kaiteki/di.dart';
import 'package:kaiteki/fediverse/model/post.dart';
import 'package:kaiteki/fediverse/model/timeline_kind.dart';
import 'package:kaiteki/ui/shared/error_landing_widget.dart';
import 'package:kaiteki/ui/shared/posts/post_widget.dart';
import 'package:tuple/tuple.dart';

class Timeline extends ConsumerStatefulWidget {
  final double? maxWidth;
  final bool wide;
  final TimelineKind kind;

  const Timeline({
    super.key,
    this.maxWidth,
    this.wide = false,
    this.kind = TimelineKind.home,
  });

  @override
  TimelineState createState() => TimelineState();
}

class TimelineState extends ConsumerState<Timeline> {
  final PagingController<String?, Post> _controller = PagingController(
    firstPageKey: null,
  );

  @override
  void initState() {
    _controller.addPageRequestListener((id) async {
      try {
        final adapter = ref.watch(accountProvider).adapter;
        final posts = await adapter.getTimeline(widget.kind, untilId: id);

        if (mounted) {
          if (posts.isEmpty) {
            _controller.appendLastPage(posts.toList());
          } else {
            _controller.appendPage(posts.toList(), posts.last.id);
          }
        }
      } catch (e, s) {
        if (mounted) _controller.error = Tuple2(e, s);
      }
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant Timeline oldWidget) {
    if (widget.kind != oldWidget.kind) {
      _controller.refresh();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void refresh() => _controller.refresh();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PagedListView<String?, Post>.separated(
          padding: EdgeInsets.symmetric(
            horizontal: _getPadding(constraints.maxWidth),
          ),
          pagingController: _controller,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: _buildPost,
            firstPageErrorIndicatorBuilder: (context) {
              final t = _controller.error as Tuple2<dynamic, StackTrace>;
              return ErrorLandingWidget(
                error: t.item1,
                stackTrace: t.item2,
              );
            },
          ),
          separatorBuilder: _buildSeparator,
        );
      },
    );
  }

  double _getPadding(double width) {
    final maxWidth = widget.maxWidth;
    if (maxWidth == null || width <= maxWidth) {
      return 0;
    } else {
      return width / 2 - maxWidth / 2;
    }
  }

  Widget _buildPost(context, item, index) {
    return Consumer(
      builder: (context, ref, child) {
        return Material(
          child: InkWell(
            onTap: () {
              final account = ref.read(accountProvider).currentAccount;
              context.push(
                "/@${account.key.username}@${account.key.host}/posts/${item.id}",
                extra: item,
              );
            },
            child: PostWidget(item, wide: widget.wide),
          ),
        );
      },
    );
  }

  Widget _buildSeparator(BuildContext context, int index) {
    return const Divider(height: 1);
  }
}
