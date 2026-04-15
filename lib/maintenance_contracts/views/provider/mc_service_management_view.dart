import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../controllers/mc_provider_dashboard_controller.dart';
import '../../controllers/mc_provider_auth_controller.dart';
import '../../models/mc_service_model.dart';

class McServiceManagementView extends StatelessWidget {
  const McServiceManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = context.watch<McProviderDashboardController>();
    final providerId = context.read<McProviderAuthController>().currentProvider?.id ?? '';

    return Scaffold(
      body: dashboardController.services.isEmpty
          ? Center(child: Text("No services listed yet.", style: TextStyle(color: Colors.grey, fontSize: 14.sp)))
          : ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: dashboardController.services.length,
              itemBuilder: (context, index) {
                final service = dashboardController.services[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(3.w),
                    title: Text(service.title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp)),
                    subtitle: Text("${service.category} • \$${service.price}", style: TextStyle(color: Colors.grey[400])),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        dashboardController.deleteService(service.id, providerId);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0EA5E9),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddServiceDialog(context, providerId),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, String providerId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("Add New Service", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: catCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Category")),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Price")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newService = McServiceModel(
                id: '',
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                category: catCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                providerId: providerId,
              );
              context.read<McProviderDashboardController>().addService(newService);
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
