import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';
import '../search/bus_search_results_screen.dart';

class AgencyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> agency;

  const AgencyDetailsScreen({super.key, required this.agency});

  @override
  State<AgencyDetailsScreen> createState() => _AgencyDetailsScreenState();
}

class _AgencyDetailsScreenState extends State<AgencyDetailsScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Reviews
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;
  bool _canUserReview = false;
  bool _isCheckingCanReview = true;
  int _actualReviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _checkCanReview();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final apiService = ApiService();
      final agencyId = widget.agency['id'] as String;
      final reviews = await apiService.getAgencyReviews(agencyId);
      
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _actualReviewCount = reviews.length;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviews = [];
          _actualReviewCount = 0;
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _checkCanReview() async {
    setState(() {
      _isCheckingCanReview = true;
    });

    try {
      final apiService = ApiService();
      final agencyId = widget.agency['id'] as String;
      final canReview = await apiService.canUserReviewAgency(agencyId);
      
      if (mounted) {
        setState(() {
          _canUserReview = canReview;
          _isCheckingCanReview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _canUserReview = false;
          _isCheckingCanReview = false;
        });
      }
    }
  }

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
                              (widget.agency['rating'] ?? 0).toString(),
                              style: quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($_actualReviewCount reviews)',
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
                    builder: (context) {
                      final today = DateTime.now();
                      final dateString = '${_getMonthName(today.month)} ${today.day}, ${today.year}';
                      return BusSearchResultsScreen(
                        fromLocation: 'Yaoundé',
                        toLocation: 'Douala',
                        selectedDate: dateString,
                        agencyFilter: widget.agency['name'] as String,
                      );
                    },
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
                widget.agency['description'] as String? ?? 'No description available',
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
                  (widget.agency['routes'] ?? 0).toString(),
                  PhosphorIcons.mapPin(),
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(
                child: _buildStatItem(
                  'Rating',
                  (widget.agency['rating'] ?? 0).toString(),
                  PhosphorIcons.star(),
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              Expanded(
                child: _buildStatItem(
                  'Reviews',
                  _actualReviewCount.toString(),
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
                children: ((widget.agency['amenities'] as List<dynamic>?) ?? <String>[]).map((amenity) {
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
                    (widget.agency['rating'] ?? 0).toString(),
                    style: quicksand(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      final rating = (widget.agency['rating'] ?? 0) as num;
                      return Icon(
                        index < rating.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 20,
                        color: Colors.amber,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_actualReviewCount reviews',
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

        // Write Review Button (only if user can review)
        if (!_isCheckingCanReview && _canUserReview)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showReviewDialog(),
              icon: PhosphorIcon(
                PhosphorIcons.pencil(),
                size: 20,
                color: Colors.white,
              ),
              label: Text(
                'Write a Review',
                style: quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

        if (!_isCheckingCanReview && !_canUserReview)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.info(),
                  size: 20,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can only review agencies you have booked with.',
                    style: quicksand(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Reviews List
        _isLoadingReviews
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF9500),
                  ),
                ),
              )
            : _reviews.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.chatCircle(),
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to review this agency!',
                            style: quicksand(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView(
                      children: _reviews.map((review) => Container(
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
                            ((review['user']?['name'] ?? review['userName'] ?? 'U') as String)[0].toUpperCase(),
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
                              review['user']?['name'] ?? review['userName'] ?? 'Anonymous',
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
                                  final rating = (review['rating'] ?? 0) as int;
                                  return Icon(
                                    index < rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 14,
                                    color: Colors.amber,
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  _formatReviewDate(review['createdAt'] ?? review['date']),
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
                  if (review['route'] != null) ...[
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
                  ],
                  const SizedBox(height: 12),
                  Text(
                    review['comment'] ?? review['text'] ?? '',
                    style: quicksand(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )).toList(),
                    ),
                  ),
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatReviewDate(dynamic date) {
    if (date == null) return 'Recently';
    
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
      final now = DateTime.now();
      final difference = now.difference(parsedDate);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else {
        return '${(difference.inDays / 365).floor()} years ago';
      }
      } catch (e) {
        return date.toString();
      }
    }
    
    return date.toString();
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

  void _showReviewDialog() {
    int selectedRating = 5;
    final TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Write a Review',
            style: quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rating',
                  style: quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedRating = index + 1;
                        });
                      },
                      child: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        size: 40,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Text(
                  'Comment',
                  style: quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    hintStyle: quicksand(
                      fontSize: 14,
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
                  ),
                  style: quicksand(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                    if (commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter a comment',
                            style: quicksand(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      isSubmitting = true;
                    });

                    try {
                      final apiService = ApiService();
                      final agencyId = widget.agency['id'] as String;
                      await apiService.createAgencyReview(
                        agencyId: agencyId,
                        rating: selectedRating,
                        comment: commentController.text.trim(),
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Review submitted successfully!',
                              style: quicksand(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadReviews(); // Reload reviews
                      }
                    } catch (e) {
                      if (mounted) {
                        setDialogState(() {
                          isSubmitting = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceAll('Exception: ', ''),
                              style: quicksand(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit',
                      style: quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
