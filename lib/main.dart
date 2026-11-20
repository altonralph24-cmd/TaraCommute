import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/dc_bus_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  

const supabaseUrl =
    String.fromEnvironment('SUPABASE_URL');

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
      title: 'TaraCommute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F5B)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedTab = 0;

  final pages = const [
    HomePage(),
    CommutePage(),
    ExplorePage(),
    ReportsPage(),
    ProfilePage(),
  ];

  final titles = const ['TaraCommute', 'Commute', 'Explore', 'Reports / Activity', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedTab], style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.tonalIcon(
              onPressed: () => showEmergencyDialog(context),
              icon: const Icon(Icons.emergency_outlined, color: Colors.red),
              label: const Text('Emergency'),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: selectedTab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (value) => setState(() => selectedTab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.directions_bus_outlined), selectedIcon: Icon(Icons.directions_bus), label: 'Commute'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Asa ka padulong?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Find a way to get around Davao City.'),
        const SizedBox(height: 14),
        const TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Where are you going?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        const SizedBox(height: 280, child: DavaoMapPreview()),
        const SizedBox(height: 12),
        const Text('Choose your ride', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const TransportChoices(),
        const SizedBox(height: 12),
        const Text('Map note: live traffic and live vehicle locations are not connected yet.',
            style: TextStyle(color: Colors.black54)),
      ],
    );
  }
}

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
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.bueraglobal.taracommute',
          ),
          const RichAttributionWidget(
            attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
          ),
        ],
      ),
    );
  }
}

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
      children: choices.map((choice) => Chip(
        avatar: Icon(choice.$2, size: 19),
        label: Text(choice.$1),
        padding: const EdgeInsets.all(8),
      )).toList(),
    );
  }
}

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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Plan your trip', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.my_location), labelText: 'Where am I?', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.place_outlined), labelText: 'Where are you going?', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        const Text('Choose your ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedRide,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'Jeepney / Multicab', child: Text('Jeepney / Multicab')),
            DropdownMenuItem(value: 'DC Bus [FREE]', child: Text('DC Bus [FREE]')),
            DropdownMenuItem(value: 'Tricycle', child: Text('Tricycle')),
            DropdownMenuItem(value: 'TNV / Motorcycle Taxi', child: Text('TNV / Motorcycle Taxi')),
          ],
          onChanged: (value) => setState(() => selectedRide = value ?? selectedRide),
        ),
        if (selectedRide == 'DC Bus [FREE]') ...[
          const SizedBox(height: 18),
          const Text('DC Bus routes', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const Text('Fare: FREE  •  Service times below are supplied schedule information.'),
          const SizedBox(height: 8),
          DropdownButtonFormField<DcBusRoute>(
            value: selectedRoute,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Choose a route', border: OutlineInputBorder()),
            items: dcBusRoutes.map((route) => DropdownMenuItem(
              value: route,
              child: Text('${route.code} — ${route.title}', overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (value) => setState(() => selectedRoute = value ?? selectedRoute),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'AM', label: Text('AM direction')),
              ButtonSegment(value: 'PM', label: Text('PM direction')),
            ],
            selected: {direction},
            onSelectionChanged: (value) => setState(() => direction = value.first),
          ),
          const SizedBox(height: 8),
          const Text(
  dcBusServiceHours,
  style: TextStyle(color: Colors.black54),
),
          const SizedBox(height: 12),
          Text('${selectedRoute.code} — $direction stops', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...stops.asMap().entries.map((entry) => ListTile(
            dense: true,
            leading: CircleAvatar(radius: 14, child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12))),
            title: Text(entry.value),
            trailing: entry.key == 0 || entry.key == stops.length - 1
                ? const Icon(Icons.flag_outlined, color: Colors.green)
                : null,
          )),
          const Text(
            'These are stop names and order only. Map route lines and boarding guidance will be added after every stop is accurately located and checked.',
            style: TextStyle(color: Colors.deepOrange),
          ),
        ] else ...[
          const SizedBox(height: 16),
          Text('$selectedRide route details will appear when verified local route or provider information is connected.'),
          if (selectedRide == 'TNV / Motorcycle Taxi')
            const Text('Possible providers: Grab, Maxim and JoyRide. No booking or price quote is available in this starter version.'),
        ],
      ],
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Find places around Davao City', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search a place or address', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        for (final item in [
          ('Schools and colleges', Icons.school_outlined),
          ('Hospitals, clinics and pharmacies', Icons.local_hospital_outlined),
          ('Malls, shops and banks', Icons.storefront_outlined),
          ('Restaurants and daily needs', Icons.restaurant_outlined),
          ('Parks and government offices', Icons.account_balance_outlined),
          ('Police, fire and public services', Icons.local_police_outlined),
        ])
          Card(child: ListTile(leading: Icon(item.$2), title: Text(item.$1), subtitle: const Text('Directory entries will be added and checked before publication.'))),
      ],
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Road and traffic updates', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Report an accident, traffic, road closure, flood or road hazard.'),
        SizedBox(height: 12),
        Text('Community reports are not connected yet. Do not treat unverified reports as confirmed.'),
        SizedBox(height: 12),
        Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('No public reports yet'), subtitle: Text('Report sending, review and duplicate grouping will be added with secure database support.'))),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final connected = Supabase.instance.isInitialized;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)),
        const SizedBox(height: 12),
        const Text('Your TaraCommute profile', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(child: ListTile(leading: const Icon(Icons.cloud_outlined), title: const Text('Online database'), subtitle: Text(connected ? 'Supabase connection initialized' : 'Starter mode — Supabase keys not added'))),
        const Card(child: ListTile(leading: Icon(Icons.bookmark_outline), title: Text('Saved trips'), subtitle: Text('Coming in a later development step'))),
        const Card(child: ListTile(leading: Icon(Icons.language), title: Text('Language'), subtitle: Text('English / Filipino support will be added'))),
        const Card(child: ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text('Privacy and terms'), subtitle: Text('Privacy notice and terms must be completed before public launch'))),
      ],
    );
  }
}
