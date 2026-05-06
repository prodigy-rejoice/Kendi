import 'dart:async';

import '../app/app.logger.dart';

enum WebhookEventType { transferSuccess, transferFailed, poolFunded }

class WebhookEvent {
  final WebhookEventType type;
  final String reference;
  final double amount;
  final String? recipientName;
  final DateTime timestamp;

  const WebhookEvent({
    required this.type,
    required this.reference,
    required this.amount,
    this.recipientName,
    required this.timestamp,
  });

  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    return WebhookEvent(
      type: switch (json['event'] as String) {
        'transfer.success' => WebhookEventType.transferSuccess,
        'transfer.failed' => WebhookEventType.transferFailed,
        'pool.funded' => WebhookEventType.poolFunded,
        _ => WebhookEventType.transferFailed,
      },
      reference: json['reference'] as String,
      amount: (json['amount'] as num).toDouble(),
      recipientName: json['recipient_name'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class WebhookService {
  final log = getLogger('WebhookService');

  final _controller = StreamController<WebhookEvent>.broadcast();

  /// ViewModels subscribe to this stream to react to payment events.
  Stream<WebhookEvent> get stream => _controller.stream;

  /// Called when Payaza fires a real webhook (via your backend relay).
  void processIncomingEvent(Map<String, dynamic> payload) {
    log.i('Webhook received: ${payload["event"]}');
    try {
      final event = WebhookEvent.fromJson(payload);
      _controller.add(event);
      switch (event.type) {
        case WebhookEventType.transferSuccess:
          log.i('✓ Transfer SUCCESS — ${event.reference} | ₦${event.amount}');
        case WebhookEventType.transferFailed:
          log.w('✗ Transfer FAILED — ${event.reference}');
        case WebhookEventType.poolFunded:
          log.i('💰 Pool funded — ₦${event.amount}');
      }
    } catch (e, st) {
      log.e('Failed to parse webhook', error: e, stackTrace: st);
    }
  }

  /// ★ HACKATHON DEMO — call this to trigger a live balance update on screen.
  /// Run this from a second browser tab or a Dart test during your pitch.
  void simulateTransferSuccess({
    required String reference,
    required double amount,
    required String employeeName,
  }) {
    log.i('DEMO: Simulating transfer success for $employeeName (₦$amount)');
    processIncomingEvent({
      'event': 'transfer.success',
      'reference': reference,
      'amount': amount,
      'recipient_name': employeeName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void dispose() => _controller.close();
}
