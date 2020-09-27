import Vue from 'vue';
import { flatten, isEqual } from 'lodash';
import * as types from './mutation_types';

export default {
  [types.UPDATE_KEYBINDING](state, { command, newKeys }) {
    const allKeybindings = flatten(state.keybindings.map(group => group.keybindings));

    const bindingToUpdate = allKeybindings.find(binding => binding.command === command);

    // TODO: Maybe come up with a better way to compare if two keybindings are the same.
    // This method will treat ['command+shift+p'] as different than ['shift+command+p'].
    // Or, ensure that whatever process is setting these keyboard shortcuts always
    // lists the keys in the same order.
    if (isEqual(bindingToUpdate.defaultKeys.sort(), newKeys.sort())) {
      // The customization is the same as the default, so delete the `customKeys` property
      Vue.delete(bindingToUpdate, 'customKeys');
    } else {
      // The customization is different than the default, so record the new keys in `customKeys`
      Vue.set(bindingToUpdate, 'customKeys', newKeys);
    }
  },
};
