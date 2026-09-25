import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Serves [content] for any string asset; `null` simulates a missing asset.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.content);

  final String? content;

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final content = this.content;
    if (content == null) throw FlutterError('Asset not found: $key');
    return content;
  }
}
