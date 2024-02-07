import 'dart:core';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:studyu_core/core.dart';

class TemporaryStorageHandler {
  static const String _stagingBaseNamePrefix = 'staging_';
  static const String _audioFileType = ".m4a";
  static const String _imageFileType = ".jpg";

  final String _userId;
  final String _studyId;

  TemporaryStorageHandler(this._studyId, this._userId);

  // a file name does not include the file suffix/type, like .png
  String _buildFileName() {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return "user-id_${_userId}_study-id_${_studyId}_$timestamp";
  }

  static Future<Directory> _getMultimodalDirectory() async {
    final appData = await getApplicationDocumentsDirectory();
    final applicationMediaDirectory = Directory("${appData.path}/multimodal-artifacts");
    await applicationMediaDirectory.create(recursive: true);
    return applicationMediaDirectory;
  }

  Future<FutureBlobFile> getStagingAudio() async {
    final temporaryMultimodalDirectory = await _getMultimodalDirectory();
    final fileName = _buildFileName();
    final localFilePath = path.join(
      temporaryMultimodalDirectory.path,
      [
        TemporaryStorageHandler._stagingBaseNamePrefix,
        fileName,
        TemporaryStorageHandler._audioFileType,
      ].join(),
    );
    final futureBlobId = [fileName, TemporaryStorageHandler._audioFileType].join();
    return FutureBlobFile(localFilePath, futureBlobId);
  }

  Future<FutureBlobFile> getStagingImage() async {
    final temporaryMultimodalDirectory = await _getMultimodalDirectory();
    final fileName = _buildFileName();
    final localFilePath = path.join(
      temporaryMultimodalDirectory.path,
      [
        TemporaryStorageHandler._stagingBaseNamePrefix,
        fileName,
        TemporaryStorageHandler._imageFileType,
      ].join(),
    );
    final futureBlobId = [fileName, TemporaryStorageHandler._imageFileType].join();
    return FutureBlobFile(localFilePath, futureBlobId);
  }

  static Future<void> deleteAllStagingFiles() async {
    final temporaryMultimodalDirectory = await _getMultimodalDirectory();
    for (final file in await temporaryMultimodalDirectory
        .list()
        .where((f) => path.basename(f.path).startsWith(TemporaryStorageHandler._stagingBaseNamePrefix))
        .toList()) {
      await file.delete();
    }
  }
}
