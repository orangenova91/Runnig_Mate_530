import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../utils/pace_parser.dart';
import '../widgets/pace_input_row.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_photo_picker.dart';
import '../widgets/section_header.dart';
import '../widgets/step_indicator.dart';
import '../widgets/time_chip_selector.dart';
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _paceMinController = TextEditingController();
  final _paceSecController = TextEditingController();
  final _picker = ImagePicker();
  final _storage = StorageService();
  final _userService = UserService();

  int _step = 0;
  Set<String> _preferredTimes = {};
  String? _runStyle;
  Uint8List? _profileBytes;
  Uint8List? _verifyBytes;
  String? _photoUrl;
  String? _verifyPhotoUrl;
  bool _uploadingPhoto = false;
  bool _submitting = false;

  static const _stepLabels = ['기본 정보', '러닝 정보', '마무리'];
  static const _runStyles = {
    'scenic': '풍경 러닝',
    'speed': '스피드 러닝',
    'social': '소셜 러닝',
    'interval': '인터벌 러닝',
  };

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName;
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }
    final photo = user?.photoURL;
    if (photo != null && photo.isNotEmpty) {
      _photoUrl = photo;
    }
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

    setState(() => _verifyBytes = bytes);

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
    }
  }

  String? _validateStep(int step) {
    switch (step) {
      case 0:
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
        return null;
      case 1:
        final min = int.tryParse(_paceMinController.text);
        final sec = int.tryParse(_paceSecController.text);
        if (min == null || sec == null || sec >= 60) {
          return '페이스를 올바르게 입력해 주세요.';
        }
        if (_preferredTimes.isEmpty) return '선호 시간대를 1개 이상 선택해 주세요.';
        return null;
      case 2:
        if (_runStyle == null) return '러닝 스타일을 선택해 주세요.';
        return null;
      default:
        return null;
    }
  }

  void _nextStep() {
    final error = _validateStep(_step);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
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

  Future<void> _submit() async {
    final error = _validateStep(2);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 세션이 만료되었습니다. 다시 로그인해 주세요.')),
      );
      return;
    }

    setState(() => _submitting = true);
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

      await _userService.createProfile(
        uid,
        UserProfile.onboardingDefaults(
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text),
          avgPace: avgPace,
          preferredTime: _preferredTimes.toList(),
          runStyle: _runStyle!,
          photoUrl: _photoUrl!,
          paceVerifyPhotoUrl: _verifyPhotoUrl ?? '',
        ),
      );

      final saved = await _userService.waitForProfile(uid);
      if (!saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 저장이 확인되지 않았습니다. 잠시 후 다시 시도해 주세요.'),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_profileSaveErrorMessage(e))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _profileSaveErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return '프로필 저장 권한이 없습니다. 로그인 상태를 확인하거나 잠시 후 다시 시도해 주세요.';
      case 'unavailable':
        return '서버에 연결할 수 없습니다. 네트워크를 확인해 주세요.';
      default:
        return '프로필 저장 실패 (${e.code})';
    }
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: '나를 소개해 주세요',
          subtitle: '러닝 메이트에게 보여질 기본 정보예요',
        ),
        const SizedBox(height: 28),
        Center(
          child: ProfilePhotoPicker(
            imageBytes: _profileBytes,
            imageUrl: _photoUrl,
            onPick: _pickProfilePhoto,
            isLoading: _uploadingPhoto,
          ),
        ),
        const SizedBox(height: 28),
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
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: '러닝 스타일을 알려주세요',
          subtitle: '비슷한 페이스와 시간대의 러너를 찾아드려요',
        ),
        const SizedBox(height: 28),
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
        const SizedBox(height: 28),
        const SectionHeader(title: '언제 뛰는 걸 좋아하세요?'),
        const SizedBox(height: 12),
        TimeChipSelector(
          selected: _preferredTimes,
          onChanged: (v) => setState(() => _preferredTimes = v),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: '거의 다 왔어요!',
          subtitle: '러닝 스타일을 선택하고 시작해 보세요',
        ),
        const SizedBox(height: 28),
        const Text(
          '러닝 스타일',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownMenu<String>(
          initialSelection: _runStyle,
          hintText: '스타일을 선택하세요',
          width: double.infinity,
          dropdownMenuEntries: _runStyles.entries
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
          onTap: _pickVerifyPhoto,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: _verifyBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(_verifyBytes!, fit: BoxFit.cover),
                  )
                : Column(
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
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('프로필 만들기'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: StepIndicator(
              currentStep: _step,
              totalSteps: 3,
              labels: _stepLabels,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStepContent(),
                ),
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
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting ? null : _prevStep,
                        child: const Text('이전'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _step > 0 ? 2 : 1,
                    child: PrimaryButton(
                      label: _step < 2 ? '다음' : '시작하기',
                      loading: _submitting,
                      onPressed: _submitting ? null : _nextStep,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
