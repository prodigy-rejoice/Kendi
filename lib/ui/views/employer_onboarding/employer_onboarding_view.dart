import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'employer_onboarding_viewmodel.dart';

class EmployerOnboardingView extends StackedView<EmployerOnboardingViewModel> {
  const EmployerOnboardingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    EmployerOnboardingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("EmployerOnboardingView")),
      ),
    );
  }

  @override
  EmployerOnboardingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      EmployerOnboardingViewModel();
}
