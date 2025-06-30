import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final preferencesProvider = StateProvider<List<String>>((ref) => []);

const allPreferences = [
  'Fiction',
  'Non-fiction',
  'Mystery',
  'Sci-Fi',
  'Fantasy',
  'Biography',
  'Self-help',
  'Comics',
];

class PreferencesUpdateScreen extends ConsumerWidget {
  const PreferencesUpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(preferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Preferences')),
      body: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: allPreferences.map((pref) {
            final isSelected = selected.contains(pref);
            return ChoiceChip(
              label: Text(pref),
              selected: isSelected,
              selectedColor: const Color(0xFF2ECC71).withOpacity(0.8),
              onSelected: (val) {
                final updated = List<String>.from(selected);
                if (val) {
                  updated.add(pref);
                } else {
                  updated.remove(pref);
                }
                ref.read(preferencesProvider.notifier).state = updated;
                // TODO: Optionally update repository here
              },
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selected.isNotEmpty
            ? () {
          // TODO: Save preferences to repository/state
          Navigator.of(context).pushReplacementNamed('/home');
        }
            : null,
        label: const Text('Continue'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}