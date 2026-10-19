import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medchen/global/ProfileAvatar.dart';
import 'package:medchen/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({
    super.key,
    required this.token,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();

  Map<String, dynamic>? _profile;
  XFile? _selectedImage;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  bool _isEditing = false;

  String get _profileUrl => '${AuthService.baseUrl}/profile';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
      };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.trim().isEmpty) {
      throw Exception('The server returned an empty response.');
    }

    final decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response.');
    }

    return decoded;
  }

  String _errorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(_profileUrl),
        headers: _headers,
      );

      final data = _decodeResponse(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Could not load profile.');
      }

      final profile = Map<String, dynamic>.from(data['profile'] as Map);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _fullNameController.text =
            profile['fullName']?.toString() ?? '';
        _phoneController.text = profile['phone']?.toString() ?? '';
        _selectedImage = null;
        _isEditing = false;
      });
    } catch (error) {
      _showMessage(_errorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null || !mounted) return;

      final extension = image.name.split('.').last.toLowerCase();

      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        _showMessage(
          'Please select a JPG, JPEG, or PNG image.',
          isError: true,
        );
        return;
      }

      final file = File(image.path);

      if (!await file.exists()) {
        _showMessage('The selected image file could not be found.',
            isError: true);
        return;
      }

      if (await file.length() > 5 * 1024 * 1024) {
        _showMessage(
          'Image size must not exceed 5 MB.',
          isError: true,
        );
        return;
      }

      setState(() => _selectedImage = image);
    } catch (error) {
      _showMessage(
        'Could not select image: ${_errorMessage(error)}',
        isError: true,
      );
    }
  }

  Future<void> _uploadImage() async {
    final image = _selectedImage;

    if (image == null) {
      _showMessage('Please select an image first.', isError: true);
      return;
    }

    if (_isUploadingImage) return;

    final extension = image.name.split('.').last.toLowerCase();

    if (!['jpg', 'jpeg', 'png'].contains(extension)) {
      _showMessage(
        'Only JPG, JPEG, and PNG images are allowed.',
        isError: true,
      );
      return;
    }

    setState(() => _isUploadingImage = true);

    try {
      final mimeType =
          extension == 'png' ? 'png' : 'jpeg';

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_profileUrl/image'),
      );

      request.headers.addAll(_headers);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', mimeType),
          filename: image.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _decodeResponse(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(
          data['message'] ??
              'Image upload failed (${response.statusCode}).',
        );
      }

      final updatedProfile =
          Map<String, dynamic>.from(data['profile'] as Map);

      if (!mounted) return;

      setState(() {
        _profile = updatedProfile;
        _selectedImage = null;
      });

      _showMessage('Profile picture updated successfully.');
    } catch (error) {
      _showMessage(
        'Image upload failed: ${_errorMessage(error)}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse(_profileUrl),
        headers: {
          ..._headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
        }),
      );

      final data = _decodeResponse(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Profile update failed.');
      }

      if (!mounted) return;

      setState(() {
        _profile = Map<String, dynamic>.from(data['profile'] as Map);
        _isEditing = false;
      });

      _showMessage('Profile updated successfully.');
    } catch (error) {
      _showMessage(_errorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _fullNameController.text =
          _profile?['fullName']?.toString() ?? '';
      _phoneController.text = _profile?['phone']?.toString() ?? '';
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh profile',
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? _buildLoadError()
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildProfileHeader(theme),
                      const SizedBox(height: 24),
                      _buildDetailsCard(theme),
                      const SizedBox(height: 16),
                      _buildRolesCard(theme),
                      const SizedBox(height: 24),
                      if (_isEditing)
                        _buildEditActions()
                      else
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _isEditing = true);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Profile'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Could not load your profile.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final profile = _profile!;
    final imagePath = profile['profileImagePath']?.toString();

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                _selectedImage == null
                    ? ProfileAvatar(
                        imagePath: imagePath,
                        Size: 112,
                        radius: 56,
                      )
                    : ClipOval(
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                        ),
                      ),
                Material(
                  color: theme.colorScheme.primary,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Choose profile picture',
                    onPressed:
                        _isUploadingImage ? null : _pickImage,
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              Text(
                'New picture selected',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _isUploadingImage ? null : _uploadImage,
                  icon: _isUploadingImage
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.upload),
                  label: Text(
                    _isUploadingImage ? 'Uploading...' : 'Save Picture',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              profile['fullName']?.toString() ?? 'MedChain User',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (profile['roles'] as List<dynamic>? ?? [])
                  .map((role) => role.toString())
                  .join(' • ')
                  .toUpperCase(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ThemeData theme) {
    final profile = _profile!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                readOnly: !_isEditing,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                readOnly: !_isEditing,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _readOnlyField(
                label: 'National ID',
                value: profile['nationalId']?.toString() ??
                    'Not available',
                icon: Icons.badge_outlined,
              ),
              if ((profile['specialization']?.toString() ?? '')
                  .isNotEmpty) ...[
                const SizedBox(height: 14),
                _readOnlyField(
                  label: 'Specialization',
                  value: profile['specialization'].toString(),
                  icon: Icons.medical_services_outlined,
                ),
              ],
              if ((profile['licenseNumber']?.toString() ?? '')
                  .isNotEmpty) ...[
                const SizedBox(height: 14),
                _readOnlyField(
                  label: 'License Number',
                  value: profile['licenseNumber'].toString(),
                  icon: Icons.verified_user_outlined,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _readOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildRolesCard(ThemeData theme) {
    final roles = (_profile?['roles'] as List<dynamic>? ?? [])
        .map((role) => role.toString())
        .toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Roles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (roles.isEmpty)
              const Text('No roles assigned')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: roles.map((role) {
                  return Chip(
                    avatar: const Icon(
                      Icons.verified_user_outlined,
                      size: 18,
                    ),
                    label: Text(role),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _isSaving ? null : _saveProfile,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _isSaving ? null : _cancelEditing,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}