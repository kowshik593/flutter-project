import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TreeProvider(),
      child: const TreeTrackerApp(),
    ),
  );
}

class Tree {
  final String species;
  final int count;
  final String location;
  Tree({required this.species, required this.count, required this.location});
}

// ---------- Provider version: state lives in a ChangeNotifier ----------
class TreeProvider extends ChangeNotifier {
  static const int goal = 50;
  final List<Tree> _trees = [];
  String _species = 'Neem';
  int _count = 1;

  List<Tree> get trees => List.unmodifiable(_trees);
  String get species => _species;
  int get count => _count;
  int get total => _trees.fold(0, (sum, t) => sum + t.count);
  double get progress => (total / goal).clamp(0.0, 1.0);

  void setSpecies(String value) {
    _species = value;
    notifyListeners();
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    if (_count > 1) {
      _count--;
      notifyListeners();
    }
  }

  void addTree(String location) {
    if (location.trim().isEmpty) return;
    _trees.insert(
        0, Tree(species: _species, count: _count, location: location.trim()));
    _count = 1;
    notifyListeners();
  }

  void removeTree(int index) {
    _trees.removeAt(index);
    notifyListeners();
  }
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

class TreeHomePage extends StatefulWidget {
  const TreeHomePage({super.key});

  @override
  State<TreeHomePage> createState() => _TreeHomePageState();
}

class _TreeHomePageState extends State<TreeHomePage> {
  final TextEditingController locationController = TextEditingController();

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TreeProvider>();
    final actions = context.read<TreeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tree Planting Tracker (Provider)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${state.total} of ${TreeProvider.goal} trees planted',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: state.progress, minHeight: 10),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.species,
            items: ['Neem', 'Mango', 'Banyan', 'Teak', 'Peepal']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => actions.setSpecies(v!),
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
                  icon: const Icon(Icons.remove), onPressed: actions.decrement),
              Text('${state.count}'),
              IconButton(
                  icon: const Icon(Icons.add), onPressed: actions.increment),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  actions.addTree(locationController.text);
                  locationController.clear();
                },
                icon: const Icon(Icons.park),
                label: const Text('Add Tree'),
              ),
            ],
          ),
          const Divider(),
          if (state.trees.isEmpty) const Text('No trees planted yet.'),
          for (int i = 0; i < state.trees.length; i++)
            ListTile(
              leading: const Icon(Icons.park, color: Colors.green),
              title: Text('${state.trees[i].species} x ${state.trees[i].count}'),
              subtitle: Text(state.trees[i].location),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => actions.removeTree(i),
              ),
            ),
        ],
      ),
    );
  }
}
