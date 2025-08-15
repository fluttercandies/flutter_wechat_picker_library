// Copyright 2023 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

/// Common extensions for the [BuildContext].
extension BuildContextExtension on BuildContext {
  /// [Theme.of].
  ThemeData get theme => Theme.of(this);

  /// [IconTheme.of].
  IconThemeData get iconTheme => IconTheme.of(this);

  /// [ThemeData.textTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// [MediaQueryData.padding].top
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// [MediaQueryData.padding].bottom
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// [MediaQueryData.viewInsets].bottom
  double get bottomInsets => MediaQuery.viewInsetsOf(this).bottom;
}

/// Common extensions for the [Brightness].
extension BrightnessExtension on Brightness {
  /// [Brightness.dark].
  bool get isDark => this == Brightness.dark;

  /// [Brightness.light].
  bool get isLight => this == Brightness.light;

  /// Get the reversed [Brightness].
  Brightness get reverse =>
      this == Brightness.light ? Brightness.dark : Brightness.light;
}

/// Common extensions for the [Color].
extension ColorExtension on Color {
  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  /// Returns a 32-bit value representing this color.
  ///
  /// The returned value is compatible with the default constructor
  /// ([Color.new]) but does _not_ guarantee to result in the same color due to
  /// [imprecisions in numeric conversions](https://en.wikipedia.org/wiki/Floating-point_error_mitigation).
  ///
  /// Unlike accessing the floating point equivalent channels individually
  /// ([a], [r], [g], [b]), this method is intentionally _lossy_, and scales
  /// each channel using `(channel * 255.0).round() & 0xff`.
  ///
  /// While useful for storing a 32-bit integer value, prefer accessing the
  /// individual channels (and storing the double equivalent) where higher
  /// precision is required.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 represents the [a] channel as an 8-bit unsigned integer.
  /// * Bits 16-23 represents the [r] channel as an 8-bit unsigned integer.
  /// * Bits 8-15 represents the [g] channel as an 8-bit unsigned integer.
  /// * Bits 0-7 represents the [b] channel as an 8-bit unsigned integer.
  ///
  /// > [!WARNING]
  /// > The value returned by this getter implicitly converts floating-point
  /// > component values (such as `0.5`) into their 8-bit equivalent by using
  /// > the [toARGB32] method; the returned value is not guaranteed to be stable
  /// > across different platforms or executions due to the complexity of
  /// > floating-point math.
  int _toARGB32() {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }

  /// The alpha channel of this color in an 8 bit value.
  ///
  /// A value of 0 means this color is fully transparent. A value of 255 means
  /// this color is fully opaque.
  int get _alpha => (0xff000000 & _toARGB32()) >> 24;

  /// Determine the transparent color by 0 alpha.
  bool get isTransparent => _alpha == 0x00;
}

/// Common extensions for the [ThemeData].
extension ThemeDataExtension on ThemeData {
  /// The effective brightness from the
  /// [SystemUiOverlayStyle.statusBarBrightness]
  /// and [ThemeData.brightness].
  Brightness get effectiveBrightness =>
      appBarTheme.systemOverlayStyle?.statusBarBrightness ?? brightness;
}

/// Common extensions for the [State].
extension SafeSetStateExtension on State {
  /// [setState] after the [fn] is done while the [State] is still [mounted]
  /// and [State.context] is safe to mark needs build.
  FutureOr<void> safeSetState(FutureOr<dynamic> Function() fn) async {
    await fn();
    if (mounted &&
        !context.debugDoingBuild &&
        context.owner?.debugBuilding != true) {
      // ignore: invalid_use_of_protected_member
      setState(() {});
    }
  }
}
