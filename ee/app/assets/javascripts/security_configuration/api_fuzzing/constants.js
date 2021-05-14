import { __, s__ } from '~/locale';

export const SCAN_MODES = {
  HAR: {
    scanModeLabel: __('HAR (HTTP Archive)'),
    label: __('HAR file path'),
    placeholder: s__('APIFuzzing|/folder/example_file.har'),
    description: s__(
      "APIFuzzing|File path containing APIs to be tested. For example, /folder/example_file.har. HAR files may contain sensitive information such as authentication tokens, API keys, and session cookies. We recommend that you review the HAR files' contents before adding them to a repository.",
    ),
  },
  OPENAPI: {
    scanModeLabel: __('OpenAPI'),
    label: __('OpenAPI specification file path'),
    placeholder: s__('APIFuzzing|/folder/example_file.json'),
    description: s__(
      'APIFuzzing|File path containing APIs to be tested. For example, /folder/example_file.json.',
    ),
  },
  POSTMAN: {
    scanModeLabel: __('Postman collection'),
    label: __('Postman collection'),
    placeholder: s__('APIFuzzing|/folder/example_file.postman_collection.json'),
    description: s__(
      'APIFuzzing|File path containing requests to be tested. For example, /folder/example_file.postman_collection.json.',
    ),
  },
};

export const CONFIGURATION_SNIPPET_MODAL_ID = 'CONFIGURATION_SNIPPET_MODAL_ID';
