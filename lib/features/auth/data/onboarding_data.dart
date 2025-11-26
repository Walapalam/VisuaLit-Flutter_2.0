class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final String description;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.description,
  });

  static List<OnboardingData> get pages => [
    const OnboardingData(
      title: 'Build Your\nReading Habit',
      subtitle: 'Track Your Journey',
      imagePath: 'assets/onboarding/streak.png',
      description:
          'Track streaks, set goals, and watch your progress grow with our intelligent reading analytics',
    ),
    const OnboardingData(
      title: 'Transform Words\ninto Worlds',
      subtitle: 'Visualize Your Reading',
      imagePath: 'assets/onboarding/visualize.png',
      description:
          'Experience books like never before with AI-powered visualizations that bring stories to life',
    ),
    const OnboardingData(
      title: 'Your Personal\nLibrary Awaits',
      subtitle: 'Discover & Explore',
      imagePath: 'assets/onboarding/library.png',
      description:
          'Access thousands of books and audiobooks, all in one beautiful, intuitive app',
    ),
  ];
}
