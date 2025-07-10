import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget? leadingWidget;
  final IconData? leadingIcon;
  final Widget title;
  final Widget? subtitle;
  final Widget? page;
  final Color leadingIconColor;
  final double iconSize;
  final ShapeBorder shape;
  final double? leadingIconSize;

  const CustomListTile({
    Key? key,
    this.leadingWidget,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.page,
    this.leadingIconColor = Colors.green,
    this.iconSize = 24.0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    this.leadingIconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingWidget != null
          ? leadingWidget
          : leadingIcon != null
              ? Icon(leadingIcon,
                  size: leadingIconSize ?? iconSize, color: leadingIconColor)
              : null,
      title: title,
      subtitle: subtitle,
      shape: shape,
      onTap: page != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page!),
              );
            }
          : null,
    );
  }
}
