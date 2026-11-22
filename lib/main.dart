
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/dc_bus_routes.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'app/navigation/app_bottom_navigation.dart';
import 'shared/widgets/responsive_content.dart';
import 'features/auth/presentation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (supabaseUrl.isNotEmpty &&
      supabasePublishableKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }

  runApp(const TaraCommuteApp());
}

class TaraCommuteApp extends StatelessWidget {
  const TaraCommuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Supabase.instance.isInitialized
          ? const AuthGate(
              authenticatedPage: MainShell(),
            )
          : const SupabaseSetupRequiredPage(),
    );
  }
}

// SUPABASE CONFIGURATION REQUIRED

class SupabaseSetupRequiredPage extends StatelessWidget {
  const SupabaseSetupRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: Colors.orange,
                ),
                SizedBox(height: 20),
                Text(
                  'TaraCommute Configuration Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Supabase is not configured. Please configure '
                  'the required application environment variables '
                  'before using TaraCommute.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MAIN APPLICATION SHELL

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedTab = 0;

  final List<Widget> pages = const [
    HomePage(),
    CommutePage(),
    ExplorePage(),
    TerminalsPage(),
    ReportsPage(),
  ];

  final List<String> titles = const [
    'TaraCommute',
    'Commute',
    'Nearby',
    'Terminals',
    'Advisories',
  ];

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selectedTab],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: openProfile,
            icon: const Icon(Icons.person_outline),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.tonalIcon(
              onPressed: () => showEmergencyDialog(context),
              icon: const Icon(
                Icons.emergency_outlined,
                color: Colors.red,
              ),
              label: const Text('Emergency'),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedTab,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: selectedTab,
        onTap: (value) {
          setState(() {
            selectedTab = value;
          });
        },
      ),
    );
  }
}

// EMERGENCY INFORMATION

void showEmergencyDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Emergency help'),
      content: const Text(
        'If someone is in immediate danger, call 911 now. '
        'TaraCommute has not contacted an emergency dispatch center. '
        'Do not approach an accident or dangerous area.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

// HOME PAGE

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final double mapHeight =
        (screenWidth * 0.55).clamp(220.0, 360.0).toDouble();

    return ResponsiveContent(
      maxWidth: 900,
      child: ListView(
        children: [
          const Text(
            'Asa ka padulong?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Find a way to get around Davao City.',
          ),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Where are you going?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: mapHeight,
            width: double.infinity,
            child: const DavaoMapPreview(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose your ride',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const TransportChoices(),
          const SizedBox(height: 16),
          const Text(
            'Map note: live traffic and live vehicle locations '
            'are not connected yet.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// DAVAO MAP PREVIEW

class DavaoMapPreview extends StatelessWidget {
  const DavaoMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(7.0731, 125.6128),
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.bueraglobal.taracommute',
          ),
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                '© OpenStreetMap contributors',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// TRANSPORT CHOICES

class TransportChoices extends StatelessWidget {
  const TransportChoices({super.key});

  @override
  Widget build(BuildContext context) {
    final choices = [
      ('Jeepney / Multicab', Icons.airport_shuttle_outlined),
      ('DC Bus [FREE]', Icons.directions_bus_outlined),
      ('Tricycle', Icons.electric_rickshaw_outlined),
      ('TNV / Motorcycle Taxi', Icons.motorcycle_outlined),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: choices
          .map(
            (choice) => Chip(
              avatar: Icon(
                choice.$2,
                size: 19,
              ),
              label: Text(choice.$1),
              padding: const EdgeInsets.all(8),
            ),
          )
          .toList(),
    );
  }
}

// COMMUTE PAGE

class CommutePage extends StatefulWidget {
  const CommutePage({super.key});

  @override
  State<CommutePage> createState() => _CommutePageState();
}

class _CommutePageState extends State<CommutePage> {
  String selectedRide = 'DC Bus [FREE]';
  String direction = 'AM';
  DcBusRoute selectedRoute = dcBusRoutes.first;

  @override
  Widget build(BuildContext context) {
    final stops = selectedRoute.stopsFor(direction);

    return ResponsiveContent(
      maxWidth: 900,
      child: ListView(
        children: [
          const Text(
            'Plan your trip',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.my_location),
              labelText: 'Where am I?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.place_outlined),
              labelText: 'Where are you going?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose your ride',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedRide,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Jeepney / Multicab',
                child: Text('Jeepney / Multicab'),
              ),
              DropdownMenuItem(
                value: 'DC Bus [FREE]',
                child: Text('DC Bus [FREE]'),
              ),
              DropdownMenuItem(
                value: 'Tricycle',
                child: Text('Tricycle'),
              ),
              DropdownMenuItem(
                value: 'TNV / Motorcycle Taxi',
                child: Text('TNV / Motorcycle Taxi'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedRide = value ?? selectedRide;
              });
            },
          ),
          if (selectedRide == 'DC Bus [FREE]') ...[
            const SizedBox(height: 18),
            const Text(
              'DC Bus routes',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Fare: FREE  •  Service times below are supplied schedule information.',
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<DcBusRoute>(
              value: selectedRoute,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Choose a route',
                border: OutlineInputBorder(),
              ),
              items: dcBusRoutes
                  .map(
                    (route) => DropdownMenuItem(
                      value: route,
                      child: Text(
                        '${route.code} — ${route.title}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoute = value ?? selectedRoute;
                });
              },
            ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'AM',
                  label: Text('AM direction'),
                ),
                ButtonSegment(
                  value: 'PM',
                  label: Text('PM direction'),
                ),
              ],
              selected: {direction},
              onSelectionChanged: (value) {
                setState(() {
                  direction = value.first;
                });
              },
            ),
            const SizedBox(height: 8),
            const Text(
              dcBusServiceHours,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${selectedRoute.code} — $direction stops',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...stops.asMap().entries.map(
                  (entry) => ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    title: Text(entry.value),
                    trailing:
                        entry.key == 0 || entry.key == stops.length - 1
                            ? const Icon(
                                Icons.flag_outlined,
                                color: Colors.green,
                              )
                            : null,
                  ),
                ),
            const Text(
              'These are stop names and order only. Map route lines '
              'and boarding guidance will be added after every stop '
              'is accurately located and checked.',
              style: TextStyle(
                color: Colors.deepOrange,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              '$selectedRide route details will appear when verified '
              'local route or provider information is connected.',
            ),
            if (selectedRide == 'TNV / Motorcycle Taxi')
              const Text(
                'Possible providers: Grab, Maxim and JoyRide. '
                'No booking or price quote is available in this starter version.',
              ),
          ],
        ],
      ),
    );
  }
}

// NEARBY PAGE

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Schools and colleges', Icons.school_outlined),
      (
        'Hospitals, clinics and pharmacies',
        Icons.local_hospital_outlined,
      ),
      ('Malls, shops and banks', Icons.storefront_outlined),
      ('Restaurants and daily needs', Icons.restaurant_outlined),
      (
        'Parks and government offices',
        Icons.account_balance_outlined,
      ),
      (
        'Police, fire and public services',
        Icons.local_police_outlined,
      ),
    ];

    return ResponsiveContent(
      maxWidth: 900,
      child: ListView(
        children: [
          const Text(
            'Find places around Davao City',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search a place or address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          for (final item in categories)
            Card(
              child: ListTile(
                leading: Icon(item.$2),
                title: Text(item.$1),
                subtitle: const Text(
                  'Directory entries will be added and checked before publication.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// TERMINALS PAGE

class TerminalsPage extends StatelessWidget {
  const TerminalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: 900,
      child: ListView(
        children: const [
          Text(
            'Transport terminals',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Find transport terminals and boarding locations around Davao City.',
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(Icons.directions_bus_outlined),
              title: Text('Terminal directory'),
              subtitle: Text(
                'Verified terminal locations and details will be added here.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ADVISORIES PAGE

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: 900,
      child: ListView(
        children: const [
          Text(
            'Road and traffic updates',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Report an accident, traffic, road closure, flood or road hazard.',
          ),
          SizedBox(height: 12),
          Text(
            'Community reports are not connected yet. '
            'Do not treat unverified reports as confirmed.',
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('No public reports yet'),
              subtitle: Text(
                'Report sending, review and duplicate grouping will be '
                'added with secure database support.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 // PROFILE PAGE

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final connected = Supabase.instance.isInitialized;

    final user = connected
        ? Supabase.instance.client.auth.currentUser
        : null;

    final metadataName = user?.userMetadata?['full_name'];

    final fullName = metadataName is String
        ? metadataName
        : null;

    final displayName =
        fullName != null && fullName.trim().isNotEmpty
            ? fullName
            : 'Your TaraCommute profile';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ResponsiveContent(
        maxWidth: 900,
        child: ListView(
          children: [
            const SizedBox(height: 12),
            const Center(
              child: CircleAvatar(
                radius: 34,
                child: Icon(
                  Icons.person,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (user?.email != null)
              Text(
                user!.email!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: const Text('Online database'),
                subtitle: Text(
                  connected
                      ? 'Supabase connection initialized'
                      : 'Starter mode — Supabase keys not added',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.bookmark_outline),
                title: Text('Saved trips'),
                subtitle: Text(
                  'Save your regular destinations in a future update.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.language_outlined),
                title: Text('Language'),
                subtitle: Text(
                  'Language preferences will be available here.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('Privacy and security'),
                subtitle: Text(
                  'Account privacy and security settings.',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
