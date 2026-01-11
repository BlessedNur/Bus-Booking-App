import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';
import '../../models/booking_model.dart';
import 'passenger_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> busService;
  final String fromLocation;
  final String toLocation;
  final String selectedDate;

  const SeatSelectionScreen({
    super.key,
    required this.busService,
    required this.fromLocation,
    required this.toLocation,
    required this.selectedDate,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  String _selectedDeck = 'LOWER'; // 'LOWER' or 'UPPER'
  Set<String> _selectedSeats = {}; // Track selected seats by seat number (e.g., "1", "2A", "12B")
  Set<String> _bookedSeats = {}; // Real booked seats from API
  List<SeatModel> _allSeats = []; // All seats from API
  bool _isLoadingSeats = true;
  late String _selectedDate;
  int _totalSeats = 0;
  int _availableSeats = 0;
  int _bookedSeatsCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _totalSeats = widget.busService['totalSeats'] ?? 50;
    // Initialize with the available seats from the bus data
    _availableSeats = widget.busService['seatsLeft'] ?? _totalSeats;
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    setState(() {
      _isLoadingSeats = true;
    });

    // Get busId outside try block so it's available in catch block
    final busId = widget.busService['id'] as String? ?? widget.busService['_id'] as String? ?? '';

    try {
      final apiService = ApiService();
      
      if (busId.isEmpty) {
        throw Exception('Bus ID is missing');
      }
      
      // Convert date to API format
      final dateParts = _selectedDate.split(' ');
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

      final seats = await apiService.getBusSeats(busId: busId, date: apiDate);
      
      if (mounted) {
        setState(() {
          _allSeats = seats;
          // Mark seats as booked if they are booked OR not available
          _bookedSeats = seats.where((s) => s.isBooked || !s.isAvailable).map((s) => s.seatNumber).toSet();
          _bookedSeatsCount = _bookedSeats.length;
          
          // Debug: Print booked seats to console
          print('🔴 Booked seats found: ${_bookedSeats.length}');
          print('🔴 Booked seat numbers: ${_bookedSeats.toList()}');
          print('🔴 Total seats: ${seats.length}');
          for (var seat in seats) {
            if (seat.isBooked || !seat.isAvailable) {
              print('🔴 Seat ${seat.seatNumber}: isBooked=${seat.isBooked}, isAvailable=${seat.isAvailable}');
            }
          }
          
          // Calculate available seats: total - booked - selected
          // Use the actual available seats count from the bus data if available
          final busAvailableSeats = widget.busService['seatsLeft'] as int?;
          if (busAvailableSeats != null && busAvailableSeats >= 0) {
            // Use the bus's available seats count, subtracting selected seats
            _availableSeats = busAvailableSeats - _selectedSeats.length;
          } else {
            // Fallback: calculate from total - booked - selected
            _availableSeats = _totalSeats - _bookedSeatsCount - _selectedSeats.length;
          }
          
          // Ensure available seats doesn't go below 0
          if (_availableSeats < 0) {
            _availableSeats = 0;
          }
          
          _isLoadingSeats = false;
        });
      }
    } catch (e) {
      // If API fails, create default seats based on totalSeats
      if (mounted) {
        setState(() {
          // Generate default seat list if API fails
          _allSeats = List.generate(_totalSeats, (index) {
            final seatNum = (index + 1).toString().padLeft(2, '0');
            return SeatModel(
              id: seatNum,
              busId: busId.isEmpty ? 'default' : busId,
              seatNumber: seatNum,
              isAvailable: true,
              isBooked: false,
            );
          });
          _bookedSeats = {};
          _bookedSeatsCount = 0;
          // Use the initial available seats from bus data, or calculate from total
          _availableSeats = widget.busService['seatsLeft'] ?? (_totalSeats - _selectedSeats.length);
          _isLoadingSeats = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF9500),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = '${_getMonthName(picked.month)} ${picked.day}, ${picked.year}';
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _toggleSeat(String seatNumber) {
    setState(() {
      if (_selectedSeats.contains(seatNumber)) {
        _selectedSeats.remove(seatNumber);
      } else {
        _selectedSeats.add(seatNumber);
      }
      // Update available seats count
      // Use the bus's available seats count if available, otherwise calculate
      final busAvailableSeats = widget.busService['seatsLeft'] as int?;
      if (busAvailableSeats != null && busAvailableSeats >= 0) {
        _availableSeats = busAvailableSeats - _selectedSeats.length;
      } else {
        _availableSeats = _totalSeats - _bookedSeatsCount - _selectedSeats.length;
      }
      // Ensure available seats doesn't go below 0
      if (_availableSeats < 0) {
        _availableSeats = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Choose Your Seat',
          style: quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.bell(),
              size: 24,
              color: Colors.black87,
            ),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Route Card (Red)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Logo (white/inverted) at the top
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/images/BONBLOGO.png',
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'B-ON-B',
                          style: quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Route display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.fromLocation,
                        style: quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      PhosphorIcon(
                        PhosphorIcons.arrowsLeftRight(),
                        size: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.toLocation,
                        style: quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Date pill (ghost/outlined variant)
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Open date picker
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      widget.selectedDate,
                      style: quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bus Details Card
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.busService['agency'] as String,
                          style: quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (widget.busService['isVIP'] ?? false)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
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
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.busService['type'] as String,
                    style: quicksand(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.busService['departureTime']} — ${widget.busService['arrivalTime']}',
                        style: quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.busService['duration'] as String,
                        style: quicksand(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_availableSeats Seats left',
                        style: quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _availableSeats <= 5 
                              ? Colors.red 
                              : Colors.green,
                        ),
                      ),
                      Row(
                        children: _buildAmenityIcons(widget.busService['amenities'] as List<String>),
                      ),
                      Text(
                        '${widget.busService['price']} FCFA',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF9500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Seat Selection Card
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
                  // Deck Selection Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildDeckButton('LOWER', _selectedDeck == 'LOWER'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDeckButton('UPPER', _selectedDeck == 'UPPER'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Seat Layout
                  _isLoadingSeats
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF9500),
                            ),
                          ),
                        )
                      : _buildSeatLayout(),
                  
                  const SizedBox(height: 20),
                  
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.grey.shade300, 'Available'),
                      const SizedBox(width: 20),
                      _buildLegendItem(Colors.red.shade300, 'Booked'),
                      const SizedBox(width: 20),
                      _buildLegendItem(const Color(0xFFFF9500), 'Your Seat'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Continue Button
            if (_selectedSeats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PassengerDetailsScreen(
                            busService: widget.busService,
                            fromLocation: widget.fromLocation,
                            toLocation: widget.toLocation,
                            selectedDate: _selectedDate,
                            selectedSeats: _selectedSeats.toList()..sort((a, b) {
                              // Sort numerically if both are numbers, otherwise alphabetically
                              final aNum = int.tryParse(a);
                              final bNum = int.tryParse(b);
                              if (aNum != null && bNum != null) {
                                return aNum.compareTo(bNum);
                              }
                              return a.compareTo(b);
                            }),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue (${_selectedSeats.length} ${_selectedSeats.length == 1 ? 'Seat' : 'Seats'})',
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
    );
  }

  Widget _buildDeckButton(String deck, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeck = deck;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFFF9500) 
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          deck,
          textAlign: TextAlign.center,
          style: quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? const Color(0xFFFF9500) 
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatLayout() {
    // Cameroonian bus layout: 2+2 configuration (most common)
    // Layout: Left side (A, B) | Aisle | Right side (C, D)
    
    // If no seats loaded, create default seats
    List<SeatModel> seatsToDisplay = _allSeats;
    if (seatsToDisplay.isEmpty) {
      // Generate default seats based on totalSeats
      seatsToDisplay = List.generate(_totalSeats, (index) {
        final seatNum = (index + 1).toString().padLeft(2, '0');
        return SeatModel(
          id: seatNum,
          busId: widget.busService['id'] as String? ?? '',
          seatNumber: seatNum,
          isAvailable: true,
          isBooked: false,
        );
      });
    }
    
    // Sort seats by numeric value (handle zero-padded numbers like "01", "02")
    final sortedSeats = List<SeatModel>.from(seatsToDisplay);
    sortedSeats.sort((a, b) {
      // Try to parse as integers (handles "01", "02", "1", "2", etc.)
      final aNum = int.tryParse(a.seatNumber);
      final bNum = int.tryParse(b.seatNumber);
      if (aNum != null && bNum != null) {
        return aNum.compareTo(bNum);
      }
      // If not numeric, sort alphabetically
      return a.seatNumber.compareTo(b.seatNumber);
    });
    
    final seatsPerRow = 4;
    final rows = (sortedSeats.length / seatsPerRow).ceil();
    
    return Column(
      children: [
        // Column labels
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['A', 'B'].map((label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(width: 32), // Aisle gap
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['C', 'D'].map((label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
        // Seat grid - 2+2 configuration (Cameroonian standard)
        ...List.generate(rows, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left side (A, B) - seats 1, 2 of row
                ...List.generate(2, (colIndex) {
                  final seatIndex = rowIndex * seatsPerRow + colIndex;
                  if (seatIndex >= sortedSeats.length) {
                    return const SizedBox(width: 36, height: 32);
                  }
                  final seat = sortedSeats[seatIndex];
                  // Use the seat's actual booked status, not just the set lookup
                  final isSeatBooked = seat.isBooked || !seat.isAvailable || _bookedSeats.contains(seat.seatNumber);
                  return _buildSeat(seat.seatNumber, colIndex < 1 ? 8 : 0, isSeatBooked: isSeatBooked);
                }),
                // Aisle gap
                const SizedBox(width: 32),
                // Right side (C, D) - seats 3, 4 of row
                ...List.generate(2, (colIndex) {
                  final seatIndex = rowIndex * seatsPerRow + colIndex + 2;
                  if (seatIndex >= sortedSeats.length) {
                    return const SizedBox(width: 36, height: 32);
                  }
                  final seat = sortedSeats[seatIndex];
                  // Use the seat's actual booked status, not just the set lookup
                  final isSeatBooked = seat.isBooked || !seat.isAvailable || _bookedSeats.contains(seat.seatNumber);
                  return _buildSeat(seat.seatNumber, 8, isSeatBooked: isSeatBooked);
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSeat(String seatNumber, double rightMargin, {bool? isSeatBooked}) {
    // Check if seat is booked - use provided status or check the set
    final normalizedSeatNumber = seatNumber.trim();
    final bool isBooked = isSeatBooked ?? _bookedSeats.contains(normalizedSeatNumber);
    final bool isSelected = _selectedSeats.contains(normalizedSeatNumber);
    
    Color seatColor;
    Color textColor;
    
    if (isBooked) {
      seatColor = Colors.red.shade300;
      textColor = Colors.white;
    } else if (isSelected) {
      seatColor = const Color(0xFFFF9500);
      textColor = Colors.white;
    } else {
      seatColor = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
    }
    
    return GestureDetector(
      onTap: isBooked ? null : () => _toggleSeat(seatNumber),
      child: Container(
        margin: EdgeInsets.only(right: rightMargin),
        width: 36,
        height: 32,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFFF9500) 
                : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
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
              color: color == Colors.grey.shade300 
                  ? Colors.grey.shade400 
                  : color,
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

  List<Widget> _buildAmenityIcons(List<String> amenities) {
    return amenities.map((amenity) {
      PhosphorIconData icon;
      switch (amenity) {
        case 'wifi':
          icon = PhosphorIcons.wifiHigh();
          break;
        case 'charging':
          icon = PhosphorIcons.batteryCharging();
          break;
        case 'luggage':
          icon = PhosphorIcons.suitcase();
          break;
        case 'ac':
          icon = PhosphorIcons.snowflake();
          break;
        case 'entertainment':
          icon = PhosphorIcons.monitorPlay();
          break;
        default:
          icon = PhosphorIcons.circle();
      }
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: PhosphorIcon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
      );
    }).toList();
  }
}
