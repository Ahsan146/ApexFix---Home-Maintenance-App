import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import '../apexfix_theme.dart';
import 'booking_flow_screen.dart';

class CategoryScreen extends StatelessWidget {
  final ServiceCategory category;
  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final services = MockData.services.where((s) => s.categoryId == category.id).toList();
    final categoryText = Color(int.parse(category.colorText.replaceFirst('#', '0xFF')));
    final categoryBg = Color(int.parse(category.colorBg.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text(category.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: categoryBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: categoryText.withValues(alpha: 0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(category.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: categoryText)),
              const SizedBox(height: 4),
              Text(category.description, style: TextStyle(fontSize: 12, color: categoryText.withValues(alpha: 0.85), height: 1.4)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Available Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (services.isEmpty)
            Container(padding: const EdgeInsets.all(24), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: line)), child: const Column(children: [Icon(Icons.handyman_outlined, size: 40, color: muted), SizedBox(height: 8), Text('Custom diagnostic visit available for this category.', style: TextStyle(color: muted, fontSize: 13))]))
          else
            ...services.map((srv) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(srv.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(srv.description, style: const TextStyle(fontSize: 12, color: muted, height: 1.4)),
                const SizedBox(height: 12),
                Wrap(spacing: 6, runSpacing: 6, children: srv.features.map((f) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check, size: 12, color: Color(0xFF10B981)), const SizedBox(width: 4), Text(f, style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w600))]))).toList()),
                const Divider(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Standard Price', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w600)), Text('PKR ${srv.basePrice.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))]),
                  ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFlowScreen(category: category, service: srv))), child: const Row(children: [Text('Book Pro', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), SizedBox(width: 4), Icon(Icons.arrow_forward, size: 14)])),
                ]),
              ]),
            )),
        ],
      ),
    );
  }
}
