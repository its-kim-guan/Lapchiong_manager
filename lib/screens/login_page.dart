import 'package:flutter/material.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/utils/app_constants.dart';
import 'package:my_app/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final ValueChanged<AppUser> onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  static const _users = <AppUser>[
    AppUser(
      username: adminUsername,
      password: adminPassword,
      name: 'Lapchiong Admin',
      role: UserRole.admin,
    ),
    AppUser(
      username: cashierUsername,
      password: cashierPassword,
      name: 'Lapchiong Cashier',
      role: UserRole.cashier,
    ),
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF600D12), Color(0xFF8F1218), Color(0xFFC2410C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(width: 420, child: _HeroPanel(users: _users)),
                  SizedBox(
                    width: 380,
                    child: Card(
                      color: Colors.white.withAlpha(242),
                      elevation: 16,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Masuk ke Sistem',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF7F1D1D),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Admin dapat menambah barang dan melihat growth. Cashier fokus pada penjualan yang cepat dan akurat.',
                                style: TextStyle(
                                  color: Color(0xFF7C2D12),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              AppTextField(
                                controller: _usernameController,
                                label: 'Username',
                                prefixIcon: Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFB91C1C),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: _submit,
                                  child: const Text('Login'),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  void _submit() {
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    AppUser? user;
    for (final item in _users) {
      if (item.username == username) {
        user = item;
        break;
      }
    }

    if (user == null || user.password != password) {
      setState(() {
        _errorMessage = 'Username atau password tidak cocok.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });
    widget.onLogin(user);
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.users});

  final List<AppUser> users;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Chinese Lapchiong Manager',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Color(0xFFD44A4A),
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Satu aplikasi untuk stok, transaksi, dan pertumbuhan bisnis. Pilih akun yang sesuai dengan tanggung jawab tim Anda.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        ...users.map(
          (user) => Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
              top: 4,
            ), // 🔥 spacing here
            child: Card(
              color: Colors.white.withAlpha(242),
              elevation: 12,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFECACA),
                  child: Text(
                    user.role.label.characters.first,
                    style: const TextStyle(
                      color: Color(0xFF7F1D1D),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                title: Text(
                  user.role.label,
                  style: const TextStyle(
                    color: Color(0xFF7F1D1D),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  '${user.role.description}\nLogin: ${user.username} / ${user.password}',
                  style: const TextStyle(
                    color: Color(0xFF7C2D12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
