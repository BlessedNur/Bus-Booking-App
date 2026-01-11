import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/font_helper.dart';
import '../../../models/user_model.dart';
import '../../../models/bus_model.dart';
import '../../../models/booking_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/location_picker.dart';
import '../../search/bus_search_results_screen.dart';
import '../../bookings/booking_details_screen.dart';
import '../../agencies/agencies_screen.dart';
import '../../agencies/agency_details_screen.dart';

class BusSearchSection extends StatefulWidget {
  final UserModel? user;
  const BusSearchSection({super.key, this.user});

  @override
  State<BusSearchSection> createState() => _BusSearchSectionState();
}

class _BusSearchSectionState extends State<BusSearchSection> {
  String _fromLocation = 'Yaoundé';
  String _toLocation = 'Douala';
  String _selectedTimeOfDay = 'Morning'; // Default selection
  String _selectedTab = 'Recent Search'; // Tab selection: 'Recent Search' or 'Recently Booked'
  
  // User data from API
  String get userName => widget.user?.name ?? 'User';
  String get userEmail => widget.user?.email ?? '';

  // Real data from API
  List<AgencyModel> _agencies = [];
  List<BookingModel> _recentBookings = [];
  List<Map<String, dynamic>> _recentSearches = [];
  bool _isLoadingAgencies = true;
  bool _isLoadingBookings = true;

  final List<Map<String, dynamic>> _timeOfDayOptions = [
    {'label': 'Morning', 'time': '6:00 AM - 12:00 PM', 'icon': PhosphorIcons.sun()},
    {'label': 'Afternoon', 'time': '12:00 PM - 6:00 PM', 'icon': PhosphorIcons.sunHorizon()},
    {'label': 'Evening', 'time': '6:00 PM - 11:00 PM', 'icon': PhosphorIcons.moon()},
  ];

  @override
  void initState() {
    super.initState();
    _loadAgencies();
    _loadRecentBookings();
    _loadRecentSearches();
  }

  Future<void> _loadAgencies() async {
    try {
      final apiService = ApiService();
      final agencies = await apiService.getAgencies();
      if (mounted) {
        setState(() {
          _agencies = agencies.take(6).toList(); // Show top 6 agencies
          _isLoadingAgencies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAgencies = false;
        });
      }
    }
  }

