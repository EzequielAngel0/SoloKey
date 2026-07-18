import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
// plugin_platform_interface ships transitively with every Flutter plugin; it is
// used here only to mock the FilePicker platform channel in tests.
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Headless [FilePicker] for widget tests: it never opens a native dialog.
///
/// - `pickFiles` returns [pickResult] (build one with [pickedFile]); `null`
///   models the user cancelling the open dialog.
/// - `saveFile` returns [savePath]; `null` models cancelling the save dialog.
///
/// Both members log their call count so a test can assert the screen actually
/// reached the OS seam. Register it with `FilePicker.platform = FakeFilePicker(...)`.
/// Reading `FilePicker.platform` before setting it throws when no plugin is
/// registered, so set it directly (no capture/restore needed — each test file
/// runs in its own isolate).
class FakeFilePicker extends FilePicker with MockPlatformInterfaceMixin {
  FakeFilePicker({this.pickResult, this.savePath});

  FilePickerResult? pickResult;
  String? savePath;

  int pickCalls = 0;
  int saveCalls = 0;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    pickCalls++;
    return pickResult;
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    saveCalls++;
    return savePath;
  }
}

/// Builds a [FilePickerResult] with a single in-memory file, mirroring what the
/// real picker hands back when called with `withData: true`.
FilePickerResult pickedFile(String name, Uint8List bytes) =>
    FilePickerResult([PlatformFile(name: name, size: bytes.length, bytes: bytes)]);
