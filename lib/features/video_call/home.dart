import 'package:design_test/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/global/variables.dart';
import '../../core/utils.dart';
import '../auth/controller/auth_controller.dart';
import '../users/screens/users_list.dart';
import 'call_screen.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String baseRoomId = "ROOM_";
  String _lastChar = 'A';

  late RTCVideoRenderer localRenderer;
  late RTCVideoRenderer remoteRenderer;

  String newRoomId = '';

  String get nextRoomId {
    final roomId = baseRoomId + _lastChar;
    if (_lastChar == 'Z') {
      _lastChar = 'A';
    } else {
      _lastChar = String.fromCharCode(_lastChar.codeUnitAt(0) + 1);
    }
    return roomId;
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  Future<void> initRenderers() async {
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  void signOut(WidgetRef ref, BuildContext context) {
    ref.watch(authControllerProvider.notifier).signOut(context);
  }

  Future<void> openCamera() async {
    if (newRoomId.isEmpty) {
      showSnackBar(context, 'Please create a room', Palette.redColor);
      return;
    }

    try {
      await signaling.openUserMedia(localRenderer, remoteRenderer, newRoomId);
      showSnackBar(context, 'Camera opened', Colors.green);
    } catch (e) {
      showSnackBar(context, 'Failed to open camera', Palette.redColor);
    }
    setState(() {});
  }

  Future<void> createRoom() async {
    if (newRoomId.isEmpty) {
      showSnackBar(context, 'Please create a room', Palette.redColor);
      return;
    }

    try {
      String roomId = await signaling.createRoom(remoteRenderer, newRoomId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            offerData: {},
            roomId: roomId,
            caller: true,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context, 'Failed to create room', Palette.redColor);
    }
    setState(() {});
  }

  Future<void> joinRoomDialog() async {
    TextEditingController roomIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Room ID"),
          content: TextField(
            controller: roomIdController,
            decoration: const InputDecoration(hintText: "Room ID"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final enteredRoomId = roomIdController.text.trim();
                if (enteredRoomId.isEmpty) {
                  showSnackBar(context, 'Please enter a room ID', Palette.redColor);
                } else {
                  Navigator.of(context).pop();
                  try {
                    await signaling.joinRoom(remoteRenderer, enteredRoomId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallScreen(
                          offerData: {},
                          roomId: enteredRoomId,
                          caller: false,
                        ),
                      ),
                    );
                  } catch (e) {
                    showSnackBar(context, 'Something went wrong!', Palette.redColor);
                  }
                }
              },
              child: const Text("Join"),
            ),
          ],
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SnapTalk",
          style: GoogleFonts.poppins(
            fontSize: w * 0.06,
            fontWeight: FontWeight.bold,
            color: Palette.blackColor,
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersList()));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.file_copy),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              return InkWell(
                onTap: () => signOut(ref, context),
                child: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.logout),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(w * 0.15),
              child: Text(
                newRoomId.isEmpty
                    ? ''
                    : 'This is the room id for the new\nroom you are going to create\n$newRoomId',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Palette.blackColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: openCamera,
              child: const Text("Open Camera"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  newRoomId = nextRoomId;
                });
              },
              child: const Text("Get Room Id"),
            ),
            ElevatedButton(
              onPressed: createRoom,
              child: const Text("Create Room"),
            ),
            ElevatedButton(
              onPressed: joinRoomDialog,
              child: const Text("Join Room"),
            ),
          ],
        ),
      ),
    );
  }
}
