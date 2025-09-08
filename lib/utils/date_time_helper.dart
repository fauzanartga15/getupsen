import 'package:intl/intl.dart';

class DateTimeHelper {
  /// Ambil format sesuai server
  static Map<String, String> getServerDateTime({DateTime? dateTime}) {
    final now = dateTime ?? DateTime.now();

    final date = DateFormat('yyyy-MM-dd').format(now);
    final time = DateFormat('HH:mm:ss').format(now);

    return {"date": date, "time": time};
  }
}
