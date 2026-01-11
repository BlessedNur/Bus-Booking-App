import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';
import '../../models/booking_model.dart';
import 'booking_details_screen.dart';
import '../search/bus_search_results_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTab = 'Upcoming'; // 'Upcoming', 'Past', 'Cancelled'

  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<BookingModel> get _upcomingBookings => _allBookings
      .where((b) => b.status == 'Confirmed' && 
                    b.route.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
      .toList();

  List<BookingModel> get _pastBookings => _allBookings
      .where((b) => b.status == 'Completed' || 
                    (b.status == 'Confirmed' && b.route.date.isBefore(DateTime.now())))
      .toList();

  List<BookingModel> get _cancelledBookings => _allBookings
      .where((b) => b.status == 'Cancelled')
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _selectedTab = 'Upcoming';
              break;
            case 1:
              _selectedTab = 'Past';
              break;
            case 2:
              _selectedTab = 'Cancelled';
              break;
          }
        });
      }
    });
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final bookings = await apiService.getMyBookings();
      if (mounted) {
        setState(() {
          _allBookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> get _currentBookings {
    switch (_selectedTab) {
      case 'Past':
        return _pastBookings;
      case 'Cancelled':
        return _cancelledBookings;
      default:
        return _upcomingBookings;
    }
  }

  Map<String, dynamic> _bookingToMap(BookingModel booking) {
    final date = booking.route.date;
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    
    Color statusColor;
    switch (booking.status) {
      case 'Confirmed':
        statusColor = Colors.green;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return {
      'id': booking.id,
      'bookingId': booking.bookingId,
      'date': dateStr,
      'from': booking.route.from,
      'to': booking.route.to,
      'departureTime': booking.route.departureTime,
      'arrivalTime': booking.route.arrivalTime,
      'agency': booking.bus?.agency?.name ?? 'Unknown Agency',
      'seats': '${booking.passengers.length} ${booking.passengers.length == 1 ? 'Seat' : 'Seats'}',
      'status': booking.status,
      'statusColor': statusColor,
      'isVIP': booking.bus?.isVIP ?? false,
      'seatNumbers': booking.passengers.map((p) => p.seatNumber).toList(),
      'totalPrice': booking.totalPrice,
      'passengers': booking.passengers.map((p) => {
        'name': p.name,
        'seat': p.seatNumber,
        'age': p.age,
      }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'My Bookings',
                        style: quicksand(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Search icon button
                    IconButton(
                      icon: PhosphorIcon(
                        PhosphorIcons.magnifyingGlass(),
                        size: 24,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        // TODO: Implement search
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Book New Ticket Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to bus search results screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusSearchResultsScreen(
                            fromLocation: 'Yaoundé',
                            toLocation: 'Douala',
                            selectedDate: 'Mar 15, 2024',
                          ),
                        ),
                      );
                    },
                    icon: PhosphorIcon(
                      PhosphorIcons.ticket(),
                      size: 22,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Book New Ticket',
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
              ],
            ),
          ),
          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF9500),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFFFF9500),
              indicatorWeight: 3,
              labelStyle: quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF9500),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading bookings',
                              style: quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: quicksand(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadBookings,
                              child: Text(
                                'Retry',
                                style: quicksand(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _currentBookings.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(24.0),
                            itemCount: _currentBookings.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildBookingCard(_bookingToMap(_currentBookings[index])),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String icon;
    
    switch (_selectedTab) {
      case 'Past':
        message = 'No past bookings';
        icon = 'history';
        break;
      case 'Cancelled':
        message = 'No cancelled bookings';
        icon = 'cancel';
        break;
      default:
        message = 'No upcoming bookings';
        icon = 'calendar';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(
            icon == 'history'
                ? PhosphorIcons.clockClockwise()
                : icon == 'cancel'
                    ? PhosphorIcons.xCircle()
                    : PhosphorIcons.calendar(),
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: quicksand(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your bookings will appear here',
            style: quicksand(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final bool isVIP = booking['isVIP'] ?? false;
    return GestureDetector(
      onTap: () {
        // Find the actual booking model
        final bookingModel = _allBookings.firstWhere(
          (b) => b.id == booking['id'] || b.bookingId == booking['bookingId'],
          orElse: () => _allBookings.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(booking: booking, bookingModel: bookingModel),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
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
            // Header: Booking ID, VIP Badge, and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.ticket(),
                        size: 18,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Booking #${booking['bookingId'] ?? booking['id']}',
                          style: quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isVIP) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.crown(),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'VIP',
                          style: quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (booking['statusColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking['status'] as String,
                    style: quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: booking['statusColor'] as Color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Date
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.calendar(),
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  booking['date'] as String,
                  style: quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF9500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Route visualization
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['departureTime'] as String,
                      style: quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['from'] as String,
                      style: quicksand(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
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
                          width: 32,
                          height: 32,
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
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.directions_bus,
                                    size: 18,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      booking['arrivalTime'] as String,
                      style: quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['to'] as String,
                      style: quicksand(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            // Footer: Agency and Seats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.bus(),
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking['agency'] as String,
                      style: quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.user(),
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking['seats'] as String,
                      style: quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF9500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Action buttons for upcoming bookings
            if (_selectedTab == 'Upcoming' && booking['status'] == 'Confirmed') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: View ticket
                      },
                      icon: PhosphorIcon(
                        PhosphorIcons.qrCode(),
                        size: 18,
                        color: const Color(0xFFFF9500),
                      ),
                      label: Text(
                        'View Details',
                        style: quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF9500),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF9500), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Cancel booking
                      },
                      icon: PhosphorIcon(
                        PhosphorIcons.x(),
                        size: 18,
                        color: Colors.red,
                      ),
                      label: Text(
                        'Cancel',
                        style: quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade300, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
