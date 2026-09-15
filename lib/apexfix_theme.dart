import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const navy = Color(0xFF17143F);
const primary = Color(0xFF4B3FE4);
const orange = Color(0xFFFFA51F);
const pageBg = Color(0xFFF5F7FC);
const ink = Color(0xFF20253D);
const muted = Color(0xFF77809A);
const line = Color(0xFFE4E7F0);

class ApexFixMark extends StatelessWidget {
  final bool compact;
  const ApexFixMark({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: compact ? 30 : 38, height: compact ? 30 : 38, decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.bolt_rounded, color: Colors.white, size: compact ? 18 : 23)),
    const SizedBox(width: 9),
    Text('apexfix', style: GoogleFonts.inter(fontSize: compact ? 15 : 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.4)),
  ]);
}
