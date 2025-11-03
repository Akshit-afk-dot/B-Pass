import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'offers_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'flight_offer.dart';

// Add at the top of the file (after imports):
final Map<String, String> logoMap = {
  'cleartrip.com': 'assets/logos/cleartrip.png',
  'Cleartrip': 'assets/logos/cleartrip.png',
  'easemytrip.com': 'assets/logos/easemytrip.png',
  'EaseMyTrip': 'assets/logos/easemytrip.png',
  'ixigo.com': 'assets/logos/ixigo.png',
  'Ixigo': 'assets/logos/ixigo.png',
  'adanione.com': 'assets/logos/adanione.png',
  'AdaniOne': 'assets/logos/adanione.png',
  'adani flights': 'assets/logos/adanione.png',
  'ADANI FLIGHTS': 'assets/logos/adanione.png',
  'yatra.com': 'assets/logos/yatra.png',
  'Yatra': 'assets/logos/yatra.png',
  'goibibo.com': 'assets/logos/goibibo.png',
  'Goibibo': 'assets/logos/goibibo.png',
  'paytm.com': 'assets/logos/paytm.png',
  'Paytm': 'assets/logos/paytm.png',
  // Add more mappings as needed
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialState;
  const HomeScreen({super.key, this.initialState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isRoundTrip = false;
  String? _selectedSource;
  String? _selectedDestination;
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  List<String> _selectedWebsites = [];

  final List<String> _websites = flightWebsites.map((w) => w['name'] as String).toList();

  List<Map<String, String>> _airports = [];
  bool _loadingAirports = true;

  @override
  void initState() {
    super.initState();
    _loadAirports();
    // Restore state if provided
    final s = widget.initialState;
    if (s != null) {
      _selectedSource = s['selectedSource'];
      _selectedDestination = s['selectedDestination'];
      _departureDate = s['departureDate'];
      _returnDate = s['returnDate'];
      _isRoundTrip = s['isRoundTrip'] ?? false;
      _adults = s['adults'] ?? 1;
      _children = s['children'] ?? 0;
      _infants = s['infants'] ?? 0;
      _selectedWebsites = List<String>.from(s['selectedWebsites'] ?? []);
    }
  }

  Future<void> _loadAirports() async {
    print('Loading airports...');
    try {
      final String data = await rootBundle.loadString('assets/airports.json');
      final Map<String, dynamic> jsonResult = json.decode(data);
      final List<Map<String, String>> airports = [];
      jsonResult.forEach((key, value) {
        if ((value['city'] ?? '').isNotEmpty && (value['name'] ?? '').isNotEmpty) {
          airports.add({
            'code': value['iata'] ?? '',
            'city': value['city'] ?? '',
            'name': value['name'] ?? '',
          });
        }
      });
      print('Loaded \u001b[32m\u001b[1m${airports.length}\u001b[0m airports');
      print('Sample: ${airports.take(10).toList()}');
      setState(() {
        _airports = airports;
        _loadingAirports = false;
      });
    } catch (e) {
      print('Error loading airports: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildHome(context) : _buildOffers(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Offers',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
    );
  }

  Widget _buildHome(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Greyed out background
          Container(
            color: Colors.black.withOpacity(0.08),
          ),
          // Animated card
          Center(
            child: Container(
              width: 420,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Title Row
                    Row(
                      children: [
                        Text(
                          'FareByAir',
                          style: TextStyle(
                            fontFamily: 'Teko',
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.orange[800],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: !_isRoundTrip ? Colors.orange : Colors.white,
                                foregroundColor: !_isRoundTrip ? Colors.white : Colors.orange,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  bottomLeft: Radius.circular(32),
                                ),
                                  side: BorderSide(color: Colors.orange, width: 2),
                              ),
                                elevation: !_isRoundTrip ? 4 : 0,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shadowColor: Colors.orange.withOpacity(0.18),
                            ),
                            onPressed: () => setState(() => _isRoundTrip = false),
                              child: const Text(
                                'ONE WAY',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Teko',
                                ),
                              ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _isRoundTrip ? Colors.orange : Colors.white,
                                foregroundColor: _isRoundTrip ? Colors.white : Colors.orange,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(32),
                                  bottomRight: Radius.circular(32),
                                ),
                                  side: BorderSide(color: Colors.orange, width: 2),
                              ),
                                elevation: _isRoundTrip ? 4 : 0,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shadowColor: Colors.orange.withOpacity(0.18),
                            ),
                            onPressed: () => setState(() => _isRoundTrip = true),
                              child: const Text(
                                'ROUNDTRIP',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Teko',
                                ),
                              ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Source & Destination
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _loadingAirports
                                ? const CircularProgressIndicator()
                                : _AirportDropdown(
                                    hint: 'From',
                                    airports: _airports,
                                    value: _selectedSource,
                                    onChanged: (val) => setState(() => _selectedSource = val),
                                    exclude: _selectedDestination,
                                    showStyled: true, // new prop to control styled display
                                  ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                            height: 64,
                            width: 64,
                            child: IconButton(
                              icon: const Icon(Icons.swap_horiz, color: Colors.orange, size: 36),
                              onPressed: () {
                                setState(() {
                                  final temp = _selectedSource;
                                  _selectedSource = _selectedDestination;
                                  _selectedDestination = temp;
                                });
                              },
                              tooltip: 'Swap',
                            ),
                          ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _loadingAirports
                                ? const CircularProgressIndicator()
                                : _AirportDropdown(
                                    hint: 'To',
                                    airports: _airports,
                                    value: _selectedDestination,
                                    onChanged: (val) => setState(() => _selectedDestination = val),
                                    exclude: _selectedSource,
                                    showStyled: true, // new prop to control styled display
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Departure'),
                              const SizedBox(height: 4),
                              _DateSelector(
                                hint: 'Select date',
                                selectedDate: _departureDate,
                                onDateSelected: (date) => setState(() => _departureDate = date),
                              ),
                            ],
                          ),
                        ),
                        if (_isRoundTrip) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Return'),
                                const SizedBox(height: 4),
                                _DateSelector(
                                  hint: 'Select date',
                                  selectedDate: _returnDate,
                                  onDateSelected: (date) => setState(() => _returnDate = date),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Passengers
                    const Text('Travellers'),
                    const SizedBox(height: 4),
                    _PassengerSelector(
                      adults: _adults,
                      children: _children,
                      infants: _infants,
                      onChanged: (adults, children, infants) {
                        setState(() {
                          _adults = adults;
                          _children = children;
                          _infants = infants;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Websites
                      const SizedBox(height: 16),
                      Text('Websites'),
                    const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _websites.map((site) {
                            final selected = _selectedWebsites.contains(site);
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(site),
                                selected: selected,
                                onSelected: (selectedNow) {
                                  setState(() {
                                    if (selectedNow) {
                                      _selectedWebsites.add(site);
                                    } else {
                                      _selectedWebsites.remove(site);
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                    ),
                    const SizedBox(height: 32),
                    // Compare Flights Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _selectedWebsites.isEmpty
                            ? null
                            : () async {
                                print('DEBUG: _departureDate = [32m$_departureDate[0m, _returnDate = [32m$_returnDate[0m');
                                if (_selectedSource == null || _selectedSource!.isEmpty ||
                                    _selectedDestination == null || _selectedDestination!.isEmpty ||
                                    _departureDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please fill all required fields.')),
                                  );
                                  return;
                                }
                                print('DEBUG: searchParams =');
                                print({
                                  'origin': _selectedSource ?? '',
                                  'destination': _selectedDestination ?? '',
                                  'dateDDMMYYYY': formatDate(_departureDate, format: 'DDMMYYYY'),
                                  'dateYYYYMMDD': formatDate(_departureDate, format: 'YYYYMMDD'),
                                    'dateDDMMYYYYcompact': formatDate(_departureDate, format: 'DDMMYYYY'),
                                  'dateDDMMYYYYdash': formatDate(_departureDate, format: 'DDMMYYYYdash'),
                                  'dateYYYY-MM-DD': formatDate(_departureDate, format: 'YYYY-MM-DD'),
                                  'dateDDMMYYYYslash': formatDate(_departureDate, format: 'DD/MM/YYYY'),
                                  'dateDDMMYY': formatDate(_departureDate, format: 'DDMMYY'),
                                  'returnDateDDMMYYYY': _isRoundTrip ? formatDate(_returnDate, format: 'DDMMYYYY') : '',
                                  'returnDateYYYYMMDD': _isRoundTrip ? formatDate(_returnDate, format: 'YYYYMMDD') : '',
                                    'returnDateDDMMYYYYcompact': _isRoundTrip ? formatDate(_returnDate, format: 'DDMMYYYY') : '',
                                  'returnDateDDMMYYYYdash': _isRoundTrip ? formatDate(_returnDate, format: 'DDMMYYYYdash') : '',
                                  'returnDateYYYY-MM-DD': _isRoundTrip ? formatDate(_returnDate, format: 'YYYY-MM-DD') : '',
                                  'returnDateDDMMYYYYslash': _isRoundTrip ? formatDate(_returnDate, format: 'DD/MM/YYYY') : '',
                                  'returnDateDDMMYY': _isRoundTrip ? formatDate(_returnDate, format: 'DDMMYY') : '',
                                  'tripType': _isRoundTrip ? 'roundtrip' : 'oneway',
                                  'adults': _adults.toString(),
                                  'children': _children.toString(),
                                  'infants': _infants.toString(),
                                    'departureDate': _departureDate,
                                    'returnDate': _returnDate,
                                });
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => WebViewTabsScreen(
                                      websites: _selectedWebsites,
                                      searchParams: {
                                        'origin': _selectedSource ?? '',
                                        'destination': _selectedDestination ?? '',
                                        'dateDDMMYYYY': formatDate(_departureDate, format: 'DDMMYYYY'),
                                        'dateYYYYMMDD': formatDate(_departureDate, format: 'YYYYMMDD'),
                                          'dateDDMMYYYYcompact': formatDate(_departureDate, format: 'DDMMYYYY'),
                                        'dateDDMMYYYYdash': formatDate(_departureDate, format: 'DDMMYYYYdash'),
                                        'dateYYYY-MM-DD': formatDate(_departureDate, format: 'YYYY-MM-DD'),
                                        'dateDDMMYYYYslash': formatDate(_departureDate, format: 'DD/MM/YYYY'),
                                        'dateDDMMYY': formatDate(_departureDate, format: 'DDMMYY'),
                                        'returnDateDDMMYYYY': _isRoundTrip ? formatDate(_returnDate, format: 'DDMMYYYY') : '',
                                        'returnDateYYYYMMDD': _isRoundTrip ? formatDate(_returnDate, format: 'YYYYMMDD') : '',
                                          'returnDateDDMMYYYYcompact': _isRoundTrip ? formatDate(_returnDate, format: 'DDMMYYYY') : '',
                                        'returnDateDDMMYYYYdash': _isRoundTrip ? formatDate(_returnDate, format: 'DDMMYYYYdash') : '',
                                        'returnDateYYYY-MM-DD': _isRoundTrip ? formatDate(_returnDate, format: 'YYYY-MM-DD') : '',
                                        'returnDateDDMMYYYYslash': _isRoundTrip ? formatDate(_returnDate, format: 'DD/MM/YYYY') : '',
                                        'returnDateDDMMYY': _isRoundTrip ? formatDate(_returnDate, format: 'DDMMYY') : '',
                                        'tripType': _isRoundTrip ? 'roundtrip' : 'oneway',
                                        'adults': _adults.toString(),
                                        'children': _children.toString(),
                                        'infants': _infants.toString(),
                                          'departureDate': _departureDate,
                                          'returnDate': _returnDate,
                                      },
                                      airports: _airports,
                                      initialState: {
                                        'selectedSource': _selectedSource,
                                        'selectedDestination': _selectedDestination,
                                        'departureDate': _departureDate,
                                        'returnDate': _returnDate,
                                        'isRoundTrip': _isRoundTrip,
                                        'adults': _adults,
                                        'children': _children,
                                        'infants': _infants,
                                      },
                                    ),
                                  ),
                                );
                                if (result is Map<String, dynamic>) {
                                  setState(() {
                                    _selectedSource = result['selectedSource'];
                                    _selectedDestination = result['selectedDestination'];
                                    _departureDate = result['departureDate'];
                                    _returnDate = result['returnDate'];
                                    _isRoundTrip = result['isRoundTrip'] ?? false;
                                    _adults = result['adults'] ?? 1;
                                    _children = result['children'] ?? 0;
                                    _infants = result['infants'] ?? 0;
                                    _selectedWebsites = List<String>.from(result['selectedWebsites'] ?? []);
                                  });
                                }
                              },
                        child: const Text(
                          'Submit',
                        ),
                      ),
                    ),
                      const SizedBox(height: 24),
                      Divider(),
                      const SizedBox(height: 8),
                      Text('Coupons', style: TextStyle(fontFamily: 'Teko', fontWeight: FontWeight.bold, fontSize: 24, color: Colors.orange)),
                      FutureBuilder<String>(
                        future: rootBundle.loadString('assets/Offers.json'),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final Map<String, dynamic> jsonResult = json.decode(snapshot.data!);
                          final offers = FlightOffer.fromJsonList(jsonResult);
                          offers.sort((a, b) => b.savings.compareTo(a.savings));
                          final topOffers = offers.take(5).toList();
                          return Column(
                            children: topOffers.map((offer) => HomeCouponCard(offer: offer)).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffers(BuildContext context) {
    return OffersScreen();
  }
}

// Replace _AirportDropdown with a searchable dropdown
class _AirportDropdown extends StatelessWidget {
  final String hint;
  final List<Map<String, String>> airports;
  final String? value;
  final void Function(String?) onChanged;
  final String? exclude;
  final bool showStyled;
  const _AirportDropdown({required this.hint, required this.airports, required this.value, required this.onChanged, this.exclude, this.showStyled = false});

  @override
  Widget build(BuildContext context) {
    final selectedAirport = airports.firstWhere(
      (a) => a['code'] == value,
      orElse: () => {'city': '', 'name': '', 'code': ''},
    );
    return GestureDetector(
      onTap: () async {
        final result = await showSearch<Map<String, String>?>(
          context: context,
          delegate: _AirportSearchDelegate(
            airports: airports.where((a) => a['code'] != exclude).toList(),
            hint: hint,
          ),
        );
        if (result != null) {
          onChanged(result['code']);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: (showStyled && value != null && value!.isNotEmpty && (selectedAirport['city'] ?? '').isNotEmpty)
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
              child: Text(
                          selectedAirport['city'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          selectedAirport['code'] ?? '',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.1,
                            shadows: [Shadow(color: Colors.orangeAccent, blurRadius: 2, offset: Offset(0, 1))],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    hint,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
            ),
            // Removed the search icon here
          ],
        ),
      ),
    );
  }
}

class _AirportSearchDelegate extends SearchDelegate<Map<String, String>?> {
  final List<Map<String, String>> airports;
  final String hint;
  _AirportSearchDelegate({required this.airports, required this.hint}) : super(searchFieldLabel: hint);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(fontFamily: 'Teko', fontSize: 22, color: Colors.black),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filtered = airports.where((a) {
      final q = query.toLowerCase();
      return a['city']!.toLowerCase().contains(q) ||
             a['name']!.toLowerCase().contains(q) ||
             a['code']!.toLowerCase().contains(q);
    }).toList();
    return _buildList(filtered);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = query.isEmpty
      ? airports.take(10).toList() // Show only a few suggestions when empty
      : airports.where((a) {
          final q = query.toLowerCase();
          return a['city']!.toLowerCase().contains(q) ||
                 a['name']!.toLowerCase().contains(q) ||
                 a['code']!.toLowerCase().contains(q);
        }).toList();
    return _buildList(filtered);
  }

  Widget _buildList(List<Map<String, String>> filtered) {
    if (filtered.isEmpty) {
      return const Center(child: Text('No results found'));
    }
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final airport = filtered[index];
        return ListTile(
          title: Text(
            '${airport['city']} - ${airport['name']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          subtitle: Text(airport['code']!, style: const TextStyle(fontFamily: 'Teko', fontSize: 14)),
          onTap: () => close(context, airport),
        );
      },
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String hint;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  const _DateSelector({required this.hint, required this.selectedDate, required this.onDateSelected});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? now,
          firstDate: now,
          lastDate: DateTime(now.year + 2),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              selectedDate != null ? _formatDate(selectedDate!) : hint,
            ),
            const Spacer(),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PassengerSelector extends StatelessWidget {
  final int adults;
  final int children;
  final int infants;
  final void Function(int, int, int) onChanged;
  const _PassengerSelector({
    required this.adults,
    required this.children,
    required this.infants,
    required this.onChanged,
  });

  String _summary() {
    List<String> parts = [];
    if (adults > 0) parts.add('$adults Adult${adults > 1 ? 's' : ''}');
    if (children > 0) parts.add('$children Child${children > 1 ? 'ren' : ''}');
    if (infants > 0) parts.add('$infants Infant${infants > 1 ? 's' : ''}');
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<_PassengerSelectionResult>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => _PassengerSelectorSheet(
            adults: adults,
            children: children,
            infants: infants,
          ),
        );
        if (result != null) {
          onChanged(result.adults, result.children, result.infants);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(_summary()),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _PassengerSelectionResult {
  final int adults;
  final int children;
  final int infants;
  _PassengerSelectionResult(this.adults, this.children, this.infants);
}

class _PassengerSelectorSheet extends StatefulWidget {
  final int adults;
  final int children;
  final int infants;
  const _PassengerSelectorSheet({
    required this.adults,
    required this.children,
    required this.infants,
  });

  @override
  State<_PassengerSelectorSheet> createState() => _PassengerSelectorSheetState();
}

class _PassengerSelectorSheetState extends State<_PassengerSelectorSheet> {
  late int _adults;
  late int _children;
  late int _infants;

  @override
  void initState() {
    super.initState();
    _adults = widget.adults;
    _children = widget.children;
    _infants = widget.infants;
  }

  Widget _counter(String label, int value, void Function(int) onChanged, {int min = 0, int max = 9}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            Text('$value'),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _counter('Adults', _adults, (v) => setState(() => _adults = v), min: 1),
          _counter('Children', _children, (v) => setState(() => _children = v)),
          _counter('Infants', _infants, (v) => setState(() => _infants = v)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(_PassengerSelectionResult(_adults, _children, _infants));
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebsiteSelector extends StatelessWidget {
  final List<String> websites;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  const _WebsiteSelector({required this.websites, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: websites.map((site) {
          final isSelected = selected.contains(site);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(site),
              selected: isSelected,
              selectedColor: Colors.orange,
              backgroundColor: const Color(0xFFF2F2F2),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              onSelected: (val) {
                final newSelected = List<String>.from(selected);
                if (val) {
                  newSelected.add(site);
                } else {
                  newSelected.remove(site);
                }
                onChanged(newSelected);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Text(
          'FareByAir.',
          style: const TextStyle(
            fontFamily: 'Teko',
            fontWeight: FontWeight.bold,
            fontSize: 48,
            color: Colors.black,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      'title': '✈️ One App. Every Flight Deal.',
      'body': 'Welcome to MaxxFare, your personal flight deal companion.\nCompare flights across Goibibo, MakeMyTrip, Ixigo, Skyscanner, and more — all in one place.\nSave time. Save money. Book smart.',
    },
    {
      'title': '🔍 Search Smarter',
      'body': 'Enter your source & destination\nPick dates, number of travelers, and select the travel websites to include.\nWith a boarding pass-style interface, searching feels intuitive and modern.\nRound-trip or One-way? Just toggle and go!',
    },
    {
      'title': '💸 Auto-Applied Coupons, Maximum Savings',
      'body': 'Get the best promo codes, bank offers, and UPI discounts shown in ranked order.\nOffers are filtered by your ticket amount, type (domestic/international), and even payment method.\nTags like "Expiring Soon", "Upcoming", and "Recommended" help you grab the best deal.',
    },
    {
      'title': '🚀 Ready to Fly Smarter?',
      'body': '🧭 Go to Home to search & compare flights\n🎁 Tap Offers to browse curated coupons\n⚙️ All features are live and work out-of-the-box\nLet\'s find your perfect flight.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      int next = _controller.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/plane.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        pages[index]['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Teko',
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        pages[index]['body']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Teko',
                          color: Colors.white,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.black26,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      if (index == pages.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Get Started',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (dotIndex) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == dotIndex ? Colors.white : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebViewTabsScreen extends StatefulWidget {
  final List<String> websites;
  final Map<String, dynamic> searchParams;
  final List<Map<String, String>> airports;
  final Map<String, dynamic>? initialState;
  const WebViewTabsScreen({required this.websites, required this.searchParams, required this.airports, this.initialState});

  @override
  State<WebViewTabsScreen> createState() => _WebViewTabsScreenState();
}

class _WebViewTabsScreenState extends State<WebViewTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<_TabInfo> _tabs;
  late List<InAppWebViewController?> _controllers;
  int _activeTab = 1;
  List<String?> _webViewErrors = [];
  late List<bool> _shouldLoadTab;

  String getCityForIata(String? iata, List<Map<String, String>> airports) {
    if (iata == null || iata.isEmpty) return '';
    final found = airports.firstWhere(
      (a) => a['code'] == iata,
      orElse: () => {},
    );
    return found['city'] ?? '';
  }

  Map<String, dynamic>? getWebsiteByName(String name) {
    return flightWebsites.firstWhere(
      (w) => w['name'].toString().toLowerCase() == name.toLowerCase(),
      orElse: () => <String, dynamic>{},
    );
  }

  String buildUrlForWebsite(Map<String, dynamic> website, Map<String, dynamic> params) {
    final urlTemplate = website['urlTemplate'] as String;
    final dateFormat = website['dateFormat'] as Map<String, dynamic>?;
    final Map<String, dynamic> urlParams = Map<String, dynamic>.from(params);
    bool missingRequiredDate = false;
    // Always set the required date keys for the template
    if (dateFormat != null) {
      dateFormat.forEach((key, format) {
        DateTime? date;
        if (key.toLowerCase().contains('depart')) {
          date = params['departureDate'] as DateTime?;
          if (date != null) {
            urlParams[key] = formatDateForSite(date, format);
          } else {
            urlParams[key] = '';
            // Only block navigation if a departure date is missing
            if (urlTemplate.contains('{$key}')) missingRequiredDate = true;
          }
        } else if (key.toLowerCase().contains('return')) {
          date = params['returnDate'] as DateTime?;
          if (date != null) {
            urlParams[key] = formatDateForSite(date, format);
          } else {
            urlParams[key] = '';
            // Do NOT block navigation if return date is missing (one-way trip)
          }
        } else {
          urlParams[key] = '';
        }
      });
    }
    // If any required departure date is missing, return an empty string to block navigation
    if (missingRequiredDate) {
      return '';
    }
    String url = buildUrl(urlTemplate, urlParams);
    // Clean up any double dashes, slashes, or trailing dashes/slashes
    url = url.replaceAll('--', '-');
    url = url.replaceAll(RegExp(r'-+$'), '');
    url = url.replaceAll(RegExp(r'/+$'), '');
    return url;
  }

  @override
  void initState() {
    super.initState();
    _tabs = widget.websites.map((site) => _TabInfo(site)).toList();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _controllers = List<InAppWebViewController?>.filled(widget.websites.length, null);
    _webViewErrors = List<String?>.filled(widget.websites.length, null);
    _shouldLoadTab = List.generate(widget.websites.length, (i) => i == 0);
    _tabController.addListener(() {
      setState(() {
        _activeTab = _tabController.index;
      });
    });
  }

  void _onTabLoaded(int index) async {
    if (index + 1 < _shouldLoadTab.length && !_shouldLoadTab[index + 1]) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _shouldLoadTab[index + 1] = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentController = _controllers[_tabController.index];
        if (currentController != null) {
          bool canGoBack = await currentController.canGoBack();
          if (canGoBack) {
            await currentController.goBack();
            return false;
          }
        }
        return true;
      },
      child: DefaultTabController(
      length: _tabs.length - 1, // Remove Home tab
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.orange),
                    onPressed: () {
                      Navigator.of(context).pop(widget.initialState ?? {});
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicator: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.black,
                        labelStyle: const TextStyle(fontFamily: 'Teko', fontWeight: FontWeight.bold, fontSize: 18),
                        unselectedLabelStyle: const TextStyle(fontFamily: 'Teko', fontSize: 18),
                        tabs: _tabs.map((tab) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              if (tab.icon != null) Icon(tab.icon, size: 20, color: Colors.orange),
                              if (tab.icon != null) const SizedBox(width: 4),
                              Text(tab.label),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
          body: IndexedStack(
            index: _tabController.index,
          children: List.generate(widget.websites.length, (i) {
              if (!_shouldLoadTab[i]) {
                return const Center(child: CircularProgressIndicator());
              }
            final site = widget.websites[i];
              final websiteMap = getWebsiteByName(site);
              String url = '';
              if (websiteMap != null && websiteMap.isNotEmpty && websiteMap['buildSearchUrl'] != null) {
                url = websiteMap['buildSearchUrl'](widget.searchParams, widget.airports);
              } else {
                url = 'https://www.google.com/search?q=' + Uri.encodeComponent(site + ' flights');
              }
              if (url.isEmpty) {
                // If URL is empty, just show a blank container (should not happen)
                return Container();
              }
            print('WebView[$site] loading URL: $url');
              return Expanded(
                child: Stack(
              children: [
                InAppWebView(
              key: ValueKey(site),
              initialUrlRequest: URLRequest(
                url: WebUri(url),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                userAgent: 'Mozilla/5.0 (Linux; Android 13; SM-S918B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
                        thirdPartyCookiesEnabled: true,
                        domStorageEnabled: true,
                        databaseEnabled: true,
                        cacheEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                supportZoom: true,
                transparentBackground: false,
              ),
              onWebViewCreated: (controller) {
                _controllers[i] = controller;
              },
              onLoadStart: (controller, url) {
                        debugPrint('WebView[\x1b[32m$site\x1b[0m] load start: ' + (url?.toString() ?? 'null'));
                    setState(() {
                      _webViewErrors[i] = null;
                    });
              },
              onLoadStop: (controller, url) {
                        debugPrint('WebView[\x1b[32m$site\x1b[0m] load stop: ' + (url?.toString() ?? 'null'));
                        _onTabLoaded(i);
              },
              onReceivedError: (controller, request, error) {
                        debugPrint('WebView[\x1b[31m$site\x1b[0m] received error:  7Berror.type} ${error.description} for ${request.url}');
                    setState(() {
                          _webViewErrors[i] = 'Received error: ${error.type} ${error.description}\nURL: \x1b[31m${request.url}\x1b[0m';
                    });
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
              },
                            ),
                          ],
                        ),
            );
          }),
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final IconData? icon;
  _TabInfo(this.label, {this.icon});
}

String formatDate(DateTime? date, {String format = 'DDMMYYYY'}) {
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  switch (format) {
    case 'DDMMYYYY':
      return '$day$month$year';
    case 'YYYYMMDD':
      return '$year$month$day';
    case 'YYYY-MM-DD':
      return '$year-$month-$day';
    case 'DDMMYYYYcompact':
      return '$day$month$year';
    case 'DDMMYYYYdash':
      return '$day-$month-$year';
    case 'DD/MM/YYYY':
      return '$day/$month/$year';
    case 'DDMMYY':
      return '$day$month${year.substring(2)}';
    default:
      return '$day$month$year';
  }
}

String safeParam(Map<String, dynamic> params, String key) {
  final val = params[key];
  if (val == null) return '';
  if (val is String && val.isEmpty) return '';
  return val.toString();
}

String formatDateForSite(DateTime? date, String format) {
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  switch (format) {
    case 'DD/MM/YYYY':
      return '$day/$month/$year';
    case 'DDMMYYYY':
      return '$day$month$year';
    case 'YYYYMMDD':
      return '$year$month$day';
    case 'YYYY-MM-DD':
      return '$year-$month-$day';
    case 'DD-MM-YYYY':
      return '$day-$month-$year';
    case 'DDMMYY':
      return '$day$month${year.substring(2)}';
    default:
      return '$day/$month/$year';
  }
}

String buildUrl(String template, Map<String, dynamic> params) {
  String url = template;
  params.forEach((key, value) {
    url = url.replaceAll('{$key}', Uri.encodeComponent(value?.toString() ?? ''));
  });
  return url;
}

// Top-level getCityForIata for use in all contexts
String getCityForIata(String? iata, List<Map<String, String>> airports) {
  if (iata == null || iata.isEmpty) return '';
  final found = airports.firstWhere(
    (a) => a['code'] == iata,
    orElse: () => {},
  );
  return found['city'] ?? '';
}

final List<Map<String, dynamic>> flightWebsites = [
  {
    'id': 'cleartrip',
    'name': 'Cleartrip',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateDDMMYYYYslash = params['dateDDMMYYYYslash'] ?? '';
      final returnDateDDMMYYYYslash = params['returnDateDDMMYYYYslash'] ?? '';
      final tripType = params['tripType'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      final originCity = getCityForIata(origin, airports);
      final destinationCity = getCityForIata(destination, airports);
      final encodedDepart = Uri.encodeFull(dateDDMMYYYYslash);
      final encodedReturn = Uri.encodeFull(returnDateDDMMYYYYslash);
      final encodedOrigin = Uri.encodeFull('$origin - $originCity, IN');
      final encodedDestination = Uri.encodeFull('$destination - $destinationCity, IN');
      final sourceCountry = Uri.encodeFull(originCity);
      final destinationCountry = Uri.encodeFull(destinationCity);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final rndOne = tripType == 'roundtrip' ? 'R' : 'O';
      if (tripType == 'roundtrip' && returnDateDDMMYYYYslash.isNotEmpty) {
        return 'https://www.cleartrip.com/flights/results?adults=$adults&childs=$children&infants=$infants&class=Economy&depart_date=$encodedDepart&return_date=$encodedReturn&from=$origin&to=$destination&intl=n&origin=$encodedOrigin&destination=$encodedDestination&sft=&sd=$timestamp&rnd_one=$rndOne&isCfw=false&sourceCountry=$sourceCountry&destinationCountry=$destinationCountry';
      } else {
        return 'https://www.cleartrip.com/flights/results?adults=$adults&childs=$children&infants=$infants&class=Economy&depart_date=$encodedDepart&from=$origin&to=$destination&intl=n&origin=$encodedOrigin&destination=$encodedDestination&sft=&sd=$timestamp&rnd_one=$rndOne&isCfw=false&sourceCountry=$sourceCountry&destinationCountry=$destinationCountry';
      }
    },
  },
  {
    'id': 'makemytrip',
    'name': 'MakeMyTrip',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateDDMMYYYYslash = params['dateDDMMYYYYslash'] ?? '';
      final returnDateDDMMYYYYslash = params['returnDateDDMMYYYYslash'] ?? '';
      final tripType = params['tripType'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      final encodedDepart = Uri.encodeFull(dateDDMMYYYYslash);
      final encodedReturn = Uri.encodeFull(returnDateDDMMYYYYslash);
      if (tripType == 'roundtrip' && returnDateDDMMYYYYslash.isNotEmpty) {
        return 'https://www.makemytrip.com/flight/search?itinerary=${origin}-${destination}-${encodedDepart}_${destination}-${origin}-${encodedReturn}&tripType=R&paxType=A-${adults}_C-${children}_I-${infants}&intl=false&cabinClass=E&ccde=IN&lang=eng';
      } else {
        return 'https://www.makemytrip.com/flight/search?itinerary=${origin}-${destination}-${encodedDepart}&tripType=O&paxType=A-${adults}_C-${children}_I-${infants}&intl=false&cabinClass=E&ccde=IN&lang=eng';
      }
    },
  },
  {
    'id': 'goibibo',
    'name': 'Goibibo',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateDDMMYYYYslash = params['dateDDMMYYYYslash'] ?? '';
      final returnDateDDMMYYYYslash = params['returnDateDDMMYYYYslash'] ?? '';
      final tripType = params['tripType'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      final encodedDepart = Uri.encodeFull(dateDDMMYYYYslash);
      final encodedReturn = Uri.encodeFull(returnDateDDMMYYYYslash);
      if (tripType == 'roundtrip' && returnDateDDMMYYYYslash.isNotEmpty) {
        return 'https://www.goibibo.com/flight/search/?tripType=R&itinerary=${origin}-${destination}-${encodedDepart}_${destination}-${origin}-${encodedReturn}&paxType=A-${adults}_C-${children}_I-${infants}&cabinClass=E&intl=false&ccde=IN&lang=eng';
      } else {
        return 'https://www.goibibo.com/flight/search/?tripType=O&itinerary=${origin}-${destination}-${encodedDepart}&paxType=A-${adults}_C-${children}_I-${infants}&cabinClass=E&intl=false&ccde=IN&lang=eng';
      }
    },
  },
  {
    'id': 'easemytrip',
    'name': 'EaseMyTrip',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateDDMMYYYYslash = params['dateDDMMYYYYslash'] ?? '';
      final returnDateDDMMYYYYslash = params['returnDateDDMMYYYYslash'] ?? '';
      final tripType = params['tripType'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      final originCity = getCityForIata(origin, airports);
      final destinationCity = getCityForIata(destination, airports);
      final encodedOriginCity = Uri.encodeComponent(originCity);
      final encodedDestinationCity = Uri.encodeComponent(destinationCity);
      final encodedOrigin = '$origin-$encodedOriginCity-India';
      final encodedDestination = '$destination-$encodedDestinationCity-India';
      final encodedDepart = Uri.encodeComponent(dateDDMMYYYYslash);
      String srch = '$encodedOrigin|$encodedDestination|$encodedDepart';
      String ar = 'undefined';
      if (tripType == 'roundtrip' && returnDateDDMMYYYYslash.isNotEmpty) {
        final encodedReturn = Uri.encodeComponent(returnDateDDMMYYYYslash);
        final srchReturn = '$encodedDestination|$encodedOrigin|$encodedReturn';
        srch = '$srch|$srchReturn';
        ar = encodedReturn;
      }
      return 'https://flight.easemytrip.com/FlightList/Index?srch=$srch&px=$adults-$children-$infants&cbn=0&ar=$ar&isow=${tripType == 'roundtrip' ? 'false' : 'true'}&isdm=true&lang=en-us&&IsDoubleSeat=false&CCODE=IN&curr=INR&apptype=B2C';
    },
  },
  {
    'id': 'ixigo',
    'name': 'Ixigo',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateDDMMYYYYcompact = params['dateDDMMYYYYcompact'] ?? '';
      final returnDateDDMMYYYYcompact = params['returnDateDDMMYYYYcompact'] ?? '';
      final tripType = params['tripType'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      if (tripType == 'roundtrip' && returnDateDDMMYYYYcompact.isNotEmpty) {
        return 'https://www.ixigo.com/search/result/flight?from=$origin&to=$destination&date=$dateDDMMYYYYcompact&returnDate=$returnDateDDMMYYYYcompact&adults=$adults&children=$children&infants=$infants&class=e';
      } else {
        return 'https://www.ixigo.com/search/result/flight?from=$origin&to=$destination&date=$dateDDMMYYYYcompact&returnDate=&adults=$adults&children=$children&infants=$infants&class=e';
      }
    },
  },
  {
    'id': 'paytm',
    'name': 'Paytm',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateYYYYMMDD = params['dateYYYYMMDD'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      return 'https://tickets.paytm.com/flights/flightSearch/${origin}-Jammu/${destination}/${adults}/${children}/${infants}/E/${dateYYYYMMDD}';
    },
  },
  {
    'id': 'yatra',
    'name': 'Yatra',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateDDMMYYYYslash = params['dateDDMMYYYYslash'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      final unqvalpwa = DateTime.now().millisecondsSinceEpoch.toString();
      return 'https://www.yatra.com/pwa/flights/srp?type=O&viewName=normal&flexi=0&noOfSegments=1&origin=$origin&originCountry=IN&destination=$destination&destinationCountry=IN&flight_depart_date=$dateDDMMYYYYslash&ADT=$adults&CHD=$children&INF=$infants&stops=0&class=Economy&source=fresco-home&unqvalpwa=$unqvalpwa';
    },
  },
  {
    'id': 'happyeasygo',
    'name': 'HappyEasyGo',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateYYYYMMDD = params['dateYYYYMMDD'] ?? '';
      final returnDateYYYYMMDD = params['returnDateYYYYMMDD'] ?? '';
      final tripType = params['tripType'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      if (tripType == 'roundtrip' && returnDateYYYYMMDD.isNotEmpty) {
        return 'https://www.happyeasygo.com/flights/${origin}-${destination}/${dateYYYYMMDD}?tripType=1&adults=${adults}&childs=${children}&baby=${infants}&cabinClass=Economy&returndate=${returnDateYYYYMMDD}';
      } else {
        return 'https://www.happyeasygo.com/flights/${origin}-${destination}/${dateYYYYMMDD}?tripType=0&adults=${adults}&childs=${children}&baby=${infants}&cabinClass=Economy';
      }
    },
  },
  {
    'id': 'happyfares',
    'name': 'HappyFares',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateDDMMYYYYdash = params['dateDDMMYYYYdash'] ?? '';
      final returnDateDDMMYYYYdash = params['returnDateDDMMYYYYdash'] ?? '';
      final tripType = params['tripType'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      final originCity = getCityForIata(origin, airports);
      final destinationCity = getCityForIata(destination, airports);
      final originName = Uri.encodeComponent(originCity.toLowerCase());
      final destinationName = Uri.encodeComponent(destinationCity.toLowerCase());
      final onward = dateDDMMYYYYdash;
      final returnParam = (tripType == 'roundtrip' && returnDateDDMMYYYYdash.isNotEmpty) ? returnDateDDMMYYYYdash : '';
      return 'https://www.happyfares.in/flights/origin=$origin&destination=$destination&onward=$onward&return=$returnParam&type=DOMESTIC&class=ECONOMY&adult=$adults&child=$children&infant=$infants&direct=&discount=&nocache=&defence=&originName=$originName&destinationName=$destinationName&BType=&student=&senior=&doctor=&ccode=IN';
    },
  },
  {
    'id': 'adani',
    'name': 'AdaniOne',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateDDMMYYYYcompact = params['dateDDMMYYYYcompact'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final infants = params['infants'] ?? '0';
      return 'https://www.adanione.com/flight/bookingV2/srp/ADLONE/D/O/ECO/${adults}_${children}_${infants}/${origin}-${destination}-${dateDDMMYYYYcompact}/REGF';
    },
  },
  {
    'id': 'agoda',
    'name': 'Agoda',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateYYYYMMDD = params['dateYYYYMMDD'] ?? '';
      final adults = params['adults'] ?? '1';
      return 'https://www.agoda.com/en-in/flights/results?departureFrom=${origin}&departureFromType=1&arrivalTo=${destination}&arrivalToType=1&departDate=${dateYYYYMMDD}&adults=${adults}&cabinType=Economy';
    },
  },
  {
    'id': 'booking',
    'name': 'Booking.com',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateYYYYMMDD = params['dateYYYY-MM-DD'] ?? params['dateYYYYMMDD'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final originCity = getCityForIata(origin, airports);
      final destinationCity = getCityForIata(destination, airports);
      final airportPath = '${origin}.AIRPORT-${destination}.AIRPORT';
      final from = '${origin}.AIRPORT';
      final to = '${destination}.AIRPORT';
      final fromCountry = 'IN';
      final toCountry = 'IN';
      final fromLocationName = Uri.encodeComponent(originCity.isNotEmpty ? originCity + ' Airport' : from);
      final toLocationName = Uri.encodeComponent(destinationCity.isNotEmpty ? destinationCity + ' Airport' : to);
      final depart = dateYYYYMMDD.replaceAll('/', '-');
      final childrenParam = (children == '0' || children == 0) ? '' : children;
      return 'https://flights.booking.com/flights/$airportPath/?type=ONEWAY&adults=$adults&cabinClass=ECONOMY&children=$childrenParam&from=$from&to=$to&fromCountry=$fromCountry&toCountry=$toCountry&fromLocationName=$fromLocationName&toLocationName=$toLocationName&depart=$depart&sort=BEST&travelPurpose=leisure&ca_source=flights_index_sb&aid=397656&label=duc511jc-1FCAEoggI46AdIM1gDaGyIAQKYATG4AQnIARHYAQHoAQH4AQOIAgGoAgO4AtKqmcMGwAIB0gIkZTU4MTc0ZGEtNTIxNC00ZDJiLWJhMTctMDA5NzJmN2NlZjg22AIF4AIB&adplat=mdot-index-web_shell_header-flight-missing_creative-2AuF7kicPhRuTqrSZv4PST';
    },
  },
  {
    'id': 'trip',
    'name': 'Trip.com',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = params['origin'] ?? '';
      final destination = params['destination'] ?? '';
      final dateYYYYMMDD = params['dateYYYYMMDD'] ?? '';
      final adults = params['adults'] ?? '1';
      return 'https://us.trip.com/flights/jammu-to-mumbai/tickets-${origin}-${destination}?dcity=${origin},${origin}&acity=${destination},${destination}&ddate=${dateYYYYMMDD}&flighttype=ow&class=E&quantity=${adults}';
    },
  },
  {
    'id': 'skyscanner',
    'name': 'Skyscanner',
    'buildSearchUrl': (
      Map<String, dynamic> params,
      List<Map<String, String>> airports,
    ) {
      final origin = (params['origin'] ?? '').toLowerCase();
      final destination = (params['destination'] ?? '').toLowerCase();
      final dateDDMMYY = params['dateDDMMYY'] ?? '';
      final adults = params['adults'] ?? '1';
      final children = params['children'] ?? '0';
      final childrenv2 = (children == '0' || children == 0) ? '' : children;
      return 'https://www.skyscanner.co.in/transport/flights/$origin/$destination/$dateDDMMYY/?adultsv2=$adults&cabinclass=economy&childrenv2=$childrenv2&ref=home&rtn=0&preferdirects=false&outboundaltsenabled=false&inboundaltsenabled=false';
    },
  },
];

class _CouponNotchPainter extends CustomPainter {
  final bool isLeft;
  _CouponNotchPainter({required this.isLeft});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    final radius = 8.0;
    final centerY = size.height / 2;
    if (isLeft) {
      canvas.drawCircle(Offset(0, centerY), radius, paint);
    } else {
      canvas.drawCircle(Offset(size.width, centerY), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    // Top
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    // Bottom
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
    // Left
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    // Right
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HorizontalDashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeCouponCard extends StatelessWidget {
  final FlightOffer offer;
  const HomeCouponCard({Key? key, required this.offer}) : super(key: key);

  // Add this helper at the top or inside the HomeCouponCard class:
  String formatValidityDate(String date) {
    if (date.isEmpty) return '';
    try {
      final d = DateTime.parse(date);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day.toString().padLeft(2, '0')}-${months[d.month - 1]}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = ((offer.savings) / 25000 * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1),
          width: 1.5,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Stack(
          children: [
            // Top right: Valid till
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: [
                  Text(
                    'Valid till: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: Color(0xFFF59E42),
                    ),
                  ),
                  Text(
                    formatValidityDate(offer.validityDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFFF59E42),
                    ),
                  ),
                ],
              ),
            ),
            // Main Row content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: 12, top: 4),
                  child: Image.asset(
                    logoMap[offer.websiteName.toLowerCase()] ?? logoMap[offer.websiteName] ?? 'assets/logos/${offer.websiteName.toLowerCase().replaceAll(' ', '')}.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.flight, color: Colors.orange, size: 32),
                  ),
                ),
                // Coupon content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Only show offer source (if any)
                          if (offer.offerSource.isNotEmpty)
                            Text(
                              offer.offerSource,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: Color(0xFFF59E42),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        offer.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFeef2ff),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Text(
                          offer.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFFF59E42),
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bottom row: Save upto on right
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            'Save upto $percent%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFFF59E42),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// Add this extension at the end of the file:
extension WidgetPaddingX on Widget {
  Widget withPadding([EdgeInsetsGeometry padding = const EdgeInsets.all(8)]) => Padding(padding: padding, child: this);
}
