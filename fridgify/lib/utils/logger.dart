import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:device_id/device_id.dart';
import 'package:logger/logger.dart' as _Logger;

class Logger {

  static LogLevels level = LogLevels.all;

  String _name;

  static final _logger = _Logger.Logger();

  static final Map<String, Logger> cached = Map();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics();

  static String _deviceID;

  factory Logger(String named) {
    if(cached.containsKey(named)) {
      return cached[named];
    }
    cached[named] = Logger._internal(named);
    return cached[named];
  }

  Logger._internal(String named) {
    this._name = named;
  }

  void i(String msg, {bool upload}) {
    if(Logger.level.value() > LogLevels.info.value()) return;
    _logger.i("${this._name} -> $msg");
    if(upload ?? false) {
      _uploadLog('info', msg);
    }
  }

  void e(String msg, {bool upload}) {
    if(Logger.level.value() > LogLevels.error.value()) return;
    _logger.e("${this._name} -> $msg");
    if(upload ?? false) {
      _uploadLog('error', msg);
    }
  }

  Future<void> _uploadLog(String type, String msg) async {
    if(_deviceID == null) {
      _deviceID = await DeviceId.getID;
    }
    await _analytics.logEvent(name: _name,
        parameters: <String, String> {
          type: msg,
        });
  }
}

enum LogLevels {
  all,
  info,
  error,
  none,
}

extension LogLevelsExtension on LogLevels {
  int value() {
    switch(this) {
      case LogLevels.all: return 0;
      case LogLevels.info: return 1;
      case LogLevels.error: return 2;
      default: return 3;
  }
  }
}