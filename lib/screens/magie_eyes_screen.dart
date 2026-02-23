import 'dart:io';
import 'package:flutter/material.dart';
import 'package:super_scan/controllers/magic_eyes_controller.dart';

enum ScreenView { extract, summarize, chat }

class MagicEyesScreen extends StatefulWidget {
  final Directory scanDir;


  const MagicEyesScreen({
    super.key,
    required this.scanDir,
  });

  @override
  State<MagicEyesScreen> createState() => _MagicEyesScreenState();
}


class _MagicEyesScreenState extends State<MagicEyesScreen> {
  ScreenView currentView = ScreenView.extract;
  late final MagicEyesController controller;

  @override
  void initState() {
    super.initState();

    controller = MagicEyesController()
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MagicEyes AI'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // --- Segmented Control ---
          SegmentedButton<ScreenView>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ScreenView.extract, label: Text('Extract')),
              ButtonSegment(
                value: ScreenView.summarize,
                label: Text('Summarize'),
              ),
              ButtonSegment(value: ScreenView.chat, label: Text('Chat')),
            ],
            selected: {currentView},
            onSelectionChanged: (Set<ScreenView> newSelection) {
              setState(() {
                currentView = newSelection.first;
              });
            },
          ),
          const Divider(height: 32, indent: 20, endIndent: 20),
          // --- Dynamic UI Section ---
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildActiveView(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to switch between UIs
  Widget _buildActiveView() {
    switch (currentView) {
      case ScreenView.extract:
        return _ExtractUI(controller: controller,
    scanDir: widget.scanDir,);
      case ScreenView.summarize:
        return _SummarizeUI();
      case ScreenView.chat:
        return _ChatUI();
    }
  }
}

// --- View 1: Extract ---
class _ExtractUI extends StatelessWidget {
  final MagicEyesController controller;
  final Directory scanDir;

  const _ExtractUI({
    required this.controller,
    required this.scanDir,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        ElevatedButton.icon(
          icon: const Icon(Icons.document_scanner),
          label: const Text("Scan Text"),
          onPressed: controller.isProcessing
              ? null
              : () => controller.runOCR(scanDir),
        ),

        if (controller.isProcessing)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  "Processing ${controller.progressCurrent}/${controller.progressTotal}",
                ),
              ],
            ),
          ),

        const Divider(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              controller.extractedText.isEmpty
                  ? "Extracted text will appear here."
                  : controller.extractedText,
            ),
          ),
        ),
      ],
    );
  }
}

// --- View 2: Summarize ---
class _SummarizeUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(20),
      child: Column(
        children: [
          const TextField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Paste long text here...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Generate Summary"),
          ),
        ],
      ),
    );
  }
}

// --- View 3: Chat ---
class _ChatUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Align(
                alignment: Alignment.centerLeft,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("How can I help you today?"),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.send),
              hintText: "Ask MagicEyes...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
