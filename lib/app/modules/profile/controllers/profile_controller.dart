import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/theme/my_theme.dart';
import '../../../../config/translations/localization_service.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  final RxString userEmail = ''.obs;
  final RxString customerName = 'Amelia Barlow'.obs;
  final RxString customerPhone = '+34 600 777 999'.obs;
  final RxString customerAddress = 'Calle Mayor 88, Madrid'.obs;
  final RxString virtualCardNumber = ''.obs;
  final RxString virtualCardExpiry = ''.obs;
  final RxString virtualCardType = ''.obs;
  final RxBool isEditingProfile = false.obs;
  final RxBool isLoadingVirtualCard = true.obs;
  final RxString profileImageBase64 = ''.obs;
  final RxString selectedLanguageCode = 'es'.obs;
  final RxBool isDarkMode = false.obs;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  @override
  void onInit() {
    super.onInit();
    userEmail.value = AuthService.currentUserEmail ?? 'Usuario';
    _loadCustomerData();
    selectedLanguageCode.value = MySharedPref.getCurrentLocal().languageCode;
    isDarkMode.value = !MySharedPref.getThemeIsLight();
    nameController = TextEditingController(text: customerName.value);
    phoneController = TextEditingController(text: customerPhone.value);
    addressController = TextEditingController(text: customerAddress.value);
    loadVirtualCardFromBackend();
    _loadProfileFromBackend();
  }

  /// Trae el perfil real desde GET /api/v1/accounts/me y lo refleja en la UI.
  /// Si falla (sin conexion / sin token) deja los datos locales.
  Future<void> _loadProfileFromBackend() async {
    try {
      final me = await AuthRepository.instance.fetchMe();
      if (me == null) return;

      final firstName = (me['first_name'] ?? '').toString();
      final lastName = (me['last_name'] ?? '').toString();
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        customerName.value = fullName;
        await MySharedPref.setCustomerName(fullName);
      }
      final phone = me['phone_number']?.toString();
      if (phone != null && phone.isNotEmpty) {
        customerPhone.value = phone;
        await MySharedPref.setCustomerPhone(phone);
      }
      final address = me['address']?.toString();
      if (address != null && address.isNotEmpty) {
        customerAddress.value = address;
        await MySharedPref.setCustomerAddress(address);
      }
      final email = me['email']?.toString();
      if (email != null && email.isNotEmpty) {
        userEmail.value = email;
      }
      nameController.text = customerName.value;
      phoneController.text = customerPhone.value;
      addressController.text = customerAddress.value;
    } catch (_) {}
  }

  Future<void> changeLanguage(String languageCode) async {
    if (selectedLanguageCode.value == languageCode) {
      return;
    }
    await LocalizationService.updateLanguage(languageCode);
    selectedLanguageCode.value = languageCode;
    Get.snackbar('Idioma', languageCode == 'es' ? 'Idioma cambiado a Espanol' : 'Language changed to English');
  }

  void toggleDarkMode(bool enabled) {
    final bool shouldBeLight = !enabled;
    if (MySharedPref.getThemeIsLight() != shouldBeLight) {
      MyTheme.changeTheme();
    }
    isDarkMode.value = enabled;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> logout() async {
    await AuthService.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  void _loadCustomerData() {
    customerName.value = MySharedPref.getCustomerName() ?? 'Amelia Barlow';
    customerPhone.value = MySharedPref.getCustomerPhone() ?? '+34 600 777 999';
    customerAddress.value = MySharedPref.getCustomerAddress() ?? 'Calle Mayor 88, Madrid';
    profileImageBase64.value = MySharedPref.getCustomerProfileImage() ?? '';
  }

  Uint8List? get profileImageBytes {
    if (profileImageBase64.value.isEmpty) {
      return null;
    }
    try {
      return base64Decode(profileImageBase64.value);
    } catch (_) {
      return null;
    }
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    ImageSource? source;

    if (kIsWeb) {
      // On web, camera may not be available — use gallery only
      source = ImageSource.gallery;
    } else {
      source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: const Text('Cambiar foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
            ],
          ),
        ),
      );
    }
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final imageBase64 = base64Encode(bytes);
    profileImageBase64.value = imageBase64;
    await MySharedPref.setCustomerProfileImage(imageBase64);
    // propagate to home screen avatar if active

    // Sincroniza con el backend (PUT /api/v1/accounts/me). Si falla, se mantiene local.
    try {
      final parts = customerName.value.split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      await AuthRepository.instance.updateMe({
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': customerPhone.value,
        'address': customerAddress.value,
      });
    } catch (_) {}

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().profileImageBase64.value = imageBase64;
    }
  }

  void startEditingProfile() {
    nameController.text = customerName.value;
    phoneController.text = customerPhone.value;
    addressController.text = customerAddress.value;
    isEditingProfile.value = true;
  }

  void cancelEditingProfile() {
    isEditingProfile.value = false;
    nameController.text = customerName.value;
    phoneController.text = customerPhone.value;
    addressController.text = customerAddress.value;
  }

  Future<void> saveCustomerData() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      Get.snackbar('Campos requeridos', 'Completa nombre, teléfono y dirección.');
      return;
    }

    customerName.value = name;
    customerPhone.value = phone;
    customerAddress.value = address;
    await MySharedPref.setCustomerName(name);
    await MySharedPref.setCustomerPhone(phone);
    await MySharedPref.setCustomerAddress(address);
    isEditingProfile.value = false;
    Get.snackbar('Guardado', 'Tus datos fueron actualizados.');
  }

  Future<void> loadVirtualCardFromBackend() async {
    isLoadingVirtualCard.value = true;
    try {
      final card = await AuthService.fetchAssignedVirtualCard();
      virtualCardType.value = card['type'] ?? 'Marketplace Virtual';
      virtualCardNumber.value = card['number'] ?? '**** **** **** ****';
      virtualCardExpiry.value = card['expiry'] ?? '--/--';
    } finally {
      isLoadingVirtualCard.value = false;
    }
  }

  Future<void> unsubscribeService() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar baja'),
        content: const Text(
          '¿Seguro que deseas darte de baja del servicio? Esta acción cerrará tu sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Darme de baja'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await AuthService.signOut();
    Get.snackbar('Cuenta desactivada', 'Tu baja fue solicitada correctamente.');
    Get.offAllNamed(Routes.WELCOME);
  }
}
