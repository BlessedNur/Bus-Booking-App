import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/font_helper.dart';

class LocationPicker extends StatefulWidget {
  final String? initialLocation;
  final String title;

  const LocationPicker({
    super.key,
    this.initialLocation,
    this.title = 'Select Location',
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();

  static Future<String?> show(
    BuildContext context, {
    String? initialLocation,
    String title = 'Select Location',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPicker(
        initialLocation: initialLocation,
        title: title,
      ),
    );
  }
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Major cities and towns in Cameroon
  final List<String> _cameroonLocations = [
    'Douala',
    'Yaoundé',
    'Garoua',
    'Bafoussam',
    'Bamenda',
    'Maroua',
    'Ngaoundéré',
    'Bertoua',
    'Kumba',
    'Limbe',
    'Edéa',
    'Kribi',
    'Mbalmayo',
    'Ebolowa',
    'Foumban',
    'Dschang',
    'Loum',
    'Nkongsamba',
    'Bafang',
    'Buéa',
    'Mbouda',
    'Kousseri',
    'Guider',
    'Meiganga',
    'Yagoua',
    'Mokolo',
    'Wum',
    'Kumbo',
    'Banyo',
    'Tibati',
  ];

  List<String> get _filteredLocations {
    if (_searchQuery.isEmpty) {
      return _cameroonLocations;
    }
    return _cameroonLocations
        .where((location) =>
            location.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search location...',
                hintStyle: quicksand(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: PhosphorIcon(
                  PhosphorIcons.magnifyingGlass(),
                  size: 20,
                  color: Colors.grey.shade400,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF9500),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: quicksand(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),

          const Divider(height: 1),

          // Locations list
          Expanded(
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.magnifyingGlass(),
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No locations found',
                            style: quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: quicksand(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      final isSelected = location == widget.initialLocation;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, location);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF9500).withOpacity(0.1)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.mapPin(),
                                size: 20,
                                color: isSelected
                                    ? const Color(0xFFFF9500)
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  location,
                                  style: quicksand(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? const Color(0xFFFF9500)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                PhosphorIcon(
                                  PhosphorIcons.check(),
                                  size: 20,
                                  color: const Color(0xFFFF9500),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
