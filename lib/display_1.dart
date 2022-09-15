import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gazou/display.dart';
import 'package:gazou/display_1.dart';
import 'package:quiver/async.dart';

/// 写真撮影画面
class Display2 extends StatefulWidget {
  const Display2({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  Display2State createState() => Display2State();
}

class Display2State extends State<Display2> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool check = true;
  double opacity = 0.5;
  int _start = 6;
  int _current = 5;
  int tmp = 0;

  // ③ カウントダウン処理を行う関数を定義
  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start), //初期値
      new Duration(seconds: 1), // 減らす幅
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds; //毎秒減らしていく
      });
    });
    // ④終了時の処理
    sub.onDone(() {
      final image = _controller.takePicture();
      Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Display(camera:widget.camera),
              )
                    );
    });
  }


  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      // カメラを指定
      widget.camera,
      // 解像度を定義
      ResolutionPreset.medium,
    );

    // コントローラーを初期化
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // ウィジェットが破棄されたら、コントローラーを破棄
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          Opacity(
            opacity: check ? opacity = 0.6 : opacity = 0.6,
            child: Image.asset("assets/3.png"),
          ),
          Opacity(
            opacity: check ? opacity = 0.5 : opacity = 0.5,
            child: Text(
              "$_current",
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 300,
              color: Color.fromARGB(255, 50, 51, 51),
              ),
            ),
          ),
          TextButton(//やらせボタン
          onPressed: () { Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Display2(camera:widget.camera),
                      )
                            ); },
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          child: Text(''),
          )
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 写真を撮る
          startTimer();
          final image = await _controller.takePicture();
          MaterialPageRoute(builder: (context) => Display2(camera:widget.camera),);
        },
        child: const Icon(Icons.camera_alt),
      ),
      
    );
  }
}