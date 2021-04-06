import { helpPagePath } from '~/helpers/help_page_helper';

export const CODE_SNIPPET_SOURCE_URL_PARAM = 'code_snippet_copied_from';
export const CODE_SNIPPET_SOURCE_API_FUZZING = 'api_fuzzing';
export const CODE_SNIPPET_SOURCES = [CODE_SNIPPET_SOURCE_API_FUZZING];
export const CODE_SNIPPET_SOURCE_PATH = {
  [CODE_SNIPPET_SOURCE_API_FUZZING]: {
    configurationPathInjectKey: 'apiFuzzingConfigurationPath',
    docsPath: helpPagePath('user/application_security/api_fuzzing/index'),
  },
};
