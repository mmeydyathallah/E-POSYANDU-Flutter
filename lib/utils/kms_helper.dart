import '../models/models.dart';

class KmsHelper {
  static const Map<int, List<double>> _whoBoysW = {
    0: [2.5, 3.3, 4.4],
    3: [4.4, 6.0, 7.8],
    6: [6.0, 7.9, 9.8],
    9: [7.1, 9.2, 11.4],
    12: [7.8, 10.2, 12.5],
    15: [8.4, 11.0, 13.5],
    18: [8.8, 11.6, 14.2],
    21: [9.2, 12.2, 14.9],
    24: [9.7, 12.9, 15.7],
    27: [10.0, 13.5, 16.5],
    30: [10.4, 14.0, 17.2],
    36: [11.0, 15.0, 18.4],
    42: [11.6, 16.0, 19.7],
    48: [12.1, 16.9, 20.8],
    54: [12.7, 17.8, 21.9],
    60: [13.1, 18.7, 23.1],
  };

  static const Map<int, List<double>> _whoGirlsW = {
    0: [2.4, 3.2, 4.2],
    3: [4.2, 5.7, 7.4],
    6: [5.7, 7.5, 9.4],
    9: [6.8, 8.9, 11.1],
    12: [7.3, 9.7, 12.1],
    15: [7.8, 10.5, 13.0],
    18: [8.2, 11.0, 13.7],
    21: [8.7, 11.6, 14.4],
    24: [9.1, 12.2, 15.2],
    27: [9.5, 12.8, 16.0],
    30: [9.9, 13.4, 16.7],
    36: [10.5, 14.3, 17.9],
    42: [11.1, 15.2, 19.0],
    48: [11.6, 16.0, 20.1],
    54: [12.1, 16.9, 21.2],
    60: [12.7, 17.7, 22.2],
  };

  static Map<int, List<double>> getReference(String jenisKelamin) {
    return (jenisKelamin == 'P') ? _whoGirlsW : _whoBoysW;
  }

  /// Memilih data referensi (min, median, max) berdasarkan usia terdekat
  static List<double> getReferenceForAge(String jenisKelamin, int ageMoths) {
    final whoRef = getReference(jenisKelamin);
    final ages = whoRef.keys.toList()..sort();

    int ageIdx = ages.first;
    double minDiff = double.maxFinite;
    for (int a in ages) {
      double diff = (a - ageMoths).abs().toDouble();
      if (diff < minDiff) {
        minDiff = diff;
        ageIdx = a;
      }
    }
    return whoRef[ageIdx]!;
  }

  /// Menghitung status berdasarkan data Balita secara dinamis (Database Value Caching)
  /// Mengembalikan nilai baku database ('Sehat', 'Berat Rendah', dsb.)
  static String calculateDbStatus(Balita balita, {double? overrideWeight}) {
    final weight = overrideWeight ?? balita.berat ?? 0.0;
    final age = balita.usia ?? 0;

    // Jika tidak ada data awal dan tidak ada riwayat, dianggap kosong
    final hasRiwayat = balita.riwayat != null && balita.riwayat!.isNotEmpty;
    if (!hasRiwayat && weight <= 0) return 'Data Kosong';
    if (weight <= 0.01) return 'Berat Rendah';

    final ref = getReferenceForAge(balita.jenisKelamin ?? 'L', age);

    if (weight < ref[0]) return 'Berat Rendah';
    if (weight > ref[2]) return 'Berat Lebih';
    return 'Sehat';
  }

  /// Merubah status baku ke bentuk Label Display yang ramah pengguna
  static String getDisplayStatusLabel(String dbStatus) {
    if (dbStatus == 'Berat Rendah' || dbStatus == 'Perlu Perhatian')
      return 'Kurang Optimal';
    if (dbStatus == 'Berat Lebih') return 'Berlebih';
    if (dbStatus == 'Data Kosong') return 'Data Kosong';
    if (dbStatus == 'Sehat') return 'Optimal';
    return dbStatus;
  }

  /// Langsung mendapatkan Label Status dari data Balita (Kalkulasi Live untuk keakuratan Penuh)
  static String getLiveDisplayStatus(Balita balita) {
    String computed = calculateDbStatus(balita);
    return getDisplayStatusLabel(computed);
  }
}
