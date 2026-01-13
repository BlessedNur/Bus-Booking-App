import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../../widgets/location_picker.dart';
import '../../models/bus_model.dart';
import '../../services/api_service.dart';
import '../booking/seat_selection_screen.dart';

class BusSearchResultsScreen extends StatefulWidget {
  final String fromLocation;
  final String toLocation;
  final String selectedDate;
  final String? agencyFilter; // Optional agency filter

  const BusSearchResultsScreen({
    super.key,
    required this.fromLocation,
    required this.toLocation,
    required this.selectedDate,
    this.agencyFilter,
  });

  @override
  State<BusSearchResultsScreen> createState() => _BusSearchResultsScreenState();
}

class _BusSearchResultsScreenState extends State<BusSearchResultsScreen> {
  String? _userLocation;
  late String _fromLocation;
  late String _toLocation;
  late String _selectedDate;
  
  List<BusModel> _busServices = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fromLocation = widget.fromLocation;
    _toLocation = widget.toLocation;
    // Use current date if no date provided or if date is old
    if (widget.selectedDate.isEmpty || widget.selectedDate.contains('2024')) {
      final today = DateTime.now();
      _selectedDate = '${_getMonthName(today.month)} ${today.day}, ${today.year}';
    } else {
      _selectedDate = widget.selectedDate;
    }
    _getUserLocation();
    _searchBuses();
  }

  Future<void> _searchBuses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Convert date string to API format (YYYY-MM-DD)
      final dateParts = _selectedDate.split(' ');
      if (dateParts.length >= 3) {
        final monthMap = {
          'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
          'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
          'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12',
        };
        final month = monthMap[dateParts[0]] ?? '01';
        final day = dateParts[1].replaceAll(',', '');
        final year = dateParts[2];
        final apiDate = '$year-$month-${day.padLeft(2, '0')}';
        
        final apiService = ApiService();
        final buses = await apiService.searchBuses(
          from: _fromLocation,
          to: _toLocation,
          date: apiDate,
        );

        if (mounted) {
          setState(() {
            _busServices = buses;
            _isLoading = false;
          });
        }
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
      _searchBuses(); // Refresh search with new date
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12;
    final hour12 = hour == 0 ? 12 : hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final ampm = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $ampm';
  }

  void _swapLocations() {
    setState(() {
      final temp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = temp;
    });
    _searchBuses(); // Refresh search with swapped locations
  }

  Future<void> _selectLocation(bool isFrom) async {
    final selectedLocation = await LocationPicker.show(
      context,
      initialLocation: isFrom ? _fromLocation : _toLocation,
      title: isFrom ? 'Select From Location' : 'Select To Location',
    );
    if (selectedLocation != null && mounted) {
      setState(() {
        if (isFrom) {
          _fromLocation = selectedLocation;
        } else {
          _toLocation = selectedLocation;
        }
      });
      _searchBuses(); // Refresh search with new location
    }
  }

  Future<void> _getUserLocation() async {
    // For now, use a mock location. In production, use geolocator package
    // For demo purposes, we'll use a sample location
    setState(() {
      _userLocation = 'Yaoundé, Cameroon'; // Default/mock location
    });
    
    // TODO: Uncomment when geolocator is added:
    // try {
    //   LocationPermission permission = await Geolocator.checkPermission();
    //   if (permission == LocationPermission.denied) {
    //     permission = await Geolocator.requestPermission();
    //   }
    //   if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    //     Position position = await Geolocator.getCurrentPosition();
    //     // Use reverse geocoding to get address
    //     setState(() {
    //       _userLocation = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
    //     });
    //   }
    // } catch (e) {
    //   setState(() {
    //     _userLocation = 'Location unavailable';
    //   });
    // }
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
          'Select Your Bus',
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
              PhosphorIcons.funnel(),
              size: 24,
              color: Colors.black87,
            ),
            onPressed: () {
              // TODO: Show filters
            },
          ),
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
      body: Column(
        children: [
          // Route Card (Red)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500), // Orange/Red background
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Yellow box with user location at top
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.mapPin(),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _userLocation ?? 'Loading...',
                            style: quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        GestureDetector(
                          onTap: () => _selectLocation(true),
                          child: Text(
                            _fromLocation,
                            style: quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _swapLocations,
                          child: PhosphorIcon(
                            PhosphorIcons.arrowsLeftRight(),
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _selectLocation(false),
                          child: Text(
                            _toLocation,
                            style: quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Date pill (ghost/outlined variant)
                    OutlinedButton(
                      onPressed: _selectDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        _selectedDate,
                        style: quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bus Services List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF9500),
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : _busServices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _busServices.length,
                            itemBuilder: (context, index) {
                              return _buildBusServiceCard(_busServices[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(
                PhosphorIcons.bus(),
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Buses Available',
              style: quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.agencyFilter != null
                  ? '${widget.agencyFilter} doesn\'t have any buses available for this route at the moment.'
                  : 'No buses are available for this route at the moment.',
              textAlign: TextAlign.center,
              style: quicksand(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: PhosphorIcon(
                PhosphorIcons.arrowLeft(),
                size: 20,
                color: Colors.white,
              ),
              label: Text(
                'Search Other Routes',
                style: quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.warning(),
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Buses',
              style: quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: quicksand(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _searchBuses,
              icon: PhosphorIcon(
                PhosphorIcons.arrowClockwise(),
                size: 20,
                color: Colors.white,
              ),
              label: Text(
                'Retry',
                style: quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusServiceCard(BusModel bus) {
    final bool isVIP = bus.isVIP;
    final int seatsLeft = bus.availableSeats;
    final bool isLowAvailability = seatsLeft <= 5;
    
    return GestureDetector(
      onTap: () {
        // Convert BusModel to Map format expected by SeatSelectionScreen
        final busServiceMap = {
          'id': bus.id,
          'agency': bus.agency?.name ?? 'Unknown Agency',
          'type': bus.type,
          'departureTime': _formatTime(bus.departureTime),
          'arrivalTime': _formatTime(bus.arrivalTime),
          'duration': '${bus.duration} Min',
          'price': bus.price.toInt(),
          'seatsLeft': bus.availableSeats,
          'isVIP': bus.isVIP,
          'amenities': bus.amenities,
          'totalSeats': bus.totalSeats,
          'busNumber': bus.busNumber,
          'vipPrice': bus.vipPrice.toInt(),
        };
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeatSelectionScreen(
              busService: busServiceMap,
              fromLocation: _fromLocation,
              toLocation: _toLocation,
              selectedDate: _selectedDate,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Header: Agency name and VIP badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    bus.agency?.name ?? 'Unknown Agency',
                    style: quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (isVIP)
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
            // Bus type
            Text(
              bus.type,
              style: quicksand(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            // Times and duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${_formatTime(bus.departureTime)} — ${_formatTime(bus.arrivalTime)}',
                  style: quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${bus.duration} Min',
                  style: quicksand(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom row: Seats left, Amenities, Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Seats left
                Text(
                  '$seatsLeft Seats left',
                  style: quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isLowAvailability ? Colors.red : Colors.green,
                  ),
                ),
                // Amenities icons
                Row(
                  children: _buildAmenityIcons(bus.amenities),
                ),
                // Price (no background)
                Text(
                  '${bus.price.toInt()} FCFA',
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
