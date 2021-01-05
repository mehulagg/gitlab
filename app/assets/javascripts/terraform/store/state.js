export default (initialState = {}) => ({
  emptyStateImage: initialState.emptyStateImage,
  projectPath: initialState.projectPath,
  statesList: null,
  terraformAdmin: 'terraformAdmin' in initialState,
});
