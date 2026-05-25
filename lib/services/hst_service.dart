import 'package:url_launcher/url_launcher.dart';

class HstService {
  // 🔥 Logika Eksekusi Pembayaran Midtrans
  static Future<void> launchMidtransPayment(String snapToken) async {
    final Uri paymentUrl = Uri.parse(
      "https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken",
    );

    // Buka menggunakan Chrome Custom Tab di dalam aplikasi
    bool launched = await launchUrl(
      paymentUrl,
      mode: LaunchMode.inAppBrowserView,
    );

    if (!launched) {
      throw "Gagal membuka layar pembayaran Midtrans.";
    }
  }
}
