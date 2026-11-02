
const express = require('express');

const router = express.Router();

const { requireAuth } = require('../middleware/authMiddleware');
const upload = require('../middleware/profileUpload');

const {
  getProfile,
  updateProfile,
  uploadProfileImage,
} = require('../controllers/profileController');

router.get('/', requireAuth, getProfile);

router.put('/', requireAuth, updateProfile);

router.put(
  '/image',
  requireAuth,
  upload.single('image'),
  uploadProfileImage
);

router.use((error, req, res, next) => {
  if (error instanceof require('multer').MulterError) {
    return res.status(400).json({
      success: false,
      message: error.code === 'LIMIT_FILE_SIZE'
        ? 'Image must not exceed 5 MB'
        : error.message,
    });
  }

  if (error.message === 'Unsupported image type' ||
      error.message === 'Only JPG, PNG and WEBP images are allowed') {
    return res.status(400).json({
      success: false,
      message: error.message,
    });
  }

  next(error);
});

module.exports = router;
