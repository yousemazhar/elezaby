import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/global_app_bar.dart';

class PrescriptionUploadScreen extends StatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  State<PrescriptionUploadScreen> createState() =>
      _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  static const int _maxImages = 6;

  final _picker = ImagePicker();
  final _orderService = OrderService();
  final _notesController = TextEditingController();
  final List<XFile> _images = [];
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    if (_submitting) return;
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 75);
      if (picked.isEmpty) return;
      setState(() {
        final remaining = _maxImages - _images.length;
        _images.addAll(picked.take(remaining));
      });
      if (picked.length > (_maxImages - (_images.length - picked.length))) {
        _showSnack('You can upload up to $_maxImages images.');
      }
    } catch (e) {
      _showSnack('Could not pick images: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    if (_submitting) return;
    if (_images.length >= _maxImages) {
      _showSnack('You can upload up to $_maxImages images.');
      return;
    }
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );
      if (shot == null) return;
      setState(() => _images.add(shot));
    } catch (e) {
      _showSnack('Could not open camera: $e');
    }
  }

  void _removeImage(int index) {
    if (_submitting) return;
    setState(() => _images.removeAt(index));
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final auth = context.read<AuthProvider>();
    final addressProvider = context.read<AddressProvider>();
    final user = auth.appUser;
    final defaultAddress = addressProvider.defaultAddress;

    if (user == null) {
      _showSnack('You must be signed in to upload a prescription.');
      return;
    }
    if (defaultAddress == null) {
      _showSnack('Please add a delivery address first.');
      context.push('/addresses');
      return;
    }
    if (_images.isEmpty) {
      _showSnack('Add at least one prescription image.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _orderService.uploadPrescription(
        userId: user.uid,
        images: _images,
        address: defaultAddress.fullAddress,
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      _showSnack('Prescription uploaded successfully.');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Upload failed: $e');
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultAddress = context.watch<AddressProvider>().defaultAddress;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(
        title: 'Upload Prescription',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  const Text(
                    'Add photos of your prescription. Our pharmacy will review and call you to confirm.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  _AddressCard(
                    address: defaultAddress?.fullAddress,
                    onChange: () => context.push('/addresses'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Images',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${_images.length}/$_maxImages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _ImagesGrid(
                    images: _images,
                    onRemove: _removeImage,
                    onPickGallery: _pickFromGallery,
                    onPickCamera: _pickFromCamera,
                    canAddMore: _images.length < _maxImages && !_submitting,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Notes (optional)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    enabled: !_submitting,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText:
                          'e.g. Refill of monthly meds, allergic to penicillin…',
                      filled: true,
                      fillColor: AppColors.searchBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AppButton(
                label: 'Submit Prescription',
                loading: _submitting,
                onPressed: _images.isEmpty ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String? address;
  final VoidCallback onChange;

  const _AddressCard({required this.address, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null && address!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deliver to',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  hasAddress ? address! : 'No address selected',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: hasAddress
                        ? AppColors.textDark
                        : AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: Text(hasAddress ? 'Change' : 'Add'),
          ),
        ],
      ),
    );
  }
}

class _ImagesGrid extends StatelessWidget {
  final List<XFile> images;
  final void Function(int index) onRemove;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final bool canAddMore;

  const _ImagesGrid({
    required this.images,
    required this.onRemove,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.canAddMore,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      for (var i = 0; i < images.length; i++)
        _ImageTile(file: images[i], onRemove: () => onRemove(i)),
      if (canAddMore)
        _AddTile(icon: Icons.photo_library_outlined, label: 'Gallery', onTap: onPickGallery),
      if (canAddMore)
        _AddTile(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: onPickCamera),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: tiles,
    );
  }
}

class _ImageTile extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _ImageTile({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(file.path), fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withAlpha(60)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
