import Vue from 'vue';
import * as types from './mutation_types';

export default {
  [types.UPDATE_FILE_EDITOR](state, { path, data }) {
    Vue.set(state.fileEditors, path, {
      ...(state.fileEditors[path] || {}),
      data,
    });
  },
};
