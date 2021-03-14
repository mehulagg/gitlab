/**
 * Tries to parse the given JSON string, but gracefully returns if there's an issue during parsing.
 *
 * This is helpful at building resiliency for non-crticial behavior.
 *
 * @param {String} str is JSON string which will be parsed
 * @param {*} opions.defaultValue this will be returned if the JSON fails to parse
 * @param {Boolean} options.warn indicates if a console.warn should be called if parsing fails
 * @returns If success, result of JSON.parse, otherwise, the given default value.
 */
export const tryJSONParse = (str, { defaultValue = null, warn = true } = {}) => {
  try {
    return JSON.parse(str);
  } catch (e) {
    if (warn) {
      // eslint-disable-next-line no-console
      console.warn('[gitlab] tried to parse JSON but failed with error', e);
    }

    return defaultValue;
  }
};
