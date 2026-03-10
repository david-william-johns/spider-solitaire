import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../providers/settings_provider.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Number of Suits
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Number of Suits', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            _SuitSelector(
              current: settings.suitCount,
              onChanged: notifier.setSuitCount,
            ),
            const SizedBox(height: 16),

            // Winnable Deals
            _SettingsRow(
              label: 'Winnable Deals',
              description: 'Only deal solvable games',
              trailing: Switch(
                value: settings.winnableDeals,
                onChanged: notifier.setWinnableDeals,
              ),
            ),
            const Divider(height: 1),

            // Dark Mode
            _SettingsRow(
              label: 'Dark Mode',
              trailing: Switch(
                value: settings.darkMode,
                onChanged: notifier.setDarkMode,
              ),
            ),
            const Divider(height: 1),

            // Sound
            _SettingsRow(
              label: 'Sound Effects',
              trailing: Switch(
                value: settings.soundEnabled,
                onChanged: notifier.setSoundEnabled,
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuitSelector extends StatelessWidget {
  final SuitCount current;
  final void Function(SuitCount) onChanged;

  const _SuitSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: SuitCount.values.map((s) {
        final selected = s == current;
        return GestureDetector(
          onTap: () => onChanged(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2196F3) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected ? const Color(0xFF1565C0) : Colors.grey.shade400,
              ),
            ),
            child: Center(
              child: Text(
                s.label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? description;
  final Widget trailing;

  const _SettingsRow({
    required this.label,
    this.description,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 15)),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

void showSettingsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) => const SettingsDialog(),
  );
}
