import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class TrackBookingScreen extends StatelessWidget {
  final String bookingId;

  const TrackBookingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final booking = app.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => app.bookings.first,
    );

    final isAssigned = booking.technician != null &&
        booking.status != BookingStatus.pending &&
        booking.status != BookingStatus.searchingTechnician;

    final isEnRoute = booking.status == BookingStatus.onTheWay;
    final isArrived = booking.status == BookingStatus.arrived;
    final isWorkInProgress = booking.status == BookingStatus.workInProgress;
    final isCompleted = booking.status == BookingStatus.completed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Job Tracking & Dispatch',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            Text(
              booking.bookingNumber,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 5, 29, 67),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Simulated View
            Container(
              height: 240,
              width: double.infinity,
              color: const Color(0xFFE2E8F0),
              child: Stack(
                children: [
                  // Map Background Simulation Grid
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2F6),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=1000&auto=format&fit=crop&q=80',
                        ),
                        fit: BoxFit.cover,
                        opacity: 0.25,
                      ),
                    ),
                  ),

                  // Customer Destination Pin
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            booking.address.label,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 36),
                      ],
                    ),
                  ),

                  // Technician Moving Pin (Only if assigned)
                  if (isAssigned)
                    Positioned(
                      top: 40,
                      left: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.technician?.fullName ?? 'Technician',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFF4F46E5),
                            child: Icon(Icons.two_wheeler, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),

                  // Floating Status / ETA Card
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (!isAssigned)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                            )
                          else if (isEnRoute)
                            const Icon(Icons.access_time_filled, color: Color(0xFF10B981), size: 18)
                          else
                            const Icon(Icons.verified, color: Color(0xFF4F46E5), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  !isAssigned
                                      ? 'Searching for Nearby Technician...'
                                      : isEnRoute
                                          ? 'Arriving in ~${booking.estimatedArrivalMinutes ?? 12} mins'
                                          : isArrived
                                              ? 'Technician Arrived at Location'
                                              : isWorkInProgress
                                                  ? 'Service in Progress'
                                                  : isCompleted
                                                      ? 'Service Completed'
                                                      : 'Technician Assigned • Preparing Dispatch',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  !isAssigned
                                      ? 'Broadcasting to verified specialists'
                                      : isEnRoute
                                          ? 'Live GPS En Route'
                                          : 'Status updated in real-time',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Progression Steps
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
                              'Service Progression',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                booking.status.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStepBadge('Finding', !isAssigned),
                            _buildStepBadge('Assigned', isAssigned && !isEnRoute && !isArrived && !isWorkInProgress && !isCompleted),
                            _buildStepBadge('En Route', isEnRoute),
                            _buildStepBadge('On Site', isArrived || isWorkInProgress),
                            _buildStepBadge('Done', isCompleted),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Card: Searching Radar vs Assigned Tech Profile
                  if (!isAssigned)
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
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: const Icon(Icons.radar_rounded, color: Color(0xFF2563EB)),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dispatching Nearby Specialist',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      'Broadcasting request in Lahore sector...',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 42),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              context.read<AppProvider>().updateBookingStatus(
                                    booking.id,
                                    BookingStatus.technicianAssigned,
                                  );
                            },
                            child: const Text('Auto-Assign Technician (Demo)', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  booking.technician?.avatarUrl ??
                                      'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=200&auto=format&fit=crop&q=80',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.technician?.fullName ?? 'Assigned Technician',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${booking.technician?.rating ?? 4.9} (${booking.technician?.reviewCount ?? 142} reviews)',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.phone, color: Color(0xFF10B981)),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.message, color: Color(0xFF4F46E5)),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          if (booking.technician?.vehicleInfo != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.two_wheeler, size: 16, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 6),
                                  Text(
                                    booking.technician!.vehicleInfo!,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          // Simulation Transition Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.read<AppProvider>().updateBookingStatus(
                                          booking.id,
                                          BookingStatus.onTheWay,
                                        );
                                  },
                                  child: const Text('En Route', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.read<AppProvider>().updateBookingStatus(
                                          booking.id,
                                          BookingStatus.arrived,
                                        );
                                  },
                                  child: const Text('Arrived', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    context.read<AppProvider>().updateBookingStatus(
                                          booking.id,
                                          BookingStatus.completed,
                                        );
                                  },
                                  child: const Text('Complete', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBadge(String label, bool isCurrent) {
    return Column(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isCurrent ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          child: Icon(
            Icons.circle,
            size: 8,
            color: isCurrent ? Colors.white : Colors.transparent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
