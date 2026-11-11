import 'package:flutter/material.dart';

void main() {
  runApp(const TreeTrackerApp());
}

class Tree {
  final String species;
  final int count;
  final String location;
  Tree({required this.species, required this.count, required this.location});
}

class TreeTrackerApp extends StatelessWidget {
  const TreeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tree Planting Tracker',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const TreeHomePage(),
    );
  }
}

// ---------- setState version ----------
class TreeHomePage extends StatefulWidget {
  const TreeHomePage({super.key});

  @override
  State<TreeHomePage> createState() => _TreeHomePageState();
}

class _TreeHomePageState extends State<TreeHomePage> {
  static const int goal = 50;
  final TextEditingController locationController = TextEditingController();
  final List<Tree> trees = [];
  String species = 'Neem';
  int count = 1;

  int get total => trees.fold(0, (sum, t) => sum + t.count);

  void addTree() {
    if (locationController.text.trim().isEmpty) return;
    setState(() {
      trees.insert(
        0,
        Tree(
          species: species,
          count: count,
          location: locationController.text.trim(),
        ),
      );
      locationController.clear();
      count = 1;
    });
  }

  void removeTree(int index) {
    setState(() => trees.removeAt(index));
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (total / goal).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('Tree Planting Tracker (setState)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('$total of $goal trees planted',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, minHeight: 10),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: species,
            items: ['Neem', 'Mango', 'Banyan', 'Teak', 'Peepal']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => species = v!),
            decoration: const InputDecoration(labelText: 'Tree species'),
          ),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          Row(
            children: [
              const Text('Count'),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => setState(() {
                  if (count > 1) count--;
                }),
              ),
              Text('$count'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => count++),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: addTree,
                icon: const Icon(Icons.park),
                label: const Text('Add Tree'),
              ),
            ],
          ),
          const Divider(),
          if (trees.isEmpty) const Text('No trees planted yet.'),
          for (int i = 0; i < trees.length; i++)
            ListTile(
              leading: const Icon(Icons.park, color: Colors.green),
              title: Text('${trees[i].species} x ${trees[i].count}'),
              subtitle: Text(trees[i].location),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => removeTree(i),
              ),
            ),
        ],
      ),
    );
  }
}
