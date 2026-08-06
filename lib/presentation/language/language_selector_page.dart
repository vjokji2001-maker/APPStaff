import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_mate/generated/l10n.dart'; // Assuming intl generated

class LanguageSelectorPage extends ConsumerWidget {
  const LanguageSelectorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).languageSelection),
      ),
      body: ListView(
        children: const [
          _LanguageTile(locale: Locale('en'), label: 'English'),
          _LanguageTile(locale: Locale('hi'), label: 'हिन्दी'),
          _LanguageTile(locale: Locale('es'), label: 'Español'),
        ],
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  final Locale locale;
  final String label;
  const _LanguageTile({required this.locale, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(label),
      trailing: ref.watch(_currentLocaleProvider) == locale
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        // Update the locale using your app's locale provider
        ref.read(_localeChangerProvider.notifier).state = locale;
      },
    );
  }
}

// Placeholder providers – replace with your actual implementation
final _currentLocaleProvider = Provider<Locale>((ref) => const Locale('en'));
final _localeChangerProvider = StateProvider<Locale>((ref) => const Locale('en'));
