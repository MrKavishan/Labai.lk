import 'package:flutter/material.dart';

void main() {
  runApp(const TrainTrackerApp());
}

class TrainTrackerApp extends StatelessWidget {
  const TrainTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Train Tracker',
      theme: ThemeData(
        primaryColor: Colors.amber[700],
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.amber,
          accentColor: Colors.amberAccent,
        ),
      ),
      home: const TrainTrackingScreen(),
    );
  }
}

class TrainTrackingScreen extends StatefulWidget {
  const TrainTrackingScreen({Key? key}) : super(key: key);

  @override
  _TrainTrackingScreenState createState() => _TrainTrackingScreenState();
}

class _TrainTrackingScreenState extends State<TrainTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<String> stations = ["Station A", "Station B", "Station C", "Station D", "Final Destination"];
  int currentStationIndex = 1;
  double progress = 0.4;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Main UI Builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber.shade50, Colors.orange.shade50],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(), // App Bar UI
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSearchSection(), // Search section for station input
                      const SizedBox(height: 24),
                      _buildJourneyTimeline(), // Journey timeline with progress
                      const SizedBox(height: 24),
                      _buildJourneyStats(), // Stats on journey time and distance
                      const SizedBox(height: 24),
                      _buildMapButton(), // Button to track the train on the map
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // App Bar UI
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.amber[700],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Live Train Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[700]!, Colors.amber[600]!],
            ),
          ),
        ),
      ),
    );
  }

  // Search UI Section for stations
  Widget _buildSearchSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField("From Station", Icons.train),
            const SizedBox(height: 16),
            _buildSearchField("To Station", Icons.location_on),
          ],
        ),
      ),
    );
  }

  // Search Field Component (For From Station & To Station)
  Widget _buildSearchField(String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.amber[700]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // Journey Timeline UI
  Widget _buildJourneyTimeline() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(stations.length, (index) {
            bool isCurrentStation = index == currentStationIndex;
            bool isPastStation = index < currentStationIndex;
            
            return Column(
              children: [
                Row(
                  children: [
                    _buildTimelineNode(isCurrentStation, isPastStation),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stations[index],
                            style: TextStyle(
                              fontWeight: isCurrentStation ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          if (isCurrentStation) _buildCurrentStationIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index < stations.length - 1) _buildTimelineConnector(isPastStation),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Timeline Node (Circle indicator for each station)
  Widget _buildTimelineNode(bool isCurrent, bool isPast) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCurrent ? Colors.amber[700] : isPast ? Colors.green : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: isCurrent
          ? AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber[700]!.withOpacity(0.5),
                      width: 4 * _animationController.value,
                    ),
                  ),
                );
              },
            )
          : Icon(
              isPast ? Icons.check : Icons.circle,
              size: 12,
              color: Colors.white,
            ),
    );
  }

  // Timeline Connector (Line between stations)
  Widget _buildTimelineConnector(bool isPast) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      width: 2,
      height: 32,
      color: isPast ? Colors.green : Colors.grey[300],
    );
  }

  // Current Station Indicator (ETA display)
  Widget _buildCurrentStationIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: Colors.amber[700]),
          const SizedBox(width: 4),
          Text(
            'Arriving in 5 mins',
            style: TextStyle(
              color: Colors.amber[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Stats for Time to Destination & Distance Remaining
  Widget _buildJourneyStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Time to Destination', '1h 30m', Icons.timer),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Distance Remaining', '50 km', Icons.directions_train),
        ),
      ],
    );
  }

  // Stats Card UI (for Journey Time and Distance)
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.amber[700], size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Button to track on map (Currently Placeholder)
  Widget _buildMapButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement map view, fetch train route data from an API
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[700],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.map),
          SizedBox(width: 8),
          Text('Track on Map'),
        ],
      ),
    );
  }

  // Here you can make API calls to fetch data like stations, journey details, and real-time updates.
  // For example:
  // Future<void> fetchJourneyDetails() async {
  //   final response = await http.get(Uri.parse('YOUR_API_URL'));
  //   if (response.statusCode == 200) {
  //     // Parse the data and update state
  //   } else {
  //     throw Exception('Failed to load journey details');
  //   }
  // }
}
