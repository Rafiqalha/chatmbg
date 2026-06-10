library;

import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'MBGBrain';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'AI Intelligence untuk MBG Indonesia';

  // Supabase
  static const String supabaseUrl =
      'https://tckuvjuywkakffzaofeq.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRja3V2anV5d2tha2ZmemFvZmVxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzOTU3MDYsImV4cCI6MjA5NTk3MTcwNn0.vI-8J6QaeBQaNIdhNDdgupGWk73xiXWTTGAIR1E0-RI';

  // API
  static const String apiBaseUrl = 'http://10.0.2.2:8000';
  static const String apiBaseUrlIos = 'http://localhost:8000';

  // Quick prompts for chat empty state
  static const List<QuickPrompt> quickPrompts = [
    QuickPrompt(
      icon: Icons.description_outlined,
      text: 'Apa syarat menjadi supplier resmi MBG?',
      category: 'UMKM',
    ),
    QuickPrompt(
      icon: Icons.restaurant_menu_outlined,
      text: 'Validasi menu: nasi, ayam, tempe, sayur bayam, pisang untuk siswa SD',
      category: 'Validator',
    ),
    QuickPrompt(
      icon: Icons.manage_search_outlined,
      text: 'Jelaskan kewajiban hyperlocal sourcing dalam SK 244/2025',
      category: 'Regulasi',
    ),
    QuickPrompt(
      icon: Icons.assignment_outlined,
      text: 'Dokumen apa yang dibutuhkan untuk persiapan audit BPKP?',
      category: 'Compliance',
    ),
  ];

  // Recipient groups for nutrition validation
  static const List<RecipientGroup> recipientGroups = [
    RecipientGroup(value: 'sd', label: 'Siswa SD', icon: Icons.school_outlined),
    RecipientGroup(value: 'smp', label: 'Siswa SMP', icon: Icons.menu_book_outlined),
    RecipientGroup(value: 'balita', label: 'Balita 2-5 th', icon: Icons.child_care_outlined),
    RecipientGroup(value: 'bumil', label: 'Ibu Hamil', icon: Icons.pregnant_woman_outlined),
  ];
}

class QuickPrompt {
  final IconData icon;
  final String text;
  final String category;

  const QuickPrompt({
    required this.icon,
    required this.text,
    required this.category,
  });
}

class RecipientGroup {
  final String value;
  final String label;
  final IconData icon;

  const RecipientGroup({
    required this.value,
    required this.label,
    required this.icon,
  });
}
