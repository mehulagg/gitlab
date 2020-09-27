import { flatten } from 'lodash';

/**
 * Gets an object containing all keyboard shortcut customizations.
 * Default shortcuts are not included in this object.
 */
export const customizations = ({ keybindings }) => {
  return flatten(keybindings.map(group => group.keybindings)).reduce((acc, binding) => {
    const map = acc;

    if (binding.customKeys) {
      map[binding.command] = binding.customKeys;
    }

    return map;
  }, {});
};
