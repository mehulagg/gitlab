import { uniqueId } from 'lodash';

export const getLicenseKey = ({ id }) => {
  if (id) {
    return `id_${id}`;
  }

  return `client_${uniqueId()}`;
};

/**
 * Maps an individual license response entity into the license object we'll store in our Vuex state
 * @param {Object} license
 */
export const toLicenseObject = (license) => ({
  ...license,
  key: getLicenseKey(license),
});
