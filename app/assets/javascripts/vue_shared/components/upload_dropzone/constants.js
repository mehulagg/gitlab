// WARNING: replace this with something that matches server
// allowed types https://gitlab.com/gitlab-org/gitlab/issues/118611
export const VALID_IMAGE_FILE_MIMETYPE = {
  mimetype: 'image/*',
  regex: /image\/.+/,
};

// https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/types
export const VALID_DATA_TRANSFER_TYPE = 'Files';
