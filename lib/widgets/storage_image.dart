import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum _LoadMode { webImg, sdk, failed }

/// Firebase Storage 이미지 표시 위젯.
/// 웹: HTML img 태그 우선 (CORS 회피) → 실패 시 SDK fallback
/// 네이티브: Storage SDK로 바이트 다운로드
class StorageImage extends StatefulWidget {
  const StorageImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<StorageImage> createState() => _StorageImageState();
}

class _StorageImageState extends State<StorageImage> {
  _LoadMode _mode = kIsWeb ? _LoadMode.webImg : _LoadMode.sdk;
  Uint8List? _bytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (_mode == _LoadMode.sdk) _loadViaSdk();
  }

  @override
  void didUpdateWidget(StorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _mode = kIsWeb ? _LoadMode.webImg : _LoadMode.sdk;
      _bytes = null;
      if (_mode == _LoadMode.sdk) _loadViaSdk();
    }
  }

  String? _storagePathFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    final oIndex = segments.indexOf('o');
    if (oIndex == -1 || oIndex + 1 >= segments.length) return null;

    return Uri.decodeComponent(segments[oIndex + 1]);
  }

  Future<void> _loadViaSdk() async {
    if (widget.url.isEmpty) {
      setState(() => _mode = _LoadMode.failed);
      return;
    }

    setState(() {
      _loading = true;
      _bytes = null;
    });

    try {
      final path = _storagePathFromUrl(widget.url);
      final ref = path != null
          ? FirebaseStorage.instance.ref(path)
          : FirebaseStorage.instance.refFromURL(widget.url);
      final data = await ref.getData(10 * 1024 * 1024);
      if (!mounted) return;
      setState(() {
        _bytes = data;
        _loading = false;
        _mode = data == null ? _LoadMode.failed : _LoadMode.sdk;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _mode = _LoadMode.failed;
      });
    }
  }

  void _fallbackToSdk() {
    if (_mode != _LoadMode.webImg) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mode != _LoadMode.webImg) return;
      setState(() => _mode = _LoadMode.sdk);
      _loadViaSdk();
    });
  }

  Widget _defaultError() {
    return widget.errorWidget ??
        const Center(
          child: Icon(Icons.broken_image_outlined, color: AppTheme.textSecondary),
        );
  }

  Widget _defaultPlaceholder() {
    return widget.placeholder ??
        const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primary,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty || _mode == _LoadMode.failed) {
      return _defaultError();
    }

    if (_mode == _LoadMode.webImg) {
      return Image.network(
        widget.url,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (_, __, ___) {
          _fallbackToSdk();
          return _defaultPlaceholder();
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _defaultPlaceholder();
        },
      );
    }

    if (_loading) return _defaultPlaceholder();

    if (_bytes == null) return _defaultError();

    return Image.memory(
      _bytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
    );
  }
}
