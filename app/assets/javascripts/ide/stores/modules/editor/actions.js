import * as types from './mutation_types';

/**
 * Action to update the current file editor info at the given `path` with the given `data`
 *
 * @param {} vuex
 * @param {{ path: String, data: any }} payload
 */
export const updateFileEditor = ({ commit }, payload) => {
  commit(types.UPDATE_FILE_EDITOR, payload);
};
