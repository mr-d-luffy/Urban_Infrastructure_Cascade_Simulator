import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '../../config/app_theme.dart';
import '../../providers/simulation_controller.dart';
import 'graph_painter.dart';
import 'service_details_sheet.dart';
import 'service_node_widget.dart';

class InteractiveGraphView extends StatefulWidget {
  const InteractiveGraphView({super.key});

  @override
  State<InteractiveGraphView> createState() => _InteractiveGraphViewState();
}

class _InteractiveGraphViewState extends State<InteractiveGraphView> with SingleTickerProviderStateMixin {
  final TransformationController _transController = TransformationController();
  late AnimationController _pulseController;

  static const double canvasWidth = 860.0;
  static const double canvasHeight = 620.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();

    // Initial centering on canvas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitToView();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transController.dispose();
    super.dispose();
  }

  void _fitToView() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final viewWidth = renderBox.size.width;
    final viewHeight = renderBox.size.height;

    final scaleX = (viewWidth - 32) / canvasWidth;
    final scaleY = (viewHeight - 32) / canvasHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (viewWidth - canvasWidth * scale) / 2;
    final offsetY = (viewHeight - canvasHeight * scale) / 2;

    _transController.value = Matrix4.identity()
      ..translateByVector3(Vector3(offsetX, offsetY, 0.0))
      ..scaleByVector3(Vector3(scale, scale, 1.0));
  }

  void _zoomIn() {
    final matrix = _transController.value.clone();
    matrix.scaleByVector3(Vector3(1.2, 1.2, 1.0));
    _transController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transController.value.clone();
    matrix.scaleByVector3(Vector3(0.833, 0.833, 1.0));
    _transController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimulationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface.withValues(alpha: 0.4) : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Interactive Pan & Zoom Canvas
            InteractiveViewer(
              transformationController: _transController,
              boundaryMargin: const EdgeInsets.all(300),
              minScale: 0.3,
              maxScale: 2.2,
              constrained: false,
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: Stack(
                  children: [
                    // Dependency Lines and Background Dots
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: GraphPainter(
                              services: controller.services,
                              dependencies: controller.dependencies,
                              selectedId: controller.selectedId,
                              activeEdgeIds: controller.activeEdgeIds,
                              isDark: isDark,
                              pulseProgress: _pulseController.value,
                            ),
                          );
                        },
                      ),
                    ),

                    // Nodes Placed at Fixed Positions
                    ...controller.services.map((service) {
                      final isSelected = controller.selectedId == service.id;
                      return Positioned(
                        left: service.position.dx,
                        top: service.position.dy,
                        child: ServiceNodeWidget(
                          service: service,
                          isSelected: isSelected,
                          onTap: () {
                            controller.selectService(service.id);
                            ServiceDetailsSheet.show(
                              context,
                              service: service,
                              upstream: controller.upstreamServices,
                              downstream: controller.downstreamServices,
                              onSelectService: (id) {
                                controller.selectService(id);
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Floating Graph Toolbar
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkSurface : AppTheme.lightSurface).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _toolbarButton(Icons.zoom_in, 'Zoom In', _zoomIn, isDark),
                    _toolbarButton(Icons.zoom_out, 'Zoom Out', _zoomOut, isDark),
                    _toolbarButton(Icons.center_focus_strong, 'Fit View', _fitToView, isDark),
                  ],
                ),
              ),
            ),

            // Hint label at bottom left
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkSurface : AppTheme.lightSurface).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                child: Text(
                  'Pan & zoom canvas · Tap node to inspect',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? AppTheme.neutral.withValues(alpha: 0.8) : AppTheme.neutral,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon, String tooltip, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? AppTheme.pureWhite : AppTheme.primaryNavy,
        ),
      ),
    );
  }
}
