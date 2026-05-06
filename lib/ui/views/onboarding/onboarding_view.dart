import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import 'onboarding_viewmodel.dart';

// ── Slide data ───────────────────────────────────────────────────────────────

class _Slide {
  final String lottiePath;
  final String? lottieNetworkFallback;
  final String title;
  final String subtitle;
  final double? lottieHeight;
  final bool lottieClip;
  final bool showCircleBg;

  const _Slide({
    required this.lottiePath,
    this.lottieNetworkFallback,
    required this.title,
    required this.subtitle,
    this.lottieHeight,
    this.lottieClip = false,
    this.showCircleBg = false,
  });
}

const _slides = [
  _Slide(
    lottiePath: 'assets/lottie/earned.json',
    title: "You've already earned it",
    subtitle:
        "Every day you work, your wages accrue.\nEarnedNow shows you exactly what's yours.",
  ),
  _Slide(
    lottiePath: 'assets/lottie/safe.json',
    lottieNetworkFallback:
        'https://assets5.lottiefiles.com/packages/lf20_jbb5p3eo.json',
    title: 'Zero loans. Zero interest.',
    subtitle:
        "Your employer deposits payroll with us first.\nYou withdraw what's already yours — nothing more.",
    lottieHeight: 280,
    showCircleBg: true,
  ),
  _Slide(
    lottiePath: 'assets/lottie/employers.json',
    title: 'A benefit your team will love',
    subtitle:
        'Offer on-demand pay and reduce loan dependency\nin your workforce. Powered by Payaza.',
    lottieHeight: 300,
    lottieClip: true,
  ),
];

// ── Root view ────────────────────────────────────────────────────────────────

class OnboardingView extends StackedView<OnboardingViewModel> {
  const OnboardingView({super.key});

  @override
  Widget builder(
    BuildContext context,
    OnboardingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          PageView.builder(
            controller: viewModel.pageController,
            onPageChanged: viewModel.onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemCount: _slides.length,
            itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _OverlayControls(viewModel: viewModel),
          ),
        ],
      ),
    );
  }

  @override
  OnboardingViewModel viewModelBuilder(BuildContext context) =>
      OnboardingViewModel();

  @override
  bool get disposeViewModel => true;
}

// ── Individual slide ─────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        // TOP 55% — Lottie zone
        SizedBox(
          height: height * 0.55,
          child: Center(child: _LottieZone(slide: slide)),
        ),
        // MIDDLE 25% — Title + subtitle
        SizedBox(
          height: height * 0.25,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        // BOTTOM 20% — spacer for overlay
        SizedBox(height: height * 0.20),
      ],
    );
  }
}

// ── Lottie zone: handles circle-bg (slide 2) and clip (slide 3) ─────────────

class _LottieZone extends StatelessWidget {
  final _Slide slide;
  const _LottieZone({required this.slide});

  @override
  Widget build(BuildContext context) {
    Widget lottie = _SafeLottie(
      assetPath: slide.lottiePath,
      fallbackUrl: slide.lottieNetworkFallback,
      height: slide.lottieHeight,
    );

    // Fix 3 — slide 3: ClipRect + max-height constraint
    if (slide.lottieClip) {
      lottie = ClipRect(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: slide.lottieHeight ?? 300),
          child: lottie,
        ),
      );
    }

    // Fix 2 — slide 2: subtle circle background
    if (slide.showCircleBg) {
      return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
          lottie,
        ],
      );
    }

    return lottie;
  }
}

// ── Safe Lottie loader: asset → network fallback with debug prints ───────────

class _SafeLottie extends StatefulWidget {
  final String assetPath;
  final String? fallbackUrl;
  final double? height;

  const _SafeLottie({
    required this.assetPath,
    this.fallbackUrl,
    this.height,
  });

  @override
  State<_SafeLottie> createState() => _SafeLottieState();
}

class _SafeLottieState extends State<_SafeLottie> {
  late final Future<bool> _assetExists;

  @override
  void initState() {
    super.initState();
    _assetExists = _checkAsset();
  }

  Future<bool> _checkAsset() async {
    debugPrint('[Lottie] Loading: ${widget.assetPath}');
    try {
      await rootBundle.load(widget.assetPath);
      debugPrint('[Lottie] OK: ${widget.assetPath}');
      return true;
    } catch (e) {
      debugPrint(
        '[Lottie] FAILED: ${widget.assetPath} — '
        'falling back to network: ${widget.fallbackUrl}',
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExists,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Still checking — reserve space to avoid layout jump
          return SizedBox(height: widget.height ?? 200);
        }

        if (snapshot.data == true) {
          return Lottie.asset(
            widget.assetPath,
            fit: BoxFit.contain,
            height: widget.height,
            repeat: true,
          );
        }

        // Asset missing — use network fallback if provided
        final fallback = widget.fallbackUrl;
        if (fallback == null) {
          return SizedBox(height: widget.height ?? 200);
        }
        return Lottie.network(
          fallback,
          fit: BoxFit.contain,
          height: widget.height,
          repeat: true,
        );
      },
    );
  }
}

// ── Overlay navigation controls ──────────────────────────────────────────────

class _OverlayControls extends StatelessWidget {
  final OnboardingViewModel viewModel;
  const _OverlayControls({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final isLast = viewModel.isLastPage;

    return SizedBox(
      height: height * 0.20,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _PageDots(
              current: viewModel.currentPage,
              total: _slides.length,
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLast
                  ? _GetStartedButton(
                      key: const ValueKey('last'),
                      onTap: viewModel.nextPage,
                    )
                  : _NavRow(
                      key: const ValueKey('nav'),
                      onSkip: viewModel.skip,
                      onNext: viewModel.nextPage,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int current;
  final int total;
  const _PageDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NavRow extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _NavRow({super.key, required this.onSkip, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: 0.54),
          ),
          child: const Text(
            'Skip',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        _NextButton(onTap: onNext),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NextButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Next',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GetStartedButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
