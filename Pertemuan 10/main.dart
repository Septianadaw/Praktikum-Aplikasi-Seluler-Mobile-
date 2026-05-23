import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'item_model.dart';

void main() {
  runApp(const MyApp());
}

// CONSTANTS
const kPrimary = Color(0xFF5B4FE9);
const kPrimaryLight = Color(0xFF7B72F0);
const kAccent = Color(0xFFFFD166);
const kBg = Color(0xFFF4F3FF);
const kCard = Colors.white;
const kRed = Color(0xFFFF6B6B);
const kGreen = Color(0xFF06D6A0);

const List<String> kCategories = [
  'Semua',
  'Elektronik',
  'Furnitur',
  'Pakaian',
  'Makanan',
  'Buku',
  'Olahraga',
  'Kesehatan',
  'Kendaraan',
  'Lainnya',
];

const List<String> kPriorities = ['Rendah', 'Normal', 'Tinggi'];

const List<String> kIcons = [
  '📦', '💻', '🖱️', '⌨️', '📱', '🎧', '🖥️', '📷', '🎮', '🔌',
  '🛋️', '🪑', '🛏️', '🚿', '🪴',
  '👕', '👖', '👟', '🧢', '👜',
  '🍎', '🥤', '🍱', '☕', '🍕',
  '📚', '📓', '📖', '✏️', '🗂️',
  '⚽', '🏋️', '🚴', '🎾', '🏊',
  '💊', '🩺', '🧴', '🩹', '🌡️',
  '🚗', '🛵', '🚲', '🛴', '⛽',
  '🔧', '🔑', '💡', '🧹', '🪣',
];

// APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koleksi Itemku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        scaffoldBackgroundColor: kBg,
        useMaterial3: true,
      ),
      home: const ItemListPage(),
    );
  }
}

