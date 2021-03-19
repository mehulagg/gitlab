import { __, s__ } from '~/locale';

export const SCAN_MODES = {
  HAR: {
    scanModeLabel: __('HAR (HTTP Archive)'),
    label: __('HAR file path'),
    placeholder: s__('APIFuzzing|Ex: Project_Test/File/example_fuzz.har'),
    description: s__(
      "APIFuzzing|HAR files may contain sensitive information such as authentication tokens, API keys, and session cookies. We recommend that you review the HAR files' contents before adding them to a repository.",
    ),
  },
  OPENAPI: {
    scanModeLabel: __('Open API'),
    label: __('Open API specification file path'),
    placeholder: s__('APIFuzzing|Ex: Project_Test/File/example_fuzz.json'),
    description: s__(
      'APIFuzzing|We recommend that you review the JSON specifications file before adding it to a repository.',
    ),
  },
  POSTMAN: {
    scanModeLabel: __('Postman collection'),
    label: __('Postman collection'),
    placeholder: s__('APIFuzzing|Ex: Project_Test/File/example_fuzz'),
    description: s__(
      'APIFuzzing|Postman collections are a group of saved requests you can organize into folders.',
    ),
  },
};

export const CONFIGURATION_SNIPPET_MODAL_ID = 'CONFIGURATION_SNIPPET_MODAL_ID';
