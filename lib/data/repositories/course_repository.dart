import 'dart:developer';

import '../../domain/entities/course.dart';
import '../local/course_local_data_source.dart';

/// Thrown when the bundled course catalog cannot be loaded or parsed.
class CourseLoadException implements Exception {
  const CourseLoadException(this.cause);

  final Object cause;

  @override
  String toString() => 'CourseLoadException: $cause';
}

class CourseRepository {
  CourseRepository(this._dataSource);

  final CourseLocalDataSource _dataSource;
  Future<List<Course>>? _courses;

  /// Returns all courses. The catalog is parsed once and cached; a failed
  /// load is not cached so that retrying can succeed.
  Future<List<Course>> getCourses() {
    return _courses ??= _loadCourses().catchError((Object error) {
      _courses = null;
      throw error;
    });
  }

  /// Returns the course with [courseId], or `null` if it does not exist.
  Future<Course?> getCourseById(String courseId) async {
    final courses = await getCourses();
    for (final course in courses) {
      if (course.id == courseId) return course;
    }
    return null;
  }

  Future<List<Course>> _loadCourses() async {
    try {
      final models = await _dataSource.loadCourses();
      return List.unmodifiable(models.map((model) => model.toEntity()));
    } catch (error, stackTrace) {
      log(
        'Failed to load course catalog',
        name: 'CourseRepository',
        error: error,
        stackTrace: stackTrace,
      );
      throw CourseLoadException(error);
    }
  }
}
