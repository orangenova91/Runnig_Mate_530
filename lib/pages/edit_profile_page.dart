import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../utils/pace_parser.dart';
import '../utils/profile_constants.dart';
import '../widgets/pace_input_row.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_photo_picker.dart';
import '../widgets/section_header.dart';
import '../widgets/storage_image.dart';
import '../widgets/time_chip_selector.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _paceMinController;
  late final TextEditingController _paceSecController;

  final _picker = ImagePicker();
  final _storage = StorageService();
  final _userService = UserService();

  late Set<String> _preferredTimes;
  String? _runStyle;
  Uint8List? _profileBytes;
  Uint8List? _verifyBytes;
  String? _photoUrl;
  String? _verifyPhotoUrl;
  bool _uploadingPhoto = false;
  bool _uploadingVerify = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: profile.age.toString());

    final pace = parseAvgPaceParts(profile.avgPace);
    _paceMinController = TextEditingController(
      text: pace?.minutes.toString() ?? '',
    );
    _paceSecController = TextEditingController(
      text: pace != null ? pace.seconds.toString().padLeft(2, '0') : '',
    );

    _preferredTimes = Set<String>.from(profile.preferredTime);
    _runStyle = profile.runStyle.isEmpty ? null : profile.runStyle;
    _photoUrl = profile.photoUrl.isEmpty ? null : profile.photoUrl;
    _verifyPhotoUrl =
        profile.paceVerifyPhotoUrl.isEmpty ? null : profile.paceVerifyPhotoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _paceMinController.dispose();
    _paceSecController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _profileBytes = bytes;
      _uploadingPhoto = true;
    });

    try {
      final url = await _storage.uploadUserImage(
        uid: uid,
        fileName: 'profile.jpg',
        bytes: bytes,
      );
      setState(() => _photoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 업로드에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _pickVerifyPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _verifyBytes = bytes;
      _uploadingVerify = true;
    });

    try {
      final url = await _storage.uploadUserImage(
        uid: uid,
        fileName: 'pace_verify.jpg',
        bytes: bytes,
      );
      setState(() => _verifyPhotoUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증샷 업로드에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingVerify = false);
    }
  }

  String? _validate() {
    if (_profileBytes == null && (_photoUrl == null || _photoUrl!.isEmpty)) {
      return '프로필 사진을 등록해 주세요.';
    }
    if (_uploadingPhoto) {
      return '사진 업로드가 완료될 때까지 잠시만 기다려 주세요.';
    }
    if (_nameController.text.trim().isEmpty) return '이름을 입력해 주세요.';

    final age = int.tryParse(_ageController.text);
    if (age == null || age < 18 || age > 70) {
      return '나이를 확인해 주세요 (18~70).';
    }

    final min = int.tryParse(_paceMinController.text);
    final sec = int.tryParse(_paceSecController.text);
    if (min == null || sec == null || sec >= 60) {
      return '페이스를 올바르게 입력해 주세요.';
    }
    if (_preferredTimes.isEmpty) return '선호 시간대를 1개 이상 선택해 주세요.';
    if (_runStyle == null) return '러닝 스타일을 선택해 주세요.';
    return null;
  }

  Future<String?> _ensurePhotoUploaded() async {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) return null;
    if (_profileBytes == null) return '프로필 사진을 등록해 주세요.';

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return '로그인이 필요합니다.';

    setState(() => _uploadingPhoto = true);
    try {
      final url = await _storage.uploadUserImage(
        uid: uid,
        fileName: 'profile.jpg',
        bytes: _profileBytes!,
      );
      setState(() => _photoUrl = url);
      return null;
    } catch (e) {
      return '사진 업로드에 실패했습니다. 다시 시도해 주세요.';
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      final photoError = await _ensurePhotoUploaded();
      if (photoError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(photoError)),
          );
        }
        return;
      }

      final avgPace = formatAvgPace(
        int.parse(_paceMinController.text),
        int.parse(_paceSecController.text),
      );

      await _userService.updateProfile(
        uid,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        avgPace: avgPace,
        preferredTime: _preferredTimes.toList(),
        runStyle: _runStyle!,
        photoUrl: _photoUrl!,
        paceVerifyPhotoUrl: _verifyPhotoUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('프로필 수정')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: '기본 정보',
                    subtitle: '러닝 메이트에게 보여질 정보를 수정해 주세요',
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ProfilePhotoPicker(
                      imageBytes: _profileBytes,
                      imageUrl: _photoUrl,
                      onPick: _pickProfilePhoto,
                      isLoading: _uploadingPhoto,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      hintText: '지은',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: '나이',
                      hintText: '28',
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SectionHeader(title: '러닝 정보'),
                  const SizedBox(height: 16),
                  const Text(
                    '평균 페이스',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PaceInputRow(
                    minutesController: _paceMinController,
                    secondsController: _paceSecController,
                  ),
                  const Text(
                    '예: 5분 42초/km',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: '선호 시간대'),
                  const SizedBox(height: 12),
                  TimeChipSelector(
                    selected: _preferredTimes,
                    onChanged: (v) => setState(() => _preferredTimes = v),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '러닝 스타일',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownMenu<String>(
                    key: ValueKey(_runStyle),
                    initialSelection: _runStyle,
                    hintText: '스타일을 선택하세요',
                    width: double.infinity,
                    dropdownMenuEntries: ProfileConstants.runStyles.entries
                        .map(
                          (e) => DropdownMenuEntry<String>(
                            value: e.key,
                            label: e.value,
                          ),
                        )
                        .toList(),
                    onSelected: (v) => setState(() => _runStyle = v),
                  ),
                  const SizedBox(height: 28),
                  const SectionHeader(
                    title: '러닝 기록 인증샷',
                    subtitle: 'Strava·Nike Run Club 캡처 등 (선택)',
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _uploadingVerify ? null : _pickVerifyPhoto,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildVerifyPreview(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: '저장하기',
                loading: _saving,
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyPreview() {
    if (_uploadingVerify) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }
    if (_verifyBytes != null) {
      return Image.memory(_verifyBytes!, fit: BoxFit.cover);
    }
    if (_verifyPhotoUrl != null && _verifyPhotoUrl!.isNotEmpty) {
      return StorageImage(url: _verifyPhotoUrl!, fit: BoxFit.cover);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.upload_file_outlined,
          size: 32,
          color: AppTheme.textSecondary.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 8),
        Text(
          '탭하여 업로드',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
