import 'dart:async';
import 'package:flutter/services.dart';

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

class FlutterSiriActivity {
  const FlutterSiriActivity(
    this.title,
    this.key, {
    this.contentDescription,
    this.isEligibleForSearch = true,
    this.isEligibleForPrediction = true,
    this.suggestedInvocationPhrase = "",
  });

  final String title;
  final String key;
  final String? contentDescription;
  final bool isEligibleForSearch;
  final bool isEligibleForPrediction;
  final String suggestedInvocationPhrase;
}

class FlutterSiriSuggestions {
  FlutterSiriSuggestions._();

  /// Singleton of [FlutterSiriSuggestions].
  static final FlutterSiriSuggestions instance = FlutterSiriSuggestions._();

  // FlutterSiriShortcuts(this.title, this.key,
  //     {this.contentDescription,
  //     this.isEligibleForSearch = true,
  //     this.isEligibleForPrediction = true,
  //     this.suggestedInvocationPhrase})
  //     : assert(title != null),
  //       super();

  MessageHandler? _onLaunch;
  Map<String, dynamic>? retryActivity;

  static const MethodChannel _channel =
      const MethodChannel('flutter_siri_suggestions');

  Future<String> buildActivity(FlutterSiriActivity activity) async {
    return await _channel.invokeMethod('becomeCurrent', <String, Object?>{
      'title': activity.title,
      'key': activity.key,
      'contentDescription': activity.contentDescription,
      'isEligibleForSearch': activity.isEligibleForSearch,
      'isEligibleForPrediction': activity.isEligibleForPrediction,
      'suggestedInvocationPhrase': activity.suggestedInvocationPhrase,
    });
  }

  void configure({required MessageHandler onLaunch}) {
    _onLaunch = onLaunch;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> retryLaunchWithActivity() async {
    if (retryActivity != null) {
      _onLaunch!(retryActivity!);
      retryActivity = null;
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onLaunch":
        return _onLaunch!(call.arguments.cast<String, dynamic>());
      case "failedToLaunchWithActivity":
        retryActivity = call.arguments.cast<String, dynamic>();
        break;
      default:
        throw UnsupportedError("Unrecognized JSON message");
    }
  }
}
