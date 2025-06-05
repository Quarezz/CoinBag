import '../../../data/models/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTags();
}
