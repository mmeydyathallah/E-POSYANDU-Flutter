import 'package:isar/isar.dart';

part 'models.g.dart';

@embedded
class Riwayat {
  String? tanggal;
  double? berat;
  double? tinggi;

  Riwayat({this.tanggal, this.berat, this.tinggi});

  factory Riwayat.fromJson(Map<dynamic, dynamic> json) {
    return Riwayat(
      tanggal: json['tanggal'],
      berat: (json['berat'] ?? 0).toDouble(),
      tinggi: (json['tinggi'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tanggal': tanggal, 'berat': berat, 'tinggi': tinggi};
  }
}

@collection
class Balita {
  Id id; // Isar auto-increment ID

  @Index(unique: true, replace: true)
  String? uid;

  String? nama;
  String? namaAyah;
  String? namaIbu;
  int? usia;
  double? lingkarKepala;
  String? keterangan;
  double? berat;
  double? tinggi;
  List<Riwayat>? riwayat;
  String? tanggalDaftar;
  String? jenisKelamin;
  String? tanggalLahir;
  String? fotoProfile; // Local path to the selected image

  Balita({
    this.id = Isar.autoIncrement,
    this.uid,
    this.nama,
    this.namaAyah,
    this.namaIbu,
    this.usia,
    this.lingkarKepala,
    this.keterangan,
    this.berat,
    this.tinggi,
    this.riwayat,
    this.tanggalDaftar,
    this.jenisKelamin,
    this.tanggalLahir,
    this.fotoProfile,
  });

  factory Balita.fromJson(Map<dynamic, dynamic> json) {
    var rawRiwayat = json['riwayat'] as List<dynamic>? ?? [];
    List<Riwayat> riwayatList = rawRiwayat
        .map((e) => Riwayat.fromJson(e as Map<dynamic, dynamic>))
        .toList();

    return Balita(
      uid: json['uid'],
      nama: json['nama'] ?? '',
      namaAyah: json['namaAyah'] ?? '',
      namaIbu: json['namaIbu'] ?? '',
      usia: json['usia'] ?? 0,
      lingkarKepala: (json['lingkarKepala'] ?? 0).toDouble(),
      keterangan: json['keterangan'] ?? '',
      berat: (json['berat'] ?? 0).toDouble(),
      tinggi: (json['tinggi'] ?? 0).toDouble(),
      riwayat: riwayatList,
      tanggalDaftar: json['tanggalDaftar'] ?? '',
      jenisKelamin: json['jenisKelamin'] ?? '',
      tanggalLahir: json['tanggalLahir'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nama': nama,
      'namaAyah': namaAyah,
      'namaIbu': namaIbu,
      'usia': usia,
      'lingkarKepala': lingkarKepala,
      'keterangan': keterangan,
      'berat': berat,
      'tinggi': tinggi,
      'riwayat': riwayat?.map((r) => r.toJson()).toList() ?? [],
      'tanggalDaftar': tanggalDaftar,
      'jenisKelamin': jenisKelamin,
      'tanggalLahir': tanggalLahir,
    };
  }
}

@collection
class AppConfig {
  Id id = 0;
  String? adminName;
  String? posyanduName;
  String? adminPhoto;

  AppConfig({this.adminName, this.posyanduName, this.adminPhoto});
}

class SensorData {
  final double berat;
  final double tinggi;

  SensorData({required this.berat, required this.tinggi});

  factory SensorData.fromJson(Map<dynamic, dynamic> json) {
    return SensorData(
      berat: (json['berat'] ?? 0).toDouble(),
      tinggi: (json['tinggi'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'berat': berat, 'tinggi': tinggi};
  }
}
