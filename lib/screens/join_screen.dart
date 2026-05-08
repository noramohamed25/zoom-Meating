// import 'package:flutter/material.dart';
// import 'meeting_screen.dart';

// class JoinScreen extends StatefulWidget {
//   const JoinScreen({super.key});

//   @override
//   State<JoinScreen> createState() => _JoinScreenState();
// }

// class _JoinScreenState extends State<JoinScreen> {
//   final _codeController = TextEditingController();
//   final _nameController = TextEditingController();
//   bool _micOn = true;
//   bool _cameraOn = true;

//   @override
//   void dispose() {
//     _codeController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E1A),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//         title: const Text(
//           'Join Meeting',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),

//             // ─── Preview الكاميرا (بدون package) ───
//             Container(
//               height: 200,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF111827),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: _cameraOn
//                       ? const Color(0xFF2563EB).withOpacity(0.5)
//                       : Colors.white.withOpacity(0.08),
//                   width: 2,
//                 ),
//               ),
//               child: _cameraOn
//                   ? const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.videocam_rounded,
//                             color: Color(0xFF2563EB), size: 50),
//                         SizedBox(height: 10),
//                         Text(
//                           'Camera ready',
//                           style:
//                               TextStyle(color: Colors.white54, fontSize: 13),
//                         ),
//                       ],
//                     )
//                   : const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.videocam_off_rounded,
//                             color: Colors.white38, size: 50),
//                         SizedBox(height: 10),
//                         Text(
//                           'Camera is off',
//                           style:
//                               TextStyle(color: Colors.white38, fontSize: 13),
//                         ),
//                       ],
//                     ),
//             ),

//             const SizedBox(height: 24),

//             // ─── اسمك ───
//             _buildLabel('Your Name'),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _nameController,
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//               decoration: InputDecoration(
//                 hintText: 'Enter your name...',
//                 hintStyle: const TextStyle(color: Colors.white24),
//                 prefixIcon: const Icon(Icons.person_outline_rounded,
//                     color: Color(0xFF2563EB)),
//                 filled: true,
//                 fillColor: const Color(0xFF111827),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: const BorderSide(
//                     color: Color(0xFF2563EB),
//                     width: 2,
//                   ),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 20, vertical: 16),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ─── Meeting ID ───
//             _buildLabel('Meeting ID'),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _codeController,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 letterSpacing: 3,
//                 fontWeight: FontWeight.w600,
//               ),
//               keyboardType: TextInputType.text,
//               textAlign: TextAlign.center,
//               decoration: InputDecoration(
//                 hintText: 'ZEN-1234',
//                 hintStyle: const TextStyle(
//                   color: Colors.white24,
//                   letterSpacing: 3,
//                   fontSize: 16,
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFF111827),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: const BorderSide(
//                     color: Color(0xFF2563EB),
//                     width: 2,
//                   ),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 20, vertical: 16),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ─── Mic & Camera toggles ───
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildToggle(
//                     icon: _micOn
//                         ? Icons.mic_rounded
//                         : Icons.mic_off_rounded,
//                     label: _micOn ? 'Mic On' : 'Mic Off',
//                     value: _micOn,
//                     onChanged: (v) => setState(() => _micOn = v),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildToggle(
//                     icon: _cameraOn
//                         ? Icons.videocam_rounded
//                         : Icons.videocam_off_rounded,
//                     label: _cameraOn ? 'Video On' : 'Video Off',
//                     value: _cameraOn,
//                     onChanged: (v) => setState(() => _cameraOn = v),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 32),

//             // ─── زرار Join ───
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: _joinMeeting,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2563EB),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 0,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text(
//                   'Join Now',
//                   style: TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.w700),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) => Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white70,
//           fontWeight: FontWeight.w600,
//           fontSize: 14,
//         ),
//       );

//   Widget _buildToggle({
//     required IconData icon,
//     required String label,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//   }) {
//     return GestureDetector(
//       onTap: () => onChanged(!value),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding:
//             const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         decoration: BoxDecoration(
//           color: value
//               ? const Color(0xFF2563EB).withOpacity(0.15)
//               : const Color(0xFF111827),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: value
//                 ? const Color(0xFF2563EB).withOpacity(0.5)
//                 : Colors.white.withOpacity(0.08),
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color:
//                   value ? const Color(0xFF2563EB) : Colors.white38,
//               size: 22,
//             ),
//             const SizedBox(width: 10),
//             Text(
//               label,
//               style: TextStyle(
//                 color:
//                     value ? const Color(0xFF2563EB) : Colors.white38,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _joinMeeting() {
//     final name = _nameController.text.trim();
//     final code = _codeController.text.trim();

//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter your name'),
//           backgroundColor: Color(0xFFEF4444),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     if (code.length < 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid Meeting ID'),
//           backgroundColor: Color(0xFFEF4444),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) => MeetingScreen(
//           userName: name,
//           roomId: code, // ✅ تم التصحيح
//         ),
//         transitionDuration: const Duration(milliseconds: 400),
//         transitionsBuilder: (_, animation, __, child) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//       ),
//     );
//   }
// }
