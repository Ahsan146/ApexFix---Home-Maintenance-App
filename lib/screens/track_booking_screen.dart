import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../apexfix_theme.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class TrackBookingScreen extends StatelessWidget {
  final String bookingId;
  const TrackBookingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final matches = app.bookings.where((b) => b.id == bookingId).toList();
    if (matches.isEmpty) {
      return Scaffold(backgroundColor: pageBg, appBar: AppBar(title: const Text('Track Booking')), body: const Center(child: Text('Booking is no longer available.')));
    }
    final booking = matches.first;
    final isAssigned = booking.technician != null && booking.status != BookingStatus.pending && booking.status != BookingStatus.searchingTechnician;
    final isEnRoute = booking.status == BookingStatus.onTheWay;
    final isArrived = booking.status == BookingStatus.arrived;
    final isWorkInProgress = booking.status == BookingStatus.workInProgress;
    final isCompleted = booking.status == BookingStatus.completed;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Column(children: [const Text('Job Tracking & Dispatch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)), Text(booking.bookingNumber, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: Color(0xFFCBD5E1)))]),
        centerTitle: true,
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(child: Column(children: [
        Container(
          height: 240,
          width: double.infinity,
          color: const Color(0xFFE2E8F0),
          child: Stack(children: [
            Container(decoration: const BoxDecoration(color: Color(0xFFEEF2F6), image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=1000&auto=format&fit=crop&q=80'), fit: BoxFit.cover, opacity: 0.25))),
            Align(alignment: Alignment.center, child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(6)), child: Text(booking.address.label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))), const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 36)])),
            if (isAssigned) Positioned(top: 40, left: 60, child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(6)), child: Text(booking.technician?.fullName ?? 'Technician', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))), const CircleAvatar(radius: 14, backgroundColor: primary, child: Icon(Icons.two_wheeler, color: Colors.white, size: 16))])),
            Positioned(top: 12, left: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))]), child: Row(children: [if (!isAssigned) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB))) else if (isEnRoute) const Icon(Icons.access_time_filled, color: Color(0xFF10B981), size: 18) else const Icon(Icons.verified, color: primary, size: 18), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(!isAssigned ? 'Searching for Nearby Technician...' : isEnRoute ? 'Arriving in ~${booking.estimatedArrivalMinutes ?? 12} mins' : isArrived ? 'Technician Arrived at Location' : isWorkInProgress ? 'Service in Progress' : isCompleted ? 'Service Completed' : 'Technician Assigned • Preparing Dispatch', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), Text(!isAssigned ? 'Broadcasting to verified specialists' : isEnRoute ? 'Live GPS En Route' : 'Status updated in real-time', style: const TextStyle(fontSize: 10, color: muted))]))]))),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Service Progression', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildStepBadge('Finding', !isAssigned), _buildStepBadge('Assigned', isAssigned && !isEnRoute && !isArrived && !isWorkInProgress && !isCompleted), _buildStepBadge('En Route', isEnRoute), _buildStepBadge('On Site', isArrived || isWorkInProgress), _buildStepBadge('Done', isCompleted)])]),
          const SizedBox(height: 16),
          if (!isAssigned)
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.radar_rounded, color: Color(0xFF2563EB))), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Dispatching Nearby Specialist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), Text('Broadcasting request in Lahore sector...', style: TextStyle(fontSize: 11, color: muted))]))]), const SizedBox(height: 14), ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)), onPressed: () => context.read<AppProvider>().updateBookingStatus(booking.id, BookingStatus.technicianAssigned), child: const Text('Auto-Assign Technician (Demo)'))]))
          else
            _assignedCard(context, booking),
        ])),
      ])),
    );
  }

  Widget _assignedCard(BuildContext context, Booking booking) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: line)), child: Column(children: [Row(children: [CircleAvatar(radius: 24, backgroundImage: NetworkImage(booking.technician?.avatarUrl ?? 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=200&auto=format&fit=crop&q=80')), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.technician?.fullName ?? 'Assigned Technician', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)), Row(children: [const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)), const SizedBox(width: 2), Text('${booking.technician?.rating ?? 4.9} (${booking.technician?.reviewCount ?? 142} reviews)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: muted))])])), IconButton(icon: const Icon(Icons.phone, color: Color(0xFF10B981)), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling technician...')))), IconButton(icon: const Icon(Icons.message, color: primary), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening technician chat...'))))]), const SizedBox(height: 14), Row(children: [Expanded(child: OutlinedButton(onPressed: () => context.read<AppProvider>().updateBookingStatus(booking.id, BookingStatus.onTheWay), child: const Text('En Route', style: TextStyle(fontSize: 11)))), const SizedBox(width: 6), Expanded(child: OutlinedButton(onPressed: () => context.read<AppProvider>().updateBookingStatus(booking.id, BookingStatus.arrived), child: const Text('Arrived', style: TextStyle(fontSize: 11)))), const SizedBox(width: 6), Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)), onPressed: () => context.read<AppProvider>().updateBookingStatus(booking.id, BookingStatus.completed), child: const Text('Complete', style: TextStyle(fontSize: 11))))])])));
  }

  Widget _buildStepBadge(String label, bool isCurrent) => Column(children: [CircleAvatar(radius: 10, backgroundColor: isCurrent ? primary : const Color(0xFFE2E8F0), child: Icon(Icons.circle, size: 8, color: isCurrent ? Colors.white : Colors.transparent)), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500, color: isCurrent ? primary : const Color(0xFF94A3B8)))]);
}
