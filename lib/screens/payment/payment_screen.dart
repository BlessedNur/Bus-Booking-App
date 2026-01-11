import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';
import '../booking/booking_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> busService;
  final String fromLocation;
  final String toLocation;
  final String selectedDate;
  final List<String> selectedSeats;
  final List<Map<String, dynamic>> passengers;
  final String phoneNumber;
  final String email;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.busService,
    required this.fromLocation,
    required this.toLocation,
    required this.selectedDate,
    required this.selectedSeats,
    required this.passengers,
    required this.phoneNumber,
    required this.email,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double seatPrice = (widget.busService['price'] as int).toDouble();
    final double totalPrice = seatPrice * widget.selectedSeats.length;
    final double serviceFee = 500.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Main content
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
            children: [
              // Trip Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.ticket(),
                          size: 20,
                          color: const Color(0xFFFF9500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Trip Summary',
                          style: quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Route
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.fromLocation,
                                style: quicksand(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.busService['departureTime'] as String,
                                style: quicksand(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PhosphorIcon(
                          PhosphorIcons.arrowsLeftRight(),
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.toLocation,
                                style: quicksand(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.busService['arrivalTime'] as String,
                                style: quicksand(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    // Details Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedDate,
                              style: quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.selectedSeats.length} ${widget.selectedSeats.length == 1 ? 'Seat' : 'Seats'}',
                              style: quicksand(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${widget.totalPrice.toStringAsFixed(0)} FCFA',
                          style: quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF9500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Time Warning Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: PhosphorIcon(
                        PhosphorIcons.warning(),
                        size: 20,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important Reminder',
                            style: quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Please arrive at the terminal at least 30 minutes before departure time. Buses depart on time and we cannot guarantee a refund or seat change if you miss your bus.',
                            style: quicksand(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.clock(),
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Departure: ${widget.busService['departureTime'] as String}',
                                  style: quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade900,
                                  ),
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

              const SizedBox(height: 24),

              // Payment Method Selection Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.creditCard(),
                          size: 20,
                          color: const Color(0xFFFF9500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Payment Method',
                          style: quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Mobile Money
                    _buildPaymentOption(
                      'Mobile Money',
                      PhosphorIcons.deviceMobile(),
                      Colors.green,
                      'mobile_money',
                    ),
                    const SizedBox(height: 12),
                    // Orange Money
                    _buildPaymentOption(
                      'Orange Money',
                      PhosphorIcons.deviceMobile(),
                      Colors.orange,
                      'orange_money',
                    ),
                    const SizedBox(height: 12),
                    // Cash
                    _buildPaymentOption(
                      'Cash Payment',
                      PhosphorIcons.money(),
                      Colors.grey.shade700,
                      'cash',
                    ),
                    // Phone Number Field (for mobile money methods)
                    if (_selectedPaymentMethod == 'mobile_money' || _selectedPaymentMethod == 'orange_money')
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter your mobile money number',
                            labelStyle: quicksand(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            prefixIcon: PhosphorIcon(
                              PhosphorIcons.phone(),
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.phone,
                          style: quicksand(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          validator: (value) {
                            if ((_selectedPaymentMethod == 'mobile_money' || _selectedPaymentMethod == 'orange_money') &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                    // Cash Payment Info
                    if (_selectedPaymentMethod == 'cash')
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.info(),
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pay cash directly at the terminal or to the driver. Make sure to arrive 30 minutes before departure.',
                                  style: quicksand(
                                    fontSize: 12,
                                    color: Colors.blue.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Total Amount Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ticket Price',
                          style: quicksand(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(0)} FCFA',
                          style: quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Service Fee',
                          style: quicksand(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${serviceFee.toStringAsFixed(0)} FCFA',
                          style: quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${widget.totalPrice.toStringAsFixed(0)} FCFA',
                          style: quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF9500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pay Now Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedPaymentMethod == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select a payment method',
                                style: quicksand(fontSize: 14),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _processPayment();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _selectedPaymentMethod == 'cash' ? 'Confirm Booking' : 'Pay Now',
                            style: quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFFFF9500),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Processing your booking...',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: quicksand(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, Color color, String value) {
    final bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: PhosphorIcon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: quicksand(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      
      // Convert date to API format
      final dateParts = widget.selectedDate.split(' ');
      String apiDate = '';
      if (dateParts.length >= 3) {
        final monthMap = {
          'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
          'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
          'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12',
        };
        final month = monthMap[dateParts[0]] ?? '01';
        final day = dateParts[1].replaceAll(',', '');
        final year = dateParts[2];
        apiDate = '$year-$month-${day.padLeft(2, '0')}';
      }

      // Prepare route data
      final routeData = {
        'from': widget.fromLocation,
        'to': widget.toLocation,
        'date': apiDate,
        'departureTime': widget.busService['departureTime'],
        'arrivalTime': widget.busService['arrivalTime'],
      };

      // Map payment method to API format
      String? apiPaymentMethod;
      if (_selectedPaymentMethod == 'cash') {
        apiPaymentMethod = 'Cash';
      } else if (_selectedPaymentMethod == 'mobile_money' || _selectedPaymentMethod == 'orange_money') {
        apiPaymentMethod = 'Wallet'; // Mobile money is treated as wallet
      }

      // Create booking
      final booking = await apiService.createBooking(
        busId: widget.busService['id'] as String,
        seats: widget.selectedSeats,
        passengers: widget.passengers,
        route: routeData,
        paymentMethod: apiPaymentMethod,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessing = false;
        });

        // Navigate to booking confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              bookingData: {
                'bookingId': booking.bookingId,
                'fromLocation': widget.fromLocation,
                'toLocation': widget.toLocation,
                'selectedDate': widget.selectedDate,
                'departureTime': widget.busService['departureTime'],
                'arrivalTime': widget.busService['arrivalTime'],
                'selectedSeats': widget.selectedSeats,
                'passengers': widget.passengers,
                'totalPrice': widget.totalPrice,
                'busService': widget.busService,
                'phoneNumber': widget.phoneNumber,
                'email': widget.email,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessing = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _errorMessage ?? 'Failed to process booking. Please try again.',
              style: quicksand(fontSize: 14),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
