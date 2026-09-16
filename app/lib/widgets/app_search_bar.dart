import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../shared/theme.dart';
import 'app_pressable.dart';

class AppSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.placeholder = 'Search…',
    this.initialValue = '',
  });

  final ValueChanged<String> onChanged;
  final String placeholder;
  final String initialValue;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HHSpacing.screenPadding,
        0,
        HHSpacing.screenPadding,
        HHSpacing.md,
      ),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: hh.bgElevated2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hh.cardBorder.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(
              LucideIcons.search,
              size: 16,
              color: hh.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (val) {
                  setState(() {});
                  widget.onChanged(val);
                },
                style: hh.body().copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: hh.body().copyWith(
                        fontSize: 14,
                        color: hh.textTertiary,
                      ),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              AppPressable(
                onTap: () {
                  _controller.clear();
                  setState(() {});
                  widget.onChanged('');
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    LucideIcons.x,
                    size: 14,
                    color: hh.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
