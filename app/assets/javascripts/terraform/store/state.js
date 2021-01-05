export default (initialState = {}) => ({
  emptyStateImage: initialState.emptyStateImage,
  projectPath: initialState.projectPath,
  terraformAdmin: 'terraformAdmin' in initialState,
});
