import 'package:flutter/material.dart';

class ProfileInfoWidget extends StatelessWidget {
  final ImageProvider profileImage;
  final double profileImageSize;
  final Color smallCircleColor;
  final double smallCircleSize;
  final Color tinyCircleColor;
  final double tinyCircleSize;
  final String name;
  final String staffId;
  final VoidCallback? onTap;

  const ProfileInfoWidget({
    Key? key,
    required this.profileImage,
    this.profileImageSize = 139,
    this.smallCircleColor = const Color(0xFFEE8924),
    this.smallCircleSize = 31,
    this.tinyCircleColor = Colors.transparent,
    this.tinyCircleSize = 18,
    required this.name,
    required this.staffId,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [

              // Profile picture 
              Container(
                width: profileImageSize,
                height: profileImageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: profileImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Edit button
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: smallCircleSize,
                    height: smallCircleSize,
                    decoration: BoxDecoration(
                      color: smallCircleColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: smallCircleSize * 0.6,
                    ),
                  ),
                ),
              ),

              if (tinyCircleColor != Colors.transparent)
                Positioned(
                  bottom: smallCircleSize + 12,
                  right: 12,
                  child: Container(
                    width: tinyCircleSize,
                    height: tinyCircleSize,
                    decoration: BoxDecoration(
                      color: tinyCircleColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: tinyCircleSize * 0.6,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 15),

          // Name and ID 
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF262422),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.20,
                  letterSpacing: 0.04,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 327,
                child: Text(
                  staffId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFABABAB),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.20,
                    letterSpacing: 0.03,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFF005CE7),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF005CE7),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.20,
                letterSpacing: 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }
}