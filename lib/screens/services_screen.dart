import 'package:flutter/material.dart';
import '../apexfix_theme.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import 'category_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final categories = MockData.categories.where((category) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return category.title.toLowerCase().contains(q) || category.description.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(title: const Text('Services')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(hintText: 'Search services...', prefixIcon: Icon(Icons.search_rounded)),
          ),
          const SizedBox(height: 18),
          const Text('All services', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: Text('No matching services', style: TextStyle(color: muted))),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15),
              itemBuilder: (context, index) => _ServiceCard(category: categories[index]),
            ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceCategory category;
  const _ServiceCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(category: category))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFEDEBFF), borderRadius: BorderRadius.circular(11)), child: Icon(_iconFor(category.iconName), color: primary, size: 22)),
          const SizedBox(height: 10),
          Text(category.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 3),
          Text('From PKR ${category.startingPrice.toInt()}', style: const TextStyle(fontSize: 10, color: muted)),
        ]),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'wind': return Icons.air_rounded;
      case 'zap': return Icons.bolt_rounded;
      case 'droplet': return Icons.water_drop_rounded;
      case 'cpu': return Icons.kitchen_rounded;
      case 'hammer': return Icons.handyman_rounded;
      case 'sun': return Icons.solar_power_rounded;
      default: return Icons.build_rounded;
    }
  }
}
