import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../app/theme/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.enabled,
  });

  final void Function(String text) onSend;
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                maxLines: null,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.cream,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: widget.enabled ? 'Message your coach…' : 'Thinking…',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onSubmitted: widget.enabled ? (_) => _submit() : null,
              ),
            ),
            const SizedBox(width: 10),
            _SendButton(onTap: widget.enabled ? _submit : null),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatefulWidget {
  const _SendButton({this.onTap});
  final VoidCallback? onTap;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _ctrl.reverse() : null,
        onTapUp: enabled
            ? (_) {
                _ctrl.forward();
                widget.onTap?.call();
              }
            : null,
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: enabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.gold, AppColors.goldDim],
                  )
                : null,
            color: enabled ? null : AppColors.surfaceRaised,
          ),
          child: Icon(
            Icons.arrow_upward_rounded,
            size: 20,
            color: enabled ? AppColors.bg : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}
