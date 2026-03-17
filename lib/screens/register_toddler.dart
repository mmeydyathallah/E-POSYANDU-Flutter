import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:isar/isar.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/models.dart';
import '../services/isar_service.dart';
import '../widgets/modern_notification.dart';

class RegisterToddlerScreen extends StatefulWidget {
  final Balita? balitaToEdit;
  const RegisterToddlerScreen({Key? key, this.balitaToEdit}) : super(key: key);

  @override
  State<RegisterToddlerScreen> createState() => _RegisterToddlerScreenState();
}

class _RegisterToddlerScreenState extends State<RegisterToddlerScreen> {
  int _currentIndex = -1;
  String _selectedGender = 'male';

  final _namaCtrl = TextEditingController();
  final _namaAyahCtrl = TextEditingController();
  final _namaIbuCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _lingkarKepalaCtrl = TextEditingController();
  final _usiaCtrl = TextEditingController();
  bool _isSaving = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.balitaToEdit != null) {
      final b = widget.balitaToEdit!;
      _namaCtrl.text = b.nama ?? '';
      _namaAyahCtrl.text = b.namaAyah ?? '';
      _namaIbuCtrl.text = b.namaIbu ?? '';
      _tanggalLahirCtrl.text = b.tanggalLahir ?? '';
      _lingkarKepalaCtrl.text = b.lingkarKepala?.toString() ?? '';
      _usiaCtrl.text = b.usia?.toString() ?? '';
      _selectedGender = (b.jenisKelamin == 'P') ? 'female' : 'male';
      if (b.fotoProfile != null && b.fotoProfile!.isNotEmpty) {
        _selectedImage = File(b.fotoProfile!);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final savedImage = await File(
          pickedFile.path,
        ).copy('${appDir.path}/$uniqueFileName');

        setState(() {
          _selectedImage = savedImage;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ModernNotification.show(context, 'Gagal mengambil gambar: $e');
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _namaAyahCtrl.dispose();
    _namaIbuCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _lingkarKepalaCtrl.dispose();
    _usiaCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRegistration() async {
    if (_namaCtrl.text.isEmpty) {
      ModernNotification.show(context, 'Nama anak tidak boleh kosong!');
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final balita = Balita(
      id: widget.balitaToEdit?.id ?? Isar.autoIncrement,
      uid: widget.balitaToEdit?.uid ?? 'balita-${now.millisecondsSinceEpoch}',
      nama: _namaCtrl.text.trim(),
      namaAyah: _namaAyahCtrl.text.trim(),
      namaIbu: _namaIbuCtrl.text.trim(),
      tanggalLahir: _tanggalLahirCtrl.text.trim().isEmpty
          ? now.toIso8601String().substring(0, 10)
          : _tanggalLahirCtrl.text.trim(),
      tanggalDaftar:
          widget.balitaToEdit?.tanggalDaftar ??
          now.toIso8601String().substring(0, 10),
      jenisKelamin: _selectedGender == 'male' ? 'L' : 'P',
      lingkarKepala: double.tryParse(_lingkarKepalaCtrl.text) ?? 0.0,
      usia: int.tryParse(_usiaCtrl.text) ?? widget.balitaToEdit?.usia ?? 0,
      berat: widget.balitaToEdit?.berat ?? 0.0,
      tinggi: widget.balitaToEdit?.tinggi ?? 0.0,
      keterangan: widget.balitaToEdit?.keterangan ?? 'Sehat',
      riwayat: widget.balitaToEdit?.riwayat ?? [],
      fotoProfile: _selectedImage?.path,
    );

    await IsarService().saveBalita(balita);

    setState(() => _isSaving = false);

    if (!mounted) return;
    final msg = widget.balitaToEdit != null
        ? 'Data berhasil diperbarui!'
        : 'Berhasil mendaftar balita baru!';
    ModernNotification.show(context, msg);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.balitaToEdit != null;
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    isEdit ? 'Edit Data Balita' : 'Register New Toddler',
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEdit ? Icons.edit : Icons.child_care,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitles(isEdit),
                        const SizedBox(height: 24),
                        _buildRegistrationForm(isEdit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (_currentIndex == index) return;
              setState(() => _currentIndex = index);
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/toddler_data');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/growth');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/export');
                  break;
              }
            },
            onAddTap: () {
              Navigator.pushNamed(context, '/input');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitles(bool isEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHILD INFORMATION',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isEdit
              ? 'Perbarui informasi balita untuk menjaga akurasi data pemantauan kesehatan.'
              : 'Please fill in the details accurately to ensure proper health monitoring.',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildImagePickerTile()),
          const SizedBox(height: 24),
          _buildTextField(
            "Child's Full Name",
            'e.g. Liam Alexander',
            Icons.person_outline,
            controller: _namaCtrl,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            "Father's Name",
            'Name of father',
            null,
            controller: _namaAyahCtrl,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            "Mother's Name",
            'Name of mother',
            null,
            controller: _namaIbuCtrl,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Date of Birth',
            'YYYY-MM-DD',
            Icons.calendar_today_outlined,
            isDate: true,
            controller: _tanggalLahirCtrl,
          ),
          const SizedBox(height: 24),
          const Text(
            'GENDER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'male',
                  label: Text('Male'),
                  icon: Icon(Icons.male),
                ),
                ButtonSegment(
                  value: 'female',
                  label: Text('Female'),
                  icon: Icon(Icons.female),
                ),
              ],
              selected: {_selectedGender},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedGender = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.primary,
                selectedForegroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Initial Head Circumference (cm)',
            'e.g. 35.5',
            Icons.straighten_outlined,
            isNumber: true,
            controller: _lingkarKepalaCtrl,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Usia (Bulan)',
            'Contoh: 12',
            Icons.cake_outlined,
            isNumber: true,
            controller: _usiaCtrl,
          ),
          const SizedBox(height: 32),
          _buildSaveButton(isEdit),
        ],
      ),
    );
  }

  Widget _buildImagePickerTile() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: _selectedImage!.path.startsWith('http')
                        ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                        : Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.primary.withValues(alpha: 0.5),
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData? icon, {
    bool isDate = false,
    bool isNumber = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          readOnly: isDate,
          onTap: isDate
              ? () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2022),
                    firstDate: DateTime(2019),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    controller?.text = picked.toIso8601String().substring(
                      0,
                      10,
                    );
                  }
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            prefixIcon: icon != null ? Icon(icon, color: Colors.black38) : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return FilledButton.icon(
      onPressed: _isSaving ? null : _saveRegistration,
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(isEdit ? Icons.save : Icons.how_to_reg),
      label: Text(
        _isSaving
            ? 'Menyimpan...'
            : (isEdit ? 'Simpan Perubahan' : 'Save Registration'),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