// HOME / LIST PAGE
class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  String _selectedCategory = 'Semua';
  int _bottomNavIndex = 0;
  bool _isGridView = false;

  final TextEditingController _searchController = TextEditingController();

  final List<ItemModel> _dummyItems = [
    // Elektronik
    ItemModel(
      id: 1,
      name: 'Laptop Gaming',
      description: 'Laptop gaming GPU RTX 4060, RAM 16GB, layar 165Hz IPS. Cocok gaming & video editing.',
      category: 'Elektronik',
      priority: 'Tinggi',
      isFavorite: true,
      iconEmoji: '💻',
      addedAt: DateTime(2025, 5, 12),
      activityLog: ['Ditambahkan — 12 Mei 2025', 'Diedit — 14 Mei 2025', 'Difavoritkan — 15 Mei 2025'],
    ),
    ItemModel(
      id: 2,
      name: 'Headphone ANC',
      description: 'Sony WH-1000XM5 · Noise cancelling aktif · Baterai 30 jam.',
      category: 'Elektronik',
      priority: 'Normal',
      isFavorite: true,
      iconEmoji: '🎧',
      addedAt: DateTime(2025, 5, 6),
      activityLog: ['Ditambahkan — 6 Mei 2025', 'Difavoritkan — 7 Mei 2025'],
    ),
    ItemModel(
      id: 4,
      name: 'Meja Belajar',
      description: 'Meja kayu minimalis 120x60cm · Laci samping · Finishing anti gores.',
      category: 'Furnitur',
      priority: 'Normal',
      isFavorite: false,
      iconEmoji: '🛋️',
      addedAt: DateTime(2025, 5, 3),
      activityLog: ['Ditambahkan — 3 Mei 2025'],
    ),
    ItemModel(
      id: 7,
      name: 'Clean Code',
      description: 'Robert C. Martin · Panduan menulis kode bersih dan mudah di-maintain.',
      category: 'Buku',
      priority: 'Tinggi',
      isFavorite: true,
      iconEmoji: '📚',
      addedAt: DateTime(2025, 4, 15),
      activityLog: ['Ditambahkan — 15 Apr 2025', 'Difavoritkan — 16 Apr 2025'],
    ),
    ItemModel(
      id: 10,
      name: 'Vitamin C 1000mg',
      description: 'Suplemen imunitas harian · Effervescent rasa jeruk · Isi 30 tablet.',
      category: 'Kesehatan',
      priority: 'Rendah',
      isFavorite: false,
      iconEmoji: '💊',
      addedAt: DateTime(2025, 3, 30),
      activityLog: ['Ditambahkan — 30 Mar 2025'],
    ),
    ItemModel(
      id: 5,
      name: 'Jaket Outdoor',
      description: 'Jaket waterproof ripstop · Hoodie · Cocok hiking & camping.',
      category: 'Pakaian',
      priority: 'Normal',
      isFavorite: false,
      iconEmoji: '👕',
      addedAt: DateTime(2025, 4, 28),
      activityLog: ['Ditambahkan — 28 Apr 2025'],
    ),
    ItemModel(
      id: 11,
      name: 'Helm Full Face',
      description: 'INK CL-MAX · Double visor · SNI certified · Warna matte black.',
      category: 'Kendaraan',
      priority: 'Tinggi',
      isFavorite: false,
      iconEmoji: '🛵',
      addedAt: DateTime(2025, 3, 22),
      activityLog: ['Ditambahkan — 22 Mar 2025'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final matchCat = _selectedCategory == 'Semua' || item.category == _selectedCategory;
        final matchQuery = query.isEmpty ||
            item.name.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
        return matchCat && matchQuery;
      }).toList();
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('items_list_v2');
    if (raw != null) {
      final list = json.decode(raw) as List;
      setState(() {
        _items = list.map((e) => ItemModel.fromMap(e)).toList();
        _applyFilter();
      });
    } else {
      setState(() {
        _items = List.from(_dummyItems);
        _applyFilter();
      });
      await _saveItems();
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('items_list_v2', json.encode(_items.map((e) => e.toMap()).toList()));
  }

  Future<void> _addItem(ItemModel item) async {
    setState(() {
      _items.insert(0, item);
      _applyFilter();
    });
    await _saveItems();
  }

  Future<void> _updateItem(ItemModel updated) async {
    setState(() {
      final idx = _items.indexWhere((e) => e.id == updated.id);
      if (idx != -1) _items[idx] = updated;
      _applyFilter();
    });
    await _saveItems();
  }

  Future<void> _deleteItem(int id) async {
    setState(() {
      _items.removeWhere((e) => e.id == id);
      _applyFilter();
    });
    await _saveItems();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item berhasil dihapus')),
      );
    }
  }

  int get _favoriteCount => _items.where((e) => e.isFavorite).length;
  int get _categoryCount => _items.map((e) => e.category).toSet().length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          // Tab 0: Home
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildCategoryChips(),
                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_filteredItems.length} hasil ditemukan',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                Expanded(child: _buildList()),
              ],
            ),
          ),
          // Tab 1: Favorit
          FavoritePage(
            items: _items.where((e) => e.isFavorite).toList(),
            onTap: _openDetail,
          ),
          // Tab 2: Profil
          ProfilePage(
            items: _items,
            onResetData: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('items_list_v2');
              await _loadData();
              setState(() => _bottomNavIndex = 0);
            },
          ),
        ],
      ),
      floatingActionButton: _bottomNavIndex == 0
          ? FloatingActionButton(
              onPressed: () => _openAddPage(),
              backgroundColor: kPrimary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo, Septiana Daw! 👋', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('Koleksi Itemku',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: const Text('SD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard('${_items.length}', 'Total Item', shade: 0),
              const SizedBox(width: 12),
              _statCard('$_categoryCount', 'Kategori', shade: 1),
              const SizedBox(width: 12),
              _statCard('$_favoriteCount', 'Favorit ★', shade: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, {int shade = 0}) {
    final bgColor = shade == 2
        ? kAccent
        : shade == 1
            ? Color(0xFFFFD166)
            : Color(0xFFFFD166);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari item...',
          prefixIcon: const Icon(Icons.search, color: kPrimary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
              : IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    color: kPrimary,
                  ),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                  tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: kCategories.length,
        itemBuilder: (ctx, i) {
          final cat = kCategories[i];
          final selected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat);
                _applyFilter();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: selected
                      ? [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black54,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📭', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty ? 'Item tidak ditemukan.' : 'Belum ada item. Tambahkan!',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: _filteredItems.length,
        itemBuilder: (ctx, i) => _buildGridCard(_filteredItems[i]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredItems.length,
      itemBuilder: (ctx, i) => _buildItemCard(_filteredItems[i]),
    );
  }

  Widget _buildGridCard(ItemModel item) {
    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(item.iconEmoji, style: const TextStyle(fontSize: 26))),
                ),
                if (item.isFavorite) const Icon(Icons.star, color: kAccent, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 3),
            Text(item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const Spacer(),
            Row(
              children: [
                _chipLabel(item.category, kPrimary.withOpacity(0.12), kPrimary),
                if (item.priority == 'Tinggi') ...[
                  const SizedBox(width: 4),
                  _chipLabel('!', kRed.withOpacity(0.12), kRed),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(ItemModel item) {
    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(item.iconEmoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _chipLabel(item.category, kPrimary.withOpacity(0.12), kPrimary),
                      if (item.priority == 'Tinggi') ...[
                        const SizedBox(width: 6),
                        _chipLabel('Prioritas !', kRed.withOpacity(0.12), kRed),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (item.isFavorite) const Icon(Icons.star, color: kAccent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _chipLabel(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _bottomNavIndex,
      onTap: (i) => setState(() => _bottomNavIndex = i),
      selectedItemColor: kPrimary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.star_rounded), label: 'Favorit'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
      ],
    );
  }

  void _openAddPage() async {
    final result = await Navigator.push<ItemModel>(
      context,
      MaterialPageRoute(builder: (_) => AddItemPage(nextId: _items.isNotEmpty ? _items.last.id + 1 : 1)),
    );
    if (result != null) {
      await _addItem(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item berhasil ditambahkan')),
        );
      }
    }
  }

  void _openDetail(ItemModel item) async {
    final result = await Navigator.push<_DetailResult>(
      context,
      MaterialPageRoute(builder: (_) => DetailItemPage(item: item)),
    );
    if (result == null) return;
    if (result.deleted) {
      await _deleteItem(item.id);
    } else if (result.updated != null) {
      await _updateItem(result.updated!);
    }
  }
}

// ADD ITEM PAGE
class AddItemPage extends StatefulWidget {
  final int nextId;
  const AddItemPage({super.key, required this.nextId});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = kCategories[1];
  String _selectedPriority = 'Normal';
  bool _isFavorite = false;
  String _selectedIcon = '📦';

  void _save() {
    if (_nameController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan deskripsi tidak boleh kosong')),
      );
      return;
    }
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final item = ItemModel(
      id: widget.nextId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      isFavorite: _isFavorite,
      iconEmoji: _selectedIcon,
      addedAt: now,
      activityLog: ['Ditambahkan — $dateStr'],
    );
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Item Baru', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickIcon,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.15), blurRadius: 12)],
                  ),
                  child: Center(child: Text(_selectedIcon, style: const TextStyle(fontSize: 48))),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(child: Text('Ketuk untuk ubah ikon', style: TextStyle(color: Colors.grey, fontSize: 12))),
            const SizedBox(height: 20),
            _label('NAMA ITEM'),
            _inputField(_nameController, 'Masukkan nama item...'),
            const SizedBox(height: 14),
            _label('DESKRIPSI'),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deskripsikan item Anda...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            _label('KATEGORI'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: kCategories
                      .where((c) => c != 'Semua')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _label('PRIORITAS'),
            Row(
              children: kPriorities.map((p) {
                final selected = _selectedPriority == p;
                final color = p == 'Tinggi' ? kRed : p == 'Normal' ? kPrimary : kGreen;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPriority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color, width: selected ? 0 : 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '$p${p == "Tinggi" ? " !" : ""}',
                            style: TextStyle(
                              color: selected ? Colors.white : color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _label('TANDAI FAVORIT'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Simpan sebagai favorit', style: TextStyle(fontSize: 14)),
                Switch(
                  value: _isFavorite,
                  onChanged: (v) => setState(() => _isFavorite = v),
                  activeColor: kPrimary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan Item ✓',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimary, letterSpacing: 0.8)),
      );

  Widget _inputField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: kIcons.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedIcon = kIcons[i]);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedIcon == kIcons[i] ? kPrimary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text(kIcons[i], style: const TextStyle(fontSize: 26))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FAVORIT PAGE
class FavoritePage extends StatelessWidget {
  final List<ItemModel> items;
  final void Function(ItemModel) onTap;

  const FavoritePage({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary, kPrimaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Koleksi Favorit',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statCard('${items.length}', 'Total Favorit', shade: 0),
                    const SizedBox(width: 12),
                    _statCard(
                      '${items.where((e) => e.priority == 'Tinggi').length}',
                      'Prioritas Tinggi',
                      shade: 1,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      '${items.map((e) => e.category).toSet().length}',
                      'Kategori',
                      shade: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⭐', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 8),
                        Text('Belum ada item favorit.\nTambahkan bintang pada item!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      return GestureDetector(
                        onTap: () => onTap(item),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text(item.iconEmoji, style: const TextStyle(fontSize: 24))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text(item.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: kPrimary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6)),
                                      child: Text(item.category,
                                          style: const TextStyle(color: kPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.star_rounded, color: kAccent, size: 22),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, {int shade = 0}) {
    final bgColor = shade == 2
        ? kAccent
        : shade == 1
            ? Color(0xFFFFD166)
            : Color(0xFFFFD166);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// PROFILE PAGE
class ProfilePage extends StatefulWidget {
  final List<ItemModel> items;
  final VoidCallback onResetData;

  const ProfilePage({super.key, required this.items, required this.onResetData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Septiana Daw';
  String _email = 'septiana.daw@gmail.com';
  String _initials = 'SD';

  // Controller untuk form inline
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  // Apakah ada perubahan yang belum disimpan
  bool get _isDirty =>
      _nameCtrl.text.trim() != _name || _emailCtrl.text.trim() != _email;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _name);
    _emailCtrl = TextEditingController(text: _email);
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // Hitung inisial dari nama
  String _buildInitials(String name) {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _saveProfile() {
    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }
    setState(() {
      _name = newName;
      _email = _emailCtrl.text.trim();
      _initials = _buildInitials(_name);
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui ✓')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inisial preview real-time dari input
    final previewInitials = _buildInitials(_nameCtrl.text);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient dengan avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kPrimaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16)],
                    ),
                    child: Center(
                      child: Text(
                        previewInitials,
                        style: const TextStyle(color: kPrimary, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(_name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Form edit profil
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('EDIT PROFIL'),
                    const SizedBox(height: 12),
                    _fieldLabel('Nama'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama...',
                        filled: true,
                        fillColor: kBg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Email'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Masukkan email...',
                        filled: true,
                        fillColor: kBg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isDirty ? _saveProfile : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          disabledBackgroundColor: kPrimary.withOpacity(0.35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Simpan Perubahan ✓',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pengaturan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: _sectionLabel('⚙️  PENGATURAN'),
                  ),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Data?'),
                        content: const Text('Semua item akan dihapus dan dikembalikan ke data awal.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: kRed),
                            onPressed: () {
                              Navigator.pop(ctx);
                              widget.onResetData();
                            },
                            child: const Text('Reset', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: kRed, size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reset Data',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: kRed, fontSize: 14)),
                                Text('Hapus semua item & kembali ke data awal',
                                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text('Koleksi Itemku v1.0.0',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: kPrimary, letterSpacing: 0.8),
      );

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
      );
}

// DETAIL ITEM PAGE
class _DetailResult {
  final bool deleted;
  final ItemModel? updated;
  _DetailResult({this.deleted = false, this.updated});
}

class DetailItemPage extends StatefulWidget {
  final ItemModel item;
  const DetailItemPage({super.key, required this.item});

  @override
  State<DetailItemPage> createState() => _DetailItemPageState();
}

class _DetailItemPageState extends State<DetailItemPage> {
  late ItemModel _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  String get _formattedDate {
    final d = _item.addedAt;
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Color get _priorityColor => _item.priority == 'Tinggi'
      ? kRed
      : _item.priority == 'Normal'
          ? kPrimary
          : kGreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 52, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary, kPrimaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                Text(_item.iconEmoji, style: const TextStyle(fontSize: 64)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(_item.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      GestureDetector(
                        onTap: () {
                          final now = DateTime.now();
                          const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
                          final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
                          setState(() {
                            _item = _item.copyWith(
                              isFavorite: !_item.isFavorite,
                              activityLog: [
                                ..._item.activityLog,
                                '${_item.isFavorite ? "Dihapus dari favorit" : "Difavoritkan"} — $dateStr',
                              ],
                            );
                          });
                        },
                        child: Icon(
                          _item.isFavorite ? Icons.star : Icons.star_border,
                          color: kAccent,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('ID #${_item.id.toString().padLeft(3, '0')} · Ditambahkan $_formattedDate',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _chip(_item.category, kPrimary.withOpacity(0.12), kPrimary),
                      const SizedBox(width: 8),
                      _chip(_item.priority, _priorityColor.withOpacity(0.12), _priorityColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('DESKRIPSI'),
                  Text(_item.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                  const SizedBox(height: 16),
                  _sectionTitle('LOG AKTIVITAS'),
                  ..._item.activityLog.map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $log', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      )),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openEdit(),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit item'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kPrimary),
                            foregroundColor: kPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Hapus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kRed.withOpacity(0.1),
                            foregroundColor: kRed,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.upload, color: kPrimary),
            Icon(Icons.link, color: Colors.grey),
            Icon(Icons.description_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
      );

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimary, letterSpacing: 0.8)),
      );

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: const Text('Item ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, _DetailResult(deleted: true));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openEdit() async {
    final result = await Navigator.push<ItemModel>(
      context,
      MaterialPageRoute(builder: (_) => EditItemPage(item: _item)),
    );
    if (result != null) {
      setState(() => _item = result);
      if (mounted) Navigator.pop(context, _DetailResult(updated: result));
    }
  }
}

// EDIT ITEM PAGE
class EditItemPage extends StatefulWidget {
  final ItemModel item;
  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedPriority;
  late bool _isFavorite;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descController = TextEditingController(text: widget.item.description);
    _selectedCategory = widget.item.category;
    _selectedPriority = widget.item.priority;
    _isFavorite = widget.item.isFavorite;
    _selectedIcon = widget.item.iconEmoji;
  }

  void _save() {
    if (_nameController.text.trim().isEmpty || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan deskripsi tidak boleh kosong')),
      );
      return;
    }
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final updated = widget.item.copyWith(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      isFavorite: _isFavorite,
      iconEmoji: _selectedIcon,
      activityLog: [...widget.item.activityLog, 'Diedit — $dateStr'],
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Item', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickIcon,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.15), blurRadius: 12)],
                  ),
                  child: Center(child: Text(_selectedIcon, style: const TextStyle(fontSize: 48))),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(child: Text('Ketuk untuk ubah ikon', style: TextStyle(color: Colors.grey, fontSize: 12))),
            const SizedBox(height: 20),
            _label('NAMA ITEM'),
            _inputField(_nameController, 'Masukkan nama item...'),
            const SizedBox(height: 14),
            _label('DESKRIPSI'),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deskripsikan item Anda...',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            _label('KATEGORI'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: kCategories.where((c) => c != 'Semua')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _label('PRIORITAS'),
            Row(
              children: kPriorities.map((p) {
                final selected = _selectedPriority == p;
                final color = p == 'Tinggi' ? kRed : p == 'Normal' ? kPrimary : kGreen;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPriority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: color, width: selected ? 0 : 1.5),
                        ),
                        child: Center(
                          child: Text('$p${p == "Tinggi" ? " !" : ""}',
                              style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _label('TANDAI FAVORIT'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Simpan sebagai favorit', style: TextStyle(fontSize: 14)),
                Switch(value: _isFavorite, onChanged: (v) => setState(() => _isFavorite = v), activeColor: kPrimary),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Simpan Perubahan ✓',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimary, letterSpacing: 0.8)),
      );

  Widget _inputField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: kIcons.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedIcon = kIcons[i]);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedIcon == kIcons[i] ? kPrimary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text(kIcons[i], style: const TextStyle(fontSize: 26))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}