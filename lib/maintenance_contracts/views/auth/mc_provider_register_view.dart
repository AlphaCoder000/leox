import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_auth_controller.dart';
import 'mc_provider_login_view.dart';
import '../provider/mc_provider_dashboard_view.dart';

class McProviderRegisterView extends StatefulWidget {
  const McProviderRegisterView({super.key});

  @override
  State<McProviderRegisterView> createState() => _McProviderRegisterViewState();
}

class _McProviderRegisterViewState extends State<McProviderRegisterView> {
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<McProviderAuthController>();
      final error = await authController.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _companyController.text.trim(),
        _phoneController.text.trim(),
        _locationController.text.trim(),
      );

      if (!mounted) return;

      if (error == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const McProviderDashboardView()),
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
    final authController = context.watch<McProviderAuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Registration"),
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
              color: theme.cardTheme.color?.withValues(alpha: 0.8) ?? Colors.black87,
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
                      Icon(Icons.business_outlined, size: 40.sp, color: const Color(0xFF0EA5E9)),
                      SizedBox(height: 2.h),
                      Text(
                        "Become a Provider",
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 3.h),
                      
                      _buildTextField(_companyController, "Company/Provider Name", Icons.business, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_emailController, "Email Address", Icons.email_outlined, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_phoneController, "Contact Number", Icons.phone_outlined, false),
                      SizedBox(height: 2.h),
                      _buildTextField(_locationController, "Location/City", Icons.location_on_outlined, false),
                      SizedBox(height: 2.h),
                      
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0EA5E9)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
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
                              : Text("Register", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const McProviderLoginView())),
                        child: Text("Already a provider? Login", style: TextStyle(color: const Color(0xFF0EA5E9), fontSize: 13.sp)),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: const Color(0xFF0EA5E9)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[800]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9))),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Required field" : null,
    );
  }
}
