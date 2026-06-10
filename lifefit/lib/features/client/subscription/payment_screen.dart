import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/subscription_service.dart';

/// Terminal outcome returned to [ExpertSubscriptionPayment.start].
enum PaymentResult { success, cancelled, failed }

/// WebView wrapper for the Moamalat payment gateway.
/// Receives checkout params from backend → JS callbacks → confirm/fail API.
class MoamalatPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const MoamalatPaymentScreen({super.key, required this.paymentData});

  /// Opens the payment screen and returns a [PaymentResult].
  static Future<PaymentResult?> open(
    BuildContext context,
    Map<String, dynamic> paymentData,
  ) {
    return Navigator.push<PaymentResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MoamalatPaymentScreen(paymentData: paymentData),
      ),
    );
  }

  @override
  State<MoamalatPaymentScreen> createState() => _MoamalatPaymentScreenState();
}

class _MoamalatPaymentScreenState extends State<MoamalatPaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final d = widget.paymentData;
    final html = _buildHtml(
      merchantId: d['MerchantId']?.toString() ?? '',
      terminalId: d['TerminalId']?.toString() ?? '',
      amount: d['Amount']?.toString() ?? '0',
      merchantReference: d['MerchantReference']?.toString() ?? '',
      dateTime: d['DateTimeLocalTrxn']?.toString() ?? '',
      secureHash: d['SecureHash']?.toString() ?? '',
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..addJavaScriptChannel(
        'MoamalatCallback',
        onMessageReceived: _handleCallback,
      )
      ..loadHtmlString(html);
  }

  /// Handles callbacks sent from the JS code inside the WebView.
  void _handleCallback(JavaScriptMessage message) {
    try {
      final json = jsonDecode(message.message) as Map<String, dynamic>;
      final type = json['type'] as String?;

      if (type == 'complete') {
        // Payment successful on gateway side, now confirm with our backend.
        final networkRef = (json['data'] as Map<String, dynamic>?)
            ?['NetworkReference'] as String?;
        _confirmPayment(networkRef);
      } else if (type == 'cancel') {
        if (mounted) Navigator.pop(context, PaymentResult.cancelled);
      } else if (type == 'error') {
        final code = (json['data'] as Map<String, dynamic>?)
            ?['errorCode'] as String?;
        _failPayment(code);
      }
    } catch (_) {
      if (mounted) Navigator.pop(context, PaymentResult.failed);
    }
  }

  /// Verification step: verify the transaction with the app server.
  Future<void> _confirmPayment(String? networkRef) async {
    try {
      await SubscriptionService().confirmPayment(
        merchantReference:
            widget.paymentData['MerchantReference']?.toString() ?? '',
        networkReference: networkRef,
      );
      if (mounted) Navigator.pop(context, PaymentResult.success);
    } catch (_) {
      if (mounted) Navigator.pop(context, PaymentResult.failed);
    }
  }

  /// Logging failure: notify backend about the failed attempt.
  Future<void> _failPayment(String? errorCode) async {
    await SubscriptionService().failPayment(
      merchantReference:
          widget.paymentData['MerchantReference']?.toString() ?? '',
      errorCode: errorCode,
    );
    if (mounted) Navigator.pop(context, PaymentResult.failed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, PaymentResult.cancelled),
        ),
        title: const Text(
          'الدفع الإلكتروني',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: const Row(
              children: [
                Icon(Icons.lock_outline,
                    color: AppColors.primary, size: 16),
                SizedBox(width: 4),
                Text('آمن',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('جاري تحميل بوابة الدفع...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _buildHtml({
    required String merchantId,
    required String terminalId,
    required String amount,
    required String merchantReference,
    required String dateTime,
    required String secureHash,
  }) {
    return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://tnpg.moamalat.net:6006/js/lightbox.js"></script>
  <style>
    body {
      margin: 0;
      background: #F8FAFC;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      font-family: sans-serif;
    }
    .msg {
      text-align: center;
      color: #64748B;
      font-size: 15px;
    }
    .dot { animation: blink 1.2s infinite; }
    @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.3} }
  </style>
</head>
<body>
  
  <script>
    function startPayment() {
      if (typeof Lightbox === 'undefined') {
        setTimeout(startPayment, 500);
        return;
      }
      var LB = Lightbox.Checkout;
      LB.configure = {
        MID: '$merchantId',
        TID: '$terminalId',
        AmountTrxn: $amount,
        MerchantReference: '$merchantReference',
        TrxDateTime: '$dateTime',
        SecureHash: '$secureHash',
        completeCallback: function(response) {
          MoamalatCallback.postMessage(JSON.stringify({
            type: 'complete',
            data: response
          }));
        },
        cancelCallback: function() {
          MoamalatCallback.postMessage(JSON.stringify({ type: 'cancel' }));
        },
        errorCallback: function(err) {
          MoamalatCallback.postMessage(JSON.stringify({
            type: 'error',
            data: err
          }));
        }
      };
      LB.showLightbox();
    }
    window.addEventListener('load', startPayment);
  </script>
</body>
</html>
''';
  }
}
