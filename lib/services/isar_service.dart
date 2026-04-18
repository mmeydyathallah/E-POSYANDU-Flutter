import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'activity_log_service.dart';

class IsarService {
  static late Isar _isar;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([BalitaSchema, AppConfigSchema], directory: dir.path);
    _initialized = true;
    await _seedDummyDataIfEmpty();
    await _ensureAppConfig();
  }

  static Isar get isar => _isar;

  // ─── APP CONFIG ───────────────────────────────────────────────────────────

  static Future<void> _ensureAppConfig() async {
    final config = await _isar.appConfigs.get(0);
    if (config == null) {
      await _isar.writeTxn(() async {
        await _isar.appConfigs.put(AppConfig(
          adminName: 'Admin',
          posyanduName: 'Posyandu Kab. Pasuruan',
          adminPhoto: null,
        ));
      });
    }
  }

  Stream<AppConfig?> watchConfig() {
    return _isar.appConfigs.watchObject(0, fireImmediately: true);
  }

  Future<AppConfig?> getConfig() async {
    return await _isar.appConfigs.get(0);
  }

  Future<void> saveConfig(AppConfig config) async {
    config.id = 0;
    await _isar.writeTxn(() async {
      await _isar.appConfigs.put(config);
    });
    await ActivityLogService().log(
      'Config',
      'Profil admin diperbarui (${config.adminName ?? "Admin"}).',
    );
  }

  // ─── SEEDS ────────────────────────────────────────────────────────────────

  static Future<void> _seedDummyDataIfEmpty() async {
    final count = await _isar.balitas.count();
    if (count > 0) return;

    final dummyData = [
      Balita(
        uid: 'dummy-1',
        nama: 'Ahmad Aditya Santoso',
        namaAyah: 'Budi Santoso',
        namaIbu: 'Siti Rahayu',
        usia: 24,
        lingkarKepala: 48.5,
        keterangan: 'Sehat',
        berat: 12.3,
        tinggi: 85.0,
        jenisKelamin: 'L',
        tanggalLahir: '2022-03-10',
        tanggalDaftar: '2022-03-15',
        riwayat: [
          Riwayat(tanggal: '2024-01-10', berat: 11.9, tinggi: 83.0),
          Riwayat(tanggal: '2024-02-10', berat: 12.1, tinggi: 84.0),
          Riwayat(tanggal: '2024-03-10', berat: 12.3, tinggi: 85.0),
        ],
      ),
      Balita(
        uid: 'dummy-2',
        nama: 'Siti Nur Fatimah',
        namaAyah: 'Ahmad Fauzi',
        namaIbu: 'Dewi Lestari',
        usia: 18,
        lingkarKepala: 46.0,
        keterangan: 'Perlu Perhatian',
        berat: 8.5,
        tinggi: 75.0,
        jenisKelamin: 'P',
        tanggalLahir: '2022-09-05',
        tanggalDaftar: '2022-09-10',
        riwayat: [
          Riwayat(tanggal: '2024-01-05', berat: 8.1, tinggi: 73.0),
          Riwayat(tanggal: '2024-02-05', berat: 8.3, tinggi: 74.0),
          Riwayat(tanggal: '2024-03-05', berat: 8.5, tinggi: 75.0),
        ],
      ),
      Balita(
        uid: 'dummy-3',
        nama: 'Kevin Pratama',
        namaAyah: 'Dedi Pratama',
        namaIbu: 'Rini Wulandari',
        usia: 30,
        lingkarKepala: 50.0,
        keterangan: 'Sehat',
        berat: 14.2,
        tinggi: 93.0,
        jenisKelamin: 'L',
        tanggalLahir: '2021-09-20',
        tanggalDaftar: '2021-09-25',
        riwayat: [
          Riwayat(tanggal: '2024-01-20', berat: 13.8, tinggi: 91.0),
          Riwayat(tanggal: '2024-02-20', berat: 14.0, tinggi: 92.0),
          Riwayat(tanggal: '2024-03-20', berat: 14.2, tinggi: 93.0),
        ],
      ),
    ];

    await _isar.writeTxn(() async {
      await _isar.balitas.putAll(dummyData);
    });
  }

  // ─── CRUD ──────────────────────────────────────────────────────────────────

  /// Fetch all balita as a reactive stream
  Stream<List<Balita>> watchAllBalita() {
    return _isar.balitas.where().watch(fireImmediately: true);
  }

  /// Fetch all balita as a one-shot Future
  Future<List<Balita>> getAllBalita() {
    return _isar.balitas.where().findAll();
  }

  /// Save or update a balita (uses uid as unique key via @Index)
  Future<void> saveBalita(Balita balita) async {
    final isNew = balita.id == Isar.autoIncrement;
    await _isar.writeTxn(() async {
      await _isar.balitas.put(balita);
    });
    await ActivityLogService().log(
      'Data Balita',
      isNew
          ? 'Tambah data balita: ${balita.nama ?? "-"}'
          : 'Update data balita: ${balita.nama ?? "-"}',
    );
  }

  /// Add a new Riwayat entry to an existing balita
  Future<void> addRiwayat(Balita balita, Riwayat riwayat) async {
    balita.riwayat = [...(balita.riwayat ?? []), riwayat];
    // Keep the latest summary fields in sync with the newest measurement.
    balita.berat = riwayat.berat;
    balita.tinggi = riwayat.tinggi;
    balita.lingkarKepala = riwayat.lingkarKepala;
    await saveBalita(balita);
    await ActivityLogService().log(
      'Pemeriksaan',
      'Simpan pengukuran ${balita.nama ?? "-"} '
          '(BB ${riwayat.berat?.toStringAsFixed(1) ?? "0.0"} kg, '
          'TB ${riwayat.tinggi?.toStringAsFixed(1) ?? "0.0"} cm'
          '${riwayat.lingkarKepala != null ? ', LK ${riwayat.lingkarKepala!.toStringAsFixed(1)} cm' : ''}).',
    );
  }

  /// Remove a Riwayat entry from an existing balita
  Future<void> deleteRiwayat(Balita balita, int index) async {
    if (balita.riwayat == null || index < 0 || index >= balita.riwayat!.length) return;

    final deleted = balita.riwayat![index];
    final newList = List<Riwayat>.from(balita.riwayat!);
    newList.removeAt(index);
    balita.riwayat = newList;

    // Update latest summary fields after removing a measurement.
    if (newList.isNotEmpty) {
      balita.berat = newList.last.berat;
      balita.tinggi = newList.last.tinggi;
      balita.lingkarKepala = newList.last.lingkarKepala;
    } else {
      balita.berat = 0.0;
      balita.tinggi = 0.0;
      balita.lingkarKepala = 0.0;
    }

    await saveBalita(balita);
    await ActivityLogService().log(
      'Pemeriksaan',
      'Hapus riwayat ${balita.nama ?? "-"} pada ${deleted.tanggal ?? "-"}.',
    );
  }

  /// Delete a balita by Isar id
  Future<void> deleteBalita(int id) async {
    final balita = await _isar.balitas.get(id);
    await _isar.writeTxn(() async {
      await _isar.balitas.delete(id);
    });
    await ActivityLogService().log(
      'Data Balita',
      'Hapus data balita: ${balita?.nama ?? "ID $id"}',
    );
  }
}
