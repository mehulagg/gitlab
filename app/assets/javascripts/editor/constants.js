import { __ } from '~/locale';

export const EDITOR_LITE_INSTANCE_ERROR_NO_EL = __(
  '"el" parameter is required for createInstance()',
);

export const URI_PREFIX = 'gitlab';
export const CONTENT_UPDATE_DEBOUNCE = 250;

export const ERROR_INSTANCE_REQUIRED_FOR_EXTENSION = __(
  'Editor Lite instance is required to set up an extension.',
);

export const EDITOR_READY_EVENT = 'editor-ready';

//
// EXTENSIONS' CONSTANTS
//

// For CI config schemas the filename must match
// '*.gitlab-ci.yml' regardless of project configuration.
// https://gitlab.com/gitlab-org/gitlab/-/issues/293641
export const EXTENSION_CI_SCHEMA_FILE_NAME_MATCH = '.gitlab-ci.yml';
