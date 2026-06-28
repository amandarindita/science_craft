import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../controllers/lab_controller.dart';
import 'package:flutter/services.dart';
class SimulationView extends StatefulWidget {
  const SimulationView({super.key});

  @override
  State<SimulationView> createState() => _SimulationViewState();
}

class _SimulationViewState extends State<SimulationView> {
  final LabController controller = Get.find<LabController>();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          UnityWidget(
            onUnityCreated: controller.onUnityCreated,
            onUnityMessage: controller.onUnityMessage,
            onUnitySceneLoaded: controller.onUnitySceneLoaded,
            useAndroidViewSurface: true,
            fullscreen: true,
            borderRadius: BorderRadius.zero,
          ),

          Positioned(
            top: 30,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}