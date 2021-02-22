import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';

import '../../models/app_state.dart';
import '../../routes.dart';
import '../../util/notifications.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initStudy();
  }

  Future<void> initStudy() async {
    final model = context.read<AppState>()..activeStudy = ParseUserStudy();
    final prefs = await SharedPreferences.getInstance();
    final selectedStudyObjectId = prefs.getString(UserQueries.selectedStudyObjectIdKey);
    print('Selected study: $selectedStudyObjectId');
    if (selectedStudyObjectId == null) {
      if (await UserQueries.isUserLoggedIn()) {
        Navigator.pushReplacementNamed(context, Routes.studySelection);
        return;
      }
      Navigator.pushReplacementNamed(context, Routes.welcome);
      return;
    }

    final userStudy = await ParseUserStudy().getUserStudy(selectedStudyObjectId);
    if (userStudy != null) {
      model.activeStudy = userStudy;
      if (!kIsWeb) {
        // Notifications not supported on web
        scheduleStudyNotifications(context);
      }
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, Routes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context).loading}...',
                style: Theme.of(context).textTheme.headline4,
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
