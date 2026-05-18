// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'result_page.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  String? _selectedCategory;
  String  _selectedGender = '';
  bool    _submitted      = false;

  // error message ditampilkan di luar box
  String? _nameError;
  String? _weightError;
  String? _heightError;

  // ── Palet warna ────────────────────────────────────────────────────────────
  static const navy       = Color(0xFF0D1B5E);
  static const navyLight  = Color(0xFF1A2D80);
  static const navyBorder = Color(0xFF1E3A8A);
  static const navyAccent = Color(0xFF2563EB);
  static const hintCol    = Color(0xFF7C9CC9);
  static const bodyBg     = Color(0xFFF8FAFF);
  static const mutedCol   = Color(0xFF94A3B8);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyBg,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Nama Lengkap ──────────────────────────────────────
                    _SectionTitle(
                      icon: Icons.person_outline_rounded,
                      label: 'NAMA LENGKAP',
                    ),
                    SizedBox(height: 8),
                    _WhiteBox(
                      hasError: _nameError != null,
                      child: TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        style: _inputStyle(),
                        onChanged: (_) {
                          if (_nameError != null)
                            setState(() => _nameError = null);
                        },
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            _nameError = 'Mohon isi nama kamu';
                            return '';
                          }
                          _nameError = null;
                          return null;
                        },
                        decoration: _hintDeco(
                          hint: 'Masukkan nama lengkap kamu...',
                          prefix: Icons.badge_outlined,
                        ),
                      ),
                    ),
                    if (_nameError != null) _errorMsg(_nameError!),

                    SizedBox(height: 22),

                    // ── Berat & Tinggi ────────────────────────────────────
                    _SectionTitle(
                      icon: Icons.straighten_rounded,
                      label: 'BERAT & TINGGI BADAN',
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _WhiteBox(
                                hasError: _weightError != null,
                                child: TextFormField(
                                  controller: _weightCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputStyle(),
                                  onChanged: (_) {
                                    if (_weightError != null)
                                      setState(() => _weightError = null);
                                  },
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      _weightError = 'Isi berat';
                                      return '';
                                    }
                                    _weightError = null;
                                    return null;
                                  },
                                  decoration: _hintDeco(
                                    hint: '65',
                                    suffix: 'kg',
                                  ),
                                ),
                              ),
                              if (_weightError != null) _errorMsg(_weightError!),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _WhiteBox(
                                hasError: _heightError != null,
                                child: TextFormField(
                                  controller: _heightCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputStyle(),
                                  onChanged: (_) {
                                    if (_heightError != null)
                                      setState(() => _heightError = null);
                                  },
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      _heightError = 'Isi tinggi';
                                      return '';
                                    }
                                    _heightError = null;
                                    return null;
                                  },
                                  decoration: _hintDeco(
                                    hint: '170',
                                    suffix: 'cm',
                                  ),
                                ),
                              ),
                              if (_heightError != null) _errorMsg(_heightError!),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 22),

                    // ── Kategori Usia ─────────────────────────────────────
                    _SectionTitle(
                      icon: Icons.cake_rounded,
                      label: 'KATEGORI USIA',
                    ),
                    SizedBox(height: 8),
                    _buildCategorySelector(),
                    if (_submitted && _selectedCategory == null)
                      Padding(
                        padding: EdgeInsets.only(top: 6, left: 2),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 13, color: Colors.redAccent),
                            SizedBox(width: 4),
                            Text('Pilih kategori usia',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.redAccent)),
                          ],
                        ),
                      ),

                    SizedBox(height: 22),

                    // ── Jenis Kelamin ─────────────────────────────────────
                    _SectionTitle(
                      icon: Icons.wc_rounded,
                      label: 'JENIS KELAMIN',
                    ),
                    SizedBox(height: 8),
                    _buildGenderSelector(),
                    if (_submitted && _selectedGender.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 6, left: 2),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 13, color: Colors.redAccent),
                            SizedBox(width: 4),
                            Text('Pilih jenis kelamin',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.redAccent)),
                          ],
                        ),
                      ),

                    SizedBox(height: 32),

                    // ── Tombol ───────────────────────────────────────────
                    _buildHitungButton(),
                    SizedBox(height: 12),
                    _buildResetButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [navy, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40, top: -40,
            child: _Bubble(180, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            left: -30, bottom: -50,
            child: _Bubble(140, Colors.white.withOpacity(0.05)),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 36),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'KALKULATOR BMI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.more_horiz,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 28),
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.monitor_heart_outlined,
                        color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Cek BMI Kamu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Isi data di bawah untuk mengetahui\nIndeks Massa Tubuh kamu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kategori Usia ──────────────────────────────────────────────────────────
  static const _cats = [
    ('Anak-anak', Icons.child_care_rounded, '2–12 thn'),
    ('Remaja',    Icons.school_rounded,      '13–17 thn'),
    ('Dewasa',    Icons.person_rounded,      '18+ thn'),
  ];

  Widget _buildCategorySelector() {
    return Row(
      children: _cats.map((c) {
        final sel    = _selectedCategory == c.$1;
        final isLast = c.$1 == 'Dewasa';
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = c.$1),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : 10),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? navy : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? navyAccent : Color(0xFFDDE4F0),
                  width: sel ? 2 : 1.5,
                ),
                boxShadow: sel
                    ? [BoxShadow(
                        color: navy.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4))]
                    : [BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Icon(c.$2,
                      size: 20,
                      color: sel ? Colors.white : navy),
                  SizedBox(height: 6),
                  Text(c.$1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : navy,
                      )),
                  SizedBox(height: 2),
                  Text(c.$3,
                      style: TextStyle(
                        fontSize: 11,
                        color: sel
                            ? Colors.white.withOpacity(0.65)
                            : mutedCol,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Jenis Kelamin ──────────────────────────────────────────────────────────
  Widget _buildGenderSelector() {
    return Row(
      children: [
        _genderBtn('Laki-laki', Icons.male_rounded),
        SizedBox(width: 10),
        _genderBtn('Perempuan', Icons.female_rounded),
      ],
    );
  }

  Widget _genderBtn(String label, IconData icon) {
    final sel = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? navy : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: sel ? navyAccent : Color(0xFFDDE4F0),
              width: sel ? 2 : 1.5,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: navy.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4))]
                : [BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: sel ? Colors.white : navy),
              SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : navy,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tombol Hitung ──────────────────────────────────────────────────────────
  Widget _buildHitungButton() {
    return GestureDetector(
      onTap: _onHitung,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: navyBorder, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_rounded, color: navy, size: 22),
            SizedBox(width: 10),
            Text(
              'Hitung BMI Sekarang',
              style: TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tombol Reset ───────────────────────────────────────────────────────────
  Widget _buildResetButton() {
    return GestureDetector(
      onTap: _onReset,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: navyBorder, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, color: navy, size: 22),
            SizedBox(width: 8),
            Text(
              'Reset semua data',
              style: TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _onHitung() {
    setState(() => _submitted = true);
    if (_selectedGender.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFFCA5A5), size: 18),
              SizedBox(width: 8),
              Text('Lengkapi semua data terlebih dahulu',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
          backgroundColor: Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      final nama     = _nameCtrl.text.trim();
      final berat    = double.parse(_weightCtrl.text);
      final tinggiCm = double.parse(_heightCtrl.text);
      final bmi      = berat / ((tinggiCm / 100) * (tinggiCm / 100));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            nama: nama,
            bmi: bmi,
            gender: _selectedGender,
            kategori: _selectedCategory!,
            berat: berat,
            tinggi: tinggiCm,
          ),
        ),
      );
    }
  }

  void _onReset() {
    setState(() {
      _nameCtrl.clear();
      _weightCtrl.clear();
      _heightCtrl.clear();
      _selectedCategory = null;
      _selectedGender   = '';
      _submitted        = false;
      _nameError        = null;
      _weightError      = null;
      _heightError      = null;
    });
    _formKey.currentState?.reset();
  }

  // ── Error msg di luar box ──────────────────────────────────────────────────
  Widget _errorMsg(String msg) => Padding(
        padding: EdgeInsets.only(top: 5, left: 4),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 12, color: Colors.redAccent),
            SizedBox(width: 4),
            Text(msg,
                style: TextStyle(fontSize: 11, color: Colors.redAccent)),
          ],
        ),
      );

  // ── Style helpers ──────────────────────────────────────────────────────────
  TextStyle _inputStyle() => TextStyle(
        color: navy,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  InputDecoration _hintDeco({
    required String hint,
    IconData? prefix,
    String? suffix,
  }) {
    return InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(
        horizontal: prefix != null ? 0 : 16,
        vertical: 16,
      ),
      hintText: hint,
      hintStyle: TextStyle(
        color: mutedCol,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon: prefix != null
          ? Icon(prefix, color: mutedCol, size: 20)
          : null,
      suffixText: suffix,
      suffixStyle: TextStyle(
        color: mutedCol,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      errorStyle: TextStyle(
        fontSize: 0,
        height: 0,
        color: Colors.transparent,
      ),
      errorMaxLines: 1,
    );
  }
}

// ── White input container ─────────────────────────────────────────────────────
class _WhiteBox extends StatelessWidget {
  final Widget child;
  final bool hasError;
  const _WhiteBox({required this.child, this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? Colors.redAccent : const Color(0xFFDDE4F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Color(0xFF1A2D80)),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Color(0xFF1A2D80),
          ),
        ),
      ],
    );
  }
}

// ── Dekorasi lingkaran header ─────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final double size;
  final Color color;
  const _Bubble(this.size, this.color);

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}