import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/constants/asset_paths.dart';
import '../models/course_model.dart';
import '../models/json_reader.dart';

class CourseLocalDataSource {
  const CourseLocalDataSource(this._bundle);

  final AssetBundle _bundle;

  /// Loads and parses the bundled course catalog.
  ///
  /// Throws if the asset is missing or its content is not valid.
  Future<List<CourseModel>> loadCourses() async {
    // The repository caches parsed courses, so skip the bundle's own cache.
    final raw = await _bundle.loadString(AssetPaths.coursesJson, cache: false);
    final decoded = jsonDecode(raw);
    if (decoded is! JsonMap) {
      throw const FormatException('Course catalog root must be an object');
    }
    return decoded.requireMapList('courses').map(CourseModel.fromJson).toList();
  }
}
