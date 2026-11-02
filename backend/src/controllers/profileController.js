
const fs = require('fs/promises');
const path = require('path');

const profileService = require('../services/profileService');

async function getProfile(req, res) {
  try {
    const profile = await profileService.getMyProfile(
      req.user.userId
    );

    return res.json({
      success: true,
      profile,
    });
  } catch (error) {
    console.error('Get profile error:', error.message);

    return res.status(
      error.message === 'User not found' ? 404 : 500
    ).json({
      success: false,
      message: error.message,
    });
  }
}

async function updateProfile(req, res) {
  try {
    const { fullName, phone } = req.body;

    const profile = await profileService.updateMyProfile(
      req.user.userId,
      { fullName, phone }
    );

    return res.json({
      success: true,
      message: 'Profile updated successfully',
      profile,
    });
  } catch (error) {
    console.error('Update profile error:', error.message);

    return res.status(
      error.message === 'User not found' ? 404 : 400
    ).json({
      success: false,
      message: error.message,
    });
  }
}

async function uploadProfileImage(req, res) {
  let newImagePath;

  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please select an image',
      });
    }

    const userId = req.user.userId;

    newImagePath = `/uploads/profiles/${req.file.filename}`;

    const oldProfile = await profileService.getMyProfile(userId);

    const profile = await profileService.updateProfileImage(
      userId,
      newImagePath
    );

    // Delete the previous image only if it belongs to our upload folder.
    const oldImagePath = oldProfile.profileImagePath;

    if (
      oldImagePath &&
      oldImagePath.startsWith('/uploads/profiles/')
    ) {
      const oldFileName = path.basename(oldImagePath);
      const oldFilePath = path.join(
        __dirname,
        '../../uploads/profiles',
        oldFileName
      );

      if (oldFileName && oldFileName !== req.file.filename) {
        await fs.unlink(oldFilePath).catch(error => {
          if (error.code !== 'ENOENT') {
            console.error('Could not delete old profile image:', error.message);
          }
        });
      }
    }

    return res.json({
      success: true,
      message: 'Profile image updated successfully',
      profile,
    });
  } catch (error) {
    // Avoid leaving the newly uploaded file behind after a failed update.
    if (req.file) {
      await fs.unlink(req.file.path).catch(() => {});
    }

    console.error('Upload profile image error:', error.message);

    return res.status(
      error.message === 'User not found' ? 404 : 500
    ).json({
      success: false,
      message: error.message,
    });
  }
}

module.exports = {
  getProfile,
  updateProfile,
  uploadProfileImage,
};
