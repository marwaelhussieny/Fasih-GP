// lib/features/profile/presentation/widgets/profile_widgets/profile_image_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart'; // Assuming UserEntity is here

class ProfileImageSection extends StatelessWidget {
  final UserEntity? currentUser;
  final File? imageFile;
  final Function(File) onImagePicked;

  const ProfileImageSection({
    Key? key,
    required this.currentUser,
    required this.imageFile,
    required this.onImagePicked,
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color cardColor = theme.cardColor;

    // Determine which image to display
    ImageProvider? displayImage;
    if (imageFile != null) {
      displayImage = FileImage(imageFile!);
    } else if (currentUser?.profileImageUrl != null && currentUser!.profileImageUrl!.isNotEmpty) {
      displayImage = NetworkImage(currentUser!.profileImageUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60.r, // Responsive size
            backgroundColor: primaryColor.withOpacity(0.1), // Subtle background
            backgroundImage: displayImage,
            child: displayImage == null
                ? Icon(Icons.person, size: 60.r, color: primaryColor) // Themed icon
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                padding: EdgeInsets.all(8.r), // Responsive padding
                decoration: BoxDecoration(
                  color: primaryColor, // Themed primary color
                  shape: BoxShape.circle,
                  border: Border.all(color: cardColor, width: 2.w), // Themed border
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: theme.colorScheme.onPrimary, // Themed icon color
                  size: 20.r, // Responsive size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}