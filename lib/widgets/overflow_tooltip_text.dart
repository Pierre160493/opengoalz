import 'package:flutter/material.dart';

/// A widget that displays text with an ellipsis when it overflows,
/// and automatically shows a tooltip only if the text is truncated.
class OverflowTooltipText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Widget? leading;
  final double? leadingWidth;
  final double leadingSpacing;

  const OverflowTooltipText({
    super.key,
    required this.text,
    this.style,
    this.leading,
    this.leadingWidth,
    this.leadingSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = style ?? DefaultTextStyle.of(context).style;

        // Calculate available width by subtracting leading width and spacing
        double availableWidth = constraints.maxWidth;
        if (leading != null) {
          availableWidth -= (leadingWidth ?? 0) + leadingSpacing;
        }

        final textPainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: availableWidth > 0 ? availableWidth : 0);

        bool isOverflowed = textPainter.didExceedMaxLines;

        Widget content = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              if (leadingSpacing > 0) SizedBox(width: leadingSpacing),
            ],
            Flexible(
              child: Text(
                text,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        );

        return isOverflowed ? Tooltip(message: text, child: content) : content;
      },
    );
  }
}
