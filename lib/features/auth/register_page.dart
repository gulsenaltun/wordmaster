import 'package:flutter/material.dart';
import 'package:worlde_mobile/features/auth/auth_page.dart';
import 'package:worlde_mobile/features/auth/home_page.dart';

class Register extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Color) onColorChanged;

  const Register({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
  });

  @override
  State<Register> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService auth = AuthService();
  bool isLoading = false;

  String getErrorMessage(dynamic error) {
    String errorMessage = error.toString();

    if (errorMessage.contains('user-not-found')) {
      return 'Bu email adresi ile kayıtlı bir kullanıcı bulunamadı.';
    } else if (errorMessage.contains('wrong-password')) {
      return 'Hatalı şifre girdiniz.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'Geçersiz email adresi.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'Bu hesap devre dışı bırakılmış.';
    } else if (errorMessage.contains('too-many-requests')) {
      return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
    } else if (errorMessage.contains('network-request-failed')) {
      return 'İnternet bağlantınızı kontrol edin.';
    } else if (errorMessage.contains('email-already-in-use')) {
      return 'Bu email adresi zaten kullanımda.';
    } else if (errorMessage.contains('weak-password')) {
      return 'Şifre çok zayıf. En az 6 karakter kullanın.';
    } else if (errorMessage.contains('operation-not-allowed')) {
      return 'Bu işlem şu anda kullanılamıyor.';
    } else {
      return 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
    }
  }

  Future<void> register() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Şifreler eşleşmiyor')));
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre en az 6 karakter olmalıdır')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await auth.registerEmailPassword(
        '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
        emailController.text.trim(),
        passwordController.text,
        DateTime.now().toString(),
      );

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              onThemeChanged: widget.onThemeChanged,
              onColorChanged: widget.onColorChanged,
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Soyisim',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                child: TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                child: TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Şifre Tekrar',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text("Kayıt Ol"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
