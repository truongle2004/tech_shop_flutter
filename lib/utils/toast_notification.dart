import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final Color successBgColor = Color.fromRGBO(202, 237, 220, 1);
final Color successTextColor = Color.fromRGBO(6, 95, 70, 1);

final Color errorBgColor = Color.fromRGBO(254, 242, 242, 1);
final Color errorTextColor = Color.fromRGBO(156, 34, 34, 1);

final Color infoBgColor = Color.fromRGBO(239, 246, 255, 1);
final Color infoTextColor = Color.fromRGBO(88, 145, 255, 1);

final Color warnBgColor = Color.fromRGBO(255, 251, 235, 1);
final Color warnTextColor = Color.fromRGBO(180, 83, 9, 1);

enum ToastType {
  info,
  error,
  success,
  warn,
}

class ToastsColorProps {
  final Color textColor;
  final Color backgroundColor;
  ToastsColorProps(this.textColor, this.backgroundColor);
}

class ToastNotification {
  final FToast toast;

  ToastNotification(this.toast);

  /// Return text and background color for toasts type
  ToastsColorProps _getToastColor(ToastType type) {
    if (type == ToastType.success) {
      return ToastsColorProps(
        successTextColor,
        successBgColor,
      );
    } else if (type == ToastType.error) {
      return ToastsColorProps(errorTextColor, errorBgColor);
    } else if (type == ToastType.warn) {
      return ToastsColorProps(warnTextColor, warnBgColor);
    } else {
      return ToastsColorProps(infoTextColor, infoBgColor);
    }
  }

  /// Display the toast on the overlay
  void _showToast(ToastType type, String content, IconData icon) {
    toast.showToast(
      child: _buildToast(type, content, icon),
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Display Success toast
  void success(String content) {
    _showToast(ToastType.success, content, Icons.check);
  }

  /// Display Error toast
  void error(String content) {
    _showToast(ToastType.error, content, Icons.error);
  }

  /// Display Info toast
  void info(String content) {
    _showToast(ToastType.info, content, Icons.info);
  }

  /// Display Warning toast
  void warn(String content) {
    _showToast(ToastType.warn, content, Icons.warning);
  }

  /// Construct the toast notification Widget structure
  Widget _buildToast(
    ToastType type,
    String content,
    IconData icon,
  ) =>
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 560, maxWidth: 360),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _getToastColor(type).backgroundColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _getToastColor(type).textColor),
              SizedBox(width: 16),
              Flexible(
                child: Text(
                  content,
                  style: TextStyle(
                    color: _getToastColor(type).textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
