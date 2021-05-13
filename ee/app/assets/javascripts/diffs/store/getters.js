export * from '~/diffs/store/getters';

export const fileLineCodequality = (state) => (file, line) => {
  const fileDiff = state.codequalityDiff.files?.[file] || [];
  const lineDiff = fileDiff.filter((violation) => violation.line === line);
  return lineDiff;
};
