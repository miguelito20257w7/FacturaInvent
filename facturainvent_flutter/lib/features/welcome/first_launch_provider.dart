import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFirstLaunchKey = 'isFirstLaunch';

class FirstLaunchNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kFirstLaunchKey) ?? true;
  }

  Future<void> markAsLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFirstLaunchKey, false);
    state = const AsyncValue.data(false);
  }
}

final firstLaunchProvider =
    AsyncNotifierProvider<FirstLaunchNotifier, bool>(FirstLaunchNotifier.new);
