import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState {
  final bool hasSeenOnboarding;
  final bool isLoading;

  const OnboardingState({
    this.hasSeenOnboarding = false,
    this.isLoading = true,
  });

  OnboardingState copyWith({bool? hasSeenOnboarding, bool? isLoading}) {
    return OnboardingState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const String _key = 'has_seen_onboarding';

  OnboardingNotifier() : super(const OnboardingState()) {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_key) ?? false;
    state = state.copyWith(
      hasSeenOnboarding: hasSeenOnboarding,
      isLoading: false,
    );
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = state.copyWith(hasSeenOnboarding: true);
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    state = state.copyWith(hasSeenOnboarding: false);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
      (ref) => OnboardingNotifier(),
    );
