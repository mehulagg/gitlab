export const activeFile = state => state.openFiles.find(file => file.active) || null;

export const activeFileExtension = (state) => {
  const file = activeFile(state);
  return file ? `.${file.path.split('.').pop()}` : '';
};

export const canEditFile = (state) => {
  const currentActiveFile = activeFile(state);

  return state.canCommit &&
         (currentActiveFile && !currentActiveFile.renderError && !currentActiveFile.binary);
};

export const collapseButtonIcon = state => (state.rightPanelCollapsed ? 'angle-double-left' : 'angle-double-right');

export const unstagedFiles = state => state.changedFiles.filter(f => !f.staged);
