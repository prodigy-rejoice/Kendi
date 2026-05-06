import 'package:flutter/material.dart';

// ── Vertical spacing widgets ─────────────────────────────────────────────────
const Widget verticalSpaceTiny = SizedBox(height: 4);
const Widget verticalSpaceSmall = SizedBox(height: 8);
const Widget verticalSpaceMedium = SizedBox(height: 16);
const Widget verticalSpaceLarge = SizedBox(height: 32);
const Widget verticalSpaceMassive = SizedBox(height: 64);

// ── Horizontal spacing widgets ───────────────────────────────────────────────
const Widget horizontalSpaceTiny = SizedBox(width: 4);
const Widget horizontalSpaceSmall = SizedBox(width: 8);
const Widget horizontalSpaceMedium = SizedBox(width: 16);
const Widget horizontalSpaceLarge = SizedBox(width: 32);

// ── Screen dimension helpers ─────────────────────────────────────────────────
double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;
double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;
double screenHeightFraction(BuildContext context, {int dividedBy = 1}) =>
    screenHeight(context) / dividedBy;
double screenWidthFraction(BuildContext context, {int dividedBy = 1}) =>
    screenWidth(context) / dividedBy;

bool isTablet(BuildContext context) => screenWidth(context) >= 600;
bool isDesktop(BuildContext context) => screenWidth(context) >= 960;
