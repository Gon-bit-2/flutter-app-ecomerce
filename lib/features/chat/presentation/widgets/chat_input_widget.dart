import 'package:app_fe_ecomerce/core/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSend;

  const ChatInputWidget({super.key, required this.onSend});

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _hasText = false;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
        if (hasText) {
          _sendButtonController.forward();
        } else {
          _sendButtonController.reverse();
        }
      }
    });

    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _sendButtonScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 8.w,
        right: 8.w,
        top: 8.h,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8.h : 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Camera icon
            _buildAccessoryButton(
              icon: Icons.camera_alt_rounded,
              onTap: () {
                // Placeholder: open camera
              },
            ),
            SizedBox(width: 4.w),
            // Attachment icon
            _buildAccessoryButton(
              icon: Icons.attach_file_rounded,
              onTap: () {
                // Placeholder: attach file
              },
            ),
            SizedBox(width: 6.w),
            // Input field
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 120.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          color: const Color(0xFF212121),
                          height: 1.35,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14.sp,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Emoji icon
                    Padding(
                      padding: EdgeInsets.only(right: 8.w, bottom: 8.h),
                      child: GestureDetector(
                        onTap: () {
                          // Placeholder: emoji picker
                        },
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          size: 22.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 6.w),
            // Send / Mic button
            AnimatedBuilder(
              animation: _sendButtonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sendButtonScale.value,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: _hasText ? _handleSend : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _hasText
                        ? const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF00A8E8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _hasText ? null : const Color(0xFFF5F5F7),
                    boxShadow: _hasText
                        ? const [
                            BoxShadow(
                              color: Color(0x302196F3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _hasText ? Icons.send_rounded : Icons.mic_rounded,
                    color: _hasText ? Colors.white : Colors.grey.shade500,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── Accessory Button ─────
  Widget _buildAccessoryButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        margin: EdgeInsets.only(bottom: 3.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
