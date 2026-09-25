import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/data/local/progress_local_data_source.dart';
import 'package:thaheen_task/data/repositories/progress_repository.dart';

Future<ProgressRepository> createProgressRepository([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  return ProgressRepository(ProgressLocalDataSource(preferences));
}
