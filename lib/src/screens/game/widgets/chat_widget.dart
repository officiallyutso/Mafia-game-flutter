import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/game_service.dart';

class ChatWidget extends StatefulWidget {
  final List<QueryDocumentSnapshot> messages;
  final String currentPlayerId;
  final GameService gameService;
  final String roomCode;
  final bool isDisabled;
  final String hintText;

  const ChatWidget({
    super.key,
    required this.messages,
    required this.currentPlayerId,
    required this.gameService,
    required this.roomCode,
    this.isDisabled = false,
    this.hintText = 'Type your message...',
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Scroll to bottom when new messages arrive
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Get sender name from the room
      final roomSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .get();
      
      if (!roomSnapshot.exists) {
        return;
      }
      
      final players = List<Map<String, dynamic>>.from(
          roomSnapshot.data()?['players'] ?? []);
      
      final currentPlayer = players.firstWhere(
        (p) => p['id'] == widget.currentPlayerId,
        orElse: () => {'name': 'Unknown'},
      );
      
      final senderName = currentPlayer['name'] as String;
      
      await widget.gameService.sendMessage(
        widget.roomCode,
        widget.currentPlayerId,
        senderName,
        message,
      );
      
      _messageController.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[850],
          child: const Row(
            children: [
              Icon(Icons.chat, size: 20),
              SizedBox(width: 8),
              Text(
                'Chat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index].data() as Map<String, dynamic>;
              final isCurrentUser = message['senderId'] == widget.currentPlayerId;
              
              return Align(
                alignment: isCurrentUser 
                    ? Alignment.centerRight 
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser 
                        ? Colors.blue[700] 
                        : Colors.grey[700],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isCurrentUser) ...[
                        Text(
                          message['senderName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(message['message'] ?? ''),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Message input
        if (!widget.isDisabled)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[900],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSending 
                      ? const CircularProgressIndicator() 
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ],
            ),
          ),
      ],
    );
  }
}