import 'dart:math';

import 'package:cooking_quest/utils/constans.dart';
import 'package:cooking_quest/view/widgets/food_attributes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _clockWiseRotationAnimation;
  late Animation<double> _antiClockWiseRotationAnimation;
  late Tween<double> _antiClockWiseRotationTween;
  late Tween<double> _clockWiseRotationTween;

  late AnimationController _textOpacityController;
  late Animation<double> _textOpacityAnimation;

  late AnimationController _textColorController;
  late Animation<Color?> _textColorAnimation;

  late Animation<Color?> _textAttributeColorAnimation;
  int currentIndex = 1;
  bool isClockwise = false;
  bool isBgBlack = false;
  double backBgHeight = 0.0;
  double rotationValue = 0.0;

  void _changeFood() {
    setState(() {
      if (!isClockwise) {
        currentIndex =
            currentIndex < foodList.length - 1 ? currentIndex + 1 : 0;
      } else {
        currentIndex =
            currentIndex > 0 ? currentIndex - 1 : foodList.length - 1;
        print(currentIndex);
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {}

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    print(details.delta.dy);
    isClockwise = details.delta.dy < 0;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    rotationValue = 0.0;
    _antiClockWiseRotationTween.begin = rotationValue;
    _clockWiseRotationTween.begin = rotationValue;

    if (!_controller.isAnimating) {
      _controller.forward(from: 0.0);
      _textOpacityController.forward(from: 0.0);
      !isBgBlack
          ? _textColorController.forward(from: 0.0)
          : _textColorController.reverse();
      isBgBlack = !isBgBlack;
      setState(() {
        backBgHeight = isBgBlack ? MediaQuery.of(context).size.height : 0.0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _clockWiseRotationTween = Tween<double>(end: 2 * pi);
    _clockWiseRotationAnimation = _clockWiseRotationTween.animate(
        CurvedAnimation(parent: _controller, curve: const ElasticOutCurve(1.0)));

    _antiClockWiseRotationTween = Tween<double>(end: -2 * pi);
    _antiClockWiseRotationAnimation = _antiClockWiseRotationTween.animate(
        CurvedAnimation(parent: _controller, curve: const ElasticOutCurve(1.0)))
      ..addListener(() {
        setState(() {
          rotationValue = isClockwise
              ? _clockWiseRotationAnimation.value
              : _antiClockWiseRotationAnimation.value;
        });
      });

    _textOpacityController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _textOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_textOpacityController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _changeFood();
              _textOpacityController.reverse();
            }
          });

    _textColorController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _textColorAnimation =
        ColorTween(begin: const Color(0xff131c4f), end: Colors.white)
            .animate(_textColorController);
    _textAttributeColorAnimation =
        ColorTween(begin: const Color(0xff878995), end: const Color(0xffd4d5d7))
            .animate(_textColorController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _textOpacityController.dispose();
    _textColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            color: const Color(0xFFF1F1F3),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // white bg ----------------------

                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: SizedBox(
                    child: Image.asset(
                      "assets/Base.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                // black bg ----------------------

                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: backBgHeight,
                    child: Image.asset(
                      'assets/Base_black.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                // Text ----------------------
                Positioned(
                  top: 111.0,
                  left: 32.0,
                  right: 90.0,
                  bottom: 0.0,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // text ----------------------

                        const Text(
                          "DAILY COOKING QUEST",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Hero(
                            tag: "title",
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  foodList[currentIndex].foodName ?? "",
                                  style: TextStyle(
                                      color: _textColorAnimation.value,
                                      fontSize: 34.0,
                                      fontFamily: 'QuincyCF',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        FoodAttributes(
                          text: foodList[currentIndex].cookingDifficulty,
                          icon: Icons.hot_tub,
                          color: _textAttributeColorAnimation.value,
                          opacity: _textOpacityAnimation.value,
                        ),
                        Hero(
                          tag: "cooking_time",
                          child: Material(
                            color: Colors.transparent,
                            child: FoodAttributes(
                              text: foodList[currentIndex].cookingTime,
                              icon: Icons.timer,
                              color: _textAttributeColorAnimation.value,
                              opacity: _textOpacityAnimation.value,
                            ),
                          ),
                        ),
                        FoodAttributes(
                          text: foodList[currentIndex].foodEffect,
                          icon: Icons.spa,
                          color: _textAttributeColorAnimation.value,
                          opacity: _textOpacityAnimation.value,
                        ),
                        Hero(
                          tag: 'food_type',
                          child: Material(
                            color: Colors.transparent,
                            child: FoodAttributes(
                              text: foodList[currentIndex].foodType,
                              icon: Icons.four_k,
                              color: _textAttributeColorAnimation.value,
                              opacity: _textOpacityAnimation.value,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Text(
                            foodList[currentIndex].foodDescription??"",
                            style: TextStyle(
                              color: _textAttributeColorAnimation.value,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
