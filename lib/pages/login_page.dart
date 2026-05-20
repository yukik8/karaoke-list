import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class _Feature {
  const _Feature(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}

const _features = [
  _Feature(
    Icons.queue_music_rounded,
    'マイリスト管理',
    '歌いたい曲をタグやキー付きで整理。\n自分だけのセットリストを作ろう。',
  ),
  _Feature(
    Icons.shuffle_rounded,
    'おまかせ選曲',
    '次に何を歌うか迷ったら\nシャッフルにお任せ。',
  ),
  _Feature(
    Icons.history_rounded,
    '歌った記録',
    'あの日のセットリストも振り返れる。\n履歴を自動で保存。',
  ),
];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  String? _error;
  int _featurePage = 0;
  Timer? _featureTimer;

  static const _gold = Color(0xffC57E14);
  static const _textPrimary = Color(0xFF1E1A14);
  static const _textSecondary = Color(0xFF777777);

  late final PageController _pageCtrl = PageController(viewportFraction: 0.90);

  late final AnimationController _floatCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat(reverse: true);

  late final Animation<double> _floatAnim = Tween<double>(begin: -5, end: 5)
      .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));


  @override
  void initState() {
    super.initState();
    _featureTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && _pageCtrl.hasClients) {
        final next = (_featurePage + 1) % _features.length;
        _pageCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _featureTimer?.cancel();
    _pageCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _error = 'Googleログインに失敗しました';
        _loading = false;
      });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (e) {
      setState(() {
        _error = 'Apple IDログインに失敗しました';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFF5DC),
            ],
          ),
        ),
        child: Stack(
        children: [
          // Bottom-left subtle glow only — top glow was creating visible haze
          Positioned(
            bottom: 80,
            left: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF5A623).withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator(color: _gold)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.09),

                        // Dynamic shadow responding to float height
                        AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (_, __) {
                            final floatVal = _floatAnim.value; // -5 to 5
                            final t = (floatVal + 5) / 10; // 0=low, 1=high

                            final shadowY = 6.0 + t * 14.0;
                            final shadowBlur = 18.0 + t * 22.0;
                            final shadowOpacity = 0.13 - t * 0.07;

                            return Transform.translate(
                              offset: Offset(0, floatVal),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: shadowOpacity),
                                      blurRadius: shadowBlur,
                                      spreadRadius: 0,
                                      offset: Offset(0, shadowY),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: Image.asset(
                                    'lib/assets/images/icon.png',
                                    width: 120,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Karalis',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                            letterSpacing: 5.0,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'あなたのカラオケ体験を、もっと楽しく。',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Noto_Sans_JP',
                            color: _textSecondary,
                            letterSpacing: 0.8,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Swipeable feature cards
                        SizedBox(
                          height: size.height * 0.14,
                          child: PageView.builder(
                            controller: _pageCtrl,
                            itemCount: _features.length,
                            onPageChanged: (i) =>
                                setState(() => _featurePage = i),
                            itemBuilder: (_, i) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: _FeatureCard(feature: _features[i]),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Pill dot indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _features.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _featurePage ? 20 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: i == _featurePage
                                    ? _gold
                                    : const Color(0xFFDDDDDD),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              if (_error != null) ...[
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFCC4444),
                                    fontSize: 12,
                                    fontFamily: 'Noto_Sans_JP',
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              _SignInButton(
                                onPressed: _signInWithGoogle,
                                icon: const Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff4285F4),
                                  ),
                                ),
                                label: 'Googleでログイン',
                                bgColor: Colors.white,
                                borderColor: const Color(0xFFE0DADA),
                                textColor: _textPrimary,
                              ),
                              if (Platform.isIOS) ...[
                                const SizedBox(height: 12),
                                _SignInButton(
                                  onPressed: _signInWithApple,
                                  icon: const Icon(
                                    Icons.apple,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                  label: 'Apple IDでログイン',
                                  bgColor: const Color(0xFF111111),
                                  borderColor: const Color(0xFF111111),
                                  textColor: Colors.white,
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.07),
                      ],
                    ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  static const _gold = Color(0xffC57E14);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE6DE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cream container with gold icon — no gradient
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF6EDD8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: _gold, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Noto_Sans_JP',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Noto_Sans_JP',
                    color: Color(0xFF888888),
                    height: 1.6,
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

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Noto_Sans_JP',
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
