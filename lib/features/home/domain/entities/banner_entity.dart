import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final int id;
  final String imageUrl;
  final String? link;

  const BannerEntity({required this.id, required this.imageUrl, this.link});

  @override
  List<Object?> get props => [id, imageUrl, link];
}
