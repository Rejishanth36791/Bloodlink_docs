import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class StompService {
  final TokenStorage tokenStorage;
  StompClient? _client;
  bool _isConnected = false;

  StompService({TokenStorage? customStorage})
      : tokenStorage = customStorage ?? TokenStorage();

  bool get isConnected => _isConnected;

  Future<void> connect({
    Function(Map<String, dynamic>)? onRequestUpdate,
    Function(Map<String, dynamic>)? onAlertReceived,
  }) async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) return;

    _client = StompClient(
      config: StompConfig(
        url: ApiConstants.defaultWsUrl,
        onConnect: (StompFrame frame) {
          _isConnected = true;
          debugPrint('STOMP Connected to BloodLink WebSocket');

          if (onRequestUpdate != null) {
            _client?.subscribe(
              destination: '/user/queue/requests',
              callback: (frame) {
                if (frame.body != null) {
                  try {
                    final data = jsonDecode(frame.body!) as Map<String, dynamic>;
                    onRequestUpdate(data);
                  } catch (e) {
                    debugPrint('STOMP decode error: $e');
                  }
                }
              },
            );
          }

          if (onAlertReceived != null) {
            _client?.subscribe(
              destination: '/user/queue/alerts',
              callback: (frame) {
                if (frame.body != null) {
                  try {
                    final data = jsonDecode(frame.body!) as Map<String, dynamic>;
                    onAlertReceived(data);
                  } catch (e) {
                    debugPrint('STOMP alert decode error: $e');
                  }
                }
              },
            );
          }
        },
        onDisconnect: (_) {
          _isConnected = false;
          debugPrint('STOMP Disconnected');
        },
        onWebSocketError: (dynamic error) {
          _isConnected = false;
          debugPrint('STOMP WebSocket error: $error');
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _client?.activate();
  }

  void subscribeToRequestTracking(String requestId, Function(Map<String, dynamic>) onUpdate) {
    if (_client != null && _isConnected) {
      _client?.subscribe(
        destination: '/topic/requests/$requestId',
        callback: (frame) {
          if (frame.body != null) {
            try {
              final data = jsonDecode(frame.body!) as Map<String, dynamic>;
              onUpdate(data);
            } catch (e) {
              debugPrint('Error decoding tracking update: $e');
            }
          }
        },
      );
    }
  }

  void disconnect() {
    _client?.deactivate();
    _isConnected = false;
  }
}
