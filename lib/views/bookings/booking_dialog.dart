import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localization.dart';
import '../../models/booking_model.dart';
import '../../providers/bookings_provider.dart';

class BookingDialog extends ConsumerStatefulWidget {
  final BookingModel? bookingToEdit;

  const BookingDialog({super.key, this.bookingToEdit});

  @override
  ConsumerState<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends ConsumerState<BookingDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _guestsController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _requestsController;

  String _seatingPreference = 'any';
  String _status = 'pending';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.bookingToEdit;
    _nameController = TextEditingController(text: b?.fullName ?? '');
    _phoneController = TextEditingController(text: b?.phone ?? '');
    _guestsController = TextEditingController(text: b != null ? b.guestsCount.toString() : '2');
    _dateController = TextEditingController(text: b?.bookingDate ?? DateTime.now().toString().substring(0, 10));
    _timeController = TextEditingController(text: b?.bookingTime ?? '08:00 PM');
    _requestsController = TextEditingController(text: b?.specialRequests ?? '');

    // Normalize seating preference to prevent Dropdown assertion errors with legacy values (e.g. 'summer')
    final rawPref = b?.seatingPreference ?? 'any';
    if (rawPref == 'summer' || rawPref == 'summer_garden') {
      _seatingPreference = 'summer_garden';
    } else if (rawPref == 'winter' || rawPref == 'winter_lounge') {
      _seatingPreference = 'winter_lounge';
    } else {
      _seatingPreference = 'any';
    }

    // Normalize status
    final rawStatus = b?.status ?? 'pending';
    if (['pending', 'confirmed', 'completed', 'cancelled'].contains(rawStatus)) {
      _status = rawStatus;
    } else {
      _status = 'pending';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _guestsController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final actions = ref.read(bookingActionsProvider);

    try {
      if (widget.bookingToEdit == null) {
        final newBooking = BookingModel(
          id: '',
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          guestsCount: int.tryParse(_guestsController.text.trim()) ?? 1,
          bookingDate: _dateController.text.trim(),
          bookingTime: _timeController.text.trim(),
          seatingPreference: _seatingPreference,
          specialRequests: _requestsController.text.trim(),
          status: _status,
          createdAt: DateTime.now(),
        );
        await actions.addBooking(newBooking);
      } else {
        final updated = widget.bookingToEdit!.copyWith(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          guestsCount: int.tryParse(_guestsController.text.trim()) ?? 1,
          bookingDate: _dateController.text.trim(),
          bookingTime: _timeController.text.trim(),
          seatingPreference: _seatingPreference,
          specialRequests: _requestsController.text.trim(),
          status: _status,
        );
        await actions.updateBooking(updated);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    final isEdit = widget.bookingToEdit != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return AlertDialog(
      title: Text(
        isEdit ? 'تعديل الحجز' : 'إضافة حجز جديد',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Cairo'),
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 550),
        width: screenWidth * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: loc.translate('customer_name'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: loc.translate('phone_number'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),

                // Guests Count & Date
                if (isMobile) ...[
                  TextFormField(
                    controller: _guestsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: loc.translate('guests_count'),
                      prefixIcon: const Icon(Icons.group_outlined),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: loc.translate('booking_date'),
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _guestsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: loc.translate('guests_count'),
                            prefixIcon: const Icon(Icons.group_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: loc.translate('booking_date'),
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Time & Seating Preference
                if (isMobile) ...[
                  TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelText: loc.translate('booking_time'),
                      prefixIcon: const Icon(Icons.access_time_outlined),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _seatingPreference,
                    decoration: InputDecoration(
                      labelText: loc.translate('seating_preference'),
                    ),
                    items: [
                      DropdownMenuItem(value: 'any', child: Text(loc.translate('seating_any'))),
                      DropdownMenuItem(value: 'summer_garden', child: Text(loc.translate('summer_garden'))),
                      DropdownMenuItem(value: 'winter_lounge', child: Text(loc.translate('winter_lounge'))),
                    ],
                    onChanged: (val) => setState(() => _seatingPreference = val ?? 'any'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _timeController,
                          decoration: InputDecoration(
                            labelText: loc.translate('booking_time'),
                            prefixIcon: const Icon(Icons.access_time_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _seatingPreference,
                          decoration: InputDecoration(
                            labelText: loc.translate('seating_preference'),
                          ),
                          items: [
                            DropdownMenuItem(value: 'any', child: Text(loc.translate('seating_any'))),
                            DropdownMenuItem(value: 'summer_garden', child: Text(loc.translate('summer_garden'))),
                            DropdownMenuItem(value: 'winter_lounge', child: Text(loc.translate('winter_lounge'))),
                          ],
                          onChanged: (val) => setState(() => _seatingPreference = val ?? 'any'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: loc.translate('status'),
                  ),
                  items: [
                    DropdownMenuItem(value: 'pending', child: Text(loc.translate('status_pending'))),
                    DropdownMenuItem(value: 'confirmed', child: Text(loc.translate('status_confirmed'))),
                    DropdownMenuItem(value: 'completed', child: Text(loc.translate('status_completed'))),
                    DropdownMenuItem(value: 'cancelled', child: Text(loc.translate('status_cancelled'))),
                  ],
                  onChanged: (val) => setState(() => _status = val ?? 'pending'),
                ),
                const SizedBox(height: 12),

                // Special Requests
                TextFormField(
                  controller: _requestsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: loc.translate('special_requests'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(loc.translate('save')),
        ),
      ],
    );
  }
}
