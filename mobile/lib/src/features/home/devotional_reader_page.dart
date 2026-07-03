import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/devotional_models.dart';
import 'content_cards.dart';
import 'retention_support.dart';

class DevotionalReaderPage extends StatefulWidget {
  const DevotionalReaderPage({
    required this.devotional,
    required this.streak,
    required this.onComplete,
    super.key,
  });

  final DevotionalCardModel devotional;
  final StreakModel streak;
  final Future<DevotionalCompletionResultModel?> Function()? onComplete;

  @override
  State<DevotionalReaderPage> createState() => _DevotionalReaderPageState();
}

class _DevotionalReaderPageState extends State<DevotionalReaderPage> {
  bool _immersiveMode = false;

  void _toggleImmersive() {
    setState(() {
      _immersiveMode = !_immersiveMode;
    });
    if (_immersiveMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextMilestone = RetentionSupport.nextMilestone(widget.streak.currentStreak);
    
    return Scaffold(
      appBar: _immersiveMode
          ? null
          : AppBar(
              title: const Text('Leitura'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Modo Imersivo',
                  onPressed: _toggleImmersive,
                ),
              ],
            ),
      floatingActionButton: _immersiveMode
          ? FloatingActionButton.small(
              backgroundColor: Colors.white.withOpacity(0.8),
              onPressed: _toggleImmersive,
              child: const Icon(Icons.fullscreen_exit, color: Colors.black87),
            )
          : null,
      body: GestureDetector(
        onDoubleTap: _toggleImmersive,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            Text(
              widget.devotional.date,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B6F56),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.devotional.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF382315),
                    height: 1.2,
                  ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: _immersiveMode ? const EdgeInsets.all(0) : const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _immersiveMode ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _immersiveMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Text(
                widget.devotional.content,
                style: GoogleFonts.lora(
                  fontSize: 18,
                  height: 1.8,
                  color: const Color(0xFF2C241B),
                ),
              ),
            ),
            if (!_immersiveMode) ...[
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Streak atual',
                      value: '${widget.streak.currentStreak}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: 'Melhor streak',
                      value: '${widget.streak.longestStreak}',
                    ),
                  ),
                ],
              ),
              if (nextMilestone != null) ...[
                const SizedBox(height: 16),
                MilestoneBanner(
                  currentStreak: widget.streak.currentStreak,
                  nextMilestone: nextMilestone,
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: widget.onComplete == null
                    ? null
                    : () async {
                        await widget.onComplete!.call();
                      },
                child: Text(
                  widget.onComplete == null ? 'Concluido hoje' : 'Concluir leitura',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
               const SizedBox(height: 80), // Espaço extra no fim do modo imersivo
            ]
          ],
        ),
      ),
    );
  }
}
