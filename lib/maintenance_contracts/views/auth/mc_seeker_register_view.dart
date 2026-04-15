import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_seeker_auth_controller.dart';
import 'mc_seeker_login_view.dart';
import '../seeker/mc_seeker_dashboard_view.dart';

class McSeekerRegisterView extends StatefulWidget {
  const McSeekerRegisterView({super.key});

  @override
  State<McSeekerRegisterView> createState() => _McSeekerRegisterViewState();
}

class _McSeekerRegisterViewState extends State<McSeekerRegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<McSeekerAuthController>();
      final error = await authController.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _addressController.text.trim(),
      );

      if (!mounted) return;

      if (error == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const McSeekerDashboardView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = context.watch<McSeekerAuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seeker Registration"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.scaffoldBackgroundColor, const Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Card(
              color: theme.cardTheme.color ?? (isDark ? Colors.black87 : Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3)),
              ),
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_alt_1_outlined, size: 40.sp, color: const Color(0xFF0EA5E9)),
                      SizedBox(height: 2.h),
                      Text(
                        "Join as a Seeker",
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      SizedBox(height: 3.h),
                      
                      _buildTextField(_nameController, "Full Name", Icons.person, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_emailController, "Email Address", Icons.email_outlined, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_phoneController, "Contact Number", Icons.phone_outlined, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_addressController, "Full Address", Icons.home_work_outlined, false),
                      SizedBox(height: 2.h),
                      
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0EA5E9)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                      
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: authController.isLoading ? null : _register,
                          child: authController.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text("Create Account", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const McSeekerLoginView())),
                        child: Text("Already have an account? Login", style: TextStyle(color: const Color(0xFF0EA5E9), fontSize: 13.sp)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool obscure) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700]),
        prefixIcon: Icon(icon, color: const Color(0xFF0EA5E9)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Required field" : null,
    );
  }
}
