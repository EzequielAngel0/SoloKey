import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_palette.dart';

/// A secure, on-screen keyboard widget for entering sensitive text.
///
/// Security properties:
/// - Each character group (lowercase, uppercase, digits, symbols) is
///   **scrambled** independently on every session start to defeat UI
///   automation and visual keyloggers.
/// - Never exposes the entered value as a readable String until confirmed.
///   Internally stores characters in a [List<String>] buffer that is zeroed
///   on dispose.
/// - Disables predictive text, autocorrect, and keyboard suggestions.
///
/// UX improvements over the flat layout:
/// - Split into 4 tabs: a-z · A-Z · 0-9 · !@# (symbols)
/// - Each tab shows at most 10 keys per row (comfortable tap targets ≥46 px).
/// - Tab bar stays visible at all times so the user always knows where they are.
///
/// Usage:
/// ```dart
/// SecureKeyboard(
///   onComplete: (value) { /* handle secure input */ },
///   mode: SecureKeyboardMode.password,
/// )
/// ```
class SecureKeyboard extends StatefulWidget {
  const SecureKeyboard({
    super.key,
    required this.onComplete,
    this.onCancel,
    this.mode = SecureKeyboardMode.password,
    this.maxLength = 64,
    this.hintText = 'Ingresa tu contraseña',
    this.confirmLabel = 'Confirmar',
  });

  /// Called when the user taps Confirm with the entered text.
  final ValueChanged<String> onComplete;

  /// Called when the user taps Cancel/X.
  final VoidCallback? onCancel;

  /// [SecureKeyboardMode.password] — input masked with dots.
  /// [SecureKeyboardMode.text]     — input visible.
  final SecureKeyboardMode mode;

  /// Maximum number of characters allowed.
  final int maxLength;

  final String hintText;
  final String confirmLabel;

  @override
  State<SecureKeyboard> createState() => _SecureKeyboardState();
}

// ── Character groups ──────────────────────────────────────────────────────────

