import 'package:coinbag_flutter/gateway/network_data_source.dart';
import '../../../data/models/tag.dart';
import 'tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  final NetworkDataSource _networkDataSource;

  TagRepositoryImpl(this._networkDataSource);

  @override
  Future<List<Tag>> getTags() {
    return _networkDataSource.fetchTags();
  }
}
