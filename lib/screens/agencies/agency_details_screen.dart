import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../search/bus_search_results_screen.dart';

class AgencyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> agency;

  const AgencyDetailsScreen({super.key, required this.agency});

  @override
  State<AgencyDetailsScreen> createState() => _AgencyDetailsScreenState();
}

class _AgencyDetailsScreenState extends State<AgencyDetailsScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Reviews

  // Sample reviews data
  final List<Map<String, dynamic>> _reviews = [
    {
      'id': '1',
      'userName': 'Marie N.',
      'rating': 5,
      'date': '2 days ago',
      'comment': 'Excellent service! Very comfortable buses and punctual. Highly recommend.',
      'route': 'Yaoundé → Douala',
    },
    {
      'id': '2',
      'userName': 'Jean P.',
      'rating': 4,
      'date': '1 week ago',
      'comment': 'Good experience overall. Buses are clean and staff is friendly.',
      'route': 'Douala → Bafoussam',
    },
    {
      'id': '3',
      'userName': 'Sarah T.',
      'rating': 5,
      'date': '2 weeks ago',
      'comment': 'Best bus service in Cameroon! Wi-Fi works well and seats are very comfortable.',
      'route': 'Yaoundé → Garoua',
    },
    {
      'id': '4',
      'userName': 'Paul K.',
      'rating': 4,
      'date': '3 weeks ago',
      'comment': 'Reliable and affordable. Would book again.',
      'route': 'Douala → Maroua',
    },
    {
      'id': '5',
      'userName': 'Amina D.',
      'rating': 3,
      'date': '1 month ago',
      'comment': 'Decent service but could improve on punctuality.',
      'route': 'Yaoundé → Ngaoundéré',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Sample location data (would come from agency data)
    final String address = 'Ndogsimbi, Douala, Cameroon';
    final String phone = '+237 677 123 456';
    final String email = 'info@${widget.agency['name'].toString().toLowerCase().replaceAll(' ', '')}.cm';
    final String workingHours = 'Daily: 5:00 AM - 10:00 PM';

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
          widget.agency['name'] as String,
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
            // Agency Header Card
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
              child: Row(
                children: [
                  // Agency Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget.agency['logo'].toString().contains('placeholder')
                          ? Center(
                              child: Text(
                                (widget.agency['name'] as String)
                                    .split(' ')
                                    .map((w) => w[0])
                                    .take(2)
                                    .join(),
                                style: quicksand(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF9500),
                                ),
                              ),
                            )
                          : Image.network(
                              widget.agency['logo'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  (widget.agency['name'] as String)
                                      .split(' ')
                                      .map((w) => w[0])
                                      .take(2)
                                      .join(),
                                  style: quicksand(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF9500),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.agency['name'] as String,
                          style: quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.agency['rating'].toString(),
                              style: quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.agency['reviews']} reviews)',
                              style: quicksand(
                                fontSize: 14,
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

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Overview', 0),
                  ),
                  Expanded(
                    child: _buildTabButton('Reviews', 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Content
            _selectedTab == 0 ? _buildOverviewTab(address, phone, email, workingHours) : _buildReviewsTab(),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusSearchResultsScreen(
                      fromLocation: 'Yaoundé',
                      toLocation: 'Douala',
                      selectedDate: 'Mar 15, 2024',
                      agencyFilter: widget.agency['name'] as String,
                    ),
                  ),
                );
              },
              icon: PhosphorIcon(
                PhosphorIcons.ticket(),
                size: 20,
                color: Colors.white,
              ),
              label: Text(
                'Book with ${widget.agency['name']}',
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
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9500).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: quicksand(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFFFF9500) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(String address, String phone, String email, String workingHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Description Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About',
                style: quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.agency['description'] as String,
                style: quicksand(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Location & Contact Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.mapPin(),
                    size: 20,
                    color: const Color(0xFFFF9500),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Location & Contact',
                    style: quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Address
              _buildContactItem(
                PhosphorIcons.mapPin(),
                'Address',
                address,
              ),
              const Divider(height: 32),
              // Phone
              _buildContactItem(
                PhosphorIcons.phone(),
                'Phone',
                phone,
              ),
              const Divider(height: 32),
              // Email
              _buildContactItem(
                PhosphorIcons.envelope(),
                'Email',
                email,
              ),
              const Divider(height: 32),
              // Working Hours
              _buildContactItem(
                PhosphorIcons.clock(),
                'Working Hours',
                workingHours,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stats Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Routes',
                  widget.agency['routes'].toString(),
                  PhosphorIcons.mapPin(),
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(
                child: _buildStatItem(
                  'Rating',
                  widget.agency['rating'].toString(),
                  PhosphorIcons.star(),
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(
                child: _buildStatItem(
                  'Reviews',
                  widget.agency['reviews'].toString(),
                  PhosphorIcons.chatCircle(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Amenities Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amenities',
                style: quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: (widget.agency['amenities'] as List<String>).map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF9500).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          _getAmenityIcon(amenity),
                          size: 18,
                          color: const Color(0xFFFF9500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          amenity,
                          style: quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF9500),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Price Range Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
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
                    'Price Range',
                    style: quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.agency['priceRange'] as String,
                style: quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF9500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        // Review Summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    widget.agency['rating'].toString(),
                    style: quicksand(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.agency['rating'].round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 20,
                        color: Colors.amber,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.agency['reviews']} reviews',
                    style: quicksand(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 80, color: Colors.grey.shade200),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingBar(5, 80),
                      const SizedBox(height: 8),
                      _buildRatingBar(4, 15),
                      const SizedBox(height: 8),
                      _buildRatingBar(3, 4),
                      const SizedBox(height: 8),
                      _buildRatingBar(2, 1),
                      const SizedBox(height: 8),
                      _buildRatingBar(1, 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Reviews List
        ..._reviews.map((review) => Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // User Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (review['userName'] as String)[0],
                            style: quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                              review['userName'] as String,
                              style: quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < review['rating']
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 14,
                                    color: Colors.amber,
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  review['date'] as String,
                                  style: quicksand(
                                    fontSize: 12,
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
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      review['route'] as String,
                      style: quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    review['comment'] as String,
                    style: quicksand(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9500).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: PhosphorIcon(
            icon,
            size: 18,
            color: const Color(0xFFFF9500),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: quicksand(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        PhosphorIcon(
          icon,
          size: 24,
          color: const Color(0xFFFF9500),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildRatingBar(int stars, int percentage) {
    return Row(
      children: [
        Text(
          '$stars',
          style: quicksand(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wi-fi':
        return PhosphorIcons.wifiHigh();
      case 'ac':
        return PhosphorIcons.wind();
      case 'charging':
        return PhosphorIcons.batteryCharging();
      case 'entertainment':
        return PhosphorIcons.monitor();
      case 'vip':
        return PhosphorIcons.crown();
      case 'food':
        return PhosphorIcons.forkKnife();
      default:
        return PhosphorIcons.check();
    }
  }
}
