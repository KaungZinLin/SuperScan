import 'dart:io';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'package:super_scan/controllers/magic_eyes_controller.dart';
import 'package:flutter/services.dart';
import 'package:windows_toast/windows_toast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_scan/helpers/api_key_storage.dart';

enum ScreenView { extract, summarize, proofread, chat }

class MagicEyesScreen extends StatefulWidget {
  final Directory scanDir;

  const MagicEyesScreen({super.key, required this.scanDir});

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
      appBar: AppBar(title: const Text('MagicEyes'), centerTitle: true),
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
              ButtonSegment(
                value: ScreenView.proofread,
                label: Text('Proofread'),
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
          // const Divider(height: 32, indent: 20, endIndent: 20),
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
        return _ExtractUI(controller: controller, scanDir: widget.scanDir);
      case ScreenView.summarize:
        return _SummarizeUI(controller: controller, scanDir: widget.scanDir);
      case ScreenView.proofread:
        return _ProofreadUI(controller: controller, scanDir: widget.scanDir);
      case ScreenView.chat:
        return _ChatUI(scanDir: widget.scanDir);
    }
  }
}

// --- View 1: Extract ---
class _ExtractUI extends StatelessWidget {
  final MagicEyesController controller;
  final Directory scanDir;

  const _ExtractUI({required this.controller, required this.scanDir});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Action Area
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildActionArea(colorScheme, context),
        ),

        const Divider(height: 1),

        // Text Output Area
        Expanded(
          child: Container(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                controller.extractedText.isEmpty
                    ? "Extracted text will appear here."
                    : controller.extractedText,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: controller.extractedText.isEmpty
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionArea(ColorScheme colorScheme, BuildContext context) {
    // Toggle between a "Scanning" state and the "Action" state
    if (controller.isProcessing) {
      return Column(
        children: [
          const LinearProgressIndicator(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 12),
          Text(
            "Processing page ${controller.progressCurrent} of ${controller.progressTotal}...",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Primary
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => controller.runOCR(scanDir),
            icon: const Icon(Icons.document_scanner_outlined, size: 20),
            label: const Text("Extract Text"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // COPY BUTTON (WORKING)
        IconButton.filledTonal(
          tooltip: "Copy summary",
          onPressed: controller.extractedText.isEmpty
              ? null
              : () async {
                  await Clipboard.setData(
                    ClipboardData(text: controller.extractedText),
                  );
                  if (!context.mounted) return;
                  // optional snack bar feedback
                  WindowsToast.show('Copied to clipboard', context, 30);

                },
          icon: const Icon(Icons.copy),
        ),

        const SizedBox(width: 8),

        // PLACEHOLDER BUTTON (NO FUNCTION)
        IconButton.filledTonal(
          tooltip: "Share summary",
          onPressed: controller.extractedText.isEmpty
              ? null
              : () async {
                  final params = ShareParams(text: controller.extractedText);
                  await SharePlus.instance.share(params);
                },
          icon: const Icon(Icons.ios_share_outlined),
        ),
      ],
    );
  }
}

// --- View 2: Summarize ---
class _SummarizeUI extends StatelessWidget {
  final MagicEyesController controller;
  final Directory scanDir;

  const _SummarizeUI({required this.controller, required this.scanDir});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildActionArea(colorScheme, context),
        ),

        const Divider(height: 1),

        Expanded(
          child: Container(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                controller.summaryText.isEmpty
                    ? "Summary will appear here."
                    : controller.summaryText,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: controller.summaryText.isEmpty
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionArea(ColorScheme colorScheme, BuildContext context) {
    if (controller.isSummarizing || controller.isProcessing) {
      return Column(
        children: [
          const LinearProgressIndicator(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 12),
          Text(
            controller.isProcessing
                ? "Scanning document..."
                : "Generating summary...",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Primary
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => controller.summarizeFromScan(scanDir),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text("Generate Summary"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // COPY BUTTON (WORKING)
        IconButton.filledTonal(
          tooltip: "Copy summary",
          onPressed: controller.summaryText.isEmpty
              ? null
              : () async {
                  await Clipboard.setData(
                    ClipboardData(text: controller.summaryText),
                  );

                  // optional snack bar feedback
                  if (!context.mounted) return;
                  WindowsToast.show('Copied to clipboard', context, 30);
                },
          icon: const Icon(Icons.copy_rounded),
        ),

        const SizedBox(width: 8),

        // PLACEHOLDER BUTTON (NO FUNCTION)
        IconButton.filledTonal(
          tooltip: "Share summary",
          onPressed: controller.summaryText.isEmpty
              ? null
              : () async {
                  final params = ShareParams(text: controller.summaryText);
                  await SharePlus.instance.share(params);
                },
          icon: const Icon(Icons.ios_share_rounded),
        ),
      ],
    );
  }
}

//  Proofread ---
class _ProofreadUI extends StatelessWidget {
  final MagicEyesController controller;
  final Directory scanDir;

  const _ProofreadUI({required this.controller, required this.scanDir});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildActionArea(colorScheme, context),
        ),

        const Divider(height: 1),

        Expanded(
          child: Container(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                controller.proofreadResultText.isEmpty
                    ? "Results will appear here."
                    : controller.proofreadResultText,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: controller.proofreadResultText.isEmpty
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionArea(ColorScheme colorScheme, BuildContext context) {
    if (controller.isProofreading || controller.isProcessing) {
      return Column(
        children: [
          const LinearProgressIndicator(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 12),
          Text(
            controller.isProcessing
                ? "Scanning document..."
                : "Proofreading document...",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Primary
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => controller.proofreadFromScan(scanDir),
            icon: const Icon(Icons.search_rounded),
            label: const Text("Proofread Document"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // COPY BUTTON (WORKING)
        IconButton.filledTonal(
          tooltip: "Copy summary",
          onPressed: controller.proofreadResultText.isEmpty
              ? null
              : () async {
                  await Clipboard.setData(
                    ClipboardData(text: controller.proofreadResultText),
                  );
                  if (!context.mounted) return;

                  // optional snack bar feedback
                  WindowsToast.show('Copied to clipboard', context, 30);
                },
          icon: const Icon(Icons.copy_rounded),
        ),

        const SizedBox(width: 8),

        // PLACEHOLDER BUTTON (NO FUNCTION)
        IconButton.filledTonal(
          tooltip: "Share summary",
          onPressed: controller.proofreadResultText.isEmpty
              ? null
              : () async {
                  final params = ShareParams(
                    text: controller.proofreadResultText,
                  );
                  await SharePlus.instance.share(params);
                },
          icon: const Icon(Icons.ios_share_rounded),
        ),
      ],
    );
  }
}

// --- View 4: Chat UI ---
class _ChatUI extends StatefulWidget {
  final Directory scanDir;
  const _ChatUI({required this.scanDir});

  @override
  State<_ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<_ChatUI> {
  late final OpenAI _openAI;
  final MagicEyesController controller = MagicEyesController();
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'You');
  final ChatUser _gptUser = ChatUser(id: '2', firstName: 'ChatGPT');

  final List<ChatMessage> _messages = [];
  final List<ChatUser> _typingUser = <ChatUser>[];

  @override
  void initState() {
    super.initState();
    _initOpenAI();
  }

  Future<void> _initOpenAI() async {
    final apiKey = await ApiKeyStorage.loadApiKey();
    _openAI = OpenAI.instance.build(
      token: apiKey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true,
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector (
    onTap: () => FocusScope.of(context).unfocus(),
    child:  Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollStartNotification) {
              FocusScope.of(context).unfocus();
            }
            return false; // Return false to let the event continue bubbling
          },
          child: DashChat(
            currentUser: _currentUser,
            typingUsers: _typingUser,
            messageOptions: const MessageOptions(
              currentUserContainerColor: kAccentColor,
              containerColor: Colors.black,
              textColor: Colors.white,
            ),
            messages: _messages,
            onSend: (ChatMessage message) async {
              await getChatResponse(message);
            },
          ),
      )
      ),
    )
  );

  Future<void> getChatResponse(ChatMessage message) async {
    // Add the user's message immediately
    setState(() {
      _messages.insert(0, message);
      _typingUser.add(_gptUser);
    });

    // Run OCR safely
    String ocrText = "";
    try {
      ocrText = await controller.runOCRforChat(widget.scanDir);
    } catch (e) {
      // Check if the widget is still mounted before showing toast
      if (!mounted) return; //  use mounted from the State
      WindowsToast.show('OCR failed: $e', context, 30);
    }

    // Build combined prompt
    final combinedPrompt =
        """
Please use the following OCR text and answer the user's question accordingly. If the user asks a question that does not have an answer in the provided OCR test, try your best to answer it by using your own knowledge 

Document OCR content:
$ocrText

User question:
${message.text}
""";

    // Send prompt to GPT
    try {
      final request = ChatCompleteText(
        model: Gpt4OChatModel(),
        messages: [
          {'role': 'user', 'content': combinedPrompt},
        ],
        maxToken: 400,
      );

      final response = await _openAI.onChatCompletion(request: request);

      // Insert GPT response safely
      if (response != null && response.choices.isNotEmpty) {
        final gptText = response.choices.first.message?.content ?? "";
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _gptUser,
              createdAt: DateTime.now(),
              text: gptText,
            ),
          );

          _typingUser.removeWhere((u) => u.id == _gptUser.id);
        });
      } else {
        setState(() {
          _typingUser.removeWhere((u) => u.id == _gptUser.id);
        });
      }
    } catch (e) {
      setState(() {
        _typingUser.removeWhere((u) => u.id == _gptUser.id);
      });
    }
  }
}
