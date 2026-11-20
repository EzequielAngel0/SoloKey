import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder.freezed.dart';
part 'folder.g.dart';

@freezed
abstract class Folder with _$Folder {
  const factory Folder({
    required String id,
    String? parentId,
    required String name,
    @Default('folder') String icon,
    @Default('#6C63FF') String colorHex,
    @Default(false) bool isFavorite,
    required DateTime createdAt,
  }) = _Folder;

  factory Folder.fromJson(Map<String, dynamic> json) =>
      _$FolderFromJson(json);
}
