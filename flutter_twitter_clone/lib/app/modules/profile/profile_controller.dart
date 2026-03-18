import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxString username = 'Halo User'.obs;
  final RxString handle = '@halo_user'.obs;
  final RxInt followers = 128.obs;
  final RxInt following = 86.obs;
}
