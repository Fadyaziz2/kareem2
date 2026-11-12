import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/consultation_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class ConsultationChatRoomScreen extends StatefulWidget {
  final ConsultationModel consultation;

  const ConsultationChatRoomScreen({super.key, required this.consultation});

  @override
  State<ConsultationChatRoomScreen> createState() => _ConsultationChatRoomScreenState();
}

class _ConsultationChatRoomScreenState extends State<ConsultationChatRoomScreen> {
  late ConsultationModel _consultation;
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _consultation = widget.consultation;
    _refreshConsultation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshConsultation() async {
    try {
      final updated = await ApiService().getConsultationDetails(_consultation.id);
      if (mounted) {
        setState(() {
          _consultation = updated;
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      final updated = await ApiService().sendChatMessage(_consultation.id, text);
      if (mounted) {
        setState(() {
          _consultation = updated;
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الرسالة: $e'), backgroundColor: OqoodyTheme.alertRed),
        );
      }
    }
  }

  Future<void> _showCloseConsultationDialog() async {
    final notesController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        title: const Text('إغلاق وإنهاء الاستشارة', style: TextStyle(color: OqoodyTheme.accentGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اكتب الخلاصة القانونية أو الرأي النهائي للعميل:', style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'الرأي القانوني والتوصيات...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: OqoodyTheme.textMuted))),
          ElevatedButton(
            onPressed: () async {
              if (notesController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                final updated = await ApiService().closeConsultation(_consultation.id, notesController.text.trim());
                if (mounted) {
                  setState(() => _consultation = updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إنهاء الاستشارة بنجاح'), backgroundColor: OqoodyTheme.successGreen),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل الإغلاق: $e'), backgroundColor: OqoodyTheme.alertRed),
                  );
                }
              }
            },
            child: const Text('تأكيد الإغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.currentUser?.id ?? '';
    final isCompleted = _consultation.status == 'completed';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _consultation.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              _consultation.lawyerName != null ? 'المحامي: ${_consultation.lawyerName}' : 'استشارة قانونية',
              style: const TextStyle(fontSize: 11, color: OqoodyTheme.accentGold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OqoodyTheme.accentGold),
            onPressed: _refreshConsultation,
          ),
          if (!isCompleted)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: OqoodyTheme.successGreen),
              tooltip: 'إنهاء الاستشارة',
              onPressed: _showCloseConsultationDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // Consultation Info Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: OqoodyTheme.cardBg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: OqoodyTheme.primaryDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _consultation.typeArabic,
                        style: const TextStyle(fontSize: 11, color: OqoodyTheme.accentGold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCompleted ? OqoodyTheme.successGreen.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _consultation.statusArabic,
                        style: TextStyle(
                          fontSize: 11,
                          color: isCompleted ? OqoodyTheme.successGreen : Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_consultation.price.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold, fontSize: 13),
                ),
              ],
            ),
          ),

          // Initial Description Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OqoodyTheme.primaryDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OqoodyTheme.primaryEmerald),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: OqoodyTheme.accentGold),
                    SizedBox(width: 6),
                    Text('تفاصيل المسألة القانونية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: OqoodyTheme.accentGold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(_consultation.description, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),

          // Final Legal Opinion if Completed
          if (_consultation.responseNotes != null && _consultation.responseNotes!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: OqoodyTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OqoodyTheme.successGreen.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.gavel, size: 16, color: OqoodyTheme.successGreen),
                      SizedBox(width: 6),
                      Text('الرأي والتوصية القانونية النهائية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: OqoodyTheme.successGreen)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_consultation.responseNotes!, style: const TextStyle(fontSize: 13, color: Colors.white)),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: _consultation.messages.isEmpty
                ? const Center(
                    child: Text('لا توجد رسائل بعد. ابدأ المحادثة الآن.', style: TextStyle(color: OqoodyTheme.textMuted)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _consultation.messages.length,
                    itemBuilder: (context, index) {
                      final msg = _consultation.messages[index];
                      final isMe = msg.senderId == currentUserId;
                      final timeStr = DateFormat('hh:mm a', 'ar').format(msg.timestamp);

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? OqoodyTheme.primaryEmerald : OqoodyTheme.cardBg,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            border: Border.all(
                              color: isMe ? OqoodyTheme.accentGold.withOpacity(0.4) : OqoodyTheme.primaryEmerald,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    msg.senderName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: isMe ? OqoodyTheme.accentGold : Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(timeStr, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 9)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SelectableText(
                                msg.text,
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Input Bar
          if (!isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: OqoodyTheme.cardBg,
                border: Border(top: BorderSide(color: OqoodyTheme.primaryEmerald)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 3,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك للمحامي...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: OqoodyTheme.bgDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: OqoodyTheme.accentGold))
                          : const Icon(Icons.send, color: OqoodyTheme.accentGold),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: OqoodyTheme.primaryDark,
              child: const Text(
                'هذه الاستشارة مغلقة ومكتملة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
