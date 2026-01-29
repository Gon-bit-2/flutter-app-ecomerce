import 'package:image_picker/image_picker.dart'; // or cross_file
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

abstract class CommonRepository {
  Future<Either<Failure, String>> uploadFile(XFile file);
}
