import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../../models/booking_model.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;
  final BookingModel? bookingModel;

  const BookingDetailsScreen({super.key, required this.booking, this.bookingModel});

  @override
  Widget build(BuildContext context) {
    final bool isVIP = booking['isVIP'] ?? false;
    final List<String> seatNumbers = booking['seatNumbers'] ?? ['A1', 'A2'];
    final double totalPrice = booking['totalPrice'] ?? 15000.0;
    
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
          'Booking Details',
          style: quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card with Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking #${booking['id']}',
                            style: quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking['date'] as String,
                            style: quicksand(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (booking['statusColor'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking['status'] as String,
                          style: quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: booking['statusColor'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isVIP) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.crown(),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'VIP RIDE',
                            style: quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Route Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['departureTime'] as String,
                              style: quicksand(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              booking['from'] as String,
                              style: quicksand(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Dashed line
                              CustomPaint(
                                size: const Size(double.infinity, 1),
                                painter: DashedLinePainter(),
                              ),
                              // Bus icon in the middle (matching home screen style)
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF9500),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.network(
                                      'https://cdn.iconscout.com/icon/premium/png-512-thumb/bus-icon-svg-download-png-12537507.png?f=webp&w=256',
                                      width: 22,
                                      height: 22,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.directions_bus,
                                          size: 20,
                                          color: Colors.white,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              booking['arrivalTime'] as String,
                              style: quicksand(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              booking['to'] as String,
                              style: quicksand(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        PhosphorIcons.bus(),
                        'Agency',
                        booking['agency'] as String,
                      ),
                      _buildInfoItem(
                        PhosphorIcons.clock(),
                        'Duration',
                        '1h 30m',
                      ),
                      _buildInfoItem(
                        PhosphorIcons.calendar(),
                        'Date',
                        booking['date'] as String,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Seat Preview Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.seat(),
                        size: 20,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selected Seats',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Seat Preview Grid
                  _buildSeatPreview(seatNumbers),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Passenger Details Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.users(),
                        size: 20,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Passengers',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(bookingModel?.passengers.isNotEmpty == true
                      ? bookingModel!.passengers.map((p) => {
                          'name': p.name,
                          'seat': p.seatNumber,
                          'age': p.age,
                        }).toList()
                      : (booking['passengers'] as List<Map<String, dynamic>>? ?? [
                          if (seatNumbers.isNotEmpty) {'name': 'Passenger', 'seat': seatNumbers[0], 'age': 0},
                        ])).map((passenger) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (passenger['name'] as String)[0].toUpperCase(),
                              style: quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF9500),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                passenger['name'] as String,
                                style: quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Seat ${passenger['seat']} • Age ${passenger['age']}',
                                style: quicksand(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            passenger['seat'] as String,
                            style: quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF9500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.currencyCircleDollar(),
                        size: 20,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Summary',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPriceRow('Ticket Price', totalPrice / seatNumbers.length, seatNumbers.length),
                  const SizedBox(height: 8),
                  _buildPriceRow('Service Fee', 500.0, 1),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${(totalPrice + 500).toStringAsFixed(0)} FCFA',
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
            const SizedBox(height: 24),
            
            // Action Buttons
            if (booking['status'] == 'Confirmed')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Show QR code/ticket
                        },
                        icon: PhosphorIcon(
                          PhosphorIcons.qrCode(),
                          size: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          'View Ticket',
                          style: quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelBookingDialog(context),
                        icon: PhosphorIcon(
                          PhosphorIcons.x(),
                          size: 20,
                          color: Colors.red,
                        ),
                        label: Text(
                          'Cancel Booking',
                          style: quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(PhosphorIconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          PhosphorIcon(
            icon,
            size: 24,
            color: const Color(0xFFFF9500),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: quicksand(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSeatPreview(List<String> seatNumbers) {
    // 70-seater bus layout: 2-2 configuration (2 seats left, aisle, 2 seats right)
    // 17 rows of 4 seats = 68 seats, plus 2 extra seats
    const int totalSeats = 70;
    const int seatsPerRow = 4; // 2-2 configuration
    const int rows = 17;
    
    // Convert seat numbers to integers for comparison
    final selectedSeats = seatNumbers.map((s) => int.tryParse(s) ?? 0).where((n) => n > 0 && n <= totalSeats).toSet();
    
    return Column(
      children: [
        // Seat map visualization
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Driver area indicator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.airline_seat_recline_normal, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      'Driver',
                      style: quicksand(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Seat grid - 70 seats in 2-2 configuration
              // Each row has 2 seats left, aisle gap, 2 seats right
              SizedBox(
                height: 340, // Fixed height for scrollable area
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...List.generate(rows, (rowIndex) {
                        final startSeat = rowIndex * seatsPerRow + 1;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left side seats (2 seats)
                              ...List.generate(2, (colIndex) {
                                final seatNum = startSeat + colIndex;
                                if (seatNum > totalSeats) return const SizedBox.shrink();
                                final isSelected = selectedSeats.contains(seatNum);
                                
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  width: 36,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? const Color(0xFFFF9500) 
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFFFF9500) 
                                          : Colors.grey.shade400,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      seatNum.toString(),
                                      style: quicksand(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              // Aisle gap
                              const SizedBox(width: 16),
                              // Right side seats (2 seats)
                              ...List.generate(2, (colIndex) {
                                final seatNum = startSeat + colIndex + 2;
                                if (seatNum > totalSeats) return const SizedBox.shrink();
                                final isSelected = selectedSeats.contains(seatNum);
                                
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  width: 36,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? const Color(0xFFFF9500) 
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFFFF9500) 
                                          : Colors.grey.shade400,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      seatNum.toString(),
                                      style: quicksand(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                      // Last 2 seats if needed (seats 69-70)
                      if (totalSeats > rows * seatsPerRow)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...List.generate(2, (colIndex) {
                                final seatNum = rows * seatsPerRow + colIndex + 1;
                                if (seatNum > totalSeats) return const SizedBox.shrink();
                                final isSelected = selectedSeats.contains(seatNum);
                                
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  width: 36,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? const Color(0xFFFF9500) 
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFFFF9500) 
                                          : Colors.grey.shade400,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      seatNum.toString(),
                                      style: quicksand(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.grey.shade300, 'Available'),
            const SizedBox(width: 16),
            _buildLegendItem(const Color(0xFFFF9500), 'Your Seats'),
          ],
        ),
        const SizedBox(height: 12),
        // Selected seats list
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: seatNumbers.map((seat) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF9500),
                width: 1.5,
              ),
            ),
            child: Text(
              seat,
              style: quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF9500),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color == Colors.grey.shade300 ? Colors.grey.shade400 : color,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: quicksand(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double price, int quantity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          quantity > 1 ? '$label x$quantity' : label,
          style: quicksand(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          '${(price * quantity).toStringAsFixed(0)} FCFA',
          style: quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showCancelBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancel Booking',
            style: quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
            style: quicksand(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Keep Booking',
                style: quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                // TODO: Handle actual cancellation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking cancelled successfully',
                      style: quicksand(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); // Go back to bookings list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel Booking',
                style: quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2;

    const dashWidth = 5;
    const dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
