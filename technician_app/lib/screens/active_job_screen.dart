import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/technician_provider.dart';

class ActiveJobScreen extends StatelessWidget {
  const ActiveJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TechnicianProvider>();
    final job = provider.activeJob;

    if (job == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: const Text('Active Job'),
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No active job in progress', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final custLatLng = LatLng(job.address.latitude, job.address.longitude);
    final techLatLng = LatLng(custLatLng.latitude - 0.008, custLatLng.longitude - 0.006);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.bookingNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text(job.serviceName, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2563EB)),
            ),
            child: Text(
              job.status.name.toUpperCase(),
              style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Interactive Map View
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: custLatLng,
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.apexfix.technician',
                    ),
                    MarkerLayer(
                      markers: [
                        // Customer Marker
                        Marker(
                          point: custLatLng,
                          width: 44,
                          height: 44,
                          child: const Icon(Icons.location_on, color: Color(0xFFEF4444), size: 40),
                        ),
                        // Technician Marker
                        Marker(
                          point: techLatLng,
                          width: 36,
                          height: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                            ),
                            child: const Icon(Icons.two_wheeler, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // ETA banner over map
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.navigation_rounded, color: Color(0xFF38BDF8), size: 18),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Distance to Client', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                                Text(
                                  job.status == BookingStatus.arrived || job.status == BookingStatus.workInProgress
                                      ? 'On Site with Client'
                                      : '2.4 km • ~9 mins arrival',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          'PKR ${job.technicianPayout.toInt()}',
                          style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Job Actions Sheet
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: Color(0xFF334155))),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer & Contact Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF334155),
                          child: Text(
                            job.customerName.isNotEmpty ? job.customerName[0].toUpperCase() : 'C',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.customerName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              Text(
                                job.address.street,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                            foregroundColor: const Color(0xFF10B981),
                          ),
                          icon: const Icon(Icons.phone),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling client ${job.customerPhone}...')),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
                            foregroundColor: const Color(0xFF60A5FA),
                          ),
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening chat with client...')),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFF334155)),

                    // Complaint Details
                    const Text('Reported Fault & Complaint', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      job.complaintTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.complaintDescription,
                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    // Progression Action Button
                    _buildActionButton(context, provider, job),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, TechnicianProvider provider, TechJob job) {
    switch (job.status) {
      case BookingStatus.accepted:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => provider.updateActiveJobStatus(BookingStatus.onTheWay),
          icon: const Icon(Icons.directions_bike),
          label: const Text('Start Route (Mark En Route)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        );

      case BookingStatus.onTheWay:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => provider.updateActiveJobStatus(BookingStatus.arrived),
          icon: const Icon(Icons.location_on),
          label: const Text('Mark Arrived at Location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        );

      case BookingStatus.arrived:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => provider.updateActiveJobStatus(BookingStatus.workInProgress),
          icon: const Icon(Icons.build),
          label: const Text('Begin Inspection & Work', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        );

      case BookingStatus.workInProgress:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Complete Service Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Confirm job completion and payment collection from customer:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Customer Bill:', style: TextStyle(color: Colors.white70)),
                        Text('PKR ${job.serviceCharge.total.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your Net Earnings:', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
                        Text('PKR ${job.technicianPayout.toInt()}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8)))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      provider.updateActiveJobStatus(BookingStatus.completed);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Job Completed! +PKR ${job.technicianPayout.toInt()} added to your wallet.'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    },
                    child: const Text('Confirm & Collect Payment'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Finish Job & Collect Payment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

