/* eslint-disable import/export */
export * from '~/diffs/store/getters';

// Returns the code quality degradations for a specific line of a given file
export const fileLineCodequality = (state) => (file, line) => {
  const fileDiff = state.codequalityDiff.files?.[file] || [];
  const lineDiff = fileDiff.filter((violation) => violation.line === line);
  return lineDiff;
};
