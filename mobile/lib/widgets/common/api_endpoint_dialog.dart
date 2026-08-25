import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';
import 'status_badge.dart';

class ApiEndpointDialog extends StatefulWidget {
  const ApiEndpointDialog({super.key});

  @override
  State<ApiEndpointDialog> createState() => _ApiEndpointDialogState();
}

class _ApiEndpointDialogState extends State<ApiEndpointDialog> {
  late TextEditingController _controller;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    final currentUrl = context.read<SimulationController>().customApiUrl;
    _controller = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      title: Row(
        children: [
          Icon(Icons.hub_outlined, color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy, size: 20),
          const SizedBox(width: 8),
          Text(
            'Backend API Endpoint',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set the URL of the Express backend simulation server. Defaults to 10.0.2.2:5000 for Android emulator or localhost:5000 for local.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.neutral.withValues(alpha: 0.9) : AppTheme.neutral,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                labelText: 'Backend URL',
                hintText: 'http://10.0.2.2:5000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Current status: ', style: TextStyle(fontSize: 11, color: AppTheme.neutral)),
                StatusBadge.forConnection(controller.connectionState),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _controller.text = ApiConfig.getDefaultBaseUrl();
          },
          child: const Text('Reset Default', style: TextStyle(fontSize: 12, color: AppTheme.neutral)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy),
          ),
        ),
        ElevatedButton(
          onPressed: _testing
              ? null
              : () async {
                  setState(() => _testing = true);
                  await controller.setCustomApiUrl(_controller.text.trim());
                  if (!context.mounted) return;
                  setState(() => _testing = false);
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
            foregroundColor: isDark ? AppTheme.primaryNavy : AppTheme.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: _testing
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save & Connect', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
