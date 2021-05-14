/**
 * Returns `true` for non-empty string, otherwise returns `false`
 * @param {String} name
 *
 * @returns {Boolean}
 */
export const isNameFieldValid = (name) => {
  return Boolean(name?.length);
};
