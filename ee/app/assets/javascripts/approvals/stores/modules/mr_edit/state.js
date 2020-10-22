import baseState from '../base/state';

export default () => ({
  ...baseState(),
  rulesToDelete: [],
  targetBranch: '',
});
