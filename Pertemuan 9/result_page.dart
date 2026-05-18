// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final String nama, gender, kategori;
  final double bmi, berat, tinggi;

  const ResultPage({
    required this.nama,
    required this.bmi,
    required this.gender,
    required this.kategori,
    required this.berat,
    required this.tinggi,
    super.key,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  // ── Palet warna — selaras penuh dengan InputPage ──────────────────────────
  static const Color bodyBg     = Color(0xFFF8FAFF);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFDDE4F0);
  static const Color navy       = Color(0xFF0D1B5E);
  static const Color navyLight  = Color(0xFF1A2D80);
  static const Color navyBorder = Color(0xFF1E3A8A);
  static const Color hintCol    = Color(0xFF7C9CC9);
  static const Color mutedCol   = Color(0xFF94A3B8);

  // ── Warna aksen kategori — HANYA untuk angka BMI, badge, dot ─────────────
  Color get _accentColor {
    if (widget.bmi < 18.5) return Color(0xFF2563EB);
    if (widget.bmi < 25.0) return Color(0xFF16A34A);
    if (widget.bmi < 30.0) return Color(0xFFD97706);
    return Color(0xFFDC2626);
  }

  // Warna per baris kategori (tidak berubah sesuai BMI user)
  static const _catColors = [
    Color(0xFF2563EB), // Kurus
    Color(0xFF16A34A), // Normal
    Color(0xFFD97706), // Gemuk
    Color(0xFFDC2626), // Obesitas
  ];

  String _getKategori() {
    if (widget.bmi < 18.5) return 'Kurus';
    if (widget.bmi < 25.0) return 'Normal';
    if (widget.bmi < 30.0) return 'Gemuk';
    return 'Obesitas';
  }

  String _getEmoji() {
    if (widget.bmi < 18.5) return '🥗';
    if (widget.bmi < 25.0) return '💪';
    if (widget.bmi < 30.0) return '⚠️';
    return '🚨';
  }

  String _getSaran() {
    if (widget.bmi < 18.5)
      return 'Tingkatkan asupan nutrisi dan perbanyak makan bergizi.';
    if (widget.bmi < 25.0)
      return 'Pertahankan pola makan sehat dan olahraga rutin!';
    if (widget.bmi < 30.0)
      return 'Mulai kurangi makanan berlemak dan perbanyak aktivitas fisik.';
    return 'Segera konsultasi ke dokter dan atur pola makan dengan ketat.';
  }

  String _getRisiko() {
    if (widget.bmi < 18.5) return 'Rendah';
    if (widget.bmi < 25.0) return 'Minimal';
    if (widget.bmi < 30.0) return 'Sedang';
    return 'Tinggi';
  }

  double get _sliderPos {
    final c = widget.bmi.clamp(10.0, 40.0);
    return (c - 10.0) / 30.0;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return Scaffold(
      backgroundColor: bodyBg,
      body: CustomScrollView(
        slivers: [

          // ── Sliver App Bar — tetap navy, bukan warna kategori ───────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: navy,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHero(accent),
            ),
            title: Text('Hasil BMI',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 36),
              child: Column(
                children: [
                  _buildProfileCard(accent),
                  SizedBox(height: 14),
                  _buildStatsCard(accent),
                  SizedBox(height: 14),
                  _buildSliderCard(accent),
                  SizedBox(height: 14),
                  _buildCategoryCard(),
                  SizedBox(height: 14),
                  _buildSaranCard(accent),
                  SizedBox(height: 28),
                  _buildButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero — navy gradient, angka BMI berwarna aksen ────────────────────────
  Widget _buildHero(Color accent) {
    return Container(
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
            child: _circle(180, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            left: -30, bottom: -50,
            child: _circle(140, Colors.white.withOpacity(0.05)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 8),
                Text(_getEmoji(), style: TextStyle(fontSize: 38)),
                SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Text(
                    (widget.bmi * _anim.value).toStringAsFixed(1),
                    style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Indeks Massa Tubuh',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      letterSpacing: 1.2),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withOpacity(0.5)),
                  ),
                  child: Text(
                    _getKategori(),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile card ──────────────────────────────────────────────────────────
  Widget _buildProfileCard(Color accent) {
    return _WhiteCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: navy.withOpacity(0.08),
            child: Icon(
              widget.gender == 'Laki-laki' ? Icons.male : Icons.female,
              color: navy, size: 30,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.nama,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: navy)),
                SizedBox(height: 4),
                Row(
                  children: [
                    _chip(widget.gender),
                    SizedBox(width: 6),
                    _chip(widget.kategori),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Hanya badge kategori yang pakai warna aksen
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_getKategori(),
                    style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
              SizedBox(height: 3),
              Text('Status BMI',
                  style: TextStyle(fontSize: 11, color: mutedCol)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats card — berat, tinggi, risiko (tanpa duplikat angka BMI) ──────────
  Widget _buildStatsCard(Color accent) {
    return _WhiteCard(
      child: Row(
        children: [
          _statBox('Berat', '${widget.berat.toStringAsFixed(0)} kg'),
          _vertDiv(),
          _statBox('Tinggi', '${widget.tinggi.toStringAsFixed(0)} cm'),
          _vertDiv(),
          _statBox('Risiko', _getRisiko()),
        ],
      ),
    );
  }

  // ── Slider posisi ─────────────────────────────────────────────────────────
  Widget _buildSliderCard(Color accent) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('POSISI BMI KAMU'),
          SizedBox(height: 16),
          LayoutBuilder(builder: (ctx, box) {
            final totalW = box.maxWidth;
            return SizedBox(
              height: 44,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 16, left: 0, right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF16A34A),
                              Color(0xFFD97706),
                              Color(0xFFDC2626),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) {
                      final x = _anim.value * _sliderPos * totalW;
                      return Positioned(
                        top: 6, left: x - 16,
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: navy, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                  color: accent, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Kategori card — card putih, dot berwarna masing-masing ───────────────
  Widget _buildCategoryCard() {
    final rows = [
      ('Kurus',    '< 18.5',    0),
      ('Normal',   '18.5–24.9', 1),
      ('Gemuk',    '25.0–29.9', 2),
      ('Obesitas', '≥ 30.0',    3),
    ];
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('KATEGORI BMI'),
          SizedBox(height: 12),
          ...rows.map((r) {
            final color  = _catColors[r.$3];
            final active = _getKategori() == r.$1;
            return _categoryRow(r.$1, r.$2, color, active);
          }),
        ],
      ),
    );
  }

  Widget _categoryRow(String label, String range, Color color, bool active) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.06) : Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? color.withOpacity(0.35) : cardBorder,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? navy : mutedCol,
                    fontSize: 14)),
          ),
          Text(range,
              style: TextStyle(
                  color: active ? navy : mutedCol,
                  fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 13)),
          if (active) ...[
            SizedBox(width: 8),
            Icon(Icons.check_circle_rounded, color: color, size: 18),
          ],
        ],
      ),
    );
  }

  // ── Saran card ────────────────────────────────────────────────────────────
  Widget _buildSaranCard(Color accent) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF0F4FF), // biru navy sangat pucat — netral
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: navy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.lightbulb_rounded, color: navy, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saran Kesehatan',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: navy)),
                SizedBox(height: 4),
                Text(_getSaran(),
                    style: TextStyle(
                        fontSize: 13,
                        color: hintCol,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tombol Hitung Ulang — putih + navy, sama dgn InputPage ───────────────
  Widget _buildButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, color: navy, size: 22),
            SizedBox(width: 8),
            Text('Hitung Ulang',
                style: TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: navyLight,
            letterSpacing: 1.2),
      );

  // Chip gender & kategori — navy netral, bukan warna aksen
  Widget _chip(String label) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: navy.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: navyLight, fontWeight: FontWeight.w600)),
      );

  // Stat box — nilai navy, label muted
  Widget _statBox(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: navy)),
            SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: mutedCol)),
          ],
        ),
      );

  Widget _vertDiv() => Container(width: 1, height: 32, color: cardBorder);

  Widget _barLabel(String text) => Text(text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 9, color: mutedCol, height: 1.4));

  Widget _circle(double size, Color color) => Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

// ── White card widget ─────────────────────────────────────────────────────────
class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Color(0xFFDDE4F0), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: child,
      );
}