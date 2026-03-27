import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/seller_video/seller_video_bloc.dart';
import '../bloc/seller_video/seller_video_event.dart';
import '../bloc/seller_video/seller_video_state.dart';
import 'create_video_page.dart';
import 'package:app_fe_ecomerce/core/common/widgets/app_network_image.dart';

class MyVideosPage extends StatelessWidget {
  final int shopId; // Thông thường lấy từ AuthBloc context, truyền tạm để demo
  
  const MyVideosPage({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SellerVideoBloc>(
      create: (context) => GetIt.I<SellerVideoBloc>()..add(LoadMyVideosEvent(shopId: shopId, isRefresh: true)),
      child: MyVideosView(shopId: shopId),
    );
  }
}

class MyVideosView extends StatelessWidget {
  final int shopId;
  const MyVideosView({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateVideoPage()),
              ).then((_) {
                // Refresh list on pop
                context.read<SellerVideoBloc>().add(LoadMyVideosEvent(shopId: shopId, isRefresh: true));
              });
            },
          )
        ],
      ),
      body: BlocBuilder<SellerVideoBloc, SellerVideoState>(
        builder: (context, state) {
           if (state is SellerVideosLoading && state.isFirstFetch) {
            return const Center(child: CircularProgressIndicator());
          }

          List videos = [];
          if (state is SellerVideosLoaded) {
            videos = state.videos;
          } else if (state is SellerVideosLoading) {
            videos = state.oldVideos;
          } else if (state is SellerVideoError) {
            videos = state.oldVideos ?? [];
          }

          if (videos.isEmpty) {
            return const Center(
              child: Text('Chưa có đăng video nào.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 9/16, // Typical vertical video ratio
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: video.thumbnailUrl != null
                        ? AppNetworkImage(imageUrl: video.thumbnailUrl!,  fit: BoxFit.cover)
                        : const Center(child: Icon(Icons.video_file, color: Colors.grey)),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${video.likeCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                         showDialog(
                           context: context,
                           builder: (ctx) => AlertDialog(
                             title: const Text('Xác nhận xóa'),
                             content: const Text('Bạn có chắc muốn xóa video này?'),
                             actions: [
                               TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Hủy')),
                               TextButton(onPressed: (){
                                 Navigator.pop(ctx);
                                 context.read<SellerVideoBloc>().add(DeleteSellerVideoEvent(video.id));
                               }, child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                             ]
                           )
                         );
                      },
                    ),
                  )
                ],
              );
            },
          );
        }
      )
    );
  }
}
