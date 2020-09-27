import * as types from './mutation_types';

/**
 * Binds a new keyboard shortcut to a command
 * @param {Object} vuexStuff
 * @param {Object} actionParams
 * @param {string} actionParams.command The command to customize
 * @param {string[]} actionParams.newKeys The new keys to bind to the command
 */
export const updateKeybinding = ({ commit }, { command, newKeys }) => {
  commit(types.UPDATE_KEYBINDING, { command, newKeys });
};
