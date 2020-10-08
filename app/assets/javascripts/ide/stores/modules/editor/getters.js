import { createDefaultFileEditor } from './utils';

export const activeFileEditor = (state, getters, rootState, rootGetters) => {
  const { path } = rootGetters.activeFile;

  const editor = state.fileEditors[path] || {};

  return {
    ...createDefaultFileEditor(),
    ...editor,
  };
};

export const getFileEditor = state => path => state.fileEditors[path] || createDefaultFileEditor();
