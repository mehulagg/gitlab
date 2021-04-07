export * from '~/diffs/store/getters';

/**
 * Returns the codequality diff data for a given file
 * @param {string} filePath
 * @returns {Array}
 */
export const getDiffFileCodequality = (state) => (filePath) => {
  if (!state.codequalityDiff.files || !state.codequalityDiff.files[filePath]) return [];
  return state.codequalityDiff.files[filePath];
};
