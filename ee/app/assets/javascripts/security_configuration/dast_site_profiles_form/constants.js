import { s__ } from '~/locale';

export const MAX_CHAR_LIMIT_EXCLUDED_URLS = 2048;
export const MAX_CHAR_LIMIT_REQUEST_HEADERS = 2048;
export const EXCLUDED_URLS_SEPARATOR = ',';

export const siteTypes = {
  website: { value: 'WEBSITE', text: s__('DastProfiles|Website') },
  api: { value: 'API', text: s__('DastProfiles|Rest API') },
};
