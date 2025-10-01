import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/widgets/custom_loader_widget.dart';
import 'package:flutter_restaurant/helper/debounce_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';

class PaginatedListWidget extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(int? offset) onPaginate;
  final int? totalSize;
  final int? offset;
  final int? limit;
  final bool isDisableWebLoader;
  final Widget Function(Widget loaderWidget) builder;

  final bool enabledPagination;
  final bool reverse;
  const PaginatedListWidget({
    super.key,
    this.scrollController,
    required this.onPaginate,
    required this.totalSize,
    required this.offset,
    required this.builder,
    this.enabledPagination = true,
    this.reverse = false,
    this.limit = 10,
    this.isDisableWebLoader = false,
  });

  @override
  State<PaginatedListWidget> createState() => _PaginatedListWidgetState();
}

class _PaginatedListWidgetState extends State<PaginatedListWidget> {
  int? _offset;
  late List<int?> _offsetList;
  bool _isLoading = false;
  bool _isDisableLoader = true;

  static const double _triggerThreshold = 24; // مسافة صغيرة قبل آخر الليست

  @override
  void initState() {
    super.initState();

    _offset = 1;
    _offsetList = [1];

    // لو فيه ScrollController، نسمع لنهاية السكول
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(() {
        final position = widget.scrollController!.position;
        final atBottom = position.pixels >= position.maxScrollExtent - _triggerThreshold;

        if (atBottom &&
            widget.totalSize != null &&
            !_isLoading &&
            widget.enabledPagination &&
            _hasNextPage()) {
          _paginate();
        }
      });
    }
  }

  bool _hasNextPage() {
    if (widget.totalSize == null) return false;
    final pageSize = (widget.totalSize! / (widget.limit ?? 10)).ceil();
    return _offset! < pageSize && !_offsetList.contains(_offset! + 1);
  }

  Future<void> _paginate() async {
    if (!_hasNextPage()) return;

    setState(() {
      _offset = _offset! + 1;
      _offsetList.add(_offset);
      _isLoading = true;
    });

    await widget.onPaginate(_offset);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offset != null) {
      _offset = widget.offset;
      _offsetList = [];
      for (int index = 1; index <= widget.offset!; index++) {
        _offsetList.add(index);
      }
    }

    // على الديسكتوب: اعرض اللودر فقط لما يكون فيه تحميل أو لسه فيه صفحات
    _isDisableLoader = (ResponsiveHelper.isDesktop(context) &&
        (widget.totalSize == null || !_hasNextPage()) && !_isLoading);

    final DebounceHelper debounce = DebounceHelper(milliseconds: 300);

    return _OnNotificationListenerWidget(
      isEnabled: widget.scrollController == null,
      onNotification: (scrollNotification) {
        final metrics = scrollNotification!.metrics;
        final atBottom = metrics.pixels >= metrics.maxScrollExtent - _triggerThreshold;

        if (atBottom &&
            widget.totalSize != null &&
            !_isLoading &&
            widget.enabledPagination &&
            _hasNextPage()) {
          debounce.run(_paginate);
        }
      },
      child: Column(
        children: [
          widget.reverse
              ? const SizedBox()
              : widget.builder(
                  _LoadingWidget(
                    isLoading: _isLoading,
                    totalSize: widget.totalSize,
                    isDisabledLoader: _isDisableLoader,
                    onTap: () {}, // مش هنستخدم الزرار
                  ),
                ),

          if (widget.isDisableWebLoader)
            _LoadingWidget(
              isLoading: _isLoading,
              totalSize: widget.totalSize,
              isDisabledLoader: _isDisableLoader,
              onTap: () {},
            ),

          widget.reverse
              ? widget.builder(
                  _LoadingWidget(
                    isLoading: _isLoading,
                    totalSize: widget.totalSize,
                    isDisabledLoader: _isDisableLoader,
                    onTap: () {},
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget({
    required this.isLoading,
    required this.totalSize,
    required this.isDisabledLoader,
    required this.onTap,
  });

  final bool isLoading;
  final bool isDisabledLoader;
  final int? totalSize;
  final Function onTap; // متسيبة عشان التوافق، بس مش هنستخدمها

  @override
  Widget build(BuildContext context) {
    if (isDisabledLoader) {
      return SizedBox(
        height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: isLoading
            ? CustomLoaderWidget(color: Theme.of(context).primaryColor)
            : const SizedBox(), // مفيش زرار "see more"؛ التحميل تلقائي فقط عند الوصول للنهاية
      ),
    );
  }
}

class _OnNotificationListenerWidget extends StatelessWidget {
  final bool isEnabled;
  final Widget child;
  final Function(ScrollNotification? scrollNotification) onNotification;
  const _OnNotificationListenerWidget({
    required this.isEnabled,
    required this.child,
    required this.onNotification,
  });

  @override
  Widget build(BuildContext context) {
    return isEnabled
        ? NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              onNotification(scrollNotification);
              return false;
            },
            child: child,
          )
        : child;
  }
}
