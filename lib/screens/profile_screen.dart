import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showAddAddressDialog(BuildContext context) {
    final labelController = TextEditingController(text: 'Home');
    final streetController = TextEditingController();
    final cityController = TextEditingController(text: 'Lahore');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Service Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label (e.g. Home, Office)',
                  hintText: 'Home',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address & House #',
                  hintText: 'e.g. House 12, Street 4, Sector B',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Lahore',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final street = streetController.text.trim();
              if (street.isNotEmpty) {
                final newAddr = Address(
                  id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                  label: labelController.text.trim().isNotEmpty ? labelController.text.trim() : 'Home',
                  street: street,
                  city: cityController.text.trim().isNotEmpty ? cityController.text.trim() : 'Lahore',
                  state: 'Punjab',
                  zipCode: '54000',
                  latitude: 31.5204,
                  longitude: 74.3587,
                  isDefault: true,
                );
                context.read<AppProvider>().addAddress(newAddr);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final customer = app.currentCustomer;

    if (customer == null) {
      return const Scaffold(
        body: Center(child: Text('Not signed in')),
      );
    }

    final initial = customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Customer Account',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 29, 67),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFEEF2FF),
                    backgroundImage: customer.avatarUrl != null ? NetworkImage(customer.avatarUrl!) : null,
                    child: customer.avatarUrl == null
                        ? Text(
                            initial,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5)),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.fullName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.email,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        if (customer.phoneNumber.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.phoneNumber,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Saved Addresses
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saved Service Addresses',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      GestureDetector(
                        onTap: () => _showAddAddressDialog(context),
                        child: const Text(
                          '+ Add New',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (customer.addresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.location_off_outlined, color: Color(0xFF94A3B8), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'No saved addresses yet. Tap "+ Add New" to add.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  else
                    ...customer.addresses.map((a) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.home_outlined, color: Color(0xFF4F46E5)),
                          title: Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: Text('${a.street}, ${a.city}', style: const TextStyle(fontSize: 11)),
                          trailing: a.isDefault
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'DEFAULT',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5)),
                                  ),
                                )
                              : null,
                        )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Help & Support
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.headset_mic_outlined, color: Color(0xFF334155)),
                    title: const Text('24/7 Customer Support', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    leading: const Icon(Icons.verified_outlined, color: Color(0xFF10B981)),
                    title: const Text('Warranty & Guarantee Policy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                    title: const Text('Log Out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                    onTap: () => app.logout(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

