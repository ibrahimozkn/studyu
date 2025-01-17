import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class Cache {
  static bool isSynchronizing = false;

  static Future<void> storeSubject(StudySubject? subject) async {
    debugPrint("Store subject in cache");
    if (subject == null) return;
    SecureStorage.write(cacheSubjectKey, jsonEncode(subject.toFullJson()));
    assert(subject == (await loadSubject()));
  }

  static Future<StudySubject> loadSubject() async {
    // debugPrint("Load subject from cache");
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      return StudySubject.fromJson(jsonDecode((await SecureStorage.read(cacheSubjectKey))!));
    } else {
      throw Exception("No cached subject found");
    }
  }

  static Future<void> storeAnalytics(StudyUAnalytics analytics) async {
    SecureStorage.write(StudyUAnalytics.keyStudyUAnalytics, jsonEncode(analytics.toJson()));
  }

  static Future<StudyUAnalytics?> loadAnalytics() async {
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      return StudyUAnalytics.fromJson(jsonDecode((await SecureStorage.read(StudyUAnalytics.keyStudyUAnalytics))!));
    }
    return null;
  }

  static Future<void> delete() async {
    StudyULogger.warning("Delete cache");
    SecureStorage.delete(cacheSubjectKey);
  }

  static Future<void> uploadBlobFiles() async {
    final blobStorageHandler = BlobStorageHandler();
    final futureBlobFiles = await TemporaryStorageHandler.getFutureBlobFiles();
    for (final futureBlobFile in futureBlobFiles) {
      await blobStorageHandler.uploadObservation(futureBlobFile.futureBlobId, File(futureBlobFile.localFilePath));
      await File(futureBlobFile.localFilePath).delete();
    }
  }

  static Future<StudySubject> synchronize(StudySubject remoteSubject) async {
    if (isSynchronizing) return remoteSubject;
    // No local subject found
    if (!(await SecureStorage.containsKey(cacheSubjectKey))) return remoteSubject;
    final localSubject = await loadSubject();
    // local and remote subject are equal, nothing to synchronize
    if (localSubject == remoteSubject) return remoteSubject;
    // remote subject belongs to a different study
    if (!kDebugMode && remoteSubject.startedAt!.isAfter(localSubject.startedAt!)) return remoteSubject;

    debugPrint("Synchronize subject with cache");
    isSynchronizing = true;

    try {
      await uploadBlobFiles();

      // only minimal update
      // Check if progress has changed
      if (localSubject.progress.length != remoteSubject.progress.length) {
        StudyULogger.info("Cache found different progress length");
        /*if (remoteSubject.progress.isNotEmpty) {
        // sort remote progress list from oldest to newest
        remoteSubject.progress.sort((a, b) =>
            a.completedAt.compareTo(b.completedAt));
        // merge all local progress older than the latest remote progress to remote subject and upload
        newProgress = localSubject.progress.where((element) =>
            element.completedAt.isAfter(remoteSubject.progress.last.completedAt)
        ).toList();
      } else {
        newProgress = localSubject.progress;
      }*/
        // save new progress
        final List<SubjectProgress> newProgress = [...localSubject.progress, ...remoteSubject.progress];
        newProgress.removeWhere(
            (element) => localSubject.progress.contains(element) && remoteSubject.progress.contains(element));
        for (var p in newProgress) {
          await p.save();
        }

        // merge local and remote progress and remove duplicates
        final List<SubjectProgress> finalProgress = [...localSubject.progress, ...remoteSubject.progress];
        final duplicates = <DateTime?>{};
        finalProgress.retainWhere((element) => duplicates.add(element.completedAt));
        // replace remote progress with our merge
        remoteSubject.progress = finalProgress;
        await remoteSubject.save();
      } else {
        // Unable to determine what has changed
        // We can either drop local or overwrite remote
        // ... for now do nothing
        if (!kDebugMode && localSubject.startedAt == remoteSubject.startedAt) {
          StudyULogger.fatal("Cache synchronization found local changes that cannot be merged");
          StudyUDiagnostics.captureMessage(
              "localSubject: ${localSubject.toFullJson()} \nremoteSubject: ${remoteSubject.toFullJson()}");
          StudyUDiagnostics.captureException(Exception("CacheSynchronizationException"));
        }
      }
    } catch (exception) {
      StudyULogger.warning(exception);
    }
    isSynchronizing = false;
    return remoteSubject;
  }
}
