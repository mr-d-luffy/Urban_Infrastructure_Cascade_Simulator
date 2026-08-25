import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/scenario_model.dart';
import '../../providers/simulation_controller.dart';
import '../common/cinematic_button.dart';

class ScenarioManagerCard extends StatefulWidget {
  const ScenarioManagerCard({super.key});

  @override
  State<ScenarioManagerCard> createState() => _ScenarioManagerCardState();
}

class _ScenarioManagerCardState extends State<ScenarioManagerCard> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    final controller = context.read<SimulationController>();
    await controller.saveScenario(name);
    _nameController.clear();
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = controller.status == 'RUNNING';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SAVED SCENARIOS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
            ),
          ),

          const SizedBox(height: 12),

          // Save current disruption selection row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  enabled: !isRunning && !_isSaving,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Scenario name',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.4),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CinematicButton(
                label: 'Save',
                icon: Icons.add,
                style: CinematicButtonStyle.secondary,
                isLoading: _isSaving,
                onPressed: isRunning || controller.disruptions.isEmpty ? null : _handleSave,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Scenario List
          if (controller.isLoadingScenarios)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                  ),
                ),
              ),
            )
          else if (controller.scenarios.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No saved scenarios yet. Select disruptions above and save to create one.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.scenarios.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final scenario = controller.scenarios[index];
                return _scenarioTile(scenario, controller, isDark, isRunning);
              },
            ),
        ],
      ),
    );
  }

  Widget _scenarioTile(
    ScenarioModel scenario,
    SimulationController controller,
    bool isDark,
    bool isRunning,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.pureWhite : AppTheme.primaryNavy).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  scenario.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
                  ),
                ),
              ),
              Text(
                '${scenario.disruptions.length} disruptions',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppTheme.neutral.withValues(alpha: 0.7) : AppTheme.neutral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionLink(
                icon: Icons.play_arrow,
                label: 'Load',
                onTap: isRunning ? null : () => controller.loadScenario(scenario),
                color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
              ),
              const SizedBox(width: 12),
              _actionLink(
                icon: Icons.copy,
                label: 'Copy',
                onTap: isRunning ? null : () => controller.duplicateScenario(scenario),
                color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
              ),
              const SizedBox(width: 12),
              _actionLink(
                icon: Icons.delete_outline,
                label: 'Delete',
                onTap: isRunning ? null : () => controller.deleteScenario(scenario.id),
                color: AppTheme.critical,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionLink({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: onTap == null ? color.withValues(alpha: 0.3) : color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: onTap == null ? color.withValues(alpha: 0.3) : color,
            ),
          ),
        ],
      ),
    );
  }
}
