
const multer = require('multer');
const fs = require('fs');
const path = require('path');

const uploadDirectory = path.join(
  __dirname,
  '../../uploads/profiles'
);

fs.mkdirSync(uploadDirectory, { recursive: true });

const allowedTypes = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
};

const storage = multer.diskStorage({
  destination: (req, file, callback) => {
    callback(null, uploadDirectory);
  },

  filename: (req, file, callback) => {
    const extension = allowedTypes[file.mimetype];

    if (!extension) {
      return callback(new Error('Unsupported image type'));
    }

    callback(
      null,
      `user-${req.user.userId}-${Date.now()}${extension}`
    );
  },
});

const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 1,
  },
  fileFilter: (req, file, callback) => {
    if (!allowedTypes[file.mimetype]) {
      return callback(
        new Error('Only JPG, PNG and WEBP images are allowed')
      );
    }

    callback(null, true);
  },
});

module.exports = upload;
