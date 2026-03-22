import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/seller_video/seller_video_bloc.dart';
import '../bloc/seller_video/seller_video_event.dart';
import '../bloc/seller_video/seller_video_state.dart';

class CreateVideoPage extends StatelessWidget {
  const CreateVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SellerVideoBloc>(
      create: (context) => GetIt.I<SellerVideoBloc>(),
      child: const CreateVideoView(),
    );
  }
}

class CreateVideoView extends StatefulWidget {
  const CreateVideoView({super.key});

  @override
  State<CreateVideoView> createState() => _CreateVideoViewState();
}

class _CreateVideoViewState extends State<CreateVideoView> {
  File? _videoFile;
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
    }
  }

  void _submit() {
    if (_videoFile == null) return;
    
    // In a real app we might also let them select products here (productIds)
    context.read<SellerVideoBloc>().add(
      CreateSellerVideoEvent(
        video: _videoFile!,
        caption: _captionController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerVideoBloc, SellerVideoState>(
      listener: (context, state) {
        if (state is CreateSellerVideoSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng video thành công!')),
          );
          Navigator.pop(context); // Go back after success
        } else if (state is SellerVideoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SellerVideoActionLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Đăng Video Sản Phẩm'),
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                )
              else
                TextButton(
                  onPressed: _videoFile == null ? null : _submit,
                  child: const Text('ĐĂNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: isLoading ? null : _pickVideo,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _videoFile != null
                        ? Center(child: Text('Đã chọn video:\n${_videoFile!.path.split('/').last}', textAlign: TextAlign.center))
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_library_rounded, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Chạm để chọn video từ thư viện (Max 100MB)'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Mô tả video', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  enabled: !isLoading,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Nhập nội dung quảng bá sản phẩm...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // (Optional) UI for picking associated products
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('Gắn tag sản phẩm'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                     // TODO: Mở bottom sheet hoặc screen chọn sản phẩm của shop
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
