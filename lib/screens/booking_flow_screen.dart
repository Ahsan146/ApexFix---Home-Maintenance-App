import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'track_booking_screen.dart';

class BookingFlowScreen extends StatefulWidget {
  final ServiceCategory category;
  final ServiceItem service;

  const BookingFlowScreen({
    super.key,
    required this.category,
    required this.service,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0; // 0: Address, 1: Date & Time, 2: Review & Submit
  bool _isSubmitting = false;

  Address? _selectedAddress;
  String _selectedDate = '';
  String _selectedTimeSlot = '';
  final _complaintTitleController = TextEditingController();
  final _complaintDescController = TextEditingController();

  final List<String> _dates = [
    'Today, Sep 6',
    'Tomorrow, Sep 7',
    'Mon, Sep 8',
    'Tue, Sep 9',
  ];

  final List<String> _timeSlots = [
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = _dates.first;
    _selectedTimeSlot = _timeSlots.first;
    _complaintTitleController.text = '${widget.service.title} Issue';
    _complaintDescController.text =
        'Please inspect and service unit. Noticeable performance reduction and sound.';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = context.read<AppProvider>();
    _selectedAddress ??= app.currentCustomer?.addresses.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.service.basePrice;
    final tax = subtotal * 0.05;
    final total = subtotal + tax;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Book Professional Repair',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildStepPill(0, 'Address'),
                _buildStepDivider(0),
                _buildStepPill(1, 'Schedule'),
                _buildStepDivider(1),
                _buildStepPill(2, 'Review'),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStepView(),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'PKR ${total.toInt()}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _isSubmitting ? null : _handleNextOrSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _currentStep == 2 ? 'Confirm & Find Tech' : 'Continue',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill(int index, String title) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;

    return Row(
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: isDone
              ? const Color(0xFF10B981)
              : isActive
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFE2E8F0),
          child: isDone
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int afterIndex) {
    final isPassed = _currentStep > afterIndex;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isPassed ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep();
      case 1:
        return _buildScheduleStep();
      case 2:
      default:
        return _buildReviewStep();
    }
  }

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
                decoration: const InputDecoration(labelText: 'Label (e.g. Home, Office)', hintText: 'Home'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Street Address & House #', hintText: 'e.g. House 12, Street 4, Sector B'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City', hintText: 'Lahore'),
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
                setState(() => _selectedAddress = newAddr);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save & Select'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    final app = context.watch<AppProvider>();
    final addresses = app.currentCustomer?.addresses ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Service Location',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            GestureDetector(
              onTap: () => _showAddAddressDialog(context),
              child: const Text(
                '+ Add Address',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Our verified specialist will arrive at this address with tools.',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),
        if (addresses.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.location_off_outlined, color: Color(0xFF94A3B8), size: 36),
                const SizedBox(height: 8),
                const Text(
                  'No Saved Address Found',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please add a service location for your technician visit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showAddAddressDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Service Address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
          )
        else
          ...addresses.map((addr) {
            final isSelected = _selectedAddress?.id == addr.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedAddress = addr),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addr.label,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${addr.street}, ${addr.city}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildScheduleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Service Slot',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 14),
        Row(
          children: ['Today (Urgent)', 'Tomorrow, Sep 7', 'Sep 8, 2026'].map((d) {
            final isSel = _selectedDate == d;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = d),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFEEF2FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? const Color(0xFF4F46E5) : const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Available Arrival Windows',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        ..._timeSlots.map((slot) {
          final isSel = _selectedTimeSlot == slot;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeSlot = slot),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFFEEF2FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSel ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    slot,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? const Color(0xFF4F46E5) : const Color(0xFF334155),
                    ),
                  ),
                  if (isSel) const Icon(Icons.check_circle, color: Color(0xFF4F46E5), size: 18),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              Text(
                widget.service.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                widget.category.title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Text('$_selectedDate • $_selectedTimeSlot', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${_selectedAddress?.street}, ${_selectedAddress?.city}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Complaint Notes
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
              const Text(
                'Fault Description for Technician',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _complaintDescController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe the issue...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Cost Breakdown
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
              const Text(
                'Payment Summary',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              _buildCostRow('Standard Service Charge', 'PKR ${widget.service.basePrice.toInt()}'),
              const SizedBox(height: 8),
              _buildCostRow('Safety & Platform Fee (5%)', 'PKR ${(widget.service.basePrice * 0.05).toInt()}'),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              _buildCostRow('Total Estimate', 'PKR ${(widget.service.basePrice * 1.05).toInt()}', isBold: true),
              const SizedBox(height: 8),
              const Text(
                'Pay securely via Cash, Card, or Bank Transfer after technician completion.',
                style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String title, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 15 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Future<void> _handleNextOrSubmit() async {
    if (_currentStep == 0 && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a service address to proceed.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A service address is required to complete booking.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final app = context.read<AppProvider>();
    final newBooking = await app.createBooking(
      category: widget.category,
      service: widget.service,
      address: _selectedAddress!,
      date: _selectedDate,
      timeSlot: _selectedTimeSlot,
      complaintTitle: _complaintTitleController.text.trim().isNotEmpty
          ? _complaintTitleController.text.trim()
          : '${widget.service.title} Booking',
      complaintDescription: _complaintDescController.text.trim(),
    );
    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TrackBookingScreen(bookingId: newBooking.id),
        ),
      );
    }
  }
}