const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _digits = '0123456789';
const _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?/`~\\\'"';

enum _Tab { lower, upper, digits, symbols }

// ── State ─────────────────────────────────────────────────────────────────────

class _SecureKeyboardState extends State<SecureKeyboard>
    with SingleTickerProviderStateMixin {
  // Internal buffer — never exposes a String directly
  final List<String> _buffer = [];
  bool _showInput = false;
  _Tab _activeTab = _Tab.lower;

  // Scrambled layouts per tab — generated once per session
  late final Map<_Tab, List<String>> _layouts;

  late final AnimationController _feedbackController;
  String? _lastPressedKey;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _layouts = _buildLayouts();
  }

  @override
  void dispose() {
    // Zero the buffer on dispose — security hygiene
    for (var i = 0; i < _buffer.length; i++) {
      _buffer[i] = '\x00';
    }
    _buffer.clear();
    _feedbackController.dispose();
    super.dispose();
  }

  /// Shuffles each character group independently.
  Map<_Tab, List<String>> _buildLayouts() {
    List<String> shuffle(String src) {
      final chars = src.split('');
      chars.shuffle(Random.secure());
      return chars;
    }

    return {
      _Tab.lower: shuffle(_lowercase),
      _Tab.upper: shuffle(_uppercase),
      _Tab.digits: shuffle(_digits),
      _Tab.symbols: shuffle(_symbols),
    };
  }

  // ── Input handling ─────────────────────────────────────────────────────────

  void _onKey(String key) {
    if (_buffer.length >= widget.maxLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _buffer.add(key);
      _lastPressedKey = key;
    });
    _feedbackController.forward(from: 0);
  }

  void _onDelete() {
    if (_buffer.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _buffer.last = '\x00';
      _buffer.removeLast();
    });
  }

  void _onConfirm() {
    if (_buffer.isEmpty) return;
    final value = _buffer.join();
    widget.onComplete(value);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      color: palette.background,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildInputDisplay(),
            const SizedBox(height: 8),
            _buildTabBar(),
            const SizedBox(height: 4),
            _buildActiveTabKeys(),
            _buildBottomRow(),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  // ── Handle / header ────────────────────────────────────────────────────────

  Widget _buildHandle() {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          if (widget.onCancel != null)
            GestureDetector(
              onTap: widget.onCancel,
              child: Icon(Icons.close, color: palette.textMuted, size: 20),
            )
          else
            const SizedBox(width: 20),
          const Spacer(),
          Text(
            widget.hintText,
            style: TextStyle(color: palette.textMuted, fontSize: 13),
          ),
          const Spacer(),
          if (widget.mode == SecureKeyboardMode.password)
            GestureDetector(
              onTap: () => setState(() => _showInput = !_showInput),
              child: Icon(
                _showInput
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: palette.textMuted,
                size: 20,
              ),
            )
          else
            const SizedBox(width: 20),
        ],
      ),
    );
  }

  // ── Input display ──────────────────────────────────────────────────────────

  Widget _buildInputDisplay() {
    final palette = context.palette;
    final text = _buffer.map((c) {
      if (widget.mode == SecureKeyboardMode.password && !_showInput) {
        return '●';
      }
      return c == '\x00' ? '?' : c;
    }).join();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _buffer.isEmpty
              ? palette.divider
              : palette.accent.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buffer.isEmpty
                ? Text(
                    widget.hintText,
                    style: TextStyle(
                      color: palette.textDisabled,
                      fontSize: 15,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          Text(
            '${_buffer.length}/${widget.maxLength}',
            style: TextStyle(color: palette.textDisabled, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────

  static const _tabLabels = {
    _Tab.lower: 'a-z',
    _Tab.upper: 'A-Z',
    _Tab.digits: '0-9',
    _Tab.symbols: '!@#',
  };

  Widget _buildTabBar() {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _Tab.values.map((tab) {
          final isActive = tab == _activeTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? palette.accent : palette.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? palette.accent : palette.divider,
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabLabels[tab]!,
                  style: TextStyle(
                    color: isActive ? palette.textPrimary : palette.textMuted,
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Key grid for active tab ────────────────────────────────────────────────

  Widget _buildActiveTabKeys() {
    final chars = _layouts[_activeTab]!;
    // Chunk into rows of 10 (or fewer for last row)
    const perRow = 10;
    final rows = <List<String>>[];
    for (var i = 0; i < chars.length; i += perRow) {
      rows.add(chars.sublist(i, (i + perRow).clamp(0, chars.length)));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map(_buildKeyRow).toList(),
    );
  }

  Widget _buildKeyRow(List<String> chars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: chars.map(_buildKeyTile).toList(),
      ),
    );
  }

  Widget _buildKeyTile(String char) {
    final palette = context.palette;
    final isLastPressed = _lastPressedKey == char;
    return Expanded(
      child: AnimatedBuilder(
        animation: _feedbackController,
        builder: (_, child) {
          final scale =
              isLastPressed ? 1.0 - (_feedbackController.value * 0.14) : 1.0;
          return Transform.scale(scale: scale, child: child);
        },
        child: GestureDetector(
          onTap: () => _onKey(char),
          child: Container(
            margin: const EdgeInsets.all(2.5),
            height: 46,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: palette.divider,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.scrim,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              char,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom action row ──────────────────────────────────────────────────────

  Widget _buildBottomRow() {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
      child: Row(
        children: [
          // Space bar
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _onKey(' '),
              child: Container(
                height: 46,
                margin: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: palette.divider,
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).keyboardSpace,
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
              ),
            ),
          ),

          // Delete (long-press clears all)
          Expanded(
            child: GestureDetector(
              onTap: _onDelete,
              onLongPress: () {
                HapticFeedback.heavyImpact();
                setState(() {
                  for (var i = 0; i < _buffer.length; i++) {
                    _buffer[i] = '\x00';
                  }
                  _buffer.clear();
                });
              },
              child: Container(
                height: 46,
                margin: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: palette.drawer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: palette.divider,
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.backspace_rounded,
                  color: palette.danger,
                  size: 18,
                ),
              ),
            ),
          ),

          // Confirm
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _buffer.isEmpty ? null : _onConfirm,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                margin: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  gradient: _buffer.isEmpty
                      ? null
                      : LinearGradient(
                          colors: [
                            palette.accent,
                            palette.accent.withValues(alpha: 0.7),
                          ],
                        ),
                  color: _buffer.isEmpty ? palette.drawer : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.confirmLabel,
                  style: TextStyle(
                    color: _buffer.isEmpty
                        ? palette.textDisabled
                        : palette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum SecureKeyboardMode { password, text }
