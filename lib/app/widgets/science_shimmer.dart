import 'package:flutter/material.dart';

const Color _shimmerBase = Color(0xFFE7ECF4);
const Color _shimmerHighlight = Color(0xFFF8FAFD);

class ScienceShimmer extends StatefulWidget {
  const ScienceShimmer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ScienceShimmer> createState() =>
      _ScienceShimmerState();
}

class _ScienceShimmerState
    extends State<ScienceShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController
      _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1250),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (
        BuildContext context,
        Widget? child,
      ) {
        final double value =
            _controller.value;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment(
                -1.8 + (value * 3.6),
                -0.2,
              ),
              end: Alignment(
                -0.8 + (value * 3.6),
                0.2,
              ),
              colors: const <Color>[
                _shimmerBase,
                _shimmerHighlight,
                _shimmerBase,
              ],
              stops: const <double>[
                0.25,
                0.50,
                0.75,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _shimmerBase,
        borderRadius:
            BorderRadius.circular(radius),
      ),
    );
  }
}

class LearningLevelSelectorShimmer
    extends StatelessWidget {
  const LearningLevelSelectorShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScienceShimmer(
      child: SizedBox(
        height: 132,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) =>
              const SizedBox(width: 12),
          itemBuilder: (_, __) =>
              Container(
            width: 154,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: _shimmerBase,
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerBox(
                  width: 45,
                  height: 18,
                ),
                SizedBox(height: 12),
                ShimmerBox(
                  width: 105,
                  height: 13,
                ),
                SizedBox(height: 18),
                ShimmerBox(
                  height: 8,
                  radius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearningModuleListShimmer
    extends StatelessWidget {
  const LearningModuleListShimmer({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ScienceShimmer(
      child: Column(
        children: List<Widget>.generate(
          itemCount,
          (int index) => Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child: Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: _shimmerBase,
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  ShimmerBox(
                    width: 70,
                    height: 70,
                    radius: 17,
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        ShimmerBox(
                          width: 90,
                          height: 11,
                        ),
                        SizedBox(height: 9),
                        ShimmerBox(
                          height: 17,
                        ),
                        SizedBox(height: 7),
                        ShimmerBox(
                          width: 180,
                          height: 12,
                        ),
                        SizedBox(height: 13),
                        ShimmerBox(
                          height: 7,
                          radius: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LearningModuleDetailShimmer
    extends StatelessWidget {
  const LearningModuleDetailShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          32,
        ),
        physics:
            NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: <Widget>[
            ScienceShimmer(
              child: ShimmerBox(
                height: 190,
                radius: 23,
              ),
            ),
            SizedBox(height: 18),
            ScienceShimmer(
              child: ShimmerBox(
                width: 190,
                height: 22,
              ),
            ),
            SizedBox(height: 8),
            ScienceShimmer(
              child: ShimmerBox(
                width: 260,
                height: 13,
              ),
            ),
            SizedBox(height: 18),
            LearningModuleListShimmer(
              itemCount: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPageShimmer
    extends StatelessWidget {
  const QuizPageShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          28,
        ),
        physics:
            NeverScrollableScrollPhysics(),
        child: ScienceShimmer(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              ShimmerBox(
                height: 95,
                radius: 20,
              ),
              SizedBox(height: 13),
              ShimmerBox(
                height: 52,
                radius: 16,
              ),
              SizedBox(height: 18),
              ShimmerBox(
                width: 90,
                height: 13,
              ),
              SizedBox(height: 11),
              ShimmerBox(
                height: 58,
                radius: 15,
              ),
              SizedBox(height: 17),
              ShimmerBox(
                height: 63,
                radius: 16,
              ),
              SizedBox(height: 11),
              ShimmerBox(
                height: 63,
                radius: 16,
              ),
              SizedBox(height: 11),
              ShimmerBox(
                height: 63,
                radius: 16,
              ),
              SizedBox(height: 11),
              ShimmerBox(
                height: 63,
                radius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileLevelShimmer
    extends StatelessWidget {
  const ProfileLevelShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ScienceShimmer(
      child: Column(
        children: <Widget>[
          _ProfileLevelCardSkeleton(),
          SizedBox(height: 10),
          _ProfileLevelCardSkeleton(),
          SizedBox(height: 10),
          _ProfileLevelCardSkeleton(),
        ],
      ),
    );
  }
}

class _ProfileLevelCardSkeleton
    extends StatelessWidget {
  const _ProfileLevelCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: _shimmerBase,
        ),
      ),
      child: const Row(
        children: <Widget>[
          ShimmerBox(
            width: 48,
            height: 48,
            radius: 15,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerBox(
                  width: 125,
                  height: 16,
                ),
                SizedBox(height: 8),
                ShimmerBox(
                  height: 10,
                ),
                SizedBox(height: 8),
                ShimmerBox(
                  width: 170,
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminModuleListShimmer
    extends StatelessWidget {
  const AdminModuleListShimmer({
    super.key,
    this.itemCount = 4,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ScienceShimmer(
      child: ListView.separated(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          110,
        ),
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (_, __) =>
            Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: _shimmerBase,
            ),
          ),
          child: const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ShimmerBox(
                    width: 55,
                    height: 55,
                    radius: 15,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        ShimmerBox(
                          height: 17,
                        ),
                        SizedBox(height: 8),
                        ShimmerBox(
                          width: 155,
                          height: 11,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              ShimmerBox(
                height: 40,
                radius: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FunFactListShimmer
    extends StatelessWidget {
  const FunFactListShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ScienceShimmer(
      child: Column(
        children: <Widget>[
          _FunFactCardSkeleton(),
          SizedBox(height: 11),
          _FunFactCardSkeleton(),
          SizedBox(height: 11),
          _FunFactCardSkeleton(),
        ],
      ),
    );
  }
}

class _FunFactCardSkeleton
    extends StatelessWidget {
  const _FunFactCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: _shimmerBase,
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          ShimmerBox(
            width: 44,
            height: 44,
            radius: 14,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerBox(height: 13),
                SizedBox(height: 8),
                ShimmerBox(height: 13),
                SizedBox(height: 8),
                ShimmerBox(
                  width: 160,
                  height: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Siap dipakai pada BadgeView dan RewardView bila nanti kedua halaman
// memiliki state loading dari server.
class BadgeGridShimmer
    extends StatelessWidget {
  const BadgeGridShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScienceShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: 6,
        itemBuilder: (_, __) =>
            Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: _shimmerBase,
            ),
          ),
          child: const Column(
            children: <Widget>[
              ShimmerBox(
                width: 58,
                height: 58,
                radius: 29,
              ),
              SizedBox(height: 10),
              ShimmerBox(
                height: 11,
              ),
              SizedBox(height: 7),
              ShimmerBox(
                width: 55,
                height: 9,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RewardListShimmer
    extends StatelessWidget {
  const RewardListShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ScienceShimmer(
      child: Column(
        children: <Widget>[
          ShimmerBox(
            height: 180,
            radius: 24,
          ),
          SizedBox(height: 15),
          ShimmerBox(
            height: 110,
            radius: 19,
          ),
          SizedBox(height: 12),
          ShimmerBox(
            height: 110,
            radius: 19,
          ),
          SizedBox(height: 12),
          ShimmerBox(
            height: 110,
            radius: 19,
          ),
        ],
      ),
    );
  }
}
