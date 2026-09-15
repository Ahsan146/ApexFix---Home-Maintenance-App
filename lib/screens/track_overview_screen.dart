import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../apexfix_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'track_booking_screen.dart';

class TrackOverviewScreen extends StatelessWidget {
  const TrackOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final active = app.bookings.where((b) => b.status != BookingStatus.completed && b.status != BookingStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(title: const Text('Track Booking')),
      body: active.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.location_searching_rounded, size: 52, color: muted),
                  SizedBox(height: 14),
                  Text('No active bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Once a booking is confirmed, you can track your technician here.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
                ]),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: active.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = active[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackBookingScreen(bookingId: booking.id))),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEDEBFF), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.route_rounded, color: primary)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(booking.serviceName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${booking.bookingNumber} • ${booking.status.name}', style: const TextStyle(color: muted, fontSize: 11)),
                      ])),
                      const Icon(Icons.chevron_right_rounded, color: muted),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
