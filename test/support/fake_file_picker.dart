import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
// file_picker 11 no exporta su interfaz de plataforma, que es el único punto
// para inyectar un selector falso: se importa de src/ solo en las pruebas.
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';

export 'package:file_picker/src/platform/file_picker_platform_interface.dart'
    show FilePickerPlatform;

/// Headless [FilePickerPlatform] for widget tests: it never opens a native dialog.
///
/// - `pickFiles` returns [pickResult] (build one with [pickedFile]); `null`
///   models the user cancelling the open dialog.
/// - `saveFile` returns [savePath]; `null` models cancelling the save dialog.
///
/// Both members log their call count so a test can assert the screen actually
/// reached the OS seam. Register it with
/// `FilePickerPlatform.instance = FakeFilePicker(...)` (each test file runs in
/// its own isolate, so it does not leak).
class FakeFilePicker extends FilePickerPlatform {
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
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
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
