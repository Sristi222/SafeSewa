import 'package:flutter/material.dart';

class DisasterPreventionPage extends StatefulWidget {
  const DisasterPreventionPage({super.key});

  @override
  State<DisasterPreventionPage> createState() => _DisasterPreventionPageState();
}

class _DisasterPreventionPageState extends State<DisasterPreventionPage> {
  final List<Map<String, String>> disasters = [
    {
      'title': 'Fire',
      'image': 'assets/Fire.png', // Replace with your own asset
      'precaution':
          '• Install smoke detectors\n• Avoid overloading sockets\n• Keep extinguishers ready',
      'response':
          '• Call fire services\n• Evacuate calmly\n• Don’t use elevators\n• Stop, drop, and roll if clothes catch fire',
    },
    {
      'title': 'Earthquake',
      'image': 'assets/earthquake.png',
      'precaution':
          '• Secure furniture\n• Prepare emergency kit\n• Know safe spots in rooms',
      'response':
          '• Stay under sturdy shelter\n• Avoid windows\n• Check for injuries and aftershocks',
    },
    {
      'title': 'Flood',
      'image': 'assets/flood.png',
      'precaution':
          '• Move valuables to high ground\n• Prepare food and water\n• Stay informed with alerts',
      'response':
          '• Avoid floodwater\n• Do not use wet electronics\n• Disinfect wet items',
    },
    {
      'title': 'Landslide',
      'image': 'assets/landslide.png',
      'precaution':
          '• Avoid steep slopes\n• Stay alert during heavy rains\n• Identify safe evacuation areas',
      'response':
          '• Stay away from slide area\n• Report broken utilities\n• Help others',
    },
  ];

  List<Map<String, String>> filteredDisasters = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredDisasters = disasters;
  }

  void _filter(String query) {
    setState(() {
      searchQuery = query;
      filteredDisasters = disasters
          .where((item) =>
              item['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showDetails(BuildContext context, Map<String, String> disaster) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(disaster['title']!, textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Precautions Before:', style: sectionTitle),
              const SizedBox(height: 4),
              Text(disaster['precaution']!),
              const SizedBox(height: 12),
              Text('🚨 What to Do After:', style: sectionTitle),
              const SizedBox(height: 4),
              Text(disaster['response']!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  TextStyle get sectionTitle =>
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disaster Prevention"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Box
            TextField(
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: "Search disaster...",
                prefixIcon: const Icon(Icons.menu),
                suffixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grid
            Expanded(
              child: GridView.builder(
                itemCount: filteredDisasters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final disaster = filteredDisasters[index];
                  return GestureDetector(
                    onTap: () => _showDetails(context, disaster),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(disaster['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          disaster['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
