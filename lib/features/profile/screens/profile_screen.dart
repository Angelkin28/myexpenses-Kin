import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      if (mounted) {
        final userId = context.read<AuthProvider>().user?.id;
        if (userId != null) {
          final success = await context
              .read<ProfileProvider>()
              .uploadProfilePhoto(_imageFile!, userId);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Photo uploaded successfully!'
                      : 'Failed to upload photo',
                ),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profilePhotoUrl == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Profile Photo
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (provider.profilePhotoUrl != null &&
                                        !provider.profilePhotoUrl!.startsWith(
                                          'data:image',
                                        )
                                    ? NetworkImage(provider.profilePhotoUrl!)
                                    : null)
                                as ImageProvider?,
                      child:
                          _imageFile == null &&
                              (provider.profilePhotoUrl == null ||
                                  !provider.profilePhotoUrl!.startsWith(
                                    'data:image',
                                  ))
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : (provider.profilePhotoUrl != null &&
                                    provider.profilePhotoUrl!.startsWith(
                                      'data:image',
                                    )
                                ? ClipOval(
                                    child: Image.memory(
                                      base64Decode(
                                        provider.profilePhotoUrl!.split(',')[1],
                                      ),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : null),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: provider.isLoading ? null : _pickImage,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),

                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Uploading...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                const SizedBox(height: 32),

                // User Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoRow(
                          context,
                          icon: Icons.email,
                          label: 'Email',
                          value:
                              context.read<AuthProvider>().user?.email ??
                              'Not available',
                        ),

                        const Divider(height: 32),

                        _buildInfoRow(
                          context,
                          icon: Icons.person,
                          label: 'User ID',
                          value:
                              context.read<AuthProvider>().user?.id.substring(
                                0,
                                8,
                              ) ??
                              'N/A',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
