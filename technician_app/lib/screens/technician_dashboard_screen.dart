import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/technician_provider.dart';
import 'active_job_screen.dart';
import 'jobs_history_screen.dart';
import 'earnings_screen.dart';
import 'technician_profile_screen.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() => _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _RadarFeedView(),
      const JobsHistoryScreen(),
      const EarningsScreen(),
      const TechnicianProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: screens[_currentTab],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(top: BorderSide(color: Color(0xFF334155))),
        ),
        child: NavigationBar(
          selectedIndex: _currentTab,
          backgroundColor: const Color(0xFF1E293B),
          indicatorColor: const Color(0xFF2563EB).withValues(alpha: 0.25),
          onDestinationSelected: (idx) => setState(() => _currentTab = idx),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.radar_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.radar_rounded, color: Color(0xFF38BDF8)),
              label: 'Dispatch',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.assignment_rounded, color: Color(0xFF38BDF8)),
              label: 'Jobs',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF38BDF8)),
              label: 'Earnings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
              selectedIcon: Icon(Icons.person, color: Color(0xFF38BDF8)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarFeedView extends StatelessWidget {
  const _RadarFeedView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TechnicianProvider>();
    final tech = provider.currentTechnician;
    final isOnline = provider.isOnline;
    final activeJob = provider.activeJob;
    final requests = provider.incomingRequests;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Online Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(
                      tech?.fullName.isNotEmpty == true ? tech!.fullName[0].toUpperCase() : 'T',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tech?.fullName ?? 'Technician Pro',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Color(0xFF38BDF8), size: 14),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 13),
                            const SizedBox(width: 3),
                            Text(
                              '${tech?.rating ?? 4.9} (${tech?.completedJobsCount ?? 0} jobs)',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Online / Offline Toggle Button
                  GestureDetector(
                    onTap: () => provider.toggleAvailability(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFF10B981) : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isOnline
                            ? [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.white : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline ? 'ONLINE' : 'OFFLINE',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Performance Stats Grid
            Row(
              children: [
                _buildStatCard('Today Payout', 'PKR ${tech?.todayEarnings.toInt() ?? 0}', Icons.payments_outlined, const Color(0xFF10B981)),
                const SizedBox(width: 10),
                _buildStatCard('Wallet Balance', 'PKR ${tech?.totalWalletBalance.toInt() ?? 0}', Icons.account_balance_wallet_outlined, const Color(0xFF38BDF8)),
                const SizedBox(width: 10),
                _buildStatCard('Completed', '${tech?.completedJobsCount ?? 0}', Icons.task_alt_outlined, const Color(0xFFF59E0B)),
              ],
            ),
            const SizedBox(height: 18),

            // Active Job Banner (if exists)
            if (activeJob != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('ACTIVE JOB IN PROGRESS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                        Text(activeJob.bookingNumber, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      activeJob.serviceName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client: ${activeJob.customerName} • ${activeJob.address.street}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1D4ED8),
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ActiveJobScreen()),
                        );
                      },
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: const Text('Open Job Tracker & Map', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Dispatch Radar Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Incoming Dispatch Radar',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    if (isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${requests.length} Nearby', style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                if (isOnline && activeJob == null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => provider.simulateIncomingJob(),
                    icon: const Icon(Icons.add_alert_outlined, size: 16),
                    label: const Text('Test Job', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (!isOnline)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.power_settings_new_rounded, size: 48, color: Color(0xFF64748B)),
                    const SizedBox(height: 10),
                    const Text('You are currently Offline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text(
                      'Switch to Online at the top to receive instant booking alerts from nearby homeowners.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => provider.toggleAvailability(),
                      child: const Text('Go Online Now', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              )
            else if (requests.isEmpty && activeJob == null)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 3),
                    ),
                    const SizedBox(height: 14),
                    const Text('Radar Active • Scanning Sector...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text(
                      'Listening for emergency and scheduled repair requests in Lahore.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF38BDF8),
                        side: const BorderSide(color: Color(0xFF38BDF8)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => provider.simulateIncomingJob(),
                      icon: const Icon(Icons.flash_on, size: 16),
                      label: const Text('Simulate Incoming Request', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              )
            else
              ...requests.map((job) => _buildRequestCard(context, provider, job)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, TechnicianProvider provider, TechJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job.serviceCategoryName.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'Estimated Payout: PKR ${job.technicianPayout.toInt()}',
                style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            job.serviceName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job.address.street}, ${job.address.city}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Complaint: "${job.complaintTitle}" - ${job.complaintDescription}',
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => provider.declineJob(job.id),
                  child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    provider.acceptJob(job);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveJobScreen()),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accept Job', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

