import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:zenmeet/widgets/cameraService.dart';
import 'package:zenmeet/widgets/meetingConstants.dart';


// ── Pill badge (top bar) ───────────────────────────────────────────────────

Widget pillBadge(Widget child, {Color? color, bool border = false}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: border ? Border.all(color: kAccent.withOpacity(0.4)) : null,
      ),
      child: child,
    );

// ── Control button (mic / camera / speaker) ────────────────────────────────

Widget ctrlBtn({
  required IconData icon,
  required String label,
  required bool active,
  required VoidCallback onTap,
}) =>
    GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.12) : kGray,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: active ? Colors.white : Colors.white54, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(
            color: active ? Colors.white70 : Colors.white38,
            fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );

// ── Typing bubble ──────────────────────────────────────────────────────────

Widget typingBubble() => Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: kBgBubble, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => Padding(
                padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                child: Container(width: 7, height: 7,
                    decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle)),
              )),
        ),
      ),
    );

// ── Chat message bubble ────────────────────────────────────────────────────

Widget msgBubble(Map<String, String> m, bool isMe, double maxW) => Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: maxW),
        decoration: BoxDecoration(
          color: isMe ? kAccent : kBgBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(m['msg']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Text(m['time']!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );

// ── Camera preview tile (self view) ───────────────────────────────────────

Widget selfView(CameraService cam, bool camOn) => Container(
      width: 100, height: 120,
      decoration: BoxDecoration(
        color: kBgCard,
        border: Border.all(color: kAccent.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: camOn && cam.isReady && cam.controller != null
            ? CameraPreview(cam.controller!)
            : const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 28)),
      ),
    );

// ── Avatar circle ──────────────────────────────────────────────────────────

Widget avatarCircle(String letter, {double size = 100, Color color = kPurple}) => Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color.withOpacity(0.25), shape: BoxShape.circle),
      child: Center(child: Text(letter,
          style: TextStyle(color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.w700))),
    );