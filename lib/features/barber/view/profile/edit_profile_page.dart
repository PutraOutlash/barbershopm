import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const _gold   = Color(0xFFFFC107);
  static const _bg     = Color(0xFF0D0D0D);
  static const _field  = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _muted  = Color(0xFF8E8E93);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _openCtrl;
  late final TextEditingController _closeCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl    = TextEditingController(text: 'Barber Cave Premium');
    _emailCtrl   = TextEditingController(text: 'hello@barbercave.id');
    _phoneCtrl   = TextEditingController(text: '+62 812-3456-7890');
    _addressCtrl = TextEditingController(
        text: 'Jl. Karimata No. 45, Sumber Sari, Jember, 68121');
    _openCtrl    = TextEditingController(text: '08:00');
    _closeCtrl   = TextEditingController(text: '22:00');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _openCtrl.dispose();
    _closeCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    HapticFeedback.mediumImpact();
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: _gold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────
            _buildHeader(context),
            const Divider(color: Color(0xFF1A1A1A), height: 1),

            // ── Scrollable body ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto profil
                      _buildAvatarSection(),
                      const SizedBox(height: 28),

                      // Form fields
                      _buildFieldLabel('NAMA BARBERSHOP'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameCtrl,
                        hint: 'Barber Cave Premium',
                        icon: Icons.storefront_outlined,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('EMAIL'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailCtrl,
                        hint: 'hello@barbercave.id',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('NOMOR WHATSAPP'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _phoneCtrl,
                        hint: '+62 812-3456-7890',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('ALAMAT LENGKAP'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _addressCtrl,
                        hint: 'Jl. Karimata No. 45...',
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Jam operasional
                      _buildOperasionalSection(),
                      const SizedBox(height: 32),

                      // Tombol simpan
                      _buildSaveButton(),
                      const SizedBox(height: 14),

                      // Batal
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 15),
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Profil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _gold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ── Avatar section ────────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                  color: const Color(0xFF2A2000),
                ),
                alignment: Alignment.center,
                child: const Text('BC',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    )),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: _bg, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.black, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ubah foto',
            style: TextStyle(
              color: _gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Label field ───────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _muted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  // ── TextField modern ──────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1),
      ),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                14, maxLines > 1 ? 14 : 0, 0, 0),
            child: Icon(icon, color: _muted, size: 18),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    TextStyle(color: _muted.withOpacity(0.5), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Jam operasional ───────────────────────────────────────────────────────
  Widget _buildOperasionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jam Operasional',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('JAM BUKA'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _openCtrl,
                    hint: '08:00',
                    icon: Icons.access_time_rounded,
                    keyboardType: TextInputType.datetime,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('JAM TUTUP'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _closeCtrl,
                    hint: '22:00',
                    icon: Icons.access_time_outlined,
                    keyboardType: TextInputType.datetime,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Tombol simpan ─────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _onSave,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_alt_rounded, color: Colors.black, size: 18),
            SizedBox(width: 8),
            Text(
              'Simpan Perubahan',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
