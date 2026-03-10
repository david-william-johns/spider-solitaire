import 'package:flutter/material.dart';

class ToolbarWidget extends StatelessWidget {
  final bool canUndo;
  final VoidCallback onSettings;
  final VoidCallback onNewGame;
  final VoidCallback onHint;
  final VoidCallback onUndo;

  const ToolbarWidget({
    super.key,
    required this.canUndo,
    required this.onSettings,
    required this.onNewGame,
    required this.onHint,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolButton(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: onSettings,
          ),
          _ToolButton(
            icon: Icons.grid_view_rounded,
            label: 'Games',
            onTap: onNewGame,
          ),
          _ToolButton(
            icon: Icons.play_circle_outline,
            label: 'Play',
            onTap: onNewGame,
          ),
          _ToolButton(
            icon: Icons.lightbulb_outline,
            label: 'Hint',
            onTap: onHint,
          ),
          _ToolButton(
            icon: Icons.undo,
            label: 'Undo',
            onTap: canUndo ? onUndo : null,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: enabled ? Colors.white : Colors.white38,
              size: 24,
            ),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white70 : Colors.white24,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
