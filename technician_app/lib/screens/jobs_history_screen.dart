import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/technician_provider.dart';

class JobsHistoryScreen extends StatelessWidget {
  const JobsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TechnicianProvider>();
    final jobs = provider.jobsHistory;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Job History & Logs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: jobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: const Icon(Icons.assignment_turned_in_outlined, size: 40, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  const Text('No Completed Jobs Yet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    'When you accept and finish repair jobs, their records and payouts will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(job.bookingNumber, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w700, fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('COMPLETED', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(job.serviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Client: ${job.customerName} • ${job.address.city}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      const Divider(height: 20, color: Color(0xFF334155)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                              const SizedBox(width: 4),
                              Text('${job.customerRating ?? 5.0}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                            ],
                          ),
                          Text(
                            'Earned: PKR ${job.technicianPayout.toInt()}',
                            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

