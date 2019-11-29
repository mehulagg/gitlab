import { __, s__, sprintf } from '~/locale';

export const designDeletionError = (singular = true) => {
  const design = singular ? __('a design') : __('designs');
  return sprintf(s__('DesignManagement|We could not delete %{design}. Please try again.'), {
    design,
  });
};
export const ADD_DISCUSSION_COMMENT_ERROR = s__(
  'DesignManagement|Could not add a new comment. Please try again',
);
export const ADD_IMAGE_DIFF_NOTE_ERROR = s__(
  'DesignManagement|Could not create new discussion. Please try again.',
);
export const UPLOAD_DESIGN_ERROR = s__(
  'DesignManagement|Error uploading a new design. Please try again',
);
