import 'package:flutter/material.dart';

import '../../core/session/app_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/player.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_container.dart';
import 'local_add_questions_screen.dart';

class LocalPlayersScreen extends StatefulWidget {
  const LocalPlayersScreen({super.key});

  @override
  State<LocalPlayersScreen> createState() => _LocalPlayersScreenState();
}

class _LocalPlayersScreenState extends State<LocalPlayersScreen> {
  final AppSession _session = AppSession.instance;
  final TextEditingController _controller = TextEditingController();

  final List<Color> _colors = const [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
    Color(0xFFFDCB6E),
  ];

  @override
  void initState() {
    super.initState();
    _session.resetAll();
  }

  void _addPlayer() {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    _session.addPlayer(
      Player(
        id: 'player_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        color: _colors[_session.players.length % _colors.length],
      ),
    );

    _controller.clear();
    setState(() {});
  }

  void _removePlayer(Player player) {
    _session.removePlayer(player.id);
    setState(() {});
  }

  void _continue() {
    if (_session.players.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocalAddQuestionsScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الوضع المحلي'),
      ),
      body: Stack(
        children: [
          const LiquidBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  LiquidGlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: AppTextStyles.bodyLarge,
                            decoration: const InputDecoration(
                              hintText: 'اسم اللاعب',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _addPlayer(),
                          ),
                        ),
                        IconButton(
                          onPressed: _addPlayer,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _session.players.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final player = _session.players[index];

                        return LiquidGlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: player.color.withOpacity(0.25),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removePlayer(player),
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _session.players.isEmpty ? null : _continue,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('متابعة (${_session.players.length} لاعبين)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
