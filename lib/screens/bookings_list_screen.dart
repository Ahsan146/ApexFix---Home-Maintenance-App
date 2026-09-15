import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../apexfix_theme.dart';
import 'track_booking_screen.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});
  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final bookings = app.bookings;
    final active = bookings.where((b) => b.status != BookingStatus.completed && b.status != BookingStatus.cancelled).toList();
    final completed = bookings.where((b) => b.status == BookingStatus.completed).toList();
    final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: const Text('My Repair Bookings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFCBD5E1),
          indicatorColor: const Color(0xFF818CF8),
          tabs: [Tab(text: 'Active (${active.length})'), Tab(text: 'Completed (${completed.length})'), Tab(text: 'Cancelled (${cancelled.length})')],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        _buildBookingList(active),
        _buildBookingList(completed),
        _buildBookingList(cancelled),
      ]),
    );
  }

  Widget _buildBookingList(List<Booking> list) {
    if (list.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.receipt_long_outlined, size: 48, color: muted), SizedBox(height: 12), Text('No bookings found in this section', style: TextStyle(fontSize: 14, color: muted, fontWeight: FontWeight.w600))]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final booking = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(booking.bookingNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primary)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)), child: Text(booking.status.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF334155))))]),
            const SizedBox(height: 8),
            Text(booking.serviceName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${booking.scheduledDate} • ${booking.scheduledTimeSlot}', style: const TextStyle(fontSize: 12, color: muted)),
            const Divider(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('PKR ${booking.serviceCharge.total.toInt()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackBookingScreen(bookingId: booking.id))), child: const Text('Track / Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          ]),
        );
      },
    );
  }
}
