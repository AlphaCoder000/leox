import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import '../../models/mc_service_model.dart';
import 'package:leox/widgets/custom_popup.dart';
import 'package:leox/utils/app_theme.dart';
import 'package:flutter/services.dart';

class McAddServiceView extends StatefulWidget {
  final String providerId;
  final McServiceModel? service;
  const McAddServiceView({super.key, required this.providerId, this.service});

  @override
  State<McAddServiceView> createState() => _McAddServiceViewState();
}

class _McAddServiceViewState extends State<McAddServiceView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _startPriceCtrl = TextEditingController();
  final _endPriceCtrl = TextEditingController();
  final _justificationCtrl = TextEditingController();
  String _selectedCurrency = "₹";

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _titleCtrl.text = widget.service!.title;
      _descCtrl.text = widget.service!.description;
      _catCtrl.text = widget.service!.category;
      _justificationCtrl.text = widget.service!.priceJustification;

      // Parse priceRange for matching currency symbol prefix
      String storedPriceRange = widget.service!.priceRange;
      String foundCurrency = "₹";
      for (final symbol in ['A\$', 'AED', 'SAR', 'KWD', 'Rp', '\$', '£', '€', '₹', '¥']) {
        if (storedPriceRange.startsWith(symbol)) {
          foundCurrency = symbol;
          storedPriceRange = storedPriceRange.substring(symbol.length).trim();
          break;
        }
      }
      _selectedCurrency = foundCurrency;
      final parts = storedPriceRange.split('-');
      if (parts.length == 2) {
        _startPriceCtrl.text = parts[0].trim();
        _endPriceCtrl.text = parts[1].trim();
      } else {
        _startPriceCtrl.text = storedPriceRange.trim();
        _endPriceCtrl.text = '';
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _catCtrl.dispose();
    _startPriceCtrl.dispose();
    _endPriceCtrl.dispose();
    _justificationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service != null ? "Edit Service" : "Add New Service",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor.withValues(alpha: 0.95)]
                : [theme.scaffoldBackgroundColor, theme.colorScheme.primary.withValues(alpha: 0.02)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(5.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service != null ? "Update Your Service" : "List a New Service",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "Provide the details below to publish your maintenance service to seekers.",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 3.h),

                // Card wrapping the form fields
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "Basic Information", Icons.info_outline),
                      SizedBox(height: 2.h),

                      // Service Title Field
                      _buildTextField(
                        controller: _titleCtrl,
                        labelText: "Service Title",
                        hintText: "e.g., Steam Turbine Overhauling",
                        icon: Icons.title_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a service title";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.5.h),

                      // Category Field
                      _buildTextField(
                        controller: _catCtrl,
                        labelText: "Category",
                        hintText: "e.g., Steam Turbine Maintainance",
                        icon: Icons.category_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a category";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.5.h),

                      // Service Description Field
                      _buildTextField(
                        controller: _descCtrl,
                        labelText: "Service Description",
                        hintText: "Describe the scope of your service in detail...",
                        icon: Icons.description_rounded,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a description";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),

                // Card wrapping the Pricing fields
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "Pricing & Estimation", Icons.currency_rupee_rounded),
                      SizedBox(height: 2.h),

                      // Price Range Row with Currency Dropdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 25.w,
                            height: 7.2.h,
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: theme.cardColor,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCurrency,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                items: ['₹', '\$', '£', '€', 'A\$', '¥', 'Rp', 'AED', 'SAR', 'KWD'].map((symbol) {
                                  return DropdownMenuItem<String>(
                                    value: symbol,
                                    child: Text(symbol),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCurrency = val!;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _startPriceCtrl,
                                    labelText: "Start Price *",
                                    hintText: "Min price",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Required";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _endPriceCtrl,
                                    labelText: "End Price *",
                                    hintText: "Max price",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Required";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.5.h),

                      // Price Justification Field
                      _buildTextField(
                        controller: _justificationCtrl,
                        labelText: "Price Justification (Optional)",
                        hintText: "Explain why the price ranges (e.g., depends on parts needed, distance, labor time)...",
                        icon: Icons.rate_review_rounded,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitService,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            widget.service != null ? "Save Changes" : "Publish Service",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 18.sp),
        ),
        SizedBox(width: 3.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 16.sp, color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.primary, size: 18.sp) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(fontSize: 15.sp, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
        hintStyle: TextStyle(fontSize: 16.sp, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4)),
        contentPadding: EdgeInsets.all(4.w),
      ),
    );
  }

  void _submitService() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleCtrl.text.trim();
      final desc = _descCtrl.text.trim();
      final cat = _catCtrl.text.trim();
      final priceRange = "$_selectedCurrency ${_startPriceCtrl.text.trim()} - ${_endPriceCtrl.text.trim()}";
      final justification = _justificationCtrl.text.trim();

      double legacyPrice = 0.0;
      legacyPrice = double.tryParse(_startPriceCtrl.text.trim()) ?? 0.0;

      if (widget.service != null) {
        final updatedService = McServiceModel(
          id: widget.service!.id,
          title: title,
          description: desc,
          category: cat,
          price: legacyPrice,
          priceRange: priceRange,
          priceJustification: justification,
          providerId: widget.providerId,
          status: widget.service!.status,
        );

        context.read<McProviderDashboardController>().updateService(updatedService);
        Navigator.pop(context);

        await CustomPopup.show(
          context,
          type: CustomPopupType.success,
          title: 'Service Updated!',
          message: 'Your service "${updatedService.title}" has been updated successfully.',
          buttonLabel: 'Awesome',
        );
      } else {
        final newService = McServiceModel(
          id: '',
          title: title,
          description: desc,
          category: cat,
          price: legacyPrice,
          priceRange: priceRange,
          priceJustification: justification,
          providerId: widget.providerId,
        );

        // Save using dashboard controller
        context.read<McProviderDashboardController>().addService(newService);
        Navigator.pop(context);

        await CustomPopup.show(
          context,
          type: CustomPopupType.success,
          title: 'Service Published!',
          message: 'Your service "${newService.title}" has been listed successfully.',
          buttonLabel: 'Awesome',
        );
      }
    }
  }
}
