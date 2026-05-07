import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:zenmeet/widgets/audioService.dart';
import 'package:zenmeet/widgets/cameraService.dart';
import 'package:zenmeet/widgets/chatService.dart';
import 'package:zenmeet/widgets/meetingConstants.dart';
import 'package:zenmeet/widgets/meetingWidgits.dart';



class MeetingScreen extends StatefulWidget {
  final String userName;
  final String roomId;
  const MeetingScreen({super.key, required this.userName, required this.roomId});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  // ── Services ───────────────────────────────────────────────────────────────
  final _cam   = CameraService();
  final _audio = AudioService();
  late final ChatService _chat;

  // ── State ──────────────────────────────────────────────────────────────────
  bool   _joined = false, _chatOpen = false, _saraTyping = false, _camOn = true;
  int    _seconds = 0;
  Timer? _clock;

  final _msgs      = <Map<String, String>>[];
  final _chatCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();

  // ── Init / Dispose ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _chat = ChatService(userName: widget.userName, saraName: kSaraName);
    _cam.init(onReady: () => setState(() {}));

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _joined = true);
      _clock = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
      _snack('$kSaraName joined the meeting', Icons.person_add_rounded, kGreen);
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    _cam.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String get _timer =>
      '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';

  String get _timeNow {
    final t = TimeOfDay.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _snack(String msg, IconData icon, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ));

  void _scrollToBottom() => Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
        );
      });

  // ── Send message ───────────────────────────────────────────────────────────
  Future<void> _send() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty || !_joined) return;

    _chatCtrl.clear();
    setState(() => _msgs.add({'sender': widget.userName, 'msg': text, 'time': _timeNow}));
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saraTyping = true);
    _scrollToBottom();

    final history = _msgs.map((m) => {
      'role': m['sender'] == widget.userName ? 'user' : 'assistant',
      'content': m['msg']!,
    }).toList();

    final reply = await _chat.sendMessage(userMessage: text, history: history);
    if (!mounted) return;

    setState(() {
      _saraTyping = false;
      _msgs.add({'sender': kSaraName, 'msg': reply, 'time': _timeNow});
    });
    _scrollToBottom();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBgDark,
        body: Stack(children: [
          _joined ? _callView() : _waitingView(),
          _topBar(),
          _controlsBar(),
          if (_chatOpen && _joined) _chatPanel(),
        ]),
      );

  // ── Waiting view ───────────────────────────────────────────────────────────
  Widget _waitingView() => Stack(children: [
        if (_cam.isReady && _camOn && _cam.controller != null)
          Positioned.fill(child: CameraPreview(_cam.controller!)),
        Positioned.fill(child: Container(color: Colors.black54)),
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (!_cam.isReady || !_camOn)
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kAccent, kPurple]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: kAccent.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
              ),
              child: Center(child: Text(widget.userName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700))),
            ),
          const SizedBox(height: 24),
          Text(widget.userName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          const Text('Waiting for the other person...', style: TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 32),
          pillBadge(
            Row(children: [
              const Icon(Icons.tag_rounded, color: kAccent, size: 18),
              const SizedBox(width: 8),
              Text(widget.roomId, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ]),
            color: Colors.black.withOpacity(0.6), border: true,
          ),
          const SizedBox(height: 10),
          const Text('Share this code with the other person', style: TextStyle(color: Colors.white60, fontSize: 12)),
        ])),
      ]);

  // ── Call view ──────────────────────────────────────────────────────────────
  Widget _callView() => Column(children: [
        Expanded(
          child: Container(
            color: kBgPanel,
            child: Stack(children: [
              Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                avatarCircle('S', size: 110),
                const SizedBox(height: 16),
                const Text(kSaraName, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                if (_saraTyping) ...[
                  const SizedBox(height: 8),
                  const Text('typing...', style: TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ])),
              const Positioned(bottom: 16, left: 16,
                child: Row(children: [
                  Icon(Icons.mic_rounded, color: Colors.white70, size: 16),
                  SizedBox(width: 6),
                  Text(kSaraName, style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              ),
            ]),
          ),
        ),
        Container(
          height: 140, color: kBgDark, padding: const EdgeInsets.all(10),
          child: Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [selfView(_cam, _camOn)]),
        ),
      ]);

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _topBar() => Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            pillBadge(Row(children: [
              const Icon(Icons.circle, color: Color(0xFF22C55E), size: 8),
              const SizedBox(width: 6),
              Text(_joined ? _timer : widget.roomId,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ])),
            const Spacer(),
            pillBadge(Row(children: [
              const Icon(Icons.people_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(_joined ? '2' : '1',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ])),
          ]),
        )),
      );

  // ── Controls bar ───────────────────────────────────────────────────────────
  Widget _controlsBar() => Positioned(
        bottom: 0, left: 0, right: 0,
        child: SafeArea(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
          )),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ctrlBtn(icon: _audio.isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                label: _audio.isMicOn ? 'Mute' : 'Unmute',
                active: _audio.isMicOn,
                onTap: () => setState(() => _audio.toggleMic())),
            ctrlBtn(icon: _camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                label: _camOn ? 'Camera' : 'No Cam',
                active: _camOn,
                onTap: () => setState(() => _camOn = !_camOn)),
            ctrlBtn(icon: _audio.isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                label: _audio.isSpeakerOn ? 'Speaker' : 'Muted',
                active: _audio.isSpeakerOn,
                onTap: () => setState(() => _audio.toggleSpeaker())),
            // Chat toggle
            GestureDetector(
              onTap: () { if (_joined) setState(() => _chatOpen = !_chatOpen); },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Stack(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: _chatOpen ? kAccent.withOpacity(0.3) : Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded,
                        color: _chatOpen ? kAccent : Colors.white, size: 24),
                  ),
                  if (_msgs.isNotEmpty && !_chatOpen)
                    Positioned(top: 4, right: 4,
                        child: Container(width: 10, height: 10,
                            decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle))),
                ]),
                const SizedBox(height: 6),
                const Text('Chat', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
              ]),
            ),
            // End call
            GestureDetector(
              onTap: _leaveDialog,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: kRed, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: kRed.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 6),
                const Text('End', style: TextStyle(color: kRed, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        )),
      );

  // ── Chat panel ─────────────────────────────────────────────────────────────
  Widget _chatPanel() => Positioned(
        right: 0, top: 0, bottom: 0,
        width: MediaQuery.of(context).size.width * 0.88,
        child: Container(
          decoration: const BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
          ),
          child: Column(children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                const Text('Chat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => setState(() => _chatOpen = false)),
              ]),
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: _msgs.isEmpty && !_saraTyping
                  ? const Center(child: Text('Say hello! 👋', style: TextStyle(color: Colors.white38, fontSize: 14)))
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: _msgs.length + (_saraTyping ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_saraTyping && i == _msgs.length) return typingBubble();
                        final m = _msgs[i];
                        return msgBubble(m, m['sender'] == widget.userName,
                            MediaQuery.of(context).size.width * 0.65);
                      },
                    ),
            ),
            // Input row
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: Row(children: [
                Expanded(child: TextField(
                  controller: _chatCtrl,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true, fillColor: kBgBubble,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(22)),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );

  // ── Leave dialog ───────────────────────────────────────────────────────────
  void _leaveDialog() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: kBgBubble,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Leave Meeting?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: const Text('Are you sure you want to leave?', style: TextStyle(color: Colors.white60)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('Stay', style: TextStyle(color: Colors.white60))),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: kRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Leave', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}