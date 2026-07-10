import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/model/disease_info.dart';
import '../../providers/chatbot_provider.dart';

class ChatMessage {
const ChatMessage({
required this.text,
required this.isUser,
});

final String text;
final bool isUser;
}

class ChatScreen extends ConsumerStatefulWidget {
const ChatScreen({
  super.key,
  this.currentDisease, 
});

final DiseaseInfo? currentDisease; 

@override
ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
final _messageController = TextEditingController();
final _scrollController = ScrollController();

final List<ChatMessage> _messages = [
const ChatMessage(
text:
'Bonjour ! Je suis l’assistant Agri_Succès.\n\nJe peux vous aider à comprendre les maladies des plantes, les symptômes, les traitements et la prévention.',
isUser: false,
),
];

bool _isReplying = false;

@override
void dispose() {
_messageController.dispose();
_scrollController.dispose();
super.dispose();
}

Future<void> _sendMessage() async {
final message = _messageController.text.trim();

if (message.isEmpty || _isReplying) return;

setState(() {
  _messages.add(
    ChatMessage(
      text: message,
      isUser: true,
    ),
  );

  _isReplying = true;
});

_messageController.clear();
_scrollToBottom();

try {
  final chatbot = ref.read(chatbotServiceProvider);

  final reply = await chatbot.reply(
    message: message,
    currentDisease: widget.currentDisease,
  );

  if (!mounted) return;

  setState(() {
    _messages.add(
      ChatMessage(
        text: reply,
        isUser: false,
      ),
    );

    _isReplying = false;
  });

  _scrollToBottom();
} catch (_) {
  if (!mounted) return;

  setState(() {
    _messages.add(
      const ChatMessage(
        text:
            'Une erreur est survenue lors de la recherche des informations. Réessayez dans quelques instants.',
        isUser: false,
      ),
    );

    _isReplying = false;
  });

  _scrollToBottom();
}

}

void _scrollToBottom() {
WidgetsBinding.instance.addPostFrameCallback((_) {
if (!_scrollController.hasClients) return;

  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );
});

}

void _sendQuickQuestion(String question) {
_messageController.text = question;
_sendMessage();
}

@override
Widget build(BuildContext context) {
final currentDiseaseName = widget.currentDisease?.name;

return Scaffold(
  appBar: AppBar(
    title: const Text('Assistant agricole'),
    centerTitle: true,
  ),
  body: SafeArea(
    child: Column(
      children: [
        if (currentDiseaseName != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Discussion sur : $currentDiseaseName',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isReplying ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isReplying && index == _messages.length) {
                return const _TypingBubble();
              }

              return _MessageBubble(
                message: _messages[index],
              );
            },
          ),
        ),
        if (_messages.length == 1 && !_isReplying)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickQuestionChip(
                  label: 'Symptômes',
                  onTap: () => _sendQuickQuestion(
                    'Quels sont les symptômes ?',
                  ),
                ),
                _QuickQuestionChip(
                  label: 'Traitement',
                  onTap: () => _sendQuickQuestion(
                    'Quel traitement recommandez-vous ?',
                  ),
                ),
                _QuickQuestionChip(
                  label: 'Prévention',
                  onTap: () => _sendQuickQuestion(
                    'Comment prévenir cette maladie ?',
                  ),
                ),
                _QuickQuestionChip(
                  label: 'Gravité',
                  onTap: () => _sendQuickQuestion(
                    'Est-ce que cette maladie est grave ?',
                  ),
                ),
              ],
            ),
          ),
        _ChatInput(
          controller: _messageController,
          isReplying: _isReplying,
          onSend: _sendMessage,
        ),
      ],
    ),
  ),
);

}
}

class _MessageBubble extends StatelessWidget {
const _MessageBubble({
required this.message,
});

final ChatMessage message;

@override
Widget build(BuildContext context) {
final isUser = message.isUser;
final colorScheme = Theme.of(context).colorScheme;

return Align(
  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
  child: Container(
    constraints: const BoxConstraints(maxWidth: 310),
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: isUser
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(isUser ? 16 : 4),
        bottomRight: Radius.circular(isUser ? 4 : 16),
      ),
    ),
    child: Text(
      message.text,
      style: TextStyle(
        color: isUser
            ? colorScheme.onPrimary
            : colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    ),
  ),
);

}
}

class _TypingBubble extends StatelessWidget {
const _TypingBubble();

@override
Widget build(BuildContext context) {
return Align(
alignment: Alignment.centerLeft,
child: Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 12,
),
decoration: BoxDecoration(
color: Theme.of(context).colorScheme.surfaceContainerHighest,
borderRadius: BorderRadius.circular(16),
),
child: const Row(
mainAxisSize: MainAxisSize.min,
children: [
SizedBox(
width: 16,
height: 16,
child: CircularProgressIndicator(strokeWidth: 2),
),
SizedBox(width: 10),
Text('Assistant en train d’écrire...'),
],
),
),
);
}
}

class _QuickQuestionChip extends StatelessWidget {
const _QuickQuestionChip({
required this.label,
required this.onTap,
});

final String label;
final VoidCallback onTap;

@override
Widget build(BuildContext context) {
return ActionChip(
label: Text(label),
onPressed: onTap,
);
}
}

class _ChatInput extends StatelessWidget {
const _ChatInput({
required this.controller,
required this.isReplying,
required this.onSend,
});

final TextEditingController controller;
final bool isReplying;
final VoidCallback onSend;

@override
Widget build(BuildContext context) {
return Material(
elevation: 8,
child: SafeArea(
top: false,
child: Padding(
padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
child: Row(
children: [
Expanded(
child: TextField(
controller: controller,
enabled: !isReplying,
minLines: 1,
maxLines: 4,
textCapitalization: TextCapitalization.sentences,
onSubmitted: (_) => onSend(),
decoration: InputDecoration(
hintText: 'Posez votre question...',
filled: true,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(24),
borderSide: BorderSide.none,
),
contentPadding: const EdgeInsets.symmetric(
horizontal: 18,
vertical: 12,
),
),
),
),
const SizedBox(width: 8),
IconButton.filled(
onPressed: isReplying ? null : onSend,
icon: const Icon(Icons.send),
tooltip: 'Envoyer',
),
],
),
),
),
);
}
}
