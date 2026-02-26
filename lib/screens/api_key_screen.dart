import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:super_scan/helpers/api_key_storage.dart';
import 'package:windows_toast/windows_toast.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final TextEditingController _controller = TextEditingController();
  String _currentKeyDisplay = '';
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadKey() async {
    final key = await ApiKeyStorage.loadApiKey();
    if (!mounted) return;
    setState(() {
      _currentKeyDisplay = key ?? '';
      if (_controller.text != _currentKeyDisplay) {
        _controller.text = _currentKeyDisplay;
      }
    });
  }

  // Helper to mask the key for UI beauty
  String _getMaskedKey(String key) {
    if (key.isEmpty) return "No key configured";
    if (key.length < 12) return "********";
    return "${key.substring(0, 8)}...${key.substring(key.length - 4)}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Configuration'),
        elevation: 0, // Flat AppBar
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),

            // --- Input Section (Flat Container instead of Card) ---
            Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                    ? Colors.grey[50]
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'OpenAI API Key',
                        hintText: 'sk-...',
                        // FontAwesome OpenAI Icon
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FaIcon(
                            FontAwesomeIcons.openai,
                            size: 18,
                            color: theme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0, // Flat button
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _saveKey,
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            elevation: 0, // Flat button
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _deleteKey,
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text(
              "Guide & Information",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // --- Info Cards (Already Flat) ---
            _infoTile(
              Icons.help_outline,
              "What is this?",
              "An OpenAI API key allows MagicEyes to securely use AI to summarize and analyze your documents. It works like a private access token for your personal OpenAI account.",
            ),
            _infoTile(
              Icons.privacy_tip_outlined,
              "Privacy First",
              "We never see your key. Documents are sent directly from your device to OpenAI. You only pay for what you use, directly to OpenAI.",
            ),
            _infoTile(
              Icons.account_balance_wallet_outlined,
              "How to get one?",
              "1. Sign in to platform.openai.com\n2. Navigate to API Keys\n3. Create a 'Secret Key' and paste it above.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(
              "MagicEyes AI",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Current Status: ${_currentKeyDisplay.isNotEmpty ? 'Active' : 'Inactive'}",
          style: TextStyle(
            color: _currentKeyDisplay.isNotEmpty ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          _getMaskedKey(_currentKeyDisplay),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Future<void> _saveKey() async {
    final trimmed = _controller.text.trim();
    if (trimmed.isNotEmpty) {
      await ApiKeyStorage.saveApiKey(trimmed);
      await _loadKey();
      if (mounted) {
        WindowsToast.show('API Key Updated Successfully', context, 30);
      }
    } else {
      if (mounted) WindowsToast.show('Please enter a valid key', context, 30);
    }
  }

  Future<void> _deleteKey() async {
    await ApiKeyStorage.deleteApiKey();
    await _loadKey();
    if (mounted) WindowsToast.show('API Key Removed', context, 30);
  }
}
