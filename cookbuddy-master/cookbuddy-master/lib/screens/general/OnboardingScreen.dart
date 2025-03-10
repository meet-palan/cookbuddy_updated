import 'package:cookbuddy/screens/general/get_started_screen.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/onBoarding/img1.png',
      'title': 'Discover Your Recipe Paradise',
      'description':
          'Dive into a world of flavors with recipes curated just for you.',
    },
    {
      'image': 'assets/onBoarding/img2.png',
      'title': 'Gather Ingredients with Ease',
      'description':
          'Follow simple instructions to prepare all you need for a perfect meal.',
    },
    {
      'image': 'assets/onBoarding/img3.png',
      'title': 'Master the Art of Preparation',
      'description':
          'Step-by-step guidance ensures your dishes turn out just right.',
    },
    {
      'image': 'assets/onBoarding/img4.png',
      'title': 'Savor Every Bite',
      'description':
          'Cook like a pro and create memorable meals for yourself and your loved ones.',
    },
  ];

  void _nextPage() {
    if (_currentIndex < _onboardingData.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GetStartedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingPage(
                  image: _onboardingData[index]['image']!,
                  title: _onboardingData[index]['title']!,
                  description: _onboardingData[index]['description']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex != _onboardingData.length - 1)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetStartedScreen()),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: GoogleFonts.lora(
                        color: AppColors.headingText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? AppColors.buttonBackground
                            : AppColors.enabledBorder,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    foregroundColor: AppColors.buttonText,
                  ),
                  onPressed: _nextPage,
                  child: Text(
                    _currentIndex == _onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 350),
          const SizedBox(height: 50),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 18,
              color: AppColors.headingText,
            ),
          ),
        ],
      ),
    );
  }
}