  Future<void> _loadRecentBookings() async {
    try {
      final apiService = ApiService();
      final bookings = await apiService.getMyBookings();
      if (mounted) {
        setState(() {
          _recentBookings = bookings
              .where((b) => b.status == 'Confirmed')
              .take(1)
              .toList(); // Show most recent confirmed booking
          _isLoadingBookings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBookings = false;
        });
      }
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searchesJson = prefs.getStringList('recent_searches') ?? [];
      if (mounted) {
        setState(() {
          _recentSearches = searchesJson
              .map((json) {
                try {
                  // Simple JSON parsing for stored searches
                  final parts = json.split('|');
                  if (parts.length >= 3) {
                    return {
                      'from': parts[0],
                      'to': parts[1],
                      'date': parts[2],
                      'passengers': parts.length > 3 ? parts[3] : '1',
                    };
                  }
                } catch (e) {
                  // Ignore errors
                }
                return null;
              })
              .whereType<Map<String, dynamic>>()
              .take(1)
              .toList();
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _saveSearch(String from, String to, String date, String passengers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recent_searches') ?? [];
      final searchString = '$from|$to|$date|$passengers';
      
      // Remove if already exists
      searches.remove(searchString);
      // Add to beginning
      searches.insert(0, searchString);
      // Keep only last 10
      if (searches.length > 10) {
        searches.removeRange(10, searches.length);
      }
      
      await prefs.setStringList('recent_searches', searches);
      _loadRecentSearches();
    } catch (e) {
      // Ignore errors
    }
  }

  void _swapLocations() {
    setState(() {
      final temp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = temp;
    });
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
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _truncateEmail(String email) {
    if (email.length <= 20) return email;
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 8) {
      return '$username@${domain.substring(0, domain.length > 8 ? 8 : domain.length)}...';
    }
    return '${username.substring(0, 8)}...@${domain.substring(0, domain.length > 8 ? 8 : domain.length)}...';
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            // Logo on the left
            Image.asset(
              'assets/images/BONBLOGO.png',
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'B-ON-B',
                  style: quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Dark text on white background
                  ),
                );
              },
            ),
            const Spacer(),
            // Bell icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: PhosphorIcon(
                  PhosphorIcons.bell(),
                  size: 24.0,
                  color: Colors.black87,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            // Round profile with user info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // User name and email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _truncateEmail(userEmail),
                        style: quicksand(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          // Orange background that scrolls with content
          Transform.translate(
            offset: const Offset(0, -300), // Offset upward to extend behind header area
            child: Container(
              height: 550, // Height to cover header and search area
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFF), // Orange background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          // Content column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header that scrolls with content
              SafeArea(
                bottom: false,
                child: _buildHeader(),
              ),
          // Time of Day Section and Search Form - Offset upward
          Transform.translate(
            offset: const Offset(0, 0), // Adjusted offset - Move up by 60px
            child: Column(
              children: [
                // Time of Day Section - Above search box
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _timeOfDayOptions.map((option) {
                        final isSelected = _selectedTimeOfDay == option['label'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTimeOfDay = option['label'] as String;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFF9500) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(300),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFF9500) : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PhosphorIcon(
                                    option['icon'] as PhosphorIconData,
                                    size: 20,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        option['label'] as String,
                                        style: quicksand(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        option['time'] as String,
                                        style: quicksand(
                                          fontSize: 10,
                                          color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                        ),
                      ),
                    ),
                    // Left fade gradient
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 30,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white, // White background color
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Right fade gradient
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 30,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Colors.white, // White background color
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Form Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // Reduced border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Reduced shadow
                      blurRadius: 10, // Reduced blur
                      offset: const Offset(0, 2), // Reduced offset
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Time badge above From field
                        Padding(
                          padding: const EdgeInsets.only(right: 56, bottom: 8), // Space for swap button
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9500),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PhosphorIcon(
                                    _timeOfDayOptions.firstWhere(
                                      (option) => option['label'] == _selectedTimeOfDay,
                                    )['icon'] as PhosphorIconData,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedTimeOfDay,
                                    style: quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // From Field - Full Width (touches swap button on right)
                        Padding(
                          padding: const EdgeInsets.only(right: 56), // Space for swap button
                          child: _buildLocationField('From', _fromLocation, () {
                            _selectLocation(true); // Open location picker
                          }),
                        ),
                        const SizedBox(height: 6), // Very little space between From and To

                        // To Field - Full Width (touches swap button on right)
                        Padding(
                          padding: const EdgeInsets.only(right: 56), // Space for swap button
                          child: _buildLocationField('To', _toLocation, () {
                            _selectLocation(false); // Open location picker
                          }),
                        ),
                        const SizedBox(height: 16),

                        // Search Button and View All Agencies - Flexed

                        // Search Button and View All Agencies - Flexed
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 50, // Reduced height
                                child: ElevatedButton(
                                  onPressed: () {
                                    final today = DateTime.now();
                                    final dateString = '${_getMonthName(today.month)} ${today.day}, ${today.year}';
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BusSearchResultsScreen(
                                          fromLocation: _fromLocation,
                                          toLocation: _toLocation,
                                          selectedDate: dateString,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF9500),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIcons.magnifyingGlass(),
                                        size: 18, // Reduced icon size
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Search',
                                        style: quicksand(
                                          fontSize: 13, // Reduced font size
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ).copyWith(letterSpacing: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10), // Reduced spacing
                            Expanded(
                              flex: 2,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Navigate to all agencies
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  '',
                                  style: quicksand(
                                    fontSize: 12, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF9500),
                                    textDecoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFFFF9500),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // App logo at bottom right of search box
                    Positioned(
                      bottom: -80,
                      right: -80,
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/images/BONBLOGO.png',
                          height: 200,
                          width: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    // Swap Button - Absolutely positioned on the right
                    // ADJUST POSITION: Change 'right' (move left/right) and 'top' (move up/down) values
                    // ADJUST SIZE: Change 'width' and 'height' in Container below
                    Positioned(
                      right: 0, // ADJUST THIS: Move left (positive) or right (negative) - e.g., right: 8 moves it left
                      top: 45, // ADJUST THIS: Move up (decrease) or down (increase) - e.g., top: 40 moves it down
                      child: GestureDetector(
                        onTap: _swapLocations,
                        child: Container(
                          width: 40, // ADJUST THIS: Change button size (e.g., 36, 40, 44, 48)
                          height: 40, // ADJUST THIS: Change button size (e.g., 36, 40, 44, 48)
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF9500),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.swap_vert_rounded,
                            color: const Color(0xFFFF9500),
                            size: 22, // ADJUST THIS: Change icon size inside button
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ], // Closes Column children (time selector and search form)
          ), // Closes Column (time selector and search form)
          ), // Closes Transform.translate for time selector and search form
          // Content below the search box - grey background area
          const SizedBox(height: 24), // Spacing after search box
          Container(
            color: Colors.grey.shade50, // Grey background for content below orange area
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    // Tab Switcher for Recent Search / Recently Booked
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque, // Make entire area tappable
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 'Recent Search';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      'Recent Search',
                                      textAlign: TextAlign.center,
                                      style: quicksand(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedTab == 'Recent Search'
                                            ? const Color(0xFFFF9500)
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque, // Make entire area tappable
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 'Recently Booked';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      'Recently Booked',
                                      textAlign: TextAlign.center,
                                      style: quicksand(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedTab == 'Recently Booked'
                                            ? const Color(0xFFFF9500)
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Sliding underline indicator
                          Positioned(
                            bottom: 0,
                            left: _selectedTab == 'Recent Search' 
                                ? 0 
                                : MediaQuery.of(context).size.width / 2 - 24, // Slide to second tab
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutCubic,
                              width: MediaQuery.of(context).size.width / 2 - 24, // Half width minus padding
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9500),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                // Content based on selected tab
                _selectedTab == 'Recent Search'
                    ? _buildRecentSearchCard()
                    : _buildRecentlyBookedCard(),
                const SizedBox(height: 24),

                // Available Agencies Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Agencies',
                      style: quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AgenciesScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View All Agencies',
                        style: quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF9500),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _agencies.length,
                    itemBuilder: (context, index) {
                      final agency = _agencies[index];
                      // Calculate width for mobile - wider cards
                      // Make cards wider: 2 cards + peek, but with larger width
                      final screenWidth = MediaQuery.of(context).size.width;
                      final cardWidth = (screenWidth - 48 - 16) / 1.8; // Wider cards for mobile - was 2.2
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgencyDetailsScreen(
                                  agency: {
                                    'id': agency.id,
                                    'name': agency.name,
                                    'logo': agency.logo,
                                    'description': agency.description ?? '',
                                    'rating': agency.rating,
                                    'amenities': agency.amenities,
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: cardWidth,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12), // Slightly larger radius
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Agency name
                                      Text(
                                        agency.name,
                                        style: quicksand(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      // Bottom section with rating and departures
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Rating
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 14,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                agency.rating.toStringAsFixed(1),
                                                style: quicksand(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          // Description or routes
                                          Text(
                                            agency.description ?? 'Multiple Routes',
                                            style: quicksand(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          // Amenities count
                                          Text(
                                            '${agency.amenities.length} amenities',
                                            style: quicksand(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFFF9500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // App logo at bottom right
                                Positioned(
                                  bottom: -40,
                                  right: -40,
                                  child: Opacity(
                                    opacity: 0.25,
                                    child: Image.asset(
                                      'assets/images/BONBLOGO.png',
                                      height: 120,
                                      width: 120,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24), // Bottom padding
              ],
            ), // Closes Column (line 497)
          ), // Closes Container (grey background) (line 494)
        ], // Closes Column children (content column)
      ), // Closes Column (content column)
        ], // Closes Stack children
      ), // Closes Stack
    ); // Closes SingleChildScrollView and ends return
  }


  Widget _buildLocationField(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Full width
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10), // Reduced border radius
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: const Color(0xFFFF9500),
              size: 18, // Reduced icon size
            ),
            const SizedBox(width: 8), // Reduced spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: quicksand(
                      fontSize: 10, // Reduced font size
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  Text(
                    value,
                    style: quicksand(
                      fontSize: 14, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 18, // Reduced icon size
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyBookedCard() {
    if (_isLoadingBookings) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF9500),
          ),
        ),
      );
    }

    if (_recentBookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No recent bookings',
            style: quicksand(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    final booking = _recentBookings.first;
    final date = booking.route.date;
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    final departureTime = booking.route.departureTime; // Already a string
    final arrivalTime = booking.route.arrivalTime; // Already a string
    
    return GestureDetector(
      onTap: () {
        final bookingMap = {
          'id': booking.id,
          'bookingId': booking.bookingId,
          'date': dateStr,
          'from': booking.route.from,
          'to': booking.route.to,
          'departureTime': departureTime,
          'arrivalTime': arrivalTime,
          'agency': booking.bus?.agency?.name ?? 'Unknown',
          'seats': '${booking.passengers.length} ${booking.passengers.length == 1 ? 'Seat' : 'Seats'}',
          'status': booking.status,
          'statusColor': Colors.green,
          'isVIP': booking.bus?.isVIP ?? false,
          'seatNumbers': booking.passengers.map((p) => p.seatNumber).toList(),
          'totalPrice': booking.totalPrice,
          'passengers': booking.passengers.map((p) => {
            'name': p.name,
            'seat': p.seatNumber,
            'age': p.age,
          }).toList(),
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(booking: bookingMap, bookingModel: booking),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.ticket(),
                      size: 16,
                      color: const Color(0xFFFF9500),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF9500),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status,
                    style: quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
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
                      departureTime,
                      style: quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.route.from,
                      style: quicksand(
                        fontSize: 12,
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
                        CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: DashedLinePainter(),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9500),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            size: 18,
                            color: Colors.white,
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
                      arrivalTime,
                      style: quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.route.to,
                      style: quicksand(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.bus?.agency?.name ?? 'Unknown Agency',
                  style: quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${booking.passengers.length} ${booking.passengers.length == 1 ? 'Seat' : 'Seats'}',
                  style: quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  Widget _buildRecentSearchCard() {
    if (_recentSearches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No recent searches',
            style: quicksand(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    final search = _recentSearches.first;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusSearchResultsScreen(
              fromLocation: search['from'] ?? 'Yaoundé',
              toLocation: search['to'] ?? 'Douala',
              selectedDate: search['date'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.calendar(),
                      size: 16,
                      color: const Color(0xFFFF9500),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      search['date'] ?? '',
                      style: quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF9500),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.user(),
                      size: 16,
                      color: const Color(0xFFFF9500),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${search['passengers'] ?? '1'} Seat${(search['passengers'] ?? '1') != '1' ? 's' : ''}',
                      style: quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF9500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Route visualization
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    search['from'] ?? 'Yaoundé',
                    style: quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: DashedLinePainter(),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF9500),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    search['to'] ?? 'Douala',
                    style: quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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
